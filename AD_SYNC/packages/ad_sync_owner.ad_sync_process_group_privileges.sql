prompt CREATE OR REPLACE PACKAGE ad_sync_owner.ad_sync_process_group_privileges

CREATE OR REPLACE PACKAGE AD_SYNC_OWNER.AD_SYNC_PROCESS_GROUP_PRIVILEGES AUTHID CURRENT_USER AS
  PROCEDURE ADD_SYSTEM_PRIVILEGES_AND_ROLES (
    P_PROCESS_RUN NUMBER
  );

  PROCEDURE ADD_OBJECT_PRIVILEGES (
    P_PROCESS_RUN NUMBER
  );
END AD_SYNC_PROCESS_GROUP_PRIVILEGES;
/

prompt CREATE OR REPLACE PACKAGE BODY ad_sync_owner.ad_sync_process_group_privileges

CREATE OR REPLACE PACKAGE BODY AD_SYNC_OWNER.AD_SYNC_PROCESS_GROUP_PRIVILEGES AS

  PROCEDURE ADD_SYSTEM_PRIVILEGES_AND_ROLES (
    P_PROCESS_RUN NUMBER
  ) IS
  BEGIN
    AD_SYNC_LOG.WRITE_INFO(
      $$PLSQL_UNIT || '->add_system_privileges_and_roles started'
     ,SQLCODE
     ,SQLERRM
     ,P_PROCESS_RUN
    );
    FOR J IN (
      SELECT 'grant '
             || PERMISSION
             || '  to '
             || GROUPNAME AS STMT
        FROM AD_SYNC_OWNER.AD_SYNC_GROUP_PERMISSION
       WHERE SCHEMA = '*'
         AND OBJECT_NAME = '*'
    ) LOOP
      BEGIN
 
                --DBMS_OUTPUT.PUT_LINE(J.STMT);
        EXECUTE IMMEDIATE J.STMT;
      EXCEPTION
        WHEN OTHERS THEN
          AD_SYNC_LOG.WRITE_ERROR(
            $$PLSQL_UNIT || '->add_system_privileges_and_roles'
           ,SQLCODE
           ,SQLERRM
           ,P_PROCESS_RUN
          );
      END;
    END LOOP;

    AD_SYNC_LOG.WRITE_INFO(
      $$PLSQL_UNIT || '->add_system_privileges_and_roles finished'
     ,SQLCODE
     ,SQLERRM
     ,P_PROCESS_RUN
    );
  EXCEPTION
    WHEN OTHERS THEN
      AD_SYNC_LOG.WRITE_ERROR(
        $$PLSQL_UNIT || '->add_system_privileges_and_roles'
       ,SQLCODE
       ,SQLERRM
       ,P_PROCESS_RUN
      );
      RAISE;
  END ADD_SYSTEM_PRIVILEGES_AND_ROLES;

  PROCEDURE ADD_OBJECT_PRIVILEGES (
    P_PROCESS_RUN NUMBER
  ) IS
  BEGIN
    AD_SYNC_LOG.WRITE_INFO(
      $$PLSQL_UNIT || '->add_object_privileges started'
     ,SQLCODE
     ,SQLERRM
     ,P_PROCESS_RUN
    );
    FOR J IN (
      SELECT *
        FROM AD_SYNC_OWNER.AD_SYNC_GROUP_PERMISSION
       WHERE SCHEMA <> '*'
         AND OBJECT_NAME = '*'
    ) LOOP
      FOR I IN (
        SELECT 'grant '
               || J.PERMISSION
               || ' on "'
               || J.SCHEMA
               || '"."'
               || OBJECT_NAME
               || '" to '
               || J.GROUPNAME AS STMT
          FROM DBA_OBJECTS
         WHERE OWNER = J.SCHEMA
           AND OBJECT_TYPE IN ( 'TABLE'
                               ,'VIEW'
                               ,'MATERIALIZED VIEW' )
         ORDER BY OBJECT_TYPE
                 ,OWNER
                 ,OBJECT_NAME
      ) LOOP
        BEGIN
 
                    --DBMS_OUTPUT.PUT_LINE(I.STMT);
          EXECUTE IMMEDIATE I.STMT;
        EXCEPTION
          WHEN OTHERS THEN
            AD_SYNC_LOG.WRITE_ERROR(
              $$PLSQL_UNIT || '->add_object_privileges'
             ,SQLCODE
             ,SQLERRM
             ,P_PROCESS_RUN
            );
        END;
      END LOOP;
    END LOOP;

    AD_SYNC_LOG.WRITE_INFO(
      $$PLSQL_UNIT || '->add_object_privileges finished'
     ,SQLCODE
     ,SQLERRM
     ,P_PROCESS_RUN
    );
  EXCEPTION
    WHEN OTHERS THEN
      AD_SYNC_LOG.WRITE_ERROR(
        $$PLSQL_UNIT || '->add_object_privileges'
       ,SQLCODE
       ,SQLERRM
       ,P_PROCESS_RUN
      );
      RAISE;
  END ADD_OBJECT_PRIVILEGES;
END AD_SYNC_PROCESS_GROUP_PRIVILEGES;
/