set serveroutput on
declare 
v_stmt varchar2(4000);
begin
for i in (select * from dba_roles where role like '&groupname_prefix.'||'%')
loop
  v_stmt := 'drop role '||i.role;
  dbms_output.put_line(v_stmt);
  execute immediate v_stmt;
end loop;
end;
/