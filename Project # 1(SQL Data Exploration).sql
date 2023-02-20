SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3, 4 --(this means sort results a/c to column no. 3 and 4)
-- Selecting Data that is going to be used
SELECT location , date, population, new_cases, total_cases,total_deaths
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2
-- Comparing total cases vs total deaths
-- shows chances of dying if someone get infected
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'Pakistan' AND continent IS NOT NULL
ORDER BY 1,2

-- Comparing Total cases vs population
-- Showing what percentage of population is infected
SELECT location, date, total_cases, population, (total_cases / population) * 100 AS PopulationPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location = 'Pakistan'
WHERE continent is NOT NULL
ORDER BY 1,2

-- Looking for countries who got the highest covid cases
SELECT location, MAX(total_cases) AS Highest_infection_Count, population, MAX((total_cases / population)) * 100 AS MaxPopulationPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY MaxPopulationPercentage desc;

-- Showing Countries with highet death count per population
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCount desc;

-- Showing continents with the highest death counts per population
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc;

-- GLOBAL NUMBERS
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths,SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 
AS Death_Percentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2;

SELECT dea.continent, dea.location, dea.date, dea.population, vacc.daily_vaccinations,
SUM(CONVERT(bigint,vacc.daily_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date ROWS UNBOUNDED PRECEDING)
AS total_daily_vaccinations
FROM PortfolioProject.dbo.CovidDeaths  dea
Join PortfolioProject.dbo.CovidVaccinations  vacc
    On dea.location = vacc.country
	and dea.date = vacc.date
WHERE dea.continent is not null
ORDER BY 2,3

--Use ETC
WITH PopvsVac (continent, location, date, population, daily_vaccinations, total_daily_vaccinations) 
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.daily_vaccinations,
SUM(CONVERT(bigint,vacc.daily_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date ROWS UNBOUNDED PRECEDING)
AS total_daily_vaccinations
FROM PortfolioProject.dbo.CovidDeaths  dea
Join PortfolioProject.dbo.CovidVaccinations  vacc
    On dea.location = vacc.country
	and dea.date = vacc.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (total_daily_vaccinations / population) * 100
FROM PopvsVac

-- Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
total_daily_vaccinations numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.daily_vaccinations,
SUM(CONVERT(bigint,vacc.daily_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date ROWS UNBOUNDED PRECEDING)
AS total_daily_vaccinations
FROM PortfolioProject.dbo.CovidDeaths  dea
Join PortfolioProject.dbo.CovidVaccinations  vacc
    On dea.location = vacc.country
	and dea.date = vacc.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (total_daily_vaccinations / population) * 100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.daily_vaccinations,
SUM(CONVERT(bigint,vacc.daily_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date ROWS UNBOUNDED PRECEDING)
AS total_daily_vaccinations
FROM PortfolioProject.dbo.CovidDeaths  dea
Join PortfolioProject.dbo.CovidVaccinations  vacc
    On dea.location = vacc.country
	and dea.date = vacc.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated
