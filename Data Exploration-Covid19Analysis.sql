
--1) Total cases vs total deaths
select location,date,total_cases,total_deaths
from covid19..covid19deaths 
where continent is not null
order by 1,2;


--2) likelihood of dying if contract to covid or death percentage
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from covid19..covid19deaths
where continent is not null
order by 1,2;


--3) Total cases vs population
----shows percentage of population who got covid
select location,date,total_cases,population,total_deaths,(total_cases/population)*100 as infected_population_percentage
from covid19..covid19deaths
where continent is not null
order by 1,2;


--4) Highest infection rate vs population
select location,population,max(total_cases) as highest_infection_count,max((total_cases/population))*100 as infected_population_percentage
from covid19..covid19deaths
where continent is not null 
group by location,population
order by infected_population_percentage desc;


--5) Highest Death Rate vs population
select location,max(cast(total_deaths as int)) as highest_death_count
from covid19..covid19deaths
where continent is not null
group by location
order by highest_death_count desc;


--6) Continent wise analysis
select continent,max(cast(total_deaths as int)) as highest_death_count
from covid19..covid19deaths
where continent is not null
group by continent
order by highest_death_count desc;


--7) Global Numbers
select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as Death_percentage  
from covid19..covid19deaths 
where continent is not null;


--8) Global Numbers date wise
select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as Death_percentage  
from covid19..covid19deaths 
where continent is not null
group by date
order by date;


--9) Total population vs Total Vaccinations
select d.location,population,sum(convert(int,v.new_vaccinations)) as total_vaccinations
from covid19..covid19deaths d
join covid19..covid19vaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null
group by d.location,population
order by 1;


--10) cumulative vaccine count
select d.location,d.date,population,v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) over (Partition by d.location order by d.location,d.date) as Cumulative_vaccine_count
from covid19..covid19deaths d
join covid19..covid19vaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null
order by 1,2;


--11) People vaccinated percentage (CTE)

with popvsvac as 
(select d.location,d.date,population,v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) over (Partition by d.location order by d.location,d.date) as Cumulative_vaccine_count
from covid19..covid19deaths d
join covid19..covid19vaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null
)
select *, (Cumulative_vaccine_count/population)*100 as people_vaccinated_percentage
from popvsvac;


--12) People Vaccinated percentage (TEMP TABLE)
drop table if exists #vaccination_percent
create table #vaccination_percent(
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Cumulative_vaccine_count numeric
)
insert into #vaccination_percent
select d.location,d.date,population,v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) over (Partition by d.location order by d.location,d.date) as Cumulative_vaccine_count
from covid19..covid19deaths d
join covid19..covid19vaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null

select *,(Cumulative_vaccine_count/population)*100 as people_vaccinated_percentage 
from #vaccination_percent
order by 1,2;

