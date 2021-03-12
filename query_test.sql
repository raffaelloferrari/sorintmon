-- Query test:

set serveroutput on 
set timing on
declare
x number :=0 ;
y number :=0 ;
r number :=0 ;
 
begin
while  y < 10000 loop
   y := y+1;
   while  x < 10000  loop
   x := x+1;
   r := x*y;
   end loop;
   /*sorintmon|0.1|*/
x := 0;
end loop;
dbms_output.put_line('result = '||r);
end;
/