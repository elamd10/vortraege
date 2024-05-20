
select ort, count(*) 
  from kunden 
 group by ort 
 order by count(*) desc; 




select ort, count(*) 
  from kunden
 where ort is not null 
 group by ort 
 order by count(*) desc; 



select * from kunden where ort is null;



alter table kunden modify (ort not null);




select ort, count(*) 
  from kunden 
 group by ort 
 order by count(*) desc; 


