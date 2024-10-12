# Retail Sales Analysis SQL Project

## Project Overview

**Project Title**: Retail Sales Analysis  
**Level**: Beginner  
**Database**: `sql_project_p1`

This project is designed to demonstrate SQL skills and techniques typically used by data analysts to explore, clean, and analyze retail sales data. The project involves setting up a retail sales database, performing exploratory data analysis (EDA), and answering specific business questions through SQL queries. This project is ideal for those who are starting their journey in data analysis and want to build a solid foundation in SQL.

## Objectives

1. **Set up a retail sales database**: Create and populate a retail sales database with the provided sales data.
2. **Data Cleaning**: Identify and remove any records with missing or null values.
3. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.
4. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `sql_project_p1`.
- **Table Creation**: A table named `retail_sales` is created to store the sales data. The table structure includes columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount.

```sql
CREATE DATABASE p1_retail_db;

CREATE TABLE retail_sales
(
    transactions_id INT PRIMARY KEY,
    sale_date DATE,	
    sale_time TIME,
    customer_id INT,	
    gender VARCHAR(10),
    age INT,
    category VARCHAR(35),
    quantity INT,
    price_per_unit FLOAT,	
    cogs FLOAT,
    total_sale FLOAT
);
```

### 2. Data Exploration & Cleaning

- **Record Count**: Determine the total number of records in the dataset.
- **Customer Count**: Find out how many unique customers are in the dataset.
- **Category Count**: Identify all unique product categories in the dataset.
- **Null Value Check**: Check for any null values in the dataset and delete records with missing data.

```sql
SELECT COUNT(*) FROM retail_sales;
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;
SELECT DISTINCT category FROM retail_sales;

SELECT * FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;

DELETE FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;
```

### 3. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

1. **Write a SQL query to retrieve all columns for sales made on '2022-11-05**:
```sql

select * from retail_sales where sale_date = '2022-11-05';

```

2. **Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022**:
```sql

select * from retail_sales
where category = 'Clothing' and (sale_date) >= '2022-11-01' and sale_date < '2022-12-01'
and quantiy >= 4;

-- OR --

select * from retail_sales 
where category = 'Clothing' 
and to_char(sale_date,'yyyy-mm') = '2022-11' -- to_char used to convert date into char to search for nov-22
and quantiy >= 4;

```

3. **Write a SQL query to calculate the total sales (total_sale) for each category.**:
```sql

select category , sum(total_sale) "Total Sales" , count(total_sale) "Order" from retail_sales
group by 1;

```

4. **Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.**:
```sql

select category , round(avg(age),2) "Avg Age" from retail_sales
where category = 'Beauty';

```

5. **Write a SQL query to find all transactions where the total_sale is greater than 1000.**:
```sql

select * from retail_sales
where total_sale > 1000;

```

6. **Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.**:
```sql

select gender , category , count(*)
from retail_sales
group by 1,2;

```

7. **Write a SQL query to calculate the average sale for each month. Find out best selling month in each year**:
```sql

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

```

8. **Write a SQL query to find the top 5 customers based on the highest total sales **:
```sql

select customer_id , sum(total_sale) 
from retail_sales
group by 1
order by 2 desc
limit 5

```

9. **Write a SQL query to find the number of unique customers who purchased items from each category.**:
```sql

select category ,  count(distinct customer_id) "Unique Customer"
from retail_sales
group by 1;

```

10. **Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)**:
```sql

select 
(case when sale_time <= '12:00:00' then 'Morning' when sale_time between '12:00:01' and '17:00:00' then 'Afternoon' else 'Evening' end )"Shift" 
count (*) "No of Orders" 
from retail_sales
 group by 2; 
;

-- OR --

WITH hourly_sale
AS
(
SELECT *,
    CASE
        WHEN EXTRACT(HOUR FROM sale_time) <= 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END as shift
FROM retail_sales
)
SELECT 
    shift, 
     COUNT(*) as total_orders    
FROM hourly_sale
 GROUP BY shift

```


11. Find the total quantity sold and total sales for each category while showing the highest total sales first first.
```sql

select category , sum(quantiy)"Total Quantity Sold" , sum(total_sale) "Total Sales"
from retail_sales
group by 1
order by 3 desc;

```

12. find the percentage of total sales contributed by each gender.
```sql

select gender , count(*) "Total Sales Count" , avg(total_sale) , sum(total_sale) "Total Sales Generated" ,
    (SUM(total_sale) / (SELECT SUM(total_sale) FROM retail_sales) * 100) "percentage_of_total_sales"
from retail_sales
group by 1;

```
13. Identify the month with the highest total sales for each year.
```sql

with cte as 
(
select extract(year from sale_date) "year",
extract(month from sale_date) "month" , sum(total_sale) "Total Sales",
rank() over(partition by extract(year from sale_date) order by sum(total_sale) desc) as rnk
from retail_sales
group by 1,2
)
select * from cte
where rnk = 1
;

```
14. Retrieve the top-selling product category for each age group (e.g., 18-25, 26-35, etc.).

```sql

-- getting age group and category wise sales data here
 WITH AgeGroups AS (
    SELECT 
        CASE 
            WHEN age BETWEEN 17 AND 24 THEN '18-24'
            WHEN age BETWEEN 25 AND 34 THEN '25-34'
            WHEN age BETWEEN 35 AND 44 THEN '35-44'
            WHEN age BETWEEN 45 AND 54 THEN '45-54'
            WHEN age BETWEEN 55 AND 64 THEN '55-64' else '64+'
        END AS age_group,
        category,
        SUM(total_sale) AS total_sales
    FROM 
        retail_sales
    GROUP BY 
        age_group, category
),


-- setting up rank based on total sales done by each age group
RankedCategories AS (
    SELECT 
        age_group,
        category,
        total_sales,
        RANK() OVER (PARTITION BY age_group ORDER BY total_sales DESC) AS sales_rank
    FROM 
        AgeGroups
)

SELECT 
    age_group,
    category,
    total_sales , sales_rank
FROM 
    RankedCategories
WHERE 
    sales_rank = 1;

```

15. Find the average transaction value for each customer and identify the customer with the highest average transaction value.
```sql

with cte as 
(
select customer_id , avg(total_sale) "avg_txn"
from retail_sales
group by 1
)

select customer_id , avg_txn
from cte
order by 2 desc
limit 1;

```
## Findings

- **Customer Demographics**: The dataset includes customers from various age groups, with sales distributed across different categories such as Clothing and Beauty.
- **High-Value Transactions**: Several transactions had a total sale amount greater than 1000, indicating premium purchases.
- **Sales Trends**: Monthly analysis shows variations in sales, helping identify peak seasons.
- **Customer Insights**: The analysis identifies the top-spending customers and the most popular product categories.

## Reports

- **Sales Summary**: A detailed report summarizing total sales, customer demographics, and category performance.
- **Trend Analysis**: Insights into sales trends across different months and shifts.
- **Customer Insights**: Reports on top customers and unique customer counts per category.

## Conclusion

This project serves as a comprehensive introduction to SQL for data analysts, covering database setup, data cleaning, exploratory data analysis, and business-driven SQL queries. The findings from this project can help drive business decisions by understanding sales patterns, customer behavior, and product performance.


## Author - Nitin Singh

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!

### Stay Updated and Join the Community

For more content on SQL, data analysis, and other data-related topics, make sure to follow me on social media and join our community:


- **LinkedIn**: [Connect with me professionally](https://www.linkedin.com/in/nitin-a-singh/)

Thank you for your support, and I look forward to connecting with you!
