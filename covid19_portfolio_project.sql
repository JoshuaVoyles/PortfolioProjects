SELECT *
FROM covid_deaths
WHERE continent is not null;

SELECT populations
FROM deaths;

ALTER TABLE vaccinations
RENAME TO covid_vaccinations;

SELECT *
FROM vaccinations;

SELECT
  location,
  date,
  total_cases,
  new_cases,
  total_deaths,
  population
FROM covid_deaths
WHERE location IS 'United States';
  
  -- Looking at Total Cases vs Total Deaths
  
SELECT
  location,
  date,
  total_cases,
  total_deaths,
  (total_deaths/total_cases) * 100 AS death_percentage
FROM covid_deaths
WHERE location like '%states%';

-- Looking at total cases vs population
-- Shows percentage of population that got covid. 

SELECT
  location,
  date,
  total_cases,
  population,
  (total_cases/population) * 100 AS death_percentage
FROM covid_deaths
WHERE location like '%states%';

-- Countries with highest infection rate compared to population.

SELECT
  location,
  population,
  MAX(total_cases) AS highest_infection_count,
  MAX((total_cases/population)) * 100 AS percent_population_infected
FROM covid_deaths
GROUP BY
  location,
  population
ORDER BY percent_population_infected DESC;

-- Showing countries with highest death count per population.

SELECT
  location,
  MAX(total_deaths) AS total_death_count
FROM covid_deaths
GROUP BY location
ORDER BY total_death_count DESC;

SELECT
  continent,
  MAX(total_deaths) AS total_death_count
FROM covid_deaths
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count DESC;


-- Showing continents with highest death count per population.

SELECT
  continent,
  MAX(total_deaths) AS total_death_count
FROM covid_deaths
GROUP BY continent
ORDER BY total_death_count DESC;

-- Showing the contintents with the highest death counts.

SELECT
  date,
  SUM(new_cases) AS total_cases,
  SUM(new_deaths) AS total_deaths,
  SUM(new_deaths)/SUM(new_cases) * 100 as death_percentage
-- WHERE continent IS NOT NULL
FROM covid_deaths
GROUP BY date;

-- Global Numbers per day. 
SELECT
  date,
  SUM(new_cases) AS total_cases,
  SUM(new_deaths) AS total_deaths,
  SUM(new_deaths)/SUM(new_cases) * 100 as death_percentage
FROM covid_deaths
GROUP BY date;

-- Total death percentage

SELECT
  -- date,
  SUM(new_cases) AS total_cases,
  SUM(new_deaths) AS total_deaths,
  SUM(new_deaths)/SUM(new_cases) * 100 as death_percentage
FROM covid_deaths
-- GROUP BY date;

-- Looking at Total Population vs Vaccinations

SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccination_count
FROM covid_deaths AS dea
JOIN covid_vaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3;

-- Use CTE
WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_vaccination_count)
AS 
(
SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccination_count
FROM covid_deaths AS dea
JOIN covid_vaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3
)
SELECT *,(rolling_vaccination_count/population) * 100
FROM pop_vs_vac;

-- Temp Table

select convert(varchar, getdate(), 23)

DROP TABLE IF EXISTS percent_population_vaccinated
Create Table percent_population_vaccinated
(
continent varchar(255),
location varchar(255),
date date,
population numeric,
new_vaccinations int,
rolling_people_vaccinated numeric
);

UPDATE covid_vaccinations
SET new_vaccinations = 0
WHERE new_vaccinations = '';

SELECT *
FROM percent_population_vaccinated

INSERT INTO percent_population_vaccinated
SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM covid_deaths AS dea
JOIN covid_vaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3;

SELECT *,(rolling_people_vaccinated/population) * 100
FROM percent_population_vaccinated;

-- Creating View to store data for later visulizations

CREATE VIEW percentpopulationvaccinated AS 
SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM covid_deaths AS dea
JOIN covid_vaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 1,2,3;

SELECT *
FROM percentpopulationvaccinated;