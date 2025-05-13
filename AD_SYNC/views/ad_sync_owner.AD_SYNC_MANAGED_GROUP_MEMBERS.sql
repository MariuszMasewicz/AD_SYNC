prompt CREATE OR REPLACE VIEW ad_sync_owner.AD_SYNC_MANAGED_GROUP_MEMBERS

CREATE OR REPLACE VIEW AD_SYNC_OWNER.AD_SYNC_MANAGED_GROUP_MEMBERS AS
 /*
select ROLE,	GRANTED_ROLE as member,	ADMIN_OPTION,	COMMON,	INHERITED 
from sys.role_role_privs 
where role like ad_sync_owner.ad_sync_tools.get_param_value('GROUPNAME_PREFIX')||'%' 
and GRANTED_ROLE  like ad_sync_owner.ad_sync_tools.get_param_value('GROUPNAME_PREFIX')||'%' 
union all */
    SELECT
        GRANTED_ROLE    AS GROUPNAME,
        GRANTEE         AS GROUP_MEMBER,
        ADMIN_OPTION,
        DELEGATE_OPTION,
        DEFAULT_ROLE,
        COMMON,
        INHERITED
    FROM
        SYS.DBA_ROLE_PRIVS
    WHERE
        GRANTEE LIKE AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('USERNAME_PREFIX')
                                                 ||'%'
        AND GRANTED_ROLE LIKE AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('GROUPNAME_PREFIX')
                                                          ||'%'
    ORDER BY
        GRANTED_ROLE,
        GRANTEE;