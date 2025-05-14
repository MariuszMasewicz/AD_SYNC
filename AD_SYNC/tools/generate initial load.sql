SELECT 'exec ad_sync_owner.ad_sync_load.init_load(p_LOAD_TYPE => ''R'');' AS TEXT
  FROM DUAL
UNION ALL
SELECT *
  FROM (
  SELECT DISTINCT 'exec ad_sync_owner.ad_sync_load.add_user_to_load (p_username => '''
                  || UPPER(USERNAME)
                  || ''', p_REQUESTED_OPERATION => ''C'');' AS USERNAME
    FROM DBA_USERS
   WHERE UPPER(USERNAME) LIKE 'PL%'
   ORDER BY USERNAME
)
UNION ALL
-- The maximum length of the role name is 128 bytes.
SELECT *
  FROM (
  SELECT DISTINCT 'exec ad_sync_owner.ad_sync_load.add_group_to_load (p_groupname => '''
                  || UPPER(GRANTED_ROLE)
                  || ''', p_REQUESTED_OPERATION => ''C'');' AS GROPNAME
    FROM SYS.DBA_ROLE_PRIVS
   WHERE UPPER(GRANTEE) LIKE 'PL%'
   ORDER BY GROPNAME
)
UNION ALL
-- The maximum number of user-defined roles that can be enabled for a single user at one time is 148.
SELECT *
  FROM (
  SELECT DISTINCT 'exec ad_sync_owner.ad_sync_load.add_group_member_to_load (p_groupname => '''
                  || UPPER(GRANTED_ROLE)
                  || ''', p_member => '''
                  || UPPER(GRANTEE)
                  || ''', p_REQUESTED_OPERATION => ''C'');' AS GROUP_MEMBER
    FROM SYS.DBA_ROLE_PRIVS
   WHERE UPPER(GRANTEE) LIKE 'PL%'
   ORDER BY GROUP_MEMBER
)
UNION ALL
SELECT 'exec ad_sync_owner.ad_sync_load.finish_load;'
  FROM DUAL;