select *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

-- Looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
and continent is not null
order by 1,2

-- Looking at total cases vs population
-- shows what percentage of population got covid
select location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
and continent is not null
order by 1,2

-- Looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
where continent is not null
group by location, population
order by PercentPopulationInfected desc

--showing continent with highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc;

-- looking at total population vs vaccinations

with PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
sum(convert(bigint, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ cd
join PortfolioProject..CovidVaccinations$ cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
)

select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

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
Select cd.continent, cd.location, cd.date, cd.population, cd.new_vaccinations
, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ cd
Join PortfolioProject..CovidVaccinations$ cv
	On cd.location = cv.location
	and cd.date = cv.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(bigint, cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ cd
Join PortfolioProject..CovidVaccinations$ cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null


