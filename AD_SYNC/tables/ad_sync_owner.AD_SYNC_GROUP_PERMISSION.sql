prompt CREATE TABLE ad_sync_owner.AD_SYNC_GROUPS_PERMISSION

CREATE TABLE AD_SYNC_OWNER.AD_SYNC_GROUP_PERMISSION (
  ID NUMBER DEFAULT AD_SYNC_OWNER.AD_SYNC_GROUPS_SEQ.NEXTVAL
, GROUPNAME VARCHAR2(1000 BYTE) NOT NULL ENABLE
, SCHEMA VARCHAR2(128 BYTE)
, OBJECT_NAME VARCHAR2(128 BYTE)
, PERMISSION VARCHAR2(256 BYTE)
, CREATED_TIMESTAMP TIMESTAMP (6) DEFAULT ON NULL SYSTIMESTAMP NOT NULL ENABLE
, CREATED_USER VARCHAR2(255 CHAR) DEFAULT ON NULL USER NOT NULL ENABLE
, UPDATED_TIMESTAMP TIMESTAMP (6)
, UPDATED_USER VARCHAR2(255 CHAR)
, PRIMARY KEY (ID)
);


ALTER TABLE AD_SYNC_OWNER.AD_SYNC_GROUP_PERMISSION
ADD CONSTRAINT AD_SYNC_GROUP_PERMISSION_UK1 UNIQUE 
(
  GROUPNAME 
, SCHEMA 
, OBJECT_NAME 
, PERMISSION 
)
ENABLE;


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

------ grant object privileges
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

-- grant system privileges and roles
set serveroutput on
begin
for j in (select 'grant '||permission||'  to '||groupname as stmt 
from AD_SYNC_OWNER.AD_SYNC_GROUP_PERMISSION
where schema = '*'
and object_name is null) 
loop
begin
dbms_output.put_line(j.stmt);
execute immediate j.stmt;
exception
  when others then dbms_output.put_line('ERROR: '||j.stmt);
end;  
end loop;
end;
/
*/