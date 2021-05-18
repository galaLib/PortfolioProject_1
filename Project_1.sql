use PortfolioProject_1
 
select *
from CovidDeaths
order by 3,4

select *
from CovidVaccinations
order by 3,4

select cd.location, cd.date, cd.total_cases, cd.new_cases, cd.total_deaths, cd.population
from CovidDeaths as cd
order by 1,2

-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract Covid in Israel
select cd.location, cd.date, cd.total_cases, cd.total_deaths, 
	   round((cd.total_deaths /cd.total_cases) *100, 2) as "Death_percentage"
from CovidDeaths as cd
where cd.location like 'israel'
order by 1,2

-- Looking at total cases vs population
-- Shows what percentage of population got Covid
select cd.location, cd.date, cd.total_cases, cd.population, 
	   round((cd.total_cases/ cd.population) *100, 5) as "Case_percentage"
from CovidDeaths as cd
where cd.location like 'israel'
order by 1,2

-- Looking at countries with highest infection rate comperd to population
select cd.location, cd.population, max(cd.total_cases) as "HighestInfectionCount", 
	   max(cd.total_cases/ cd.population)*100 as "PercentOfPopulationInfected"
from CovidDeaths as cd
where cd.continent is not null
group by cd.location, cd.population
order by PercentOfPopulationInfected desc

--Showing countries with highst death count per population
select cd.location, max(cast(cd.total_deaths as int)) as "TotalDeathCount"
from CovidDeaths as cd
where cd.continent is not null
group by cd.location
order by TotalDeathCount desc

--Let's break things down by continent
select cd.continent, sum(cast(cd.new_deaths as int)) as "TotalDeathCount"
from CovidDeaths as cd
where cd.continent is not null
group by cd.continent
order by TotalDeathCount desc

--Global numbers
select cd.date, sum(cd.new_cases) as "TotalNewCases", 
	   sum(cast(cd.new_deaths as int)) as "TotalNewDeaths",
	   sum(cast(cd.new_deaths as int))/ sum(cd.new_cases)*100 as "DeathPercentage"
from CovidDeaths as cd
where cd.continent is not null
group by cd.date
order by 1,2

select sum(cd.new_cases) as "TotalNewCases", 
	   sum(cast(cd.new_deaths as int)) as "TotalNewDeaths",
	   sum(cast(cd.new_deaths as int))/ sum(cd.new_cases)*100 as "DeathPercentage"
from CovidDeaths as cd
where cd.continent is not null

--Looking at total population vs vaccinations
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	   sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as "RollingPeopleVaccinated"
from CovidDeaths as cd inner join CovidVaccinations as cv
	 on cd.location = cv.location
	 and cd.date = cv.date
where cd.continent is not null
order by 2,3

--TEMP TABLE
drop table if exists #PercentPopulationVaccinated

create table #PercentPopulationVaccinated
(
continent nvarchar(255), 
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric, 
RollingPepoleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	   sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as "RollingPeopleVaccinated"
from CovidDeaths as cd inner join CovidVaccinations as cv
	 on cd.location = cv.location
	 and cd.date = cv.date
where cd.continent is not null

select *, (RollingPepoleVaccinated/ population)*100 as "PercentPopulationVaccinated"
from #PercentPopulationVaccinated
--where location = 'israel'
order by 1,2,3


--Creating view to store data for later visualizations
create view PercentPopulationVaccinated as 
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	   sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as "RollingPeopleVaccinated"
from CovidDeaths as cd inner join CovidVaccinations as cv
	 on cd.location = cv.location
	 and cd.date = cv.date
where cd.continent is not null


