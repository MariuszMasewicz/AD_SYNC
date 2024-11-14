prompt CREATE TABLE ad_sync_owner.AD_SYNC_LOG_TABLE 

CREATE TABLE ad_sync_owner.AD_SYNC_LOG_TABLE 
    ( 
     LOG_ID            INTEGER  NOT NULL primary key, 
     PROCESS_RUN_ID    INTEGER,  
     log_TYPE          INTEGER REFERENCES ad_sync_owner.AD_SYNC_LOG_TABLE_TYPE(ID), 
     log_SRC           VARCHAR2 (4000 CHAR) , 
     log_CODE          INTEGER , 
     log_MSG           VARCHAR2 (4000 CHAR) NOT NULL , 
     log_TIMESTAMP     TIMESTAMP with time zone, 
     CREATED_TIMESTAMP TIMESTAMP (6)  DEFAULT on null systimestamp  NOT NULL ENABLE,
	CREATED_USER VARCHAR2(255 CHAR) DEFAULT on null user  NOT NULL ENABLE, 
	UPDATED_TIMESTAMP TIMESTAMP (6) , 
	UPDATED_USER VARCHAR2(255 CHAR) 
    ) 
	;