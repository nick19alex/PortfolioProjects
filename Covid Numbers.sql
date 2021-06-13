select * from [Covid Deaths]
where continent is not null
order by 3,4

select * from [Covid Vaccinations]
order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population from [Covid Deaths] order by 1,2

--likelihood of dying if you contract covid in India

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage 
from [Covid Deaths] where location like '%india%' and continent is not null order by 1,2

--looking at total cases vs population

select Location, date, total_cases, Population, (total_cases/Population)*100 as Infected_Population_Percentage
from [Covid Deaths] where location like '%india%' and continent is not null order by 1,2

--Looking at countries with highest infection rate compared to population

select Location, Population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/Population))*100 as Infected_Population_Percentage
from [Covid Deaths] where continent is not null Group by Location, Population order by Infected_Population_Percentage desc

--Countries with highest death count

select Location, MAX(cast(total_deaths as int)) as Total_Death_Count
from [Covid Deaths] where continent is not null Group by Location order by Total_Death_Count desc

--Continents with highest death count

select continent, MAX(cast(total_deaths as int)) as Total_Death_Count
from [Covid Deaths] where continent is not null Group by continent order by Total_Death_Count desc

select location, MAX(cast(total_deaths as int)) as Total_Death_Count
from [Covid Deaths] where continent is null Group by location order by Total_Death_Count desc

--Global Numbers

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 
as Global_Death_Percentage 
from [Covid Deaths] where continent is not null group by date order by 1,2

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 
as Global_Death_Percentage 
from [Covid Deaths] where continent is not null order by 1,2

--Looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as Total_People_Vaccinated
from [Covid Deaths] dea join [Covid Vaccinations] vac on dea.location=vac.location and dea.date = vac.date
where dea.continent is not null order by 2,3

--Using CTE

with PopsvsVac (Continent, Location, Date, Population, New_Vaccination, Total_People_Vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as Total_People_Vaccinated
from [Covid Deaths] dea join [Covid Vaccinations] vac on dea.location=vac.location and dea.date = vac.date
where dea.continent is not null --order by 2,3
)
Select *, Total_People_Vaccinated/population*100 from PopsvsVac

--Temp table

Drop table if exists #Percent_Population_Vaccinated
create table #Percent_Population_Vaccinated
(Continent nvarchar(255), Location nvarchar(255), Date datetime, Population numeric, New_Vaccination numeric, Total_People_Vaccinated numeric)

insert into #Percent_Population_Vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as Total_People_Vaccinated
from [Covid Deaths] dea join [Covid Vaccinations] vac on dea.location=vac.location and dea.date = vac.date
where dea.continent is not null --order by 2,3

Select *, Total_People_Vaccinated/population*100 from #Percent_Population_Vaccinated

--Creating view to store data for later visualizations

create view Percent_Population_Vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as Total_People_Vaccinated
from [Covid Deaths] dea join [Covid Vaccinations] vac on dea.location=vac.location and dea.date = vac.date
where dea.continent is not null --order by 2,3

select * from Percent_Population_Vaccinated 


