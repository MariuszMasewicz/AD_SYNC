prompt CREATE OR REPLACE PACKAGE  ad_sync_owner.ad_sync_process_group_members

CREATE OR REPLACE PACKAGE  ad_sync_owner.ad_sync_process_group_members AUTHID current_user AS
    PROCEDURE add_group_members (p_start_timestamp timestamp, p_end_timestamp timestamp, p_process_run number, p_load_id number);
    --PROCEDURE drop_group_members_not_exist_in_load (p_start_timestamp timestamp, p_end_timestamp timestamp, p_process_run number, p_load_id number);
    PROCEDURE drop_group_member_on_demand (p_start_timestamp timestamp, p_end_timestamp timestamp, p_process_run number, p_load_id number);
    PROCEDURE mark_existing_group_members (p_start_timestamp timestamp, p_end_timestamp timestamp, p_process_run number, p_load_id number);
END ad_sync_process_group_members;
/

prompt CREATE OR REPLACE PACKAGE BODY ad_sync_owner.ad_sync_process_group_members
CREATE OR REPLACE PACKAGE BODY ad_sync_owner.ad_sync_process_group_members AS

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

PROCEDURE drop_group_member_on_demand (p_start_timestamp timestamp, p_end_timestamp timestamp, p_process_run number, p_load_id number) as
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
                ag.id, ag.GROUPname, ag.member
            FROM
                ad_sync_owner.ad_sync_group_members ag join ad_sync_owner.AD_SYNC_MANAGED_group_members g on (ag.GROUPname=g.GROUPname and ag.member=g.GRANTEE)
            WHERE
                ag.status = 1
                and ag.REQUESTED_OPERATION = 'D' --requested drop GROUP
                and ag.GROUPname like ad_sync_owner.ad_sync_tools.get_param_value('GROUPNAME_PREFIX')||'%'
                and ag.member like ad_sync_owner.ad_sync_tools.get_param_value('USERNAME_PREFIX')||'%'
                and ag.CREATED_TIMESTAMP between p_start_timestamp and p_end_timestamp
                )
         LOOP
            v_stmt := 'revoke ' || i.GROUPname || ' from ' || i.member
                   --|| ' cascade'
                   ;
            dbms_output.put_line(v_stmt||';');
            
            ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->drop_gropus group dropped: '|| i.GROUPname,
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
            execute immediate v_stmt;
            UPDATE ad_sync_owner.ad_sync_group_members
            SET
                status = 32 -- GROUP dropped
                , PROCESS_TIMESTAMP = current_timestamp
                , load_id=p_load_id
            WHERE
                id = i.id;

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
    
    END drop_group_member_on_demand;
  
    PROCEDURE mark_existing_group_members (p_start_timestamp timestamp, p_end_timestamp timestamp, p_process_run number, p_load_id number) is
    v_number_of_existing pls_integer;
    begin
      if p_process_run is not null then
      ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->mark_existing_group_members started for: '||p_start_timestamp||' and '||p_end_timestamp,
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
      -- existing group_members
      UPDATE ad_sync_owner.AD_SYNC_group_members
            SET
                status = 48 -- GROUP exists in database
                , PROCESS_TIMESTAMP = current_timestamp
                , load_id=p_load_id
            WHERE
                (groupname,member) in (select groupname,GRANTEE from ad_sync_owner.AD_SYNC_MANAGED_group_members)
                and status = 1
                and REQUESTED_OPERATION = 'C' --requested create GROUP
                and groupname like ad_sync_owner.ad_sync_tools.get_param_value('GROUPNAME_PREFIX')||'%'
                and member  like ad_sync_owner.ad_sync_tools.get_param_value('USERNAME_PREFIX')||'%'
                and CREATED_TIMESTAMP between p_start_timestamp and p_end_timestamp;
            v_number_of_existing := SQL%ROWCOUNT;
            commit;    
            ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->mark_existing_group_members number of existing: '||v_number_of_existing,
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
        -- bad prefix
      UPDATE ad_sync_owner.AD_SYNC_group_members
            SET
                status = 47 -- invalid GROUP prefix
                , PROCESS_TIMESTAMP = current_timestamp
                , load_id=p_load_id
            WHERE
                (groupname not like ad_sync_owner.ad_sync_tools.get_param_value('GROUPNAME_PREFIX')||'%'
                or member  not like ad_sync_owner.ad_sync_tools.get_param_value('USERNAME_PREFIX')||'%' )
                and status = 1
                and CREATED_TIMESTAMP between p_start_timestamp and p_end_timestamp;
            v_number_of_existing := SQL%ROWCOUNT;
            commit;    
            ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->mark_existing_group_members number of bad prefixes: '||v_number_of_existing,
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
      end if;
    EXCEPTION
      WHEN OTHERS THEN
        ad_sync_log.write_error($$PLSQL_UNIT ||
                            '->add_group_members' ,
                            SQLCODE,
                            SQLERRM);
        RAISE;
    end mark_existing_group_members;

    PROCEDURE add_group_members (p_start_timestamp timestamp, p_end_timestamp timestamp, p_process_run number, p_load_id number) IS
        v_stmt VARCHAR2(4000);
        --v_file_name varchar2(100);
        --v_file  UTL_FILE.FILE_TYPE;
    BEGIN
        if p_process_run is not null then
        ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->add_group_members started for: '||p_start_timestamp||' and '||p_end_timestamp,
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
        FOR i IN (
            SELECT
                ag.id,ag.groupname, ag.member
            FROM
                ad_sync_owner.ad_sync_group_members ag 
            WHERE
                ag.status = 1
                and ag.REQUESTED_OPERATION = 'C' --requested create GROUP
                and ag.groupname like ad_sync_owner.ad_sync_tools.get_param_value('GROUPNAME_PREFIX')||'%'
                and ag.member like ad_sync_owner.ad_sync_tools.get_param_value('USERNAME_PREFIX')||'%'
                and ag.CREATED_TIMESTAMP between p_start_timestamp and p_end_timestamp
                and ag.groupname is not null
                and ag.member is not null
                )
         LOOP
            v_stmt :=  'GRANT '||i.groupname||' to '||i.member
                   ;
            dbms_output.put_line(v_stmt||';');
            
            ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->add_group_members add member to group: '|| i.member||':'||i.groupname,
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
            execute immediate v_stmt;
            UPDATE ad_sync_owner.AD_SYNC_group_members
            SET
                status = 49 -- GROUP_member created
                , PROCESS_TIMESTAMP = current_timestamp
                , load_id=p_load_id
            WHERE
                id = i.id;

        END LOOP;

        COMMIT;
        ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->add_group_members finished',
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
         end if;                   
    EXCEPTION
      WHEN OTHERS THEN
        ad_sync_log.write_error($$PLSQL_UNIT ||
                            '->add_group_members' ,
                            SQLCODE,
                            SQLERRM);
        RAISE;
    
    END add_group_members;

END ad_sync_process_group_members;
/
