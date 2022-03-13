SELECT location, date, total_cases, new_cases, total_deaths, population FROM PortfolioProject..COVIDDeaths$
Order By 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying of contracted COVID
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..COVIDDeaths$
Where location = 'Singapore'
Order By 1, 2


-- Looking at Total Cases vs Population
-- Shows percentage of population had Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as CasesPercentage
FROM PortfolioProject..COVIDDeaths$
Where location = 'Singapore'
Order By 1, 2

-- Looking at countries with highest infection rate
SELECT location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as CasesPercentage
FROM PortfolioProject..COVIDDeaths$
WHERE continent is not null
group by location, population
Order By CasesPercentage desc

-- Countries with highest death count per population
SELECT location, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..COVIDDeaths$
WHERE continent is not null
group by location
Order By TotalDeathCount desc

-- Breaking down by continent
-- Showing continents with highest death count
SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..COVIDDeaths$
WHERE continent is not null
group by continent
Order By TotalDeathCount desc

-- Global Numbers
SELECT date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, 
  sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM PortfolioProject..COVIDDeaths$
Where continent is not null
group by date
Order By 1

SELECT sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, 
  sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM PortfolioProject..COVIDDeaths$
Where continent is not null
Order By 1

-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location , 
	dea.date) as CumulativeVaccinated
from PortfolioProject..COVIDDeaths$ dea
join PortfolioProject..COVIDVaccinations$ vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

-- Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, CumulativeVaccinated) as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location , 
	dea.date) as CumulativeVaccinated
from PortfolioProject..COVIDDeaths$ dea
join PortfolioProject..COVIDVaccinations$ vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
)
select *, (CumulativeVaccinated/population)*100 as CumulativePercentage
from PopvsVac
order by 1,2,3


-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
CumulativeVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location , 
	dea.date) as CumulativeVaccinated
from PortfolioProject..COVIDDeaths$ dea
join PortfolioProject..COVIDVaccinations$ vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

select *, (CumulativeVaccinated/population)*100 as CumulativePercentage
from #PercentPopulationVaccinated
order by 1,2,3

-- Creating View to store date for later visualisations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location , 
	dea.date) as CumulativeVaccinated
from PortfolioProject..COVIDDeaths$ dea
join PortfolioProject..COVIDVaccinations$ vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

Select * from PercentPopulationVaccinated