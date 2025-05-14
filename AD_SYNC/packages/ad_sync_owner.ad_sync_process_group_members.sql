prompt CREATE OR REPLACE PACKAGE  ad_sync_owner.ad_sync_process_group_members

CREATE OR REPLACE PACKAGE AD_SYNC_OWNER.AD_SYNC_PROCESS_GROUP_MEMBERS AUTHID CURRENT_USER AS
  PROCEDURE ADD_GROUP_MEMBERS (
    P_START_TIMESTAMP TIMESTAMP
   ,P_END_TIMESTAMP   TIMESTAMP
   ,P_PROCESS_RUN     NUMBER
   ,P_LOAD_ID         NUMBER
  );
    --PROCEDURE drop_group_members_not_exist_in_load (p_start_timestamp timestamp, p_end_timestamp timestamp, p_process_run number, p_load_id number);
  PROCEDURE DROP_GROUP_MEMBER_ON_DEMAND (
    P_START_TIMESTAMP TIMESTAMP
   ,P_END_TIMESTAMP   TIMESTAMP
   ,P_PROCESS_RUN     NUMBER
   ,P_LOAD_ID         NUMBER
  );
  PROCEDURE MARK_EXISTING_GROUP_MEMBERS (
    P_START_TIMESTAMP TIMESTAMP
   ,P_END_TIMESTAMP   TIMESTAMP
   ,P_PROCESS_RUN     NUMBER
   ,P_LOAD_ID         NUMBER
  );
END AD_SYNC_PROCESS_GROUP_MEMBERS;
/

prompt CREATE OR REPLACE PACKAGE BODY ad_sync_owner.ad_sync_process_group_members
CREATE OR REPLACE PACKAGE BODY AD_SYNC_OWNER.AD_SYNC_PROCESS_GROUP_MEMBERS AS

/*PROCEDURE drop_group_members_not_exist_in_load (p_start_timestamp timestamp, p_end_timestamp timestamp, p_process_run number, p_load_id number) as
        v_stmt VARCHAR2(4000);
    BEGIN
        if p_process_run is not null then
        ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->drop_gropus_not_exist_in_load started for: '||p_start_timestamp||' and '||p_end_timestamp,
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
        FOR i IN (
            SELECT
                ag.id, ag.GROUPname
            FROM
                ad_sync_owner.ad_sync_group_members ag right join ad_sync_owner.AD_SYNC_MANAGED_group_members g on (ag.GROUPname=g.GROUPname)
            WHERE
                ag.status = 1
                --and ag.REQUESTED_OPERATION = 'D' --requested drop GROUP
                and ag.GROUPname like ad_sync_owner.ad_sync_tools.get_param_value('GROUPNAME_PREFIX')||'%'
                and ag.CREATED_TIMESTAMP between p_start_timestamp and p_end_timestamp
                and ag.id is null
                )
         LOOP
            v_stmt := 'drop role ' || i.GROUPname 
                   --|| ' cascade'
                   ;
            dbms_output.put_line(v_stmt||';');
            
            ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->drop_gropus_not_exist_in_load group dropped: '|| i.GROUPname,
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
            execute immediate v_stmt;
        END LOOP;

--        COMMIT;
        ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->drop_gropus_not_exist_in_load  finished',
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
         end if;                   
    EXCEPTION
      WHEN OTHERS THEN
        ad_sync_log.write_error($$PLSQL_UNIT ||
                            '->drop_gropus_not_exist_in_load' ,
                            SQLCODE,
                            SQLERRM);
        RAISE;
    
    END drop_group_members_not_exist_in_load;
*/

  PROCEDURE DROP_GROUP_MEMBER_ON_DEMAND (
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
              ,AG.MEMBER
          FROM AD_SYNC_OWNER.AD_SYNC_GROUP_MEMBERS AG
          JOIN AD_SYNC_OWNER.AD_SYNC_MANAGED_GROUP_MEMBERS G
        ON ( AG.GROUPNAME = G.GROUPNAME
           AND AG.MEMBER = G.GRANTEE )
         WHERE AG.STATUS = 1
           AND AG.REQUESTED_OPERATION = 'D' --requested drop GROUP
        AND AG.GROUPNAME LIKE AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('GROUPNAME_PREFIX')
               || '%'
        AND AG.MEMBER LIKE AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('USERNAME_PREFIX')
                           || '%'
           AND AG.CREATED_TIMESTAMP BETWEEN P_START_TIMESTAMP AND P_END_TIMESTAMP
      ) LOOP
        V_STMT := 'revoke '
                  || I.GROUPNAME
                  || ' from '
                  || I.MEMBER;
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
        UPDATE AD_SYNC_OWNER.AD_SYNC_GROUP_MEMBERS
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
  END DROP_GROUP_MEMBER_ON_DEMAND;

  PROCEDURE MARK_EXISTING_GROUP_MEMBERS (
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
        || '->mark_existing_group_members started for: '
        || P_START_TIMESTAMP
        || ' and '
        || P_END_TIMESTAMP
       ,SQLCODE
       ,SQLERRM
       ,P_PROCESS_RUN
      );
      -- existing group_members
      UPDATE AD_SYNC_OWNER.AD_SYNC_GROUP_MEMBERS
         SET STATUS = 48 -- GROUP exists in database
         ,PROCESS_TIMESTAMP = CURRENT_TIMESTAMP
      ,LOAD_ID = P_LOAD_ID
       WHERE ( GROUPNAME
              ,MEMBER ) IN (
        SELECT GROUPNAME
              ,GRANTEE
          FROM AD_SYNC_OWNER.AD_SYNC_MANAGED_GROUP_MEMBERS
      )
         AND STATUS = 1
         AND REQUESTED_OPERATION = 'C' --requested create GROUP
      AND GROUPNAME LIKE AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('GROUPNAME_PREFIX')
             || '%'
      AND MEMBER LIKE AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('USERNAME_PREFIX')
                      || '%'
         AND CREATED_TIMESTAMP BETWEEN P_START_TIMESTAMP AND P_END_TIMESTAMP;
      V_NUMBER_OF_EXISTING := SQL%ROWCOUNT;
      COMMIT;
      AD_SYNC_LOG.WRITE_INFO(
        $$PLSQL_UNIT
        || '->mark_existing_group_members number of existing: '
        || V_NUMBER_OF_EXISTING
       ,SQLCODE
       ,SQLERRM
       ,P_PROCESS_RUN
      );
        -- bad prefix
      UPDATE AD_SYNC_OWNER.AD_SYNC_GROUP_MEMBERS
         SET STATUS = 47 -- invalid GROUP prefix
         ,PROCESS_TIMESTAMP = CURRENT_TIMESTAMP
      ,LOAD_ID = P_LOAD_ID
       WHERE ( GROUPNAME NOT LIKE AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('GROUPNAME_PREFIX')
                                  || '%'
      OR MEMBER NOT LIKE AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('USERNAME_PREFIX')
                         || '%' )
         AND STATUS = 1
         AND CREATED_TIMESTAMP BETWEEN P_START_TIMESTAMP AND P_END_TIMESTAMP;
      V_NUMBER_OF_EXISTING := SQL%ROWCOUNT;
      COMMIT;
      AD_SYNC_LOG.WRITE_INFO(
        $$PLSQL_UNIT
        || '->mark_existing_group_members number of bad prefixes: '
        || V_NUMBER_OF_EXISTING
       ,SQLCODE
       ,SQLERRM
       ,P_PROCESS_RUN
      );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      AD_SYNC_LOG.WRITE_ERROR(
        $$PLSQL_UNIT || '->mark_existing_group_members'
       ,SQLCODE
       ,SQLERRM
      );
      RAISE;
  END MARK_EXISTING_GROUP_MEMBERS;

  PROCEDURE ADD_GROUP_MEMBERS (
    P_START_TIMESTAMP TIMESTAMP
   ,P_END_TIMESTAMP   TIMESTAMP
   ,P_PROCESS_RUN     NUMBER
   ,P_LOAD_ID         NUMBER
  ) IS
    V_STMT VARCHAR2(4000);
        --v_file_name varchar2(100);
        --v_file  UTL_FILE.FILE_TYPE;
  BEGIN
    IF P_PROCESS_RUN IS NOT NULL THEN
      AD_SYNC_LOG.WRITE_INFO(
        $$PLSQL_UNIT
        || '->add_group_members started for: '
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
              ,AG.MEMBER
          FROM AD_SYNC_OWNER.AD_SYNC_GROUP_MEMBERS AG
         WHERE AG.STATUS = 1
           AND AG.REQUESTED_OPERATION = 'C' --requested create GROUP
        AND AG.GROUPNAME LIKE AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('GROUPNAME_PREFIX')
               || '%'
        AND AG.MEMBER LIKE AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('USERNAME_PREFIX')
                           || '%'
           AND AG.CREATED_TIMESTAMP BETWEEN P_START_TIMESTAMP AND P_END_TIMESTAMP
           AND AG.GROUPNAME IS NOT NULL
           AND AG.MEMBER IS NOT NULL
      ) LOOP
        V_STMT := 'GRANT '
                  || I.GROUPNAME
                  || ' to '
                  || I.MEMBER;
        DBMS_OUTPUT.PUT_LINE(V_STMT || ';');
        AD_SYNC_LOG.WRITE_INFO(
          $$PLSQL_UNIT
          || '->add_group_members add member to group: '
          || I.MEMBER
          || ':'
          || I.GROUPNAME
         ,SQLCODE
         ,SQLERRM
         ,P_PROCESS_RUN
        );
        EXECUTE IMMEDIATE V_STMT;
        UPDATE AD_SYNC_OWNER.AD_SYNC_GROUP_MEMBERS
           SET STATUS = 49 -- GROUP_member created
           ,PROCESS_TIMESTAMP = CURRENT_TIMESTAMP
        ,LOAD_ID = P_LOAD_ID
         WHERE ID = I.ID;

      END LOOP;

      COMMIT;
      AD_SYNC_LOG.WRITE_INFO(
        $$PLSQL_UNIT || '->add_group_members finished'
       ,SQLCODE
       ,SQLERRM
       ,P_PROCESS_RUN
      );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      AD_SYNC_LOG.WRITE_ERROR(
        $$PLSQL_UNIT || '->add_group_members'
       ,SQLCODE
       ,SQLERRM
      );
      RAISE;
  END ADD_GROUP_MEMBERS;

END AD_SYNC_PROCESS_GROUP_MEMBERS;
/