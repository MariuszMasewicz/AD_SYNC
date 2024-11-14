prompt CREATE OR REPLACE VIEW ad_sync_owner.AD_SYNC_MANAGED_USERS

CREATE OR REPLACE VIEW ad_sync_owner.AD_SYNC_MANAGED_USERS
as
select * 
from sys.dba_users 
where username like ad_sync_owner.ad_sync_tools.get_param_value('USERNAME_PREFIX')||'%' 
order by username;