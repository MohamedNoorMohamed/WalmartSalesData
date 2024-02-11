CREATE DATABASE IF NOT EXISTS salesDataWalmart;

use salesDataWalmart;
# create table
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(10) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(20),
    gross_income DECIMAL(12, 4),
    rating FLOAT(3)
);

SELECT * FROM salesdatawalmart.sales;

-- -------------------------------------------------------------------------------------------------------
-- -----------Feature Engineering --This will help use generate some new columns from existing ones----------------------------------------------------------------------

-- ----------------Time_of_the_day---to give insight of sales in the Morning, Afternoon and Evening---------------------------------------------------------------------

SELECT time,
	(CASE
	  WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
	  WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
	  ELSE 'Evening'
	  END
	) AS time_of_day
from sales;

-- Now we have to create a new column for time of day and insert values

ALTER TABLE sales
ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day = (
	CASE
		  WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
		  WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
		  ELSE 'Evening'
		  END
	);
    
-- day_name -- that contains the extracted days of the week on which the given transaction
-- took place (Mon, Tue, Wed, Thur, Fri)
SELECT date, DAYNAME(date) AS day_name
FROM sales;

-- ADD COULUMN AND INSERT VALUES
ALTER TABLE sales
ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = (
	DAYNAME(date)
    );

-- month_name ---that contains the extracted months of the year on which the given transaction
--  took place (Jan, Feb, Mar).

SELECT date, MONTHNAME(date) AS month_name
FROM sales;

-- ADD COULUMN AND INSERT VALUES
ALTER TABLE sales
ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = (
	MONTHNAME(date)
    );

-- ----------------------BUSINESS QUESTIONS TO ANSWER--------------------------------------------------------
-- -----------------------Generic Questions------------------------------------------------------------------
-- 1. How many unique cities does the data have?

select distinct city from sales;

-- 2. In which city is each branch?
SELECT DISTINCT city,  branch 
FROM sales
ORDER BY branch;

-- -------------------------Product Questions----------------------------------------------------------------
-- 1. How many unique product lines does the data have?
SELECT DISTINCT product_line
FROM sales;

SELECT COUNT(DISTINCT product_line) AS unique_lines
FROM sales;

-- 2. What is the most common payment method?
SELECT payment,
	COUNT(payment) AS cnt
FROM sales
GROUP BY payment
ORDER BY cnt DESC;

-- 3. What is the most selling product line?
SELECT product_line,
	COUNT(product_line) AS count_line
FROM sales
GROUP BY product_line
ORDER BY count_line DESC;

-- 4. What is the total revenue by month?
SELECT month_name, SUM(total) AS total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- 5. What month had the largest COGS?
SELECT month_name, SUM(cogs) AS total_cogs
FROM sales
GROUP BY month_name
ORDER BY total_cogs DESC;

-- 6. What product line had the largest revenue?
SELECT product_line, SUM(total) AS total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;


-- 7. What is the city with the largest revenue?
SELECT city, SUM(total) AS total_revenue 
FROM sales
GROUP BY city
ORDER BY total_revenue DESC;

-- 8. What product line had the largest VAT?
SELECT product_line, SUM(tax_pct) AS vat
FROM sales
GROUP BY product_line
ORDER BY vat DESC;

-- 9. Fetch each product line and add a column to those product line showing "Good", "Bad".
-- Good if its greater than average sales
SELECT product_line, total, AVG(total) AS avg_sales
FROM sales
GROUP BY product_line, total
ORDER BY avg_sales DESC;

SELECT product_line, total,
AVG(total) OVER(PARTITION BY product_line) AS avg_sales,
(CASE
	WHEN total >  THEN 'Good'
    ELSE 'Bad'
END
)
FROM sales;

SELECT product_line, 
AVG(total) OVER(PARTITION BY product_line) AS avg_sales,
IF(total > AVG(total), 'Good', 'Bad') AS status
FROM sales
GROUP BY product_line;

-- WILL COME BACK FOR THIS QUESTION

-- 10. Which branch sold more products than average product sold?
SELECT branch, SUM(quantity) AS qty
FROM SALES
GROUP BY branch
ORDER BY qty DESC;

-- or 
SELECT branch, SUM(quantity) AS qty
FROM SALES
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales)
ORDER BY qty DESC;

-- 11. What is the most common product line by gender?
SELECT product_line, gender, COUNT(gender) AS total_cnt
FROM sales
GROUP BY gender, product_line
ORDER BY product_line DESC;

-- 12. What is the average rating of each product line?
SELECT product_line, ROUND(AVG(rating), 2) AS avg_rating
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

-- ---------------------------------SALES--------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------
-- 1. Number of sales made in each time of the day per weekday?
select time_of_day,
count(total) AS total_sales
from sales
where day_name = 'Sunday' -- Try with differen names to get the sales per weekday
group by time_of_day;

-- 2. Which of the customer types brings the most revenue?
select customer_type, sum(total) AS total_revenue
from sales
group by customer_type
order by total_revenue desc;

-- 3. Which city has the largest tax percent/ VAT (Value Added Tax)?
select city, avg(tax_pct) AS vat
from sales
group by city
order by vat desc;

-- 4. Which customer type pays the most in VAT?
select customer_type, avg(tax_pct) AS vat
from sales
group by customer_type
order by vat desc;

-- ------------------------------CUSTOMERS-------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------
-- 1. How many unique customer types does the data have?
select distinct customer_type
from sales;
--  To show the count of each customer type
select distinct customer_type, count(customer_type)
from sales
group by customer_type;


-- 2. How many unique payment methods does the data have?
select distinct payment 
from sales;

-- to get the count of each payment method
select distinct payment, count(payment) as payment_count
from sales
group by payment;


-- 3. Which customer type buys the most?
select customer_type, count(customer_type)
from sales
group by customer_type;

-- 4. What is the gender of most of the customers?
select gender, count(gender) as gender_count
from sales
group by gender
order by gender_count desc;


-- 5. What is the gender distribution per branch?
select gender, count(gender) as gender_count
from sales
where branch = 'C' -- you can try with different branches
group by gender
order by gender_count desc;

-- 6. Which time of the day do customers give most ratings?
select time_of_day, avg(rating) AS rating_cnt
from sales
group by time_of_day
order by rating_cnt desc;

-- 7. Which time of the day do customers give most ratings per branch?
select time_of_day, avg(rating) AS rating_cnt
from sales
where branch = 'C'
group by time_of_day
order by branch desc;

-- 8. Which day fo the week has the best avg ratings?
select day_name, avg(rating) as avg_rating
from sales
group by day_name
order by avg_rating desc
limit 1;

-- 9. Which day of the week has the best average ratings per branch?
select day_name, avg(rating) as avg_rating
from sales
where branch  = 'A'
group by day_name
order by avg_rating desc;

















































