select * from emp;

select * from dept;








-- Durchschnittsgehalt 

select round(avg(sal)) from emp;




-- Durchschnittsgehalt pro Abteilung

select e.deptno, round(avg(e.sal))
  from emp e
 group by e.deptno;  




-- Abweichung vom Durchschnittsgehalt pro Abteilung

select e.ename, 
       e.deptno,
       e.sal,
       h.avg_sal_per_dept, 
       e.sal - h.avg_sal_per_dept as abweichung
  from emp e
  join (select e2.deptno, round(avg(e2.sal)) as avg_sal_per_dept
          from emp e2
         group by e2.deptno) h
    on e.deptno = h.deptno
 order by 2,1;  




-- Weitere Variante

select e.ename,
       e.deptno, 
       e.sal,
       (select round(avg(e2.sal)) as avg_sal_per_dept from emp e2 where e2.deptno = e.deptno group by e2.deptno) as avg_sal_per_dept, 
       e.sal - (select round(avg(e2.sal)) as avg_sal_per_dept from emp e2 where e2.deptno = e.deptno group by e2.deptno) as abweichung
  from emp e
order by 2,1;  





-- mit analytischer Funktion

select e.ename,
       e.deptno, 
       e.sal,
       round(avg(e.sal) over (partition by deptno)) as avg_sal_per_dept, 
       e.sal - round(avg(e.sal) over (partition by deptno)) as abweichung
  from emp e
 order by 2,1;  

