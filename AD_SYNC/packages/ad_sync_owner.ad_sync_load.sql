prompt CREATE OR REPLACE PACKAGE ad_sync_owner.ad_sync_load

CREATE OR REPLACE PACKAGE AD_SYNC_OWNER.AD_SYNC_LOAD AS
  PROCEDURE INIT_LOAD (
    P_LOAD_TYPE CHAR
  );

  PROCEDURE FINISH_LOAD;

  PROCEDURE ADD_USER_TO_LOAD (
    P_USERNAME            VARCHAR2
   ,P_PASSWORD            VARCHAR2 DEFAULT NULL
   ,P_REQUESTED_OPERATION CHAR DEFAULT 'C'
  );

  PROCEDURE ADD_GROUP_TO_LOAD (
    P_GROUPNAME           VARCHAR2
   ,P_REQUESTED_OPERATION CHAR DEFAULT 'C'
  );

  PROCEDURE ADD_GROUP_MEMBER_TO_LOAD (
    P_GROUPNAME           VARCHAR2
   ,P_MEMBER              VARCHAR2
   ,P_REQUESTED_OPERATION CHAR DEFAULT 'C'
  );
END AD_SYNC_LOAD;
/

prompt CREATE OR REPLACE PACKAGE BODY ad_sync_owner.ad_sync_load

CREATE OR REPLACE PACKAGE BODY AD_SYNC_OWNER.AD_SYNC_LOAD AS

  V_LOAD_ID NUMBER;
  v_start_timestamp timestamp;
  v_end_timestamp timestamp;

  PROCEDURE INIT_LOAD (
    P_LOAD_TYPE CHAR
  ) IS
  BEGIN
    v_start_timestamp := SYSTIMESTAMP;
    v_end_timestamp := NULL;
    V_LOAD_ID := AD_SYNC_OWNER.AD_SYNC_LOAD_SEQ.NEXTVAL;
    INSERT INTO AD_SYNC_OWNER.AD_SYNC_HISTORY (
      SYNC_STATUS
      ,LOAD_ID
      ,LOAD_TYPE
    ) VALUES ( 2
              ,V_LOAD_ID
              ,P_LOAD_TYPE ); -- sync started
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      AD_SYNC_OWNER.AD_SYNC_LOG.WRITE_ERROR(
        $$PLSQL_UNIT
        || '->init_load'
        || ':'
        || V_LOAD_ID
       ,SQLCODE
       ,SQLERRM
      );
      ROLLBACK;
      RAISE;
  END INIT_LOAD;

  PROCEDURE FINISH_LOAD IS
  v_process_run number := ad_sync_owner.AD_SYNC_PROCESS_RUN_seq.nextval;
  BEGIN
    INSERT INTO AD_SYNC_OWNER.AD_SYNC_HISTORY (
      LOAD_ID
      ,SYNC_STATUS
    ) VALUES ( V_LOAD_ID
              ,3 ); -- sync finished
        --DBMS_SCHEDULER.RUN_JOB(job_name => '"AD_SYNC_OWNER"."AD_SYNC_PROCESS_LOAD"', USE_CURRENT_SESSION => FALSE);
    COMMIT;
    v_end_timestamp := SYSTIMESTAMP;

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


  EXCEPTION
    WHEN OTHERS THEN
      AD_SYNC_OWNER.AD_SYNC_LOG.WRITE_ERROR(
        $$PLSQL_UNIT
        || '->finish_load'
        || ':'
        || V_LOAD_ID
       ,SQLCODE
       ,SQLERRM
      );
      ROLLBACK;
      RAISE;
  END FINISH_LOAD;

  PROCEDURE ADD_USER_TO_LOAD (
    P_USERNAME            VARCHAR2
   ,P_PASSWORD            VARCHAR2 DEFAULT NULL
   ,P_REQUESTED_OPERATION CHAR DEFAULT 'C'
  ) IS
  BEGIN
    INSERT INTO AD_SYNC_OWNER.AD_SYNC_USERS (
      USERNAME
      ,PASSWORD
      ,REQUESTED_OPERATION
      ,LOAD_ID
    ) VALUES ( UPPER(P_USERNAME)
              ,P_PASSWORD
              ,UPPER(P_REQUESTED_OPERATION)
              ,V_LOAD_ID );
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      AD_SYNC_OWNER.AD_SYNC_LOG.WRITE_ERROR(
        $$PLSQL_UNIT
        || '->add_user_to_load: '
        || P_USERNAME
        || ':'
        || V_LOAD_ID
       ,SQLCODE
       ,SQLERRM
      );
      ROLLBACK;
      RAISE;
  END ADD_USER_TO_LOAD;

  PROCEDURE ADD_GROUP_TO_LOAD (
    P_GROUPNAME           VARCHAR2
   ,P_REQUESTED_OPERATION CHAR DEFAULT 'C'
  ) IS
  BEGIN
    INSERT INTO AD_SYNC_OWNER.AD_SYNC_GROUPS (
      GROUPNAME
      ,LOAD_ID
    ) VALUES ( UPPER(P_GROUPNAME)
              ,V_LOAD_ID );
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      AD_SYNC_OWNER.AD_SYNC_LOG.WRITE_ERROR(
        $$PLSQL_UNIT
        || '->add_group_to_load: '
        || P_GROUPNAME
        || ':'
        || V_LOAD_ID
       ,SQLCODE
       ,SQLERRM
      );
      ROLLBACK;
      RAISE;
  END ADD_GROUP_TO_LOAD;

  PROCEDURE ADD_GROUP_MEMBER_TO_LOAD (
    P_GROUPNAME           VARCHAR2
   ,P_MEMBER              VARCHAR2
   ,P_REQUESTED_OPERATION CHAR DEFAULT 'C'
  ) IS
  BEGIN
    INSERT INTO AD_SYNC_OWNER.AD_SYNC_GROUP_MEMBERS (
      GROUPNAME
      ,MEMBER
      ,REQUESTED_OPERATION
      ,LOAD_ID
    ) VALUES ( UPPER(P_GROUPNAME)
              ,UPPER(P_MEMBER)
              ,UPPER(P_REQUESTED_OPERATION)
              ,V_LOAD_ID );
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      AD_SYNC_OWNER.AD_SYNC_LOG.WRITE_ERROR(
        $$PLSQL_UNIT
        || '->add_group_member_to_load: '
        || P_GROUPNAME
        || ':'
        || P_MEMBER
        || ':'
        || V_LOAD_ID
       ,SQLCODE
       ,SQLERRM
      );
      ROLLBACK;
      RAISE;
  END ADD_GROUP_MEMBER_TO_LOAD;
END AD_SYNC_LOAD;
/