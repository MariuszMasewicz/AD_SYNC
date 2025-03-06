prompt CREATE TABLE ad_sync_owner.AD_SYNC_GROUPS_PERMISSION

CREATE TABLE ad_sync_owner.AD_SYNC_GROUP_PERMISSION
(
  ID NUMBER DEFAULT ad_sync_owner.AD_SYNC_GROUPS_seq.nextval PRIMARY KEY
, GROUPNAME VARCHAR2(1000) NOT NULL 
,SCHEMA                   VARCHAR2(128) 
,OBJECT_NAME             VARCHAR2(128)
,PERMISSION     Varchar2(256)
	created_timestamp   TIMESTAMP(6) DEFAULT on null systimestamp NOT NULL,
  created_user        VARCHAR2(255 CHAR) DEFAULT on null user NOT NULL,
  updated_timestamp   TIMESTAMP(6),
  updated_user        VARCHAR2(255 CHAR)
);


