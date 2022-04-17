SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..COVIDDeaths$
ORDER BY 1, 2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying of contracted COVID
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..COVIDDeaths$
WHERE location = 'Singapore'
ORDER BY 1, 2;


-- Looking at Total Cases vs Population
-- Shows percentage of population had Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS CasesPercentage
FROM PortfolioProject..COVIDDeaths$
WHERE location = 'Singapore'
ORDER BY 1, 2;

-- Looking at countries with highest infection rate
SELECT location, population, max(total_cases) AS HighestInfectionCount, max((total_cases/population))*100 AS CasesPercentage
FROM PortfolioProject..COVIDDeaths$
WHERE continent IS NOT null
GROUP BY location, population
ORDER BY CasesPercentage DESC;

-- Countries with highest death count per population
SELECT location, max(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..COVIDDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Breaking down by continent
-- Showing continents with highest death count
SELECT continent, max(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..COVIDDeaths$
WHERE continent IS NOT null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Global Numbers
SELECT date, sum(new_cases) AS TotalCases, sum(cast(new_deaths AS int)) AS TotalDeaths, 
  sum(cast(new_deaths AS int))/sum(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..COVIDDeaths$
WHERE continent IS NOT null
GROUP BY date
ORDER BY 1;

SELECT sum(new_cases) AS TotalCases, sum(cast(new_deaths AS int)) AS TotalDeaths, 
  sum(cast(new_deaths AS int))/sum(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..COVIDDeaths$
WHERE continent IS NOT null
ORDER BY 1

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations AS bigint)) over (Partition BY dea.location ORDER BY dea.location , 
	dea.date) AS CumulativeVaccinated
FROM PortfolioProject..COVIDDeaths$ dea
JOIN PortfolioProject..COVIDVaccinations$ vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT null
ORDER BY 1,2,3

-- Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, CumulativeVaccinated) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations AS bigint)) over (Partition BY dea.location ORDER BY dea.location , 
	dea.date) AS CumulativeVaccinated
FROM PortfolioProject..COVIDDeaths$ dea
JOIN PortfolioProject..COVIDVaccinations$ vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT null
)
SELECT *, (CumulativeVaccinated/population)*100 AS CumulativePercentage
FROM PopvsVac
ORDER BY 1,2,3


-- Temp Table

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
CumulativeVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations AS bigint)) over (Partition BY dea.location ORDER BY dea.location , 
	dea.date) AS CumulativeVaccinated
FROM PortfolioProject..COVIDDeaths$ dea
JOIN PortfolioProject..COVIDVaccinations$ vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT null
ORDER BY 1,2,3

SELECT *, (CumulativeVaccinated/population)*100 AS CumulativePercentage
FROM #PercentPopulationVaccinated
ORDER BY 1,2,3

-- Creating View to store date for later visualisations

CREATE View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations AS bigint)) over (Partition BY dea.location ORDER BY dea.location , 
	dea.date) AS CumulativeVaccinated
FROM PortfolioProject..COVIDDeaths$ dea
JOIN PortfolioProject..COVIDVaccinations$ vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT null
