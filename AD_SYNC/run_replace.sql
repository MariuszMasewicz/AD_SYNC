set serveroutput on
set echo on 

@views/ad_sync_owner.AD_SYNC_MANAGED_USERS.sql
@views/ad_sync_owner.AD_SYNC_MANAGED_GROUPS.sql
@views/ad_sync_owner.AD_SYNC_MANAGED_GROUP_MEMBERS.sql
@views/ad_sync_owner.AD_SYNC_PROCESSING_STATUS_USERS.sql

@packages/ad_sync_owner.ad_sync_load.sql
@packages/ad_sync_owner.ad_sync_log.sql
@packages/ad_sync_owner.ad_sync_tools.sql
@packages/ad_sync_owner.ad_sync_process_users.sql
@packages/ad_sync_owner.ad_sync_process_groups.sql
@packages/ad_sync_owner.ad_sync_process_group_members.sql
@packages/ad_sync_owner.ad_sync_process_group_privileges.sql

@jobs/AD_SYNC_PROCESS_LOAD.sql
@jobs/AD_SYNC_REFRESH_ROLES.sql


@scripts/compile_all.sql
@scripts/invalid_objects_check.sql

@users/ad_sync_owner_grants.sql
@users/ad_sync_interface_grants.sql