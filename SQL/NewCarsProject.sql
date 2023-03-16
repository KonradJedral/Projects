USE cars_fuel_db;


# Zmienić nazwę tabeli, 
# Dodać index,
# rozdzielić na dwie osobne, 
# sprawdzić sumę zarejestrowanych aut w poszcególnych kategoriach
# Połączyć w jedną nową tabelę
# Dodać kolumnę z sumą wszystkich zarejestrowanych aut wg. kraju
# Sprawdzić sumę wszsytkich zarejestrowanych aut wg. kraju i lat
# Sprawdzić sumę wszystkich zarejestrowanych aut wg lat
# Sprawdzić % zarejestrowanych samochodów Elektrycznych, Plugin i Hybrydowych w stosunku do wszystkich zarejesrowanych pojazdów wg. lat
# Sprawdzić % zarejestrowanych samochodów Elektrycznych, Plugin i Hybrydowych w stosunku do wszystkich zarejesrowanych pojazdów wg. kraju
# Sprawdzić jak wygląda rejestrowanie nowych aut we Francji oraz jak z roku na rok zmienia się ilość nowych rejesrowancyh aut na diesla



# zmieniam nazwę tabeli
RENAME TABLE `new-vehicles-type-area` TO NewCars;


#Sprawdzam zawartość tabeli
SELECT * FROM NewCars;


# Tworzę własny index

ALTER TABLE newcars
DROP COLUMN id;

ALTER TABLE NewCars
ADD Id VARCHAR(255) FIRST;

UPDATE NewCars
SET Id = CONCAT(Code, SUBSTRING(Year, -2, 2));

SELECT * FROM NewCars;



# Podział na dwie tabele

CREATE TABLE ElectricHybridCars 
(id VARCHAR(255),
Entity VARCHAR(255),
Year INT,
battery_electric_number INT,
plugin_hybrid_number INT,
full_mild_hybrid_number INT);

INSERT INTO ElectricHybridCars
SELECT id, Entity, Year, battery_electric_number, plugin_hybrid_number, full_mild_hybrid_number FROM newcars;

SELECT * FROM ElectricHybridCars;



# Tworzę tabele innym sposobem

CREATE TABLE PetrolDieselCars
SELECT id ,Entity, Year, petrol_number, diesel_gas_number FROM newcars;

SELECT * FROM PetrolDieselCars;


# Suma zarejestrowanych aut w każdym kraju od 2001 do 2019 wg zasilania

SELECT 
    Entity,
    '2001 - 2019' AS Year,
    SUM(battery_electric_number) AS ElectricCars,
    SUM(plugin_hybrid_number) AS PluginHybridCars,
    SUM(full_mild_hybrid_number) AS FullMildHybridCars
FROM
    ElectricHybridCars
GROUP BY Entity;

SELECT 
    Entity,
    '2001 - 2019' AS Year,
    SUM(petrol_number) AS PetrolCars,
    SUM(diesel_gas_number) AS DieselCars
FROM
    PetrolDieselCars
GROUP BY Entity;


# Zarejestrowane auta z obydwu tabel

SELECT 
    ElectricHybridCars.Entity,
    '2001 - 2019' AS Year,
    SUM(battery_electric_number) AS ElectricCars,
    SUM(plugin_hybrid_number) AS PluginHybridCars,
    SUM(full_mild_hybrid_number) AS FullMildHybridCars,
    SUM(petrol_number) AS PetrolCars,
    SUM(diesel_gas_number) AS DieselCars
FROM
    ElectricHybridCars
        JOIN
    PetrolDieselCars ON ElectricHybridCars.id = PetrolDieselCars.id
GROUP BY Entity;


# Suma wszsytkich zarejestrowanych aut wg. kraju. W tym celu łączę stworzone tabele.
drop table allcarsbyentity;

CREATE TABLE AllCarsByEntity 
SELECT 
	ElectricHybridCars.Entity,
    '2001 - 2019' AS Year,
    SUM(battery_electric_number) AS ElectricCars,
    SUM(plugin_hybrid_number) AS PluginHybridCars,
    SUM(full_mild_hybrid_number) AS FullMildHybridCars,
    SUM(petrol_number) AS PetrolCars,
    SUM(diesel_gas_number) AS DieselCars FROM
    ElectricHybridCars
        JOIN
    PetrolDieselCars ON ElectricHybridCars.id = PetrolDieselCars.id
GROUP BY Entity;

SELECT * FROM AllCarsByEntity;

ALTER TABLE AllCarsByEntity
ADD Sum INT;

UPDATE AllCarsByEntity
SET Sum = ElectricCars + PluginHybridCars + FullMildHybridCars + PetrolCars + DieselCars;

SELECT Entity, Year, Sum FROM AllCarsByEntity;



# Suma wszsytkich zarejestrowanych aut wg. kraju i roku

SELECT * FROM newcars;

SELECT 
    Entity,
    Year,
    battery_electric_number + plugin_hybrid_number + full_mild_hybrid_number + petrol_number + diesel_gas_number AS SumByYearAndEntity
FROM
    newcars
ORDER BY 1;



# Suma wszystkich zarejestrowanych aut wg roku

SELECT 
    Year,
    SUM(battery_electric_number) + SUM(plugin_hybrid_number) + SUM(full_mild_hybrid_number) + SUM(petrol_number) + SUM(diesel_gas_number) AS SumByYear
FROM
    newcars
GROUP BY Year;


# Sprawdzam % zarejestrowanych samochodów Elektrycznych, Plugin i Hybrydowych w stosunku do wszystkich zarejesrowanych pojazdów wg. kraju

SELECT 
    Entity,
    Year,
    ((ElectricCars + PluginHybridCars + FullMildHybridCars) / Sum) * 100 AS '%SamochodówElPlugHyb'
FROM
    AllCarsByEntity
ORDER BY 3 DESC;

			# W latach 2001 - 2019 największy procent nowo zarejestrowanych aut Elektrycznych, Plugin i Hybrydowych był w Norwegii i wyniósł 40,49% 
            # wszystkich zarejestrowanych aut


# Sprawdzić % zarejestrowanych samochodów Elektrycznych, Plugin i Hybrydowych w stosunku do wszystkich zarejesrowanych pojazdów wg. lat

CREATE TABLE AllCarsByYear 
SELECT 
	ElectricHybridCars.Year,
    SUM(battery_electric_number) AS ElectricCars,
    SUM(plugin_hybrid_number) AS PluginHybridCars,
    SUM(full_mild_hybrid_number) AS FullMildHybridCars,
    SUM(petrol_number) AS PetrolCars,
    SUM(diesel_gas_number) AS DieselCars FROM
    ElectricHybridCars
        JOIN
    PetrolDieselCars ON ElectricHybridCars.id = PetrolDieselCars.id
GROUP BY Year;

SELECT * FROM AllCarsByYear;

ALTER TABLE AllCarsByYear
ADD Sum INT;

UPDATE AllCarsByYear
SET Sum = ElectricCars + PluginHybridCars + FullMildHybridCars + PetrolCars + DieselCars;

SELECT 
    Year,
    ((ElectricCars + PluginHybridCars + FullMildHybridCars) / Sum) * 100 AS '%SamochodówElPlugHyb'
FROM
    AllCarsByYear
ORDER BY 2 DESC;
		
					# Jak można zauważyć stosunek rejestrowanych samochodów elektrycznych, hybrydowych oraz plugin do pozostałych zródeł zasilania 
                    # stale rośnie osiągając 9,14% w roku 2019.
                    
                    


# Sprawdzenie jak wyglądało rejestrowanie aut we Francji 

SELECT * FROM NewCars
WHERE Entity = 'France'
Order by Year DESC;


# Obliczenie zmian ilości nowo rejestrowancyh aut na dielsa we Francji 

SELECT Year, diesel_gas_number - LAG(diesel_gas_number) OVER(ORDER BY id) AS ZmianaNowychSamochodówDiesla
FROM NewCars
WHERE Entity = "France"
ORDER BY 2;

					# We Francji od 2009 roku można zauważyć, że rok do roku resjestrowancyh jest coraz mniej samochodów na ropę za wyjątkiem roku 2011,
                    # w którym był delikatny wzrost względem roku 2010. Najbardziej znaczące spadki odnotowane zostały w latach 2012, 2013 oraz 2018.