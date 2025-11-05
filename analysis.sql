-- success rate of each income_category
WITH S_Rate_By_Segment AS (
	SELECT 
		c.income_category 
		
		-- count the number of successfull outcomes - Numerator  
		, count(CASE WHEN l.loan_status = 'Fully Paid' THEN 1 END) AS fully_paid_loan_count

		
		-- count the number of definitive loan outcomes (Default, Charged off etc.) - Denominator
		, count(CASE WHEN l.loan_status != 'Current' THEN 1 END) AS definitive_outcome_count
		
	FROM v_customer_clean c
	JOIN v_loan_clean l ON l.customer_id = c.customer_id
	GROUP BY 1
)

SELECT 
	income_category
	, round(100.00*fully_paid_loan_count / definitive_outcome_count, 2) AS fully_paid_success_rate_percent
FROM S_Rate_By_Segment
WHERE definitive_outcome_count > 0 -- Ensure we only analyze segments with closed loans
ORDER BY fully_paid_success_rate_percent DESC



-- success rate of each emp_sector
WITH S_Rate_By_Emp_Sector AS (
	SELECT 
		c.emp_sector  
		
		-- count the number of successfull outcomes - Numerator  
		, count(CASE WHEN l.loan_status = 'Fully Paid' THEN 1 END) AS fully_paid_loan_count

		
		-- count the number of definitive loan outcomes (Default, Charged off etc.) - Denominator
		, count(CASE WHEN l.loan_status != 'Current' THEN 1 END) AS definitive_outcome_count
		
	FROM v_customer_clean c
	JOIN v_loan_clean l ON l.customer_id = c.customer_id
	GROUP BY 1
)

SELECT 
	emp_sector
	, round(100.00*fully_paid_loan_count / definitive_outcome_count, 2) AS fully_paid_success_rate_percent
FROM S_Rate_By_Emp_Sector
WHERE definitive_outcome_count > 0 -- Ensure we only analyze segments with closed loans
ORDER BY fully_paid_success_rate_percent DESC



-- success rate of employees with different employment length 
WITH S_Rate_By_Emp_Length AS (
	SELECT 
		c.standardized_emp_length_years  
		
		-- count the number of successfull outcomes - Numerator  
		, count(CASE WHEN l.loan_status = 'Fully Paid' THEN 1 END) AS fully_paid_loan_count

		
		-- count the number of definitive loan outcomes (Default, Charged off etc.) - Denominator
		, count(CASE WHEN l.loan_status != 'Current' THEN 1 END) AS definitive_outcome_count
		
	FROM v_customer_clean c
	JOIN v_loan_clean l ON l.customer_id = c.customer_id
	GROUP BY 1
)

SELECT 
	standardized_emp_length_years
	, round(100.00*fully_paid_loan_count / definitive_outcome_count, 2) AS fully_paid_success_rate_percent
FROM S_Rate_By_Emp_Length
WHERE definitive_outcome_count > 0 -- Ensure we only analyze segments with closed loans
ORDER BY fully_paid_success_rate_percent DESC



-- success rate of employees with different verification status
WITH S_Rate_By_Ver AS (
	SELECT 
		c.standardized_verification_status 
		
		-- count the number of successfull outcomes - Numerator  
		, count(CASE WHEN l.loan_status = 'Fully Paid' THEN 1 END) AS fully_paid_loan_count

		
		-- count the number of definitive loan outcomes (Default, Charged off etc.) - Denominator
		, count(CASE WHEN l.loan_status != 'Current' THEN 1 END) AS definitive_outcome_count
		
	FROM v_customer_clean c
	JOIN v_loan_clean l ON l.customer_id = c.customer_id
	GROUP BY 1
)

SELECT 
	standardized_verification_status
	, round(100.00*fully_paid_loan_count / definitive_outcome_count, 2) AS fully_paid_success_rate_percent
FROM S_Rate_By_Ver
WHERE definitive_outcome_count > 0 -- Ensure we only analyze segments with closed loans
ORDER BY fully_paid_success_rate_percent DESC



-- success rate of employees with different states
WITH S_Rate_States AS (
	SELECT 
		c.addr_state  
		
		-- count the number of successfull outcomes - Numerator  
		, count(CASE WHEN l.loan_status = 'Fully Paid' THEN 1 END) AS fully_paid_loan_count

		
		-- count the number of definitive loan outcomes (Default, Charged off etc.) - Denominator
		, count(CASE WHEN l.loan_status != 'Current' THEN 1 END) AS definitive_outcome_count
		
	FROM v_customer_clean c
	JOIN v_loan_clean l ON l.customer_id = c.customer_id
	GROUP BY 1
)

SELECT 
	addr_state
	, round(100.00*fully_paid_loan_count / definitive_outcome_count, 2) AS fully_paid_success_rate_percent
FROM S_Rate_States
WHERE definitive_outcome_count > 0 -- Ensure we only analyze segments with closed loans
ORDER BY fully_paid_success_rate_percent DESC