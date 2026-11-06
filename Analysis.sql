/* ===============================================================================
02_ analysis.sql
Project: Employee HR Analytics (MYSQL)
Purpose: Business questions answered on top of the cleaned data.
==================================================================================*/

Use employe_project;
-- Unified view of employee + engagement + training
-- (valid as one row per employee because both child tables were chechedd as one-to-one)
select e.EmpID, e.DepartmentType, e.Division, e.EmployeeStatus, e.EmployeeType, e.StartDate,
e.ExitDate, e.GenderCode, e.`Performance Score`, s.`Engagement Score`, s.`Satisfaction Score`,
t.`Training Outcome`, t.`Training Cost`
from employee_data e
Left Join employee_engagement_survey_data s ON e.EmpID =s.`Employee ID`
Left Join training_and_development_data t ON e.EmpID =t.`Employee ID`;

select * from employee_data;
select * from employee_engagement_survey_data;
select * from training_and_development_data;
-- creating view
create view analysis_view As
select e.*, 
s.`Engagement Score`, s.`Satisfaction Score`, s.`Work-Life Balance Score`,
t.`Training Program Name`,t.`Training Outcome`, t.`Training Cost`
from employee_data e
Left Join employee_engagement_survey_data s ON e.EmpID = s.`Employee ID`
Left Join training_and_development_data t ON e.EmpID = t.`Employee ID`;

-- Q1. Headcount, leavers and attrition rate by department
SELECT DepartmentType,
       COUNT(*) AS headcount,
       SUM(ExitDate IS NOT NULL) AS leavers,
       ROUND(100 * SUM(ExitDate IS NOT NULL) / COUNT(*), 1) AS attrition_pct
FROM employee_data
GROUP BY DepartmentType
ORDER BY attrition_pct DESC;

-- Q2. Why do people leave?
SELECT TerminationType, COUNT(*) AS leavers
FROM employee_data
WHERE ExitDate IS NOT NULL
GROUP BY TerminationType
ORDER BY leavers DESC;

-- Q3. Average tenure (years) of leavers vs current employees
SELECT CASE WHEN ExitDate IS NULL THEN 'Current' ELSE 'Left' END AS status,
       ROUND(AVG(DATEDIFF(COALESCE(ExitDate, CURDATE()), StartDate) / 365.25), 1) AS avg_tenure_years
FROM employee_data
GROUP BY status;

-- Q4. Average engagement & satisfaction by department
SELECT DepartmentType,
       ROUND(AVG(`Engagement Score`), 2)   AS avg_engagement,
       ROUND(AVG(`Satisfaction Score`), 2) AS avg_satisfaction
FROM vw_employee_overview
GROUP BY DepartmentType
ORDER BY avg_engagement DESC;

-- Q5. Do leavers have lower engagement than people who stayed?
SELECT CASE WHEN ExitDate IS NULL THEN 'Current' ELSE 'Left' END AS status,
       ROUND(AVG(`Engagement Score`), 2)   AS avg_engagement,
       ROUND(AVG(`Satisfaction Score`), 2) AS avg_satisfaction
FROM vw_employee_overview
GROUP BY status;

-- Q6. Performance score distribution
SELECT `Performance Score`, COUNT(*) AS employees,
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM employee_data
GROUP BY `Performance Score`
ORDER BY employees DESC;

-- Q7. Training: spend and outcomes
SELECT `Training Outcome`,
       COUNT(*) AS sessions,
       ROUND(SUM(`Training Cost`), 2) AS total_cost,
       ROUND(AVG(`Training Cost`), 2) AS avg_cost
FROM training_and_development_data
GROUP BY `Training Outcome`
ORDER BY total_cost DESC;

-- Q8. Training cost by department
SELECT DepartmentType, ROUND(SUM(`Training Cost`), 2) AS total_training_cost
FROM vw_employee_overview
GROUP BY DepartmentType
ORDER BY total_training_cost DESC;

-- Q9. Recruitment funnel by application status
SELECT `Status`, COUNT(*) AS applicants,
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM recruitment_data
GROUP BY `Status`
ORDER BY applicants DESC;

-- Q10. Most in-demand job titles among applicants
SELECT `Job Title`, COUNT(*) AS applications, ROUND(AVG(`Desired Salary`), 0) AS avg_desired_salary
FROM recruitment_data
GROUP BY `Job Title`
ORDER BY applications DESC
LIMIT 10;

-- Q11. Hires per year
SELECT YEAR(StartDate) AS year, COUNT(*) AS hires
FROM employee_data
GROUP BY YEAR(StartDate)
ORDER BY year;

-- Q12. Gender split by department
SELECT DepartmentType, GenderCode, COUNT(*) AS employees
FROM employee_data
GROUP BY DepartmentType, GenderCode
ORDER BY DepartmentType, employees DESC;

