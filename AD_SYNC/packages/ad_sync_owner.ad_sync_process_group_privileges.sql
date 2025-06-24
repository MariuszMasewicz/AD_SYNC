prompt CREATE OR REPLACE PACKAGE ad_sync_owner.ad_sync_process_group_privileges

CREATE OR REPLACE PACKAGE AD_SYNC_OWNER.AD_SYNC_PROCESS_GROUP_PRIVILEGES
  AUTHID CURRENT_USER AS

  PROCEDURE ADD_SYSTEM_PRIVILEGES_AND_ROLES (
    P_PROCESS_RUN NUMBER
  );

  PROCEDURE ADD_OBJECT_PRIVILEGES (
    P_PROCESS_RUN NUMBER
  );

  PROCEDURE CLEAN_GROUP (
    P_GROUP VARCHAR2
  , P_PROCESS_RUN NUMBER
  );

  PROCEDURE CLEAN_ALL_GROUPS (
    P_PROCESS_RUN NUMBER
  );

  PROCEDURE GRANT_PRIVILEGES_TO_GROUPS (
    P_PROCESS_RUN NUMBER
  );
END AD_SYNC_PROCESS_GROUP_PRIVILEGES;
/

prompt CREATE OR REPLACE PACKAGE BODY ad_sync_owner.ad_sync_process_group_privileges

CREATE OR REPLACE PACKAGE BODY AD_SYNC_OWNER.AD_SYNC_PROCESS_GROUP_PRIVILEGES AS

  PROCEDURE GRANT_PRIVILEGES_TO_GROUPS (
    P_PROCESS_RUN NUMBER
  ) IS
  BEGIN
    AD_SYNC_LOG.WRITE_INFO( $$PLSQL_UNIT
                            || '->grant_privileges_to_groups started', SQLCODE, SQLERRM, P_PROCESS_RUN );
 
    --clean all groups
    --clean_all_groups('*', P_PROCESS_RUN);
    --add system privileges and roles
    ADD_SYSTEM_PRIVILEGES_AND_ROLES(P_PROCESS_RUN);
 
    --add object privileges
    ADD_OBJECT_PRIVILEGES(P_PROCESS_RUN);
    AD_SYNC_LOG.WRITE_INFO( $$PLSQL_UNIT
                            || '->grant_privileges_to_groups finished', SQLCODE, SQLERRM, P_PROCESS_RUN );
  EXCEPTION
    WHEN OTHERS THEN
      AD_SYNC_LOG.WRITE_ERROR( $$PLSQL_UNIT
                               || '->grant_privileges_to_groups', SQLCODE, SQLERRM, P_PROCESS_RUN );
      RAISE;
  END GRANT_PRIVILEGES_TO_GROUPS;

  PROCEDURE CLEAN_ALL_GROUPS (
    P_PROCESS_RUN NUMBER
  ) IS
  BEGIN
    AD_SYNC_LOG.WRITE_INFO( $$PLSQL_UNIT
                            || '->clean_all_groups started', SQLCODE, SQLERRM, P_PROCESS_RUN );
 
    --clean all groups
    FOR I IN (
      SELECT
        ROLE AS GROUPNAME
      FROM
        DBA_ROLES
      WHERE
        ROLE LIKE AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('GROUPNAME_PREFIX')
                                              ||'%'
    ) LOOP
      CLEAN_GROUP(I.GROUPNAME, P_PROCESS_RUN);
    END LOOP;

    AD_SYNC_LOG.WRITE_INFO( $$PLSQL_UNIT
                            || '->clean_all_groups finished', SQLCODE, SQLERRM, P_PROCESS_RUN );
  END CLEAN_ALL_GROUPS;

  PROCEDURE CLEAN_GROUP (
    P_GROUP VARCHAR2
  , P_PROCESS_RUN NUMBER
  ) IS
  BEGIN
    AD_SYNC_LOG.WRITE_INFO( $$PLSQL_UNIT
                            || '->clean_group started: '
                            ||P_GROUP, SQLCODE, SQLERRM, P_PROCESS_RUN );
 
    --clean roles granted to role
    FOR I IN (
      SELECT
        'revoke '
        || GRANTED_ROLE
        || ' from '
        || ROLE AS STMT
      FROM
        ROLE_ROLE_PRIVS
      WHERE
        ROLE = P_GROUP
        AND ROLE LIKE AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('GROUPNAME_PREFIX')
                                                  ||'%'
    ) LOOP
      BEGIN
 
        --DBMS_OUTPUT.PUT_LINE(I.STMT);
        EXECUTE IMMEDIATE I.STMT;
      EXCEPTION
        WHEN OTHERS THEN
          AD_SYNC_LOG.WRITE_ERROR( $$PLSQL_UNIT
                                   || '->clean_group', SQLCODE, SQLERRM, P_PROCESS_RUN );
      END;
    END LOOP;
 

    --clean system privileges granted to role
    FOR I IN (
      SELECT
        'revoke '
        || PRIVILEGE
        || ' from '
        || ROLE AS STMT
      FROM
        ROLE_SYS_PRIVS
      WHERE
        ROLE = P_GROUP
        AND ROLE LIKE AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('GROUPNAME_PREFIX')
                                                  ||'%'
    ) LOOP
      BEGIN
 
        --DBMS_OUTPUT.PUT_LINE(I.STMT);
        EXECUTE IMMEDIATE I.STMT;
      EXCEPTION
        WHEN OTHERS THEN
          AD_SYNC_LOG.WRITE_ERROR( $$PLSQL_UNIT
                                   || '->clean_group', SQLCODE, SQLERRM, P_PROCESS_RUN );
      END;
    END LOOP;
 

    --clean object privileges granted to role
    FOR I IN (
      SELECT
        'revoke '
        || PRIVILEGE
        || ' on '
        || OWNER
        || '.'
        || TABLE_NAME
        || ' from '
        || ROLE AS STMT
      FROM
        ROLE_TAB_PRIVS
      WHERE
        ROLE = P_GROUP
        AND ROLE LIKE AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('GROUPNAME_PREFIX')
                                                  ||'%'
    ) LOOP
      BEGIN
 
        --DBMS_OUTPUT.PUT_LINE(I.STMT);
        EXECUTE IMMEDIATE I.STMT;
      EXCEPTION
        WHEN OTHERS THEN
          AD_SYNC_LOG.WRITE_ERROR( $$PLSQL_UNIT
                                   || '->clean_group', SQLCODE, SQLERRM, P_PROCESS_RUN );
      END;
    END LOOP;

    AD_SYNC_LOG.WRITE_INFO( $$PLSQL_UNIT
                            || '->clean_group finished', SQLCODE, SQLERRM, P_PROCESS_RUN );
  END CLEAN_GROUP;

  PROCEDURE ADD_SYSTEM_PRIVILEGES_AND_ROLES (
    P_PROCESS_RUN NUMBER
  ) IS
  BEGIN
    AD_SYNC_LOG.WRITE_INFO( $$PLSQL_UNIT
                            || '->add_system_privileges_and_roles started', SQLCODE, SQLERRM, P_PROCESS_RUN );
    FOR J IN (
      SELECT
        'grant '
        || PERMISSION
        || '  to '
        || GROUPNAME AS STMT
      FROM
        AD_SYNC_OWNER.AD_SYNC_GROUP_PERMISSION
      WHERE
        SCHEMA = '*'
        AND OBJECT_NAME = '*'
    ) LOOP
      BEGIN
 
        --DBMS_OUTPUT.PUT_LINE(J.STMT);
        EXECUTE IMMEDIATE J.STMT;
      EXCEPTION
        WHEN OTHERS THEN
          AD_SYNC_LOG.WRITE_ERROR( $$PLSQL_UNIT
                                   || '->add_system_privileges_and_roles', SQLCODE, SQLERRM, P_PROCESS_RUN );
      END;
    END LOOP;

    AD_SYNC_LOG.WRITE_INFO( $$PLSQL_UNIT
                            || '->add_system_privileges_and_roles finished', SQLCODE, SQLERRM, P_PROCESS_RUN );
  EXCEPTION
    WHEN OTHERS THEN
      AD_SYNC_LOG.WRITE_ERROR( $$PLSQL_UNIT
                               || '->add_system_privileges_and_roles', SQLCODE, SQLERRM, P_PROCESS_RUN );
      RAISE;
  END ADD_SYSTEM_PRIVILEGES_AND_ROLES;

  PROCEDURE ADD_OBJECT_PRIVILEGES (
    P_PROCESS_RUN NUMBER
  ) IS
  BEGIN
    AD_SYNC_LOG.WRITE_INFO( $$PLSQL_UNIT
                            || '->add_object_privileges started', SQLCODE, SQLERRM, P_PROCESS_RUN );
 /* whole schema privileges */
    FOR J IN (
      SELECT
        *
      FROM
        AD_SYNC_OWNER.AD_SYNC_GROUP_PERMISSION
      WHERE
        SCHEMA <> '*'
        AND OBJECT_NAME = '*'
        AND GROUPNAME LIKE AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('GROUPNAME_PREFIX')
                                                  ||'%'
    ) LOOP
      FOR I IN (
        SELECT
          'grant '
          || J.PERMISSION
          || ' on "'
          || J.SCHEMA
          || '"."'
          || OBJECT_NAME
          || '" to '
          || J.GROUPNAME AS STMT
        FROM
          DBA_OBJECTS
        WHERE
          OWNER = J.SCHEMA
          AND OBJECT_TYPE IN ( 'TABLE', 'VIEW', 'MATERIALIZED VIEW', 'SEQUENCE' )
        ORDER BY
          OBJECT_TYPE
        , OWNER
        , OBJECT_NAME
      ) LOOP
        BEGIN
 
          --DBMS_OUTPUT.PUT_LINE(I.STMT);
          EXECUTE IMMEDIATE I.STMT;
        EXCEPTION
          WHEN OTHERS THEN
            AD_SYNC_LOG.WRITE_ERROR( $$PLSQL_UNIT
                                     || '->add_object_privileges', SQLCODE, SQLERRM, P_PROCESS_RUN );
        END;
      END LOOP;
    END LOOP;
 
 
 /* given object  privileges */
    FOR J IN (
      SELECT
        'grant '
        || PERMISSION
        || ' on "'
        || SCHEMA
        || '"."'
        || OBJECT_NAME
        || '" to '
        || GROUPNAME AS STMT
      FROM
        AD_SYNC_OWNER.AD_SYNC_GROUP_PERMISSION
      WHERE
        SCHEMA <> '*'
        AND OBJECT_NAME <> '*'
        AND GROUPNAME LIKE AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('GROUPNAME_PREFIX')
                                                  ||'%'
    ) LOOP
      BEGIN
 
        --DBMS_OUTPUT.PUT_LINE(I.STMT);
        EXECUTE IMMEDIATE J.STMT;
      EXCEPTION
        WHEN OTHERS THEN
          AD_SYNC_LOG.WRITE_ERROR( $$PLSQL_UNIT
                                   || '->add_object_privileges', SQLCODE, SQLERRM, P_PROCESS_RUN );
      END;
    END LOOP;

    AD_SYNC_LOG.WRITE_INFO( $$PLSQL_UNIT
                            || '->add_object_privileges finished', SQLCODE, SQLERRM, P_PROCESS_RUN );
  EXCEPTION
    WHEN OTHERS THEN
      AD_SYNC_LOG.WRITE_ERROR( $$PLSQL_UNIT
                               || '->add_object_privileges', SQLCODE, SQLERRM, P_PROCESS_RUN );
      RAISE;
  END ADD_OBJECT_PRIVILEGES;
END AD_SYNC_PROCESS_GROUP_PRIVILEGES;
/