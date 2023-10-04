-- Write SQL queries to perform the following tasks using the Sakila database:

-- 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
select COUNT(*) as num_copies
from film f
inner join inventory i on f.film_id = i.film_id
where f.title = 'Hunchback Impossible';

-- 2. List all films whose length is longer than the average length of all the films in the Sakila database.
select * 
from film
where length > (select avg(length) from film);


-- 3. Use a subquery to display all actors who appear in the film "Alone Trip".
select a.actor_id, a.first_name, a.last_name
from actor a
left join film_actor fa on a.actor_id = fa.actor_id
left join film f on fa.film_id = f.film_id
where f.title = 'Alone Trip';


with alonetrip as (
select film_id
from film
where title = 'Alone Trip'
)

select a.actor_id, a.first_name, a.last_name
from actor a
inner join film_actor fa on a.actor_id = fa.actor_id -- the INNER JOIN ensures that only actors with a matching entry in both film_actor and alonetrip are selected, effectively finding actors who appear in the film "Alone Trip".
inner join alonetrip af on fa.film_id = af.film_id;


-- 4. Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.
select f.title, c.name
from film f 
inner join film_category fc on f.film_id = fc.film_id
inner join category c ON fc.category_id = c.category_id
where c.name = 'Family';

-- 5. Retrieve the name and email of customers from Canada using both subqueries and joins. 
-- To use joins, you will need to identify the relevant tables and their primary and foreign keys.
with canadacus as (
select country, country_id
from country 
where country in ('Canada')
)

select c.first_name, c.email, co.country
from customer c 
inner join address ad on c.address_id = ad.address_id
inner join city ct on ad.city_id = ct.city_id
inner join canadacus co on ct.country_id = co.country_id;

-- 6. Determine which films were starred by the most prolific actor in the Sakila database. 
-- A prolific actor is defined as the actor who has acted in the most number of films. First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.
with actorfilm as (
select actor_id, count(*) as film_count
from film_actor
group by actor_id
order by film_count desc
limit 1
)

select f.title, f.film_id, fa.actor_id
from film_actor fa
inner join actorfilm af on fa.actor_id = af.actor_id
inner join film f on fa.film_id = f.film_id;

-- 7. Find the films rented by the most profitable customer in the Sakila database. You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.
with profcust as (
select customer_id
from payment
group by customer_id
order by sum(amount) desc
limit 1
)

select f.title, p.customer_id
from payment p  
inner join profcust pc on p.customer_id = pc.customer_id
inner join rental r on p.rental_id = r.rental_id
inner join inventory i on r.inventory_id = i.inventory_id
inner join film f on i.film_id = f.film_id;

-- 8. Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. You can use subqueries to accomplish this.
with customertotal as (
select customer_id, sum(amount) as total_amount_spent
from payment
group by customer_id
)

select ct.customer_id, ct.total_amount_spent
from customertotal ct
where ct.total_amount_spent > (
    select avg(total_amount_spent) 
    from customertotal
);