set serveroutput on
set echo on 

/**** values used as initial values for table ad_sync_owner.AD_SYNC_PARAMETERS */
DEFINE username_prefix = AD_TEST
DEFINE groupname_prefix = AD_TEST
DEFINE user_pass_directory_location = '/oracle/ADimp'
DEFINE user_pass_directory_name = AD_SYNC_PASSWORDS

/**** values used as initial values for create users */
DEFINE temp_tablespace = temp
DEFINE ad_sync_owner_passwd = Passw0rd1
DEFINE ad_sync_owner_tablespace = ad_sync

DEFINE ad_sync_interface_passwd = Passw0rd2
DEFINE ad_sync_interface_tablespace = ad_sync

--@tablespace/ad_sync.sql

@users/ad_sync_owner.sql
@directories/ad_sync_passwords.sql

@sequences/ad_sync_owner_sequences.sql

@tables/ad_sync_owner.AD_SYNC_STATUSES.sql
@tables/ad_sync_owner.AD_SYNC_HISTORY_LOAD_TYPES.sql
@tables/ad_sync_owner.AD_SYNC_HISTORY.sql
@tables/ad_sync_owner.AD_SYNC_USERS_REQUEST_TYPES.sql
@tables/ad_sync_owner.AD_SYNC_USERS.sql
@tables/ad_sync_owner.AD_SYNC_GROUPS.sql
@tables/ad_sync_owner.AD_SYNC_GROUP_MEMBERS.sql
@tables/ad_sync_owner.AD_SYNC_PARAMETERS.sql
@tables/ad_sync_owner.AD_SYNC_LOG_TABLE_TYPE.sql
@tables/ad_sync_owner.AD_SYNC_LOG_TABLE.sql

@packages/ad_sync_owner.ad_sync_load.sql
@packages/ad_sync_owner.ad_sync_log.sql
@packages/ad_sync_owner.ad_sync_tools.sql
@packages/ad_sync_owner.ad_sync_process_users.sql
@packages/ad_sync_owner.ad_sync_process_groups.sql
@packages/ad_sync_owner.ad_sync_process_group_members.sql


@scripts/compile_all.sql
@scripts/invalid_objects_check.sql

@views/ad_sync_owner.AD_SYNC_MANAGED_USERS.sql
@views/ad_sync_owner.AD_SYNC_MANAGED_GROUPS.sql
@views/ad_sync_owner.AD_SYNC_MANAGED_GROUP_MEMBERS.sql
@views/ad_sync_owner.AD_SYNC_PROCESSING_STATUS_USERS.sql


@users/ad_sync_interface.sql


--@tests/test_scenario.sql

--drop role AD_TEST_1;
--drop role AD_TEST_2;

--CREATE ROLE "AD_TEST_1";
--CREATE ROLE "AD_TEST_2";
--grant ad_test_1 to ad_test_2;
--grant ad_test_1 to AD_TEST_USER1;

/*
select * from ad_sync_owner.AD_SYNC_LOG_TABLE order by log_id desc;
select * from ad_sync_owner.AD_SYNC_PARAMETERS;
select * from ad_sync_owner.ad_sync_users;
select * from all_users where username like '&username_prefix.'||'%'

select * from ad_sync_owner.AD_SYNC_MANAGED_USERS;
select * from ad_sync_owner.AD_SYNC_MANAGED_GROUPS;
select * from ad_sync_owner.AD_SYNC_MANAGED_GROUP_MEMBERS;


select * from dba_users where username like ad_sync_owner.ad_sync_tools.get_param_value('USERNAME_PREFIX')||'%' order by username;
select * from dba_roles;
select * from role_role_privs;
select * from dba_role_privs;

select ROLE,	GRANTED_ROLE,	ADMIN_OPTION,	COMMON,	INHERITED 
from sys.role_role_privs 
--where role like ad_sync_owner.ad_sync_tools.get_param_value('GROUPNAME_PREFIX')||'%' 
--and GRANTED_ROLE  like ad_sync_owner.ad_sync_tools.get_param_value('GROUPNAME_PREFIX')||'%' 
union all 
select GRANTED_ROLE,	GRANTEE,	ADMIN_OPTION,	COMMON,	INHERITED 
from sys.dba_role_privs 
--where username like ad_sync_owner.ad_sync_tools.get_param_value('USERNAME_PREFIX')||'%' 
--and GRANTED_ROLE  like ad_sync_owner.ad_sync_tools.get_param_value('GROUPNAME_PREFIX')||'%' ;

select ad_sync_owner.ad_sync_tools.get_param_value('USERNAME_PREFIX') from dual;
*/                