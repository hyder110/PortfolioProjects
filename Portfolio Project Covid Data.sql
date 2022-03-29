select * from PortfolioProject.dbo.CovidDeaths
order by 3,4;

--select * from PortfolioProject.dbo.[CovidVaccinations ]
--order by 3,4;

-- select the data that we are gonna be using 

select Location,date,total_cases,new_cases,total_deaths,population from PortfolioProject.dbo.CovidDeaths
order by 1,2;

-- Looking at Total Cases vs Total Deaths
-- shows the likelihood of dying if you contract covid in your country

select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS Percentage_Death from PortfolioProject.dbo.CovidDeaths
where location='Pakistan'
order by 1,2;

select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS Percentage_Death from PortfolioProject.dbo.CovidDeaths
where location like '%states%'
order by 1,2;

--Looking at the Total Cases vs Population
-- Shows what percenatge of the population has got covid


select Location,date,total_cases,population,(total_cases/population)*100 AS Percentage_Death from PortfolioProject.dbo.CovidDeaths
where location like '%Pakistan%'
order by 1,2;


-- Looking at countries with highest infection rate as compared to population

select Location,population, MAX(total_cases)AS HighestInfectionRate, MAX((total_cases/population))*100 AS Percentage_Infection from PortfolioProject.dbo.CovidDeaths
--where location like '%Pakistan%'
group by  Location ,population
order by Percentage_Infection desc;

-- Look at the highest mortality rate per population

select Location, MAX(cast(total_deaths as int)) AS TotaldeathCount from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by  Location 
order by TotaldeathCount desc;

--Breaking up by Continent
--Showing the continents with highest death counts

select continent, MAX(cast(total_deaths as int)) AS TotaldeathCount from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by  continent 
order by TotaldeathCount desc;


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
Select *
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 



Create View GlobalNumbers as
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
--order by 1,2

select* from GlobalNumbers

Create View ConHighDeaCou as
select continent, MAX(cast(total_deaths as int)) AS TotaldeathCount from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by  continent 
--order by TotaldeathCount desc;


select* from ConHighDeaCou
