prompt CREATE OR REPLACE VIEW ad_sync_owner.AD_SYNC_PROCESSING_STATUS_USERS

CREATE OR REPLACE VIEW ad_sync_owner.AD_SYNC_PROCESSING_STATUS_USERS
as
SELECT
    username,
    requested_operation,
    password_file,
    status,
    process_timestamp
FROM
    ad_sync_owner.ad_sync_users u
where password_file is not null
and process_timestamp = (select max(process_timestamp) from ad_sync_owner.ad_sync_users u1 where u.username=u1.username and password_file is not null);;
