-- Activate database
USE sakila ;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name
FROM actor ;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT 
	actor_id,
	first_name, 
    last_name,
    last_update,
    CONCAT(first_name,' ',last_name) as actor_name
FROM actor ; 

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT 
	actor_id,
	first_name, 
    last_name
FROM actor
WHERE first_name LIKE '%joe' ;

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT 
	actor_id,
	first_name, 
    last_name
FROM actor
WHERE last_name LIKE '%GEN' ;

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT 
	actor_id,
	first_name, 
    last_name
FROM actor
WHERE last_name LIKE '%l' OR last_name LIKE '%i' 
ORDER BY last_name, first_name ;


-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT    
    country_id,
    country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh','China') ; 

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description
-- Create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor
ADD COLUMN description BLOB ;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP COLUMN description ;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT DISTINCT last_name, COUNT(1) as count
FROM actor 
GROUP BY last_name
ORDER BY count DESC ;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT DISTINCT last_name, COUNT(1) as count
FROM actor 
GROUP BY last_name
HAVING count >=2
ORDER BY count DESC ;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.

	-- Find unique actor_id for Groucho Williams (172)
SELECT actor_id, first_name, last_name
	FROM actor
    WHERE first_name LIKE 'Grou%' ;

	-- Update name
UPDATE actor SET first_name = 'HARPO' WHERE actor_id = 172 ; 

	-- Confirm update
SELECT actor_id, first_name, last_name
	FROM actor
	WHERE actor_id = 172 ;

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
-- It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO
UPDATE actor SET first_name = 'GROUCHO' WHERE actor_id = 172 ;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
	-- Print the structure of the table in order to recreate it
SHOW CREATE TABLE address ; 

	-- Find the schema where your table is in
SELECT table_schema
FROM information_schema.tables
WHERE table_name = 'address' ;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT s.first_name, s.last_name, a.address
FROM staff AS s
JOIN address AS a
USING (address_id) ; 

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT s.first_name, s.last_name, SUM(amount) as ttl_amount
FROM staff AS s
JOIN payment AS p
USING (staff_id) 
WHERE p.payment_date LIKE '2005-08%'
GROUP BY staff_id ; 

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT f.title, COUNT(actor_id) AS number_actors
FROM film AS f
JOIN film_actor AS a 
USING (film_id) 
GROUP BY film_id ; 

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
-- 6 COPIES

SELECT COUNT(film_id) as ttl_copies, f.title
FROM inventory 
JOIN film AS f
USING (film_id) 
WHERE title LIKE 'Hunchback%'  ; 

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT c.first_name, c.last_name, SUM(amount) AS ttl_paid 
FROM payment AS p 
JOIN customer AS c
USING (customer_id)
GROUP BY customer_id 
ORDER BY c.last_name ;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title, film_id FROM film WHERE title LIKE 'K%' OR title LIKE 'Q%' AND film_id IN (
	SELECT film_id FROM language WHERE language_id = 1 ) ; 

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name FROM actor WHERE actor_id IN (
	SELECT actor_id FROM film_actor WHERE film_id IN (
		SELECT film_id FROM film WHERE title = "ALONE TRIP" ) 
); 

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT c1.first_name, c1.last_name, c1.email, a.address, c3.country
FROM customer AS c1
JOIN address AS a
	USING (address_id) 
JOIN city AS c2
	USING (city_id) 
JOIN country AS c3
	USING (country_id) 
WHERE country = 'Canada' ; 

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT f.title, f.description, c.name AS film_category
FROM film AS f 
JOIN film_category AS fc
	USING (film_id) 
JOIN category as c
	USING (category_id) 
WHERE name = 'Family' ;

-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title, i.inventory_id, COUNT(inventory_id) as rental_count 
FROM film AS f
JOIN inventory AS i
	USING (film_id) 
JOIN rental AS r 
	USING (inventory_id) 
GROUP BY title 
ORDER BY rental_count DESC ; 

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, CONCAT('$', FORMAT(SUM(amount), 2)) AS ttl_amount
FROM store AS s
JOIN inventory AS i
	USING (store_id) 
JOIN rental AS r
	USING (inventory_id)
JOIN payment AS p
	USING (rental_id)
GROUP BY store_id ; 

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, a.address, c.city, c2.country
FROM store AS s
JOIN address AS a
	USING (address_id) 
JOIN city AS c 
	USING (city_id)
JOIN country AS c2
	USING (country_id)
GROUP BY store_id ;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW TopGenres AS
	SELECT c.name AS category_name, CONCAT('$', FORMAT(SUM(amount),2)) AS gross_revenue  
    FROM category AS c 
    JOIN film_category AS f
		USING (category_id) 
	JOIN inventory AS i 
		USING (film_id)
	JOIN rental AS r
		USING (inventory_id) 
	JOIN payment AS p
		USING (rental_id) 
    GROUP BY name 
    ORDER BY gross_revenue DESC 
    LIMIT 5 ;
    
-- 8b. How would you display the view that you created in 8a?
SELECT * FROM TopGenres ;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW TopGenres ;