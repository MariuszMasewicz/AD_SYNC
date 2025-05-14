   set serveroutput on
DECLARE
  V_STMT VARCHAR2(4000);
BEGIN
  FOR I IN (
    SELECT *
      FROM ALL_USERS
     WHERE USERNAME LIKE '&username_prefix.' || '%'
  ) LOOP
    V_STMT := 'drop user '
              || I.USERNAME
              || ' cascade';
    DBMS_OUTPUT.PUT_LINE(V_STMT);
    EXECUTE IMMEDIATE V_STMT;
  END LOOP;
END;
/