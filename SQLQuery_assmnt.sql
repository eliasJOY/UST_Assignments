declare @variable varchar(123)= 'HREmployeeDB';
if not exists(select 1 from sys.databases where name = @variable)
begin
	declare @SQL nvarchar(max) = 'create database' + quotename(@variable)
	exec sp_executesql @SQL
end

use HREmployeeDB;
CREATE TABLE [dbo].EmployeeData (
    Attrition VARCHAR(20) NOT NULL,
    BusinessTravel VARCHAR(26) NOT NULL,
    CF_age_band VARCHAR(20) NOT NULL,
    CF_attrition_label VARCHAR(35) NOT NULL,
    Department VARCHAR(50) NOT NULL,
    EducationField VARCHAR(50) NOT NULL,
    emp_no VARCHAR(20) PRIMARY KEY,
    EmployeeNumber INT NOT NULL,
    Gender VARCHAR(6) NOT NULL,
    JobRole VARCHAR(50) NOT NULL,
    MaritalStatus VARCHAR(10) NOT NULL,
    OverTime VARCHAR(3) NOT NULL,
    Over18 VARCHAR(3) NOT NULL,
    TrainingTimesLastYear INT NOT NULL,
    Age INT NOT NULL,
    CF_current VARCHAR(3) NOT NULL,
    DailyRate INT NOT NULL,
    DistanceFromHome INT NOT NULL,
    Education VARCHAR(20) NOT NULL,
    EmployeeCount INT NOT NULL,
    EnvironmentSatisfaction INT NOT NULL,
    HourlyRate INT NOT NULL,
    JobInvolvement INT NOT NULL,
    JobLevel INT NOT NULL,
    JobSatisfaction INT NOT NULL,
    MonthlyIncome INT NOT NULL,
    MonthlyRate INT NOT NULL,
    NumCompaniesWorked INT NOT NULL,
    PercentSalaryHike INT NOT NULL,
    PerformanceRating INT NOT NULL,
    RelationshipSatisfaction INT NOT NULL,
    StandardHours INT NOT NULL,
    StockOptionLevel INT NOT NULL,
    TotalWorkingYears INT NOT NULL,
    WorkLifeBalance INT NOT NULL,
    YearsAtCompany INT NOT NULL,
    YearsInCurrentRole INT NOT NULL,
    YearsSinceLastPromotion INT NOT NULL,
    YearsWithCurrentManager INT NOT NULL
);



bulk insert EmployeeData
from 'C:/Users/Administrator/Downloads/HR_Employee.csv'
with 
(
	fieldterminator = ',',
	rowterminator = '0x0a',
	firstrow = 2   --skips header for 2 lines 
)

select* from EmployeeData;

--a) Return the shape of the table

select COUNT(*) as Row_Count from EmployeeData;
select COUNT(*) as  Col_Count from INFORMATION_SCHEMA.COLUMNS 
where TABLE_NAME = 'EmployeeData';

--b) Calculate the cumulative sum of total working years for each department

select Department,TotalWorkingYears,
sum(TotalWorkingYears) over (partition by Department order by TotalWorkingYears rows 
between unbounded preceding and current row) as Running_Sum
from EmployeeData;

--c) Which gender have higher strength as workforce in each department
with genCount as 
(select Department,Gender,COUNT(*) as EmpCount
from EmployeeData
group by Department,Gender) 
select distinct Department,MAX(EmpCount) as Employee_count
from genCount
group by Department;