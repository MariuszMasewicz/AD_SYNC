prompt CREATE TABLE ad_sync_owner.AD_SYNC_LOG_TABLE_TYPE 

CREATE TABLE ad_sync_owner.AD_SYNC_LOG_TABLE_TYPE 
    ( 
     ID            INTEGER  NOT NULL primary key, 
	 DESCRIPTION   VARCHAR2 (100 CHAR),
  created_timestamp   TIMESTAMP(6) DEFAULT on null systimestamp NOT NULL,
  created_user        VARCHAR2(255 CHAR) DEFAULT on null user NOT NULL,
  updated_timestamp   TIMESTAMP(6),
  updated_user        VARCHAR2(255 CHAR)
    );

PROMPT LOADING ad_sync_owner.AD_SYNC_LOG_TABLE_TYPE
Insert into ad_sync_owner.AD_SYNC_LOG_TABLE_TYPE (ID,DESCRIPTION) values (0,'ERROR');
Insert into ad_sync_owner.AD_SYNC_LOG_TABLE_TYPE (ID,DESCRIPTION) values (1,'WARRNING');
Insert into ad_sync_owner.AD_SYNC_LOG_TABLE_TYPE (ID,DESCRIPTION) values (2,'INFO');

commit;
PROMPT ad_sync_owner.AD_SYNC_LOG_TABLE_TYPE - 3 rows created.