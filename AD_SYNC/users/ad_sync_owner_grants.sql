prompt ad_sync_owner_grants 

-- SYSTEM PRIVILEGES
GRANT connect TO ad_sync_owner ;
GRANT CREATE TABLE TO ad_sync_owner ;
GRANT CREATE PROCEDURE TO ad_sync_owner ;
GRANT CREATE VIEW TO ad_sync_owner ;
GRANT CREATE SEQUENCE TO ad_sync_owner ;
GRANT INHERIT PRIVILEGES ON USER SYS TO ad_sync_owner;

GRANT CREATE ROLE TO AD_SYNC_OWNER ;
GRANT GRANT ANY OBJECT PRIVILEGE TO AD_SYNC_OWNER ;
GRANT ALTER USER TO AD_SYNC_OWNER ;
GRANT CREATE USER TO AD_SYNC_OWNER ;
GRANT ALTER ANY ROLE TO AD_SYNC_OWNER ;
GRANT GRANT ANY PRIVILEGE TO AD_SYNC_OWNER ;
GRANT DROP USER TO AD_SYNC_OWNER ;
GRANT DROP ANY ROLE TO AD_SYNC_OWNER ;
GRANT GRANT ANY ROLE TO AD_SYNC_OWNER ;



grant select on sys.dba_users to ad_sync_owner with grant option; 
grant select on sys.dba_roles to ad_sync_owner with grant option;
grant select on sys.dba_role_privs to ad_sync_owner with grant option;
grant select on sys.role_role_privs to ad_sync_owner with grant option;
