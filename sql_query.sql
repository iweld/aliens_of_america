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

SELECT
	state,
	count(*) AS alien_population_number,
	round(avg(age)) AS avg_alien_age
FROM alien_data
GROUP BY state
ORDER BY alien_population_number desc;

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
Tennessee           |                    934|          202|
Massachusetts       |                    767|          199|
Oklahoma            |                    756|          197|
Kentucky            |                    699|          204|
Connecticut         |                    697|          202|
Kansas              |                    676|          202|
Nevada              |                    660|          198|
Maryland            |                    598|          201|
Wisconsin           |                    579|          194|
South Carolina      |                    554|          197|
Iowa                |                    537|          198|
West Virginia       |                    484|          199|
New Jersey          |                    474|          208|
Utah                |                    435|          198|
Nebraska            |                    420|          208|
Oregon              |                    413|          203|
New Mexico          |                    309|          201|
Arkansas            |                    282|          200|
Mississippi         |                    282|          204|
Hawaii              |                    227|          198|
Idaho               |                    220|          211|
Alaska              |                    204|          203|
Delaware            |                    192|          195|
Montana             |                    144|          195|
South Dakota        |                    141|          195|
North Dakota        |                    109|          189|
New Hampshire       |                     92|          205|
Rhode Island        |                     53|          201|
Wyoming             |                     32|          218|
Maine               |                     32|          197|
Vermont             |                     30|          220|
        
