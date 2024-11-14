prompt CREATE OR REPLACE PACKAGE ad_sync_owner.ad_sync_tools

CREATE OR REPLACE PACKAGE ad_sync_owner.ad_sync_tools
 IS
  FUNCTION get_param_value(p_param_name IN ad_sync_owner.AD_SYNC_PARAMETERS.parameter_name%TYPE)
    RETURN ad_sync_owner.AD_SYNC_PARAMETERS.parameter_value%TYPE result_cache;

function generate_password(
  no_of_digits             in number default 2,
  no_of_special_characters in number default 2,
  no_of_lower              in number default 5,
  no_of_upper              in number default 5
) return varchar2;

  /*FUNCTION generate_password
    RETURN VARCHAR2;  */
END ad_sync_tools;
/

prompt CREATE OR REPLACE PACKAGE BODY ad_sync_owner.ad_sync_tools
CREATE OR REPLACE PACKAGE BODY ad_sync_owner.ad_sync_tools IS
  FUNCTION get_param_value( 
                           p_param_name IN ad_sync_owner.AD_SYNC_PARAMETERS.parameter_name%TYPE)
    RETURN ad_sync_owner.AD_SYNC_PARAMETERS.parameter_value%TYPE result_cache IS
    v_ret ad_sync_owner.AD_SYNC_PARAMETERS.parameter_value%TYPE;
  BEGIN
  
    BEGIN
      SELECT parameter_value
        INTO v_ret
        FROM ad_sync_owner.AD_SYNC_PARAMETERS p
       WHERE p.parameter_name = p_param_name;
    
    EXCEPTION
      WHEN OTHERS THEN
        v_ret := 'null';
        ad_sync_log.write_error($$PLSQL_UNIT ||
                            '->get_param_value: p_param_name: ' ||
                            p_param_name,
                            SQLCODE,
                            SQLERRM);
        RAISE;
    END;
    RETURN v_ret;
  
  END get_param_value;

/*password, chars => 12, uppercase => 1, lowercase => 1,
                           digit => 1, special => 1 */
function generate_password(
  no_of_digits             in number default 2,
  no_of_special_characters in number default 2,
  no_of_lower              in number default 5,
  no_of_upper              in number default 5
) return varchar2
AS
  password VARCHAR2(4000);
  digits   CONSTANT VARCHAR2(10) := '0123456789';
  lower    CONSTANT VARCHAR2(26) := 'abcdefghijklmnopqrstuvwxyz';
  upper    CONSTANT VARCHAR2(26) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  special  CONSTANT VARCHAR2(128) := '!"£$%^&*()-_=+{}[]<>,.\|/?;:''@#';
  --special  CONSTANT VARCHAR2(32) := '!$%^&*()-_=+{}[]<>,.\|/?;:#';
BEGIN
  SELECT LISTAGG(letter, NULL) WITHIN GROUP (ORDER BY DBMS_RANDOM.VALUE)
  INTO   password
  FROM   (
    SELECT SUBSTR(
             digits,
             FLOOR(DBMS_RANDOM.VALUE(1, LENGTH(digits) + 1)),
             1
           ) AS letter
    FROM   DUAL
    CONNECT BY LEVEL <= no_of_digits
    UNION ALL
    SELECT SUBSTR(
             lower,
             FLOOR(DBMS_RANDOM.VALUE(1, LENGTH(lower) + 1)),
             1
           ) AS letter
    FROM   DUAL
    CONNECT BY LEVEL <= no_of_lower
    UNION ALL
    SELECT SUBSTR(
             upper,
             FLOOR(DBMS_RANDOM.VALUE(1, LENGTH(upper) + 1)),
             1
           ) AS letter
    FROM   DUAL
    CONNECT BY LEVEL <= no_of_upper
    UNION ALL
    SELECT SUBSTR(
             special,
             FLOOR(DBMS_RANDOM.VALUE(1, LENGTH(special) + 1)),
             1
           ) AS letter
    FROM   DUAL
    CONNECT BY LEVEL <= no_of_special_characters
  );
  
  RETURN password;
END generate_password;

/*FUNCTION generate_password
    RETURN VARCHAR2 is
    begin
      return replace(dbms_random.string('a', 14), ' ', 'x');
    end generate_password;*/

END ad_sync_tools;
/
