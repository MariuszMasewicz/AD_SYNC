prompt create or replace directory ad_sync_passwords as '/tmp/pass/
create or replace directory &user_pass_directory_name. as '&user_pass_directory_location.';

grant WRITE on directory &user_pass_directory_name. to AD_SYNC_OWNER ;