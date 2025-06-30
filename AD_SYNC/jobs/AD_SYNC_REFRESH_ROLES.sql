BEGIN
    DBMS_SCHEDULER.DROP_JOB(job_name => '"AD_SYNC_OWNER"."AD_SYNC_REFRESH_ROLES"',
                                defer => false,
                                force => false);
END;
/

BEGIN
  DBMS_SCHEDULER.CREATE_JOB(
    JOB_NAME            => '"AD_SYNC_OWNER"."AD_SYNC_REFRESH_ROLES"'
   ,JOB_TYPE            => 'PLSQL_BLOCK'
   ,JOB_ACTION          => 'declare
v_process_run number := ad_sync_owner.AD_SYNC_PROCESS_RUN_seq.nextval;
begin
ad_sync_owner.AD_SYNC_PROCESS_GROUP_PRIVILEGES.clean_all_groups(v_process_run);
ad_sync_owner.AD_SYNC_PROCESS_GROUP_PRIVILEGES.ADD_SYSTEM_PRIVILEGES_AND_ROLES(v_process_run);
ad_sync_owner.AD_SYNC_PROCESS_GROUP_PRIVILEGES.ADD_OBJECT_PRIVILEGES(v_process_run);
ad_sync_owner.ad_sync_process_group_tablespace_quotas.ADD_GROUP_MEMBERS_TABLESPACE_QUOTAS(v_process_run);
end;'
   ,NUMBER_OF_ARGUMENTS => 0
   ,START_DATE          => NULL
   ,REPEAT_INTERVAL     => 'FREQ=DAILY;BYTIME=212000'
   ,END_DATE            => NULL
   ,ENABLED             => FALSE
   ,AUTO_DROP           => FALSE
   ,COMMENTS            => ''
  );
  DBMS_SCHEDULER.SET_ATTRIBUTE(
    NAME      => '"AD_SYNC_OWNER"."AD_SYNC_REFRESH_ROLES"'
   ,ATTRIBUTE => 'store_output'
   ,VALUE     => TRUE
  );
  DBMS_SCHEDULER.SET_ATTRIBUTE(
    NAME      => '"AD_SYNC_OWNER"."AD_SYNC_REFRESH_ROLES"'
   ,ATTRIBUTE => 'logging_level'
   ,VALUE     => DBMS_SCHEDULER.LOGGING_OFF
  );
 
    --DBMS_SCHEDULER.enable(name => '"AD_SYNC_OWNER"."AD_SYNC_REFRESH_ROLES"');
END;
/
