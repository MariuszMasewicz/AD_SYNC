prompt CREATE OR REPLACE PACKAGE ad_sync_owner.ad_sync_log

CREATE OR REPLACE PACKAGE AD_SYNC_OWNER.AD_SYNC_LOG AS
  PROCEDURE WRITE_ERROR (
    P_SRC            IN VARCHAR2
   ,P_CODE           IN PLS_INTEGER
   ,P_MSG            IN VARCHAR2
   ,P_PROCESS_RUN_ID IN PLS_INTEGER DEFAULT NULL
  );

  PROCEDURE WRITE_WARNING (
    P_SRC            IN VARCHAR2
   ,P_CODE           IN PLS_INTEGER
   ,P_MSG            IN VARCHAR2
   ,P_PROCESS_RUN_ID IN PLS_INTEGER DEFAULT NULL
  );

  PROCEDURE WRITE_INFO (
    P_SRC            IN VARCHAR2
   ,P_CODE           IN PLS_INTEGER
   ,P_MSG            IN VARCHAR2
   ,P_PROCESS_RUN_ID IN PLS_INTEGER DEFAULT NULL
  );
END AD_SYNC_LOG;
/

CREATE OR REPLACE PACKAGE BODY AD_SYNC_OWNER.AD_SYNC_LOG IS

  PROCEDURE WRITE_ERROR (
    P_SRC            IN VARCHAR2
   ,P_CODE           IN PLS_INTEGER
   ,P_MSG            IN VARCHAR2
   ,P_PROCESS_RUN_ID IN PLS_INTEGER DEFAULT NULL
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    V_SYSTIMESTAMP CONSTANT TIMESTAMP WITH TIME ZONE := SYSTIMESTAMP;
  BEGIN
    INSERT INTO AD_SYNC_OWNER.AD_SYNC_LOG_TABLE (
      LOG_ID
      ,PROCESS_RUN_ID
      ,LOG_TYPE
      ,LOG_SRC
      ,LOG_CODE
      ,LOG_MSG
      ,LOG_TIMESTAMP
      ,CREATED_TIMESTAMP
      ,CREATED_USER
      ,UPDATED_TIMESTAMP
      ,UPDATED_USER
    ) VALUES ( AD_SYNC_OWNER.AD_SYNC_LOG_TABLE_SEQ.NEXTVAL
              ,P_PROCESS_RUN_ID
              ,0
              ,SUBSTR(
      P_SRC
     ,1
     ,4000
    )
              ,P_CODE
              ,CASE
                 WHEN P_MSG IS NOT NULL THEN
                   SUBSTR(
                     P_MSG
                     || CHR(10)
                     || 'Error backtrace  :'
                     || CHR(10)
                     || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                    ,1
                    ,4000
                   )
                 ELSE
                   'NO MESSAGE'
               END
              ,V_SYSTIMESTAMP
              ,V_SYSTIMESTAMP
              ,USER
              ,V_SYSTIMESTAMP
              ,USER );
    COMMIT WRITE NOWAIT;
  END WRITE_ERROR;
 

  -----------------------------------------------------------------------------
  PROCEDURE WRITE_WARNING (
    P_SRC            IN VARCHAR2
   ,P_CODE           IN PLS_INTEGER
   ,P_MSG            IN VARCHAR2
   ,P_PROCESS_RUN_ID IN PLS_INTEGER DEFAULT NULL
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    V_SYSTIMESTAMP CONSTANT TIMESTAMP WITH TIME ZONE := SYSTIMESTAMP;
  BEGIN
    INSERT INTO AD_SYNC_OWNER.AD_SYNC_LOG_TABLE (
      LOG_ID
      ,PROCESS_RUN_ID
      ,LOG_TYPE
      ,LOG_SRC
      ,LOG_CODE
      ,LOG_MSG
      ,LOG_TIMESTAMP
      ,CREATED_TIMESTAMP
      ,CREATED_USER
      ,UPDATED_TIMESTAMP
      ,UPDATED_USER
    ) VALUES ( AD_SYNC_OWNER.AD_SYNC_LOG_TABLE_SEQ.NEXTVAL
              ,P_PROCESS_RUN_ID
              ,1
              ,SUBSTR(
      P_SRC
     ,1
     ,4000
    )
              ,P_CODE
              ,CASE
                 WHEN P_MSG IS NOT NULL THEN
                   SUBSTR(
                     P_MSG
                     || CHR(10)
                     || 'Error backtrace :'
                     || CHR(10)
                     || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                    ,1
                    ,4000
                   )
                 ELSE
                   'NO MESSAGE'
               END
              ,V_SYSTIMESTAMP
              ,V_SYSTIMESTAMP
              ,USER
              ,V_SYSTIMESTAMP
              ,USER );
    COMMIT WRITE NOWAIT;
  END WRITE_WARNING;
 

  -----------------------------------------------------------------------------
  PROCEDURE WRITE_INFO (
    P_SRC            IN VARCHAR2
   ,P_CODE           IN PLS_INTEGER
   ,P_MSG            IN VARCHAR2
   ,P_PROCESS_RUN_ID IN PLS_INTEGER DEFAULT NULL
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    V_SYSTIMESTAMP CONSTANT TIMESTAMP WITH TIME ZONE := SYSTIMESTAMP;
  BEGIN
    IF ( AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('LOG_INFO') = 1 ) THEN
      INSERT INTO AD_SYNC_OWNER.AD_SYNC_LOG_TABLE (
        LOG_ID
        ,PROCESS_RUN_ID
        ,LOG_TYPE
        ,LOG_SRC
        ,LOG_CODE
        ,LOG_MSG
        ,LOG_TIMESTAMP
        ,CREATED_TIMESTAMP
        ,CREATED_USER
        ,UPDATED_TIMESTAMP
        ,UPDATED_USER
      ) VALUES ( AD_SYNC_OWNER.AD_SYNC_LOG_TABLE_SEQ.NEXTVAL
                ,P_PROCESS_RUN_ID
                ,2
                ,SUBSTR(
        P_SRC
       ,1
       ,4000
      )
                ,P_CODE
                ,CASE
                   WHEN P_MSG IS NOT NULL THEN
                     SUBSTR(
                       P_MSG
                       || CHR(10)
                       || 'Error backtrace  :'
                       || CHR(10)
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                      ,1
                      ,4000
                     )
                   ELSE
                     'NO MESSAGE'
                 END
                ,V_SYSTIMESTAMP
                ,V_SYSTIMESTAMP
                ,USER
                ,V_SYSTIMESTAMP
                ,USER );
      COMMIT WRITE NOWAIT;
    END IF;
  END WRITE_INFO;
END AD_SYNC_LOG;
/