SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..['07-08-21 Covid Death$']
ORDER By 1,2


SELECT location,date,population,total_cases,new_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..['07-08-21 Covid Death$']
WHERE location like '%states%'
ORDER By 1,2

SELECT location,population, MAX(total_cases) as HighestInfectionCount, Max((total_deaths/total_cases))*100 as PercentPopulationInfected
FROM PortfolioProject..['07-08-21 Covid Death$']
--WHERE location like '%states%'
Group by location, population
ORDER By PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..['07-08-21 Covid Death$']
--WHERE location like '%states%'
Where continent is not null
Group by location
ORDER By TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINT


SELECT Continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..['07-08-21 Covid Death$']
Where continent is not null
Group by Continent
ORDER By TotalDeathCount desc

-- showing continents with the hihest death count per population

SELECT Continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..['07-08-21 Covid Death$']
Where continent is not null
Group by Continent
ORDER By TotalDeathCount desc

-- Global Number

SELECT date, SUM(new_cases) as Total_cases, SUM(CAST(new_deaths as int)) as Total_Deaths, SUM(Cast(new_deaths as int))/SUM
 (New_Cases)*100 as DeathPercentage
-- total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..['07-08-21 Covid Death$']
--WHERE location like '%states%
WHERE continent is not null
Group BY date
ORDER By 1,2

--Looking at Total Population vs Vaccinations


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
   dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['07-08-21 Covid Death$'] dea
Join PortfolioProject..['07-08-21 Covid Vaccination$'] vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
ORDER By 2,3


--USE CTE

With PopvsVac (Continent, location, date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
   dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['07-08-21 Covid Death$'] dea
Join PortfolioProject..['07-08-21 Covid Vaccination$'] vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--ORDER By 2,3
)
SELECT*, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
   dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['07-08-21 Covid Death$'] dea
Join PortfolioProject..['07-08-21 Covid Vaccination$'] vac
    On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--ORDER By 2,3

SELECT*, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
   dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['07-08-21 Covid Death$'] dea
Join PortfolioProject..['07-08-21 Covid Vaccination$'] vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--ORDER By 2,3


Select*
FROM PercentPopulationVaccinated