DROP TABLE IF EXISTS final_dataset;

--Table Creation

CREATE TABLE final_dataset AS
SELECT 
    l.LoanID,
    l.CustomerID,

    -- Loan Info
    l.Loan_Amount,
    l.Loan_Term_Months,
    l.Interest_Rate,
    l.EMI,
    l.Loan_Purpose,
    l.Application_Channel,

    -- Customer Info
    c.Age,
    c.Gender,
    c.Marital_Status,
    c.Number_of_Dependents,
    c.Education_Level,

    -- Financial Info
    f.Employment_Status,
    f.Job_Type,
    f.Years_Employed,
    f.Income_Type,
    f.Annual_Income,
    f.Monthly_Income,
    f.Income_Stability_Score,

    -- Credit Info
    cp.Credit_Score,
    cp.Credit_Utilization_Ratio,
    cp.Number_of_Previous_Loans,
    cp.Previous_Defaults,
    cp.Delinquencies,
    cp.Number_of_Active_Loans,
    cp.Avg_Days_Past_Due,

    -- Risk
    r.EMI_to_Income_Ratio,
    r.Loan_to_Income_Ratio,
    r.Debt_to_Income_Ratio,
    r.High_Risk_Flag,
    r.Low_Income_Flag,
    r.High_Loan_Flag,
    r.Default_Status,

    -- Behavioral Features
    t.avg_monthly_spending,
    t.spending_to_income_ratio,
    t.balance_volatility,
    t.rent_payment_ratio,
    t.behavioral_risk_score

FROM loans l
JOIN customers c ON l.CustomerID = c.CustomerID
JOIN financials f ON l.CustomerID = f.CustomerID
JOIN credit_profile cp ON l.CustomerID = cp.CustomerID
JOIN risk_analysis r 
    ON l.CustomerID = r.CustomerID AND l.LoanID = r.LoanID
LEFT JOIN transaction_features t 
    ON l.CustomerID = t.CustomerID;

--Query 1
--Default Rate by Income
SELECT 
    CASE 
        WHEN Monthly_Income < 30000 THEN 'Low'
        WHEN Monthly_Income < 80000 THEN 'Medium'
        ELSE 'High'
    END AS income_group,
    COUNT(*) AS total_loans,
    AVG(Default_Status) AS default_rate
FROM final_dataset
GROUP BY income_group;



--Query 2
--Credit Score vs Default
SELECT 
    ROUND(Credit_Score / 50) * 50 AS score_bucket,
    AVG(Default_Status) AS default_rate
FROM final_dataset
GROUP BY score_bucket
ORDER BY score_bucket;

--Query 3
--Behavioral Risk Impact
SELECT 
    CASE 
        WHEN behavioral_risk_score < 0.3 THEN 'Low'
        WHEN behavioral_risk_score < 0.6 THEN 'Medium'
        ELSE 'High'
    END AS risk_level,
    AVG(Default_Status) AS default_rate
FROM final_dataset
GROUP BY risk_level;

--Query 4
--Loan Purpose Risk
SELECT 
    Loan_Purpose,
    AVG(Default_Status) AS default_rate
FROM final_dataset
GROUP BY Loan_Purpose
ORDER BY default_rate DESC;

--Query 5
--Top Risk Customers
SELECT *
FROM final_dataset
ORDER BY behavioral_risk_score DESC
LIMIT 20;
