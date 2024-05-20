
create index kunden_mig_name_vorname_ort_idx on kunden_mig (name, vorname, ort);
 
select segment_name, segment_type, bytes, round(bytes/1024/1024,0) as mb 
  from user_segments
 where segment_name in ('KUNDEN_MIG','KUNDEN_MIG_NAME_VORNAME_ORT_IDX')
 order by segment_type desc, segment_name;


alter table kunden_mig move compress;

alter index kunden_mig_name_vorname_ort_idx rebuild compress 1; -- auch ohne Advanced Compression Option

alter index kunden_mig_name_vorname_ort_idx rebuild compress advanced;


