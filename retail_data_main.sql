
create database retail_data_test
 use retail_data_test


 --adding not null to customer_id
alter table customer alter column customer_id numeric(38) not null;


--adding primary key to customer-id in customer table
alter table customer
add primary key (customer_id)

select * from customer 

-- after adding table of transactions
select * from transactions

alter table transactions alter column transaction_id numeric(38) not null;

alter table transactions alter column cust_id numeric(38) not null;

alter table transactions
add constraint FK_customer_transactions foreign key (cust_id) references customer (customer_Id)

--adding prod_cat_info table
select * from prod_cat_info

alter table prod_cat_info alter column prod_cat_code numeric(38) not null;






---------------------------- DATA PREPARATION----------------


--1. total no. of rows in each table
 select count(customer_id) as [no.of rows] from customer
 select count(transaction_id) as [no of rows] from Transactions
 select count(prod_cat_code) as [no of rows] from prod_cat_info


--2. total no. of transactions that have a return
select count(total_amt) [no. of transaction] from Transactions
where total_amt < 0


--3. change date format into valid date format
   SELECT CONVERT(datetime,TRAN_DATE, 103)FROM TRANSACTIONS


--4. what is time range of transaction data available for analysis. show o/p as days, months, years.
select datediff(dd,min(tran_date),max(tran_date)) as [no of days],
		datediff(month,min(tran_date),max(tran_date)) as [no of months],
		DATEDIFF(year,min(tran_date),max(tran_date)) as [no of years] from Transactions


--5. which prod cat does the sub-cat "DIY" belong to ?
select * from prod_cat_info
where prod_subcat='diy'


------------------------ DATA ANALYSIS------------------------


--1. which channel is most frequently used for transactions.
SELECT store_type, COUNT(store_type) [Count] FROM Transactions
GROUP BY store_type
HAVING COUNT(store_type) > 1
order by COUNT(store_type) desc


--2. count of male and female customer in DB ?
 Select count(CASE when gender='M' then 1 end) as male, count(case when gender='F' then 1 end) as female	
 FROM customer

--3. which city we have max no of customers & how many?

 select TOP 1 city_code , COUNT(CUSTOMER_ID) AS [no. of customers] FROM CUSTOMER 
 GROUP BY CITY_CODE 
 ORDER BY COUNT(CUSTOMER_ID) DESC 


 --4 how may subcat are in book cat ?
 select prod_cat, count(prod_cat) [book cat] from prod_cat_info
 where prod_cat='Books'
 group by prod_cat

 --5. max qty of prod ever ordered ?
 select max(qty) [max qty] from Transactions

 --6. what is net total revenue generated in cat. electronics and books ?

 select t1.prod_cat,sum(t2.total_amt) [net revenue]
 from prod_cat_info as t1 inner join Transactions as t2 on t1.prod_cat_code=t2.prod_cat_code 
 where t1.prod_cat in ('electronics','books')
 group by t1.prod_cat

 --7. how many customers have > 10 transactions with us, exclude return.

  select distinct cust_id, count(cust_id) [no of transactions] from Transactions
  where total_amt > 0
  group by cust_id
  having count(cust_id) > 10
  order by [no of transactions] desc


  --8. combine revenue from elect and clothing cat  from 'flagship stores'.

select t1.Store_type, sum(t1.total_amt) [Combine revenue] from Transactions as t1 inner join prod_cat_info as t2 on t1.prod_cat_code=t2.prod_cat_code
where t1.Store_type = 'flagship store' and t2.prod_cat in ('electronics','clothing')
group by t1.Store_type

									-----------------or-----------------

select t2.prod_cat, sum(t1.total_amt) [Combine revenue] from Transactions as t1 inner join prod_cat_info as t2 on t1.prod_cat_code=t2.prod_cat_code
where t1.Store_type = 'flagship store' and t2.prod_cat ='clothing'
group by t2.prod_cat
union
select t2.prod_cat, sum(t1.total_amt) [Combine revenue] from Transactions as t1 inner join prod_cat_info as t2 on t1.prod_cat_code=t2.prod_cat_code
where t1.Store_type = 'flagship store' and t2.prod_cat = 'electronics'
group by t2.prod_cat


--9.total revenue from 'male' customer in 'elect' cat. output display total revenue by prod sub cat ?

 select t3.prod_subcat, sum(t2.total_amt) [ Total Revenue ] from customer t1 inner join Transactions t2 on t1.customer_Id=t2.cust_id inner join prod_cat_info t3 on t2.prod_cat_code=t3.prod_cat_code
where t1.Gender='M'and t3.prod_cat='electronics' 
group by t3.prod_subcat


--10. what is percentage of sales and return by prod sub cat, display only top 5 sub cat in terms of sales.

  SELECT top 5 t1.prod_subcat, SUM(CASE 
										WHEN t2.Qty > 0 THEN total_amt end)*100/(select sum(total_amt) from Transactions) [percentage of sales],
							   sum(case 
										when  t2.Qty < 0 then total_amt end)*100/(select sum(total_amt) from Transactions) [percentage of return]
  FROM prod_cat_info t1 right join Transactions t2 on t1.prod_cat_code=t2.prod_cat_code
  GROUP BY t1.prod_subcat
  order by  [percentage of sales] desc;
  /* as in the above query its the combined percentage of respective products sub categories as shown */



--11.age b/w  25-30, find what is net total revenue generated in last 30 days of transactions from max transaction date available in data ?

SELECT  SUM(t1.total_amt) as [Total Revenue]
FROM (SELECT t1.*, MAX(t1.tran_date) OVER () as max_tran_date FROM Transactions t1) t1 inner JOIN Customer t2 ON t1.cust_id = t2.customer_Id
WHERE t1.tran_date >= DATEADD(day, -30, t1.max_tran_date) AND t1.tran_date >= DATEADD(YEAR, 25, t2.DOB) AND t1.tran_date < DATEADD(YEAR, 31, t2.DOB)



--12. which prod cat has seen the max value of return  in last 3 months of transactions ?

 select t2.prod_cat, sum(t1.total_amt) [total revenue] 
 from (select *, max(t1.tran_date) over() as max_tran_date from Transactions t1) t1 inner join prod_cat_info t2 on t1.prod_cat_code=t2.prod_cat_code
 where t1.tran_date >= DATEADD(day , -90 , t1.max_tran_date) AND t1.total_amt < 0
 Group by t2.prod_cat
 order by [total revenue] asc



 --13. which store type sells the max prod  by value of sales amount and by quantity sold.

 select Store_type, max(total_amt) as[ max total ], max(Qty) as[max Qty] from Transactions
 group by Store_type
order by max(total_amt) desc, max(Qty) desc
 

 --14 what are cat for which avg revenue is above of overall avg

	 select t2.prod_cat, AVG(t1.total_amt) [total avg amt] 
	 from (select *, avg(t1.total_amt) over() as [overall average] from Transactions t1) t1 inner join prod_cat_info t2 on t1.prod_cat_code=t2.prod_cat_code
	 group by t2.prod_cat, [overall average]
	 having AVG(t1.total_amt) > [overall average]


 --15  find avg and total revenue by each sub_cat for cat which are among top 5 cat in terms of qty sold.


 select P.prod_cat , P.prod_subcat,
 AVG(cast(total_amt as float)) as Average_Revenue, SUM(cast(total_amt as float)) as Total_Revenue
 from Transactions as T INNER JOIN prod_Cat_info as P
 ON T.prod_cat_code = P.prod_cat_code AND T.prod_subcat_code = P.prod_sub_cat_code
 WHERE P.prod_cat_code IN (select top 5 P.prod_cat_code from prod_cat_info as P inner join Transactions as T
 ON P.prod_cat_code = T.prod_cat_code AND P.prod_sub_cat_code = T.prod_subcat_code
 group by P.prod_cat_code
 order by sum(Cast(Qty as int)) desc
 )
 group by P.prod_cat, P.prod_subcat


