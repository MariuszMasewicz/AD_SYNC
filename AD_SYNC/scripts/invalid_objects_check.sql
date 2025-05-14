prompt Checking invalid object

DECLARE
  V_ERROR_COUNT NUMBER;
BEGIN
  SELECT COUNT(*) AS ERROR_COUNT
    INTO V_ERROR_COUNT
    FROM DBA_OBJECTS
   WHERE OWNER IN ( 'AD_SYNC_OWNER' )
     AND STATUS <> 'VALID';
  IF V_ERROR_COUNT > 0 THEN
    DBMS_OUTPUT.PUT_LINE('There are '
                         || V_ERROR_COUNT
                         || ' invalid objects:');
    FOR C_INVALID IN (
      SELECT OWNER
            ,OBJECT_NAME
            ,OBJECT_TYPE
            ,STATUS
        FROM DBA_OBJECTS
       WHERE OWNER IN ( 'AD_SYNC_OWNER' )
         AND STATUS <> 'VALID'
    ) LOOP
      DBMS_OUTPUT.PUT_LINE(C_INVALID.OBJECT_TYPE
                           || ': '
                           || C_INVALID.OWNER
                           || '.'
                           || C_INVALID.OBJECT_NAME
                           || ' - '
                           || C_INVALID.STATUS);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('');
    RAISE_APPLICATION_ERROR(
      -20001
     ,'FAIL - There are '
      || V_ERROR_COUNT
      || ' invalid objects'
    );
  ELSE
    DBMS_OUTPUT.PUT_LINE('OK - There are NO invalid objects');
  END IF;
END;
/