prompt CREATE OR REPLACE PACKAGE ad_sync_owner.ad_sync_process_group_privileges

CREATE OR REPLACE PACKAGE AD_SYNC_OWNER.AD_SYNC_PROCESS_GROUP_PRIVILEGES AUTHID CURRENT_USER AS
  PROCEDURE ADD_SYSTEM_PRIVILEGES_AND_ROLES (
    P_PROCESS_RUN NUMBER
  );

  PROCEDURE ADD_OBJECT_PRIVILEGES (
    P_PROCESS_RUN NUMBER
  );

  PROCEDURE clean_group (
    p_group VARCHAR2(1000),
    P_PROCESS_RUN NUMBER
  );

  PROCEDURE clean_all_groups (
    p_group VARCHAR2(1000),
    P_PROCESS_RUN NUMBER
  );

 PROCEDURE grant_privileges_to_groups (
    P_PROCESS_RUN NUMBER
  );

END AD_SYNC_PROCESS_GROUP_PRIVILEGES;
/

prompt CREATE OR REPLACE PACKAGE BODY ad_sync_owner.ad_sync_process_group_privileges

CREATE OR REPLACE PACKAGE BODY AD_SYNC_OWNER.AD_SYNC_PROCESS_GROUP_PRIVILEGES AS

 PROCEDURE grant_privileges_to_groups (
    P_PROCESS_RUN NUMBER
  ) is
  begin
    AD_SYNC_LOG.WRITE_INFO(
      $$PLSQL_UNIT || '->grant_privileges_to_groups started'
     ,SQLCODE
     ,SQLERRM
     ,P_PROCESS_RUN
    );
    --clean all groups
    --clean_all_groups('*', P_PROCESS_RUN);
    --add system privileges and roles
    ADD_SYSTEM_PRIVILEGES_AND_ROLES(P_PROCESS_RUN);
    --add object privileges
    ADD_OBJECT_PRIVILEGES(P_PROCESS_RUN);

    AD_SYNC_LOG.WRITE_INFO(
      $$PLSQL_UNIT || '->grant_privileges_to_groups finished'
     ,SQLCODE
     ,SQLERRM
     ,P_PROCESS_RUN
    );
  EXCEPTION
    WHEN OTHERS THEN
      AD_SYNC_LOG.WRITE_ERROR(
        $$PLSQL_UNIT || '->grant_privileges_to_groups'
       ,SQLCODE
       ,SQLERRM
       ,P_PROCESS_RUN
      );
      RAISE;
      end grant_privileges_to_groups;



 PROCEDURE clean_all_groups (
    p_group VARCHAR2(1000),
    P_PROCESS_RUN NUMBER
  ) is
  begin
    AD_SYNC_LOG.WRITE_INFO(
      $$PLSQL_UNIT || '->clean_all_groups started'
     ,SQLCODE
     ,SQLERRM
     ,P_PROCESS_RUN
    );
    --clean all groups
    FOR I IN (
      SELECT role AS GROUPNAME
        FROM dba_roles
       WHERE role LIKE AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('GROUPNAME_PREFIX')
    ) LOOP
      clean_group(I.GROUPNAME, P_PROCESS_RUN);
    END LOOP;

    AD_SYNC_LOG.WRITE_INFO(
      $$PLSQL_UNIT || '->clean_all_groups finished'
     ,SQLCODE
     ,SQLERRM
     ,P_PROCESS_RUN
    );
  end clean_all_groups;

  PROCEDURE clean_group (
    p_group (1000),
    P_PROCESS_RUN NUMBER
  ) is
  BEGIN
    AD_SYNC_LOG.WRITE_INFO(
      $$PLSQL_UNIT || '->clean_group started'
     ,SQLCODE
     ,SQLERRM
     ,P_PROCESS_RUN
    );
    --clean roles granted to role
    FOR I IN (
      SELECT 'revoke '
             || granted_role
             || ' from '
             || role AS STMT
        FROM role_role_privs
       WHERE role = p_group
       and role LIKE AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('GROUPNAME_PREFIX')
    ) LOOP
      BEGIN
        --DBMS_OUTPUT.PUT_LINE(I.STMT);
        EXECUTE IMMEDIATE I.STMT;
      EXCEPTION
        WHEN OTHERS THEN
          AD_SYNC_LOG.WRITE_ERROR(
            $$PLSQL_UNIT || '->clean_group'
           ,SQLCODE
           ,SQLERRM
           ,P_PROCESS_RUN
          );
      END;
    END LOOP;
    --clean system privileges granted to role
    FOR I IN (
      SELECT 'revoke '
             || privilege
             || ' from '
             || role AS STMT
        FROM role_sys_privs
       WHERE role = p_group
       and role LIKE AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('GROUPNAME_PREFIX')
    ) LOOP
      BEGIN
        --DBMS_OUTPUT.PUT_LINE(I.STMT);
        EXECUTE IMMEDIATE I.STMT;
      EXCEPTION
        WHEN OTHERS THEN
          AD_SYNC_LOG.WRITE_ERROR(
            $$PLSQL_UNIT || '->clean_group'
           ,SQLCODE
           ,SQLERRM
           ,P_PROCESS_RUN
          );
      END;
    END LOOP;
    --clean object privileges granted to role
    FOR I IN (
      SELECT 'revoke '
             || privilege
             || ' on '
             || owner
             || '.'
             || table_name
             || ' from '
             || role AS STMT
        FROM role_sys_privs
       WHERE role = p_group
       and role LIKE AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('GROUPNAME_PREFIX')
    ) LOOP
      BEGIN
        --DBMS_OUTPUT.PUT_LINE(I.STMT);
        EXECUTE IMMEDIATE I.STMT;
      EXCEPTION
        WHEN OTHERS THEN
          AD_SYNC_LOG.WRITE_ERROR(
            $$PLSQL_UNIT || '->clean_group'
           ,SQLCODE
           ,SQLERRM
           ,P_PROCESS_RUN
          );
      END;
    END LOOP;
    AD_SYNC_LOG.WRITE_INFO(
      $$PLSQL_UNIT || '->clean_group finished'
     ,SQLCODE
     ,SQLERRM
     ,P_PROCESS_RUN
    );
  end clean_group;


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