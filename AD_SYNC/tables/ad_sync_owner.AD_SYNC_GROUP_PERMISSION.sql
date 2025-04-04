prompt CREATE TABLE ad_sync_owner.AD_SYNC_GROUPS_PERMISSION

CREATE TABLE ad_sync_owner.AD_SYNC_GROUP_PERMISSION
(
  ID NUMBER DEFAULT ad_sync_owner.AD_SYNC_GROUP_PERMISSION_seq.nextval PRIMARY KEY
, GROUPNAME VARCHAR2(1000) NOT NULL 
,SCHEMA                   VARCHAR2(128) not null default '*'
,OBJECT_NAME             VARCHAR2(128) not null default '*'
,PERMISSION     Varchar2(256) not null default '*'
,	created_timestamp   TIMESTAMP(6) DEFAULT on null systimestamp NOT NULL,
  created_user        VARCHAR2(255 CHAR) DEFAULT on null user NOT NULL,
  updated_timestamp   TIMESTAMP(6),
  updated_user        VARCHAR2(255 CHAR)
);


/*
ALTER TABLE AD_SYNC_OWNER.AD_SYNC_GROUP_PERMISSION  
MODIFY (ID DEFAULT ad_sync_owner.AD_SYNC_GROUP_PERMISSION_seq.nextval );

ALTER TABLE AD_SYNC_OWNER.AD_SYNC_GROUP_PERMISSION  
MODIFY (SCHEMA NOT NULL);

ALTER TABLE AD_SYNC_OWNER.AD_SYNC_GROUP_PERMISSION  
MODIFY (OBJECT_NAME DEFAULT '*' NOT NULL);

ALTER TABLE AD_SYNC_OWNER.AD_SYNC_GROUP_PERMISSION  
MODIFY (PERMISSION DEFAULT '*' NOT NULL);
*/

/*
select 
'INSERT INTO ad_sync_owner.ad_sync_group_permission (id,groupname,schema,object_name,permission) VALUES (1,''AT_TEST_ITTESTER'','''||owner||''','''||table_name||''','''||privilege||''');'
from dba_tab_privs
where grantee ='AD_TEST_USER1'
and owner <> 'SYS'
and privilege in ('SELECT', 'READ');   

SELECT 'grant '||permission||' on '||schema||'.'||object_name ||' to '||groupname||';'
  from  ad_sync_owner.ad_sync_group_permission
    where object_name <>'*';
*/

/*
select * 
from AD_SYNC_OWNER.AD_SYNC_GROUP_PERMISSION
where schema <> '*'
and object_name='*';

set serveroutput on
begin
for j in (select * 
from AD_SYNC_OWNER.AD_SYNC_GROUP_PERMISSION
where schema <> '*'
and object_name='*') loop
for i in (select 'grant '||j.permission||' on '||j.schema||'.'||object_name||' to '||j.groupname as stmt
          from dba_objects 
          where owner=j.schema
          and object_type in ('TABLE', 'VIEW', 'MATERIALIZED VIEW')
          order by object_type, object_name)
loop
begin
dbms_output.put_line(i.stmt);
execute immediate i.stmt;
exception
  when others then dbms_output.put_line('ERROR: '||i.stmt);
end;  
end loop;
end loop;
end;
/
*/