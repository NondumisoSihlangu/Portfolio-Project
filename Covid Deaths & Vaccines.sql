-- Data we're going to be using

select location, date, population, new_cases, total_cases, total_deaths
from CovidDeaths
where continent is not null
order by location,date

--Total cases vs Total Deaths for all locations (likelihood of a person living in SA dying after getting Covid)

select location, date, population, total_cases, total_deaths, (CAST(total_deaths AS float) / CAST(total_cases AS float) * 100) as DeathPercentages
from CovidDeaths
where continent is not null
where location = 'South Africa'
order by location,date


--Total cases vs population. The percentage of the population in South Africa that got Covid

select location, date, population, total_cases, (CAST(total_cases AS float) / CAST(population AS float) * 100) as PopulationPercentages
from CovidDeaths
where location = 'South Africa' 
order by location,date

-- The total percentage of the population that got Covid since 2020 is less than 10% 

-- Countries with highest infection rate compared to population 

select location, population, max(cast(total_cases as int)) as HighestInfections, max(CAST(total_cases AS float) / CAST(population AS float) * 100) as PopulationPercentages
from CovidDeaths 
where continent is not null 
group by location,population
order by PopulationPercentages desc


--Countries with highest death count per population 

select location, max(CAST(total_deaths AS int)) as TotalDeathCount 
from CovidDeaths 
where continent is not null 
group by location
order by TotalDeathCount desc

--Highest death count per population for each continent

select continent, max(CAST(total_deaths AS int)) as TotalDeathCount 
from CovidDeaths 
where continent is not null
group by continent
order by TotalDeathCount desc


--Total population vs vaccinations
--Rolling number of people that were vaccinated

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(cast(v.new_vaccinations as float)) 
over (partition by d.location order by d.location, d.date) as VaccinatedPeople 
FROM   CovidDeaths as d Join CovidVaccinations as v
       on d.location = v.location and d.date = v.date
where d.continent is not null
order by d.location, d.date


--Create a view for the percentage of people vaccinated

Create View PopulationVaccPercentage as 
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(cast(v.new_vaccinations as float)) 
over (partition by d.location order by d.location, d.date) as VaccinatedPeople 
FROM   CovidDeaths as d Join CovidVaccinations as v
       on d.location = v.location and d.date = v.date
where d.continent is not null



