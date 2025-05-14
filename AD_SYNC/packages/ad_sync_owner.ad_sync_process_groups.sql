prompt CREATE OR REPLACE PACKAGE ad_sync_owner.ad_sync_process_groups

CREATE OR REPLACE PACKAGE AD_SYNC_OWNER.AD_SYNC_PROCESS_GROUPS AUTHID CURRENT_USER AS
  PROCEDURE ADD_GROUPS (
    P_START_TIMESTAMP TIMESTAMP
   ,P_END_TIMESTAMP   TIMESTAMP
   ,P_PROCESS_RUN     NUMBER
   ,P_LOAD_ID         NUMBER
  );

  PROCEDURE DROP_GROPUS_NOT_EXIST_IN_LOAD (
    P_START_TIMESTAMP TIMESTAMP
   ,P_END_TIMESTAMP   TIMESTAMP
   ,P_PROCESS_RUN     NUMBER
   ,P_LOAD_ID         NUMBER
  );

  PROCEDURE DROP_GROPUS_ON_DEMAND (
    P_START_TIMESTAMP TIMESTAMP
   ,P_END_TIMESTAMP   TIMESTAMP
   ,P_PROCESS_RUN     NUMBER
   ,P_LOAD_ID         NUMBER
  );

  PROCEDURE MARK_EXISTING_GROUPS (
    P_START_TIMESTAMP TIMESTAMP
   ,P_END_TIMESTAMP   TIMESTAMP
   ,P_PROCESS_RUN     NUMBER
   ,P_LOAD_ID         NUMBER
  );
END AD_SYNC_PROCESS_GROUPS;
/

prompt CREATE OR REPLACE PACKAGE BODY ad_sync_owner.ad_sync_process_groups

CREATE OR REPLACE PACKAGE BODY AD_SYNC_OWNER.AD_SYNC_PROCESS_GROUPS AS

  PROCEDURE DROP_GROPUS_NOT_EXIST_IN_LOAD (
    P_START_TIMESTAMP TIMESTAMP
   ,P_END_TIMESTAMP   TIMESTAMP
   ,P_PROCESS_RUN     NUMBER
   ,P_LOAD_ID         NUMBER
  ) AS
    V_STMT VARCHAR2(4000);
  BEGIN
    IF P_PROCESS_RUN IS NOT NULL THEN
      AD_SYNC_LOG.WRITE_INFO(
        $$PLSQL_UNIT
        || '->drop_gropus_not_exist_in_load started for: '
        || P_START_TIMESTAMP
        || ' and '
        || P_END_TIMESTAMP
       ,SQLCODE
       ,SQLERRM
       ,P_PROCESS_RUN
      );
      FOR I IN (
        SELECT G.GROUPNAME
          FROM AD_SYNC_OWNER.AD_SYNC_GROUPS AG
         RIGHT JOIN AD_SYNC_OWNER.AD_SYNC_MANAGED_GROUPS G
        ON ( AG.GROUPNAME = G.GROUPNAME )
         WHERE AG.STATUS = 1
 --and ag.REQUESTED_OPERATION = 'D' --requested drop GROUP
           AND AG.GROUPNAME LIKE AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('GROUPNAME_PREFIX')
                                 || '%'
           AND AG.CREATED_TIMESTAMP BETWEEN P_START_TIMESTAMP AND P_END_TIMESTAMP
           AND AG.ID IS NULL
      ) LOOP
        V_STMT := 'drop role ' || I.GROUPNAME
 --|| ' cascade'
        ;
        DBMS_OUTPUT.PUT_LINE(V_STMT || ';');
        AD_SYNC_LOG.WRITE_INFO(
          $$PLSQL_UNIT
          || '->drop_gropus_not_exist_in_load group dropped: '
          || I.GROUPNAME
         ,SQLCODE
         ,SQLERRM
         ,P_PROCESS_RUN
        );
        EXECUTE IMMEDIATE V_STMT;
      END LOOP;
 

            --        COMMIT;
      AD_SYNC_LOG.WRITE_INFO(
        $$PLSQL_UNIT || '->drop_gropus_not_exist_in_load  finished'
       ,SQLCODE
       ,SQLERRM
       ,P_PROCESS_RUN
      );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      AD_SYNC_LOG.WRITE_ERROR(
        $$PLSQL_UNIT || '->drop_gropus_not_exist_in_load'
       ,SQLCODE
       ,SQLERRM
      );
      RAISE;
  END DROP_GROPUS_NOT_EXIST_IN_LOAD;

  PROCEDURE DROP_GROPUS_ON_DEMAND (
    P_START_TIMESTAMP TIMESTAMP
   ,P_END_TIMESTAMP   TIMESTAMP
   ,P_PROCESS_RUN     NUMBER
   ,P_LOAD_ID         NUMBER
  ) AS
    V_STMT VARCHAR2(4000);
  BEGIN
    IF P_PROCESS_RUN IS NOT NULL THEN
      AD_SYNC_LOG.WRITE_INFO(
        $$PLSQL_UNIT
        || '->drop_gropus started for: '
        || P_START_TIMESTAMP
        || ' and '
        || P_END_TIMESTAMP
       ,SQLCODE
       ,SQLERRM
       ,P_PROCESS_RUN
      );
      FOR I IN (
        SELECT AG.ID
              ,AG.GROUPNAME
          FROM AD_SYNC_OWNER.AD_SYNC_GROUPS AG
          JOIN AD_SYNC_OWNER.AD_SYNC_MANAGED_GROUPS G
        ON ( AG.GROUPNAME = G.GROUPNAME )
         WHERE AG.STATUS = 1
           AND AG.REQUESTED_OPERATION = 'D' --requested drop GROUP
           AND AG.GROUPNAME LIKE AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('GROUPNAME_PREFIX')
                                 || '%'
           AND AG.CREATED_TIMESTAMP BETWEEN P_START_TIMESTAMP AND P_END_TIMESTAMP
      ) LOOP
        V_STMT := 'drop role ' || I.GROUPNAME
 --|| ' cascade'
        ;
        DBMS_OUTPUT.PUT_LINE(V_STMT || ';');
        AD_SYNC_LOG.WRITE_INFO(
          $$PLSQL_UNIT
          || '->drop_gropus group dropped: '
          || I.GROUPNAME
         ,SQLCODE
         ,SQLERRM
         ,P_PROCESS_RUN
        );
        EXECUTE IMMEDIATE V_STMT;
        UPDATE AD_SYNC_OWNER.AD_SYNC_GROUPS
           SET STATUS = 32 -- GROUP dropped
           ,PROCESS_TIMESTAMP = CURRENT_TIMESTAMP
        ,LOAD_ID = P_LOAD_ID
         WHERE ID = I.ID;
      END LOOP;

      COMMIT;
      AD_SYNC_LOG.WRITE_INFO(
        $$PLSQL_UNIT || '->drop_gropus  finished'
       ,SQLCODE
       ,SQLERRM
       ,P_PROCESS_RUN
      );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      AD_SYNC_LOG.WRITE_ERROR(
        $$PLSQL_UNIT || '->drop_gropus'
       ,SQLCODE
       ,SQLERRM
      );
      RAISE;
  END DROP_GROPUS_ON_DEMAND;

  PROCEDURE MARK_EXISTING_GROUPS (
    P_START_TIMESTAMP TIMESTAMP
   ,P_END_TIMESTAMP   TIMESTAMP
   ,P_PROCESS_RUN     NUMBER
   ,P_LOAD_ID         NUMBER
  ) IS
    V_NUMBER_OF_EXISTING PLS_INTEGER;
  BEGIN
    IF P_PROCESS_RUN IS NOT NULL THEN
      AD_SYNC_LOG.WRITE_INFO(
        $$PLSQL_UNIT
        || '->mark_existing_groups started for: '
        || P_START_TIMESTAMP
        || ' and '
        || P_END_TIMESTAMP
       ,SQLCODE
       ,SQLERRM
       ,P_PROCESS_RUN
      );
 /* existing GROUPs*/
      UPDATE AD_SYNC_OWNER.AD_SYNC_GROUPS
         SET STATUS = 38 -- GROUP exists in database
         ,PROCESS_TIMESTAMP = CURRENT_TIMESTAMP
      ,LOAD_ID = P_LOAD_ID
       WHERE GROUPNAME IN (
        SELECT GROUPNAME
          FROM AD_SYNC_OWNER.AD_SYNC_MANAGED_GROUPS
      )
         AND STATUS = 1
         AND REQUESTED_OPERATION = 'C' --requested create GROUP
         AND GROUPNAME LIKE AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('GROUPNAME_PREFIX')
                            || '%'
         AND CREATED_TIMESTAMP BETWEEN P_START_TIMESTAMP AND P_END_TIMESTAMP;
      V_NUMBER_OF_EXISTING := SQL%ROWCOUNT;
      COMMIT;
      AD_SYNC_LOG.WRITE_INFO(
        $$PLSQL_UNIT
        || '->mark_existing_groups number of existing: '
        || V_NUMBER_OF_EXISTING
       ,SQLCODE
       ,SQLERRM
       ,P_PROCESS_RUN
      );
 /* bad prefix*/
      UPDATE AD_SYNC_OWNER.AD_SYNC_GROUPS
         SET STATUS = 37 -- invalid GROUP prefix
         ,PROCESS_TIMESTAMP = CURRENT_TIMESTAMP
      ,LOAD_ID = P_LOAD_ID
       WHERE GROUPNAME NOT LIKE AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('GROUPNAME_PREFIX')
                                || '%'
         AND STATUS = 1
         AND CREATED_TIMESTAMP BETWEEN P_START_TIMESTAMP AND P_END_TIMESTAMP;
      V_NUMBER_OF_EXISTING := SQL%ROWCOUNT;
      COMMIT;
      AD_SYNC_LOG.WRITE_INFO(
        $$PLSQL_UNIT
        || '->mark_existing_groups number of bad prefixes: '
        || V_NUMBER_OF_EXISTING
       ,SQLCODE
       ,SQLERRM
       ,P_PROCESS_RUN
      );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      AD_SYNC_LOG.WRITE_ERROR(
        $$PLSQL_UNIT || '->add_groups'
       ,SQLCODE
       ,SQLERRM
      );
      RAISE;
  END MARK_EXISTING_GROUPS;

  PROCEDURE ADD_GROUPS (
    P_START_TIMESTAMP TIMESTAMP
   ,P_END_TIMESTAMP   TIMESTAMP
   ,P_PROCESS_RUN     NUMBER
   ,P_LOAD_ID         NUMBER
  ) IS
    V_STMT      VARCHAR2(4000);
    V_FILE_NAME VARCHAR2(100);
    V_FILE      UTL_FILE.FILE_TYPE;
  BEGIN
    IF P_PROCESS_RUN IS NOT NULL THEN
      AD_SYNC_LOG.WRITE_INFO(
        $$PLSQL_UNIT
        || '->add_groups started for: '
        || P_START_TIMESTAMP
        || ' and '
        || P_END_TIMESTAMP
       ,SQLCODE
       ,SQLERRM
       ,P_PROCESS_RUN
      );
      FOR I IN (
        SELECT AG.ID
              ,AG.GROUPNAME
          FROM AD_SYNC_OWNER.AD_SYNC_GROUPS AG
          LEFT JOIN AD_SYNC_OWNER.AD_SYNC_MANAGED_GROUPS G
        ON ( AG.GROUPNAME = G.GROUPNAME )
         WHERE AG.STATUS = 1
           AND AG.REQUESTED_OPERATION = 'C' --requested create GROUP
           AND AG.GROUPNAME LIKE AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('GROUPNAME_PREFIX')
                                 || '%'
           AND AG.CREATED_TIMESTAMP BETWEEN P_START_TIMESTAMP AND P_END_TIMESTAMP
           AND G.GROUPNAME IS NULL
      ) LOOP
        V_STMT := 'create role ' || I.GROUPNAME;
        DBMS_OUTPUT.PUT_LINE(V_STMT || ';');
        AD_SYNC_LOG.WRITE_INFO(
          $$PLSQL_UNIT
          || '->add_groups create group: '
          || I.GROUPNAME
         ,SQLCODE
         ,SQLERRM
         ,P_PROCESS_RUN
        );
        EXECUTE IMMEDIATE V_STMT;
        UPDATE AD_SYNC_OWNER.AD_SYNC_GROUPS
           SET STATUS = 39 -- GROUP created
           ,PROCESS_TIMESTAMP = CURRENT_TIMESTAMP
        ,LOAD_ID = P_LOAD_ID
         WHERE ID = I.ID;
      END LOOP;

      COMMIT;
      AD_SYNC_LOG.WRITE_INFO(
        $$PLSQL_UNIT || '->add_groups finished'
       ,SQLCODE
       ,SQLERRM
       ,P_PROCESS_RUN
      );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      AD_SYNC_LOG.WRITE_ERROR(
        $$PLSQL_UNIT || '->add_groups'
       ,SQLCODE
       ,SQLERRM
      );
      RAISE;
  END ADD_GROUPS;
END AD_SYNC_PROCESS_GROUPS;
/