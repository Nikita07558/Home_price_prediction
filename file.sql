

-- 1. Average price of all properties
SELECT AVG(price) AS avg_price FROM housing_data;

-- 2. Price per square foot calculation
SELECT price, total_sqft, ROUND(price / total_sqft, 2) AS price_per_sqft
FROM housing_data;

-- 3. Most expensive property
SELECT * FROM housing_data
ORDER BY price DESC
LIMIT 1;

-- 4. Total properties in '1st Block Jayanagar'
SELECT COUNT(*) AS count_jayanagar
FROM housing_data
WHERE `1st Block Jayanagar` = 1;

-- 5. Average price by BHK
SELECT bhk, AVG(price) AS avg_price
FROM housing_data
GROUP BY bhk
ORDER BY bhk;

-- 6. Properties with high price per sqft (outliers)
SELECT *, ROUND(price / total_sqft, 2) AS price_per_sqft
FROM housing_data
WHERE price / total_sqft > 20;

-- 7. Compare average prices in two areas
SELECT 
  '1st Phase JP Nagar' AS location, AVG(price) AS avg_price
FROM housing_data
WHERE `1st Phase JP Nagar` = 1
UNION
SELECT 
  '2nd Phase JP Nagar', AVG(price)
FROM housing_data
WHERE `2nd Phase JP Nagar` = 1;

-- 8. Categorize price into Low, Mid, High
SELECT *,
  CASE 
    WHEN price < 50 THEN 'Low'
    WHEN price BETWEEN 50 AND 150 THEN 'Mid'
    ELSE 'High'
  END AS price_category
FROM housing_data;

-- 9. Top 3 most expensive properties for each BHK
WITH ranked_props AS (
  SELECT *,
         RANK() OVER (PARTITION BY bhk ORDER BY price DESC) AS rank
  FROM housing_data
)
SELECT * FROM ranked_props
WHERE rank <= 3;

-- 10. Properties with above-average price in 5th Phase JP Nagar
WITH area_avg AS (
  SELECT AVG(price) AS avg_price
  FROM housing_data
  WHERE `5th Phase JP Nagar` = 1
)
SELECT *
FROM housing_data, area_avg
WHERE `5th Phase JP Nagar` = 1 AND price > avg_price;

-- 11. BHK configuration distribution in '2nd Stage Nagarbhavi'
SELECT bhk, COUNT(*) AS count
FROM housing_data
WHERE `2nd Stage Nagarbhavi` = 1
GROUP BY bhk
ORDER BY count DESC;

-- 12. Price per sqft deviation from BHK average
WITH bhk_avg AS (
  SELECT bhk, AVG(price / total_sqft) AS avg_pps
  FROM housing_data
  GROUP BY bhk
)
SELECT h.*, ROUND(h.price / h.total_sqft, 2) AS actual_pps, ROUND(b.avg_pps, 2) AS expected_pps
FROM housing_data h
JOIN bhk_avg b ON h.bhk = b.bhk
WHERE (h.price / h.total_sqft) > b.avg_pps + 10;

-- 13. Locations with more than 50 listings (sample)
SELECT '1st Phase JP Nagar' AS location, COUNT(*) AS total
FROM housing_data
WHERE `1st Phase JP Nagar` = 1
HAVING COUNT(*) > 50
UNION
SELECT 'Vishwapriya Layout', COUNT(*) FROM housing_data WHERE `Vishwapriya Layout` = 1 HAVING COUNT(*) > 50
UNION
SELECT 'Vittasandra', COUNT(*) FROM housing_data WHERE `Vittasandra` = 1 HAVING COUNT(*) > 50;

