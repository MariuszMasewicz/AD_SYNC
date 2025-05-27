BEGIN
  DBMS_SCHEDULER.CREATE_JOB(
    JOB_NAME            => '"AD_SYNC_OWNER"."AD_SYNC_PROCESS_LOAD"'
   ,JOB_TYPE            => 'PLSQL_BLOCK'
   ,JOB_ACTION          => 'declare
v_start_timestamp timestamp;
v_end_timestamp timestamp;
v_load_id number;
v_process_run number := ad_sync_owner.AD_SYNC_PROCESS_RUN_seq.nextval;
begin
select  created_timestamp, load_id 
  into v_start_timestamp, v_load_id 
  from ad_sync_owner.AD_SYNC_HISTORY 
  where sync_status=2 
    and created_timestamp = (select  max(created_timestamp)from ad_sync_owner.AD_SYNC_HISTORY where sync_status=2);
select  max(created_timestamp) 
  into v_end_timestamp from ad_sync_owner.AD_SYNC_HISTORY 
  where sync_status=3;
ad_sync_owner.ad_sync_process_users.mark_existing_users (v_start_timestamp,  v_end_timestamp ,v_process_run, v_load_id);
ad_sync_owner.ad_sync_process_users.add_users (v_start_timestamp,  v_end_timestamp , v_process_run, v_load_id);
ad_sync_owner.ad_sync_process_users.lock_users (v_start_timestamp,  v_end_timestamp ,v_process_run, v_load_id);
ad_sync_owner.ad_sync_process_users.unlock_users (v_start_timestamp,  v_end_timestamp ,v_process_run, v_load_id);
ad_sync_owner.ad_sync_process_users.change_password (v_start_timestamp,  v_end_timestamp ,v_process_run, v_load_id);
ad_sync_owner.ad_sync_process_users.expire_password (v_start_timestamp,  v_end_timestamp ,v_process_run, v_load_id);
ad_sync_owner.ad_sync_process_users.drop_users (v_start_timestamp,  v_end_timestamp ,v_process_run, v_load_id);

ad_sync_owner.ad_sync_process_groups.add_groups (v_start_timestamp,  v_end_timestamp ,v_process_run, v_load_id);
ad_sync_owner.ad_sync_process_groups.mark_existing_groups (v_start_timestamp,  v_end_timestamp ,v_process_run, v_load_id);

ad_sync_owner.ad_sync_process_group_members.mark_existing_group_members (v_start_timestamp,  v_end_timestamp ,v_process_run, v_load_id);
ad_sync_owner.ad_sync_process_group_members.add_group_members (v_start_timestamp,  v_end_timestamp ,v_process_run, v_load_id);
ad_sync_owner.ad_sync_process_group_members.drop_group_members_on_demand (v_start_timestamp,  v_end_timestamp ,v_process_run, v_load_id);

end;
'
   ,NUMBER_OF_ARGUMENTS => 0
   ,START_DATE          => NULL
   ,REPEAT_INTERVAL     => 'FREQ=HOURLY;BYTIME=2000'
   ,END_DATE            => NULL
   ,ENABLED             => FALSE
   ,AUTO_DROP           => FALSE
   ,COMMENTS            => ''
  );
  DBMS_SCHEDULER.SET_ATTRIBUTE(
    NAME      => '"AD_SYNC_OWNER"."AD_SYNC_PROCESS_LOAD"'
   ,ATTRIBUTE => 'store_output'
   ,VALUE     => TRUE
  );
  DBMS_SCHEDULER.SET_ATTRIBUTE(
    NAME      => '"AD_SYNC_OWNER"."AD_SYNC_PROCESS_LOAD"'
   ,ATTRIBUTE => 'logging_level'
   ,VALUE     => DBMS_SCHEDULER.LOGGING_OFF
  );
 
  --DBMS_SCHEDULER.enable(name => '"AD_SYNC_OWNER"."AD_SYNC_PROCESS_LOAD"');
END;
/