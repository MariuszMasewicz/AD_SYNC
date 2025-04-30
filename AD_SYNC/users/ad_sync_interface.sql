prompt ad_sync_interface 
DROP USER ad_sync_interface cascade;

prompt CREATE USER ad_sync_interface
-- USER SQL
CREATE USER ad_sync_interface IDENTIFIED BY &ad_sync_interface_passwd.  
DEFAULT TABLESPACE &ad_sync_interface_tablespace.
TEMPORARY TABLESPACE &temp_tablespace.;
-- SYSTEM PRIVILEGES
