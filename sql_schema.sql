-- Create the three tables we are going to import of csv data into.
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