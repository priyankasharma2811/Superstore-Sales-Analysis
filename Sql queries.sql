

-- query 1  percentage of total orders were shipped on the same date?

SELECT CONVERT((ShippedOnTime * 1.0) / (NULLIF(TotalOrdersShipped * 1.0,0)*100),decimal(5,1))  as Same_Day_Shipping_Percentage from (
	select sum( case when Order_Date= Ship_Date then 1 else 0 end ) as ShippedonTime, count(*) as TotalOrdersShipped 
    from be0295df.superstore ) as t;

/* output 
Same_Day_Shipping_Percentage
0.0
*/

-- query 2 Name top 3 customers with highest total value of orders.

select  Customer_Name,sum(Sales) as TotalOrderValue from be0295df.superstore group by Customer_Name order by sum(Sales) desc limit 3;

/* output 

Customer_Name	TotalOrderValue
Sean Miller		24516.6000
Tamara Chand	19044.9060
Raymond Buch	15056.8540

-- query 3 The top 5 items with the highest average sales per day
*/

select Product_ID,  Average_Sales from( 
	select  Product_ID,avg(Sales) as Average_Sales, Rank () over( order by avg(Sales) desc) as rank1 
	from be0295df.superstore group by Product_ID) as t 
where t.rank1<=5;

/* output 
Product_ID			Average_Sales
TEC-MA-10002412		22638.48000000
TEC-CO-10004722		12319.96480000
TEC-MA-10004125		7999.98000000
TEC-MA-10001047		7149.94500000
TEC-MA-10001127		6124.96500000



-- query 4  Write a query to find the average order value for each customer, and rank the customers by their average order value

*/

select Customer_ID, Avg_Order_Value,rank1 from 
(select Customer_ID,avg(Sales) as Avg_Order_Value,Rank () over( order by AVG(Sales) desc) as rank1
from be0295df.superstore
group by Customer_ID)as t

/* output 

Customer_ID		Avg_Order_Value	rank
TA-21385		2301.29500000	1
MW-18235		1751.29200000	2
SM-20320		1751.18571429	3
TC-20980		1731.35509091	4
GT-14635		1558.53533333	5
HL-15040		1283.85080000	6
BS-11365		1166.85033333	7
CH-12070		1127.97600000	8
CC-12370		1102.64290909	9
SH-20635		1048.19600000	10
RB-19360		1003.79026667	11
AR-10540		981.41333333	12
SE-20110		935.62916667	13
JW-15220		928.86425000	14
TP-21415		921.73416000	15
CM-12385		895.40200000	16
JR-15700		863.88000000	17
YC-21895		776.95000000	18
DR-12940		773.56244444	19
TB-21400		762.66672727	20
BM-11140		762.18933333	21
CM-12655		736.31350000	22
JM-15865		735.17560000	23
NF-18385		726.98225000	24
AB-10105		723.67855000	25



--query 5 
the name of customers who ordered highest and lowest orders from each city

*/
with  t as (
	select City, Customer_Name,sum(Sales) as cnt , rank() over (partition by City order by sum(Sales) desc ) as rnk_max, 
	rank() over (partition by City order by sum(Sales) )as rnk_min 
    from be0295df.superstore 
    group by City,Customer_Name) 
select t1.City ,t1.highest_order_sales , t2.lowest_order_sales,t1.max_customer,t2.min_customer from  (
	select t.City ,t.Customer_Name  as max_customer,t.cnt as highest_order_sales from t where t.rnk_max=1) as t1 
	join
	(select t.City ,t.Customer_Name as min_customer ,t.cnt as lowest_order_sales from t where t.rnk_min=1) as t2 
	on t1.City =t2.City


/* Glimpse of output 
City		highest_order_sales	lowest_order_sales	max_customer	min_customer	
Aberdeen	25.5				25.5				Jeremy Lonsdale	Jeremy Lonsdale	
Abilene		1.392				1.392				Dennis Kane		Dennis Kane	
Akron		949.772				17.184				Ed Braxton		Ross DeVincentis	
Albuquerque	780.086				27.18				Benjamin 		Farhat	David Wiener	
Alexandria	4251.92				24.56				Greg Maxwell	Roy Collins	
Allen		259.942				30.264				Anna Gayman		Anthony Witt	
Allentown	837.444				15.808				Sean Miller		Caroline Jumper	
*/
	

-- Query 6 the most demanded sub-category in the west region?

select Sub_Category ,sub_count from (
	select Sub_Category,sum(Sales) as sub_count,Region,rank() over (order by sum(Sales) desc) as rnk3 
	from be0295df.superstore where Region='West' group by Sub_Category,Region ) as y 
where rnk3<=1

/* output 
Sub_Category	sub_count
Chairs			86795.7600



*/

-- query 7 Which order has the highest number of items? 


select Order_ID as Highest_number_of_items,total  from (
	select Order_ID , count(Product_ID) total, rank() over (order by count(Product_ID) desc) as rnk_max 
	from be0295df.superstore group by Order_ID) as t where 
t.rnk_max<=1

/* output 
Highest_number_of_items		total
CA-2018-100111				14


-- query 8  which order has the highest cumulative value?

*/
select Order_ID as highest_cumulative_value, total_sales from (
	select Order_ID , sum(Sales) as total_sales, rank() over ( order by  sum(Sales) desc) as rnk 
	from be0295df.superstore group by Order_ID) as t1 
where t1.rnk<=1

/* output 
highest_cumulative_value	total_sales
CA-2015-145317				23661.2280

*/

-- Query 9  Which segment’s order is more likely to be shipped via first class?

select Segment,cnt from
(
Select Segment,Ship_Mode,count(Ship_Mode) as cnt ,rank() over ( order by count(Ship_Mode) desc)  as rnk
from superstore
where Ship_Mode='First Class'
group by Segment,Ship_Mode)as x
where x.rnk=1


/* output

Segment		cnt
Consumer	685

*/


-- Query 10 

-- Which city is least contributing to total revenue?


select p.City,TotalSales from ( 
	select City,sum(Sales) as TotalSales,rank() over (   order by  Sum(Sales) ) as rnk2 
	from be0295df.superstore	group by City) as 
where rnk2=1

/* output 

City	TotalSales	
Abilene	1.3920

-- Query 11 
-- What is the average time for orders to get shipped after order is placed?

*/
select FORMAT(avg(DATEDIFF(Ship_Date,Order_Date)) ,8) as avg_days from be0295df.superstore

/* ouput 

avg_days
41.72803554



-- Query 12  Which segment places the highest number of orders from each state and which segment places the largest individual orders from each state?
*/


select * from (
	select Segment,State, count(Order_ID) as cnt, rank() over ( partition by State order by count(Order_ID) desc) as rnk  
	from superstore group by Segment,State)as t



/* Output
Segment		State		cnt	rnk
Corporate	Alabama		26	1
Consumer	Alabama		19	2
Home Office	Alabama		6	3
Consumer	Arizona		94	1
Corporate	Arizona		54	2
Home Office	Arizona		42	3
Consumer	Arkansas	36	1
Corporate	Arkansas	12	2
Home Office	Arkansas	5	3
Consumer	California	857	1
Corporate	California	494	2
Home Office	California	289	3
Consumer	Colorado	82	1
Corporate	Colorado	44	2
Home Office	Colorado	17	3
Consumer	Connecticut	31	1
Corporate	Connecticut	22	2
Home Office	Connecticut	9	3
Consumer	Delaware	34	1
Corporate	Delaware	31	2
Home Office	Delaware	6	3
Home Office	Columbia	1	1
Consumer	Florida		149	1
Corporate	Florida		100	2
Home Office	Florida		54	3

*/





=