-- Q1 Is the business growing? Revenue by year
SELECT strftime('%Y', o.OrderDate) AS Year,
COUNT(DISTINCT o.OrderID) AS Total_Orders,
ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)),2) AS Total_Revenue
FROM Orders o
JOIN `Order Details` od ON o.OrderID = od.OrderID
GROUP BY Year
ORDER BY Year;

-- Q2 Which countries generate the most revenue?
-- this helps identify priority markets for growth strategy
SELECT c.Country,
COUNT(DISTINCT c.CustomerID) AS Customers,
COUNT(DISTINCT o.OrderID) as Orders,
ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)),2) AS Revenue,
ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) / COUNT(DISTINCT o.OrderID), 2) 
AS Avg_Order_Value
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN `Order Details` od ON o.OrderID = od.OrderID
GROUP BY c.Country
ORDER BY Revenue DESC
LIMIT 10;

-- Q3 Who are our top 10 most valuable customers?
SELECT c.CompanyName,
c.Country,
COUNT(DISTINCT o.OrderID) AS Order_Count,
ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) AS Total_Revenue
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN `Order Details` od ON o.OrderID = od.OrderID
GROUP BY c.CompanyName, c.Country
ORDER BY Total_Revenue DESC
LIMIT 10;

-- Q4 Which products generate the most revenue?
SELECT p.ProductName,
SUM(od.Quantity) AS Units_Sold,
ROUND(SUM(od.UnitPrice * od.Quantity * (1-od.Discount)),2) AS Revenue
FROM Products p
JOIN `Order Details` od ON p.ProductID = od.ProductID
GROUP BY p.ProductName
ORDER BY Revenue DESC
LIMIT 15;

-- Q5 Which products are most heavily discounted?
SELECT p.ProductName,
ROUND(AVG(od.Discount) * 100, 1) AS Avg_Discount_Pct,
COUNT(*) AS Times_Ordered
FROM Products p
JOIN `Order Details` od ON p.ProductID = od.ProductID
GROUP BY p.ProductName
HAVING Avg_Discount_Pct > 0.1
ORDER BY Avg_Discount_Pct DESC;

-- Q6 Average days to ship by Country
SELECT c.Country,
COUNT(o.OrderID) AS Orders,
ROUND(AVG(julianday(o.ShippedDate) - julianday(o.OrderDate)),1) AS Avg_Days_To_Ship
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE o.ShippedDate IS NOT NULL
GROUP BY c.Country
ORDER BY Avg_Days_To_Ship DESC
LIMIT 10;

-- Q7 Which sales employees generate the most revenue?
SELECT e.FirstName || ' ' || e.LastName AS Employee,
e.Title,
COUNT(DISTINCT o.OrderID) AS Orders_Handled,
ROUND(SUM(od.UnitPrice * od.Quantity * (1-od.Discount)),2) AS Revenue_Generated
FROM Employees e
JOIN Orders o ON e.EmployeeID = o.EmployeeID
JOIN `Order Details` od ON o.OrderID = od.OrderID
GROUP BY e.EmployeeID
ORDER BY Revenue_Generated DESC;

-- Q8 Monthly revenue trend, any seasonal patterns?
SELECT strftime('%Y-%m', o.OrderDate) AS Month,
COUNT(DISTINCT o.OrderID) AS Orders,
ROUND(SUM(od.UnitPrice * od.Quantity * (1-od.Discount)),2) AS Monthly_Revenue
FROM Orders o
JOIN `Order Details` od ON o.OrderID = od.OrderID
GROUP BY Month
ORDER BY Month;

-- Q9 Customer order frequency
SELECT c.CompanyName,
c.Country,
COUNT(DISTINCT o.OrderID) AS Total_Orders,
ROUND(AVG(od.UnitPrice * od.Quantity * (1-od.Discount)),2) AS Avg_Order_Value
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN `Order Details` od ON o.OrderID = od.OrderID
GROUP BY c.CustomerID
ORDER BY Total_Orders DESC
LIMIT 15;

-- Q10 Customers at churn risk with no order in the last 6 months
SELECT c.CompanyName,
c.Country,
MAX(o.OrderDate) AS Last_Order_Date,
ROUND(julianday('2023--01--01') - julianday(MAX(o.OrderDate)), 0) AS Days_Since_Order
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID
HAVING Days_Since_Order > 180
ORDER BY Days_Since_Order DESC;