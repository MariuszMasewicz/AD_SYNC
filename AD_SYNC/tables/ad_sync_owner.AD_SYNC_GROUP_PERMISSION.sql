prompt CREATE TABLE ad_sync_owner.AD_SYNC_GROUPS_PERMISSION

CREATE TABLE ad_sync_owner.AD_SYNC_GROUP_PERMISSION
(
  ID NUMBER DEFAULT ad_sync_owner.AD_SYNC_GROUPS_seq.nextval PRIMARY KEY
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