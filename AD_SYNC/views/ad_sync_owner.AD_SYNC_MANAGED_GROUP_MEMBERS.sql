prompt CREATE OR REPLACE VIEW ad_sync_owner.AD_SYNC_MANAGED_GROUP_MEMBERS

CREATE OR REPLACE VIEW ad_sync_owner.AD_SYNC_MANAGED_GROUP_MEMBERS
as
/*
select ROLE,	GRANTED_ROLE as member,	ADMIN_OPTION,	COMMON,	INHERITED 
from sys.role_role_privs 
where role like ad_sync_owner.ad_sync_tools.get_param_value('GROUPNAME_PREFIX')||'%' 
and GRANTED_ROLE  like ad_sync_owner.ad_sync_tools.get_param_value('GROUPNAME_PREFIX')||'%' 
union all */
select GRANTED_ROLE as groupname,	GRANTEE as group_member,	ADMIN_OPTION, DELEGATE_OPTION, DEFAULT_ROLE,	COMMON,	INHERITED 
from sys.dba_role_privs 
where GRANTEE like ad_sync_owner.ad_sync_tools.get_param_value('USERNAME_PREFIX')||'%' 
and GRANTED_ROLE  like ad_sync_owner.ad_sync_tools.get_param_value('GROUPNAME_PREFIX')||'%' 
order by GRANTED_ROLE,	GRANTEE;
