# 🚀 Fintech Loan Portfolio Analysis

This project analyzes a relational dataset from the `cloud-training-demos.fintech` BigQuery repository to develop a **Low-Risk Customer Segment Profile** and an optimized lending strategy, following the **CRISP-DM** methodology. The final output is a set of actionable success rates derived from cleaned, engineered data.

## 🎯 Business Objectives

The analysis was driven by three primary goals:

1.  **Customer Profiling (Predictive):** Identify the demographic and financial features (income, verification status, employment) that best predict a loan reaching **"Fully Paid"** status.
2.  **Temporal & Segment Analysis (Descriptive):** Quantify loan success rates across different customer segments (Income, Employment, Geography) to isolate high-value lending markets.
3.  **Customer Scoring (Classification):** Provide the foundation for a Propensity Score model to prioritize new leads based on their likelihood of success.

---

## 🛠️ Data Modeling and Preparation

The project transformed six raw, interconnected tables into a single, clean, model-ready view by executing comprehensive SQL DDL and DML commands.

### 1. Schema Setup (`01_ddl_setup.sql`)
* Defined the **Primary Keys (PKs)** and **Foreign Keys (FKs)** across all six tables (`customer`, `loan`, `state_region`, etc.) to enforce a strong relational data model.
* Executed initial data cleaning using `UPDATE` statements to standardize missing values (e.g., converting `'n/a'` and empty strings `''` to `NULL`).

### 2. Feature Engineering (Complex Views)

Two final analytical views were created to house all cleaning logic and calculated features:

#### `v_customer_clean` (Created in `02_data_prep_customer.sql`)
This view focuses on customer demographics and financial stability.

| Feature Engineering Task | Rationale |
| :--- | :--- |
| **`income_category`** | Created using an **IQR-based calculation** to define strategic segments: `Affluent` ($\ge 75\text{th}$ percentile outlier), `Upper-Middle Class`, `Middle Class`, and `Lower Income`. |
| **`emp_sector`** | Solved **high cardinality** ($\sim 89\text{k}$ unique titles) by grouping titles using `ILIKE` pattern matching into $11$ manageable sectors (e.g., `Government/Public`, `Technology/Engineering`). |
| **`standardized_emp_length_years`** | Converted categorical strings (`'10+ years'`, `'< 1 year'`) to numerical values (`10`, `0.5`) for modeling. |
| **`standardized_home_ownership`** | Consolidated low-volume categories (`ANY`, `NONE`, `OTHER`) into a single `OTHER` category. |

#### `v_final_data_model` (The Final Analytical Table)
This final view joins the cleaned customer and loan data and calculates the target metrics.

| Engineered Metric | Rationale |
| :--- | :--- |
| **`is_fully_paid`** | Binary target variable (`1` for 'Fully Paid', `0` for loss statuses) for classification modeling. |
| **`is_definitive_outcome`** | Flag used in the denominator of success rate calculations to exclude loans that are still **'Current'** (outcome unknown). |
| **`installment_to_income_ratio`** | Calculated as $\frac{\text{Installment}}{\text{Annual Income} / 12}$ to create a key financial burden predictor (Debt-to-Income proxy). |

---

## 💡 Key Analytical Findings

The initial analysis (`eda.sql`) provided actionable, non-obvious insights into risk:

| Segment Analyzed | Key Discovery | Business Implication |
| :--- | :--- | :--- |
| **Verification Status** | Loans with **"Source not verified"** status had a success rate that was **$\approx 8$ percentage points higher** than those that were "Source verified" (e.g., $81.82\%$ vs. $74.13\%$). | **Counter-Intuitive Insight:** The model must penalize 'Source verified' status, suggesting lender over-reliance or external wealth of unverified applicants. |
| **Income Category** | The **Affluent** segment ($\ge \$166\text{k}$) had a $\mathbf{7\%}$ higher success rate than the Lower Income segment ($\le \$47\text{k}$). | The risk differential is highly significant on a large portfolio; confirms the Affluent segment as the primary acquisition target. |
| **Employment Sector** | **Government/Public** and **Finance/Accounting** sectors demonstrated the highest loan success rates ($\approx 82\%$). | Marketing efforts should be prioritized toward job titles in these stable sectors. |
