select * 
from PortfolioProject..Walmart_stores

-- Total number of store by each type

select TYPE,COUNT(Store) as NumberOfStore
from PortfolioProject..Walmart_stores
group by Type

select * 
from PortfolioProject..Walmart_features

--Showing data when holiday is yes

select Store,Date, Temperature,Fuel_Price,Unemployment, IsHoliday
from PortfolioProject..Walmart_features
where IsHoliday = 1
order by date

--Showing data when holiday is no

select Store,Date, Temperature,Fuel_Price,Unemployment, IsHoliday
from PortfolioProject..Walmart_features
where IsHoliday = 0
order by date


select * 
from PortfolioProject..Walmart_features

--Showing all markdown column with NA values only

select Store,Date,MarkDown1,MarkDown2,MarkDown3,MarkDown4,MarkDown5 
from PortfolioProject..Walmart_features
where MarkDown1 = 'NA'
order by Store

--Showing all markdown column without NA values only

select Store,Date,MarkDown1,MarkDown2,MarkDown3,MarkDown4,MarkDown5 
from PortfolioProject..Walmart_features
where MarkDown1 <> 'NA'
order by Store

-- Checking the data type of each column

exec sp_help Walmart_features

--MarkDown columns contain NA value so let's convert into Null value

UPDATE PortfolioProject..Walmart_features
SET MarkDown1 = TRY_CONVERT(float,MarkDown1), 
    MarkDown2 = TRY_CONVERT(float,MarkDown2),
	MarkDown3=TRY_CONVERT(float,MarkDown3),
	MarkDown4=TRY_CONVERT(float,MarkDown4),
	MarkDown5=TRY_CONVERT(float,MarkDown5)

UPDATE PortfolioProject..Walmart_features
SET CPI = TRY_CONVERT(float,CPI),
    Unemployment = TRY_CONVERT(float,Unemployment)


	
select *
from PortfolioProject..Walmart_features
order by Date

--Let's join the three table

select * 
from PortfolioProject..Walmart W
join PortfolioProject..Walmart_stores WS
     on W.Store = WS.Store
	 join PortfolioProject..Walmart_features WF
	      on W.Store = WF.Store
		  and W.Date = WF.Date
order by W.date


--Let's check Duplicate value

select *,
row_number () over (partition by 
                              W.Store,
							  W.Dept,
							  W.Date order by W.date) row_num

from PortfolioProject..Walmart W
join PortfolioProject..Walmart_stores WS
     on W.Store = WS.Store
	 join PortfolioProject..Walmart_features WF
	      on W.Store = WF.Store
		  and W.Date = WF.Date
--There is no duplicate value

--Checking null values in sales column

select Dept,Date,Weekly_Sales
from PortfolioProject..Walmart
where Weekly_Sales is  null
order by Date

--There is no null values in sales column, SO in this case we have null values in Walmart feature table
--- Changing the data dtype
--MarkedDown 1
ALTER TABLE PortfolioProject..Walmart_features
alter COLUMN MarkDown1 float

--MarkedDown 2

ALTER TABLE PortfolioProject..Walmart_features
alter COLUMN MarkDown2 float

--MarkedDown 3
ALTER TABLE PortfolioProject..Walmart_features
alter COLUMN MarkDown3 float

--MarkedDown 4
ALTER TABLE PortfolioProject..Walmart_features
alter COLUMN MarkDown4 float

--MarkedDown 5
ALTER TABLE PortfolioProject..Walmart_features
alter COLUMN MarkDown5 float

--CPI
ALTER TABLE PortfolioProject..Walmart_features
alter COLUMN CPI float

--Unemployment
ALTER TABLE PortfolioProject..Walmart_features
alter COLUMN Unemployment float


select *
from Walmart

exec sp_help Walmart
--Changing the null values by previous value

With newwalmarttable as 
(select *,
      COUNT(CPI) over (partition by Store order by Date) as grp,
	  COUNT(Unemployment) over (partition by Store order by Date) as grpU
from PortfolioProject..Walmart_features)
select *,
      first_value(CPI) over (partition by Store, grp order by date) as CPI2,
	  first_value(Unemployment) over (partition by Store, grpU order by date) as Unemployment2
	  from newwalmarttable

update PortfolioProject..Walmart_features
set CPI =newwalmarttable.CPI2

--For every store comapny does not have any markdown value from   2010-02-05 to 2011-11-01, So we can add 0 to these value

--markdown1

update PortfolioProject..Walmart_features
set MarkDown1 = ISNULL(MarkDown1,0)

--markdown2

update PortfolioProject..Walmart_features
set MarkDown2 = ISNULL(MarkDown2,0)


--markdown3

update PortfolioProject..Walmart_features
set MarkDown3 = ISNULL(MarkDown3,0)


--markdown4

update PortfolioProject..Walmart_features
set MarkDown4 = ISNULL(MarkDown4,0)


--markdown5

update PortfolioProject..Walmart_features
set MarkDown5 = ISNULL(MarkDown5,0)

--I will convert 1 to Yes and 0 to No in isholiday column

exec sp_help Walmart

select *
from Walmart


select * 
from PortfolioProject..Walmart W
join PortfolioProject..Walmart_stores WS
     on W.Store = WS.Store
	 join PortfolioProject..Walmart_features WF
	      on W.Store = WF.Store
		  and W.Date = WF.Date
order by W.date

--Now we have done all the data manupulation. Let's do data exploration

--showing Depatmentwise salse

select W.Dept,SUM(weekly_sales) as Total_deptsales
from PortfolioProject..Walmart W
join PortfolioProject..Walmart_stores WS
     on W.Store = WS.Store
	 join PortfolioProject..Walmart_features WF
	      on W.Store = WF.Store
		  and W.Date = WF.Date
group by W.Dept
order by Total_deptsales desc

--showing store-wise salse

select W.Store,SUM(weekly_sales) as Total_storesales
from PortfolioProject..Walmart W
join PortfolioProject..Walmart_stores WS
     on W.Store = WS.Store
	 join PortfolioProject..Walmart_features WF
	      on W.Store = WF.Store
		  and W.Date = WF.Date
group by W.Store
order by Total_storesales desc


--showing store-wise salse

select WS.Type,SUM(weekly_sales) as Total_typesales
from PortfolioProject..Walmart W
join PortfolioProject..Walmart_stores WS
     on W.Store = WS.Store
	 join PortfolioProject..Walmart_features WF
	      on W.Store = WF.Store
		  and W.Date = WF.Date
group by WS.Type
order by Total_typesales desc

--updating isholiday (yes in case 1 and No in 0)

--showing sales in holidays period
 
 select W.IsHoliday,weekly_sales,
 case
     when W.IsHoliday = 1 then 'Yes'
	 else 'No'
end as Holiday
from PortfolioProject..Walmart W
join PortfolioProject..Walmart_stores WS
     on W.Store = WS.Store
	 join PortfolioProject..Walmart_features WF
	      on W.Store = WF.Store
		  and W.Date = WF.Date
where W.IsHoliday = 1
order by weekly_sales desc


--showing sales in when there is no holiday

 select W.IsHoliday,weekly_sales,
 case
     when W.IsHoliday = 1 then 'Yes'
	 else 'No'
end as NotHoliday
from PortfolioProject..Walmart W
join PortfolioProject..Walmart_stores WS
     on W.Store = WS.Store
	 join PortfolioProject..Walmart_features WF
	      on W.Store = WF.Store
		  and W.Date = WF.Date
where W.IsHoliday = 0
order by weekly_sales desc

--Showing yearly wise sales

ALTER TABLE PortfolioProject..Walmart
alter COLUMN Date Date


select Year(W.Date) as Year_date,weekly_sales
from PortfolioProject..Walmart W
join PortfolioProject..Walmart_stores WS
     on W.Store = WS.Store
	 join PortfolioProject..Walmart_features WF
	      on W.Store = WF.Store
		  and W.Date = WF.Date

order by Year_date

--Showing week wise sales


ALTER TABLE Walmart
ADD  NumberOfWeek int
SELECT * FROM Walmart

update Walmart
set NumberOfWeek=datepart(WEEK,Date)



select NumberOfWeek,sum(Weekly_Sales) as Weekly_Sales
from PortfolioProject..Walmart W
join PortfolioProject..Walmart_stores WS
     on W.Store = WS.Store
	 join PortfolioProject..Walmart_features WF
	      on W.Store = WF.Store
		  and W.Date = WF.Date
group by NumberOfWeek
order by  Weekly_Sales

--showing weekly sales as per size of store

select Size,sum(Weekly_Sales) as Weekly_Sales
from PortfolioProject..Walmart W
join PortfolioProject..Walmart_stores WS
     on W.Store = WS.Store
	 join PortfolioProject..Walmart_features WF
	      on W.Store = WF.Store
		  and W.Date = WF.Date
group by Size
order by  Weekly_Sales















































