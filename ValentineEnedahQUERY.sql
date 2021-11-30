/*QUESTION 1 - What is the total monthly number of rental orders for each store? */

select date_trunc('month', r.rental_date) Rental_month, i.store_id, count(*) count_rentals
from rental r
left join inventory i
on i.inventory_id = r.inventory_id
group by 1,2
order by 3 desc;

/* QUESTION 2 - Who are the customers with the highest difference in orders of rentals from one month to another? */

WITH
top_10 AS
	(SELECT c.customer_id, CONCAT (c.first_name, ' ', c.last_name) fullname, COUNT(*) pay_countpermon, SUM(p.amount) total_rents
	FROM payment p
	JOIN customer c
	ON p.customer_id = c.customer_id
	GROUP BY 1,2
	ORDER BY 3 DESC, 2
	LIMIT 10)

SELECT DATE_TRUNC('month', p.payment_date) pay_mon, t.fullname, COUNT(DATE_TRUNC('month', p.payment_date)) pay_countpermon, SUM(p.amount), SUM(p.amount) - LAG(SUM(p.amount)) OVER (PARTITION BY t.fullname ORDER BY DATE_TRUNC('month', p.payment_date)) difference
FROM payment p
JOIN top_10 t
ON p.customer_id = t.customer_id
GROUP BY 1,2;   



/* QUESTION 3 - Is there a comparison between the length of rental duration of family-friendly movies? */

select category, standard_quartile,
count(*)
from
	(select c.name category, f.rental_duration,
	 ntile(4) over (order by f.rental_duration) as standard_quartile
	 from category c
	 join film_category fc
	 on c.category_id = fc.category_id
	 join film f
	 on fc.film_id = f.film_id
	 where c.name in ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')) t1
	 group by category, standard_quartile
	 order by category, standard_quartile;

/* QUESTION 4 - What is the total number of rentals for the top 10 customers based on the highest orders of rentals per month? */

with
top_10 as 
		(select c.customer_id, concat (c.first_name, ' ', c.last_name) fullname, count(*) pay_countpermon, sum(p.amount)
		 from payment p
		 join customer c
		 on p.customer_id =  c.customer_id
		 group by 1, 2
		 order by 3 desc, 2
		 limit 10)
		 
select fullname, sum(pay_countpermon)
from (select date_trunc('month', p.payment_date) pay_mon, t.fullname, count(date_trunc('month', p.payment_date)) pay_countpermon, sum(p.amount)
from payment p
join top_10 t
on p.customer_id = t.customer_id
group by 1,2
order by 2,3 desc) sub
group by 1
order by 2 desc;

	
	
	
	
	
	
	
	                                   