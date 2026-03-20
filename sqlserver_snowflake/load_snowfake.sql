-- You can replace the tables as to match yours

-- load salesorderHeader
COPY INTO staging.public.SalesOrderHeader (
    SalesOrderID, RevisionNumber, OrderDate, DueDate, ShipDate, 
    Status, OnlineOrderFlag, SalesOrderNumber, PurchaseOrderNumber, 
    AccountNumber, CustomerID, SalesPersonID, TerritoryID, 
    BillToAddressID, ShipToAddressID, ShipMethodID, CreditCardID, 
    CreditCardApprovalCode, CurrencyRateID, SubTotal, TaxAmt, 
    Freight, TotalDue, Comment, rowguid, ModifiedDate
)
FROM (
  SELECT 
    $1:SalesOrderID::INT,
    $1:RevisionNumber::INT,
    -- THE FIX: The '9' handles the 19-digit nanosecond integer
    TO_TIMESTAMP_NTZ($1:OrderDate::INT, 3), 
    TO_TIMESTAMP_NTZ($1:DueDate::INT, 3),
    TO_TIMESTAMP_NTZ($1:ShipDate::INT, 3),
    $1:Status::INT,
    $1:OnlineOrderFlag::BOOLEAN,
    $1:SalesOrderNumber::VARCHAR,
    $1:PurchaseOrderNumber::VARCHAR,
    $1:AccountNumber::VARCHAR,
    $1:CustomerID::INT,
    $1:SalesPersonID::INT,
    $1:TerritoryID::INT,
    $1:BillToAddressID::INT,
    $1:ShipToAddressID::INT,
    $1:ShipMethodID::INT,
    $1:CreditCardID::INT,
    $1:CreditCardApprovalCode::VARCHAR,
    $1:CurrencyRateID::INT,
    $1:SubTotal::NUMBER(19,4),
    $1:TaxAmt::NUMBER(19,4),
    $1:Freight::NUMBER(19,4),
    $1:TotalDue::NUMBER(19,4),
    $1:Comment::VARCHAR,
    $1:rowguid::VARCHAR,
    TO_TIMESTAMP_NTZ($1:ModifiedDate::INT, 3)
  FROM @my_s3_stage/salesorderheader/salesorderheader.parquet
)
FILE_FORMAT = (TYPE = 'PARQUET');

-- load customer table
COPY INTO staging.public.Customer (
    CustomerID, 
    PersonID, 
    StoreID, 
    TerritoryID, 
    AccountNumber, 
    rowguid, 
    ModifiedDate
)
FROM (
  SELECT 
    $1:CustomerID::INT,
    $1:PersonID::INT,
    $1:StoreID::INT,
    $1:TerritoryID::INT,
    $1:AccountNumber::VARCHAR,
    $1:rowguid::VARCHAR,
    TO_TIMESTAMP_NTZ($1:ModifiedDate::INT, 3)
  FROM @my_s3_stage/customer/customer.parquet
)
FILE_FORMAT = (TYPE = 'PARQUET');

-- load Person table
COPY INTO staging.public.Person (
    BusinessEntityID, PersonType, NameStyle, Title, FirstName, 
    MiddleName, LastName, Suffix, EmailPromotion, 
    AdditionalContactInfo, Demographics, rowguid, ModifiedDate
)
FROM (
  SELECT 
    $1:BusinessEntityID::INT,
    $1:PersonType::VARCHAR,
    $1:NameStyle::BOOLEAN,
    $1:Title::VARCHAR,
    $1:FirstName::VARCHAR,
    $1:MiddleName::VARCHAR,
    $1:LastName::VARCHAR,
    $1:Suffix::VARCHAR,
    $1:EmailPromotion::INT,
    $1:AdditionalContactInfo::VARIANT,
    $1:Demographics::VARIANT,
    $1:rowguid::VARCHAR,
    TO_TIMESTAMP_NTZ($1:ModifiedDate::INT, 3)
  FROM @my_s3_stage/person/person.parquet
)
FILE_FORMAT = (TYPE = 'PARQUET');