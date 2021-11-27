----- COVID DEATHS DATA & QUERIES ------

Select * from 
CovidDeathsAnalysis..CovidDeaths
Where continent is not null
Order by 3,4;

--Selection of the columns to be used

Select location, date, total_cases, new_cases, total_deaths, population
from CovidDeathsAnalysis..CovidDeaths
Order by 1,2; 

--Total no. of cases vs. Total deaths (Chances (in %) of dying after contracting Covid) 
Select location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 As deathRate_percentage 
from CovidDeathsAnalysis..CovidDeaths
Order by 1,2; 

--India
Select location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 As deathRate_percentage 
from CovidDeathsAnalysis..CovidDeaths
where location like 'INDIA'
Order by 1,2; 

--Total no. of cases vs. Population% of persons who contracted Covid
Select location, date, total_cases, population, (total_deaths/total_cases)*100 As deathRate_percentage,
(total_cases/population)*100 As ContractedCovid_percentage 
from CovidDeathsAnalysis..CovidDeaths
Where location = 'India' 
Order by 1,2; 

--Countries with highest contraction rates compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 As ContractedCovid_percentage 
from CovidDeathsAnalysis..CovidDeaths  
Group by population, location
Order by ContractedCovid_percentage DESC; 

--Countries with the highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeathsAnalysis..CovidDeaths  
Where continent is not null
Group by population, location
Order by TotalDeathCount DESC;

--Global total deaths
Select SUM(new_cases) as NewCases, SUM(cast(new_deaths as int)) as NewDeaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as NewDeathPercentage
from CovidDeathsAnalysis..CovidDeaths  
Order by 1,2;

----- COVID VACCINATIONS DATA & QUERIES ------

-- vaccinations 
Select * from 
CovidDeathsAnalysis..CovidVaccinations
Where location = 'India'
Order by 3,4;

-- Joining the 2 tables via common keys (location and date)
Select * from 
CovidDeathsAnalysis..CovidDeaths dea JOIN
CovidDeathsAnalysis..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date  = vac.date;

-- Looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From CovidDeathsAnalysis..CovidDeaths dea
Join CovidDeathsAnalysis..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date  = vac.date
Where dea.continent is NOT NULL 
AND vac.new_vaccinations is NOT NULL
Order by 2,3;

-- COMMON TABLE EXPRESSION (CTE)

WITH PopVsVac (continent,location,date,population,new_vaccinations,rollingvaccination)
as
(
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) AS RollingVaccination
From CovidDeathsAnalysis..CovidDeaths dea
Join CovidDeathsAnalysis..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date  = vac.date
Where dea.continent is NOT NULL 
AND vac.new_vaccinations is NOT NULL
)

SELECT * FROM PopVsVac

