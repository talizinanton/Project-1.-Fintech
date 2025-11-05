CREATE VIEW v_customer_clean AS


-- STEP 1: Calculate Quartiles (Boundary Data)
WITH QuartilesIncome AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY annual_inc) AS Q1_annual_inc,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY annual_inc) AS Q3_annual_inc
    FROM customer
),

IqrAndBounds AS (
    -- Calculate IQR and the High Bound for Affluent segmentation
    SELECT 
        Q1_annual_inc,
        Q3_annual_inc,
        (Q3_annual_inc - Q1_annual_inc) AS IQR,
        (Q3_annual_inc + 1.5 * (Q3_annual_inc - Q1_annual_inc)) AS high_income_boundary 
    FROM QuartilesIncome
),

-- STEP 2: Clean and Standardize Customer Features
CustomerCleaned AS (
    SELECT 
        c.*, -- Start by selecting all columns for the chaining process
        -- a) Impute Missing Values (emp_title and joint income)
        COALESCE(c.emp_title, 'Unknown') AS standardized_emp_title,
        COALESCE(c.annual_inc_joint, 0) AS standardized_joint_income
    FROM customer c
),

EmpSector AS (
    -- b) Group employment title into manageable sectors
    SELECT *,
        CASE
			-- 1. Missing Data 
		    WHEN standardized_emp_title = 'Unknown' THEN 'Z_Missing' 
		    
		    -- 2. Management/Executive 
		    WHEN standardized_emp_title ILIKE '%Manager%' 
		    OR standardized_emp_title ILIKE '%Director%' 
		    OR standardized_emp_title ILIKE '%Supervisor%' 
		    OR standardized_emp_title ILIKE '%Chief%' 
		    OR standardized_emp_title ILIKE '%Executive%' THEN 'Management/Executive'
	
		    -- 3. Construction & Trade
		    WHEN standardized_emp_title ILIKE '%Construct%' 
		    OR standardized_emp_title ILIKE '%Mechanic%' 
		    OR standardized_emp_title ILIKE '%Plumber%' 
		    OR standardized_emp_title ILIKE '%Electrician%' 
		    OR standardized_emp_title ILIKE '%Laborer%' THEN 'Construction/Trade'
		    
		    -- 4. Government/Public Service 
		    WHEN standardized_emp_title ILIKE '%Police%' 
		    OR standardized_emp_title ILIKE '%Fire%' 
		    OR standardized_emp_title ILIKE '%Military%' 
		    OR standardized_emp_title ILIKE '%Govt%' 
		    OR standardized_emp_title ILIKE '%Federal%' THEN 'Government/Public'
		    
		    -- 5. Technology/Engineering
		    WHEN standardized_emp_title ILIKE '%Engineer%' 
		    OR standardized_emp_title ILIKE '%Analyst%' 
		    OR standardized_emp_title ILIKE '%Developer%' 
		    OR standardized_emp_title ILIKE '%IT%' 
		    OR standardized_emp_title ILIKE '%Data%' THEN 'Technology/Engineering'
	
		    -- 6. Education
		    WHEN standardized_emp_title ILIKE '%Teacher%' 
		    OR standardized_emp_title ILIKE '%Education%' 
		    OR standardized_emp_title ILIKE '%Professor%' THEN 'Education'
		    
		    -- 7. Healthcare
		    WHEN standardized_emp_title ILIKE '%Nurse%' 
		    OR standardized_emp_title ILIKE '%Doctor%' 
		    OR standardized_emp_title ILIKE '%Medical%' 
		    OR standardized_emp_title ILIKE '%Therapist%' THEN 'Healthcare'
	
		    -- 8. Finance 
		    WHEN standardized_emp_title ILIKE '%Financial%' 
		    OR standardized_emp_title ILIKE '%Accountant%' 
		    OR standardized_emp_title ILIKE '%Credit%' 
		    OR standardized_emp_title ILIKE '%Bank%' 
		    OR standardized_emp_title ILIKE '%Auditor%' 
		    OR standardized_emp_title ILIKE '%Loan%' THEN 'Finance/Accounting'
		    
		    -- 9. Sales 
		    WHEN standardized_emp_title ILIKE '%Sales%' 
		    OR standardized_emp_title ILIKE '%Rep%' 
		    OR standardized_emp_title ILIKE '%Agent%' THEN 'Sales'
	
		    -- 10. Retail & Service (Combined for better volume)
		    WHEN standardized_emp_title ILIKE '%Retail%' 
		    OR standardized_emp_title ILIKE '%Server%' 
		    OR standardized_emp_title ILIKE '%Chef%' 
		    OR standardized_emp_title ILIKE '%Store%' THEN 'Retail/Service'
		    
		    -- 11. Catch-all for remaining low-volume/miscellaneous titles
            ELSE 'Other Highly Varied'
        END AS emp_sector
    FROM CustomerCleaned
),

EmpLengthFixed AS (
    -- c) Convert employment length string to numerical years
    SELECT *,
        CASE
            WHEN emp_length IS NULL THEN NULL 
            WHEN emp_length = '< 1 year' THEN 0.5
            WHEN emp_length = '10+ years' THEN 10
            ELSE CAST(REPLACE(REPLACE(emp_length, ' years', ''), ' year', '') AS NUMERIC)
        END AS standardized_emp_length_years
    FROM EmpSector
),

StandardizedCategorical AS (
    -- d) Consolidate home ownership and standardize verification status
    SELECT 
        *,
        CASE WHEN home_ownership IN ('ANY', 'NONE', 'OTHER') THEN 'OTHER'
        ELSE home_ownership
        END AS standardized_home_ownership,
        
        CASE 
            WHEN verification_status IN ('Verified', 'Source Verified') THEN 'Source verified'
            WHEN verification_status = 'Not Verified' THEN 'Source not verified'
            ELSE 'Other/Unspecified' 
        END AS standardized_verification_status
    FROM EmpLengthFixed
)



-- STEP 3: Final SELECT statement for the View (using all CTEs)
SELECT 
    -- Select the cleaned and engineered features
    s.customer_id,
    s.annual_inc,
    s.standardized_joint_income,
    s.avg_cur_bal, -- Numeric columns remain for potential scaling

    -- Engineered Features
    s.emp_sector,
    s.standardized_emp_length_years,
    s.standardized_home_ownership,
    s.standardized_verification_status,
    
    -- Numerical Binning (Joining the IQR boundaries)
    CASE
        -- Top Tier (Affluent)
        WHEN s.annual_inc >= lh.high_income_boundary THEN 'Affluent'
        
        -- Upper-Middle Class
        WHEN s.annual_inc >= lh.Q3_annual_inc THEN 'Upper-Middle Class'
        
        -- Middle Class
        WHEN s.annual_inc >= lh.Q1_annual_inc THEN 'Middle Class'
        
        -- Lower Income
        ELSE 'Lower Income'
    END AS income_category,
    
    -- Keep other original columns if needed for joins/reference
    s.zip_code,
    s.addr_state
    
FROM StandardizedCategorical s
CROSS JOIN IqrAndBounds lh