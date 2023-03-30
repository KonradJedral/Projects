-- Dane pobrane ze storny: https://ourworldindata.org/coronavirus


USE covidproject;							
								
# Tworzenie tabel

CREATE TABLE covidproject.coviddeaths
(
	iso_code VARCHAR(45),
    continent VARCHAR(45) NULL DEFAULT NULL,
    location VARCHAR(45) NULL DEFAULT NULL, 
    date DATETIME NULL DEFAULT NULL, 
    new_cases INT NULL DEFAULT 0, 
    total_cases INT NULL DEFAULT 0, 
    new_deaths INT NULL DEFAULT 0, 
    total_deaths INT NULL DEFAULT 0,
    population BIGINT NULL DEFAULT 0
);



CREATE TABLE covidproject.covidvaccinations
(
	iso_code VARCHAR(45),
    continent VARCHAR(45) NULL DEFAULT NULL,
    location VARCHAR(45) NULL DEFAULT NULL, 
    date DATETIME NULL DEFAULT NULL, 
    new_tests INT NULL DEFAULT 0, 
    total_tests INT NULL DEFAULT 0, 
    new_vaccinations INT NULL DEFAULT 0, 
    total_vaccinations INT NULL DEFAULT 0
);



# Import Tabel


LOAD DATA INFILE 'C:\\Programowanie\\SQL\\Databases\\coviddeathssmall.csv'
INTO TABLE coviddeaths
CHARACTER SET utf8MB4 
FIELDS TERMINATED BY ';' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 LINES 
(iso_code, continent, location, @date, @new_cases, @total_cases, @new_deaths, @total_deaths, @population)
SET population = IF(@population='',NULL,@population),
total_deaths = IF(@total_deaths='',0,@total_deaths),
new_deaths = IF(@new_deaths='',0,@new_deaths),
total_cases = IF(@total_cases='',0,@total_cases),
new_cases = IF(@new_cases='',0,@new_cases),
date = str_to_date(@date, '%d.%m.%Y');

SELECT * FROM coviddeaths;

SELECT COUNT(*) FROM coviddeaths;




LOAD DATA INFILE 'C:\\Programowanie\\SQL\\Databases\\covidvaccinationssmall.csv'
INTO TABLE covidvaccinations
CHARACTER SET utf8MB4 
FIELDS TERMINATED BY ';' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 LINES 
(iso_code, continent, location, @date, @new_tests, @total_tests, @new_vaccinations, @total_vaccinations)
SET new_tests = IF(@new_tests='',0,@new_tests),
total_tests = IF(@total_tests='',0,@total_tests),
new_vaccinations = IF(@new_vaccinations='',0,@new_vaccinations),
total_vaccinations = IF(@total_vaccinations='',0,@total_vaccinations),
date = str_to_date(@date, '%d.%m.%Y');

SELECT * FROM covidvaccinations;

SELECT COUNT(*) FROM covidvaccinations;




-- Tworzę nowe tabele, na których będę pracował (Same Państwa bez kontynentów z coviddeaths i covidvaccination oraz same kontynenty z coviddeaths i covidvaccination)

SELECT iso_code, location FROM coviddeaths
WHERE iso_code LIKE '%owid%'
GROUP BY 1, 2;



-- Kosovo i 'Northern Cyprus' jako jedyne państwa ma w iso_code OWID, dlatego zmieniam na "KOS" i NCY, które są wolne. Następnie tworzę tabelę.

UPDATE coviddeaths SET iso_code = "KOS" 
WHERE location ="Kosovo";

UPDATE covidvaccinations SET iso_code = "KOS" 
WHERE location ="Kosovo";

UPDATE coviddeaths SET iso_code = "NCY" 
WHERE location ="Northern Cyprus";

UPDATE covidvaccinations SET iso_code = "NCY" 
WHERE location ="Northern Cyprus";



CREATE TABLE CovD 
SELECT 
	iso_code,
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    new_deaths,
    population FROM
    coviddeaths
WHERE
    iso_code NOT LIKE 'OWID_%';

CREATE TABLE CovV 
SELECT 
	iso_code,
	location,
    date,
    new_tests,
    total_tests,
    new_vaccinations,
    total_vaccinations
FROM
    covidvaccinations
WHERE
    iso_code NOT LIKE 'OWID_%';

CREATE TABLE ConCovD 
SELECT 
	iso_code,
    location, 
	date, 
    total_cases, 
    new_cases, 
    total_deaths, 
    population
FROM 
	coviddeaths
WHERE 
	iso_code LIKE "OWID_%";

CREATE TABLE ConCovV 
SELECT 
	iso_code,
    location,
    date,
    new_tests,
    total_tests,
    new_vaccinations,
    total_vaccinations 
FROM
    covidvaccinations
WHERE
    iso_code LIKE 'OWID_%';
    
    
SELECT * FROM Covd;

SELECT DISTINCT(location) FROM ConCovD;



SELECT 
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    covd
ORDER BY 1 , 2;


SELECT 
	location,
    date,
    new_tests,
    total_tests,
    new_vaccinations,
    total_vaccinations
FROM covv
ORDER BY 1, 2;

-- Porównuje skalę zgonów do wszystkich przypadków zarażenia

SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    ROUND((total_deaths / total_cases) * 100, 6) AS DeathCasesPct
FROM
    covd
ORDER BY 1 , 2;



-- Porównuje skalę zgonów do wszystkich przypadków zarażenia w Polsce 

SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    ROUND((total_deaths / total_cases) * 100, 6) AS DeathCasesPct
FROM
    covd
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
    covd
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
    covd
WHERE
    location = 'Poland'
ORDER BY date;



-- Sprawdzam, w których 10 krajach był największy stosunek ludzi zarażonych do populacji

SELECT 
    location,
    population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX(ROUND((total_cases / population) * 100, 6)) AS CasesPopPct
FROM
    covd
GROUP BY location , population
ORDER BY CasesPopPct DESC
LIMIT 10;



-- Sprawdzam, w których krajach wystąpiło najwięcej przypadków zarażenia

SELECT 
    location,
    MAX(total_deaths) AS TotalDeathCount
FROM
    covd
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
    covd
GROUP BY location , population
ORDER BY DeaPopPct DESC
LIMIT 100;



-- Sprawdzam ilość wszystkich przypadków zarażenia, zgonów oraz ich wzajemny stosunek na Świecie.

SELECT 
    SUM(new_cases) AS TotalCases,
    SUM(new_deaths) AS TotalDeaths,
    (SUM(new_deaths)/SUM(new_cases)) * 100 AS DeathsCasesPct
FROM
	covd;



-- Sprawdzam ilość nowych przypadków zarażenia, zgonów oraz ich wzajemny stosunek na Świecie wg. daty

SELECT 
	date, 
    SUM(new_cases) AS TotalCases,
    SUM(new_deaths) AS TotalDeaths,
    (SUM(new_deaths)/SUM(new_cases)) * 100 AS DeathsCasesPct
FROM
	covd
GROUP BY date
ORDER BY 1;



--  Spradzam ilość testów i szczepień wg. kraju 

SELECT 
	location,
    MAX(total_tests) AS TotalTests,
    MAX(total_vaccinations) AS TotalVaccinations
FROM
	covv
GROUP BY 1
ORDER BY 2 DESC;



-- Sprawdzam stosunek testów i szczepień do populacji krajów 

SELECT 
	covd.location,
    MAX(covd.population) AS Population,
    MAX(total_tests) AS TotalTests,
    MAX(total_vaccinations) AS TotalVaccinations,
    MAX(total_tests/population) * 100 AS TestPopPct,
    MAX(total_vaccinations/Population) * 100 AS VacPopPct
FROM 
	covd
JOIN 
	covv
ON 
	covd.location = covv.location 
AND covd.date = covv.date
GROUP BY 1
ORDER BY 1;



-- Sprawdzam jak rosła ilośc testów na Świecie wg kraju i daty

SELECT 
	covd.location,
    covd.date,
    covd.population,
    covv.new_tests,
    SUM(covv.new_tests) OVER (PARTITION BY covd.location ORDER BY covd.date) AS SumTestsToDate
FROM
	covd
JOIN 
	covv
ON 
	covd.location = covv.location 
AND covd.date = covv.date
ORDER BY 1, 2;



-- Sprawdzam jak rosła ilośc testów w Polsce wg daty

SELECT 
	covd.location,
    covd.date,
    covd.population,
    covv.new_tests,
    SUM(covv.new_tests) OVER (PARTITION BY covd.location ORDER BY covd.date) AS SumTestsToDate
FROM
	covd
JOIN 
	covv
ON 
	covd.location = covv.location 
AND covd.date = covv.date
WHERE 
	covd.location = 'Poland'
ORDER BY 1, 2;



-- Tworze CTE dla łatwiejszego obliczenia Stosunku sumy testów do populacji wg codziennej sumy testów

With NewTestsPop (Location, Date, Population, NewTests, SumTestsToDate)
as 
(
SELECT 
	covd.location,
    covd.date,
    covd.population,
    covv.new_tests,
    SUM(covv.new_tests) OVER (PARTITION BY covd.location ORDER BY covd.date) AS SumTestsToDate
FROM
	covd
JOIN 
	covv
ON 
	covd.location = covv.location 
AND covd.date = covv.date
WHERE 
	covd.location = 'Poland'
)
SELECT 
	*,
    (SumTestsToDate/Population) * 100 AS TestToDatePopPct
FROM
	NewTestsPop
ORDER BY 2;



-- Tworzę przykładowy widok do wizualizacji 


CREATE VIEW TotalCasesByContinent 
AS 
SELECT 
	Location, 
	Population, 
    MAX(total_cases) AS TotalCases
FROM 
	concovd
WHERE location NOT IN ('Europe Union', 'International', 'World') 
GROUP BY 1, 2;

SELECT * FROM TotalCasesByContinent

