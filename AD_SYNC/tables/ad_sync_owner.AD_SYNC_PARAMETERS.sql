prompt CREATE TABLE ad_sync_owner.AD_SYNC_PARAMETERS

CREATE TABLE ad_sync_owner.AD_SYNC_PARAMETERS (
  parameter_name   VARCHAR2(100 CHAR) PRIMARY KEY,
  parameter_value   VARCHAR2(200 CHAR),
	description varchar2(4000 char),
	created_timestamp   TIMESTAMP(6) DEFAULT on null systimestamp NOT NULL,
  created_user        VARCHAR2(255 CHAR) DEFAULT on null user NOT NULL,
  updated_timestamp   TIMESTAMP(6),
  updated_user        VARCHAR2(255 CHAR)
)
ORGANIZATION INDEX 
NOLOGGING 
INCLUDING parameter_value
OVERFLOW 
STORAGE 
( 
  BUFFER_POOL KEEP 
)
;

insert into ad_sync_owner.AD_SYNC_PARAMETERS (parameter_name, parameter_value, description) values ('LOG_WARNING','1','');
insert into ad_sync_owner.AD_SYNC_PARAMETERS (parameter_name, parameter_value, description) values ('LOG_INFO','1','');
insert into ad_sync_owner.AD_SYNC_PARAMETERS (parameter_name, parameter_value, description) values ('STORE_USER_PASSWORD_IN_FILE','1','1 means yes');
insert into ad_sync_owner.AD_SYNC_PARAMETERS (parameter_name, parameter_value, description) values ('STORE_USER_PASSWORD_IN_FILE_DIRECTORY','&user_pass_directory_name.','directory object name');
insert into ad_sync_owner.AD_SYNC_PARAMETERS (parameter_name, parameter_value, description) values ('STORE_USER_PASSWORD_IN_TABLE','1','1 means yes');
insert into ad_sync_owner.AD_SYNC_PARAMETERS (parameter_name, parameter_value, description) values ('USER_ACCOUNT_LOCK_STATUS','unlock','unlock or lock');
insert into ad_sync_owner.AD_SYNC_PARAMETERS (parameter_name, parameter_value, description) values ('USER_TABLESPACE','users','');
insert into ad_sync_owner.AD_SYNC_PARAMETERS (parameter_name, parameter_value, description) values ('USER_TEMP_TABLESPACE','temp','');
insert into ad_sync_owner.AD_SYNC_PARAMETERS (parameter_name, parameter_value, description) values ('USERNAME_PREFIX','&username_prefix.','');
insert into ad_sync_owner.AD_SYNC_PARAMETERS (parameter_name, parameter_value, description) values ('GROUPNAME_PREFIX','&groupname_prefix.','');
insert into ad_sync_owner.AD_SYNC_PARAMETERS (parameter_name, parameter_value, description) values ('SYNC_USERS_LOCK_INSTEAD_OF_DROP','1','1 means yes');
insert into ad_sync_owner.AD_SYNC_PARAMETERS (parameter_name, parameter_value, description) values ('SYNC_USERS_PROCESS_DROP','1','1 means yes');
insert into ad_sync_owner.AD_SYNC_PARAMETERS (parameter_name, parameter_value, description) values ('SYNC_GROUPS_PROCESS_DROP','1','1 means yes');
insert into ad_sync_owner.AD_SYNC_PARAMETERS (parameter_name, parameter_value, description) values ('SYNC_GROUP_MEMBERS_PROCESS_DROP','1','1 means yes');

commit;