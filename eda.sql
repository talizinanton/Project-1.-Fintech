-- creating CTE with new column (prev_year)
WITH LagYear AS (
	SELECT 
		issue_year
		, loan_count 
		, LAG (loan_count) OVER (ORDER BY issue_year) AS prev_year --column containing value from previous year
	FROM loan_count_by_year
	ORDER BY 1
)
--showing the percentage change Year-to-Year
SELECT issue_year, loan_count, round((1.0*(loan_count - prev_year) / prev_year)*100.0, 2) AS change_in_precent
FROM LagYear



-- top 10 states by customer count 
SELECT  
	addr_state
	, count(*) 
FROM customer 
GROUP BY 1 
ORDER BY 2 DESC 
LIMIT 10



--most preffered term for loan
SELECT  
	term
	, round(count(*) / ((SELECT count(*) FROM loan)*1.0) * 100, 2) AS percent_of_total
FROM loan 
GROUP BY 1 
ORDER BY 2 DESC 




-- newly created views


-- employee sector distribution 

SELECT 
	emp_sector 
	, count(*) AS emp_count
	, round(1.0*count(*) / (SELECT count(customer_id) FROM customer), 2) AS emp_percentage
	
FROM v_customer_clean
GROUP BY 1
ORDER BY 2 DESC 



-- standardized_emp_length_years distribution 
SELECT 
	standardized_emp_length_years 
	, count(*) AS emp_count
	, round(1.0*count(*) / (SELECT count(customer_id) FROM customer), 2) AS emp_percentage
	
FROM v_customer_clean
GROUP BY 1
ORDER BY 2 DESC 


-- income_category distribution 
SELECT 
	income_category 
	, count(*) AS emp_count
	, round(1.0*count(*) / (SELECT count(customer_id) FROM customer), 2) AS emp_percentage
	
FROM v_customer_clean
GROUP BY 1
ORDER BY 2 DESC 


-- loan_application_type distribution 
SELECT 
	loan_application_type 
	, count(*) AS emp_count
	, round(1.0*count(*) / (SELECT count(customer_id) FROM customer), 2) AS emp_percentage
	
FROM v_loan_clean
GROUP BY 1
ORDER BY 2 DESC 