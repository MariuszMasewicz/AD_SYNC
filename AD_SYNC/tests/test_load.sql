set serveroutput on;

--version 1
exec ad_sync_owner.ad_sync_load.init_load(p_LOAD_TYPE => 'R'); 
exec ad_sync_owner.ad_sync_load.add_user_to_load (p_username => 'ad_test_user1', p_REQUESTED_OPERATION => 'C');
exec ad_sync_owner.ad_sync_load.add_user_to_load (p_username => 'ad_test_user2', p_REQUESTED_OPERATION => 'C');
exec ad_sync_owner.ad_sync_load.add_group_to_load (p_groupname => 'ad_test_group1', p_REQUESTED_OPERATION => 'C');
exec ad_sync_owner.ad_sync_load.add_group_to_load (p_groupname => 'ad_test_group2', p_REQUESTED_OPERATION => 'C');
exec ad_sync_owner.ad_sync_load.add_group_to_load (p_groupname => 'ad_test_group3', p_REQUESTED_OPERATION => 'C');
exec ad_sync_owner.ad_sync_load.add_group_to_load (p_groupname => 'ad_test_group4', p_REQUESTED_OPERATION => 'C');
exec ad_sync_owner.ad_sync_load.add_group_member_to_load (p_groupname => 'ad_test_group1', p_member => 'ad_test_user1', p_REQUESTED_OPERATION => 'C');
exec ad_sync_owner.ad_sync_load.add_group_member_to_load (p_groupname => 'ad_test_group1', p_member => 'ad_test_user2', p_REQUESTED_OPERATION => 'C');
exec ad_sync_owner.ad_sync_load.add_group_member_to_load (p_groupname => 'ad_test_group1', p_member => 'ad_test_user1', p_REQUESTED_OPERATION => 'C');
exec ad_sync_owner.ad_sync_load.add_group_member_to_load (p_groupname => 'ad_test_group1', p_member => 'ad_test_user2', p_REQUESTED_OPERATION => 'C');
exec ad_sync_owner.ad_sync_load.add_group_member_to_load (p_groupname => 'ad_test_group3', p_member => 'ad_test_user1', p_REQUESTED_OPERATION => 'C');
exec ad_sync_owner.ad_sync_load.add_group_member_to_load (p_groupname => 'ad_test_group3', p_member => 'ad_test_group1', p_REQUESTED_OPERATION => 'C');
exec ad_sync_owner.ad_sync_load.add_group_member_to_load (p_groupname => 'ad_test_group3', p_member => 'ad_test_group2', p_REQUESTED_OPERATION => 'C');
exec ad_sync_owner.ad_sync_load.add_group_member_to_load (p_groupname => 'ad_test_group4', p_member => 'ad_test_user2', p_REQUESTED_OPERATION => 'C');
exec ad_sync_owner.ad_sync_load.add_user_to_load (p_username => 'ad_aa_test_user1', p_REQUESTED_OPERATION => 'C');
exec ad_sync_owner.ad_sync_load.finish_load;

--version 2
exec ad_sync_owner.ad_sync_load.init_load(p_LOAD_TYPE => 'R');
exec ad_sync_owner.ad_sync_load.add_user_to_load ('ad_test_user1','C');
/* bad data */
exec ad_sync_owner.ad_sync_load.add_user_to_load ('','C'); 
exec ad_sync_owner.ad_sync_load.add_user_to_load ('ad_test_user2','C');
exec ad_sync_owner.ad_sync_load.add_group_to_load ('ad_test_group1','C');
/* bad data */
exec ad_sync_owner.ad_sync_load.add_group_to_load ('','C');
exec ad_sync_owner.ad_sync_load.add_group_to_load ('ad_test_group2','C');
exec ad_sync_owner.ad_sync_load.add_group_to_load ('ad_test_group3','C');
exec ad_sync_owner.ad_sync_load.add_group_to_load ('ad_test_group4','C');
exec ad_sync_owner.ad_sync_load.add_group_member_to_load ('ad_test_group1', 'ad_test_user1'),'C';
exec ad_sync_owner.ad_sync_load.add_group_member_to_load ('ad_test_group1', 'ad_test_user2','C');
exec ad_sync_owner.ad_sync_load.add_group_member_to_load ('ad_test_group1', 'ad_test_user1','C');
exec ad_sync_owner.ad_sync_load.add_group_member_to_load ('ad_test_group1', 'ad_test_user2','C');
exec ad_sync_owner.ad_sync_load.add_group_member_to_load ('ad_test_group3', 'ad_test_user1','C');
exec ad_sync_owner.ad_sync_load.add_group_member_to_load ('ad_test_group3', 'ad_test_group1','C');
exec ad_sync_owner.ad_sync_load.add_group_member_to_load ('ad_test_group3', 'ad_test_group2','C');
exec ad_sync_owner.ad_sync_load.add_group_member_to_load ('ad_test_group4', 'ad_test_user2','C');
/* bad prefix */
exec ad_sync_owner.ad_sync_load.add_user_to_load ('ad_aa_test_user1','C'); 
exec ad_sync_owner.ad_sync_load.finish_load;
