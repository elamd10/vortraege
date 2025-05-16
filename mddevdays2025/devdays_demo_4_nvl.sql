create table demo_func as
select row_number() over (order by object_name) as id,
       object_type, object_name
  from (select object_type, object_name, 
               rank() over (partition by object_type order by object_name) as rnk
          from user_objects)
 where rnk <= 2;

select * from demo_func;

create or replace function verbrenne_zeit (sek integer) return varchar2
is
begin
  dbms_session.sleep(sek);
  return to_char(sek);
end;
/







select * from demo_func where nvl(object_name, verbrenne_zeit(id)) != 'XYZ' and id < 5;

--> verbrenne Zeit wird ausgeführt, obwohl object_name immer gefüllt ist!!!








select * from demo_func where coalesce(object_name, verbrenne_zeit(id)) != 'XYZ' and id < 5;

--> Ergebniss ist wesentlich schneller!!!