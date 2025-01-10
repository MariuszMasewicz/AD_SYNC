prompt CREATE OR REPLACE PACKAGE  ad_sync_owner.ad_sync_process_users

CREATE OR REPLACE PACKAGE  ad_sync_owner.ad_sync_process_users AUTHID current_user AS
    PROCEDURE add_users (p_start_timestamp timestamp, p_end_timestamp timestamp, p_process_run number, p_load_id number);
    PROCEDURE drop_users (p_start_timestamp timestamp, p_end_timestamp timestamp, p_process_run number, p_load_id number);
    PROCEDURE lock_users (p_start_timestamp timestamp, p_end_timestamp timestamp, p_process_run number, p_load_id number);
    PROCEDURE unlock_users (p_start_timestamp timestamp, p_end_timestamp timestamp, p_process_run number, p_load_id number);
    PROCEDURE mark_existing_users (p_start_timestamp timestamp, p_end_timestamp timestamp, p_process_run number, p_load_id number);
    PROCEDURE change_password (p_start_timestamp timestamp, p_end_timestamp timestamp, p_process_run number, p_load_id number);
    PROCEDURE expire_password (p_start_timestamp timestamp, p_end_timestamp timestamp, p_process_run number, p_load_id number);
END ad_sync_process_users;
/

prompt CREATE OR REPLACE PACKAGE BODY ad_sync_owner.ad_sync_process_users
CREATE OR REPLACE PACKAGE BODY ad_sync_owner.ad_sync_process_users AS

PROCEDURE drop_users (p_start_timestamp timestamp, p_end_timestamp timestamp, p_process_run number, p_load_id number) as
        v_stmt VARCHAR2(4000);
    BEGIN
        if p_process_run is not null then
        ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->drop_users started for: '||p_start_timestamp||' and '||p_end_timestamp,
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
        FOR i IN (
            SELECT
                au.id, au.username
            FROM
                ad_sync_owner.ad_sync_users au join ad_sync_owner.AD_SYNC_MANAGED_USERS u on (au.username=u.username)
            WHERE
                au.status = 1
                and au.REQUESTED_OPERATION = 'D' --requested drop user
                and au.username like ad_sync_owner.ad_sync_tools.get_param_value('USERNAME_PREFIX')||'%'
                and au.CREATED_TIMESTAMP between p_start_timestamp and p_end_timestamp
                )
         LOOP
           if ad_sync_owner.ad_sync_tools.get_param_value('SYNC_USERS_LOCK_INSTEAD_OF_DROP') = '1' then 
            v_stmt := 'alter user ' || i.username 
                   || ' account lock'
                   || ' password expire';
            dbms_output.put_line(v_stmt||';');
            
            ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->drop_users lock user: '|| i.username,
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
            execute immediate v_stmt;
            UPDATE ad_sync_owner.ad_sync_users
            SET
                status = 26 -- user locked
                , PROCESS_TIMESTAMP = current_timestamp
                , load_id=p_load_id
            WHERE
                id = i.id;
            else 
            v_stmt := 'drop user ' || i.username 
                   || ' cascade';
            dbms_output.put_line(v_stmt||';');
            
            ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->drop_users dropped user: '|| i.username,
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
            execute immediate v_stmt;
            UPDATE ad_sync_owner.ad_sync_users
            SET
                status = 22 -- user dropped
                , PROCESS_TIMESTAMP = current_timestamp
                , load_id=p_load_id
            WHERE
                id = i.id;

            end if;
        END LOOP;

        COMMIT;
        ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->drop_users  finished',
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
         end if;                   
    EXCEPTION
      WHEN OTHERS THEN
        ad_sync_log.write_error($$PLSQL_UNIT ||
                            '->drop_users' ,
                            SQLCODE,
                            SQLERRM);
        RAISE;
    
    END drop_users;

PROCEDURE expire_password (p_start_timestamp timestamp, p_end_timestamp timestamp, p_process_run number, p_load_id number) as
        v_stmt VARCHAR2(4000);
    BEGIN
        if p_process_run is not null then
        ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->expire_password started for: '||p_start_timestamp||' and '||p_end_timestamp,
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
        FOR i IN (
            SELECT
                au.id, au.username
            FROM
                ad_sync_owner.ad_sync_users au join ad_sync_owner.AD_SYNC_MANAGED_USERS u on (au.username=u.username)
            WHERE
                au.status = 1
                and au.REQUESTED_OPERATION = 'E' --requested create user
                and au.username like ad_sync_owner.ad_sync_tools.get_param_value('USERNAME_PREFIX')||'%'
                and au.CREATED_TIMESTAMP between p_start_timestamp and p_end_timestamp
                )
         LOOP
            v_stmt := 'alter user ' || i.username 
                   || ' password expire';
            dbms_output.put_line(v_stmt||';');
            
            ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->expire_password password expired: '|| i.username,
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
            execute immediate v_stmt;
            UPDATE ad_sync_owner.ad_sync_users
            SET
                status = 23 -- password expired
                , PROCESS_TIMESTAMP = current_timestamp
                , load_id=p_load_id
            WHERE
                id = i.id;


        END LOOP;

        COMMIT;
        ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->expire_password  finished',
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
         end if;                   
    EXCEPTION
      WHEN OTHERS THEN
        ad_sync_log.write_error($$PLSQL_UNIT ||
                            '->expire_password' ,
                            SQLCODE,
                            SQLERRM);
        RAISE;
    
    END expire_password;


PROCEDURE change_password (p_start_timestamp timestamp, p_end_timestamp timestamp, p_process_run number, p_load_id number) as
        v_stmt VARCHAR2(4000);
        v_file_name varchar2(100);
        v_file  UTL_FILE.FILE_TYPE;
    BEGIN
        if p_process_run is not null then
        ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->change_password started for: '||p_start_timestamp||' and '||p_end_timestamp,
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
        FOR i IN (
            SELECT
                au.id, au.username, nvl(au.password,ad_sync_owner.ad_sync_tools.generate_password) as password
            FROM
                ad_sync_owner.ad_sync_users au join ad_sync_owner.AD_SYNC_MANAGED_USERS u on (au.username=u.username)
            WHERE
                au.status = 1
                and au.REQUESTED_OPERATION = 'P' --requested create user
                and au.username like ad_sync_owner.ad_sync_tools.get_param_value('USERNAME_PREFIX')||'%'
                and au.CREATED_TIMESTAMP between p_start_timestamp and p_end_timestamp
                )
         LOOP
            v_stmt := 'alter user ' || i.username 
                   || ' identified by "'|| i.password||'"'
                   || ' account unlock';
            dbms_output.put_line(v_stmt||';');
            
            ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->change_password password changed: '|| i.username,
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
            execute immediate v_stmt;
            if ad_sync_owner.ad_sync_tools.get_param_value('STORE_USER_PASSWORD_IN_TABLE') ='1' then
            UPDATE ad_sync_owner.ad_sync_users
            SET
                status = 24 -- password changed
                , PROCESS_TIMESTAMP = current_timestamp
                , password = i.password
                , load_id=p_load_id
            WHERE
                id = i.id;
             else 
             UPDATE ad_sync_owner.ad_sync_users
            SET
                status = 24 -- user created
                , PROCESS_TIMESTAMP = current_timestamp
                --, password = i.password
                , load_id=p_load_id
            WHERE
                id = i.id;  
            end if; 

            if ad_sync_owner.ad_sync_tools.get_param_value('STORE_USER_PASSWORD_IN_FILE') ='1' then
            v_file_name := ad_sync_owner.ad_sync_tools.generate_password;
            UPDATE ad_sync_owner.ad_sync_users
            SET
                password_file = v_file_name
                , load_id=p_load_id
            WHERE
                id = i.id;  
             v_file := UTL_FILE.FOPEN(ad_sync_owner.ad_sync_tools.get_param_value('STORE_USER_PASSWORD_IN_FILE_DIRECTORY'), v_file_name, 'w');

            UTL_FILE.PUT(v_file, i.password);
            UTL_FILE.FCLOSE(v_file);   
            end if;

        END LOOP;

        COMMIT;
        ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->change_password finished',
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
         end if;                   
    EXCEPTION
      WHEN OTHERS THEN
        ad_sync_log.write_error($$PLSQL_UNIT ||
                            '->change_password' ,
                            SQLCODE,
                            SQLERRM);
        RAISE;
    
    END change_password;

PROCEDURE unlock_users (p_start_timestamp timestamp, p_end_timestamp timestamp, p_process_run number, p_load_id number) as
        v_stmt VARCHAR2(4000);
    BEGIN
        if p_process_run is not null then
        ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->unlock_users started for: '||p_start_timestamp||' and '||p_end_timestamp,
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
        FOR i IN (
            SELECT
                au.id, au.username, ad_sync_owner.ad_sync_tools.generate_password as password
            FROM
                ad_sync_owner.ad_sync_users au join ad_sync_owner.AD_SYNC_MANAGED_USERS u on (au.username=u.username)
            WHERE
                au.status = 1
                and au.REQUESTED_OPERATION = 'U' --requested unlock user
                and au.username like ad_sync_owner.ad_sync_tools.get_param_value('USERNAME_PREFIX')||'%'
                and au.CREATED_TIMESTAMP between p_start_timestamp and p_end_timestamp
                )
         LOOP
            v_stmt := 'alter user ' || i.username 
                   || ' account unlock';
            dbms_output.put_line(v_stmt||';');
            
            ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->unlock_users unlocked users: '|| i.username,
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
            execute immediate v_stmt;
            UPDATE ad_sync_owner.ad_sync_users
            SET
                status = 25 -- user unlocked
                , PROCESS_TIMESTAMP = current_timestamp
                , load_id=p_load_id
            WHERE
                id = i.id;

        END LOOP;

        COMMIT;
        ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->unlock_users finished',
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
         end if;                   
    EXCEPTION
      WHEN OTHERS THEN
        ad_sync_log.write_error($$PLSQL_UNIT ||
                            '->unlock_users' ,
                            SQLCODE,
                            SQLERRM);
        RAISE;
    end unlock_users;

    PROCEDURE lock_users (p_start_timestamp timestamp, p_end_timestamp timestamp, p_process_run number, p_load_id number) as
        v_stmt VARCHAR2(4000);
    BEGIN
        if p_process_run is not null then
        ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->lock_users started for: '||p_start_timestamp||' and '||p_end_timestamp,
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
        FOR i IN (
            SELECT
                au.id, au.username, ad_sync_owner.ad_sync_tools.generate_password as password
            FROM
                ad_sync_owner.ad_sync_users au join ad_sync_owner.AD_SYNC_MANAGED_USERS u on (au.username=u.username)
            WHERE
                au.status = 1
                and au.REQUESTED_OPERATION = 'L' --requested lock  user
                and au.username like ad_sync_owner.ad_sync_tools.get_param_value('USERNAME_PREFIX')||'%'
                and au.CREATED_TIMESTAMP between p_start_timestamp and p_end_timestamp
                )
         LOOP
            v_stmt := 'alter user ' || i.username 
                   || ' account lock';
            dbms_output.put_line(v_stmt||';');
            
            ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->lock_users lock user: '|| i.username,
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
            execute immediate v_stmt;
            UPDATE ad_sync_owner.ad_sync_users
            SET
                status = 26 -- user locked
                , PROCESS_TIMESTAMP = current_timestamp
                , load_id=p_load_id
            WHERE
                id = i.id;

        END LOOP;

        COMMIT;
        ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->lock_users finished',
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
         end if;                   
    EXCEPTION
      WHEN OTHERS THEN
        ad_sync_log.write_error($$PLSQL_UNIT ||
                            '->lock_users' ,
                            SQLCODE,
                            SQLERRM);
        RAISE;
    end lock_users;
    
    PROCEDURE mark_existing_users (p_start_timestamp timestamp, p_end_timestamp timestamp, p_process_run number, p_load_id number) is
    v_number_of_existing pls_integer;
    begin
      if p_process_run is not null then
      ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->mark_existing_users started for: '||p_start_timestamp||' and '||p_end_timestamp,
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
      /* existing users*/
      UPDATE ad_sync_owner.ad_sync_users
            SET
                status = 28 -- user exists in database
                , PROCESS_TIMESTAMP = current_timestamp
                , load_id=p_load_id
            WHERE
                username in (select username from ad_sync_owner.AD_SYNC_MANAGED_USERS)
                and status = 1
                and REQUESTED_OPERATION = 'C' --requested create user
                and username like ad_sync_owner.ad_sync_tools.get_param_value('USERNAME_PREFIX')||'%'
                and CREATED_TIMESTAMP between p_start_timestamp and p_end_timestamp;
            v_number_of_existing := SQL%ROWCOUNT;
            commit;    
            ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->mark_existing_users number of existing: '||v_number_of_existing,
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
        /* bad prefix*/
      UPDATE ad_sync_owner.ad_sync_users
            SET
                status = 27 -- invalid user prefix
                , PROCESS_TIMESTAMP = current_timestamp
                , load_id=p_load_id
            WHERE
                username not like ad_sync_owner.ad_sync_tools.get_param_value('USERNAME_PREFIX')||'%'
                and status = 1
                and CREATED_TIMESTAMP between p_start_timestamp and p_end_timestamp;
            v_number_of_existing := SQL%ROWCOUNT;
            commit;    
            ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->mark_existing_users number of bad prefixes: '||v_number_of_existing,
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
      end if;
    EXCEPTION
      WHEN OTHERS THEN
        ad_sync_log.write_error($$PLSQL_UNIT ||
                            '->add_users' ,
                            SQLCODE,
                            SQLERRM);
        RAISE;
    end mark_existing_users;

    PROCEDURE add_users (p_start_timestamp timestamp, p_end_timestamp timestamp, p_process_run number, p_load_id number) IS
        v_stmt VARCHAR2(4000);
        v_file_name varchar2(100);
        v_file  UTL_FILE.FILE_TYPE;
    BEGIN
        if p_process_run is not null then
        ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->add_users started for: '||p_start_timestamp||' and '||p_end_timestamp,
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
        FOR i IN (
            SELECT
                au.id, au.username, nvl(au.password,ad_sync_owner.ad_sync_tools.generate_password) as password
            FROM
                ad_sync_owner.ad_sync_users au left join ad_sync_owner.AD_SYNC_MANAGED_USERS u on (au.username=u.username)
            WHERE
                au.status = 1
                and au.REQUESTED_OPERATION = 'C' --requested create user
                and au.username like ad_sync_owner.ad_sync_tools.get_param_value('USERNAME_PREFIX')||'%'
                and au.CREATED_TIMESTAMP between p_start_timestamp and p_end_timestamp
                and u.username is null
                )
         LOOP
            v_stmt := 'create user ' || i.username 
                   || ' identified by "'|| i.password||'"'
                   || ' DEFAULT TABLESPACE '||ad_sync_owner.ad_sync_tools.get_param_value('USER_TABLESPACE')
                   || ' TEMPORARY TABLESPACE ' ||ad_sync_owner.ad_sync_tools.get_param_value('USER_TEMP_TABLESPACE')
                   || ' account '||ad_sync_owner.ad_sync_tools.get_param_value('USER_ACCOUNT_LOCK_STATUS')
                   || ' profile ad_sync_default_profile'
                   --|| ' password expire'
                   ;
            dbms_output.put_line(v_stmt||';');
            
            ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->add_users create user: '|| i.username,
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
            execute immediate v_stmt;
            if ad_sync_owner.ad_sync_tools.get_param_value('STORE_USER_PASSWORD_IN_TABLE') ='1' then
            UPDATE ad_sync_owner.ad_sync_users
            SET
                status = 29 -- user created
                , PROCESS_TIMESTAMP = current_timestamp
                , password = i.password
                , load_id=p_load_id
            WHERE
                id = i.id;
             else 
             UPDATE ad_sync_owner.ad_sync_users
            SET
                status = 29 -- user created
                , PROCESS_TIMESTAMP = current_timestamp
                --, password = i.password
                , load_id=p_load_id
            WHERE
                id = i.id;  
            end if; 

            if ad_sync_owner.ad_sync_tools.get_param_value('STORE_USER_PASSWORD_IN_FILE') ='1' then
            v_file_name := ad_sync_owner.ad_sync_tools.generate_password;
            UPDATE ad_sync_owner.ad_sync_users
            SET
                password_file = v_file_name
                , load_id=p_load_id
            WHERE
                id = i.id;  
             v_file := UTL_FILE.FOPEN(ad_sync_owner.ad_sync_tools.get_param_value('STORE_USER_PASSWORD_IN_FILE_DIRECTORY'), v_file_name, 'w');

            UTL_FILE.PUT(v_file, i.password);
            UTL_FILE.FCLOSE(v_file);   
            end if;

        END LOOP;

        COMMIT;
        ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->add_users finished',
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
         end if;                   
    EXCEPTION
      WHEN OTHERS THEN
        ad_sync_log.write_error($$PLSQL_UNIT ||
                            '->add_users' ,
                            SQLCODE,
                            SQLERRM);
        RAISE;
    
    END add_users;

END ad_sync_process_users;
/
