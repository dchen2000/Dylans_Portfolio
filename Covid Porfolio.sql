select *
From PortfolioProjects..Coviddeaths
where continent is not null
order by 3,4

--select *
--From [dbo].[CovidVaccinations]
--order by 3,4

--Select Data that we are going to be using

select location, date,total_cases, new_cases, total_deaths, population
From PortfolioProjects..Coviddeaths
order by 1,2

--Looking at total cases vs total deaths
--Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (cast(total_deaths as numeric))/ cast(total_cases as numeric)*100 as deathpercentage
From PortfolioProjects..Coviddeaths
where location like '%states%'
order by 1,2

--Looking at the total cases vs the population 
--shows what % of population get covid 
select location, date, population,total_cases, (cast(total_cases as numeric))/ cast(population as numeric)*100 as InfectedPercentage
From PortfolioProjects..Coviddeaths
where location like '%states%'
order by 1,2

--looking at countries with highest infection rate compared to population

select location, population,max(total_cases), (max(cast(total_cases as int))/population)*100 as PercentPopulationInfected
From PortfolioProjects..Coviddeaths
Group by location, population
order by PercentPopulationInfected desc

--showing countries with highest death count per population

select location,max(cast(total_deaths as int)) as TotalDeath
From PortfolioProjects..Coviddeaths
where continent is not null
Group by location
order by TotalDeath desc

-- Lets break things down by continent 
--showing continents with highest death count

select continent,max(cast(total_deaths as int)) as TotalDeath
From PortfolioProjects..Coviddeaths
where continent is not null
Group by continent
order by TotalDeath desc

-- global numbers

SELECT
  date
    SUM(ISNULL(new_cases, 0)) AS total_cases,
    SUM(ISNULL(new_deaths, 0)) AS total_deaths,
    SUM(ISNULL(new_deaths, 0)) / NULLIF(SUM(ISNULL(new_cases, 0)), 0) AS death_percentage
FROM PortfolioProjects..Coviddeaths
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER By  date, death_percentage;

--looking at total pop vs vaccinations
--USE CTE

With PopvsVac (Continent, Location, Date, Population,New_vaccinations,  cumulative_new_vaccinations)
as
(
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, ISNULL(vac.new_vaccinations, 0))) OVER (PARTITION BY dea.location ORDER BY dea.date) AS cumulative_new_vaccinations
	
FROM PortfolioProjects..Coviddeaths dea
JOIN PortfolioProjects..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY dea.location, dea.date
)
Select *, (Cumulative_new_vaccinations/population)*100
from PopvsVac

--Temp Table
DROp table if exists  #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
cumulative_new_vaccinations numeric,
)


Insert into #PercentPopulationVaccinated
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, ISNULL(vac.new_vaccinations, 0))) OVER (PARTITION BY dea.location ORDER BY dea.date) AS cumulative_new_vaccinations
	
FROM PortfolioProjects..Coviddeaths dea
JOIN PortfolioProjects..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY dea.location, dea.date
Select *, (Cumulative_new_vaccinations/population)*100
from #PercentPopulationVaccinated





--Creating view to store data for later visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, ISNULL(vac.new_vaccinations, 0))) OVER (PARTITION BY dea.location ORDER BY dea.date) AS cumulative_new_vaccinations
FROM PortfolioProjects..Coviddeaths dea
JOIN PortfolioProjects..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

Select *
from PercentPopulationVaccinated