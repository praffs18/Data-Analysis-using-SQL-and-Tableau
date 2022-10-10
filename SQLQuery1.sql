create database PortfolioDB

use PortfolioDB;

--- Inspecting Data --- 
select * from [dbo].[sales_data_sample]


--- Description of quantity orderd column
select max(QUANTITYORDERED) as maximum_order_qty,
       min(Quantityordered) as minimum_order_qty,
	   avg(quantityordered) as mean,
	   count(quantityordered) as total_observations
from sales_data_sample  

--- Description of price column
select max(PRICEEACH) as maximum_price,
       min(PRICEEACH) as minimum_price,
	   avg(PRICEEACH) as mean_price,
	   count(PRICEEACH) as total_observations
from sales_data_sample  

--- Description of the sales column
select max(SALES) as maximum_sales,
       min(SALES) as minimum_sales,
	   avg(SALES) as mean_sales,
	   count(SALES) as total_observations
from sales_data_sample

--- Order date range---
select min(orderdate) as start_date,
       max(orderdate) as recent_date
from sales_data_sample

--- Checking the unique values
select distinct PRODUCTLINE from sales_data_sample
select distinct dealsize from sales_data_sample
select distinct COUNTRY from sales_data_sample
select distinct TERRITORY from sales_data_sample

--- Analysis
--- lets check the sales by productline
select PRODUCTLINE , sum(sales) as Revenue
from sales_data_sample
group by PRODUCTLINE
order by Revenue desc

--- lets check the sales revenue by year wise
select YEAR_ID , sum(sales) as Revenue
from sales_data_sample
group by YEAR_ID
order by Revenue desc

--- lets check the sales revenue by dealsize
select DEALSIZE , sum(sales) as Revenue
from sales_data_sample
group by DEALSIZE
order by Revenue desc

--- lets check the sales revenue by month wise
select MONTH_ID , sum(sales) as Revenue
from sales_data_sample
group by MONTH_ID
order by Revenue desc

--- lets check what was the month which has generated high revenue in that specific year? 
--- check for 2003
select MONTH_ID, sum(sales) as Revenue, COUNT(ordernumber) as Frequency
from sales_data_sample
where YEAR_ID = 2003
group by MONTH_ID
order by Revenue desc

--- check for 2004
select MONTH_ID, sum(sales) as Revenue, COUNT(ordernumber) as Frequency
from sales_data_sample
where YEAR_ID = 2004
group by MONTH_ID
order by Revenue desc

--- check for 2005
select MONTH_ID, sum(sales) as Revenue, COUNT(ordernumber) as Frequency
from sales_data_sample
where YEAR_ID = 2005
group by MONTH_ID
order by Revenue desc

--- It seems like November generates more revenue so what product they sale mostly
--- check for 2003
select PRODUCTLINE , sum(sales) as Revenue, count(ordernumber) as Frequency
from sales_data_sample
where year_id = 2003 and month_id = 11 
group by productline
order by revenue desc

--- check for 2004
select PRODUCTLINE , sum(sales) as Revenue, count(ordernumber) as Frequency
from sales_data_sample
where year_id = 2004 and month_id = 11 
group by productline
order by revenue desc

--- Who is our best customer using RFM analysis
drop table if exists #rfm
;with rfm as
(
	select CUSTOMERNAME,
		   DATEDIFF(DD, max(orderdate), (select max(orderdate) from sales_data_sample)) as Recency,
		   count(ordernumber) as Frequency,
		   sum(sales) as spent_value,
		   max(orderdate) as Last_order_date_of_customer,
		   (select max(orderdate) from sales_data_sample) as last_order_date
	from sales_data_sample
	group by CUSTOMERNAME
),
rfm_calc as
(
	select r.*,
		ntile(4) over (order by recency desc) as rfm_recency,
		ntile(4) over (order by frequency) as rfm_frequency,
		ntile(4) over (order by spent_value) as rfm_Monetory
	from rfm r
)
select c.*,rfm_recency +  rfm_frequency + rfm_Monetory as rfm_cell,
      cast(rfm_recency as varchar) +cast(rfm_frequency as varchar) + cast(rfm_Monetory as varchar) as rfm_string
into #rfm
from rfm_calc c

select CUSTOMERNAME, rfm_recency, rfm_frequency, rfm_Monetory, rfm_string,
	case 
		when rfm_string in (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141,232) then 'lost_customers'  --lost customers
		when rfm_string in (133, 134, 143, 244, 334,144) then 'slipping away, cannot lose' -- (Big spenders who haven’t purchased lately) slipping away
		when rfm_string in (311, 411, 331,421,412) then 'new customers'
		when rfm_string in (222, 223, 233, 322,234,221) then 'potential churners'
		when rfm_string in (323, 333,321, 422, 332,343, 432,344,423) then 'active' --(Customers who buy often & recently, but at low price points)
		when rfm_string in (433, 434, 443, 444) then 'loyal'
	end rfm_segment
from #rfm


---What city has the highest number of sales in a specific country
select city, sum(sales) as Revenue
from sales_data_sample
where COUNTRY = 'UK'
group by CITY
order by Revenue desc

---What is the best product in United States?
select PRODUCTLINE, sum(sales) Revenue
from sales_data_sample
where COUNTRY = 'USA'
group by PRODUCTLINE
order by Revenue desc
