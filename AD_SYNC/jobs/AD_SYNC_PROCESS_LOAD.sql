BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => '"AD_SYNC_OWNER"."AD_SYNC_PROCESS_LOAD"',
            job_type => 'PLSQL_BLOCK',
            job_action => 'declare
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

ad_sync_owner.ad_sync_process_group_members.add_group_members (v_start_timestamp,  v_end_timestamp ,v_process_run, v_load_id);

end;
',
            number_of_arguments => 0,
            start_date => NULL,
            repeat_interval => 'FREQ=HOURLY;BYTIME=2000',
            end_date => NULL,
            enabled => FALSE,
            auto_drop => FALSE,
            comments => '');

         
     
 
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => '"AD_SYNC_OWNER"."AD_SYNC_PROCESS_LOAD"', 
             attribute => 'store_output', value => TRUE);
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => '"AD_SYNC_OWNER"."AD_SYNC_PROCESS_LOAD"', 
             attribute => 'logging_level', value => DBMS_SCHEDULER.LOGGING_OFF);
      
   
  
    
    DBMS_SCHEDULER.enable(
             name => '"AD_SYNC_OWNER"."AD_SYNC_PROCESS_LOAD"');
END;
/
