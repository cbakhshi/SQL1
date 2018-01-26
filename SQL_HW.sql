USE Sakila;

-- Display the first and last names of all actors from the table `actor`
SELECT first_name, last_name FROM actor;

-- Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
ALTER TABLE actor ADD Actor_Name VARCHAR(50);
UPDATE actor SET Actor_Name = CONCAT(UPPER(first_name),' ',UPPER(last_name));

-- You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'Joe';
    
-- Find all actors whose last name contain the letters `GEN`:
SELECT *
FROM actor
WHERE last_name like '%GEN%';
  	
-- Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT *
FROM actor
WHERE last_name like '%LI%'
ORDER BY last_name, first_name;

-- Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. Hint: you will need to specify the data type.
ALTER table actor ADD column middle_name VARCHAR(20) AFTER first_name;
  	
-- You realize that some of these actors have tremendously long last names. Change the data type of the `middle_name` column to `blobs`.
ALTER TABLE actor
MODIFY COLUMN middle_name blob;

-- Now delete the `middle_name` column.
ALTER TABLE actor
DROP COLUMN middle_name;

-- List the last names of actors, as well as how many actors have that last name.
SELECT DISTINCT last_name, COUNT(last_name)
FROM actor
GROUP BY last_name;
  	
-- List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
CREATE TEMPORARY TABLE table_1
SELECT DISTINCT last_name, COUNT(last_name) as 'count_name'
FROM actor
GROUP BY last_name; 

SELECT *
FROM table_1
WHERE count_name > 2;
  	
-- Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
UPDATE actor 
SET Actor_Name = 'HARPO WILLIAMS' 
WHERE Actor_Name = 'GROUCHO WILLIAMS';
  	
-- Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! (Hint: update the record using a unique identifier.)
UPDATE actor
SET first_name = 'Groucho', last_name = 'Williams', Actor_Name = 'GROUCHO WILLIAMS'
WHERE Actor_Name = 'HARPO WILLIAMS';

-- You cannot locate the schema of the `address` table. Which query would you use to re-create it?
CREATE TABLE address (
	address_id VARCHAR(10),
    address VARCHAR(100),
    address2 VARCHAR(100),
	district VARCHAR(100),
    city_id INTEGER(10),
    postal_code INTEGER(10),
    phone INTEGER(10),
    location VARCHAR(100),
    last_update VARCHAR(100)
    );
    
-- Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT staff.first_name, staff.last_name, address.address
FROM staff
LEFT JOIN address ON staff.address_id=address.address_id;

-- Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`. 
SELECT staff.first_name, staff.last_name, payment.payment_date, payment.amount
FROM staff
LEFT JOIN payment ON staff.staff_id=payment.staff_id
WHERE payment.payment_date like '2005-08%';
    
-- List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT film.title, (SELECT count(*) FROM film_actor WHERE film_actor.film_id = film.film_id) AS '# of actors'
FROM film;

-- How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT count(film_id) as '# of copies'
FROM inventory
WHERE film_id IN (
	SELECT film_id
    FROM film
    WHERE title = 'Hunchback Impossible');

-- Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name: see instructions
SELECT customer.first_name, customer.last_name, SUM(payment.amount) 
FROM payment
INNER JOIN customer ON payment.customer_id = customer.customer_id
GROUP BY payment.customer_id
ORDER BY customer.last_name ASC;

-- The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English. 
SELECT title 
FROM film 
WHERE language_id IN(
	SELECT language_id
    FROM language 
    WHERE name = 'English') 
AND (title LIKE 'K%') OR  (title LIKE 'Q%');

-- Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name 
FROM actor
WHERE actor_id IN(
	SELECT actor_id
    FROM film_actor
    WHERE film_id IN(
		SELECT film_id
        FROM film
        WHERE title = 'Alone Trip'
));
   
-- You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT customer.first_name, customer.last_name, customer.email
FROM customer
LEFT JOIN address ON customer.address_id = address.address_id
LEFT JOIN city ON address.city_id = city.city_id 
LEFT JOIN country ON city.country_id = country.country_id
WHERE country.country = 'Canada';

-- Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.
SELECT title
FROM film
WHERE film_id IN(
	SELECT film_id
    FROM film_category
    WHERE category_id IN(
		SELECT category_id
        FROM category
        WHERE name = 'Family' 
));

-- Display the most frequently rented movies in descending order.
SELECT film.title, film.film_id, COUNT(rental.rental_id) AS 'rented #'
FROM film
LEFT JOIN inventory ON film.film_id = inventory.film_id
LEFT JOIN rental ON rental.inventory_id = inventory.inventory_id
GROUP BY film.film_id
ORDER BY COUNT(rental_id) DESC;

-- Write a query to display how much business, in dollars, each store brought in.
SELECT store.store_id, SUM(payment.amount) as 'Revenue' 
FROM store
INNER JOIN customer ON customer.store_id = store.store_id
INNER JOIN payment ON payment.customer_id = customer.customer_id
GROUP BY store.store_id
ORDER BY store.store_id; 

-- Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, city.city, country.country
FROM store
LEFT JOIN address ON store.address_id = address.address_id
LEFT JOIN city ON city.city_id = address.city_id 
LEFT JOIN country ON city.country_id = country.country_id;
    
-- List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT category.name, SUM(payment.amount) AS 'gross revenue' 
FROM film
LEFT JOIN film_category ON film_category.film_id = film.film_id
LEFT JOIN category ON film_category.category_id = category.category_id
LEFT JOIN inventory ON inventory.film_id = film.film_id
LEFT JOIN rental ON rental.inventory_id = inventory.inventory_id
LEFT JOIN payment ON payment.rental_id = rental.rental_id 
WHERE payment.amount IS NOT NULL 
GROUP BY category.name
ORDER BY SUM(payment.amount) DESC
LIMIT 5;

-- How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;

-- You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_five_genres;