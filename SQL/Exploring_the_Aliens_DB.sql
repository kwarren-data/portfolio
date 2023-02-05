-- Let's do some exploratory data analysis on the tables.
-- First is the aliens table. How many different genders 
-- are there and how many aliens are in each?
SELECT gender, COUNT( gender)
FROM aliens
GROUP BY gender;

-- What are the alien types and how many of each are there?
SELECT alien_type, 
       COUNT(alien_type)
FROM aliens
GROUP BY alien_type
ORDER BY 2 DESC;

-- Any NULL values?
SELECT *
FROM aliens
WHERE NOT (aliens IS NOT NULL);

-- Check the loc table
-- How many distinct current_location values are there?
SELECT current_location, 
       COUNT(current_location)
FROM loc
GROUP BY current_location
ORDER BY 2 DESC;

-- How many states are represented and how many aliens are location in each?
SELECT state, 
       COUNT(state)
FROM loc
GROUP BY state
ORDER BY 2 DESC;

-- Now by country. It should only be one, but we'll check
SELECT country, 
       COUNT(country)
FROM loc
GROUP BY country
ORDER BY 2 DESC;

-- Finally, what about the occupation of the aliens
SELECT occupation, 
       COUNT(occupation)
FROM loc
GROUP BY occupation
ORDER BY 2 DESC;

-- Let's look at the details table
-- First up is favorite food
SELECT fav_food, 
       COUNT(fav_food)
FROM details
GROUP BY fav_food
ORDER BY 2 DESC;

-- Feeding frequency?
SELECT feeding_freq, 
       COUNT(feeding_freq)
FROM details
GROUP BY feeding_freq
ORDER BY 2 DESC;

-- How many are aggressive?
SELECT aggressive, 
       COUNT(aggressive)
FROM details
GROUP BY aggressive
ORDER BY 2 DESC;

--After getting a little more familiar with the data,
-- let's start some joins and answer a few questions regarding the aliens.

--First how aggressive are each type of alien? 
-- Join the aliens and details tables to answer the question.
SELECT a.alien_type, 
       d.aggressive, 
	   COUNT(d.aggressive)
FROM aliens AS a
INNER JOIN details AS d 
  ON a.id = d.detail_id
GROUP BY a.alien_type, 
         d.aggressive
ORDER BY 2,3 DESC;

--Which gender, if any, has the most number of aggressive individuals?
SELECT a.gender, 
       COUNT(d.aggressive) AS aggressive_count
FROM aliens AS a
INNER JOIN details AS d 
  ON a.id = d.detail_id
GROUP BY a.gender, 
         d.aggressive
HAVING d.aggressive='True'
ORDER BY 2 DESC;

-- Now, what about aggressiveness percentage-wise? .
SELECT gender, 
       total_count, 
	   agg_count, 
	   non_agg_count,
       ROUND((agg_count*100.0)/total_count,2) AS agg_percentage
FROM (
	SELECT a.gender, 
	       COUNT(a.gender) 
	       AS total_count,
           SUM(CASE WHEN d.aggressive='True' THEN 1 ELSE 0 END) AS agg_count,
           SUM(CASE WHEN d.aggressive='False' THEN 1 ELSE 0 END) AS non_agg_count
    FROM aliens AS a
    INNER JOIN details AS d 
      ON a.id = d.detail_id
    GROUP BY a.gender
) AS gen
ORDER BY 5 DESC;

--Which states have the most aliens?
SELECT state, 
       COUNT(loc_id)
FROM loc
GROUP BY state
ORDER BY 2 DESC
LIMIT 10;

-- For Florida aliens, what are their occupations?
SELECT occupation, 
       COUNT(occupation)
FROM loc
WHERE state='Florida'
GROUP BY occupation
ORDER BY 2 DESC;

-- Aggressive counts by occupation in Florida aliens
SELECT occupation, 
       total_count, 
	   agg_count,non_agg_count,
       ROUND((agg_count*100.0)/total_count,2) AS agg_percentage
FROM (
  SELECT l.occupation, 
	     COUNT(l.occupation) AS total_count,
         SUM(CASE WHEN d.aggressive='True' THEN 1 ELSE 0 END) AS agg_count,
         SUM(CASE WHEN d.aggressive='False' THEN 1 ELSE 0 END) AS non_agg_count
  FROM loc AS l
  INNER JOIN details AS d
    ON l.loc_id = d.detail_id
  WHERE l.state='Florida'
  GROUP BY l.occupation
) AS o
ORDER BY 5 DESC;

-- Aggressiveness by state
SELECT state, 
       total_count, 
	   agg_count, 
	   non_agg_count,
       ROUND((agg_count*100.0)/total_count,2) AS agg_percentage
FROM (
  SELECT l.state, 
	     COUNT(l.state) AS total_count,
         SUM(CASE WHEN d.aggressive='True' THEN 1 ELSE 0 END) AS agg_count,
         SUM(CASE WHEN d.aggressive='False' THEN 1 ELSE 0 END) AS non_agg_count
  FROM loc as l
  INNER JOIN details AS d
    ON l.loc_id = d.detail_id
  GROUP BY l.state
) AS st
ORDER BY 5 DESC;

