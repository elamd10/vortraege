
create table kunden_mig
as
select * from kunden where 1=2;

insert into kunden_mig 
select * from kunden where rownum <= 200000;

create index kunden_mig_ort_idx on kunden_mig (ort);



select * from kunden_mig where ort = 'Wuerselen';

select * from kunden_mig where ort = 'Magdeburg';




select num_rows, avg_row_len from user_tables where table_name = 'KUNDEN_MIG';

exec dbms_stats.gather_table_stats(user, 'KUNDEN_MIG');


select * from kunden_mig where ort = 'Wuerselen';

select * from kunden_mig where ort = 'Magdeburg';

