SELECT *
FROM PortfolioManagmentProject..CovidDeaths
where continent is not null
order by 3,4

--SELECT *
--FROM PortfolioManagmentProject..CovidVaccinations
--order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioManagmentProject..CovidDeaths
order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract COVID in India
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioManagmentProject..CovidDeaths
Where location = 'India'
order by 1,2

--Looking at the Total cases vs Population
--Shows what percentage of popualiton got COVID

SELECT location, date, population, total_cases, (total_cases/population)*100 as CasePercentage
FROM PortfolioManagmentProject..CovidDeaths
--Where location = 'India'
order by 1,2


--Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as CasePercentage
FROM PortfolioManagmentProject..CovidDeaths
--Where location = 'India'
group by location, population
order by CasePercentage desc


--Showing Countries with highest Death Count per Population

SELECT location, MAX(Cast (total_deaths as int)) as TotalDeathCount
FROM PortfolioManagmentProject..CovidDeaths
--Where location = 'India'
where continent is not null
group by location
order by TotalDeathCount desc


--Break down by Continent

SELECT continent, MAX(Cast (total_deaths as int)) as TotalDeathCount
FROM PortfolioManagmentProject..CovidDeaths
--Where location = 'India'
where continent is not null
group by continent
order by TotalDeathCount desc


-- Showing continent with highest Death count per population

SELECT continent, MAX(Cast (total_deaths as int)) as TotalDeathCount
FROM PortfolioManagmentProject..CovidDeaths
--Where location = 'India'
where continent is not null
group by continent
order by TotalDeathCount desc


--GLOBAL Numbers datewise

SELECT date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases) as DeathPercentage
FROM PortfolioManagmentProject..CovidDeaths
--Where location = 'India'
where continent is not null
group by date
order by 1,2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeaopleVaccinated
From PortfolioManagmentProject..CovidDeaths dea
Join PortfolioManagmentProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null and new_vaccinations is not null
order by 2,3


--Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeaopleVaccinated
From PortfolioManagmentProject..CovidDeaths dea
Join PortfolioManagmentProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null and new_vaccinations is not null
)

Select *, (RollingPeopleVaccinated/population)*100 as PercentageRollingPeople
From PopvsVac


--Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeaopleVaccinated
From PortfolioManagmentProject..CovidDeaths dea
Join PortfolioManagmentProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100 as PercentageRollingPeople
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

CREATE View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeaopleVaccinated
From PortfolioManagmentProject..CovidDeaths dea
Join PortfolioManagmentProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null


Select *
From PercentPopulationVaccinated