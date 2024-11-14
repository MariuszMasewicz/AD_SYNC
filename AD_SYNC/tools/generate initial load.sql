select 'exec ad_sync_owner.ad_sync_load.init_load(p_LOAD_TYPE => ''R'');' as text from dual
union all
select * from 
  (select distinct 'exec ad_sync_owner.ad_sync_load.add_user_to_load (p_username => '''||upper(username)||''', p_REQUESTED_OPERATION => ''C'');' as username from dba_users where upper(username) like 'PL%' order by username)
union all
-- The maximum length of the role name is 128 bytes.
select * from 
  (select distinct 'exec ad_sync_owner.ad_sync_load.add_group_to_load (p_groupname => '''||upper(granted_role)||''', p_REQUESTED_OPERATION => ''C'');' as gropname from sys.dba_role_privs where upper(grantee) like 'PL%' order by gropname)
union all
-- The maximum number of user-defined roles that can be enabled for a single user at one time is 148.
select * from 
  (select distinct 'exec ad_sync_owner.ad_sync_load.add_group_member_to_load (p_groupname => '''||upper(granted_role)||''', p_member => '''||upper(grantee)||''', p_REQUESTED_OPERATION => ''C'');' as group_member from sys.dba_role_privs where upper(grantee) like 'PL%' order by group_member)
union all
select 'exec ad_sync_owner.ad_sync_load.finish_load;' from dual;