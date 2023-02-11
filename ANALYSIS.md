# Aliens in America
## Case Study Questions and Answers

**Author**: Jaime M. Shaker

**Email**: jaime.m.shaker@gmail.com

**Website**: https://www.shaker.dev

**LinkedIn**: https://www.linkedin.com/in/jaime-shaker/

## A. Create tables and insert data.
````sql
DROP TABLE IF EXISTS aliens;
CREATE TABLE aliens (
	id int, 
	first_name varchar(100),
	last_name varchar(100),
	email varchar(250),
	gender varchar(50),
	type varchar(50), 
	birth_year int, 
	PRIMARY KEY (id));

DROP TABLE IF EXISTS details;
CREATE TABLE details (
	detail_id int, 
	favorite_food VARCHAR(250),
	feeding_frequency VARCHAR(50), 
	aggressive bool,
	PRIMARY KEY (detail_id));

DROP TABLE IF EXISTS location;
CREATE TABLE location (
	loc_id int, 
	current_location varchar(100),
	state varchar(50),
	country varchar(150),
	occupation varchar(250),
	PRIMARY KEY (loc_id));
	
-- Copy and insert data from csv files to tables.

COPY aliens (
	id, 
	first_name,
	last_name,
	email,
	gender,
	type, 
	birth_year)
FROM 'csv\aliens.csv'
DELIMITER ',' CSV HEADER;

COPY details (
	detail_id, 
	favorite_food,
	feeding_frequency, 
	aggressive)
FROM 'csv\details.csv'
DELIMITER ',' CSV HEADER;

COPY location (
	loc_id, 
	current_location,
	state,
	country,
	occupation)
FROM 'csv\location.csv'
DELIMITER ',' CSV HEADER;
````
### Create Temp Table, clean  and join data.

````sql
-- Create a temp table and join all the data

DROP TABLE IF EXISTS alien_data;
CREATE TEMP TABLE alien_data as (
	SELECT
		a.id,
		lower(a.first_name) AS first_name,
		lower(a.last_name) AS last_name,
		a.email,
		CASE
			WHEN lower(a.gender) <> 'female' OR lower(a.gender) <> 'male' THEN 'non-binary'
			ELSE lower(a.gender)
		END AS gender,
		lower(a.TYPE),
		a.birth_year,
		(extract(YEAR FROM now()) - a.birth_year)::int AS age,
		lower(d.favorite_food) AS favorite_food,
		lower(d.feeding_frequency) AS feeding_frequency,
		d.aggressive,
		lower(l.occupation) AS occupation,
		lower(l.current_location) AS current_location,
		lower(l.state) AS state,
		CASE
			WHEN lower(l.state) IN ('maine', 'new hampshire', 'massachusetts', 'connecticut', 'vermont', 'rhode island') then 'new england'
			WHEN lower(l.state) IN ('alabama', 'arkansas', 'florida', 'georgia', 'kentucky', 'louisiana', 'mississippi', 'north carolina', 'south carolina', 'tennessee', 'virginia', 'west virginia') then 'southeast'
			WHEN lower(l.state) IN ('wisconsin', 'ohio', 'indiana', 'illinois', 'michigan') then 'great lakes'
			WHEN lower(l.state) IN ('new mexico', 'arizona', 'texas', 'oklahoma') then 'southwest'
			WHEN lower(l.state) IN ('north dakota', 'south dakota', 'kansas', 'iowa', 'nebraska', 'missouri', 'minnesota') then 'plains'
			WHEN lower(l.state) IN ('colorado', 'utah', 'idaho', 'montana', 'wyoming') then 'rocky mountain'
			WHEN lower(l.state) IN ('new york', 'new jersey', 'pennsylvania', 'delaware', 'maryland', 'district of columbia') then 'mideast'
			WHEN lower(l.state) IN ('california', 'alaska', 'nevada', 'oregon', 'washington', 'hawaii') then 'far west'
		END AS us_region,
		lower(l.country) AS country
	FROM aliens AS a
	JOIN details AS d ON a.id = d.detail_id
	JOIN location AS l ON a.id = l.loc_id
);

SELECT * FROM alien_data WHERE id = 1;
````
**Results**

id|first_name|last_name|email              |gender    |lower  |birth_year|age|favorite_food       |feeding_frequency|aggressive|occupation            |current_location|state|us_region  |country      |
--|----------|---------|-------------------|----------|-------|----------|---|--------------------|-----------------|----------|----------------------|----------------|-----|-----------|-------------|
 1|tyrus     |wrey     |twrey0@sakura.ne.jp|non-binary|reptile|      1717|305|white-faced tree rat|weekly           |true      |senior cost accountant|cincinnati      |ohio |great lakes|united states|
 
 ### How many records are in the dataset?
 
 **Results**
 
n_records|
--|
 50000|
 
### Are there any duplicate email addresses which could indicate duplicate records?

````sql
SELECT
	email,
	count(*)
FROM alien_data
GROUP BY email
HAVING count(*) > 1;
````

** Results ** 

email|count|
-----|-----|
 
❗ **Note**
* No records were returned

### How many countrys are present in our dataset?

````sql
SELECT 
	country AS countries
FROM alien_data
GROUP BY country;
````

**Results**

countries    |
-------------|
united states|

### Are all states represented in the dataset?

```sql
SELECT 
	count(DISTINCT state) AS number_of_states
FROM alien_data;
```

**Results**

number_of_states|
----------------|
51|

❗ **Note**
* All 50 states are represented and the District of Columbia

### What is the count of aliens per state and what is the average age?   Order from highest to lowest population.  Include the percentage of hostile vs. friendly aliens per state.  Limit the first 10 for brevity.

````sql
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
````

**Results**

state               |alien_population_total|avg_alien_age|friendly_alien_percentage|hostile_alien_percentage|
--------------------|----------------------|-------------|-------------------------|------------------------|
texas               |                  5413|          200|                    49.53|                   50.47|
california          |                  5410|          202|                    50.15|                   49.85|
florida             |                  4176|          199|                    50.36|                   49.64|
new york            |                  2690|          202|                    50.56|                   49.44|
ohio                |                  1851|          199|                    49.43|                   50.57|
virginia            |                  1749|          197|                    51.80|                   48.20|
district of columbia|                  1661|          197|                    48.77|                   51.23|
pennsylvania        |                  1590|          200|                    51.38|                   48.62|
georgia             |                  1431|          196|                    51.99|                   48.01|
north carolina      |                  1248|          201|                    50.72|                   49.28|

### What are the yougest and oldest alien ages in the U.S.?

````sql
SELECT
	max(age) AS oldest_age,
	min(age) AS youngest_age
FROM alien_data
````

**Results**

oldest_age|youngest_age|
----------|------------|
350|          50|

### The U.S. Bureau of Economic Analysis developed an eight-region map of the US seen below.  
![alt text](https://github.com/iweld/aliens_of_america/blob/main/images/bea_us_regions.JPG)

### What regions have the highest population of aliens and what is the overall population percentage per region?

````sql
SELECT
	us_region,
	alien_regional_population,
	round(((alien_regional_population::float / sum(sum(alien_regional_population)) OVER ()) * 100)::numeric, 2) AS regional_population_percentage
from
	(SELECT
		ad.us_region,
		count(ad.*) AS alien_regional_population
	FROM alien_data AS ad
	GROUP BY 
		ad.us_region
	ORDER BY alien_regional_population DESC) AS tmp
GROUP BY 
	us_region,
	alien_regional_population
ORDER BY regional_population_percentage DESC
````

**Results**

us_region     |alien_regional_population|regional_population_percentage|
--------------|-------------------------|------------------------------|
southeast     |                    13856|                         27.71|
far west      |                     7885|                         15.77|
southwest     |                     7600|                         15.20|
mideast       |                     7205|                         14.41|
great lakes   |                     5725|                         11.45|
plains        |                     4052|                          8.10|
rocky mountain|                     2006|                          4.01|
new england   |                     1671|                          3.34|

### What is the alien population and gender percentage per region?  Rank results according to gender percentage results.

````sql
SELECT
	us_region,
	gender,
	regional_gender_population,
	round(((regional_gender_population::float / sum(sum(regional_gender_population)) OVER (PARTITION BY us_region)) * 100)::numeric, 2) AS gender_population_percentage,
	rank() OVER (PARTITION BY us_region ORDER BY regional_gender_population desc) AS ranking
from
	(SELECT
		ad.us_region,
		ad.gender,
		count(ad.*) AS regional_gender_population
	FROM alien_data AS ad
	GROUP BY 
		ad.us_region,
		ad.gender
	ORDER BY regional_gender_population DESC) AS tmp
GROUP BY 
	us_region,
	gender,
	regional_gender_population
ORDER BY us_region, gender_population_percentage DESC;
````

**Results**

us_region     |gender    |regional_gender_population|gender_population_percentage|ranking|
--------------|----------|--------------------------|----------------------------|-------|
far west      |female    |                      3540|                       44.90|      1|
far west      |male      |                      3526|                       44.72|      2|
far west      |non-binary|                       819|                       10.39|      3|
great lakes   |female    |                      2615|                       45.68|      1|
great lakes   |male      |                      2531|                       44.21|      2|
great lakes   |non-binary|                       579|                       10.11|      3|
mideast       |female    |                      3251|                       45.12|      1|
mideast       |male      |                      3229|                       44.82|      2|
mideast       |non-binary|                       725|                       10.06|      3|
new england   |female    |                       791|                       47.34|      1|
new england   |male      |                       716|                       42.85|      2|
new england   |non-binary|                       164|                        9.81|      3|
plains        |male      |                      1849|                       45.63|      1|
plains        |female    |                      1818|                       44.87|      2|
plains        |non-binary|                       385|                        9.50|      3|
rocky mountain|female    |                       935|                       46.61|      1|
rocky mountain|male      |                       872|                       43.47|      2|
rocky mountain|non-binary|                       199|                        9.92|      3|
southeast     |female    |                      6332|                       45.70|      1|
southeast     |male      |                      6175|                       44.57|      2|
southeast     |non-binary|                      1349|                        9.74|      3|
southwest     |female    |                      3448|                       45.37|      1|
southwest     |male      |                      3425|                       45.07|      2|
southwest     |non-binary|                       727|                        9.57|      3|

### How many different aliens species live in the U.S. and are they concentrated in any particular region?  Use a cte to rank the species type by their region and return the top 2 ranked species per region.

````sql
WITH top_species_region AS (
	SELECT
		DISTINCT ad.type AS species,
		count(ad.type) AS n_species,
		ad.us_region,
		rank() OVER (PARTITION BY ad.type ORDER BY count(ad.type) desc) AS rnk
	FROM alien_data AS ad
	GROUP BY
		species,
		ad.us_region
)

SELECT
	species,
	us_region,
	n_species
FROM top_species_region
WHERE rnk <= 2
ORDER BY species, n_species DESC;
````

**Results**

species  |us_region|n_species|
---------|---------|---------|
flatwoods|southeast|     2848|
flatwoods|far west |     1620|
green    |southeast|     2752|
green    |far west |     1608|
grey     |southeast|     2799|
grey     |southwest|     1532|
nordic   |southeast|     2768|
nordic   |far west |     1548|
reptile  |southeast|     2689|
reptile  |far west |     1608|

### What is the top favorite food of every species including ties?

````sql
SELECT
	species,
	favorite_food
from
	(SELECT
		DISTINCT type AS species,
		favorite_food,
		rank() OVER (PARTITION BY type ORDER BY count(*) desc) AS rnk
	FROM alien_data 
	GROUP BY 
		species,
		favorite_food) AS tmp
WHERE rnk = 1
ORDER BY species, rnk DESC;
````

**Results**

species  |favorite_food            |
---------|-------------------------|
flatwoods|eagle, bateleur          |
green    |gray duiker              |
grey     |openbill stork           |
nordic   |two-toed tree sloth      |
nordic   |scaly-breasted lorikeet  |
nordic   |pine snake (unidentified)|
reptile  |gonolek, burchell's      |

### Which are the top 10 cities where aliens are located and is the population majority hostile or friendly?

````sql
SELECT
	alien_location,
	hostile_aliens,
	friendly_aliens,
	CASE
		WHEN hostile_aliens > friendly_aliens THEN 'Hostile'
		ELSE 'Friendly'
	END AS population_majority
from
	(SELECT
		current_location AS alien_location,
		count(
			CASE
				WHEN aggressive = TRUE THEN 1
				ELSE null
			END 
		) AS hostile_aliens,
		count(
			CASE
				WHEN aggressive != TRUE THEN 1
				ELSE null
			END 
		) AS friendly_aliens
	FROM alien_data
	GROUP BY current_location
	ORDER BY count(current_location) desc
	LIMIT 10) AS tmp;
````

**Results**

alien_location|hostile_aliens|friendly_aliens|population_majority|
--------------|--------------|---------------|-------------------|
washington    |           851|            810|Hostile            |
houston       |           513|            502|Hostile            |
el paso       |           415|            425|Friendly           |
new york city |           421|            419|Hostile            |
dallas        |           325|            339|Friendly           |
atlanta       |           297|            328|Friendly           |
kansas city   |           270|            293|Friendly           |
sacramento    |           291|            251|Hostile            |
miami         |           260|            267|Friendly           |
los angeles   |           230|            271|Friendly           |

 
 
