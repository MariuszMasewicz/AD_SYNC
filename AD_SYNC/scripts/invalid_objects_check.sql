prompt Checking invalid object
DECLARE
  v_error_count NUMBER;
BEGIN
  SELECT COUNT(*) AS error_count
    INTO v_error_count
    FROM dba_objects
   WHERE owner IN ('AD_SYNC_OWNER')
     AND status <> 'VALID';
  IF v_error_count > 0 THEN
    dbms_output.put_line('There are ' || v_error_count ||
                         ' invalid objects:');
  
    FOR c_invalid IN (SELECT owner, object_name, object_type, status
                        FROM dba_objects
                       WHERE owner IN
                             ('AD_SYNC_OWNER')
                         AND status <> 'VALID') LOOP
      dbms_output.put_line(c_invalid.object_type || ': ' ||
                           c_invalid.owner || '.' || c_invalid.object_name ||
                           ' - ' || c_invalid.status);
    END LOOP;
    dbms_output.put_line('');
    raise_application_error(-20001,
                            'FAIL - There are ' || v_error_count ||
                            ' invalid objects');
  ELSE
    dbms_output.put_line('OK - There are NO invalid objects');
  END IF;
END;
/
