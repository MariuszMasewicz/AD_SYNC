prompt CREATE OR REPLACE PACKAGE ad_sync_owner.ad_sync_process_group_tablespace_quotas

CREATE OR REPLACE PACKAGE AD_SYNC_OWNER.AD_SYNC_PROCESS_GROUP_TABLESPACE_QUOTAS
  AUTHID CURRENT_USER AS

  PROCEDURE ADD_GROUP_MEMBERS_TABLESPACE_QUOTAS (
    P_PROCESS_RUN NUMBER
  );
END AD_SYNC_PROCESS_GROUP_TABLESPACE_QUOTAS;
/

prompt CREATE OR REPLACE PACKAGE BODY ad_sync_owner.ad_sync_process_group_tablespace_quotas

CREATE OR REPLACE PACKAGE BODY AD_SYNC_OWNER.AD_SYNC_PROCESS_GROUP_TABLESPACE_QUOTAS AS

  PROCEDURE ADD_GROUP_MEMBERS_TABLESPACE_QUOTAS (
    P_PROCESS_RUN NUMBER
  )AS
  BEGIN
    AD_SYNC_LOG.WRITE_INFO( $$PLSQL_UNIT
                            || '->ADD_GROUP_MEMBERS_TABLESPACE_QUOTAS started', SQLCODE, SQLERRM, P_PROCESS_RUN );
    DECLARE
      V_STMT VARCHAR2(4000);
    BEGIN
      FOR I IN (
        SELECT
          *
        FROM
          AD_SYNC_OWNER.AD_SYNC_GROUP_TABLESPACE_QUOTAS
      ) LOOP
        FOR J IN (
          SELECT
            GRANTEE
          FROM
            DBA_ROLE_PRIVS
          WHERE
            GRANTED_ROLE = I.GROUPNAME
        ) LOOP
          V_STMT:='ALTER USER '
                  ||J.GRANTEE
                  ||' QUOTA '
                  ||I.QUOTA
                  ||' ON '
                  ||I.TABLESPACE;
 
          --DBMS_OUTPUT.PUT_LINE( V_STMT );
          EXECUTE IMMEDIATE V_STMT;
        END LOOP;
      END LOOP;
    END;

    AD_SYNC_LOG.WRITE_INFO( $$PLSQL_UNIT
                            || '->ADD_GROUP_MEMBERS_TABLESPACE_QUOTAS finished', SQLCODE, SQLERRM, P_PROCESS_RUN );
  EXCEPTION
    WHEN OTHERS THEN
      AD_SYNC_LOG.WRITE_ERROR( $$PLSQL_UNIT
                               || '->ADD_GROUP_MEMBERS_TABLESPACE_QUOTAS', SQLCODE, SQLERRM, P_PROCESS_RUN );
      RAISE;
  END ADD_GROUP_MEMBERS_TABLESPACE_QUOTAS;
END AD_SYNC_PROCESS_GROUP_TABLESPACE_QUOTAS;
/