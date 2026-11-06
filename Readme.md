# Employee HR Analytics – SQL Project

Cleaned and analyzed four related HR datasets in **MySQL** to uncover patterns in employee attrition, engagement, training and recruitment.

## Project Overview
Raw HR data often arrives with text-formatted dates, inconsistent spacing, blank values and no defined relationships between tables. This project takes four raw files through a full workflow:

1. **Clean** the data (dates, blanks, whitespace, duplicates)
2. **Model** it (primary key and foreign keys)
3. **Analyze** it with SQL to answer business questions

## Dataset
Source: [Dataset name](PASTE-LINK-HERE)
Raw files are stored in [`data/raw/`](data/raw).

| Table | Description | Key |
|---|---|---|
| `employee_data` | Employee profile, department, status and termination details | `EmpID` (PK) |
| `employee_engagement_survey_data` | Engagement and satisfaction scores | `Employee ID` (FK → `EmpID`) |
| `training_and_development_data` | Training programs, outcomes and costs | `Employee ID` (FK → `EmpID`) |
| `recruitment_data` | Job applicants and application status | `Applicant ID` |

## Repository Structure
```
├── data/
│   └── raw/                    # original Excel files (before cleaning)
├── sql/
│   ├── 01_data_cleaning.sql    # cleaning, type conversion, keys
│   └── 02_analysis.sql         # view + business questions
├── README.md
└── .gitignore
```

## Data Cleaning Steps
- Converted text dates (`DD-Mon-YY`) to proper `DATE` type in all tables using `STR_TO_DATE`
- Replaced blank `ExitDate` values with `NULL` before conversion
- Fixed the two-digit-year issue in birth dates (e.g. `65` read as 2065, shifted back 100 years)
- Trimmed leading and trailing spaces in text columns
- Checked for duplicate rows with `ROW_NUMBER()` and repeated applicant emails
- Reviewed categorical columns with `SELECT DISTINCT` for inconsistent values
- Verified one-to-one relationships and orphan records, then added the primary key and foreign keys

## Business Questions Answered
Found in `sql/02_analysis.sql`:

1. What is the attrition rate by department?
2. What are the main termination types?
3. How does tenure differ between leavers and current employees?
4. What are the average engagement and satisfaction scores by department?
5. Do employees who left have lower engagement than those who stayed?
6. How are performance scores distributed?
7. How much is spent on training, by outcome?
8. Which departments have the highest training cost?
9. What does the recruitment funnel look like by application status?
10. Which job titles attract the most applicants?
11. How many people were hired each year?
12. What is the gender split by department?

## SQL Skills Demonstrated
- Data cleaning: `STR_TO_DATE`, `TRIM`, `CASE`, `ALTER TABLE`, `UPDATE`
- Window functions: `ROW_NUMBER() OVER (PARTITION BY ...)`, `SUM() OVER ()`
- Joins, aggregation, `GROUP BY` / `HAVING`
- Views, primary and foreign keys, data integrity checks

## How to Run
1. Create a database named `employee_project` in MySQL.
2. Import the four files from `data/raw/` as tables with these names: `employee_data`, `employee_engagement_survey_data`, `training_and_development_data`, `recruitment_data` (import all columns as text).
3. Run `sql/01_data_cleaning.sql` **once**. The date conversions overwrite the original values, so running them twice will turn dates into `NULL`.
4. Run `sql/02_analysis.sql`.

**Requirements:** MySQL 8.0 or later (window functions).

## Key Findings
> Run `02_analysis.sql` and replace this note with 3–5 findings using your real numbers, for example:
> - Which department has the highest attrition rate, and what is it?
> - Do leavers score lower on engagement than current employees?
> - Which termination type is most common?

## Tools
MySQL 8 · MySQL Workbench · Excel

## Author
**Roshna Assi**
[GitHub](https://github.com/RoshnaAssi21)
