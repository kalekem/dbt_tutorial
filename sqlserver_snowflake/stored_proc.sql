CREATE PROCEDURE dbo.usp_GenerateCustomerSummary
AS
BEGIN
	
	SET NOCOUNT ON; -- This prevents extra messages from blocking your result set in DBeaver
	
    -- create temp table -> classsic legacy stuff
    CREATE TABLE #CustomerSales (
        CustomerID INT,
        TotalSpend MONEY,
        OrderCount INT
    );

    -- transformations
    INSERT INTO #CustomerSales
    SELECT 
        CustomerID, 
        SUM(TotalDue) as TotalSpend, 
        COUNT(SalesOrderID) as OrderCount
    FROM Sales.SalesOrderHeader
    GROUP BY CustomerID;

    -- final joins
    SELECT 
        c.AccountNumber,
        p.FirstName,
        p.LastName,
        s.TotalSpend,
        s.OrderCount
    FROM #CustomerSales s
    JOIN Sales.Customer c ON s.CustomerID = c.CustomerID
    JOIN Person.Person p ON c.PersonID = p.BusinessEntityID;
END;
