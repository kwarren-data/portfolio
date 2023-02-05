-- Create the initial table for the aliens CSV file
CREATE TABLE aliens (
  id SERIAL,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  email VARCHAR(50),
  gender VARCHAR(12),
  alien_type VARCHAR(16),
  birth_year INTEGER
)

-- Verify that the aliens table was created
SELECT * FROM aliens;

-- Copy the data from the CSV file to the table
COPY aliens(id, first_name, last_name, email, gender,
		   alien_type, birth_year)
FROM '/home/ken/my_datasets/AliensInAmerica/Aliens of America - aliens.csv'
DELIMITER ','
CSV HEADER;

-- Verify the data was copied to the table
SELECT *
FROM aliens
LIMIT(10);

-- Create the table for the locations
CREATE TABLE loc (
  loc_id SERIAL,
  current_location VARCHAR(50),
  state VARCHAR(50),
  country VARCHAR(50),
  occupation VARCHAR(50)
)

-- Copy the data from the CSV file to the table
COPY loc(loc_id, 
		 current_location,
		 state, 
		 country, 
		 occupation)
FROM '/home/ken/my_datasets/AliensInAmerica/Aliens of America - location.csv'
DELIMITER ','
CSV HEADER;

-- Verify location data successfully uploaded
SELECT *
FROM loc
LIMIT(10);

-- Create details table
CREATE TABLE details (
  detail_id SERIAL,
  fav_food VARCHAR(50),
  feeding_freq VARCHAR(12),
  aggressive BOOLEAN
)

-- Copy the data from the CSV file to the table
COPY details(
	detail_id, 
	fav_food, 
	feeding_freq, 
	aggressive)
FROM '/home/ken/my_datasets/AliensInAmerica/Aliens of America - details.csv'
DELIMITER ','
CSV HEADER;

-- Verify location data successfully uploaded
SELECT *
FROM details
LIMIT(10);

