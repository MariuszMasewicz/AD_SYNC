prompt CREATE OR REPLACE PACKAGE ad_sync_owner.ad_sync_tools

CREATE OR REPLACE PACKAGE AD_SYNC_OWNER.AD_SYNC_TOOLS IS
--version: 0.0.001
  FUNCTION GET_PARAM_VALUE (
    P_PARAM_NAME IN AD_SYNC_OWNER.AD_SYNC_PARAMETERS.PARAMETER_NAME%TYPE
  ) RETURN AD_SYNC_OWNER.AD_SYNC_PARAMETERS.PARAMETER_VALUE%TYPE
    RESULT_CACHE;

  FUNCTION GENERATE_PASSWORD (
    NO_OF_DIGITS             IN NUMBER DEFAULT 2
   ,NO_OF_SPECIAL_CHARACTERS IN NUMBER DEFAULT 2
   ,NO_OF_LOWER              IN NUMBER DEFAULT 5
   ,NO_OF_UPPER              IN NUMBER DEFAULT 5
  ) RETURN VARCHAR2;
 /*FUNCTION generate_password
    RETURN VARCHAR2;  */
END AD_SYNC_TOOLS;
/

prompt CREATE OR REPLACE PACKAGE BODY ad_sync_owner.ad_sync_tools

CREATE OR REPLACE PACKAGE BODY AD_SYNC_OWNER.AD_SYNC_TOOLS IS
--version: 0.0.001
  FUNCTION GET_PARAM_VALUE (
    P_PARAM_NAME IN AD_SYNC_OWNER.AD_SYNC_PARAMETERS.PARAMETER_NAME%TYPE
  ) RETURN AD_SYNC_OWNER.AD_SYNC_PARAMETERS.PARAMETER_VALUE%TYPE
    RESULT_CACHE
  IS
    V_RET AD_SYNC_OWNER.AD_SYNC_PARAMETERS.PARAMETER_VALUE%TYPE;
  BEGIN
    BEGIN
      SELECT PARAMETER_VALUE
        INTO V_RET
        FROM AD_SYNC_OWNER.AD_SYNC_PARAMETERS P
       WHERE P.PARAMETER_NAME = P_PARAM_NAME;
    EXCEPTION
      WHEN OTHERS THEN
        V_RET := 'null';
        AD_SYNC_LOG.WRITE_ERROR(
          $$PLSQL_UNIT
          || '->get_param_value: p_param_name: '
          || P_PARAM_NAME
         ,SQLCODE
         ,SQLERRM
        );
        RAISE;
    END;

    RETURN V_RET;
  END GET_PARAM_VALUE;
 /*password, chars => 12, uppercase => 1, lowercase => 1,
                           digit => 1, special => 1 */

  FUNCTION GENERATE_PASSWORD (
    NO_OF_DIGITS             IN NUMBER DEFAULT 2
   ,NO_OF_SPECIAL_CHARACTERS IN NUMBER DEFAULT 2
   ,NO_OF_LOWER              IN NUMBER DEFAULT 5
   ,NO_OF_UPPER              IN NUMBER DEFAULT 5
  ) RETURN VARCHAR2 AS
    PASSWORD VARCHAR2(4000);
    DIGITS   CONSTANT VARCHAR2(10) := '0123456789';
    LOWER    CONSTANT VARCHAR2(26) := 'abcdefghijklmnopqrstuvwxyz';
    UPPER    CONSTANT VARCHAR2(26) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    --SPECIAL  CONSTANT VARCHAR2(128) := '!"£$%^&*()-_=+{}[]<>,.\|/?;:''@#';
    SPECIAL  CONSTANT VARCHAR2(128)   := '!$%^&*()-_=+{}[]<>,.\|/?:#';
     --special  CONSTANT VARCHAR2(32) := '!$%^&*()-_=+{}[]<>,.\|/?;:#';
  BEGIN
    SELECT
      LISTAGG(LETTER
              ,NULL) WITHIN GROUP(
       ORDER BY DBMS_RANDOM.VALUE)
      INTO PASSWORD
      FROM (
      SELECT SUBSTR(
        DIGITS
       ,FLOOR(DBMS_RANDOM.VALUE(
          1
         ,LENGTH(DIGITS) + 1
        ))
       ,1
      ) AS LETTER
        FROM DUAL
      CONNECT BY
        LEVEL <= NO_OF_DIGITS
      UNION ALL
      SELECT SUBSTR(
        LOWER
       ,FLOOR(DBMS_RANDOM.VALUE(
          1
         ,LENGTH(LOWER) + 1
        ))
       ,1
      ) AS LETTER
        FROM DUAL
      CONNECT BY
        LEVEL <= NO_OF_LOWER
      UNION ALL
      SELECT SUBSTR(
        UPPER
       ,FLOOR(DBMS_RANDOM.VALUE(
          1
         ,LENGTH(UPPER) + 1
        ))
       ,1
      ) AS LETTER
        FROM DUAL
      CONNECT BY
        LEVEL <= NO_OF_UPPER
      UNION ALL
      SELECT SUBSTR(
        SPECIAL
       ,FLOOR(DBMS_RANDOM.VALUE(
          1
         ,LENGTH(SPECIAL) + 1
        ))
       ,1
      ) AS LETTER
        FROM DUAL
      CONNECT BY
        LEVEL <= NO_OF_SPECIAL_CHARACTERS
    );
    RETURN PASSWORD;
  END GENERATE_PASSWORD;
 /*FUNCTION generate_password
    RETURN VARCHAR2 is
    begin
      return replace(dbms_random.string('a', 14), ' ', 'x');
    end generate_password;*/
END AD_SYNC_TOOLS;
/