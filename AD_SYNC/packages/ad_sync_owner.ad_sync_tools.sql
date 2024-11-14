prompt CREATE OR REPLACE PACKAGE ad_sync_owner.ad_sync_tools

CREATE OR REPLACE PACKAGE ad_sync_owner.ad_sync_tools
 IS
  FUNCTION get_param_value(p_param_name IN ad_sync_owner.AD_SYNC_PARAMETERS.parameter_name%TYPE)
    RETURN ad_sync_owner.AD_SYNC_PARAMETERS.parameter_value%TYPE result_cache;
  FUNCTION generate_password
    RETURN VARCHAR2;  
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

FUNCTION generate_password
    RETURN VARCHAR2 is
    begin
      return replace(dbms_random.string('a', 14), ' ', 'x');
    end generate_password;

END ad_sync_tools;
/
