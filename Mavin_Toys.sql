CREATE DATABASE IF NOT EXISTS mavin_toys;  -- create database called 'mavin_toys'
 
USE mavin_toys;-- select mavin_toys database

CREATE TABLE inventory (
    Store_ID INT NOT NULL,
    Product_ID INT NOT NULL,
    Stock_On_Hand INT NULL,
    CONSTRAINT PK_inventory PRIMARY KEY (Store_ID , Product_ID)
);
-- create empty inventory table

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/inventory.csv'
INTO TABLE inventory FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
-- load data into the empty inventory table

CREATE TABLE products (
    Product_ID INT NOT NULL PRIMARY KEY,
    Product_Name VARCHAR(255) NULL,
    Product_Category VARCHAR(255) NULL,
    Product_Cost VARCHAR(255) NULL,
    Product_Price VARCHAR(255) NULL
);
-- create empty products table

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv'
INTO TABLE products FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
-- load data into the empty products table

CREATE TABLE sales (
    Sale_ID INT NOT NULL PRIMARY KEY,
    Date DATE NULL,
    Store_ID INT NULL,
    Product_ID INT NULL,
    Units INT NULL
);
-- create empty sales table

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales.csv'
into table sales fields terminated by ',' lines terminated by '\n' ignore 1 rows;
-- load data into the empty sales table

CREATE TABLE stores (
    Store_ID INT NOT NULL PRIMARY KEY,
    Store_Name VARCHAR(255) NULL,
    Store_City VARCHAR(255) NULL,
    Store_Location VARCHAR(255) NULL,
    Store_Open_Date DATE NULL
);
-- create empty stores table

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/stores.csv'
INTO TABLE stores FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
-- load data into the empty stores table

-- the following lines of codes aim at cleaning the dataset
SELECT * FROM inventory;  -- manually inspect the inventory table

SELECT COUNT(*) FROM inventory WHERE Stock_On_Hand IS NULL;  -- check for rows where Stock_On_Hand is null. No rows.

SELECT * FROM products;  -- manually inspect the products table

SELECT * FROM products WHERE
    Product_Name IS NULL
        OR Product_Category IS NULL
        OR Product_Cost IS NULL
        OR Product_Price IS NULL;-- check if columns have null values. None has.
        
SELECT * FROM products WHERE
    Product_Name LIKE '% '
        OR Product_Name LIKE ' %';  -- check for trailing spaces in Product_Name column. No trailing spaces.
        
SELECT DISTINCT(Product_Name) FROM products;-- check for misspellings in the Product_Name column. No misspelling.

SELECT * FROM products WHERE
    Product_Category LIKE '% '
        OR Product_Category LIKE ' %';  -- check for trailing spaces in Product_Category column. No trailing spaces.

SELECT DISTINCT(Product_Category) FROM products;-- check for misspellings in the Product_Category column. No misspelling.

UPDATE products SET 
    Product_Cost = TRIM(LEADING '$' FROM Product_Cost) WHERE
    Product_Cost LIKE '$%'; -- remove the '$' symbol preceeding the data in Product_Cost column.

SELECT * FROM products WHERE
    Product_Cost LIKE '% '
        OR Product_Cost LIKE ' %';-- check for trailing spaces in the Product cost column. There are.alter.

UPDATE products SET 
    Product_Cost = TRIM(Product_Cost) WHERE
    Product_Cost LIKE '% '
        OR Product_Cost LIKE ' %';  -- trim trailing spaces.

UPDATE products SET 
    Product_Price = TRIM(LEADING '$' FROM Product_Price) WHERE
    Product_Price LIKE '$%';-- remove the '$' symbol preceeding the data in Product_Price column.

SELECT * FROM products WHERE
    Product_Price LIKE ' %'
        OR Product_Price LIKE '% ';-- check for trailing spaces in the Product price column. No trailing spaces.

UPDATE products SET 
    Product_Price = TRIM(TRAILING '\r' FROM Product_Price)
WHERE
    Product_Price LIKE '%\r'; -- trim trailing carriage returns. This step was edited when I realised this column has an extra space and a carriage return attached to each field when I was export the final table.

UPDATE products SET 
    Product_Price = TRIM(Product_Price) WHERE
    Product_Price LIKE '% ';-- trim trailing space.

SELECT * FROM sales; -- manually inspect the sales table

SELECT * FROM sales WHERE
    Date IS NULL 
		OR Store_ID IS NULL
        OR Product_ID IS NULL
        OR Units IS NULL;  -- check if columns have null values. None has.

SELECT COUNT(*) FROM sales WHERE
    Date <> DATE_FORMAT(date, '%y-%m-%d');  -- check for Date fields with inconsistent date format. None has.

SELECT * FROM stores;  -- manually inspect the stores table 

SELECT * FROM stores WHERE
    Store_Name IS NULL OR Store_City IS NULL
        OR Store_Location IS NULL
        OR Store_Open_Date IS NULL;  -- check if columns have null values. None has.

SELECT DISTINCT(Store_Name) FROM stores
ORDER BY Store_Name ASC;  -- check for possible misspellings in the store names. None observed.

SELECT DISTINCT(Store_City) FROM stores
ORDER BY Store_City ASC;  -- check for possible misspellings in the store cities. None observed.

SELECT DISTINCT(Store_Location) FROM stores
ORDER BY Store_Location ASC; -- check for possible misspellings in the store locations. None observed.

SELECT COUNT(*) FROM stores WHERE
    Store_Open_Date <> DATE_FORMAT(Store_Open_Date, '%y-%m-%d');-- check for Date fields with inconsistent date format. None has.

SELECT 
    'Sale_ID',
    'Sales_Date',
    'Store_ID',
    'Product_ID',
    'Units',
    'Product_Name',
    'Product_Category',
    'Product_Cost',
    'Product_Price',
    'Product_Profit',
    'Store_Name',
    'Store_City',
    'Store_Location',
    'Store_Open_Date',
    'Stock_On_Hand'

UNION ALL SELECT 
    s.Sale_ID,
    s.Date AS Sales_Date,
    s.Store_ID,
    s.Product_ID,
    s.Units,
    p.Product_Name,
    p.Product_Category,
    p.Product_Cost,
    p.Product_Price,
    format(p.Product_Price - p.Product_Cost, 2) as Product_Price,
    st.Store_Name,
    st.Store_City,
    st.Store_Location,
    st.Store_Open_Date,
    i.Stock_On_Hand
FROM
    sales s
        JOIN
    products p ON s.Product_ID = p.Product_ID
        JOIN
    stores st ON s.Store_ID = st.Store_ID
        JOIN
    inventory i ON s.Store_ID = i.Store_ID
        AND s.Product_ID = i.Product_ID INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Mavin_Toys.csv' FIELDS ENCLOSED BY "" TERMINATED BY ',' ESCAPED BY "" LINES TERMINATED BY '\n'; 
        -- Export a joined table of necessary columns from the different tables into a csv file.