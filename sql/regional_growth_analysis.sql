-- Task 30: Regional Growth Analysis
CREATE DATABASE IF NOT EXISTS regional_growth;
USE regional_growth;

DROP TABLE IF EXISTS regional_sales;

CREATE TABLE regional_sales (
    year INT,
    region VARCHAR(30),
    sales DECIMAL(14,2)
);

INSERT INTO regional_sales (year, region, sales) VALUES
(2019,'Central',210000),(2020,'Central',225000),(2021,'Central',255000),(2022,'Central',290000),
(2019,'East',280000),(2020,'East',295000),(2021,'East',340000),(2022,'East',370000),
(2019,'South',150000),(2020,'South',165000),(2021,'South',190000),(2022,'South',215000),
(2019,'West',180000),(2020,'West',210000),(2021,'West',250000),(2022,'West',290000);

-- Year-over-year growth
WITH growth AS (
    SELECT year, region, sales,
           LAG(sales) OVER (PARTITION BY region ORDER BY year) AS previous_year_sales
    FROM regional_sales
)
SELECT year, region, sales, previous_year_sales,
       ROUND((sales-previous_year_sales)/previous_year_sales*100,2) AS yoy_growth_pct
FROM growth
ORDER BY region, year;

-- Total growth by region
SELECT region,
       MIN(CASE WHEN year=2019 THEN sales END) AS start_sales,
       MAX(CASE WHEN year=2022 THEN sales END) AS end_sales,
       ROUND(
         (MAX(CASE WHEN year=2022 THEN sales END) -
          MIN(CASE WHEN year=2019 THEN sales END))
         / MIN(CASE WHEN year=2019 THEN sales END) * 100, 2
       ) AS total_growth_pct
FROM regional_sales
GROUP BY region
ORDER BY total_growth_pct DESC;

-- Rank regions by total growth
WITH summary AS (
    SELECT region,
           MIN(CASE WHEN year=2019 THEN sales END) AS start_sales,
           MAX(CASE WHEN year=2022 THEN sales END) AS end_sales
    FROM regional_sales
    GROUP BY region
)
SELECT region, start_sales, end_sales,
       ROUND((end_sales-start_sales)/start_sales*100,2) AS total_growth_pct,
       DENSE_RANK() OVER (ORDER BY (end_sales-start_sales)/start_sales DESC) AS growth_rank
FROM summary
ORDER BY growth_rank;
