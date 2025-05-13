BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => '"AD_SYNC_OWNER"."AD_SYNC_REFRESH_ROLES"',
            job_type => 'PLSQL_BLOCK',
            job_action => 'declare
v_process_run number := ad_sync_owner.AD_SYNC_PROCESS_RUN_seq.nextval;
begin
ad_sync_owner.AD_SYNC_PROCESS_GROUP_PRIVILEGES.ADD_SYSTEM_PRIVILEGES_AND_ROLES(v_process_run);
ad_sync_owner.AD_SYNC_PROCESS_GROUP_PRIVILEGES.ADD_OBJECT_PRIVILEGES(v_process_run);
end;',
            number_of_arguments => 0,
            start_date => NULL,
            repeat_interval => 'FREQ=DAILY;BYTIME=212000',
            end_date => NULL,
            enabled => FALSE,
            auto_drop => FALSE,
            comments => '');

         
     
 
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => '"AD_SYNC_OWNER"."AD_SYNC_REFRESH_ROLES"', 
             attribute => 'store_output', value => TRUE);
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => '"AD_SYNC_OWNER"."AD_SYNC_REFRESH_ROLES"', 
             attribute => 'logging_level', value => DBMS_SCHEDULER.LOGGING_OFF);
      
   
  
    
    --DBMS_SCHEDULER.enable(name => '"AD_SYNC_OWNER"."AD_SYNC_REFRESH_ROLES"');
END;
