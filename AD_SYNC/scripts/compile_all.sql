set serveroutput on;

prompt compile_objects.sql

DECLARE
BEGIN
  FOR IDX IN 1 .. 5 LOOP
    DBMS_OUTPUT.PUT_LINE(IDX);
    FOR I IN (
      SELECT
        OBJECT_NAME,
        OBJECT_TYPE,
        OWNER
      FROM
        ALL_OBJECTS
      WHERE
        OWNER IN ('AD_SYNC_OWNER')
        AND OBJECT_TYPE IN ('PACKAGE', 'PACKAGE BODY', 'VIEW', 'TRIGGER', 'MATERIALIZED VIEW', 'SYNONYM')
        AND STATUS = 'INVALID'
      ORDER BY
        1,
        2
    ) LOOP
      BEGIN
        DBMS_OUTPUT.PUT_LINE(I.OBJECT_TYPE
                             || ': '
                             || I.OWNER
                             || '.'
                             || I.OBJECT_NAME);
        IF I.OBJECT_TYPE <> 'PACKAGE BODY' THEN
          EXECUTE IMMEDIATE 'ALTER '
                            || I.OBJECT_TYPE
                            || ' '
                            || I.OWNER
                            || '.'
                            || I.OBJECT_NAME
                            || ' COMPILE';
        ELSE
          EXECUTE IMMEDIATE 'ALTER PACKAGE '
                            || I.OWNER
                            || '.'
                            || I.OBJECT_NAME
                            || ' COMPILE BODY';
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('compilation error-'
                               || I.OBJECT_NAME);
      END;
    END LOOP;
  END LOOP;
END;
/