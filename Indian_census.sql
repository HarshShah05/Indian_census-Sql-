use Cencus_India

select* from dbo.Data1
select* from dbo.Data2

--1 Number_of_rows in our dataset

select count(District)
from Data1


--2 Select for jharkhand and bihar

select *
from Data1
where State in('bihar','jharkhand')

--3 Population of india
select sum(Population) as Population
from Data2


--4 Avg growth 

select avg(Growth)*100
from Data1

--5 Average growth by state

select State, round(avg(Growth)*100,0)as Average_growth
from Data1
group by State
--having round(avg(Growth)*100,0)>50
order by Average_growth desc

--6 top 3 having highest average growth rate

select b.* from(
select State ,Average_growth, rank()over( order by Average_growth desc) rnk from
(select State, round(avg(Growth)*100,0)as Average_growth
from Data1
group by State)a)b
where rnk in (1,2,3)



--7 bottom 3 in sex ratio.....order in ascending order

select top 3 State, round(avg(Sex_ratio),0) as Avg_sex_ratio
from Data1
where State is not null
group by State


--8  top3 and bottom 3 in literacy


--Indivisual
select top 3 State, round(avg(Literacy),0) as Avg_literacy
from Data1
where State !='State' 
group by State
order by Avg_literacy

select top 3 State, round(avg(Literacy),0) as Avg_literacy
from Data1
where State != 'State'
group by State 
order by Avg_literacy desc


---But for joining them we have to use make temporary tables and join them via union operator

drop table  if exists Maxi
create table Maxi(
state nvarchar(255),
topstate float
)
insert into Maxi
select  State, round(avg(Literacy),0) as Avg_literacy
from Data1
where State !='State' 
group by State
order by Avg_literacy desc

select top 3 * from Maxi
order by topstate desc


drop table  if exists Mini
create table Mini(
state nvarchar(255),
bottomstate float
)
insert into Mini
select  State, round(avg(Literacy),0) as Avg_literacy
from Data1
where State !='State' 
group by State
order by Avg_literacy desc

select top 3 * from Mini
order by bottomstate

---union_operator

select* from
(select* from
(select top 3 * from Maxi
order by topstate desc)a
union
select* from
(select top 3 * from Mini
order by bottomstate )b)c
order by topstate


--9 Calculate no_of_females and no_of males 
--females/male = sex-ratio
--females+male=population

--females= pop-male
--(pop-male)=sex-ratio*male
--pop=male(1+sex-ratio)


--male=pop/(1+sex-ratio)-----final male count
--female=pop-(pop/(1+sex-ratio))----(pop*sex-ratio)/(1+s)

select distinct(a.District),a.State,a.Sex_Ratio,b.Population,Population/(Sex_Ratio+1) as Males , (Population*Sex_Ratio)/(1+Sex_Ratio) as Females
from Data1 a
inner join Data2 b on a.District=b.District


--10...Calculate the population in previous census

--prev+ growth*prev = current population
--prev_population= current_populatio/1+growth


select q,r.total_area 
from(
select '1' as keyy , n.* from(	
select sum(prev_year_pop) as prev_year_tot_pop , sum(population) as current_year_tot_pop from
(select District,State, round(Population/(1+Growth),0) as prev_year_pop , Population as population from 
(select a.District, a.state,a.growth , b.population  
from Data1 a
inner join Data2 b on a.District=b.District)d)e)n) q inner join(
--select '1' as keyy , z.* from(
--select sum(area_km2) total_area from Data2)z) r on q.keyy=r.keyy)

--11. area vs population
--areakm2 not present due to glitches.
--if present assumed , writting the query
--we wanna join both this area and above result of prev and current population, but we dont have a common column so we will use key to give common column to both



--12...select top 3 literact districts from each state
--window function

select*
from Data1


---without window function also output is coming but we want only three for each so use window
select b.* from(
select *, rank() over(partition by State order by Literacy desc) as rnk from(
select State,District,Literacy
from Data1
group by State,District,Literacy
having state is not null
)a)b
where rnk in(1,2,3)

