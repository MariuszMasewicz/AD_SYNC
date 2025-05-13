prompt CREATE OR REPLACE PACKAGE ad_sync_owner.ad_sync_process_users

CREATE OR REPLACE PACKAGE AD_SYNC_OWNER.AD_SYNC_PROCESS_USERS
    AUTHID CURRENT_USER AS

    PROCEDURE ADD_USERS (
        P_START_TIMESTAMP TIMESTAMP,
        P_END_TIMESTAMP TIMESTAMP,
        P_PROCESS_RUN NUMBER,
        P_LOAD_ID NUMBER
    );

    PROCEDURE DROP_USERS (
        P_START_TIMESTAMP TIMESTAMP,
        P_END_TIMESTAMP TIMESTAMP,
        P_PROCESS_RUN NUMBER,
        P_LOAD_ID NUMBER
    );

    PROCEDURE LOCK_USERS (
        P_START_TIMESTAMP TIMESTAMP,
        P_END_TIMESTAMP TIMESTAMP,
        P_PROCESS_RUN NUMBER,
        P_LOAD_ID NUMBER
    );

    PROCEDURE UNLOCK_USERS (
        P_START_TIMESTAMP TIMESTAMP,
        P_END_TIMESTAMP TIMESTAMP,
        P_PROCESS_RUN NUMBER,
        P_LOAD_ID NUMBER
    );

    PROCEDURE MARK_EXISTING_USERS (
        P_START_TIMESTAMP TIMESTAMP,
        P_END_TIMESTAMP TIMESTAMP,
        P_PROCESS_RUN NUMBER,
        P_LOAD_ID NUMBER
    );

    PROCEDURE CHANGE_PASSWORD (
        P_START_TIMESTAMP TIMESTAMP,
        P_END_TIMESTAMP TIMESTAMP,
        P_PROCESS_RUN NUMBER,
        P_LOAD_ID NUMBER
    );

    PROCEDURE EXPIRE_PASSWORD (
        P_START_TIMESTAMP TIMESTAMP,
        P_END_TIMESTAMP TIMESTAMP,
        P_PROCESS_RUN NUMBER,
        P_LOAD_ID NUMBER
    );
END AD_SYNC_PROCESS_USERS;
/

prompt CREATE OR REPLACE PACKAGE BODY ad_sync_owner.ad_sync_process_users

CREATE OR REPLACE PACKAGE BODY AD_SYNC_OWNER.AD_SYNC_PROCESS_USERS AS

    PROCEDURE DROP_USERS (
        P_START_TIMESTAMP TIMESTAMP,
        P_END_TIMESTAMP TIMESTAMP,
        P_PROCESS_RUN NUMBER,
        P_LOAD_ID NUMBER
    ) AS
        V_STMT VARCHAR2(4000);
    BEGIN
        IF P_PROCESS_RUN IS NOT NULL THEN
            AD_SYNC_LOG.WRITE_INFO($$PLSQL_UNIT
                                   || '->drop_users started for: '
                                   ||P_START_TIMESTAMP
                                   ||' and '
                                   ||P_END_TIMESTAMP, SQLCODE, SQLERRM, P_PROCESS_RUN);
            FOR I IN (
                SELECT
                    AU.ID,
                    AU.USERNAME
                FROM
                    AD_SYNC_OWNER.AD_SYNC_USERS         AU
                    JOIN AD_SYNC_OWNER.AD_SYNC_MANAGED_USERS U
                    ON (AU.USERNAME=U.USERNAME)
                WHERE
                    AU.STATUS = 1
                    AND AU.REQUESTED_OPERATION = 'D' --requested drop user
                    AND AU.USERNAME LIKE AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('USERNAME_PREFIX')
                                                                     ||'%'
                    AND AU.CREATED_TIMESTAMP BETWEEN P_START_TIMESTAMP AND P_END_TIMESTAMP
            ) LOOP
                IF AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('SYNC_USERS_LOCK_INSTEAD_OF_DROP') = '1' THEN
                    V_STMT := 'alter user '
                              || I.USERNAME
                              || ' account lock'
                              || ' password expire';
                    DBMS_OUTPUT.PUT_LINE(V_STMT
                                         ||';');
                    AD_SYNC_LOG.WRITE_INFO($$PLSQL_UNIT
                                           || '->drop_users lock user: '
                                           || I.USERNAME, SQLCODE, SQLERRM, P_PROCESS_RUN);
                    EXECUTE IMMEDIATE V_STMT;
                    UPDATE AD_SYNC_OWNER.AD_SYNC_USERS
                    SET
                        STATUS = 26 -- user locked
,
                        PROCESS_TIMESTAMP = CURRENT_TIMESTAMP,
                        LOAD_ID=P_LOAD_ID
                    WHERE
                        ID = I.ID;
                ELSE
                    V_STMT := 'drop user '
                              || I.USERNAME
                              || ' cascade';
                    DBMS_OUTPUT.PUT_LINE(V_STMT
                                         ||';');
                    AD_SYNC_LOG.WRITE_INFO($$PLSQL_UNIT
                                           || '->drop_users dropped user: '
                                           || I.USERNAME, SQLCODE, SQLERRM, P_PROCESS_RUN);
                    EXECUTE IMMEDIATE V_STMT;
                    UPDATE AD_SYNC_OWNER.AD_SYNC_USERS
                    SET
                        STATUS = 22 -- user dropped
,
                        PROCESS_TIMESTAMP = CURRENT_TIMESTAMP,
                        LOAD_ID=P_LOAD_ID
                    WHERE
                        ID = I.ID;
                END IF;
            END LOOP;

            COMMIT;
            AD_SYNC_LOG.WRITE_INFO($$PLSQL_UNIT
                                   || '->drop_users  finished', SQLCODE, SQLERRM, P_PROCESS_RUN);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            AD_SYNC_LOG.WRITE_ERROR($$PLSQL_UNIT
                                    || '->drop_users', SQLCODE, SQLERRM);
            RAISE;
    END DROP_USERS;

    PROCEDURE EXPIRE_PASSWORD (
        P_START_TIMESTAMP TIMESTAMP,
        P_END_TIMESTAMP TIMESTAMP,
        P_PROCESS_RUN NUMBER,
        P_LOAD_ID NUMBER
    ) AS
        V_STMT VARCHAR2(4000);
    BEGIN
        IF P_PROCESS_RUN IS NOT NULL THEN
            AD_SYNC_LOG.WRITE_INFO($$PLSQL_UNIT
                                   || '->expire_password started for: '
                                   ||P_START_TIMESTAMP
                                   ||' and '
                                   ||P_END_TIMESTAMP, SQLCODE, SQLERRM, P_PROCESS_RUN);
            FOR I IN (
                SELECT
                    AU.ID,
                    AU.USERNAME
                FROM
                    AD_SYNC_OWNER.AD_SYNC_USERS         AU
                    JOIN AD_SYNC_OWNER.AD_SYNC_MANAGED_USERS U
                    ON (AU.USERNAME=U.USERNAME)
                WHERE
                    AU.STATUS = 1
                    AND AU.REQUESTED_OPERATION = 'E' --requested create user
                    AND AU.USERNAME LIKE AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('USERNAME_PREFIX')
                                                                     ||'%'
                    AND AU.CREATED_TIMESTAMP BETWEEN P_START_TIMESTAMP AND P_END_TIMESTAMP
            ) LOOP
                V_STMT := 'alter user '
                          || I.USERNAME
                          || ' password expire';
                DBMS_OUTPUT.PUT_LINE(V_STMT
                                     ||';');
                AD_SYNC_LOG.WRITE_INFO($$PLSQL_UNIT
                                       || '->expire_password password expired: '
                                       || I.USERNAME, SQLCODE, SQLERRM, P_PROCESS_RUN);
                EXECUTE IMMEDIATE V_STMT;
                UPDATE AD_SYNC_OWNER.AD_SYNC_USERS
                SET
                    STATUS = 23 -- password expired
,
                    PROCESS_TIMESTAMP = CURRENT_TIMESTAMP,
                    LOAD_ID=P_LOAD_ID
                WHERE
                    ID = I.ID;
            END LOOP;

            COMMIT;
            AD_SYNC_LOG.WRITE_INFO($$PLSQL_UNIT
                                   || '->expire_password  finished', SQLCODE, SQLERRM, P_PROCESS_RUN);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            AD_SYNC_LOG.WRITE_ERROR($$PLSQL_UNIT
                                    || '->expire_password', SQLCODE, SQLERRM);
            RAISE;
    END EXPIRE_PASSWORD;

    PROCEDURE CHANGE_PASSWORD (
        P_START_TIMESTAMP TIMESTAMP,
        P_END_TIMESTAMP TIMESTAMP,
        P_PROCESS_RUN NUMBER,
        P_LOAD_ID NUMBER
    ) AS
        V_STMT      VARCHAR2(4000);
        V_FILE_NAME VARCHAR2(100);
        V_FILE      UTL_FILE.FILE_TYPE;
    BEGIN
        IF P_PROCESS_RUN IS NOT NULL THEN
            AD_SYNC_LOG.WRITE_INFO($$PLSQL_UNIT
                                   || '->change_password started for: '
                                   ||P_START_TIMESTAMP
                                   ||' and '
                                   ||P_END_TIMESTAMP, SQLCODE, SQLERRM, P_PROCESS_RUN);
            FOR I IN (
                SELECT
                    AU.ID,
                    AU.USERNAME,
                    NVL(AU.PASSWORD, AD_SYNC_OWNER.AD_SYNC_TOOLS.GENERATE_PASSWORD) AS PASSWORD
                FROM
                    AD_SYNC_OWNER.AD_SYNC_USERS         AU
                    JOIN AD_SYNC_OWNER.AD_SYNC_MANAGED_USERS U
                    ON (AU.USERNAME=U.USERNAME)
                WHERE
                    AU.STATUS = 1
                    AND AU.REQUESTED_OPERATION = 'P' --requested create user
                    AND AU.USERNAME LIKE AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('USERNAME_PREFIX')
                                                                     ||'%'
                    AND AU.CREATED_TIMESTAMP BETWEEN P_START_TIMESTAMP AND P_END_TIMESTAMP
            ) LOOP
                V_STMT := 'alter user '
                          || I.USERNAME
                          || ' identified by "'
                          || I.PASSWORD
                          ||'"'
                          || ' account unlock';
                DBMS_OUTPUT.PUT_LINE(V_STMT
                                     ||';');
                AD_SYNC_LOG.WRITE_INFO($$PLSQL_UNIT
                                       || '->change_password password changed: '
                                       || I.USERNAME, SQLCODE, SQLERRM, P_PROCESS_RUN);
                EXECUTE IMMEDIATE V_STMT;
                IF AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('STORE_USER_PASSWORD_IN_TABLE') ='1' THEN
                    UPDATE AD_SYNC_OWNER.AD_SYNC_USERS
                    SET
                        STATUS = 24 -- password changed
,
                        PROCESS_TIMESTAMP = CURRENT_TIMESTAMP,
                        PASSWORD = I.PASSWORD,
                        LOAD_ID=P_LOAD_ID
                    WHERE
                        ID = I.ID;
                ELSE
                    UPDATE AD_SYNC_OWNER.AD_SYNC_USERS
                    SET
                        STATUS = 24 -- user created
,
                        PROCESS_TIMESTAMP = CURRENT_TIMESTAMP
 --, password = i.password
,
                        LOAD_ID=P_LOAD_ID
                    WHERE
                        ID = I.ID;
                END IF;

                IF AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('STORE_USER_PASSWORD_IN_FILE') ='1' THEN
                    V_FILE_NAME := AD_SYNC_OWNER.AD_SYNC_TOOLS.GENERATE_PASSWORD(
                        NO_OF_DIGITS => 2,
                        NO_OF_SPECIAL_CHARACTERS => 0,
                        NO_OF_LOWER => 5,
                        NO_OF_UPPER => 3
                    );
                    UPDATE AD_SYNC_OWNER.AD_SYNC_USERS
                    SET
                        PASSWORD_FILE = V_FILE_NAME,
                        LOAD_ID=P_LOAD_ID
                    WHERE
                        ID = I.ID;
                    V_FILE := UTL_FILE.FOPEN(AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('STORE_USER_PASSWORD_IN_FILE_DIRECTORY'), V_FILE_NAME, 'w');
                    UTL_FILE.PUT(V_FILE, I.PASSWORD);
                    UTL_FILE.FCLOSE(V_FILE);
                END IF;
            END LOOP;

            COMMIT;
            AD_SYNC_LOG.WRITE_INFO($$PLSQL_UNIT
                                   || '->change_password finished', SQLCODE, SQLERRM, P_PROCESS_RUN);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            AD_SYNC_LOG.WRITE_ERROR($$PLSQL_UNIT
                                    || '->change_password', SQLCODE, SQLERRM);
            RAISE;
    END CHANGE_PASSWORD;

    PROCEDURE UNLOCK_USERS (
        P_START_TIMESTAMP TIMESTAMP,
        P_END_TIMESTAMP TIMESTAMP,
        P_PROCESS_RUN NUMBER,
        P_LOAD_ID NUMBER
    ) AS
        V_STMT VARCHAR2(4000);
    BEGIN
        IF P_PROCESS_RUN IS NOT NULL THEN
            AD_SYNC_LOG.WRITE_INFO($$PLSQL_UNIT
                                   || '->unlock_users started for: '
                                   ||P_START_TIMESTAMP
                                   ||' and '
                                   ||P_END_TIMESTAMP, SQLCODE, SQLERRM, P_PROCESS_RUN);
            FOR I IN (
                SELECT
                    AU.ID,
                    AU.USERNAME,
                    AD_SYNC_OWNER.AD_SYNC_TOOLS.GENERATE_PASSWORD AS PASSWORD
                FROM
                    AD_SYNC_OWNER.AD_SYNC_USERS         AU
                    JOIN AD_SYNC_OWNER.AD_SYNC_MANAGED_USERS U
                    ON (AU.USERNAME=U.USERNAME)
                WHERE
                    AU.STATUS = 1
                    AND AU.REQUESTED_OPERATION = 'U' --requested unlock user
                    AND AU.USERNAME LIKE AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('USERNAME_PREFIX')
                                                                     ||'%'
                    AND AU.CREATED_TIMESTAMP BETWEEN P_START_TIMESTAMP AND P_END_TIMESTAMP
            ) LOOP
                V_STMT := 'alter user '
                          || I.USERNAME
                          || ' account unlock';
                DBMS_OUTPUT.PUT_LINE(V_STMT
                                     ||';');
                AD_SYNC_LOG.WRITE_INFO($$PLSQL_UNIT
                                       || '->unlock_users unlocked users: '
                                       || I.USERNAME, SQLCODE, SQLERRM, P_PROCESS_RUN);
                EXECUTE IMMEDIATE V_STMT;
                UPDATE AD_SYNC_OWNER.AD_SYNC_USERS
                SET
                    STATUS = 25 -- user unlocked
,
                    PROCESS_TIMESTAMP = CURRENT_TIMESTAMP,
                    LOAD_ID=P_LOAD_ID
                WHERE
                    ID = I.ID;
            END LOOP;

            COMMIT;
            AD_SYNC_LOG.WRITE_INFO($$PLSQL_UNIT
                                   || '->unlock_users finished', SQLCODE, SQLERRM, P_PROCESS_RUN);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            AD_SYNC_LOG.WRITE_ERROR($$PLSQL_UNIT
                                    || '->unlock_users', SQLCODE, SQLERRM);
            RAISE;
    END UNLOCK_USERS;

    PROCEDURE LOCK_USERS (
        P_START_TIMESTAMP TIMESTAMP,
        P_END_TIMESTAMP TIMESTAMP,
        P_PROCESS_RUN NUMBER,
        P_LOAD_ID NUMBER
    ) AS
        V_STMT VARCHAR2(4000);
    BEGIN
        IF P_PROCESS_RUN IS NOT NULL THEN
            AD_SYNC_LOG.WRITE_INFO($$PLSQL_UNIT
                                   || '->lock_users started for: '
                                   ||P_START_TIMESTAMP
                                   ||' and '
                                   ||P_END_TIMESTAMP, SQLCODE, SQLERRM, P_PROCESS_RUN);
            FOR I IN (
                SELECT
                    AU.ID,
                    AU.USERNAME,
                    AD_SYNC_OWNER.AD_SYNC_TOOLS.GENERATE_PASSWORD AS PASSWORD
                FROM
                    AD_SYNC_OWNER.AD_SYNC_USERS         AU
                    JOIN AD_SYNC_OWNER.AD_SYNC_MANAGED_USERS U
                    ON (AU.USERNAME=U.USERNAME)
                WHERE
                    AU.STATUS = 1
                    AND AU.REQUESTED_OPERATION = 'L' --requested lock  user
                    AND AU.USERNAME LIKE AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('USERNAME_PREFIX')
                                                                     ||'%'
                    AND AU.CREATED_TIMESTAMP BETWEEN P_START_TIMESTAMP AND P_END_TIMESTAMP
            ) LOOP
                V_STMT := 'alter user '
                          || I.USERNAME
                          || ' account lock';
                DBMS_OUTPUT.PUT_LINE(V_STMT
                                     ||';');
                AD_SYNC_LOG.WRITE_INFO($$PLSQL_UNIT
                                       || '->lock_users lock user: '
                                       || I.USERNAME, SQLCODE, SQLERRM, P_PROCESS_RUN);
                EXECUTE IMMEDIATE V_STMT;
                UPDATE AD_SYNC_OWNER.AD_SYNC_USERS
                SET
                    STATUS = 26 -- user locked
,
                    PROCESS_TIMESTAMP = CURRENT_TIMESTAMP,
                    LOAD_ID=P_LOAD_ID
                WHERE
                    ID = I.ID;
            END LOOP;

            COMMIT;
            AD_SYNC_LOG.WRITE_INFO($$PLSQL_UNIT
                                   || '->lock_users finished', SQLCODE, SQLERRM, P_PROCESS_RUN);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            AD_SYNC_LOG.WRITE_ERROR($$PLSQL_UNIT
                                    || '->lock_users', SQLCODE, SQLERRM);
            RAISE;
    END LOCK_USERS;

    PROCEDURE MARK_EXISTING_USERS (
        P_START_TIMESTAMP TIMESTAMP,
        P_END_TIMESTAMP TIMESTAMP,
        P_PROCESS_RUN NUMBER,
        P_LOAD_ID NUMBER
    ) IS
        V_NUMBER_OF_EXISTING PLS_INTEGER;
    BEGIN
        IF P_PROCESS_RUN IS NOT NULL THEN
            AD_SYNC_LOG.WRITE_INFO($$PLSQL_UNIT
                                   || '->mark_existing_users started for: '
                                   ||P_START_TIMESTAMP
                                   ||' and '
                                   ||P_END_TIMESTAMP, SQLCODE, SQLERRM, P_PROCESS_RUN);
 /* existing users*/
            UPDATE AD_SYNC_OWNER.AD_SYNC_USERS
            SET
                STATUS = 28 -- user exists in database
,
                PROCESS_TIMESTAMP = CURRENT_TIMESTAMP,
                LOAD_ID=P_LOAD_ID
            WHERE
                USERNAME IN (
                    SELECT
                        USERNAME
                    FROM
                        AD_SYNC_OWNER.AD_SYNC_MANAGED_USERS
                )
                AND STATUS = 1
                AND REQUESTED_OPERATION = 'C' --requested create user
                AND USERNAME LIKE AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('USERNAME_PREFIX')
                                                              ||'%'
                AND CREATED_TIMESTAMP BETWEEN P_START_TIMESTAMP AND P_END_TIMESTAMP;
            V_NUMBER_OF_EXISTING := SQL%ROWCOUNT;
            COMMIT;
            AD_SYNC_LOG.WRITE_INFO($$PLSQL_UNIT
                                   || '->mark_existing_users number of existing: '
                                   ||V_NUMBER_OF_EXISTING, SQLCODE, SQLERRM, P_PROCESS_RUN);
 /* bad prefix*/
            UPDATE AD_SYNC_OWNER.AD_SYNC_USERS
            SET
                STATUS = 27 -- invalid user prefix
,
                PROCESS_TIMESTAMP = CURRENT_TIMESTAMP,
                LOAD_ID=P_LOAD_ID
            WHERE
                USERNAME NOT LIKE AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('USERNAME_PREFIX')
                                                              ||'%'
                AND STATUS = 1
                AND CREATED_TIMESTAMP BETWEEN P_START_TIMESTAMP AND P_END_TIMESTAMP;
            V_NUMBER_OF_EXISTING := SQL%ROWCOUNT;
            COMMIT;
            AD_SYNC_LOG.WRITE_INFO($$PLSQL_UNIT
                                   || '->mark_existing_users number of bad prefixes: '
                                   ||V_NUMBER_OF_EXISTING, SQLCODE, SQLERRM, P_PROCESS_RUN);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            AD_SYNC_LOG.WRITE_ERROR($$PLSQL_UNIT
                                    || '->mark_existing_users', SQLCODE, SQLERRM);
            RAISE;
    END MARK_EXISTING_USERS;

    PROCEDURE ADD_USERS (
        P_START_TIMESTAMP TIMESTAMP,
        P_END_TIMESTAMP TIMESTAMP,
        P_PROCESS_RUN NUMBER,
        P_LOAD_ID NUMBER
    ) IS
        V_STMT      VARCHAR2(4000);
        V_FILE_NAME VARCHAR2(100);
        V_FILE      UTL_FILE.FILE_TYPE;
    BEGIN
        IF P_PROCESS_RUN IS NOT NULL THEN
            AD_SYNC_LOG.WRITE_INFO($$PLSQL_UNIT
                                   || '->add_users started for: '
                                   ||P_START_TIMESTAMP
                                   ||' and '
                                   ||P_END_TIMESTAMP, SQLCODE, SQLERRM, P_PROCESS_RUN);
            FOR I IN (
                SELECT
                    AU.ID,
                    AU.USERNAME,
                    NVL(AU.PASSWORD, AD_SYNC_OWNER.AD_SYNC_TOOLS.GENERATE_PASSWORD) AS PASSWORD
                FROM
                    AD_SYNC_OWNER.AD_SYNC_USERS         AU
                    LEFT JOIN AD_SYNC_OWNER.AD_SYNC_MANAGED_USERS U
                    ON (AU.USERNAME=U.USERNAME)
                WHERE
                    AU.STATUS = 1
                    AND AU.REQUESTED_OPERATION = 'C' --requested create user
                    AND AU.USERNAME LIKE AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('USERNAME_PREFIX')
                                                                     ||'%'
                    AND AU.CREATED_TIMESTAMP BETWEEN P_START_TIMESTAMP AND P_END_TIMESTAMP
                    AND U.USERNAME IS NULL
            ) LOOP
                V_STMT := 'create user '
                          || I.USERNAME
                          || ' identified by "'
                          || I.PASSWORD
                          ||'"'
                          || ' DEFAULT TABLESPACE '
                          ||AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('USER_TABLESPACE')
                          || ' TEMPORARY TABLESPACE '
                          ||AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('USER_TEMP_TABLESPACE')
                          || ' account '
                          ||AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('USER_ACCOUNT_LOCK_STATUS')
                          || ' profile ad_sync_default_profile'
 --|| ' password expire'
;
                DBMS_OUTPUT.PUT_LINE(V_STMT
                                     ||';');
                AD_SYNC_LOG.WRITE_INFO($$PLSQL_UNIT
                                       || '->add_users create user: '
                                       || I.USERNAME, SQLCODE, SQLERRM, P_PROCESS_RUN);
                EXECUTE IMMEDIATE V_STMT;
                EXECUTE IMMEDIATE 'grant connect to '
                                  ||I.USERNAME;
                IF AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('STORE_USER_PASSWORD_IN_TABLE') ='1' THEN
                    UPDATE AD_SYNC_OWNER.AD_SYNC_USERS
                    SET
                        STATUS = 29 -- user created
,
                        PROCESS_TIMESTAMP = CURRENT_TIMESTAMP,
                        PASSWORD = I.PASSWORD,
                        LOAD_ID=P_LOAD_ID
                    WHERE
                        ID = I.ID;
                ELSE
                    UPDATE AD_SYNC_OWNER.AD_SYNC_USERS
                    SET
                        STATUS = 29 -- user created
,
                        PROCESS_TIMESTAMP = CURRENT_TIMESTAMP
 --, password = i.password
,
                        LOAD_ID=P_LOAD_ID
                    WHERE
                        ID = I.ID;
                END IF;

                IF AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('STORE_USER_PASSWORD_IN_FILE') ='1' THEN
                    V_FILE_NAME := AD_SYNC_OWNER.AD_SYNC_TOOLS.GENERATE_PASSWORD(
                        NO_OF_DIGITS => 2,
                        NO_OF_SPECIAL_CHARACTERS => 0,
                        NO_OF_LOWER => 5,
                        NO_OF_UPPER => 3
                    );
                    UPDATE AD_SYNC_OWNER.AD_SYNC_USERS
                    SET
                        PASSWORD_FILE = V_FILE_NAME,
                        LOAD_ID=P_LOAD_ID
                    WHERE
                        ID = I.ID;
                    V_FILE := UTL_FILE.FOPEN(AD_SYNC_OWNER.AD_SYNC_TOOLS.GET_PARAM_VALUE('STORE_USER_PASSWORD_IN_FILE_DIRECTORY'), V_FILE_NAME, 'w');
                    UTL_FILE.PUT(V_FILE, I.PASSWORD);
                    UTL_FILE.FCLOSE(V_FILE);
                END IF;
            END LOOP;

            COMMIT;
            AD_SYNC_LOG.WRITE_INFO($$PLSQL_UNIT
                                   || '->add_users finished', SQLCODE, SQLERRM, P_PROCESS_RUN);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            AD_SYNC_LOG.WRITE_ERROR($$PLSQL_UNIT
                                    || '->add_users', SQLCODE, SQLERRM);
            RAISE;
    END ADD_USERS;
END AD_SYNC_PROCESS_USERS;
/