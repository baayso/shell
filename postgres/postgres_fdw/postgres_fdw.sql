-- PostgreSQL 9.5 新特性之 - 水平分片架构与实践
-- https://yq.aliyun.com/articles/6635?spm=0.0.0.0.d0zZXX

-- 创建5个数据库，1个master库用于存放全局数据和数据分片的定义，数据路由算法；4个下层节点数据库，用于存放数据分片；
create database db0;
create database db1;
create database db2;
create database db3;
create database master;

-- 连接到master库，创建外部server
\c master
create extension postgres_fdw;
create server db0 foreign data wrapper postgres_fdw options (hostaddr '127.0.0.1', port '5432', dbname 'db0');
create server db1 foreign data wrapper postgres_fdw options (hostaddr '127.0.0.1', port '5432', dbname 'db1');
create server db2 foreign data wrapper postgres_fdw options (hostaddr '127.0.0.1', port '5432', dbname 'db2');
create server db3 foreign data wrapper postgres_fdw options (hostaddr '127.0.0.1', port '5432', dbname 'db3');

-- 创建user mapping
create user mapping for postgres server db0 options (user 'postgres', password 'postgres');
create user mapping for postgres server db1 options (user 'postgres', password 'postgres');
create user mapping for postgres server db2 options (user 'postgres', password 'postgres');
create user mapping for postgres server db3 options (user 'postgres', password 'postgres');

-- 连接到分片节点，创建分片表（表名请随意）
\c db0
create table tbl0(id int primary key, info text, crt_time timestamp);
alter table tbl0 add constraint ck1 check (abs(mod(id,4))=0);
\c db1
create table tbl1(id int primary key, info text, crt_time timestamp);
alter table tbl1 add constraint ck1 check (abs(mod(id,4))=1);
\c db2
create table tbl2(id int primary key, info text, crt_time timestamp);
alter table tbl2 add constraint ck1 check (abs(mod(id,4))=2);
\c db3
create table tbl3(id int primary key, info text, crt_time timestamp);
alter table tbl3 add constraint ck1 check (abs(mod(id,4))=3);

-- 连接到主节点，创建外部表，这里使用了import foreign schema语法，一键创建
\c master
import FOREIGN SCHEMA public from server db0 into public;
import FOREIGN SCHEMA public from server db1 into public;
import FOREIGN SCHEMA public from server db2 into public;
import FOREIGN SCHEMA public from server db3 into public;

-- 创建主表，用户操作主表即可（当然用户也可以直接操作子表，PostgreSQL不拦你）
create table tbl(id int primary key, info text, crt_time timestamp);

-- 设置外部表继承关系，继承到主表下面
alter foreign table tbl0 inherit tbl;
alter foreign table tbl1 inherit tbl;
alter foreign table tbl2 inherit tbl;
alter foreign table tbl3 inherit tbl;

-- 创建外部表的约束，约束即路由算法的一部分。
-- 注意，带约束条件的SQL，数据库会自动选择对应的外部表进行操作。
-- 不带约束条件的SQL，数据库会选择所有节点操作。
-- 所以建议每条SQL都带上约束条件。
alter foreign table tbl0 add constraint ck_tbl0 check (abs(mod(id,4))=0);
alter foreign table tbl1 add constraint ck_tbl1 check (abs(mod(id,4))=1);
alter foreign table tbl2 add constraint ck_tbl2 check (abs(mod(id,4))=2);
alter foreign table tbl3 add constraint ck_tbl3 check (abs(mod(id,4))=3);

-- 创建插入路由触发器函数
create or replace function f_tbl_ins() returns trigger as $$  
declare  
begin  
  case abs(mod(NEW.id, 4))   
    when 0 then  
      insert into tbl0 (id, info, crt_time) values (NEW.*);  
    when 1 then  
      insert into tbl1 (id, info, crt_time) values (NEW.*);  
    when 2 then  
      insert into tbl2 (id, info, crt_time) values (NEW.*);  
    when 3 then  
      insert into tbl3 (id, info, crt_time) values (NEW.*);  
    else  
      return null;  
  end case;  
    return null;  
end;  
$$ language plpgsql;

-- 创建插入触发器
create trigger tg1 before insert on tbl for each row execute procedure f_tbl_ins();

-- 测试插入路由是否正确
insert into tbl values (1,'abc',now());
insert into tbl values (2,'abc',now());

-- 支持绑定变量
prepare p1 (int,text,timestamp) as insert into tbl values ($1,$2,$3);
prepare p2 (int,int) as select * from tbl where id=$1 and abs(mod($1,4))=$2;
prepare p3 (int,int,text,timestamp) as update tbl set info=$3,crt_time=$4 where id=$1 and abs(mod($1,4))=$2;

execute p1(3,'abc',now());
execute p1(4,'abc',now());
execute p1(5,'abc',now());
execute p1(6,'abc',now());
execute p1(7,'abc',now());
execute p1(8,'abc',now());
execute p1(9,'abc',now());

execute p3(1,1,'test',now());
