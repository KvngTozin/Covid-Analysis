select *
from covid..CovidDeaths
where continent is not null
order by 3,4

-- percentage of deaths per cases

select location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 as deathpercent
from covid..CovidDeaths
where location like '%africa%'
order by 1,2

-- percentage of total cases per population

select location, date, population, total_cases,total_deaths, (total_cases/population)*100 as casepercent
from covid..CovidDeaths
where location like '%africa%'
order by 1,2

-- percentage of highest infection rate per population

select location, population, max(total_cases) as highest_infection_count, max((total_cases/population))*100 as casepercent
from covid..CovidDeaths
group by location, population
order by 4 desc

-- highest death count per population

select location, max(cast(total_deaths as int)) as death_count
from covid..CovidDeaths
where continent is null
group by location
order by 2 desc

-- continents with high death counts per population

select continent, max(cast(total_deaths as int)) as death_count
from covid..CovidDeaths
where continent is not null
group by continent
order by 2 desc

-- Global numbers
select sum(new_cases) as Total_cases,sum(cast(new_deaths as int)) as Total_deaths, 
sum(cast(new_deaths as int))/ sum(new_cases)*100 as death_percent
from covid..CovidDeaths
where continent is not null
order by 1,2

-- Total population that are vaccinated
-- using a CTE

with tosin (continent,location, population, date, new_vaccinations, Rolling_vaccinated) 
as
(
select 
	dea.continent,
	dea.location ,
	dea.population,
	dea.date,
	vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rolling_vaccinated
from covid..CovidDeaths dea
join covid..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)

select 
	*,
	(Rolling_vaccinated/population)*100
from tosin

-- using a temp table
drop table if exists #percent_population_vaccinated
create table #percent_population_vaccinated
(
	continent nvarchar(255),
	location nvarchar(255),
	population numeric,
	date datetime,
	new_vaccinations numeric,
	Rolling_vaccinated numeric
)
insert into #percent_population_vaccinated
select 
	dea.continent,
	dea.location ,
	dea.population,
	dea.date,
	vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rolling_vaccinated
from covid..CovidDeaths dea
join covid..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select 
	*,
	(Rolling_vaccinated/population)*100
from #percent_population_vaccinated
order by 2,3

-- create view to store data for later
create view continent_death_count as

select continent, max(cast(total_deaths as int)) as death_count
from covid..CovidDeaths
where continent is not null
group by continent
