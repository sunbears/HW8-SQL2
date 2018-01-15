## Homework Assignment

USE sakila;

--  1a. Display the first and last names of all actors from the table `actor`. 
SELECT first_name, last_name 
	FROM actor;

--  1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`. 
SELECT CONCAT(first_name, " ", last_name) 
	AS ActorName
    FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
	FROM actor 
    WHERE first_name = "Joe";
  	
-- 2b. Find all actors whose last name contain the letters `GEN`:
SELECT first_name, last_name
	FROM actor
	WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. 
-- This time, order the rows by last name and first name, in that order:

SELECT first_name, last_name
	FROM actor
    WHERE last_name LIKE '%LI%'
    ORDER BY last_name, first_name;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
	FROM country
    WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. 
-- Hint: you will need to specify the data type.

ALTER TABLE actor
	ADD MiddleName VARCHAR(30)
    AFTER first_name;

-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the `middle_name` column to `blobs`.
ALTER TABLE actor
	MODIFY MiddleName BLOB(30);

-- 3c. Now delete the `middle_name` column.
ALTER TABLE actor
	DROP MiddleName;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*)
	FROM actor
    GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) c
	FROM actor
    GROUP BY last_name
    HAVING c>=2;

-- 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, 
-- the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = "GROUCHO" AND last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, 
-- if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor will be with the grievous error. 
-- BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! (Hint: update the record using a unique identifier.)


-- For some reason, I got Error Code 1175 if I didn't turn off safe mode for this one.
SET SQL_SAFE_UPDATES = 0;
UPDATE actor
	SET first_name = 'GROUCHO'
    WHERE actor_id IN 
		(SELECT actor_id
		WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS');
SET SQL_SAFE_UPDATES = 1;

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?

SHOW COLUMNS FROM address;

CREATE TABLE address_recreated (
	'address_id' SMALLINT(5) UNSIGNED AUTO_INCREMENT NOT NULL,
    'address' VARCHAR(50) NOT NULL,
    'address2' VARCHAR(50),
    'district' VARCHAR(20) NOT NULL,
    'city_id' SMALLINT(5) UNSIGNED NOT NULL,
    'postal_code' VARCHAR(10),
    'phone' VARCHAR(20),
    'location' GEOMETRY NOT NULL,
    'last_update' TIMESTAMP CURRENT TIMESTAMP,
    PRIMARY KEY (address_id)
;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT first_name, last_name, address
	FROM address a
		JOIN staff s ON (a.address_id = s.address_id);


-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`. 
SELECT first_name, last_name, staff_id, p.payment_date, SUM(amount)
	FROM staff s
		JOIN payment p USING(staff_id)
	WHERE p.payment_date >= '2005-08-01 12:00:00 AM' AND p.payment_date <= '2005-08-31 11:59:59';

                
-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT film_id, f.title, COUNT(actor_id)
	FROM film_actor fa
		INNER JOIN film f USING (film_id)
			GROUP BY film_id;
  	
-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT film_id, title, COUNT(film_id)
	FROM inventory 
    INNER JOIN film USING (film_id)
	WHERE title = 'Hunchback Impossible'
    GROUP BY film_id;

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
-- ![Total amount paid](Images/total_payment.png)
SELECT first_name, last_name, SUM(amount)
	FROM customer
    INNER JOIN payment USING (customer_id)
    GROUP BY customer_id
    ORDER BY last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English. 

SELECT f.title, f.language_id
FROM film f
WHERE f.language_id IN
	(
	SELECT l.language_id
	FROM language l
	WHERE l.name = 'English'
	)
    AND f.title LIKE 'K%';


    
--  7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

SELECT first_name, last_name
	FROM actor
    WHERE actor_id IN
		(
        SELECT actor_id
        FROM film_actor
        WHERE film_id IN
			(
            SELECT film_id
            FROM film
            WHERE title = 'Alone Trip'
            )
		);

--  7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.

SELECT first_name, last_name, email
	FROM customer
    WHERE address_id IN
		(
        SELECT address_id
        FROM address
        WHERE city_id IN
			(
            SELECT city_id
            FROM city
            WHERE country_id IN
				(
                SELECT country_id
                FROM country
                WHERE country = 'Canada'
				)
			)
		);
            
--  7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as famiy films.

SELECT f. title
	FROM film f
    WHERE film_id IN
		(
        SELECT film_id
        FROM film_category fc
        WHERE category_id IN
			(
			SELECT category_id 
			FROM category c
			WHERE name = 'Family'
			)
		);

--  7e. Display the most frequently rented movies in descending order.

SELECT i.inventory_id, f.title, COUNT(f.title)
	FROM rental r
    JOIN inventory i USING (inventory_id)
    JOIN film f USING(film_id)
    GROUP BY f.title
    ORDER BY COUNT(f.title) DESC;

--  7f. Write a query to display how much business, in dollars, each store brought in.

SELECT s.staff_id, s.store_id, SUM(p.amount)
	FROM payment p
    LEFT JOIN staff s USING (staff_id)
    GROUP BY store_id;

--  7g. Write a query to display for each store its store ID, city, and country.

SELECT s.store_id, c.city, co.country
	FROM staff s
    JOIN address a USING(address_id)
    JOIN city c USING (city_id)
    JOIN country co USING (country_id);
  	
--  7h. List the top five genres in gross revenue in descending order. 
-- (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT film_id, c.name, i.inventory_id, r.rental_id, SUM(p.amount)
	FROM category c
	JOIN film_category fc USING (category_id)
	JOIN film f USING (film_id)
	JOIN inventory i USING (film_id)
    JOIN rental r USING (inventory_id)
    JOIN payment p USING (rental_id)
    GROUP BY name
    ORDER BY SUM(p.amount) DESC
    LIMIT 5;

--  8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top_genres AS
SELECT film_id, c.name, i.inventory_id, r.rental_id, SUM(p.amount)
	FROM category c
	JOIN film_category fc USING (category_id)
	JOIN film f USING (film_id)
	JOIN inventory i USING (film_id)
    JOIN rental r USING (inventory_id)
    JOIN payment p USING (rental_id)
    GROUP BY name
    ORDER BY SUM(p.amount) DESC
    LIMIT 5;

--  8b. How would you display the view that you created in 8a?

SELECT * FROM top_genres;

--  8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_genres;
