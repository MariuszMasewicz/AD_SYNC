prompt ad_sync_owner_grants 

-- SYSTEM PRIVILEGES
GRANT connect TO ad_sync_owner ;
GRANT CREATE TABLE TO ad_sync_owner ;
GRANT CREATE PROCEDURE TO ad_sync_owner ;
GRANT CREATE VIEW TO ad_sync_owner ;
GRANT CREATE SEQUENCE TO ad_sync_owner ;
GRANT INHERIT PRIVILEGES ON USER SYS TO ad_sync_owner;

grant select on sys.dba_users to ad_sync_owner with grant option; 
grant select on sys.dba_roles to ad_sync_owner with grant option;
grant select on sys.dba_role_privs to ad_sync_owner with grant option;
grant select on sys.role_role_privs to ad_sync_owner with grant option;
