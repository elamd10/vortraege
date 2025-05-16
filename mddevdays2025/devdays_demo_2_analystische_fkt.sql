
-- Kummulation

select e.ename, 
       e.sal,
       sum(e.sal) over (order by sal)
  from emp e;  

select e.deptno,
       e.ename, 
       e.sal,
       sum(e.sal) over (partition by deptno order by sal)
  from emp e;  





-- mathematische Funktionen allgemein

select e.deptno,
       e.ename, 
       e.sal,
       sum(e.sal) over (partition by deptno order by sal) as kummulierte_sum_p_d,
       sum(e.sal) over (partition by deptno) as summe_p_d,
       count(*) over (partition by deptno order by sal) as kummulierte_anzahl_p_d,
       count(*) over (partition by deptno) as anzahl_p_d,
       round(avg(e.sal) over (partition by deptno)) as avg_p_d,
       round(sum(e.sal) over (partition by deptno) / count(*) over (partition by deptno)) as avg_p_d_berechnet,
       min(e.sal) over (partition by deptno) as kleinste_gehalt,
       max(e.sal) over (partition by deptno) as groesste_gehalt
  from emp e;  



select e.deptno,
       e.ename, 
       e.sal,
       round(ratio_to_report(e.sal) over (partition by e.deptno) * 100,2) as anteil_in_proz,
       round(stddev(e.sal) over (partition by e.deptno)) as standardabweichung,
       round(variance(e.sal) over (partition by e.deptno)) as varianz
  from emp e;  






-- Aufsplittung meiner Ergebnisse in mehrere "Eimer"

select e.deptno,
       e.ename, 
       e.sal,
       ntile(3) over (order by e.sal) as bucket
  from emp e;

select e.deptno,
       e.ename, 
       e.sal,  
       ntile(3) over (partition by e.deptno order by e.sal) as bucket
  from emp e;  






-- Sortierung

select e.ename, 
       e.sal,
       rank() over (order by e.sal) as rnk,
       dense_rank() over (order by sal) as dense_rnk,
       row_number() over (order by sal) as rn
  from emp e;   

select e.ename, 
       e.sal,
       rank() over (partition by d.dname order by sal) as rnk,
       dense_rank() over (partition by d.dname order by sal) as dense_rnk,
       row_number() over (partition by d.dname order by sal) as rn,
       d.dname
  from emp e
  join dept d on d.deptno = e.deptno;  






-- nur Kollegen in den Departments mit geringstem Verdienst ausgeben

select *
  from (select e.ename, 
               e.sal,
               rank() over (partition by d.dname order by sal) as rnk,
               d.dname
          from emp e
          join dept d on d.deptno = e.deptno)
 where rnk = 1; 






-- Erster und letzter Wert

select e.deptno,
       e.ename, 
       e.sal,
       first_value(e.ename) over (partition by deptno),
       last_value(e.ename) over (partition by deptno)
  from emp e;  






-- Vorgänger/Nachfolger

select e.ename, 
       e.sal,
       row_number() over (order by sal) as rn,
       lag(ename) over (order by sal) as vorgaenger,
       lead(ename) over (order by sal) as nachfolger
  from emp e;  


-- praktisches Beispiel: Kontrolle auf korrekte Zeitscheibenabgrenzung

select count(*)
  from (select lead(psh_gueltig_von) over (partition by psh_vnb, psh_profilschar order by psh_gueltig_bis) as gueltig_von_nachf,
               lead(psh_id) over (partition by psh_vnb, psh_profilschar order by psh_gueltig_bis) as psh_id_nachf,
               psh_gueltig_bis
          from prf_profilschar_header a
         where psh_pssid = (select s.pss_id from prf_profilschar_status s where s.pss_description = 'gueltig')
       ) b
 where nvl(psh_gueltig_bis, to_date('01.01.4000','DD.MM.YYYY'))+(1/24/60/60) != gueltig_von_nachf
   and psh_id_nachf is not null;







-- Beispiel gleitender Durchschnitt (Daten aus dem DOXA.Fahrplanmanagement)

select tdg_station, tdg_date, tdg_temp_tag 
  from stmp_temperaturpaket_gemessen_mv 
 where tdg_date >= trunc(sysdate)-30
   and tdg_station in ('Greifswald','Bremen')
 order by tdg_station, tdg_date;

select tdg_station, tdg_date, tdg_temp_tag,
       avg(tdg_temp_tag) over (partition by tdg_station order by tdg_date rows between 2 preceding and 2 following) as avg
  from stmp_temperaturpaket_gemessen_mv 
 where tdg_date >= trunc(sysdate)-30
   and tdg_station in ('Greifswald','Bremen')
 order by tdg_station, tdg_date;




-- Ermittlung der Kollegen

select e.deptno,
       e.ename, 
       replace(replace(listagg(e.ename, ', ') over (partition by deptno), e.ename||', '), e.ename) as kollegen
  from emp e;  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  


-- zurück zur Kummulation

select e.deptno,
       e.ename, 
       e.sal,
       sum(e.sal) over (partition by deptno order by sal)
  from emp e;  

--> mit rows between unbounded preceding and unbounded following ...

select e.deptno,
       e.ename, 
       e.sal,
       sum(e.sal) over (partition by deptno order by sal rows between unbounded preceding and unbounded following)
  from emp e;  

--> wird daraus wieder die Summe pro Department

select e.deptno,
       e.ename, 
       e.sal,
       sum(e.sal) over (partition by deptno order by sal rows between unbounded preceding and 0 following)
  from emp e;  


--> Aufpassen:
-- ohne order by wird für jeden Eintrag einer Partition die Summe über alle Partitionsmitglieder erstellt
-- mit order by-Klausel werden nur die Vorgänger aufsummiert!!!




