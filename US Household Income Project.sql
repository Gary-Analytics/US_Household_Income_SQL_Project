# US Household Income Project

USE us_house_project;

-- STEP 1: DATA CLEANING

-- Switching off SQL Safety mode to allow updates
SET SQL_SAFE_UPDATES = 0;

-- Reviewing the Datasets
SELECT *
FROM us_household_income;

SELECT *
FROM us_household_income_statistics;

-- Fixing Incorrect Table Header
ALTER TABLE us_household_income_statistics RENAME COLUMN `ï»¿id` TO `id`;

-- Checking if number of ids are the same in each table
-- For us_household_income
SELECT COUNT(id) AS total_ids_income,
       COUNT(DISTINCT id) AS unique_ids_income
FROM us_household_income;

-- For us_household_income_statistics
SELECT COUNT(id) AS total_ids_statistics,
       COUNT(DISTINCT id) AS unique_ids_statistics
FROM us_household_income_statistics;

-- Checking for us_household_income duplicates
SELECT id, COUNT(id)
FROM us_household_income
GROUP BY id
HAVING COUNT(id) > 1;

-- Finding the row_id of the duplicates
SELECT *
FROM (
    SELECT row_id,
           id,
           ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) row_num
    FROM us_household_income
) duplicates
WHERE row_num > 1;

-- Deleting those dupicates using the row-id number
DELETE FROM us_household_income
WHERE row_id IN (
    SELECT row_id
    FROM (
        SELECT row_id,
               id,
               ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) row_num
        FROM us_household_income
    ) duplicates
    WHERE row_num > 1
);

-- Checking for us_household_income_statistics duplicates
SELECT id, COUNT(id)
FROM us_household_income
GROUP BY id
HAVING COUNT(id) > 1;

-- Noticed an error in some state names so reviewing count of state names
SELECT State_Name, COUNT(State_Name)
FROM us_household_income
GROUP BY State_Name;

-- Fixing Georgia mispelling for state name
UPDATE us_household_income
SET State_Name = 'Georgia'
WHERE State_Name = 'georia';

-- Fixing alabama capital letter for state name
UPDATE us_household_income
SET State_Name = 'Alabama'
WHERE State_Name = 'alabama';

-- Checking for blanks in place column
SELECT *
FROM us_household_income
WHERE Place = ''
ORDER BY 1;

-- Fixing blank space in place column
UPDATE us_household_income
SET Place = 'Autaugaville'
WHERE County = 'Autauga County'
AND City = 'Vinemont';

-- Checking Type column in us_household_income
SELECT Type, COUNT(Type)
FROM us_household_income
Group By Type
;

-- Updating Type column Error
UPDATE us_household_income
SET Type = 'Borough'
WHERE Type = 'Boroughs';

-- Examining ALand and AWater columns
SELECT ALand, AWater
FROM us_household_income
WHERE (ALand = 0 OR ALand = '' OR ALand IS NULL);

-- STEP 2: EXPLORATORY DATA ANALYSIS

-- Reviewing the Datasets
SELECT *
FROM us_household_income;

SELECT *
FROM us_household_income_statistics;

-- Checking top 10 states with most/least Land area and Water area
SELECT State_Name, SUM(ALand), SUM(AWater)
FROM us_household_income
GROUP BY State_Name
-- ORDER BY 2 DESC
ORDER BY 3 DESC
Limit 10;

-- Joining my tables with Inner Join to perform more analysis
-- Noticed figures missing for us_household_income_statistic mean statistics 
-- So removed non-useful data
SELECT *
FROM us_household_income AS income
INNER JOIN us_household_income_statistics AS stats
    ON income.id = stats.id
WHERE Mean <> 0;

-- Reviewing joined tables
SELECT income.State_Name, County, Type, `Primary`, Mean, Median
FROM us_household_income AS income
INNER JOIN us_household_income_statistics AS stats
    ON income.id = stats.id
WHERE Mean <> 0;

-- Checking average mean and median income by state
SELECT income.State_Name, 
	ROUND(AVG(Mean),1) AS 'Avg Mean Income',
	ROUND(AVG(Median),1) as 'Avg Median Income'
FROM us_household_income AS income
INNER JOIN us_household_income_statistics AS stats
    ON income.id = stats.id
WHERE Mean <> 0
GROUP BY income.State_Name
ORDER BY `Avg Mean Income`
LIMIT 5;

-- Checking average mean and median income by area type
SELECT 
    Type,
    COUNT(Type),
    ROUND(AVG(Mean), 1) AS 'Avg Mean Income',
    ROUND(AVG(Median), 1) AS 'Avg Median Income'
FROM
    us_household_income AS income
	INNER JOIN us_household_income_statistics AS stats 
    ON income.id = stats.id
WHERE
    Mean <> 0
GROUP BY Type
ORDER BY `Avg Mean Income` DESC;


-- Community (from Type) has the lowest mean and median income
-- Checking States where Community (from Type) most common
SELECT *
FROM us_household_income
WHERE Type = 'Community';

-- Checking Citys with highest mean income
SELECT 
    income.State_Name, 
    City,
    ROUND(AVG(Mean), 1) AS 'Avg Mean Income'
FROM
    us_household_income AS income
	INNER JOIN us_household_income_statistics AS stats 
    ON income.id = stats.id
WHERE
    Mean <> 0
GROUP BY income.State_Name, City
ORDER BY `Avg Mean Income` DESC;

-- Switching on SQL Safety mode to stop updates
SET SQL_SAFE_UPDATES = 1;
