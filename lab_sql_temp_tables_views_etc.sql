/* **Creating a Customer Summary Report**

In this exercise, you will create a customer summary report that summarizes key information about customers in the Sakila database, 
including their rental history and payment details. The report will be generated using a combination of views, CTEs, and temporary tables.

- Step 1: Create a View

First, create a view that summarizes rental information for each customer. 
The view should include the customer's ID, name, email address, and total number of rentals (rental_count).
*/

CREATE VIEW rental_info AS (
	SELECT rental.customer_id
		, customer.first_name
        , customer.last_name
        , customer.email
        ,count(rental.rental_id) as total_number_rentals
	FROM rental
    JOIN customer on rental.customer_id = customer.customer_id
    GROUP BY 1
);

/*
- Step 2: Create a Temporary Table

Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.
*/
CREATE TEMPORARY TABLE total_paid AS (
SELECT rental_info.customer_id
	, rental_info.first_name
    , rental_info.last_name
    , rental_info.email
    , rental_info.total_number_rentals
    , total_payment.total_amount
FROM rental_info
JOIN (
	SELECT customer_id
		, sum(amount) as total_amount
	FROM payment
	GROUP BY 1
	) as total_payment on total_payment.customer_id = rental_info.customer_id
);
/*
- Step 3: Create a CTE and the Customer Summary Report

Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. 
The CTE should include the customer's name, email address, rental count, and total amount paid. 
*/
with customer_info as (
	SELECT first_name
		, last_name
        , email
        , total_number_rentals
        , total_amount
	FROM total_paid
    )

/*
Next, using the CTE, create the query to generate the final customer summary report, 
which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, 
this last column is a derived column from total_paid and rental_count.
*/
WITH customer_info as ( -- you don't need a CTE to do this, see below
	SELECT first_name
		, last_name
        , email
        , total_number_rentals
        , total_amount
	FROM total_paid) 
SELECT *
    , total_amount/total_number_rentals as average_payment_per_rental
FROM customer_info;

SELECT first_name
	, last_name
	, email
	, total_number_rentals
	, total_amount
    , total_amount/total_number_rentals as average_payment_per_rental
FROM total_paid;