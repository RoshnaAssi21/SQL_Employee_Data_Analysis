use employe_Project;
/*===========================================================================
01_data_cleaning.Sql
Project: Employee HR Analytics (MySQL)
Projcet: clean and standardize the 4 raw HR tables, then add keys.
=============================================================================*/

/*================================================= 
         1. Data Cleaning employee_data--
 ================================================= */  

 -- Quick look     
select * from employee_data limit 20;
Describe employee_data;

-- Dublicate check (all columns except the ID,since EmpID is unique )
select * from(select *,row_number() over(partition by FirstName,LastName,StartDate,ExitDate,Title,Supervisor,AdEmail,BusinessUnit,EmployeeStatus,EmployeeType,
payZone,EmployeeClassificationType,TerminationType,TerminationDescription,DepartmentType,Division,DOB,State,JobFunctionDescription,GenderCode,LocationCode,RaceDesc,
MaritalDesc,`Performance Score`,`Current Employee Rating`
)as row_num
from employee_data) as ranked_employee
where row_num > 1; -- 0 rows= no duplicates


select distinct FirstName from employee_data;

-- Convert StartDate text -> Date
update employee_data
set StartDate=str_to_date(StartDate,'%d-%b-%y');

alter table employee_data 
modify StartDate date;

-- ExitDate: blanks -> NULL first, then convert
update employee_data
set ExitDate =str_to_date(ExitDate,'%d-%b-%y')
where ExitDate is not null
and Trim(ExitDate)!= '';

update employee_data
set ExitDate =null 
where ExitDate ='' 
or trim(ExitDate) ='';

alter table employee_data 
modify ExitDate date;

-- DOB: 2-digit years such as '65' are read as 2065-> subtruct 100 years
update employee_data
set DOB =str_to_date(DOB,'%d-%b-%y');

alter table employee_data
modify DOB date;

update employee_data
set DOB=date_sub(DOB, interval 100 year)
where DOB > curdate();

-- Whitespace check on text columns (shoul return 0 rows after trimming)

SELECT Title, LENGTH(Title) AS col, LENGTH(TRIM(Title)) AS trimmed_len, COUNT(*) AS rows_with_extra_space
FROM employee_data
GROUP BY Title
HAVING LENGTH(Title) <> LENGTH(TRIM(Title));

SELECT Supervisor, LENGTH(Supervisor) AS len, LENGTH(TRIM(supervisor)) AS trimmed_len, COUNT(*) AS n
FROM employee_data
GROUP BY Supervisor
HAVING LENGTH(Supervisor) <> LENGTH(TRIM(Supervisor));

select BusinessUnit,length(BusinessUnit),length(trim(BusinessUnit)),count(*)
 from employee_data
 group by BusinessUnit
 having length(BusinessUnit)<> length(trim(BusinessUnit));
 
select EmployeeClassificationType,length(EmployeeClassificationType),length(trim(EmployeeClassificationType))
from employee_data
group by EmployeeClassificationType
having length(EmployeeClassificationType)<>length(trim(EmployeeClassificationType));

select JobFunctionDescription,length(JobFunctionDescription),length(trim(JobFunctionDescription)) 
from employee_data
group by JobFunctionDescription
having length(JobFunctionDescription)<>length(trim(JobFunctionDescription));

select RaceDesc,length(RaceDesc),length(trim(RaceDesc)) from employee_data
group by RaceDesc
having length(RaceDesc)<>length(trim(RaceDesc));

-- Trim (Only touches rows that actually need it)
update employee_data
set Title=trim(Title);

-- Review categorical column for inconsistent spellings/casing

select distinct EmployeeStatus from employee_data;
select distinct EmployeeType from employee_data;
select distinct PayZone from employee_data;
select distinct TerminationType from employee_data;
select distinct DepartmentType from employee_data;
select distinct Division from employee_data;
select distinct State from employee_data;
select distinct GenderCode from employee_data;
select distinct MaritalDesc from employee_data;
select distinct `Performance Score` from employee_data;
select LocationCode,count(*) from employee_data
group by LocationCode;

-- Missing TerminationDescription (Null vs empty string)
select count(*) from employee_data 
where TerminationDescription is null;

select count(*) from employee_data 
where trim(TerminationDescription)='';

/*==========================================================================
   2. employee_engagement_survey_data
============================================================================
*/

update employee_engagement_survey_data
set `Survey Date`=str_to_date(`Survey Date`,'%d-%b-%y');

alter table employee_engagement_survey_data
modify `Survey Date` date; 

/*===================================================================
  3.training_and_developmemt_data
=====================================================================
*/
select * from training_and_development_data;

update training_and_development_data
set `Training Date`= str_to_date(`Training Date`,'%d-%b-%y');

alter table training_and_development_data
modify `Training Date` date;

select distinct `Training Program Name` from training_and_development_data;
select distinct `Training Type` from training_and_development_data;
select distinct `Training Outcome` from training_and_development_data;

select Trainer,count(*) from training_and_development_data 
group by Trainer;

select Trainer,length(Trainer),length(trim(Trainer)) from training_and_development_data
group by Trainer
having length(Trainer)<>length(trim(Trainer));

/*============================================================
4.Recruitment_data
===============================================================
*/
select * from recruitment_data;

update recruitment_data
set `Application Date`=str_to_date(`Application Date`,'%d-%b-%y');

alter table recruitment_data
modify `Application Date` date;

-- Blank first names
select count(*),`First Name`
from recruitment_data
group by `First Name`
having `First Name`=trim(`First Name`)='';

select distinct Gender from recruitment_data;
select * from recruitment_data;

-- Date of Birth with the same 2-digit-year correction
update recruitment_data
set `Date of Birth`=case 
when str_to_date(`Date of Birth`,'%d-%b-%y')> curdate()
then date_sub(str_to_date(`Date of Birth`,'%d-%b-%y'), interval 100 year)
else str_to_date(`Date of Birth`,'%d-%b-%y')
end;

alter table recruitment_data
modify `Date of Birth` Date;

-- check Whitespace + Categorical review

select city,length(city),length(trim(city)),count(*)
from recruitment_data
group by city
having length(city)<> length(trim(city));

select Country,length(Country),length(trim(Country)),count(*)
from recruitment_data
group by Country
having length(Country)<> length(trim(Country));

select distinct Country from recruitment_data;
select distinct `Status` from recruitment_data;
select distinct `Job Title` from recruitment_data;

-- Duplicate check (excluding Applicant ID)
with cte as(
select *,row_number() over(partition by `Applicant ID`,`Application Date`,`First Name`,`Last Name`,Gender,Email,Address,City,State,`Zip Code`,Country,
`Education Level`,`Years of Experience`,`Desired Salary`,`Job Title`,`Status`)as rownum
 from recruitment_data
)select* from cte
where rownum > 1;

select Email,count(*) from recruitment_data
group by Email
having count(*)>1;


/*============================================
  Keys & referencial integrity
=============================================*/
-- is EmpID unique? (0 rows expected)
select EmpID,count(*) from employee_data
group by EmpID
having count(*)>1;

 
-- One row per employee in the child tables? (0 rows = one-to-one)
select `Employee ID`,count(*) from employee_engagement_survey_data
group by `Employee ID`
having count(*)>1;

select `Employee ID`,count(*) from training_and_development_data
group by `Employee ID`
having count(*)>1;

-- Orphan records (0 rows expected, otherwise the FKs below will fail)
select s.`employee ID`
from employee_engagement_survey_data as s
left join employee_data as e ON s.`employee ID`=e.EmpID
where e.EmpID is null;

-- Constraints
alter table employee_data add primary key (EmpID);

alter table employee_engagement_survey_data
add constraint fk_employee_survey
foreign key (`Employee ID`) references employee_data (EmpID);

alter table training_and_development_data
add constraint fk_employee_training
foreign key(`Employee ID`) references employee_data (EmpID);

