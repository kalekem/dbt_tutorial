---=============BigQuery RUNS====================
CREATE OR REPLACE TABLE staging.customers (
    customer_id INT64,
    first_name STRING,
    last_name STRING,
    email STRING,
    signup_date DATE,
    status STRING,
    active string,
	updated_at TIMESTAMP
);

-- insert into customers -> target table
INSERT INTO staging.customers (customer_id, first_name, last_name, email, signup_date, status, active, updated_at)
VALUES
(1, 'John', 'Doe', 'john.doe@example.com', '2023-01-01', 'active', 'Y', current_timestamp()),
(2, 'Jane', 'Smith', 'jane.smith@example.com', '2023-02-15', 'inactive','N', current_timestamp()),
(3, 'Alice', 'Brown', 'alice.brown@example.com', '2023-03-10', 'active','Y',current_timestamp());

--create source table to update customers data 
CREATE OR REPLACE TABLE staging.customers_update (
    customer_id INT64,
    first_name STRING,
    last_name STRING,
    email STRING,
    signup_date DATE,
    status STRING,
    active string,
    updated_at TIMESTAMP
);

--insert into source customer table
INSERT INTO staging.customers_update (customer_id, first_name, last_name, email, signup_date, status, active,updated_at)
VALUES
(2, 'Jane', 'Smith', 'jane.newemail@example.com', '2023-02-15', 'active','Y', current_timestamp()),
(3, 'Alice', 'Brown', 'alice.brown@example.com', '2023-03-10', 'active', 'Y',current_timestamp()),
(4, 'Bob', 'Johnson', 'bob.johnson@example.com', '2023-04-01', 'active','Y', current_timestamp());


--run merge statement to update existing customers table 
MERGE INTO staging.customers  AS target
USING staging.customers_update AS source
ON target.customer_id = source.customer_id

-- Update existing records when matched
WHEN MATCHED THEN
  UPDATE SET 
    target.first_name = source.first_name,
    target.last_name = source.last_name,
    target.email = source.email,
    target.signup_date = source.signup_date,
    target.status = source.status,
    target.active = source.active,
    target.updated_at = source.updated_at

-- -- Insert new records when not matched by target
WHEN NOT MATCHED BY TARGET THEN
  INSERT (customer_id, first_name, last_name, email, signup_date, status,active,updated_at)
  VALUES (source.customer_id, source.first_name, source.last_name, source.email, source.signup_date, source.status, source.active, source.updated_at);
 
 ---======= DBT LOGIC ====
 ---only need to create source table and dbt will create incremental table for us
 
 --create source customer table 
 --we will use customers_update as source so just need to truncate and load new data for testing
 
 ---step 1: truncate source table
 TRUNCATE table staging.customers_update;
 
 --step 2: load initial data 
 
INSERT INTO staging.customers_update (customer_id, first_name, last_name, email, signup_date, status, active, updated_at)
VALUES
(1, 'John', 'Doe', 'john.doe@example.com', '2023-01-01', 'active', 'Y', CURRENT_TIMESTAMP()),
(2, 'Jane', 'Smith', 'jane.smith@example.com', '2023-02-15', 'inactive','N', CURRENT_TIMESTAMP()),
(3, 'Alice', 'Brown', 'alice.brown@example.com', '2023-03-10', 'active','Y', CURRENT_TIMESTAMP());

--step 3: load 2nd data to update existing 
INSERT INTO staging.customers_update (customer_id, first_name, last_name, email, signup_date, status,active,updated_at)
VALUES
(2, 'Jane', 'Smith', 'jane.newemail@example.com', '2023-02-15', 'active', 'Y', current_timestamp()),
(3, 'Alice', 'Brown', 'alice.brown@example.com', '2023-03-10', 'active', 'Y',current_timestamp()),
(4, 'Bob', 'Johnson', 'bob.johnson@example.com', '2023-04-01', 'active','Y', current_timestamp());