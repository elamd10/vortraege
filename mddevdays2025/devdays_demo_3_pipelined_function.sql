-- SYS 
        
grant execute on APEX_WEB_SERVICE to demouser;

begin
  dbms_network_acl_admin.append_host_ace(
    host       => 'ip-api.com',
    lower_port => 80,
    upper_port => 80,
    ace        => xs$ace_type(
                    privilege_list => xs$name_list('HTTP'),
                    principal_name => 'APEX_240200',
                    principal_type => xs_acl.ptype_db
                  )
  );
end;
/        



-- Demouser
-- Test Webservice 

select apex_web_service.make_rest_request(p_url => 'ip-api.com/json/148.164.48.97', p_http_method => 'GET') from dual;





-- Function erstellen 

create or replace type geo_result as object (
  ip        varchar2(50),
  country   varchar2(100),
  city      varchar2(100),
  timezone  varchar2(100)
);

create or replace type geo_result_tab as table of geo_result;

create or replace function geoip_from_cursor(p_ips in sys_refcursor)
return geo_result_tab pipelined
as
  l_ip        varchar2(50);
  l_response  clob;
  l_country   varchar2(100);
  l_city      varchar2(100);
  l_timezone  varchar2(100);
begin
  loop
    fetch p_ips into l_ip;
    exit when p_ips%notfound;

    l_response := apex_web_service.make_rest_request(
      p_url => 'http://ip-api.com/json/' || l_ip,
      p_http_method => 'GET'
    );

    l_country  := json_value(l_response, '$.country');
    l_city     := json_value(l_response, '$.city');
    l_timezone := json_value(l_response, '$.timezone');

    pipe row(geo_result(l_ip, l_country, l_city, l_timezone));
  end loop;
  close p_ips;
  return;
end;
/

select * from geoip_from_cursor(cursor(select '148.164.48.97' from dual));





-- Tabelle mit Logeinträgen

create table logeintraege (
  log_datum   timestamp default systimestamp,
  ip_adresse  varchar2(45),
  username    varchar2(100)
); 

insert into logeintraege (
  log_datum,
  ip_adresse,
  username
) 
select -- Zufällige Uhrzeit am heutigen Tag
       trunc(sysdate) + (dbms_random.value(0, 1)),
       -- Zufällige IPv4-Adresse
       to_char(trunc(dbms_random.value(1,255))) || '.' ||
       to_char(trunc(dbms_random.value(0,255))) || '.' ||
       to_char(trunc(dbms_random.value(0,255))) || '.' ||
       to_char(trunc(dbms_random.value(1,255))),
       -- Zufälliger Username aus einer Liste
       case trunc(dbms_random.value(1, 6))
         when 1 then 'alice'
         when 2 then 'bob'
         when 3 then 'carol'
         when 4 then 'dave'
         when 5 then 'eve'
       end
  from dual connect by level <= 50;

select * from logeintraege;

commit;





-- Verwendung

select * from geoip_from_cursor(cursor(select ip_adresse from logeintraege));

select country, count(*)
  from geoip_from_cursor(cursor(select ip_adresse from logeintraege))
 where country is not null 
 group by country
 order by count(*) desc;



 
select country, anzahl, round(ratio_to_report(anzahl) over () * 100,2) as prozentualer_anteil
  from (select country, count(*) as anzahl
          from geoip_from_cursor(cursor(select ip_adresse from logeintraege))
         where country is not null 
         group by country)
 order by anzahl desc;