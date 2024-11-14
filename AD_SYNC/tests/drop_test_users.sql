set serveroutput on
declare 
v_stmt varchar2(4000);
begin
for i in (select * from all_users where username like '&username_prefix.'||'%')
loop
  v_stmt := 'drop user '||i.username||' cascade';
  dbms_output.put_line(v_stmt);
  execute immediate v_stmt;
end loop;
end;
/