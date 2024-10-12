-- SQL Retail Sales Analysis - P1

-- Creating Table --

Create Table retail_sales
			(
				transactions_id INT,
				sale_date DATE,
				sale_time TIME,
				customer_id INT,
				gender VARCHAR(15),
				age INT,
				category VARCHAR(15),
				quantiy INT,
				price_per_unit FLOAT,
				cogs FLOAT,
				total_sale FLOAT
			);

 -- CHECKING FOR NULL VALUES

SELECT * FROM retail_sales
WHERE 
transactions_id IS NULL OR
sale_date IS NULL OR	
sale_time	IS NULL OR 
customer_id IS NULL OR
gender IS NULL  OR	category IS NULL OR	quantiy	IS NULL OR price_per_unit IS NULL OR
cogs IS NULL OR	total_sale IS NULL
;

 -- DELETING NULL VALUES
 
DELETE FROM retail_sales
WHERE 
transactions_id IS NULL OR
sale_date IS NULL OR	
sale_time	IS NULL OR 
customer_id IS NULL OR
gender IS NULL  OR	category IS NULL OR	quantiy	IS NULL OR price_per_unit IS NULL OR
cogs IS NULL OR	total_sale IS NULL ;

SELECT * FROM retail_sales;

-- Data Exploration 

-- how many sales we have 

select count(*)"Total Sales"
from retail_sales;
	
-- how many unique customers we have 

select count(DIStinct customer_id)"Total unique customers"
from retail_sales;

-- total unique categories 

select DISTINCT category"Total unique categories"
from retail_sales;


------------------------------------------------------------------------------------------------------------------------

 -- // Data Analysis and Business Key Problems // --

-- My Analysis & Findings
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05

select * from retail_sales where sale_date = '2022-11-05';


-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022

select * from retail_sales where category = 'Clothing' and (sale_date) >= '2022-11-01' and sale_date < '2022-12-01' and quantiy >= 4;

select * from retail_sales 
where category = 'Clothing' 
and to_char(sale_date,'yyyy-mm') = '2022-11' -- to_char used to convert date into char to search for nov-22
and quantiy >= 4;



-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.

select category , sum(total_sale) "Total Sales" , count(total_sale) "Order" from retail_sales
group by 1;

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.

select category , round(avg(age),2) "Avg Age" from retail_sales
where category = 'Beauty'
group by 1;

-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.

select * from retail_sales
where total_sale > 1000;

-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.

select gender , category , count(*)
from retail_sales
group by 1,2;

-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year

SELECT year , month , avg_sales
FROM
(
SELECT  
 EXTRACT(YEAR FROM sale_date)  as "year" , EXTRACT(MONTH FROM sale_date) as "month" , AVG(total_sale) as "avg_sales" ,
 RANK() OVER(PARTITION BY EXTRACT(YEAR from sale_date) ORDER BY AVG(total_sale) DESC ) as rnk
 FROM retail_sales
 group by 1,2
) as t
where rnk = 1
;


SELECT year, month, avg_sales
FROM
(
  SELECT  
    EXTRACT(YEAR FROM sale_date) AS "year", 
    EXTRACT(MONTH FROM sale_date) AS "month", 
    AVG(total_sale) AS "avg_sales", 
    RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) AS rnk
  FROM retail_sales
  GROUP BY 1, 2
) AS t
WHERE rnk = 1;


-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 

select customer_id , sum(total_sale) 
from retail_sales
group by 1
order by 2 desc
limit 5
;

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.

select category ,  count(distinct customer_id) "Unique Customer"
from retail_sales
group by 1;

-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)

select count(*), (case when sale_time <= '12:00:00' then 'Morning' when sale_time between '12:00:01' and '17:00:00' then 'Afternoon' else 'Evening' end )"Shift" 
-- count (*) "No of Orders" 
from retail_sales
 group by 2; 
;


WITH hourly_sale
AS
(
SELECT *, extract(hour from sale_time) "Hours" ,
    CASE
        WHEN EXTRACT(HOUR FROM sale_time) <= 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END as shift
FROM retail_sales
)
SELECT 
    shift, 
     *
FROM hourly_sale
 -- GROUP BY shift

