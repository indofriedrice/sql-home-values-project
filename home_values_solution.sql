-- PROJECT 4: “TRENDS IN ESTIMATED HOME VALUES” -- 

-- 1.How many distinct zip codes are in this dataset?

SELECT COUNT(DISTINCT zip_code) AS "# of Zip Code"
FROM home_value_data;

-- How many zip codes are from each state?

SELECT state, COUNT(DISTINCT zip_code) AS "# of Zip Code"
FROM home_value_data
GROUP BY 1;

-- What range of years are represented in the data?

SELECT MIN(substr(date,1,4)) AS "START YEAR", MAX(substr(date,1,4)) AS "END YEAR"
FROM home_value_data; 

-- Using the most recent month of data available, what is the range of estimated home values across the nation?

SELECT DISTINCT state AS 'State', MIN(value) AS 'Minimum Value', MAX(value) AS 'Maximum Value'
FROM home_value_data
WHERE date = (SELECT MAX(date) FROM home_value_data)
GROUP BY 1;

-- Using the most recent month of data available, which states have the highest average home values? How about the lowest? 

-- HIGHEST:
SELECT DISTINCT state AS "State", ROUND(AVG(value),2) AS "Average Value"
FROM home_value_data
WHERE date = (SELECT MAX(date) FROM home_value_data)
GROUP BY 1
ORDER BY 2 DESC;

-- LOWEST:
SELECT DISTINCT state AS "State", ROUND(AVG(value),2) AS "Average Value"
FROM home_value_data
WHERE date = (SELECT MAX(date) FROM home_value_data)
GROUP BY 1
ORDER BY 2 ASC;

-- Which states have the highest/lowest average home values for the year of 2017? What about for the year of 2007? 1997?

WITH average AS (
SELECT substr(date, 1, 4) AS "year", state, ROUND(AVG(value),0) AS "average_value"
FROM home_value_data
WHERE year = "2017"
GROUP BY 2,1
)

SELECT average.year AS "Year", 

(SELECT state FROM average WHERE average_value = (SELECT MIN(average_value) FROM average GROUP BY year)) AS "Minimum State", 

MIN(average_value) AS "Minimum Value", 

(SELECT state FROM average WHERE average_value = (SELECT MAX(average_value) FROM average GROUP BY year)) AS "Maximum State", 

MAX(average_value) AS "Maximum Value"
FROM average;

-- What is the percent change in average home values from 2007 to 2017 by state? How about from 1997 to 2017?

WITH value_2017 AS (
SELECT substr(date,1,4) AS "year", state, ROUND(AVG(value),2) AS "average"
FROM home_value_data
WHERE year = "2017"
GROUP BY 2,1
), 

value_2007 AS (
SELECT substr(date,1,4) AS "year", state, ROUND(AVG(value),2) AS "average"
FROM home_value_data
WHERE year = "2007"
GROUP BY 2,1
),

value_1997 AS (
SELECT substr(date,1,4) AS "year", state, ROUND(AVG(value),2) AS "average"
FROM home_value_data
WHERE year = "1997"
GROUP BY 2,1
)

SELECT value_2017.state, 
value_2017.average AS "2017 Average", 
value_2007.average AS "2007 Average", 
value_1997.average AS "1997 Average",
ROUND((100.0 * (value_2017.average - value_2007.average) / value_2007.average), 2) AS "% Change 2007 - 2017",
ROUND((100.0 * (value_2017.average - value_1997.average) / value_1997.average), 2) AS "% Change 1997 - 2017"

FROM value_2017
JOIN value_2007
	ON value_2017.state = value_2007.state
JOIN value_1997
	ON value_2007.state = value_1997.state
ORDER BY 5 DESC; # ORDER BY 5 -- DESCENDING BECAUSE FINDING THE MOST RECENT (2007 - 2017) GROWTH IN % OF PRICES SHOWS THE HIGHEST GROWING REAL ESTATE MARKETS 

-- How would you describe the trend in home values for each state from 1997 to 2017? How about from 2007 to 2017? Which states would you recommend for making real estate investments?

-- ANSWER:
-- According to the previous % GROUP BY query, we can find the highest growing real estate markets. 
-- In a descending order, I would suggest ND, DC, SD, TX, CO, or OK, depending on how much you have to invest and how quickly you would like to make a return.

-- Join the house value data with the table of zip-code level census data. Do there seem to be any correlations between the estimated house values and characteristics of the area, such as population count or median household income?

WITH zip_val AS(
	SELECT	
		substr(date,1,4) year,
		zip_code,
		CAST(ROUND(AVG(value),0) AS INT) average
	FROM home_value_data
	GROUP BY 2,1
)
	
SELECT zv.year,
	zv.zip_code,
	zv.average,
	cd.pop_total,
	cd.median_household_income
FROM zip_val zv
JOIN census_data cd
	ON zv.zip_code = cd.zip_code
WHERE year = '2017' AND cd.median_household_income != 'NULL'
ORDER BY cd.pop_total; # Change to median_household_income to study that correlation

-- Analysis: According to the joined databases, population number and median household income varies depending on the state and characteristics of the area. 
-- States like FL or CA tend to have more expensive houses compared to states like NH or UT.