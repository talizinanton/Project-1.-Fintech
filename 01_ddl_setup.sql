-- 1. Set the Primary Key for the customer table
ALTER TABLE customer
ADD CONSTRAINT PK_customer
PRIMARY KEY (customer_id)

-- 2. Set the Primary Key for the loan table
ALTER TABLE loan
ADD CONSTRAINT PK_loan
PRIMARY KEY (loan_id)

-- 3. Set the Primary Key for the loan_count_by_year table
ALTER TABLE loan_count_by_year 
ADD CONSTRAINT PK_loan_count_by_year
PRIMARY KEY (issue_year)

-- 4. Set the Primary Key for the loan_purposes table
ALTER TABLE loan_purposes 
ADD CONSTRAINT PK_loan_purposes
PRIMARY KEY (purpose)

-- 5. Set the Primary Key for the loan_with_region table
ALTER TABLE loan_with_region 
ADD CONSTRAINT PK_loan_with_region
PRIMARY KEY (loan_id)

-- 6. Set the Primary Key for the state_region table
ALTER TABLE state_region 
ADD CONSTRAINT PK_state_region
PRIMARY KEY (state)




-- Setting Foreign Keys (FKs)

-- 1. Set the Foreign Key for the loan table to connect to the customer table
ALTER TABLE loan 
ADD CONSTRAINT FK_loan_customer
FOREIGN KEY (customer_id)
REFERENCES customer (customer_id)

-- 2. Set the Foreign Key for the loan table to connect to the loan_purposes table
ALTER TABLE loan
ADD CONSTRAINT FK_loan_loan_purposes 
FOREIGN KEY (purpose)
REFERENCES loan_purposes (purpose)

-- 3. Set the Foreign Key for the loan_with_region table to connect to the loan table
ALTER TABLE loan_with_region
ADD CONSTRAINT FK_loan_with_region_loan
FOREIGN KEY (loan_id)
REFERENCES loan (loan_id)

-- 4. Set the Foreign Key for the customer table to connect to the state_region table
ALTER TABLE customer
ADD CONSTRAINT FK_customer_state_region
FOREIGN KEY (addr_state)
REFERENCES state_region (state)




-- Standardize empty strings to NULL 
UPDATE customer
SET emp_title = NULL
WHERE TRIM(emp_title) = ''

UPDATE customer
SET emp_length = NULL
WHERE emp_length = 'n/a'


