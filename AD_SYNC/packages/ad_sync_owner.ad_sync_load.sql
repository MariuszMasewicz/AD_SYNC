prompt CREATE OR REPLACE PACKAGE ad_sync_owner.ad_sync_load

CREATE OR REPLACE PACKAGE ad_sync_owner.ad_sync_load AS

procedure init_load (p_LOAD_TYPE char);
procedure finish_load;
procedure add_user_to_load (p_username varchar2, p_password varchar2 default null, p_REQUESTED_OPERATION char default 'C');
procedure add_group_to_load (p_groupname varchar2, p_REQUESTED_OPERATION char default 'C');
procedure add_group_member_to_load (p_groupname varchar2, p_member varchar2, p_REQUESTED_OPERATION char default 'C');

END ad_sync_load;
/

prompt CREATE OR REPLACE PACKAGE BODY ad_sync_owner.ad_sync_load

CREATE OR REPLACE PACKAGE BODY ad_sync_owner.ad_sync_load  AS
procedure init_load (p_LOAD_TYPE char) is   
begin
INSERT INTO ad_sync_owner.AD_SYNC_HISTORY (sync_status, load_id, LOAD_TYPE) values (2, ad_sync_owner.AD_SYNC_LOAD_SEQ.nextval, p_LOAD_TYPE); -- sync started
commit;
  EXCEPTION
    WHEN OTHERS THEN
      ad_sync_owner.ad_sync_log.write_error($$PLSQL_UNIT ||
                          '->init_load' ,
                          SQLCODE,
                          SQLERRM);
      ROLLBACK;
      RAISE;

end init_load;

procedure finish_load is   
begin
INSERT INTO ad_sync_owner.AD_SYNC_HISTORY (sync_status) values (3); -- sync finished
commit;
  EXCEPTION
    WHEN OTHERS THEN
      ad_sync_owner.ad_sync_log.write_error($$PLSQL_UNIT ||
                          '->finish_load' ,
                          SQLCODE,
                          SQLERRM);
      ROLLBACK;
      RAISE;
end finish_load;

procedure add_user_to_load (p_username varchar2, p_password varchar2 default null, p_REQUESTED_OPERATION char default 'C') is   
begin
INSERT INTO ad_sync_owner.ad_sync_users (username, PASSWORD, REQUESTED_OPERATION) VALUES (upper(p_username), p_PASSWORD, upper(p_REQUESTED_OPERATION));
commit;
  EXCEPTION
    WHEN OTHERS THEN
      ad_sync_owner.ad_sync_log.write_error($$PLSQL_UNIT ||
                          '->add_user_to_load: '|| p_username,
                          SQLCODE,
                          SQLERRM);
      ROLLBACK;
      RAISE;
end add_user_to_load;

procedure add_group_to_load (p_groupname varchar2, p_REQUESTED_OPERATION char default 'C') is   
begin
INSERT INTO ad_sync_owner.AD_SYNC_GROUPS (groupname) VALUES  (upper(p_groupname));
commit;
  EXCEPTION
    WHEN OTHERS THEN
      ad_sync_owner.ad_sync_log.write_error($$PLSQL_UNIT ||
                          '->add_group_to_load: '|| p_groupname,
                          SQLCODE,
                          SQLERRM);
      ROLLBACK;
      RAISE;
end add_group_to_load;

procedure add_group_member_to_load (p_groupname varchar2, p_member varchar2, p_REQUESTED_OPERATION char default 'C') is   
begin
INSERT INTO ad_sync_owner.AD_SYNC_GROUP_MEMBERS (groupname,member) VALUES (upper(p_groupname), upper(p_member));
commit;
  EXCEPTION
    WHEN OTHERS THEN
      ad_sync_owner.ad_sync_log.write_error($$PLSQL_UNIT ||
                          '->add_group_member_to_load: '|| p_groupname||':'||p_member,
                          SQLCODE,
                          SQLERRM);
      ROLLBACK;
      RAISE;
end add_group_member_to_load;

END ad_sync_load;
/