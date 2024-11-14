set serveroutput on;

prompt compile_objects.sql

DECLARE
BEGIN
   FOR idx IN 1 .. 5 LOOP
    dbms_output.put_line(idx);
    FOR i IN (SELECT object_name, object_type, owner
                FROM all_objects
               WHERE owner IN ('AD_SYNC_OWNER')
                 AND object_type IN ('PACKAGE', 'PACKAGE BODY', 'VIEW', 'TRIGGER', 'MATERIALIZED VIEW', 'SYNONYM')
                 AND status = 'INVALID'
               ORDER BY 1, 2) LOOP
      BEGIN
        dbms_output.put_line(i.object_type || ': ' || i.owner || '.' ||
                             i.object_name);
        IF i.object_type <> 'PACKAGE BODY' THEN
          EXECUTE IMMEDIATE 'ALTER ' || i.object_type || ' ' || i.owner || '.' ||
                            i.object_name || ' COMPILE';
        ELSE
          EXECUTE IMMEDIATE 'ALTER PACKAGE ' || i.owner || '.' ||
                            i.object_name || ' COMPILE BODY';
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line('compilation error-' || i.object_name);
      END;
    END LOOP;
  END LOOP; 
END;
/
