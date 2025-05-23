prompt CREATE TABLE ad_sync_owner.AD_SYNC_GROUPS

CREATE TABLE AD_SYNC_OWNER.AD_SYNC_GROUPS (
  ID                  NUMBER DEFAULT AD_SYNC_OWNER.AD_SYNC_GROUPS_SEQ.NEXTVAL NOT NULL
  ,GROUPNAME           VARCHAR2(1000) NOT NULL
  ,REQUESTED_OPERATION CHAR(1) DEFAULT 'C' NOT NULL
  ,STATUS              NUMBER DEFAULT 1 NOT NULL
  ,PROCESS_TIMESTAMP   TIMESTAMP
  ,LOAD_ID             NUMBER
  ,CREATED_TIMESTAMP   TIMESTAMP(6) DEFAULT ON NULL SYSTIMESTAMP NOT NULL
  ,CREATED_USER        VARCHAR2(255 CHAR) DEFAULT ON NULL USER NOT NULL
  ,UPDATED_TIMESTAMP   TIMESTAMP(6)
  ,UPDATED_USER        VARCHAR2(255 CHAR)
  ,CONSTRAINT AD_SYNC_GROUPS_PK PRIMARY KEY ( ID ) ENABLE
);

ALTER TABLE AD_SYNC_OWNER.AD_SYNC_GROUPS
  ADD CONSTRAINT AD_SYNC_GROUPS_FK1
    FOREIGN KEY ( STATUS )
      REFERENCES AD_SYNC_OWNER.AD_SYNC_STATUSES ( ID )
    ENABLE;