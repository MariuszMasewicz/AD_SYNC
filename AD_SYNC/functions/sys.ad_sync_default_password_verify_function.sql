create or replace NONEDITIONABLE function sys.ad_sync_default_password_verify_function 
 ( username     varchar2,
   password     varchar2,
   old_password varchar2)
 return boolean IS
   differ  integer;
   lang    varchar2(512);
   message varchar2(512);
   ret     number;

begin
   -- Get the cur context lang and use utl_lms for messages- Bug 22730089
   lang := sys_context('userenv','lang');
   lang := substr(lang,1,instr(lang,'_')-1);

   if not ora_complexity_check(password, chars => 12, uppercase => 1, lowercase => 1,
                           digit => 1, special => 1) then
      return(false);
   end if;

   -- Check if the password differs from the previous password by at least
   -- 8 characters
   if old_password is not null then
      differ := ora_string_distance(old_password, password);
      if differ < 8 then
         ret := utl_lms.get_message(28211, 'RDBMS', 'ORA', lang, message);
         raise_application_error(-20000, utl_lms.format_message(message, 'eight'));
      end if;
   end if;

   return(true);
end ad_sync_default_password_verify_function;