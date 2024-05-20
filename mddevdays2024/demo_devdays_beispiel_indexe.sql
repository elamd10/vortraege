
-- Beispiel 1
       
select * from kunden;

select count(*) from kunden;

select round(bytes/1024/1024) as mb from user_segments where segment_name = 'KUNDEN';




select * from kunden where name = 'Kaplan';

      






create index kunden_name_idx on kunden (name);

select * from kunden where name = 'Kaplan';



select * from kunden where name = 'Hertel';



select name, count(*) 
  from kunden 
 group by name 
 order by count(*) desc;    



select * from kunden where name = 'Hertel' and vorname = 'Marcel' and ort = 'Köln';





create index kunden_vorname_idx on kunden (vorname);

create index kunden_ort_idx on kunden (ort);

select * from kunden where name = 'Hertel' and vorname = 'Marcel' and ort = 'Köln';

select * from kunden where name = 'Barry' and vorname = 'Mindy' and ort = 'Magdeburg';

select * from kunden where name = 'Kaplan' and vorname = 'Dave' and ort = 'Mannheim';





create index kunden_name_vorname_ort_idx on kunden (name, vorname);

select * from kunden where name = 'Hertel' and vorname = 'Marcel' and ort = 'Köln';

alter index kunden_name_vorname_ort_idx invisible;

select * from kunden where name = 'Hertel' and vorname = 'Marcel' and ort = 'Köln';

alter index kunden_name_vorname_ort_idx visible;

select * from kunden where name = 'Hertel' and vorname = 'Marcel' and ort = 'Köln';





select * from user_indexes where table_name = 'KUNDEN' order by index_name;


drop index kunden_vorname_idx;

drop index kunden_ort_idx;


select * from user_indexes where table_name = 'KUNDEN' order by index_name;

select * from user_ind_columns where table_name = 'KUNDEN' order by index_name, column_position;

drop index kunden_name_idx;






-- Beispiel 2

select * from kunden where ort = 'Wuerselen';




create index kunden_ort_idx on kunden (ort) invisible;

select * from kunden where ort = 'Wuerselen';





alter session set optimizer_use_invisible_indexes=true;

select * from kunden where ort = 'Wuerselen';

alter index kunden_ort_idx visible;







select * from kunden where ort = 'Wuerselen' and strasse = 'Zedernstr.';



select * from kunden where plz = '52146' and strasse = 'Zedernstr.';



select * from kunden where upper(ort) = 'WUERSELEN' and strasse = 'Zedernstr.';




create index kunden_upper_ort_idx on kunden (upper(ort));

select * from kunden where upper(ort) = 'WUERSELEN' and strasse = 'Zedernstr.';





create index kunden_upper_ort_upper_strasse_idx on kunden (upper(ort), upper(strasse));

select * from kunden where upper(ort) = 'WUERSELEN' and upper(strasse) = 'ZEDERNSTR.';




select * from user_indexes where table_name = 'KUNDEN' order by index_name;

select * from user_ind_columns order by index_name, column_position;

select ic.*, tc.data_default, tc.virtual_column
  from user_ind_columns ic
  join user_tab_cols tc on tc.table_name = ic.table_name and tc.column_name = ic.column_name 
  order by ic.index_name, ic.column_position;

drop index kunden_upper_ort_idx;







-- Beispiel 3

select fremdschluessel from kunden;

select * from kunden where fremdschluessel like '00920824%';




create index kunden_fremdschluessel_idx on kunden (fremdschluessel);

select * from kunden where fremdschluessel like '00920824%';




select * from kunden where fremdschluessel like '0092%';

select * from kunden where fremdschluessel like '%82443';




create index kunden_reverse_fremdschluessel_idx on kunden (reverse(fremdschluessel));    

select * from kunden where reverse(fremdschluessel) like reverse('%82443');



exec dbms_stats.gather_table_stats(user, 'kunden', estimate_percent => 5, method_opt => 'FOR ALL INDEXED COLUMNS SIZE 255');

select fremdschluessel from kunden where reverse(fremdschluessel) like reverse('%582443');

















-- Demo Ergänzung function-based Indexe mit eigenen Funktionen

update kunden set ort = 'Würselen' where ort = 'Wuerselen' and strasse = 'Am Veilchen'; 

select * from kunden where upper(ort) = 'WUERSELEN' and upper(strasse) = 'AM VEILCHEN';




 
create or replace function umlaute_ersetzen (zeichenkette varchar2) return varchar2
deterministic
is
begin
  return replace(replace(replace(zeichenkette,'Ü','UE'),'Ä','AE'),'Ö','OE');
end;
/

create index kunden_replace_upper_ort_replace_upper_strasse_idx on kunden (umlaute_ersetzen(upper(ort)), umlaute_ersetzen(upper(strasse)));

--> ORA-30553: Funktion ist nicht deterministisch

--> Function mit Schlüsselwort deterministic neu kompilieren

create index kunden_replace_upper_ort_replace_upper_strasse_idx on kunden (umlaute_ersetzen(upper(ort)), umlaute_ersetzen(upper(strasse)));

--> ORA-01450: Maximale Schlüssellänge (6398) überschritten

create index kunden_replace_upper_ort_replace_upper_strasse_idx on kunden (umlaute_ersetzen(upper(ort)));

--> mit einem Attribut funktioniert es
--> Besserung mit 23ai und SQL-Domains?!?


select * 
  from kunden 
 where umlaute_ersetzen(upper(ort)) = 'WUERSELEN' and umlaute_ersetzen(upper(strasse)) = 'AM VEILCHEN';



--> ACHTUNG!
--> Funktion sollte auch wirklich deterministisch sein
--> Index muss nach Änderung der Funktion neu aufgebaut bzw. reorganisiert werden!!!