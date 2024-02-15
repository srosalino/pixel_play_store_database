-- GROUP 23 --
-- Devora Cavaleiro 20230974
-- Andriani Kakoulli 20230484
-- Guilherme Sá 20230520
-- Manuel Gonçalves 20230466
-- Sebastião Rosalino 20230372

-- Select the PlayPixel database for query exercises and invoice generation
USE playpixel;	


-- QUERY EXERCISES

# FIRST QUERY

-- Selecting distinct customer names, order dates, and video game titles between '2000-01-01' and '2020-12-31'
SELECT DISTINCT
    A.FirstName AS 'First Name',
    A.LastName AS 'Last Name',
    B.OrderDate AS 'Order Date',
    C.Title as 'Video Game'
FROM
    Customer A
INNER JOIN
    `Order` B ON A.CustomerID = B.CustomerID
INNER JOIN
    VideoGame C ON B.VideoGameID = C.VideoGameID
WHERE
    B.OrderDate BETWEEN '2000-01-01' AND '2020-12-31';

-- FIRST QUERY OPTIMIZATION ANALYSIS

EXPLAIN
SELECT DISTINCT
    A.FirstName AS 'First Name',
    A.LastName AS 'Last Name',
    B.OrderDate AS 'Order Date',
    C.Title as 'Video Game'
FROM
    Customer A
INNER JOIN
    `Order` B ON A.CustomerID = B.CustomerID
INNER JOIN
    VideoGame C ON B.VideoGameID = C.VideoGameID
WHERE
    B.OrderDate BETWEEN '2000-01-01' AND '2020-12-31';

/*
The query retrieves distinct customer names, order dates, and video game titles within a specified date range.
While the optimization analysis currently indicates that the speed of the query is fast, the decision to index 
the OrderDate attribute in the `Order` table is a proactive measure to ensure sustained performance as the 
database grows. Here are the key reasons why indexing OrderDate is advantageous:

1. Anticipating Data Growth: As the database accumulates more order records over time, the performance of 
   queries involving date ranges could degrade. An index on OrderDate ensures that these queries remain 
   efficient, even with a significantly larger dataset.

2. Frequent Time-Based Queries: In the current Business Context, querying orders by date is a common operation. Whether 
   for generating reports, analyzing sales trends, or providing customer order histories, quick access to 
   date-sorted data is crucial. The index on OrderDate optimizes these types of queries.

3. Enhanced Reporting and Analytics: Business intelligence and reporting often require aggregating data over 
   specific time periods. The index allows for faster aggregation and analysis, enabling more responsive 
   reporting capabilities.

4. Improved User Experience: For applications that allow users to filter or sort orders by date, the index 
   ensures that these features perform well, even with large volumes of data, thereby enhancing the overall 
   user experience.

By indexing OrderDate, a strategic step has been taken to maintain and enhance query performance, particularly 
for date-based operations, which are integral to the business process supported by this database. This 
decision aligns with best practices for database scalability and efficiency.
*/


# SECOND QUERY

-- Counting the number of orders made by each customer and selecting the top 3 (best customers)
SELECT 
    C.FirstName AS 'First Name', 
    C.LastName AS 'Last Name', 
    COUNT(O.CustomerID) AS 'Number of Purchases' 
FROM 
    `Order` O
INNER JOIN 
    Customer C ON O.CustomerID = C.CustomerID
GROUP BY 
    C.CustomerID, C.FirstName, C.LastName  -- Include non-aggregated columns in GROUP BY
ORDER BY 
    COUNT(O.CustomerID) DESC
LIMIT 3;

-- SECOND QUERY OPTIMIZATION ANALYSIS

EXPLAIN
SELECT 
    C.FirstName AS 'First Name', 
    C.LastName AS 'Last Name', 
    COUNT(O.CustomerID) AS 'Number of Purchases' 
FROM 
    `Order` O
INNER JOIN 
    Customer C ON O.CustomerID = C.CustomerID
GROUP BY 
    C.CustomerID, C.FirstName, C.LastName  -- Include non-aggregated columns in GROUP BY
ORDER BY 
    'Number of Purchases' DESC
LIMIT 3;

/*
The query counts the number of orders made by each customer and selects the top 3 customers based on the number 
of purchases. The optimization analysis shows that the execution plan doesn't suggest any index creation, 
and the speed of the query is considered fast and is sustainable for future Data Growth. Therefore, no index
creation was deemed neccessary.
*/


# THIRD QUERY

-- Calculating total sales, yearly average, and monthly average for a specific period
SELECT 
    '2000-01-01 - 2020-12-31' as PeriodOfSales, 
    SUM(Price) as 'TotalSales (euros)', 
    (AVG(Price)/DATEDIFF('2020-12-31', '2000-01-01')) as 'YearlyAverage (of the given period)', 
    (AVG(Price)/DATEDIFF('2020-12-31', '2000-01-01')/12) as 'MonthlyAverage (of the given period)' 
FROM 
    VideoGame A
INNER JOIN 
    `Order` B ON A.VideoGameID = B.VideoGameID
WHERE 
    B.OrderDate BETWEEN '2000-01-01' AND '2020-12-31';
    
-- THIRD QUERY OPTIMIZATION ANALYSIS

EXPLAIN
SELECT 
    '2000-01-01 - 2020-12-31' as PeriodOfSales, 
    SUM(Price) as 'TotalSales (euros)', 
    (AVG(Price)/DATEDIFF('2020-12-31', '2000-01-01')) as 'YearlyAverage (of the given period)', 
    (AVG(Price)/DATEDIFF('2020-12-31', '2000-01-01')/12) as 'MonthlyAverage (of the given period)' 
FROM 
    VideoGame A
INNER JOIN 
    `Order` B ON A.VideoGameID = B.VideoGameID
WHERE 
    B.OrderDate BETWEEN '2000-01-01' AND '2020-12-31';

/* 
The query calculates total sales, yearly average, and monthly average for a specific period between 
2000-01-01 and 2020-12-31. It involves joining the VideoGame and `Order` tables and performing 
aggregations based on the OrderDate.

The optimization analysis does not currently suggest the need for additional indexing, and the query 
performance is fast. This efficiency can be attributed in part to the strategic decision to index the 
OrderDate attribute in the `Order` table. Here's why this decision has been beneficial:

1. Efficient Date Range Filtering: The index on OrderDate significantly enhances the performance of queries 
   involving date range filters, as seen in this query. By having a pre-sorted and quickly accessible structure 
   for dates, the database can efficiently filter records within the specified period.

2. Improved Aggregation Performance: When calculating totals and averages over a period, the database can 
   leverage the OrderDate index to quickly access and aggregate relevant data. This is particularly useful 
   for large datasets where such operations can otherwise be time-consuming.

3. Scalability and Future-Proofing: Even though the current inserted data allows for fast query execution, as the 
   database grows, the volume of order data will increase. The indexed OrderDate ensures that the performance 
   of such queries remains optimized over time, making it a future-proof decision.

4. Supporting Business Intelligence: Queries like this one are fundamental for business intelligence and 
   reporting. The index on OrderDate ensures that these types of queries can be run quickly and efficiently, 
   providing timely insights for decision-making.

In summary, the indexing of OrderDate underlines the database's capability to handle time-based data 
efficiently, proving to be a sound strategic decision for both current and future query performance.
*/


# FOURTH QUERY

-- Calculating total sales by geographical location (city/country)
SELECT ROUND(Sum(A.Price),2) as 'Total Sales',D.City,E.Country 
FROM VideoGame A 
INNER JOIN `Order` B
ON(A.VideogameID = B.VideogameID)
INNER JOIN Customer C
ON(B.CustomerID = C.CustomerID)
INNER JOIN Address D
ON(C.AddressID = D.AddressID)
INNER JOIN Zipcode E
ON(D.ZipCode = E.ZipCode)
GROUP BY D.City, E.Country;

# FOURTH QUERY OPTIMIZATION ANALYSIS

EXPLAIN
SELECT ROUND(Sum(A.Price),2) as 'Total Sales',D.City,E.Country 
FROM VideoGame A 
INNER JOIN `Order` B
ON(A.VideogameID = B.VideogameID)
INNER JOIN Customer C
ON(B.CustomerID = C.CustomerID)
INNER JOIN Address D
ON(C.AddressID = D.AddressID)
INNER JOIN Zipcode E
ON(D.ZipCode = E.ZipCode)
GROUP BY D.City, E.Country;

/*
The query calculates total sales by geographical location (city/country). 
The optimization analysis shows that the execution plan doesn't suggest any index creation, 
and the speed of the query is considered fast and is sustainable for future Data Growth. Therefore, no index
creation was deemed neccessary.
*/


# FIFTH QUERY

-- Listing locations where products/services were sold and have customer ratings
SELECT A.Title, B.Rating, E.State 
FROM VideoGame A
INNER JOIN Rating B
ON (B.VideoGameID = A.VideoGameID)
INNER JOIN Customer C
ON (C.CustomerID = B.CustomerID)
INNER JOIN Address D
ON(C.AddressID = D.AddressID)
INNER JOIN Zipcode E
ON(D.ZipCode = E.ZipCode)
GROUP BY E.State,A.Title, B.Rating;

-- FIFTH QUERY OPTIMIZATION ANALYSIS

EXPLAIN
SELECT A.Title, B.Rating, E.State 
FROM VideoGame A
INNER JOIN Rating B
ON (B.VideoGameID = A.VideoGameID)
INNER JOIN Customer C
ON (C.CustomerID = B.CustomerID)
INNER JOIN Address D
ON(C.AddressID = D.AddressID)
INNER JOIN Zipcode E
ON(D.ZipCode = E.ZipCode)
GROUP BY E.State, A.Title, B.Rating;

/* 
The FIFTH QUERY lists locations (states) where products (video games) have been sold and have received customer ratings. 
This query involves joining the VideoGame, Rating, Customer, Address, and Zipcode tables, 
and grouping the results by State, Title, and Rating.

To optimize this query, especially considering its complex join operations, two indexes have been created 
in the Rating table:

1. Index on VideoGameID (idx_videogameid_rating): 
   - This index significantly improves the performance of the join operation between the Rating and VideoGame tables.
   - By indexing VideoGameID, the database engine can quickly locate and join the relevant ratings for each video game, 
   which is crucial for queries that analyze ratings per game.

2. Index on CustomerID (idx_customerid_rating): 
   - Similarly, the index on CustomerID enhances the join efficiency between the Rating and Customer tables.
   - This index is particularly useful for queries that need to filter or aggregate ratings based on customer demographics,
   such as identifying ratings from customers in specific locations.

These indexes are vital for ensuring efficient query execution, especially as the data volume grows. 
They are particularly beneficial for the following reasons:

- Reduced Query Time: The indexes minimize the time taken to execute the joins by providing quick lookups on the foreign key columns.
- Scalability: As the number of ratings and the size of related tables grow, these indexes ensure that the query continues to perform well, avoiding slow-downs in data retrieval.
- Enhanced User Experience: For applications that allow users to view ratings by game or to see game popularity by region, these indexes ensure that the underlying queries perform swiftly, thereby improving the overall user experience.

In summary, by indexing VideoGameID and CustomerID in the Rating table, the database has been optimized
for complex queries involving multiple joins, ensuring efficient data retrieval both now and as the dataset expands.
*/


-- INVOICE GENERATION --

-- Dropping the view if it already exists
DROP VIEW IF EXISTS Head_Totals_View;

-- Creating a view for the head of an invoice
CREATE VIEW Head_Totals_View AS
SELECT
  CONCAT(FirstName, ' ', LastName) AS 'Client Name',
  MAX(B.Street) AS 'Street Address',
  MAX(C.State) AS City,
  MAX(C.State) AS State,
  MAX(C.Country) AS Country,
  MAX(C.ZipCode) AS 'ZIP Code',
  'Pixel Play' AS 'Company Name',
  'Rua das Flores, 123 Lisboa Portugal' AS 'Company Street Address',
  '961234567' AS 'Company Phone Number',
  'playpixel@gmail.com' AS 'Company Email',
  'pixelplaystore.com' AS 'Company Website',
  D.OrderID AS 'Invoice Number',
  MAX(D.OrderDate) AS 'Date of Issue',
  ROUND(SUM(TotalAmount), 2) AS Total
FROM
  Customer A
  INNER JOIN Address B ON (A.AddressID = B.AddressID)
  INNER JOIN Zipcode C ON (B.ZipCode = C.ZipCode)
  INNER JOIN `Order` D ON (D.CustomerID = A.CustomerID)
  INNER JOIN OrderDetail E ON (E.OrderID = D.OrderID)
GROUP BY
  CONCAT(FirstName, ' ', LastName),
  'Company Name',
  'Company Street Address',
  'Company Phone Number',
  'Company Email',
  'Company Website',
  D.OrderID;
  
-- Placeholder to check a specific invoice head and totals by changing the 'Invoice Number'
SELECT * FROM Head_Totals_View WHERE `Invoice Number` = 1;

-- Dropping the view if it already exists
DROP VIEW IF EXISTS Details_View;

-- Creating a view for the details of an invoice
CREATE VIEW Details_View AS

-- Selecting information for the details of the invoice
SELECT
    -- Selecting the order ID as 'Invoice Number' to link with the head and totals view
    A.OrderID AS 'Invoice Number',
    -- Selecting the title of the video game as 'Description'
    C.Title AS 'Description',
    -- Calculating the unit cost by dividing Price by Quantity and rounding to 2 decimal places
    ROUND((C.Price / B.Quantity), 2) AS 'Unit Cost',
    -- Selecting the quantity as 'Quantity'
    B.Quantity AS 'Quantity',
    -- Selecting the total amount as 'Amount'
    C.Price AS 'Amount'
FROM
    -- Joining relevant tables to gather required information
    `Order` A
    INNER JOIN OrderDetail B ON (A.OrderID = B.OrderID)
    INNER JOIN VideoGame C ON (A.VideoGameID = C.VideoGameID);

-- Placeholder to check a specific invoice details by changing the 'Invoice Number'
SELECT * FROM Details_View WHERE `Invoice Number` = 10;