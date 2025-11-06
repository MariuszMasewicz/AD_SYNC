prompt create or replace directory ad_sync_passwords as '/tmp/pass/'
--version: 0.0.001
CREATE OR REPLACE DIRECTORY &USER_PASS_DIRECTORY_NAME. AS '&user_pass_directory_location.';

GRANT WRITE ON DIRECTORY &USER_PASS_DIRECTORY_NAME. TO AD_SYNC_OWNER;