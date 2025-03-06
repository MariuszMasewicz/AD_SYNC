prompt DROP USER ad_sync_interface cascade
DROP USER ad_sync_interface cascade;

prompt CREATE USER ad_sync_interface
-- USER SQL
CREATE USER ad_sync_interface IDENTIFIED BY &ad_sync_interface_passwd.  
DEFAULT TABLESPACE &ad_sync_interface_tablespace.
TEMPORARY TABLESPACE &temp_tablespace.;
-- SYSTEM PRIVILEGES

GRANT connect TO ad_sync_interface ;

GRANT execute ON ad_sync_owner.ad_sync_load TO ad_sync_interface ;
grant read on ad_sync_owner.ad_sync_users to ad_sync_interface;
grant read on ad_sync_owner.ad_sync_statuses to ad_sync_interface;
grant read on ad_sync_owner.AD_SYNC_PROCESSING_STATUS_USERS to ad_sync_interface;

 