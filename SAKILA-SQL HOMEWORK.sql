USE sakila;

# 1a. Display the first and last names of all actors from the table actor.
SELECT first_name
	, last_name
FROM actor;

#1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

SELECT CONCAT(first_name,' ',last_name) AS 'Actor Name'
FROM actor;

#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'Joe';
  
#2b. Find all actors whose last name contain the letters GEN:

SELECT first_name, last_name
FROM actor 
WHERE last_name LIKE '%GEN%';


#2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:

SELECT last_name, first_name
FROM actor 
WHERE last_name LIKE '%LI%';

#2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country, last_update
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

#3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
#3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor ADD actor_description blob; 
ALTER TABLE actor DROP actor_description;

#4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(actor_id) as 'Number of Actors'
FROM actor 
GROUP BY last_name; 

#4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, count(actor_id) as 'Number of Actors'
FROM actor 
GROUP BY last_name
HAVING count(actor_id) >= 2;

#4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO'
AND last_name = 'WILLIAMS';

#4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO'
AND last_name = 'WILLIAMS';

#5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
#Create the table and add in all the columns with appropriate data types
#Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
#Can only run once - ## out until final ready

CREATE TABLE `address` (
   `address_id` INT(50) NOT NULL AUTO_INCREMENT,
   `address` varchar(50) NOT NULL,
	`address2` varchar(50) NOT NULL,
   `district` varchar(50) NOT NULL,
   `city_id` INT,
   `postal_code` varchar(50) NOT NULL,
   `phone` varchar(20) NOT NULL,
   `location` geometry NOT NULL,
   `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
   PRIMARY KEY (`address_id`)
   )ENGINE=InnoDB DEFAULT CHARSET=latin1
   
#6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

SELECT staff.first_name, staff.last_name, address.address, address.address2, address.district, address.postal_code
FROM staff
	INNER JOIN address ON address.address_id = staff.address_id;
    
#6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT staff.first_name, staff.last_name, payment.payment_id, payment.staff_id, sum(payment.amount) AS 'Total Amount Rung Up ($)', payment.payment_date
FROM staff
	INNER JOIN payment ON payment.staff_id = staff.staff_id
WHERE payment.payment_date BETWEEN '2005-08-01 00:00:00' AND '2005-08-31 23:59:59'
GROUP BY staff.first_name, staff.last_name;
    
#6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

SELECT film.title, count(film_actor.actor_id) As 'Number of Actors in Film'
FROM film_actor
	INNER JOIN film ON film_actor.film_id = film.film_id
GROUP BY film.title;

#6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT count(film_id) AS 'Copies of Hunchback Impossible'
FROM inventory 
WHERE film_id IN
	(
    SELECT film_id
	FROM film
    WHERE title = 'Hunchback Impossible'
);
#6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:

SELECT sum(payment.amount) AS 'Total Paid Per Customer ($)', customer.first_name, customer.last_name
FROM payment
	INNER JOIN customer ON payment.customer_id = customer.customer_id
GROUP BY customer.first_name, customer.last_name 
ORDER BY customer.last_name;

#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
#films starting with the letters K and Q have also soared in popularity. 
#Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

SELECT title 
FROM film 
WHERE language_id IN 
	(
	SELECT language_id 
	FROM language 
	WHERE name = 'English' 
);

#7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name 
FROM actor 
WHERE actor_id IN 
	(
	SELECT actor_id 
	FROM film 
	WHERE title = 'Alone Trip' 
);

#7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
#Use joins to retrieve this information.
SELECT customer.first_name, customer.last_name, customer.email
FROM customer
	INNER JOIN address ON customer.address_id = address.address_id
    INNER JOIN city ON city.city_id = address.city_id
	INNER JOIN country ON city.country_id = country.country_id
		WHERE country = 'Canada';
        
#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
#Identify all movies categorized as family films.
SELECT title AS 'Films Rated "Family"'
FROM film 
WHERE film_id IN
	(
    SELECT film_id
    FROM film_category
    WHERE category_id IN
		( 
		SELECT category_id
        FROM category
        WHERE name = 'Family'
));

#7e. Display the most frequently rented movies in descending order.
SELECT count(rental.rental_id) AS 'Times Rented', film.title AS 'Title'
FROM rental
	JOIN inventory ON inventory.inventory_id = rental.inventory_id
	JOIN film ON film.film_id = inventory.inventory_id
GROUP BY film.title 
ORDER BY count(rental.rental_id) DESC
;
 
#7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store.store_id As 'Store ID', address.address AS 'Store Address', sum(payment.amount) As 'Total Revenue ($)'
FROM payment
	JOIN staff ON staff.staff_id = payment.staff_id
	JOIN store ON store.store_id = staff.store_id
    JOIN address ON address.address_id = store.address_id 
GROUP BY store.store_id
ORDER BY sum(payment.amount) DESC;


#7g. Write a query to display for each store its store ID, city, and country.
SELECT store.store_id As 'Store ID', city.city AS 'City', country.country AS 'Country'
FROM store
	JOIN address ON address.address_id = store.address_id
	JOIN city ON city.city_id = address.city_id
    Join country ON country.country_id = city.country_id
GROUP BY store.store_id;

#7h. List the top five genres in gross revenue in descending order. 
#(Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT category.name AS 'Genre', sum(payment.amount) AS 'Gross Revenue ($)'
FROM category
	JOIN film_category ON film_category.category_id = category.category_id
	JOIN inventory ON inventory.film_id = film_category.film_id
	JOIN rental ON rental.inventory_id = inventory.inventory_id
	JOIN payment ON payment.rental_id = rental.rental_id
GROUP BY category.name
ORDER BY sum(payment.amount) DESC
LIMIT 5;


#8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
#Use the solution from the problem above to create a view. If you haven't solved 7h, 
#you can substitute another query to create a view.
create view `Top Five Genres by Gross Revenue` As (
SELECT category.name AS 'Genre', sum(payment.amount) AS 'Gross Revenue ($)'
FROM category
	JOIN film_category ON film_category.category_id = category.category_id
	JOIN inventory ON inventory.film_id = film_category.film_id
	JOIN rental ON rental.inventory_id = inventory.inventory_id
	JOIN payment ON payment.rental_id = rental.rental_id
GROUP BY category.name
ORDER BY sum(payment.amount) DESC
LIMIT 5
);

#8b. How would you display the view that you created in 8a?
SELECT *
FROM Top_Five_Genres_By_Revenue;


#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW Top_Five_Genres_By_Revenue;
 
