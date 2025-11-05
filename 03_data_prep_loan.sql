CREATE VIEW v_loan_clean AS
SELECT
    loan_id,
    customer_id,
    loan_amount,
    int_rate,
    term,
    issue_year,
    -- Target Variable: 1 for Fully Paid (Success), 0 for failure (Default/Charged Off/etc.)
    CASE
        WHEN loan_status = 'Fully Paid' THEN 1
        WHEN loan_status IN ('Charged Off', 'Default', 'Late (31-120 days)', 'Late (16-30 days)') THEN 0
        ELSE NULL -- Ignore 'Current' loans for classification modeling (as their outcome is unknown)
    END AS loan_success_target,

    -- Consolidate Loan Purposes
    CASE
        WHEN purpose IN ('home_improvement', 'house', 'renewable_energy') THEN 'Home_Property_Upgrade'
        WHEN purpose IN ('vacation', 'moving', 'wedding') THEN 'Lifestyle_Personal'
        ELSE purpose
    END AS standardized_purpose,

    -- Consolidate Loan Types
    CASE
        WHEN type ILIKE '%INDIVIDUAL%' THEN 'Individual'
        WHEN type ILIKE '%JOINT%' THEN 'Joint'
        ELSE 'Other'
    END AS loan_application_type,
    

    -- Retain other key features
    grade,
    installment,
    loan_status 
    
FROM loan


