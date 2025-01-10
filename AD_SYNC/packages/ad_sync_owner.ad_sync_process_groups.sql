prompt CREATE OR REPLACE PACKAGE  ad_sync_owner.ad_sync_process_groups

CREATE OR REPLACE PACKAGE  ad_sync_owner.ad_sync_process_groups AUTHID current_user AS
    PROCEDURE add_groups (p_start_timestamp timestamp, p_end_timestamp timestamp, p_process_run number, p_load_id number);
    PROCEDURE drop_gropus_not_exist_in_load (p_start_timestamp timestamp, p_end_timestamp timestamp, p_process_run number, p_load_id number);
    PROCEDURE drop_gropus_on_demand (p_start_timestamp timestamp, p_end_timestamp timestamp, p_process_run number, p_load_id number);
    PROCEDURE mark_existing_groups (p_start_timestamp timestamp, p_end_timestamp timestamp, p_process_run number, p_load_id number);
END ad_sync_process_groups;
/

prompt CREATE OR REPLACE PACKAGE BODY ad_sync_owner.ad_sync_process_groups
CREATE OR REPLACE PACKAGE BODY ad_sync_owner.ad_sync_process_groups AS

PROCEDURE drop_gropus_not_exist_in_load (p_start_timestamp timestamp, p_end_timestamp timestamp, p_process_run number, p_load_id number) as
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
                g.GROUPname
            FROM
                ad_sync_owner.ad_sync_GROUPs ag right join ad_sync_owner.AD_SYNC_MANAGED_GROUPS g on (ag.GROUPname=g.GROUPname)
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
    
    END drop_gropus_not_exist_in_load;


PROCEDURE drop_gropus_on_demand (p_start_timestamp timestamp, p_end_timestamp timestamp, p_process_run number, p_load_id number) as
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
                ag.id, ag.GROUPname
            FROM
                ad_sync_owner.ad_sync_GROUPs ag join ad_sync_owner.AD_SYNC_MANAGED_GROUPS g on (ag.GROUPname=g.GROUPname)
            WHERE
                ag.status = 1
                and ag.REQUESTED_OPERATION = 'D' --requested drop GROUP
                and ag.GROUPname like ad_sync_owner.ad_sync_tools.get_param_value('GROUPNAME_PREFIX')||'%'
                and ag.CREATED_TIMESTAMP between p_start_timestamp and p_end_timestamp
                )
         LOOP
            v_stmt := 'drop role ' || i.GROUPname 
                   --|| ' cascade'
                   ;
            dbms_output.put_line(v_stmt||';');
            
            ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->drop_gropus group dropped: '|| i.GROUPname,
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
            execute immediate v_stmt;
            UPDATE ad_sync_owner.ad_sync_GROUPs
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
    
    END drop_gropus_on_demand;
  
    PROCEDURE mark_existing_groups (p_start_timestamp timestamp, p_end_timestamp timestamp, p_process_run number, p_load_id number) is
    v_number_of_existing pls_integer;
    begin
      if p_process_run is not null then
      ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->mark_existing_groups started for: '||p_start_timestamp||' and '||p_end_timestamp,
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
      /* existing GROUPs*/
      UPDATE ad_sync_owner.AD_SYNC_GROUPS
            SET
                status = 38 -- GROUP exists in database
                , PROCESS_TIMESTAMP = current_timestamp
                , load_id=p_load_id
            WHERE
                groupname in (select groupname from ad_sync_owner.AD_SYNC_MANAGED_GROUPS)
                and status = 1
                and REQUESTED_OPERATION = 'C' --requested create GROUP
                and groupname like ad_sync_owner.ad_sync_tools.get_param_value('GROUPNAME_PREFIX')||'%'
                and CREATED_TIMESTAMP between p_start_timestamp and p_end_timestamp;
            v_number_of_existing := SQL%ROWCOUNT;
            commit;    
            ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->mark_existing_groups number of existing: '||v_number_of_existing,
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
        /* bad prefix*/
      UPDATE ad_sync_owner.AD_SYNC_GROUPS
            SET
                status = 37 -- invalid GROUP prefix
                , PROCESS_TIMESTAMP = current_timestamp
                , load_id=p_load_id
            WHERE
                groupname not like ad_sync_owner.ad_sync_tools.get_param_value('GROUPNAME_PREFIX')||'%'
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
                ag.id, ag.groupname
            FROM
                ad_sync_owner.ad_sync_GROUPs ag left join ad_sync_owner.AD_SYNC_MANAGED_GROUPS g on (ag.groupname=g.groupname)
            WHERE
                ag.status = 1
                and ag.REQUESTED_OPERATION = 'C' --requested create GROUP
                and ag.groupname like ad_sync_owner.ad_sync_tools.get_param_value('GROUPNAME_PREFIX')||'%'
                and ag.CREATED_TIMESTAMP between p_start_timestamp and p_end_timestamp
                and g.groupname is null
                )
         LOOP
            v_stmt := 'create role ' || i.groupname
                   ;
            dbms_output.put_line(v_stmt||';');
            
            ad_sync_log.write_info($$PLSQL_UNIT || 
                            '->add_groups create group: '|| i.groupname,
                            SQLCODE,
                            SQLERRM,
                            p_process_run);
            execute immediate v_stmt;
            UPDATE ad_sync_owner.AD_SYNC_GROUPS
            SET
                status = 39 -- GROUP created
                , PROCESS_TIMESTAMP = current_timestamp
                , load_id=p_load_id
            WHERE
                id = i.id;

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
