select * from restuarants;

select Date from restuarants;

create table Calendar_Table As
select date from restuarants
where 1=0;

insert into calendar_table(Date)
select date from restuarants;

select * from calendar_table;

Alter table restuarants rename column Date to Datekey_opening;

Alter table calendar_table rename column Date to Datekey_opening;

select year(Datekey_opening) as "Year",
Month(Datekey_opening) as "Monthno",
monthname(Datekey_opening) as "MonthFullName",
CONCAT('Q', CEILING(MONTH(Datekey_Opening) / 3)) AS Quarter,
DATE_FORMAT(Datekey_opening, '%Y-%b') AS YearMonth,
WEEKDAY(Datekey_opening) + 1 AS WeekdayNo,
ELT(WEEKDAY(Datekey_opening) + 1,'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday','Sunday') AS WeekdayName,
case
when month(Datekey_opening) between 4 and 12 then month(datekey_opening)-3
else month(Datekey_opening)+9
end 
as Financial_Month,
case
when month(Datekey_opening) between 4 and 6 then "FQ-1"
when month(Datekey_opening) between 7 and 9 then "FQ-2"
when month(Datekey_opening) between 10 and 12 then "FQ-3"
else "FQ-4"
end 
as FinancialQuarter
from calendar_table;


--  3) Convert the Average cost for 2 column into USD dollars (currently the Average cost for 2 in local currencies --
SELECT 
	restaurantID,
    r.Average_Cost_for_two * c.`USD Rate` AS Average_Cost_in_USD
FROM restuarants r
JOIN Currency c ON r.Currency = C.Currency;


-- 4) Find the Numbers of Resturants based on City and Country --

select r.city,count(r.RestaurantID) As No_of_Restaurants,c.Countryname
from restuarants r
left join country c on r.countrycode=c.countryID
group by r.city,c.Countryname
order by r.city,c.countryname;
  
-- 5) Numbers of Resturants opening based on Year , Quarter , Month --


select c.year,c.Quarter,count(r.RestaurantID) As No_of_Rest_Openings,c.MonthFullName
from calendar c left join restuarants r on c.Datekey_opening=r.Datekey_opening
group by c.year,c.Quarter,c.MonthFullName;
-- year
select c.year,count(distinct(r.restaurantID)) As No_of_Rest_Openings
from calendar c left join restuarants r on c.Datekey_opening=r.Datekey_opening
group by c.year
order by c.year;

-- Quarter
select c.Quarter,count(distinct(r.restaurantID)) As No_of_Rest_Openings
from calendar c join restuarants r on c.Datekey_opening=r.Datekey_opening
group by c.Quarter
order by c.Quarter;

-- Month
select c.MonthFullName,count(distinct(r.restaurantID)) As No_of_Rest_Openings
from calendar c left join restuarants r on c.Datekey_opening=r.Datekey_opening
group by c.MonthFUllName
order by No_of_Rest_openings desc;


-- 6) Count of Resturants based on Average Ratings --

select rating,count(restaurantID) AS No_of_Restaurants
from restuarants 
group by rating
order by rating;

select rating from restuarants;

-- 7) Create buckets based on Average Price of reasonable size and find out how many resturants falls in each buckets --

SELECT 
    CASE 
        WHEN Average_Cost_for_two between 0 AND 300 THEN '0-300'
        WHEN Average_Cost_for_two BETWEEN 301 AND 600 THEN '301-600'
        WHEN Average_Cost_for_two BETWEEN 601 AND 1000 THEN '601-1000'
        ELSE '>1001'
    END AS PriceBucket,
    COUNT(*) AS NumberOfRestaurants
FROM restuarants
GROUP BY PriceBucket;

-- 8) Percentage of Resturants based on "Has_Table_booking --

select Has_Table_Booking, count(restaurantid) AS Total_Restaurants,
Round((count(restaurantid)/(select count(restaurantid) from restuarants))*100,2) AS Percentage_booking
from restuarants
group by Has_table_Booking;

-- 9) Percentage of Resturants based on "Has_Online_delivery --

select Has_Online_delivery, count(restaurantid) As Total_Restaurants,
Round((count(restaurantid)/(select count(restaurantid) from restuarants))*100,2) AS Percentage_booking
from restuarants
group by Has_Online_delivery;

-- 10) Total Cuisines -- 
select Cuisines, count(Cuisines) from restuarants
group by cuisines;

-- 11) Top 5 Restaurants 
SELECT city, restaurantname
FROM (
    SELECT city, restaurantname, rating,
           ROW_NUMBER() OVER (PARTITION BY city ORDER BY rating DESC) AS Ranked
    FROM restuarants
)  As ranked
WHERE Ranked <= 5
ORDER BY city, ranked;

-- 12) Top 5 cuisines

SELECT city, cuisines
FROM (
    SELECT city, cuisines, AVG(rating) AS avg_rating,
           ROW_NUMBER() OVER (PARTITION BY city ORDER BY AVG(rating) DESC) AS ranked
    FROM restuarants
    GROUP BY city, cuisines
) AS ranked
WHERE ranked <= 5
ORDER BY city, ranked;




