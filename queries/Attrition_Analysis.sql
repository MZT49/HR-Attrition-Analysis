________________________________________________________________
-- Query 1: Overall Attrition Rate by Department
-- Business Question: Which departments lose the most employees?

SELECT Department,
       Total_Employee,
       Attrition_Count,
       ROUND(CAST(Attrition_Count AS FLOAT) / Total_Employee, 2) AS Attrition_Rate
FROM 
(
SELECT Department,
       COUNT(EmployeeCount) AS Total_Employee,
       COUNT(CASE WHEN Attrition = 'Yes' THEN 1 END) AS Attrition_Count
FROM HR_Employee_Attrition
GROUP BY Department
) CT
;      -- Finding: Sales has the highest attrition rate at 21% (92 of 446 employees),
       --          followed by HR at 19% (12 of 63). R&D has the lowest rate at 14% despite having the most total leavers (133) due to its much larger headcount.

______________________________________________________________________________
-- Query 2: Attrition by Job Role
-- Business Question: Which specific job roles have the highest attrition rate?

SELECT JobRole ,
       Total_Employee,
       Attrition_Count,
       ROUND(CAST(Attrition_Count AS FLOAT) / Total_Employee, 3) AS Attrition_Rate
FROM 
(
SELECT JobRole,
       COUNT(EmployeeCount) AS Total_Employee,
       COUNT(CASE WHEN Attrition = 'Yes' THEN 1 END) AS Attrition_Count
FROM HR_Employee_Attrition
GROUP BY JobRole 
) RoleStats
ORDER BY Attrition_Rate DESC 
;  -- Finding: Sales Representative has by far the highest attrition rate at 39.8% (33 of 83 employees), followed by Laboratory Technician at 23.9%.
   --          Senior roles like Research Director (2.5%) and Manager (4.9%) are the most stable, showing a clear link between seniority and retention.

___________________________________________________________________________
-- Query 3: Does Overtime Drive Attrition?
-- Business Question: Are employees working overtime more likely to leave?

SELECT OverTime ,
       Total_Employee,
       Attrition_Count,
       ROUND(CAST(Attrition_Count AS FLOAT) / Total_Employee, 3) AS Attrition_Rate
FROM 
(
SELECT OverTime,
       COUNT(EmployeeCount) AS Total_Employee,
       COUNT(CASE WHEN Attrition = 'Yes' THEN 1 END) AS Attrition_Count
FROM HR_Employee_Attrition
GROUP BY OverTime 
) RoleStats
ORDER BY Attrition_Rate DESC 
;  -- Finding: Employees who work overtime leave at nearly 3x the rate of those
   --          who don't (30.5% vs 10.4%). This is the strongest single finding in the analysis and points to workload/burnout as a major attrition driver.

________________________________________________________________
-- Query 4a: Income Band vs Attrition Rate
-- Business Question: Do lower-paid employees leave more often?

WITH Calculation_Table AS 
(
SELECT CASE WHEN [ MonthlyIncome ] <= 5000 THEN 'Below $5000'
            WHEN [ MonthlyIncome ] BETWEEN 5000 AND 15000 THEN '$5000-$15000'
            ELSE 'Above $15000'
        END AS Income_Segment,
       COUNT(EmployeeCount) AS Total_Employee,
       COUNT(CASE WHEN Attrition = 'Yes' THEN 1 END) AS Attrition_Count
FROM HR_Employee_Attrition
GROUP BY CASE WHEN [ MonthlyIncome ] <= 5000 THEN 'Below $5000'
            WHEN [ MonthlyIncome ] BETWEEN 5000 AND 15000 THEN '$5000-$15000'
            ELSE 'Above $15000'
        END
)
SELECT Income_Segment,
       Total_Employee,
       Attrition_Count,
       ROUND(CAST(Attrition_Count AS FLOAT) / Total_Employee, 2) AS Attrition_Rate
FROM Calculation_Table
GROUP BY Income_Segment,
       Total_Employee,
       Attrition_Count
ORDER BY Attrition_Count DESC 
;  -- Finding: Attrition rate drops sharply as income rises 22% for employees earning below $5,000/month, 12% for $5,000-$15,000, and just 4%
   --          for employees earning above $15,000/month.
___________________________________________________________________________________________________________
-- Query 4b: Average Income — Leavers vs Retained
-- Business Question: How does average compensation differ between employees who left and those who stayed?

SELECT CASE WHEN Attrition = 'Yes' THEN 'Leavers'
            ELSE 'Retained'
       END  AS Employee,
       COUNT(EmployeeCount ) AS Total_Employee,
       SUM([ MonthlyIncome ] ) AS Total_Income,  
       AVG([ MonthlyIncome ] ) AS Avg_Income
FROM HR_Employee_Attrition
GROUP BY CASE WHEN Attrition = 'Yes' THEN 'Leavers' ELSE 'Retained' END
;  -- Finding: Employees who left averaged $4,787/month compared to $6,832/month for retained employees,
   --          A $2,045 gap, confirming compensation is a meaningful driver of attrition.

________________________________________________________________________
-- Query 5: Job Satisfaction vs Attrition
-- Business Question: Do employees with low job satisfaction leave more?

WITH JobSatisfaction_Segment AS
(
SELECT CASE WHEN JobSatisfaction = 1 THEN 'Low'
            WHEN JobSatisfaction = 4 THEN 'High'
            ELSE 'Medium'
            END AS Job_Satisfaction,
        Attrition     
FROM HR_Employee_Attrition
)              -- Note: Used a CTE to bin JobSatisfaction's numeric scale (1-4) into Low/Medium/High categories before aggregating.
SELECT Job_Satisfaction,
       Total_Employee,
       Leavers,
       ROUND(CAST(leavers AS FLOAT)/ Total_Employee, 2) AS Attrition_Rate
FROM 
(
SELECT Job_Satisfaction,
       COUNT(*) AS Total_Employee,
       COUNT(CASE WHEN Attrition = 'Yes' THEN 1 END) AS Leavers
FROM JobSatisfaction_Segment 
GROUP BY Job_Satisfaction 
) Count_Sg
ORDER BY Attrition_Rate 
;  -- Finding: Attrition rate is 23% for employees reporting low satisfaction,
   --          16% for medium, and 11% for high a clear, consistent pattern showing satisfaction is strongly linked to retention.