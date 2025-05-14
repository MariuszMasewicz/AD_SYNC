   set serveroutput on
DECLARE
  V_STMT VARCHAR2(4000);
BEGIN
  FOR I IN (
    SELECT *
      FROM DBA_ROLES
     WHERE ROLE LIKE '&groupname_prefix.' || '%'
  ) LOOP
    V_STMT := 'drop role ' || I.ROLE;
    DBMS_OUTPUT.PUT_LINE(V_STMT);
    EXECUTE IMMEDIATE V_STMT;
  END LOOP;
END;
/