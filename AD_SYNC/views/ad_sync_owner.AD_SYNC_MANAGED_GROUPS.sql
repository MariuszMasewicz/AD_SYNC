prompt CREATE OR REPLACE VIEW ad_sync_owner.AD_SYNC_MANAGED_GROUPS

CREATE OR REPLACE VIEW ad_sync_owner.AD_SYNC_MANAGED_GROUPS
as
select ROLE as groupname, ROLE_ID,	PASSWORD_REQUIRED,	AUTHENTICATION_TYPE,	COMMON,	ORACLE_MAINTAINED,	INHERITED,	IMPLICIT,	EXTERNAL_NAME 
from sys.dba_roles 
where role like ad_sync_owner.ad_sync_tools.get_param_value('GROUPNAME_PREFIX')||'%' 
order by role;

