prompt CREATE OR REPLACE PACKAGE ad_sync_owner.ad_sync_log

CREATE OR REPLACE PACKAGE ad_sync_owner.ad_sync_log AS
  PROCEDURE write_error(p_src        IN VARCHAR2,
                        p_code       IN PLS_INTEGER,
                        p_msg        IN VARCHAR2,
                        p_process_run_id in PLS_INTEGER default null);

  PROCEDURE write_warning(p_src        IN VARCHAR2,
                          p_code       IN PLS_INTEGER,
                          p_msg        IN VARCHAR2,
                          p_process_run_id in PLS_INTEGER default null);

  PROCEDURE write_info(p_src        IN VARCHAR2,
                       p_code       IN PLS_INTEGER,
                       p_msg        IN VARCHAR2,
                       p_process_run_id in PLS_INTEGER default null);
END ad_sync_log;
/

CREATE OR REPLACE PACKAGE BODY ad_sync_owner.ad_sync_log IS

  PROCEDURE write_error(p_src        IN VARCHAR2,
                        p_code       IN PLS_INTEGER,
                        p_msg        IN VARCHAR2,
                        p_process_run_id in PLS_INTEGER default null) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  v_systimestamp CONSTANT TIMESTAMP WITH TIME ZONE := systimestamp;
  BEGIN
  
    INSERT INTO ad_sync_owner.AD_SYNC_LOG_TABLE
      (log_id,
       process_run_id,
       log_type,
       log_src,
       log_code,
       log_msg,
       log_timestamp,
       created_timestamp,
       created_user,
       updated_timestamp,
       updated_user)
    VALUES
      (ad_sync_owner.AD_SYNC_LOG_TABLE_seq.nextval,
       p_process_run_id,
       0,
       substr(p_src, 1, 4000),
       p_code,
       CASE WHEN p_msg IS NOT NULL THEN
       substr(p_msg || chr(10) || 'Error backtrace  :' || chr(10) ||
              dbms_utility.format_error_backtrace,
              1,
              4000) ELSE 'NO MESSAGE' END,
       v_systimestamp,
       v_systimestamp,
       USER,
       v_systimestamp,
       USER);
  
    COMMIT WRITE NOWAIT;
  END write_error;

  -----------------------------------------------------------------------------

  PROCEDURE write_warning(p_src        IN VARCHAR2,
                          p_code       IN PLS_INTEGER,
                          p_msg        IN VARCHAR2,
                          p_process_run_id in PLS_INTEGER default null) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  v_systimestamp CONSTANT TIMESTAMP WITH TIME ZONE := systimestamp;
  BEGIN
  
    INSERT INTO ad_sync_owner.AD_SYNC_LOG_TABLE
      (log_id,
       process_run_id,
       log_type,
       log_src,
       log_code,
       log_msg,
       log_timestamp,
       created_timestamp,
       created_user,
       updated_timestamp,
       updated_user)
    VALUES
      (ad_sync_owner.AD_SYNC_LOG_TABLE_seq.nextval,
       p_process_run_id,
       1,
       substr(p_src, 1, 4000),
       p_code,
       CASE WHEN p_msg IS NOT NULL THEN
       substr(p_msg || chr(10) || 'Error backtrace :' || chr(10) ||
              dbms_utility.format_error_backtrace,
              1,
              4000) ELSE 'NO MESSAGE' END,
       v_systimestamp,
       v_systimestamp,
       USER,
       v_systimestamp,
       USER);
  
    COMMIT WRITE NOWAIT;
  END write_warning;

  -----------------------------------------------------------------------------

  PROCEDURE write_info(p_src        IN VARCHAR2,
                       p_code       IN PLS_INTEGER,
                       p_msg        IN VARCHAR2,
                       p_process_run_id in PLS_INTEGER default null) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  v_systimestamp CONSTANT TIMESTAMP WITH TIME ZONE := systimestamp;
  BEGIN
    IF (ad_sync_owner.ad_sync_tools.get_param_value('LOG_INFO') = 1) THEN
      INSERT INTO ad_sync_owner.AD_SYNC_LOG_TABLE
        (log_id,
         process_run_id,
         log_type,
         log_src,
         log_code,
         log_msg,
         log_timestamp,
         created_timestamp,
         created_user,
         updated_timestamp,
         updated_user)
      VALUES
        (ad_sync_owner.AD_SYNC_LOG_TABLE_seq.nextval,
         p_process_run_id,
         2,
         substr(p_src, 1, 4000),
         p_code,
         CASE WHEN p_msg IS NOT NULL THEN
         substr(p_msg || chr(10) || 'Error backtrace  :' || chr(10) ||
                dbms_utility.format_error_backtrace,
                1,
                4000) ELSE 'NO MESSAGE' END,
         v_systimestamp,
         v_systimestamp,
         USER,
         v_systimestamp,
         USER);
    
      COMMIT WRITE NOWAIT;
    END IF;
  END write_info;

END ad_sync_log;
/
