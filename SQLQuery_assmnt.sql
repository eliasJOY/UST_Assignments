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
select Department,Gender as Gender_Domination,EmpCount as Emp_count
from 
(select Department,Gender,count(*) as EmpCount,
 rank() over (partition by Department order by count(*) desc) as rn
from EmployeeData
group by Department, Gender) as ranked
where rn = 1;

--d) Create a new column AGE_BAND and Show Distribution of Employee's Age band group
--(Below 25, 25-34, 35-44, 45-55. ABOVE 55).

alter table EmployeeData
add AGE_BAND int;

update EmployeeData
set AGE_BAND =(select COUNT(*)
from EmployeeData
where EmployeeData.CF_age_band = EmployeeData.CF_age_band);

select CF_age_band,COUNT(*) as AGE_BAND_COUNT
from EmployeeData
group by CF_age_band;

--e) Compare all marital status of employee and find the most frequent marital status

select top(1) MaritalStatus,COUNT(*) as count_
from EmployeeData
group by MaritalStatus
order by MaritalStatus desc;

--f) Show the Job Role with Highest Attrition Rate (Percentage)	

select top(5) JobRole, 
yes_count * 100/yes_count as Attrition_percent
FROM (
	select JobRole,
	COUNT(case
		when Attrition = 'Yes' then 1
	end) as total_yes,
	COUNT(*) yes_count
	from EmployeeData
	group by JobRole
) jobs
order by Attrition_percent desc;

--g) Show distribution of Employee's Promotion,
--Find the maximum chances of employee getting promoted.
select YearsSinceLastPromotion, COUNT(*) as Promoted_Emp
from EmployeeData
group by YearsSinceLastPromotion
order by Promoted_Emp desc;

select JobRole,PerformanceRating,
avg(YearsInCurrentRole) as avgCurrentRoleYears,avg(YearsAtCompany) as avgWorkYears,
avg(TrainingTimesLastYear) as avgTrainingTime,avg(YearsSinceLastPromotion) as avgGapBetweenPromotions
from EmployeeData
group by JobRole,PerformanceRating
order by avgGapBetweenPromotions asc;

--h already done

--i) Find the rank of employees within each department based on their monthly income
select* from (select emp_no, Department,MonthlyIncome,
DENSE_RANK() over(partition by Department order by MonthlyIncome desc)
as rank_
from EmployeeData) as _
where rank_ <=5;

--j) Calculate the running total of 'Total Working Years' for each employee within each 
--department and age band.
select Department,emp_no,TotalWorkingYears,
SUM(TotalWorkingYears) over (partition by Department
order by TotalWorkingYears rows between unbounded preceding and current row) as running_Work_sum
from EmployeeData
where TotalWorkingYears > 0;

--k) Foreach employee who left, calculate the number of years they worked before leaving and 
--compare it with the average years worked by employees in the same department.

WITH YearsWorked AS (
    SELECT
        emp_no,Department as Department_worked,YearsAtCompany AS YearsWorkedBeforeLeaving
    FROM EmployeeData
    WHERE Attrition = 'Yes'
	
),
AverageYearsByDepartment AS (
    SELECT Department,
        AVG(YearsAtCompany) AS AvgYearsWorked
    FROM EmployeeData
    GROUP BY Department
)
select*
from YearsWorked LEFT JOIN AverageYearsByDepartment
on AverageYearsByDepartment.Department = YearsWorked.Department_worked;


--l) Rank the departments by the average monthly income of employees who have left.
select Department,AvgMonthlyIncome,
RANK() over (order by AvgMonthlyIncome desc)
as income_rank
from
(	select Department,avg(MonthlyIncome) as  AvgMonthlyIncome
	from EmployeeData
	where Attrition = 'Yes'
	group by Department
) as left_emp;


--m) Find the if there is any relation between Attrition Rate and Marital Status of Employee.
select MaritalStatus,Attrition,COUNT(*) as emp_count
from EmployeeData
group by  MaritalStatus,Attrition
order by emp_count desc;

--n) Show the Department with Highest Attrition Rate (Percentage)
select top(5) Department, 
yes_count * 100/yes_count as Attrition_percent
FROM (
	select Department,
	COUNT(case
		when Attrition = 'Yes' then 1
	end) as total_yes,
	COUNT(*) yes_count
	from EmployeeData
	group by Department
) jobs
order by Attrition_percent desc;

-- o) Calculate the moving average of monthly income over the past 3 employees for each job role.

select emp_no,MonthlyIncome,
avg(MonthlyIncome) over (order by MonthlyIncome rows between unbounded preceding and current row) as runningIncome
from EmployeeData;

-- p) Identify employees with outliers in monthly income within each job role. [ Condition : 
--Monthly_Income < Q1 - (Q3 - Q1) * 1.5 OR Monthly_Income > Q3 + (Q3 - Q1) ]
select JobRole, MonthlyIncome
from(
	select JobRole,MonthlyIncome,
	PERCENTILE_CONT(.25) within group (order by MonthlyIncome) over (partition by JobRole)
	as Q1,
	PERCENTILE_CONT(.5) within group(order by MonthlyIncome) over (partition by JobRole) 
	as Q2,
	PERCENTILE_CONT(.75) within group(order by MonthlyIncome) over (partition by JobRole) 
	as Q3
	from EmployeeData
) boxy
where MonthlyIncome < Q1 - ((Q3 - Q1) * 1.5) or MonthlyIncome > Q3 + (1.5 * (Q3 - Q1));

--q) Gender distribution within each job role, show each job role with its gender domination. 
--[Male_Domination or Female_Domination] 

select JobRole,Gender as Gender_Domination,EmpCount as no_count,
case 
	when Gender = 'Male' then 'Male_Domination'
	when Gender = 'Female' then 'Female_Domination'
end as Domination
from
(select JobRole,Gender,count(*) as EmpCount,
 rank() over (partition by JobRole order by count(*) desc) as rn
from EmployeeData
group by JobRole, Gender) as ranked
where rn = 1;

--r) Percent rank of employees based on training times last year
select emp_no,TrainingTimesLastYear,
PERCENT_RANK() over (order by TrainingTimesLastYear ) as percent_
from EmployeeData
order by percent_ desc;

--s) Divide employees into 5 groups based on training times last year [Use NTILE ()]
select emp_no,TrainingTimesLastYear,
ntile(5) over (order by TrainingTimesLastYear)
as training_grp
from EmployeeData;

--t) Categorize employees based on training times last year as - Frequent Trainee, Moderate Trainee, Infrequent Trainee.
select emp_no,TrainingTimesLastYear,
case
	when TrainingTimesLastYear > 4 then 'Frequent Trainee'
	when TrainingTimesLastYear > 2 then 'Moderate Trainee'
	else 'Infrequent Trainee'
end as 'Category'
from EmployeeData
order by TrainingTimesLastYear desc;

--u) Categorize employees as 'High', 'Medium', or 'Low' performers based on their performance 
--rating, using a CASE WHEN statement.

select emp_no,PerformanceRating,
case
	when PerformanceRating > 3 then 'High Performance'
	when PerformanceRating > 1 then 'Medium Performance'
	else 'Low Performance'
end as 'Performance'
from EmployeeData
order by PerformanceRating desc;

--v) Use a CASE WHEN statement to categorize employees into 'Poor', 'Fair', 'Good', or 'Excellent' 
--work-life balance based on their work-life balance score.

select emp_no,WorkLifeBalance,
case
	when WorkLifeBalance > 3 then 'Excellent'
	when WorkLifeBalance > 2 then 'Good'
	when WorkLifeBalance >1 then 'Fair'
	else 'Poor'
end as 'work-life balance'
from EmployeeData
order by WorkLifeBalance desc;

--w) Group employees into 3 groups based on their stock option level using the [NTILE] function.

select emp_no,StockOptionLevel,
ntile(3) over (order by StockOptionLevel)
as Stock_Level
from EmployeeData
order by Stock_Level ;

--x) Find key reasons for Attrition in Company

select JobRole,Department,
AVG(YearsAtCompany) as avgWorkingYears,
AVG(YearsSinceLastPromotion) as avgPromotionGap,
AVG(WorkLifeBalance) as avgWorkLifeRating,
AVG(PercentSalaryHike) as avgSalaryHike,
AVG(MonthlyIncome) as avgIncome,
AVG(EnvironmentSatisfaction) as avgEnviornmentSatisfaction,
AVG(RelationshipSatisfaction) as avgRelationshipSatisfaction,
COUNT(case when Attrition = 'Yes' then 1 end) Attrition_count
from EmployeeData
group by JobRole,Department
order by Attrition_count desc;