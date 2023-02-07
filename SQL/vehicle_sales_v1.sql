-- Take a quick look at the sales table
SELECT *
FROM sales
LIMIT 10;

-- Take a look at the products table
SELECT *
FROM products;

-- Take a look at the dealerships table
SELECT *
FROM dealerships
LIMIT 10;

-- What months have the highest sales total & avg sales?
SELECT EXTRACT(mon FROM sales_transaction_date) AS month,
       ROUND(SUM(sales_amount)::NUMERIC,2) AS total_monthly_sales,
	   ROUND((SUM(sales_amount)/COUNT(sales_amount))::NUMERIC,2) AS avg_monthly_sales
FROM sales
GROUP BY month
ORDER BY month;
-- In general, there are lower total sales from October through February.
-- Per the average monthly sales, September had the highest avg sales, and
--   Oct through Feb was lowest. Not as much difference in average sales.

-- Add the number of sales (count) to the previous query.
SELECT EXTRACT(mon FROM sales_transaction_date) AS month,
       COUNT(sales_amount) AS total_sales,
       ROUND(SUM(sales_amount)::NUMERIC,2) AS total_monthly_sales,
	   ROUND((SUM(sales_amount)/COUNT(sales_amount))::NUMERIC,2) AS avg_monthly_sales
FROM sales
GROUP BY month
ORDER BY month;
-- May had the highest number of sales. Like sum and average, the Summer months
--  were higher than the Winter months.

-- Which products have sold the most?
SELECT p.product_id,
       p.model,
	   p.product_type,
       COUNT(s.sales_amount) AS total_sales_count,
       ROUND(SUM(s.sales_amount)::NUMERIC,2) AS total_sales_sum
FROM sales AS s
LEFT JOIN products AS p
       ON s.product_id = p.product_id
GROUP BY p.product_id, p.model, p.product_type
ORDER BY total_sales_count DESC;
-- The Lemon (id #3) is, by far, the biggest seller, followed by the Bat models. 
--  The automobile with the most sales was the Model Sigma (id #6).

-- Compare scooter sales to automobile sales.
SELECT p.product_type,
       COUNT(s.sales_amount) AS total_sales_count,
       ROUND(SUM(s.sales_amount)::INTEGER,2) AS total_sales_sum
FROM sales AS s
LEFT JOIN products AS p
       ON s.product_id = p.product_id
GROUP BY p.product_type
ORDER BY total_sales_count DESC;
-- Scooter sale count is 10x greater than automobiles. In terms of revenue,
--  sales totals for automobiles is ~15x greater than scooter totals.

-- Look at product type sales over time. 
SELECT EXTRACT (y FROM s.sales_transaction_date) AS year,
       p.product_type,
       COUNT(s.sales_amount) AS total_sales_count,
       ROUND(SUM(s.sales_amount)::INTEGER,2) AS total_sales_sum
FROM sales AS s
LEFT JOIN products AS p
       ON s.product_id = p.product_id
GROUP BY EXTRACT (y FROM s.sales_transaction_date), p.product_type
ORDER BY total_sales_sum DESC;
-- From 2014 to 2018, automobile sales have been increasing. For 2019, only the first
--  half of the year has been reported. We will try predicting how the rest of 2019 will
--  play out later. Similarly, scooter sales have been increasing, too. 

-- Are the sales from dealerships or internet? 
SELECT channel,
       COUNT(sales_amount) AS total_sales_count,
       ROUND(SUM(sales_amount)::INTEGER,2) AS total_sales_sum
FROM sales
GROUP BY channel;
-- There are more transactions via internet, but there is not much
--  difference in total sales amounts between them.

-- Let's add the product type to the previous query
SELECT s.channel,
       p.product_type,
       COUNT(s.sales_amount) AS total_sales_count,
       ROUND(SUM(s.sales_amount)::INTEGER,2) AS total_sales_sum,
	   ROUND(SUM(s.sales_amount)::INTEGER/COUNT(s.sales_amount),2) AS avg_sale_price
FROM sales AS s
LEFT JOIN products AS p
  ON s.product_id = p.product_id
GROUP BY s.channel, p.product_type;
-- The average sales price via internet is about 5K higher than at dealerships for
--  automobiles. However, the avg price of scooter sales is higher for dealerships
--  than for internet sales. 

-- What is the average sales for each dealership?
SELECT d.dealership_id,
       d.state,
       COUNT(s.sales_amount) AS total_sales_count,
       ROUND(SUM(s.sales_amount)::INTEGER,2) AS total_sales_sum,
	   ROUND(SUM(s.sales_amount)::INTEGER/COUNT(s.sales_amount),2) AS avg_sales_price
FROM sales AS s
LEFT JOIN dealerships AS d
  ON s.dealership_id = d.dealership_id
GROUP BY d.dealership_id, d.state
ORDER BY total_sales_count DESC;
-- there are several dealerships in the same state, so let's try to re-do and group
--  the dealerships by state.

SELECT d.state,
       COUNT(DISTINCT(d.dealership_id)) AS dealer_count,
       COUNT(s.sales_amount) AS total_sales_count,
       ROUND(SUM(s.sales_amount)::INTEGER,2) AS total_sales_sum,
	   ROUND(SUM(s.sales_amount)::INTEGER/COUNT(s.sales_amount),2) AS avg_sales_price
FROM sales AS s
LEFT JOIN dealerships AS d
  ON s.dealership_id = d.dealership_id
GROUP BY d.state
ORDER BY avg_sales_price DESC;
-- The WA dealership had relatively low number of sales, but was highest in avg sales.
--  TX dealers (3) had the most dealer sales, and the hightest avg sales. 

-- Sales are not exactly MSRP, so what kind of discounts are customers getting
--  from each dealership?
SELECT s.dealership_id,
       d.state,
       COUNT(s.sales_amount) AS sales_count,
       (SUM(p.base_msrp)::INTEGER - SUM(s.sales_amount)::INTEGER)
			 /COUNT(s.sales_amount) AS avg_discount
FROM sales AS s
LEFT JOIN products AS p
    ON s.product_id = p.product_id
LEFT JOIN dealerships AS d
    ON s.dealership_id = d.dealership_id
GROUP BY s.dealership_id, d.state
ORDER BY s.dealership_id;

-- Keep looking at discounts, but separate by vehicle type (scooter vs auto)
SELECT s.dealership_id,
       p.product_type,
       COUNT(s.sales_amount) AS total_sales_count,
       (SUM(p.base_msrp)::INTEGER - SUM(s.sales_amount)::INTEGER)
	       /COUNT(s.sales_amount) AS avg_discount
FROM sales AS s
LEFT JOIN products AS p
    ON s.product_id = p.product_id
GROUP BY s.dealership_id, p.product_type
ORDER BY s.dealership_id, p.product_type;
-- Automobiles have the larger discount than scooters, but they are also higher priced. 

-- What is the average percent discount, based on MSRP and sales price?
SELECT p.product_type,
       p.model,
	   COUNT(s.sales_amount) AS total_sales_count,
	   ROUND((SUM(p.base_msrp)::INTEGER - SUM(s.sales_amount)::INTEGER)/
	       SUM(p.base_msrp)*100,2) AS avg_percent_discount
FROM sales AS s
LEFT JOIN products AS p
    ON s.product_id = p.product_id
GROUP BY p.product_type, p.model
ORDER BY p.product_type, p.model;
-- Average discounts per model are all between 4.3% and 5.3%. It appears that automobile
--  discounts are slightly larger than those for scooters, with the exception of the Lemon
--  Limited Edition. 

-- What are the maximum and minimum discounts by product & product type?
SELECT p.product_id,
       p.product_type,
       p.model,
	   COUNT(s.sales_amount) AS total_sales_count,
	   ROUND((SUM(p.base_msrp)::INTEGER - SUM(s.sales_amount)::INTEGER)/
	       SUM(p.base_msrp)*100,2) AS avg_percent_discount,
	   ROUND(MAX((p.base_msrp::INTEGER - s.sales_amount::INTEGER)/
				 p.base_msrp)*100,2) AS max_percent_discount,
	   ROUND(MIN((p.base_msrp::INTEGER - s.sales_amount::INTEGER)/
				 p.base_msrp)*100,2) AS min_percent_discount
FROM sales AS s
LEFT JOIN products AS p
    ON s.product_id = p.product_id
GROUP BY p.product_type, p.model, p.base_msrp, p.product_id
ORDER BY p.product_id;
-- With the exception of the Model Chi (#11), the maximum discount was 20% and the
--  smallest was 0. 

-- How are automobile sales for each dealership, including internet?
SELECT d.dealership_id,
	   COUNT(s.sales_amount) AS total_sales_count,
       ROUND(SUM(s.sales_amount)::INTEGER,2) AS total_sales_sum,
	   ROUND(SUM(s.sales_amount)::INTEGER/COUNT(s.sales_amount),2) AS avg_sales_price
FROM sales AS s
LEFT JOIN dealerships AS d ON s.dealership_id = d.dealership_id
LEFT JOIN products AS p ON s.product_id = p.product_id
GROUP BY d.dealership_id, p.product_type
HAVING p.product_type = 'automobile'
ORDER BY total_sales_count DESC;
-- Except for Internet sales (NULL dealer ID), dealer #10 had the most number of sales
--  and the highest sales total (~$13.5M). Dealer #13 had the highest average sale 
--  (~$79.5K), with only 25 sales. 

-- Going back to the 2019 sales. Can we predict how sales will be for the remainder of
--  2019? 
-- Take a quick look at sales count and sum per year
SELECT EXTRACT (y FROM sales_transaction_date) AS sales_year,
       COUNT(sales_amount) AS total_sales_count,
       ROUND(SUM(sales_amount)::INTEGER,2) AS total_sales_sum
FROM sales
GROUP BY sales_year
ORDER BY sales_year DESC;
-- Both count and sum of sales have been increasing since 2012.

-- Now, let's look at the sales count and sum for just the first 5 months of each year.
SELECT EXTRACT (y FROM sales_transaction_date) AS sales_year,
       COUNT(sales_amount) AS total_sales_count,
       ROUND(SUM(sales_amount)::INTEGER,2) AS total_sales_sum
FROM sales
WHERE EXTRACT(mon FROM sales_transaction_date) <6
GROUP BY sales_year
ORDER BY sales_year DESC;
-- In comparing the sales for the first 5 months of each year, the count of sales for 
--  2019 is higher than previous years, but the sum of sales is lower than 2018 and
--  slightly higher than 2017. 

-- The assumption is that the higher number of sales in 2019 is for the lower priced
--  vehicles - scooters. What is the average sales price for each year (first 5 months)?
SELECT EXTRACT (y FROM sales_transaction_date) AS sales_year,
       COUNT(sales_amount) AS total_sales_count,
       ROUND(SUM(sales_amount)::INTEGER,2) AS total_sales_sum,
	   ROUND(SUM(sales_amount)::INTEGER/COUNT(sales_amount),2) AS avg_sales_price
FROM sales
WHERE EXTRACT(mon FROM sales_transaction_date) <6
GROUP BY sales_year
ORDER BY sales_year DESC;
-- For 2019, the average sales price for the first 5 months is much lower than 2015-
--  2018. However, the number of sales is higher. Customers are buying more scooters
--  than the pricier automobiles. 

-- Out of curiosity, let's look the annual totals and avg for June through December. 
SELECT EXTRACT (y FROM sales_transaction_date) AS sales_year,
       COUNT(sales_amount) AS total_sales_count,
       ROUND(SUM(sales_amount)::INTEGER,2) AS total_sales_sum,
	   ROUND(SUM(sales_amount)::INTEGER/COUNT(sales_amount),2) AS avg_sales_price
FROM sales
WHERE EXTRACT(mon FROM sales_transaction_date) > 5
GROUP BY sales_year
ORDER BY sales_year DESC;

-- Use the LAG function to find the total sales difference between years
WITH cte AS (
         SELECT EXTRACT (y FROM sales_transaction_date) AS sales_year,
         ROUND(SUM(sales_amount)::INTEGER,2) AS total_sales_sum
	     FROM sales
	     GROUP BY sales_year
	     ORDER BY sales_year DESC
), cte2 AS (
       SELECT sales_year,
	       total_sales_sum,
	       LAG(total_sales_sum,1) OVER (
	       ORDER BY sales_year) AS previous_sales
FROM cte
)
SELECT sales_year,
       total_sales_sum,
	   previous_sales,
	   (total_sales_sum - previous_sales) AS difference
FROM cte2
ORDER BY sales_year DESC;
-- So far sales from 2019 are much lower than those of 2015-2018. In 
--  regards to 2018, the 2019 sales are down about $50M. Keep in mind
--  that the 2019 sales numbers only include the first 5 months. 

-- Let's do the same total sales difference, but this time only evaluate
--  it based on the first 5 months from each year.
WITH cte AS (
         SELECT EXTRACT (y FROM sales_transaction_date) AS sales_year,
         ROUND(SUM(sales_amount)::INTEGER,2) AS total_sales_sum
	     FROM sales
	     WHERE EXTRACT(mon FROM sales_transaction_date) < 6
	     GROUP BY sales_year
	     ORDER BY sales_year DESC
), cte2 AS (
       SELECT sales_year,
	       total_sales_sum,
	       LAG(total_sales_sum,1) OVER (
	       ORDER BY sales_year) AS previous_sales
FROM cte
)
SELECT sales_year,
       total_sales_sum,
	   previous_sales,
	   (total_sales_sum - previous_sales) AS difference
FROM cte2
ORDER BY sales_year DESC;
-- By looking at just the first 5 months, sales for 2019 are about $4M
--  lower than 2018. That doesn't seem as bad as looking at it for the 
--  entire year. However, there does seem to be something going on in 2019
--  and that's will be for another time to investigate. 
