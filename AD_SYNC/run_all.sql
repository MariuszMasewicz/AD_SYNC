   set serveroutput on
set echo on 

/**** values used as initial values for table ad_sync_owner.AD_SYNC_PARAMETERS */
DEFINE username_prefix = PL
DEFINE groupname_prefix = KSIWARCCDB02__MCC_
DEFINE user_pass_directory_location = '/oracle/ADimp/mcc'
DEFINE user_pass_directory_name = AD_SYNC_PASSWORDS

/**** values used as initial values for create users */
DEFINE temp_tablespace = temp
DEFINE ad_sync_owner_passwd = Passw0rd1
DEFINE ad_sync_owner_tablespace = ad_sync

DEFINE ad_sync_interface_passwd = Passw0rd2
DEFINE ad_sync_interface_tablespace = ad_sync

/*create as sys user*/
--@tablespace/ad_sync.sql
@functions/sys.ad_sync_default_password_verify_function.sql
@profiles/ad_sync_default_profile.sql
@profiles/ad_sync_service_account.sql
@users/ad_sync_owner.sql
@users/ad_sync_owner_grants.sql
@users/ad_sync_interface.sql


/*create as sys or dba user*/
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
@tables/ad_sync_owner.AD_SYNC_GROUP_PERMISSION.sql
@tables/ad_sync_owner.AD_SYNC_GROUP_TABLESPACE_QUOTAS.sql

@views/ad_sync_owner.AD_SYNC_MANAGED_USERS.sql
@views/ad_sync_owner.AD_SYNC_MANAGED_GROUPS.sql
@views/ad_sync_owner.AD_SYNC_MANAGED_GROUP_MEMBERS.sql
@views/ad_sync_owner.AD_SYNC_PROCESSING_STATUS_USERS.sql

@packages/ad_sync_owner.ad_sync_tools.sql
@packages/ad_sync_owner.ad_sync_log.sql
@packages/ad_sync_owner.ad_sync_load.sql
@packages/ad_sync_owner.ad_sync_process_users.sql
@packages/ad_sync_owner.ad_sync_process_groups.sql
@packages/ad_sync_owner.ad_sync_process_group_members.sql
@packages/ad_sync_owner.ad_sync_process_group_privileges.sql
@packages/ad_sync_owner.ad_sync_process_group_tablespace_quotas.sql

@jobs/AD_SYNC_PROCESS_LOAD.sql
@jobs/AD_SYNC_REFRESH_ROLES.sql


@scripts/compile_all.sql
@scripts/invalid_objects_check.sql

@users/ad_sync_interface_grants.sql