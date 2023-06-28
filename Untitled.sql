USE sakila; 

-- 1 Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.

SELECT f.title, count(f.film_id) as number_of_copies
FROM sakila.inventory as i
JOIN sakila.film as f
ON i.film_id = f.film_id
GROUP BY f.title
HAVING title = 'HUNCHBACK IMPOSSIBLE';

-- 2 List all films whose length is longer than the average length of all the films in the Sakila database.

SELECT title, length
FROM sakila.film
WHERE length > (
  SELECT AVG(length) AS average_length
  FROM sakila.film
);

-- 3 Use a subquery to display all actors who appear in the film "Alone Trip".

SELECT a.first_name, a.last_name
FROM sakila.actor AS a
WHERE actor_id IN (
    SELECT fa.actor_id
    FROM sakila.film_actor AS fa
    JOIN sakila.film AS f ON fa.film_id = f.film_id
    WHERE f.title = 'Alone Trip'
);

-- 4 Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.

SELECT title FROM sakila.film
WHERE rating = 'PG' OR 'G';

-- 5 Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify 
	-- the relevant tables and their primary and foreign keys.
    
SELECT CONCAT(first_name, ' ', last_name) as customer_name, email as customer_email
FROM sakila.country as co
JOIN sakila.city as ci
ON co.country_id = ci.country_id
JOIN sakila.address as a
ON ci.city_id = a.city_id
JOIN sakila.customer as cu
ON a.address_id = cu.address_id
WHERE country = 'Canada';
    
-- 6 Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has acted in the most 
	-- number of films. First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.

CREATE TEMPORARY TABLE sakila.prolific_actor_films
SELECT film_id from sakila.film_actor
WHERE actor_id = (
    SELECT actor_id FROM (    
	    SELECT a.actor_id, CONCAT(a.first_name, ' ', a.last_name) as actor_name, count(fa.actor_id) as number_of_films 
	    FROM sakila.film_actor fa
	    JOIN sakila.actor as a
	    ON fa.actor_id = a.actor_id
	    GROUP BY a.actor_id
	    ORDER BY number_of_films DESC
        LIMIT 1
        ) as sub 
);
    
SELECT f.title FROM sakila.prolific_actor_films as p
JOIN sakila.film as f
ON p.film_id = f.film_id; 

    
-- 7 Find the films rented by the most profitable customer in the Sakila database. You can use the customer and payment tables to find the most profitable customer, 
	-- i.e., the customer who has made the largest sum of payments.

SELECT f.title
FROM sakila.film AS f
JOIN sakila.inventory AS i ON f.film_id = i.film_id
JOIN sakila.rental AS r ON i.inventory_id = r.inventory_id
JOIN (
    SELECT c.customer_id, SUM(p.amount) AS payment_sum
    FROM sakila.customer AS c
    JOIN sakila.payment AS p ON c.customer_id = p.customer_id
    GROUP BY c.customer_id
    ORDER BY payment_sum DESC
    LIMIT 1
) AS max_profit ON r.customer_id = max_profit.customer_id;
    
-- 8 Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent 
	-- by each client. You can use subqueries to accomplish this.
    
SELECT customer_id as client_id, sum(amount) as total_amount_spent
FROM sakila.payment
GROUP BY customer_id
HAVING total_amount_spent > (
  SELECT AVG(amount) AS average_amount
  FROM sakila.payment
)
ORDER BY total_amount_spent DESC;