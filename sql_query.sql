/* 
 * Aliens in America
 * Case Study Questions by Jaime M. Shaker jaime.m.shaker@gmail.com
 *   

For this project, you play a role as a newly hired Data Analyst for a pharmaceutical company.

It's the year 2022 and aliens are well known to be living amongst us.

Unfortunately, some of the aliens are a bit... too alien... and would like to fit into society a bit more.

So it's up to you to find the best state(s) we should market our new prescription.

It would be helpful to know...

If these aliens are hostile
Their diet
Their age
It's up to you to clean up the data and report back.

*/

SELECT * FROM aliens limit 5;

-- Results:

id|first_name|last_name |email                  |gender     |type     |birth_year|
--+----------+----------+-----------------------+-----------+---------+----------+
 1|Tyrus     |Wrey      |twrey0@sakura.ne.jp    |Agender    |Reptile  |      1717|
 2|Ealasaid  |St Louis  |estlouis1@amazon.co.uk |Female     |Flatwoods|      1673|
 3|Violette  |Sawood    |vsawood2@yolasite.com  |Female     |Nordic   |      1675|
 4|Rowan     |Saintsbury|rsaintsbury3@rediff.com|Male       |Green    |      1731|
 5|Free      |Ingolotti |fingolotti4@bbb.org    |Genderfluid|Flatwoods|      1763|

SELECT * FROM details limit 5;

-- Results:

detail_id|favorite_food            |feeding_frequency|aggressive|
---------+-------------------------+-----------------+----------+
        1|White-faced tree rat     |Weekly           |true      |
        2|Lizard, goanna           |Seldom           |false     |
        3|Indian red admiral       |Weekly           |true      |
        4|Bandicoot, southern brown|Often            |false     |
        5|Kangaroo, red            |Once             |false     |
        
SELECT * FROM location limit 5;

-- Results:

loc_id|current_location|state     |country      |occupation            |
------+----------------+----------+-------------+----------------------+
     1|Cincinnati      |Ohio      |United States|Senior Cost Accountant|
     2|Bethesda        |Maryland  |United States|Senior Sales Associate|
     3|Oakland         |California|United States|Registered Nurse      |
     4|Richmond        |Virginia  |United States|Director of Sales     |
     5|Atlanta         |Georgia   |United States|Administrative Officer|

-- Create a temp table and join all the data

DROP TABLE IF EXISTS alien_data;
CREATE TEMP TABLE alien_data as (
	SELECT
		a.id,
		a.first_name,
		a.last_name,
		a.email,
		a.gender,
		a.TYPE,
		a.birth_year,
		(2022 - a.birth_year) AS age,
		d.favorite_food,
		d.feeding_frequency,
		d.aggressive,
		l.occupation,
		l.current_location,
		l.state,
		l.country
	FROM aliens AS a
	JOIN details AS d ON a.id = d.detail_id
	JOIN LOCATION AS l ON a.id = l.loc_id
);

SELECT * FROM alien_data WHERE id = 1;

-- Results:

id|first_name|last_name|email              |gender |type   |birth_year|age|favorite_food       |feeding_frequency|aggressive|occupation            |current_location|state|country      |
--+----------+---------+-------------------+-------+-------+----------+---+--------------------+-----------------+----------+----------------------+----------------+-----+-------------+
 1|Tyrus     |Wrey     |twrey0@sakura.ne.jp|Agender|Reptile|      1717|305|White-faced tree rat|Weekly           |true      |Senior Cost Accountant|Cincinnati      |Ohio |United States|
 
-- What is the count of records?
 
SELECT count(*) AS n_records FROM alien_data;

-- Results:

n_records|
---------+
    50000|
    
-- Are there any duplicate email addresses which could indicate duplicate records?
    
SELECT
	email,
	count(*)
FROM alien_data
GROUP BY email
HAVING count(*) > 1;

-- Results:

email|count|
-----+-----+

-- How many countrys are represented in out dataset?

SELECT 
	country AS countries
FROM alien_data
GROUP BY country;

-- Results:

countries    |
-------------+
United States|

-- Are all states represented in the dataset?

SELECT 
	count(DISTINCT state) AS number_of_states
FROM alien_data;

-- Results:

number_of_states|
----------------+
              51|
              
-- All 50 states are represented and the District of Columbia           

-- What is the count of aliens per state and what is the average age?   Order from highest to lowest population.
-- Include the percentage of hostile vs. friendly aliens per state.  Limit the forst 10 for brevity.

WITH alien_aggression AS (
	SELECT
		state,
		sum(
			CASE
				WHEN aggressive = TRUE THEN 1
				ELSE 0
			END 
		) AS n_hostile_aliens,
		sum(
			CASE
				WHEN aggressive = false THEN 1
				ELSE 0
			END 
		) AS n_friendly_aliens
	FROM alien_data
	GROUP BY state
)              

SELECT
	state,
	alien_population_total,
	avg_alien_age,
	round(((n_friendly_aliens::float / alien_population_total::float) * 100)::numeric, 2) AS friendly_alien_percentage,
	round(((n_hostile_aliens::float / alien_population_total::float) * 100)::numeric, 2) AS hostile_alien_percentage
from
	(SELECT
		ad.state,
		count(ad.*) AS alien_population_total,
		round(avg(ad.age)) AS avg_alien_age,
		aa.n_friendly_aliens,
		aa.n_hostile_aliens
	FROM alien_data AS ad
	JOIN alien_aggression AS aa
	ON ad.state = aa.state
	GROUP BY 
		ad.state,
		aa.n_hostile_aliens,
		aa.n_friendly_aliens) AS tmp
GROUP BY 
	state,
	alien_population_total,
	avg_alien_age,
	n_hostile_aliens,
	n_friendly_aliens
ORDER BY alien_population_total DESC
LIMIT 10;

-- Results:

state               |alien_population_total|avg_alien_age|friendly_alien_percentage|hostile_alien_percentage|
--------------------+----------------------+-------------+-------------------------+------------------------+
Texas               |                  5413|          200|                    49.53|                   50.47|
California          |                  5410|          202|                    50.15|                   49.85|
Florida             |                  4176|          199|                    50.36|                   49.64|
New York            |                  2690|          202|                    50.56|                   49.44|
Ohio                |                  1851|          199|                    49.43|                   50.57|
Virginia            |                  1749|          197|                    51.80|                   48.20|
District of Columbia|                  1661|          197|                    48.77|                   51.23|
Pennsylvania        |                  1590|          200|                    51.38|                   48.62|
Georgia             |                  1431|          196|                    51.99|                   48.01|
North Carolina      |                  1248|          201|                    50.72|                   49.28|


-- The Bureau of Economic Analysis goes with an eight-region map of the US.  What regions have the highest population of aliens and what
-- is the overall population percentage per region?

SELECT
	us_region,
	alien_regional_population,
	round(((alien_regional_population::float / sum(sum(alien_regional_population)) OVER ()) * 100)::numeric, 2) AS regional_population_percentage
from
	(SELECT
		CASE
			WHEN lower(ad.state) IN ('maine', 'new hampshire', 'massachusetts', 'connecticut', 'vermont', 'rhode island') then 'New England'
			WHEN lower(ad.state) IN ('alabama', 'arkansas', 'florida', 'georgia', 'kentucky', 'louisiana', 'mississippi', 'north carolina', 'south carolina', 'tennessee', 'virginia', 'west virginia') then 'Southeast'
			WHEN lower(ad.state) IN ('wisconsin', 'ohio', 'indiana', 'illinois', 'michigan') then 'Great Lakes'
			WHEN lower(ad.state) IN ('new mexico', 'arizona', 'texas', 'oklahoma') then 'Southwest'
			WHEN lower(ad.state) IN ('north dakota', 'south dakota', 'kansas', 'iowa', 'nebraska', 'missouri', 'minnesota') then 'Plains'
			WHEN lower(ad.state) IN ('colorado', 'utah', 'idaho', 'montana', 'wyoming') then 'Rocky Mountain'
			WHEN lower(ad.state) IN ('new york', 'new jersey', 'pennsylvania', 'delaware', 'maryland', 'district of columbia') then 'Mideast'
			WHEN lower(ad.state) IN ('california', 'alaska', 'nevada', 'oregon', 'washington', 'hawaii') then 'Far West'
		END AS us_region,
		count(ad.*) AS alien_regional_population
	FROM alien_data AS ad
	GROUP BY 
		us_region
	ORDER BY alien_regional_population DESC) AS tmp
GROUP BY 
	us_region,
	alien_regional_population
ORDER BY regional_population_percentage DESC

-- Results:

us_region     |alien_regional_population|regional_population_percentage|
--------------+-------------------------+------------------------------+
Southeast     |                    13856|                         27.71|
Far West      |                     7885|                         15.77|
Southwest     |                     7600|                         15.20|
Mideast       |                     7205|                         14.41|
Great Lakes   |                     5725|                         11.45|
Plains        |                     4052|                          8.10|
Rocky Mountain|                     2006|                          4.01|
New England   |                     1671|                          3.34|

-- What is the alien population and gender percentage per region?  Rank results according to gender percentage results  
-- Limit the first 20 for brevity. jaime.m.shaker@gmail.com

SELECT
	us_region,
	gender,
	regional_gender_population,
	round(((regional_gender_population::float / sum(sum(regional_gender_population)) OVER (PARTITION BY us_region)) * 100)::numeric, 2) AS gender_population_percentage,
	rank() OVER (PARTITION BY us_region ORDER BY regional_gender_population desc) AS ranking
from
	(SELECT
		CASE
			WHEN lower(ad.state) IN ('maine', 'new hampshire', 'massachusetts', 'connecticut', 'vermont', 'rhode island') then 'New England'
			WHEN lower(ad.state) IN ('alabama', 'arkansas', 'florida', 'georgia', 'kentucky', 'louisiana', 'mississippi', 'north carolina', 'south carolina', 'tennessee', 'virginia', 'west virginia') then 'Southeast'
			WHEN lower(ad.state) IN ('wisconsin', 'ohio', 'indiana', 'illinois', 'michigan') then 'Great Lakes'
			WHEN lower(ad.state) IN ('new mexico', 'arizona', 'texas', 'oklahoma') then 'Southwest'
			WHEN lower(ad.state) IN ('north dakota', 'south dakota', 'kansas', 'iowa', 'nebraska', 'missouri', 'minnesota') then 'Plains'
			WHEN lower(ad.state) IN ('colorado', 'utah', 'idaho', 'montana', 'wyoming') then 'Rocky Mountain'
			WHEN lower(ad.state) IN ('new york', 'new jersey', 'pennsylvania', 'delaware', 'maryland', 'district of columbia') then 'Mideast'
			WHEN lower(ad.state) IN ('california', 'alaska', 'nevada', 'oregon', 'washington', 'hawaii') then 'Far West'
		END AS us_region,
		ad.gender,
		count(ad.*) AS regional_gender_population
	FROM alien_data AS ad
	GROUP BY 
		us_region,
		ad.gender
	ORDER BY regional_gender_population DESC) AS tmp
GROUP BY 
	us_region,
	gender,
	regional_gender_population
ORDER BY us_region, gender_population_percentage DESC
LIMIT 20;

-- Results:

us_region  |gender     |regional_gender_population|gender_population_percentage|ranking|
-----------+-----------+--------------------------+----------------------------+-------+
Far West   |Female     |                      3540|                       44.90|      1|
Far West   |Male       |                      3526|                       44.72|      2|
Far West   |Non-binary |                       146|                        1.85|      3|
Far West   |Bigender   |                       145|                        1.84|      4|
Far West   |Agender    |                       144|                        1.83|      5|
Far West   |Genderfluid|                       135|                        1.71|      6|
Far West   |Polygender |                       127|                        1.61|      7|
Far West   |Genderqueer|                       122|                        1.55|      8|
Great Lakes|Female     |                      2615|                       45.68|      1|
Great Lakes|Male       |                      2531|                       44.21|      2|
Great Lakes|Non-binary |                       106|                        1.85|      3|
Great Lakes|Polygender |                       104|                        1.82|      4|
Great Lakes|Agender    |                       103|                        1.80|      5|
Great Lakes|Bigender   |                        99|                        1.73|      6|
Great Lakes|Genderqueer|                        95|                        1.66|      7|
Great Lakes|Genderfluid|                        72|                        1.26|      8|
Mideast    |Female     |                      3251|                       45.12|      1|
Mideast    |Male       |                      3229|                       44.82|      2|
Mideast    |Genderfluid|                       144|                        2.00|      3|
Mideast    |Non-binary |                       126|                        1.75|      4|



























