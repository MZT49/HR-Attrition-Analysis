# Dataset Notes

## Source
- **Dataset:** IBM HR Analytics Employee Attrition
- **Provider:** Kaggle
- **File included:** HR-Employee-Attrition.csv

## Dataset Details
- **Rows:** 1,470 employees
- **Columns:** 35
- **Target variable:** Attrition (Yes/No)

## Columns Used in Analysis
Department, JobRole, OverTime, MonthlyIncome, JobSatisfaction, Attrition, EmployeeCount

## Data Cleaning
- No missing values found
- Attrition stored as text ("Yes"/"No") used CASE WHEN for conditional counting
- JobSatisfaction stored as numeric scale (1-4) binned into Low/Medium/High using CASE WHEN
- MonthlyIncome grouped into income bands for trend analysis