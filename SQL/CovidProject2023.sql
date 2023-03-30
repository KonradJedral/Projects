-- Dane pobrane ze storny: https://ourworldindata.org/coronavirus


USE covidproject;							
								
# Tworzenie tabel

DROP TABLE IF EXISTS covidproject.Covid2023;
CREATE TABLE covidproject.Covid2023
(
	iso_code VARCHAR(45),
    Continent VARCHAR(45) DEFAULT NULL,
    Location VARCHAR(45) DEFAULT NULL,
    Date DATETIME,
    Total_cases NUMERIC DEFAULT 0,
    New_cases NUMERIC DEFAULT 0,
    Total_deaths NUMERIC DEFAULT 0,
    New_deaths NUMERIC DEFAULT 0,
    Total_tests NUMERIC DEFAULT 0,
    New_tests NUMERIC DEFAULT 0,
    Total_Vaccinations NUMERIC DEFAULT 0,
    New_Vaccinations NUMERIC DEFAULT 0,
    Population NUMERIC DEFAULT NULL
);


LOAD DATA INFILE 'C:\\Programowanie\\SQL\\Databases\\covid032023.csv'
INTO TABLE Covid2023
CHARACTER SET utf8MB4 
FIELDS TERMINATED BY ';' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 LINES 
(iso_code, @continent, location, @date, @total_cases, @new_cases, @total_deaths, @new_deaths,  
@total_tests, @new_tests, @total_vaccinations, @new_vaccinations, @population)
SET 
continent = NULLIF(@continent, ''),
population = IF(@population='',NULL,@population),
total_deaths = IF(@total_deaths='',0,@total_deaths),
new_deaths = IF(@new_deaths='',0,@new_deaths),
total_cases = IF(@total_cases='',0,@total_cases),
new_cases = IF(@new_cases='',0,@new_cases),
new_tests = IF(@new_tests='',0,@new_tests),
total_tests = IF(@total_tests='',0,@total_tests),
new_vaccinations = IF(@new_vaccinations='',0,@new_vaccinations),
total_vaccinations = IF(@total_vaccinations='',0,@total_vaccinations),
date = str_to_date(@date, '%d.%m.%Y');

SELECT * FROM Covid2023
WHERE Continent IS NULL;

SELECT COUNT(*) FROM Covid2023;



-- Tworzę nowe tabele, na których będę pracował (Same Państwa bez kontynentów z coviddeaths i covidvaccination oraz same kontynenty z coviddeaths i covidvaccination)

SELECT DISTINCT(iso_code), continent, location FROM Covid2023
WHERE Continent IS NULL;




CREATE TABLE CovD2023
SELECT 
	iso_code,
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    new_deaths,
    population 
FROM
    Covid2023
WHERE
    continent IS NOT NULL;


CREATE TABLE CovV2023
SELECT 
	iso_code,
	location,
    date,
    new_tests,
    total_tests,
    new_vaccinations,
    total_vaccinations
FROM
    Covid2023
WHERE
    continent IS NOT NULL;


CREATE TABLE ConCovD2023
SELECT 
	iso_code,
    location, 
	date, 
    total_cases, 
    new_cases, 
    total_deaths, 
    population
FROM 
	Covid2023
WHERE 
	continent IS NULL;


CREATE TABLE ConCovV2023
SELECT 
	iso_code,
    location,
    date,
    new_tests,
    total_tests,
    new_vaccinations,
    total_vaccinations 
FROM
    Covid2023
WHERE
    continent IS NULL;
    
    
SELECT * FROM Covv2023
WHERE location = 'Poland';

SELECT DISTINCT(location) FROM ConCovD2023;



SELECT 
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    covd2023
ORDER BY 1 , 2;


SELECT 
	location,
    date,
    new_tests,
    total_tests,
    new_vaccinations,
    total_vaccinations
FROM covv2023
ORDER BY 1, 2;

-- Porównuje skalę zgonów do wszystkich przypadków zarażenia

SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    ROUND((total_deaths / total_cases) * 100, 6) AS DeathCasesPct
FROM
    covd2023
ORDER BY 1 , 2;



-- Porównuje skalę zgonów do wszystkich przypadków zarażenia w Polsce 

SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    ROUND((total_deaths / total_cases) * 100, 6) AS DeathCasesPct
FROM
    covd2023
WHERE
    location = 'Poland'
ORDER BY date;



-- Sprawdzam, którego dnia był największy stosunek zgonów do przypadków zarażenia w Polsce 

SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    ROUND((total_deaths / total_cases) * 100, 6) AS DeathCasesPct
FROM
    covd2023
WHERE
    location = 'Poland'
ORDER BY DeathCasesPct DESC
LIMIT 1;


-- Porównuje wszystkie przypadki zarażenia do populacji w Polsce 

SELECT 
    location,
    date,
    total_cases,
    population,
    ROUND((total_cases / population) * 100, 6) AS CasesPopPct
FROM
    covd2023
WHERE
    location = 'Poland'
ORDER BY date DESC;



-- Sprawdzam, w których 10 krajach był największy stosunek ludzi zarażonych do populacji

SELECT 
    location,
    population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX(ROUND((total_cases / population) * 100, 6)) AS CasesPopPct
FROM
    covd2023
GROUP BY location , population
ORDER BY CasesPopPct DESC
LIMIT 10;



-- Sprawdzam, w których krajach wystąpiło najwięcej przypadków zarażenia

SELECT 
    location,
    MAX(total_deaths) AS TotalDeathCount
FROM
    covd2023
GROUP BY location
ORDER BY TotalDeathCount DESC
LIMIT 10;



-- Sprawdzam, w których krajach był największy stosunek zgonów do populacji

SELECT 
	RANK() OVER (ORDER BY MAX(ROUND((total_deaths / population) * 100, 6)) DESC) AS "Rank",
    location,
    MAX(total_deaths) AS TotalDeathCount,
    Population,
    MAX(ROUND((total_deaths / population) * 100, 6)) AS DeaPopPct
FROM
    covd2023
GROUP BY location , population
ORDER BY DeaPopPct DESC
LIMIT 100;



-- Sprawdzam ilość wszystkich przypadków zarażenia, zgonów oraz ich wzajemny stosunek na Świecie.

SELECT 
    SUM(new_cases) AS TotalCases,
    SUM(new_deaths) AS TotalDeaths,
    (SUM(new_deaths)/SUM(new_cases)) * 100 AS DeathsCasesPct
FROM
	covd2023;



-- Sprawdzam ilość nowych przypadków zarażenia, zgonów oraz ich wzajemny stosunek na Świecie wg. daty

SELECT 
	date, 
    SUM(new_cases) AS TotalCases,
    SUM(new_deaths) AS TotalDeaths,
    (SUM(new_deaths)/SUM(new_cases)) * 100 AS DeathsCasesPct
FROM
	covd2023
GROUP BY date
ORDER BY 1;



--  Spradzam ilość testów i szczepień wg. kraju 

SELECT 
	location,
    MAX(total_tests) AS TotalTests,
    MAX(total_vaccinations) AS TotalVaccinations
FROM
	covv2023
GROUP BY 1
ORDER BY 2 DESC;



-- Sprawdzam stosunek testów i szczepień do populacji krajów 

SELECT 
	covd2023.location,
    MAX(covd2023.population) AS Population,
    MAX(total_tests) AS TotalTests,
    MAX(total_vaccinations) AS TotalVaccinations,
    MAX(total_tests/population) * 100 AS TestPopPct,
    MAX(total_vaccinations/Population) * 100 AS VacPopPct
FROM 
	covd2023
JOIN 
	covv2023
ON 
	covd2023.location = covv2023.location 
AND covd2023.date = covv2023.date
GROUP BY 1
ORDER BY 6 DESC;



-- Sprawdzam jak rosła ilośc testów na Świecie wg kraju i daty

SELECT 
	covd2023.location,
    covd2023.date,
    covd2023.population,
    covv2023.new_tests,
    SUM(covv2023.new_tests) OVER (PARTITION BY covd2023.location ORDER BY covd2023.date) AS SumTestsToDate
FROM
	covd2023
JOIN 
	covv2023
ON 
	covd2023.location = covv2023.location 
AND covd2023.date = covv2023.date
ORDER BY 1, 2;



-- Sprawdzam jak rosła ilośc testów w Polsce wg daty

SELECT 
	covd2023.location,
    covd2023.date,
    covd2023.population,
    covv2023.new_tests,
    SUM(covv2023.new_tests) OVER (PARTITION BY covd2023.location ORDER BY covd2023.date) AS SumTestsToDate
FROM
	covd2023
JOIN 
	covv2023
ON 
	covd2023.location = covv2023.location 
AND covd2023.date = covv2023.date
WHERE 
	covd2023.location = 'Poland'
ORDER BY 1, 2;



-- Tworze CTE dla łatwiejszego obliczenia Stosunku sumy testów do populacji wg codziennej sumy testów

With NewTestsPop2023 (Location, Date, Population, NewTests, SumTestsToDate)
as 
(
SELECT 
	covd2023.location,
    covd2023.date,
    covd2023.population,
    covv2023.new_tests,
    SUM(covv2023.new_tests) OVER (PARTITION BY covd2023.location ORDER BY covd2023.date) AS SumTestsToDate
FROM
	covd2023
JOIN 
	covv2023
ON 
	covd2023.location = covv2023.location 
AND covd2023.date = covv2023.date
WHERE 
	covd2023.location = 'Poland'
)
SELECT 
	*,
    (SumTestsToDate/Population) * 100 AS TestToDatePopPct
FROM
	NewTestsPop2023
ORDER BY 2;



-- Tworzę przykładowy widok do wizualizacji 


CREATE VIEW TotalCasesByContinent2023
AS 
SELECT 
	Location, 
	Population, 
    MAX(total_cases) AS TotalCases
FROM 
	concovd2023
WHERE location IN ('Africa', 'North America', 'South America', 'Asia', 'Oceania', 'Europe') 
GROUP BY 1, 2;

SELECT * FROM TotalCasesByContinent2023;

