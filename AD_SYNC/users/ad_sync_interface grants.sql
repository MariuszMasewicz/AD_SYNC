prompt ad_sync_interface_grants


GRANT connect TO ad_sync_interface ;

GRANT execute ON ad_sync_owner.ad_sync_load TO ad_sync_interface ;
grant read on ad_sync_owner.ad_sync_users to ad_sync_interface;
grant read on ad_sync_owner.ad_sync_statuses to ad_sync_interface;
grant read on ad_sync_owner.AD_SYNC_PROCESSING_STATUS_USERS to ad_sync_interface;
grant read on AD_SYNC_OWNER.AD_SYNC_MANAGED_USERS to ad_sync_interface;

grant select on sys.dba_users to ad_sync_interface;
grant select on sys.dba_roles to ad_sync_interface;
grant select on sys.dba_role_privs to ad_sync_interface;
grant select on sys.role_role_privs to ad_sync_interface;