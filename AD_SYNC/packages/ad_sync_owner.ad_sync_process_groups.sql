prompt CREATE OR REPLACE PACKAGE  ad_sync_owner.ad_sync_process_users

CREATE OR REPLACE PACKAGE  ad_sync_owner.ad_sync_process_groups AUTHID current_user AS
    PROCEDURE add_groups (p_start_timestamp timestamp, p_end_timestamp timestamp, p_process_run number, p_load_id number);
    PROCEDURE drop_gropus (p_start_timestamp timestamp, p_end_timestamp timestamp, p_process_run number, p_load_id number);
    PROCEDURE mark_existing_groups (p_start_timestamp timestamp, p_end_timestamp timestamp, p_process_run number, p_load_id number);
 ND ad_sync_process_users;
/

prompt CREATE OR REPLACE PACKAGE BODY ad_sync_owner.ad_sync_process_groups
CREATE OR REPLACE PACKAGE BODY ad_sync_owner.ad_sync_process_groups AS

PROCEDURE drop_gropus (p_start_timestamp timestamp, p_end_timestamp timestamp, p_process_run number, p_load_id number) as
        v_stmt VARCHAR2(4000);
    BEGIN
        if p_process_run is not null then
        ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->drop_gropus started for: '||p_start_timestamp||' and '||p_end_timestamp,
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
        FOR i IN (
            SELECT
                au.id, au.username
            FROM
                ad_sync_owner.ad_sync_users au join all_users u on (au.username=u.username)
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
            else 
            v_stmt := 'drop user ' || i.username 
                   || ' cascade';
            dbms_output.put_line(v_stmt||';');
            
            ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->drop_gropus password expired: '|| i.username,
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
            execute immediate v_stmt;
            UPDATE ad_sync_owner.ad_sync_users
            SET
                status = 23 -- user dropped
                , PROCESS_TIMESTAMP = current_timestamp
                , load_id=p_load_id
            WHERE
                id = i.id;

            end if;
        END LOOP;

        COMMIT;
        ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->drop_gropus  finished',
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
         end if;                   
    EXCEPTION
      WHEN OTHERS THEN
        ad_sync_log.write_error($$PLSQL_UNIT ||
                            '->drop_gropus' ,
                            SQLCODE,
                            SQLERRM);
        RAISE;
    
    END drop_gropus;
  
    PROCEDURE mark_existing_groups (p_start_timestamp timestamp, p_end_timestamp timestamp, p_process_run number, p_load_id number) is
    v_number_of_existing pls_integer;
    begin
      if p_process_run is not null then
      ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->mark_existing_groups started for: '||p_start_timestamp||' and '||p_end_timestamp,
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
                username in (select username from all_users)
                and status = 1
                and REQUESTED_OPERATION = 'C' --requested create user
                and username like ad_sync_owner.ad_sync_tools.get_param_value('USERNAME_PREFIX')||'%'
                and CREATED_TIMESTAMP between p_start_timestamp and p_end_timestamp;
            v_number_of_existing := SQL%ROWCOUNT;
            commit;    
            ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->mark_existing_groups number of existing: '||v_number_of_existing,
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
                            '->mark_existing_groups number of bad prefixes: '||v_number_of_existing,
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
      end if;
    EXCEPTION
      WHEN OTHERS THEN
        ad_sync_log.write_error($$PLSQL_UNIT ||
                            '->add_groups' ,
                            SQLCODE,
                            SQLERRM);
        RAISE;
    end mark_existing_groups;

    PROCEDURE add_groups (p_start_timestamp timestamp, p_end_timestamp timestamp, p_process_run number, p_load_id number) IS
        v_stmt VARCHAR2(4000);
        v_file_name varchar2(100);
        v_file  UTL_FILE.FILE_TYPE;
    BEGIN
        if p_process_run is not null then
        ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->add_groups started for: '||p_start_timestamp||' and '||p_end_timestamp,
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
        FOR i IN (
            SELECT
                au.id, au.username, nvl(au.password,ad_sync_owner.ad_sync_tools.generate_password) as password
            FROM
                ad_sync_owner.ad_sync_users au left join all_users u on (au.username=u.username)
            WHERE
                au.status = 1
                and au.REQUESTED_OPERATION = 'C' --requested create user
                and au.username like ad_sync_owner.ad_sync_tools.get_param_value('USERNAME_PREFIX')||'%'
                and au.CREATED_TIMESTAMP between p_start_timestamp and p_end_timestamp
                and u.username is null
                )
         LOOP
            v_stmt := 'create user ' || i.username 
                   || ' identified by '|| i.password
                   || ' DEFAULT TABLESPACE '||ad_sync_owner.ad_sync_tools.get_param_value('USER_TABLESPACE')
                   || ' TEMPORARY TABLESPACE ' ||ad_sync_owner.ad_sync_tools.get_param_value('USER_TEMP_TABLESPACE')
                   || ' account '||ad_sync_owner.ad_sync_tools.get_param_value('USER_ACCOUNT_LOCK_STATUS')
                   --|| ' password expire'
                   ;
            dbms_output.put_line(v_stmt||';');
            
            ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->add_groups create user: '|| i.username,
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
                            '->add_groups finished',
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
         end if;                   
    EXCEPTION
      WHEN OTHERS THEN
        ad_sync_log.write_error($$PLSQL_UNIT ||
                            '->add_groups' ,
                            SQLCODE,
                            SQLERRM);
        RAISE;
    
    END add_groups;

END ad_sync_process_groups;
/
