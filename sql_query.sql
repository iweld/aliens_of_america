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
-- Include the percentage of hostile vs. friendly aliens per state. 

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
	alien_population_number,
	avg_alien_age,
	round(((n_friendly_aliens::float / alien_population_number::float) * 100)::numeric, 2) AS friendly_alien_percentage,
	round(((n_hostile_aliens / alien_population_number::float) * 100)::numeric, 2) AS hostile_alien_percentage
from
	(SELECT
		ad.state,
		count(ad.*) AS alien_population_number,
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
	alien_population_number,
	avg_alien_age,
	n_hostile_aliens,
	n_friendly_aliens
ORDER BY alien_population_number DESC

-- Results:

state               |alien_population_number|avg_alien_age|
--------------------+-----------------------+-------------+
Texas               |                   5413|          200|
California          |                   5410|          202|
Florida             |                   4176|          199|
New York            |                   2690|          202|
Ohio                |                   1851|          199|
Virginia            |                   1749|          197|
District of Columbia|                   1661|          197|
Pennsylvania        |                   1590|          200|
Georgia             |                   1431|          196|
North Carolina      |                   1248|          201|
Illinois            |                   1223|          197|
Colorado            |                   1175|          203|
Arizona             |                   1122|          202|
Missouri            |                   1102|          198|
Minnesota           |                   1067|          202|
Alabama             |                   1066|          199|
Indiana             |                   1056|          203|
Michigan            |                   1016|          196|
Washington          |                    971|          202|
Louisiana           |                    951|          199|
        
