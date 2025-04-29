prompt CREATE OR REPLACE VIEW ad_sync_owner.AD_SYNC_PROCESSING_STATUS_USERS

CREATE OR REPLACE VIEW ad_sync_owner.AD_SYNC_PROCESSING_STATUS_USERS
as
SELECT
    username,
    requested_operation,
    password_file,
    status,
    status_name,
    status_description,
    process_timestamp
FROM
    ad_sync_owner.ad_sync_users u join ad_sync_owner.ad_sync_statuses s on u.status=s.id
where 1=1
--and password_file is not null
and process_timestamp = (select max(process_timestamp) from ad_sync_owner.ad_sync_users u1 where u.username=u1.username 
--and password_file is not null
);
