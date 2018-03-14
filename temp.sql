select * from customers;
select * from purchases;
select * from products;
select * from employees;



1.	
select pid, name from products 
where discnt_rate > 0.1 and (qoh-10) >= qoh_threshold;


2.
select name, telephone# from customers
where to_char(last_visit_date, 'MON') = 'OCT' and to_char(last_visit_date, 'YYYY') = '2017' 
and telephone# like '666%';

NAME            TELEPHONE#
--------------- ------------
Kathy           666-555-4567
Joe             666-555-5746

3.
select name, telephone# 
from customers c where exists (select * from purchases
where c.cid = cid and total_price >=100 
and to_char(ptime, 'MON') = 'OCT' and to_char(ptime, 'YYYY') = '2017');

select name, telephone# 
from customers c, purchases p
where c.cid = p.cid and total_price >=100 
and to_char(ptime, 'MON') = 'OCT' and to_char(ptime, 'YYYY') = '2017';

select name, telephone# 
from customers c where cid in (select cid from purchases 
where c.cid = cid and total_price >=100 
and to_char(ptime, 'MON') = 'OCT' and to_char(ptime, 'YYYY') = '2017');


4. 
select pid, name from products
where original_price * (1 - discnt_rate) < 10 and pid in
(select pid from purchases 
where to_char(ptime, 'MON') = 'AUG' or to_char(ptime, 'MON') = 'SEP' 
and to_char(ptime, 'YYYY') = '2017'); 

5.
select * from purchases p
where cid in
(select cid from customers
where name like 'K%')
and pid in
(select pid from products 
where original_price < 15) 
and eid in
(select eid from employees where telephone# like '888%');


6.
column name heading "product name"
select pur#, name, 
to_char(ptime, 'Month DD, YYYY Day HH:MI:SS') ptime, 
total_price, original_price * qty - total_price saving
from purchases p1, products p2 
where p1.pid = p2.pid;

7.
select eid from employees
where substr(telephone#, 1, 3) in 
(select substr(telephone#, 1, 3) 
from customers) 
order by eid asc;

8.
select name from customers c
where visits_made >= 2 and cid in
(select cid from purchases 
where to_char(last_visit_date, 'DD-MM-YYYY') = to_char(ptime, 'DD-MM-YYYY') 
and pid in
(select pid from products 
where original_price * (1 - discnt_rate) <= 100));



9.
select e.name from employees e
where not exists
(select * from purchases p1
where exists
(select * from products p2 where e.eid = p1.eid and p1.pid = p2.pid and original_price >=200));


select e.name from employees e
where eid not in
(select eid from purchases 
where pid not in 
(select pid from products where original_price >=200));


10.
select cid, name from customers c
where not exists
(select * from products p
where pid in 
(select pid from purchases 
where cid = 'c005') and not exists
(select * from purchases
where c.cid = cid and p.pid = pid));

11.
select cid from customers c
where cid in
(select cid from purchases
where to_char(ptime, 'MON') = 'OCT' and to_char(ptime, 'YYYY') = '2017') and 
not exists 
(select * from products p where original_price > 200 and
not exists
(select * from purchases where p.pid = pid and c.cid = cid));


12.
select eid, name from employees e 
where not exists
(select * from customers c where cid in (select cid from purchases
where pid in (select pid from products where name = 'camera' or name = 'chair'))
and not exists 
(select * from purchases where e.eid = eid and c.cid = cid));

13.
select name from customers c
where cid in (
	select cid from purchases 
	where total_price in (select max(total_price) from purchases)); 

14.
column discount_amount heading "discount amount"
select pid, name, original_price * discnt_rate discount_amount from products
where original_price * discnt_rate in 
(select max(original_price * discnt_rate) from products);

15.
column ts heading "Total Sale"
select to_char(ptime, 'YYYY/MM') Month, sum(total_price) ts from purchases
group by to_char(ptime, 'YYYY/MM')
order by to_char(ptime, 'YYYY/MM');

16.
column tqs heading "total quantity sold"
select p1.pid, p1.name, p2.tqs 
from products p1, (select pid, sum(qty) tqs from purchases group by pid) p2
where p2.pid = p1.pid and 
p2.tqs >= all (select sum(qty) from purchases group by pid);

17.
select p1.pur#, p2.original_price * p1.qty - p1.total_price saving
from purchases p1, products p2 
where p1.pid = p2.pid and p2.original_price * p1.qty - p1.total_price in
(select max(saving) from
(select p2.original_price * p1.qty - p1.total_price saving from purchases p1, products p2
where p1.pid = p2.pid));

18.
select pur#
from purchases where total_price >= all
(select total_price from purchases where cid = 'c006');


select pur#
from purchases where total_price >= 
(select max(total_price) from purchases where cid = 'c006');

------------------
select g.pur# 
from purchases g, (select max(total_price) c from purchases where cid = 'c006') b
where g.total_price >= b.c;
------------------

19.
column ts heading "total amount spent"
select * from (select c.cid, c.name, temp.ts from customers c, 
(select p.cid, sum(total_price) ts from purchases p
group by p.cid
order by ts desc) temp
where temp.cid = c.cid
order by temp.ts desc)
where rownum <= 3;

20.
column nc heading "number of customers"
select p1.pid, p1.name, nvl(cc, 0) nc from 
products p1, 
(select pid, count(cid) cc from purchases 
where to_char(ptime,'MON/YYYY') = 'OCT/2017'
group by pid) temp where p1.pid = temp.pid(+);
 




