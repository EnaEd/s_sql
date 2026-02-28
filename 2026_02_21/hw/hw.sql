--region Crate Tables

--Create tables with relations and sequences
/*
Groups, Departments, Faculties, Teachers
*Relations*
1. 1-n (Faculties, Departments)
1. n-1 (Groups, Departments)
2. n-n (Groups, Teachers)
3. 1-n (Departments, Teachers)
*/

DROP SEQUENCE IF EXISTS Groups_Seq, Departments_Seq, Faculties_Seq, Teachers_Seq;
DROP TABLE IF EXISTS 
Students,GroupsTeachers, Teachers,Groups, Departments, Faculties;

CREATE SEQUENCE  Groups_Seq
START WITH 1
INCREMENT BY 1;

CREATE TABLE Groups(
Id varchar(20) PRIMARY KEY DEFAULT ('G-' + RIGHT('00000000' + CAST(NEXT VALUE FOR Groups_Seq AS VARCHAR(20)),8)),
GroupName NVARCHAR(50) UNIQUE CHECK (GroupName <> ''),
Name NVARCHAR(50) UNIQUE CHECK (Name <> ''), -- as we use sequence no need to set unique constraint. potentially unique index and primary will take more space
Rating int CHECK (Rating >= 0 AND Rating <= 5),
Year int NOT NULL CHECK (Year >= 0 AND Year <= 5)
)

CREATE SEQUENCE Departments_Seq
START WITH 1
INCREMENT BY 1;

CREATE TABLE Departments(
Id varchar(20) PRIMARY KEY DEFAULT ('Dep-' + RIGHT('00000000' + CAST(NEXT VALUE FOR Departments_Seq AS VARCHAR(20)),8)),
Financing money NOT NULL DEFAULT 0 CHECK (Financing >= 0),
Name nvarchar(100) NOT NULL UNIQUE CHECK (Name <> '')-- as we use sequence no need to set unique constraint. potentially unique index and primary will take more space  
)

CREATE SEQUENCE Faculties_Seq
START WITH 1
INCREMENT BY 1;

CREATE TABLE Faculties(
Id varchar(20) PRIMARY KEY DEFAULT ('Fct-' + RIGHT('00000000' + CAST(NEXT VALUE FOR Faculties_Seq AS VARCHAR(20)),8)),
Name nvarchar(100) NOT NULL UNIQUE CHECK (Name <> '')
)

CREATE SEQUENCE Teachers_Seq
START WITH 1
INCREMENT BY 1;

CREATE TABLE Teachers(
Id varchar(20) PRIMARY KEY DEFAULT ('Tch-' + RIGHT('00000000' + CAST(NEXT VALUE FOR Teachers_Seq AS VARCHAR(20)),8)),
EmploymentsDate date NOT NULL CHECK (EmploymentsDate >= '1990-01-01'),
Name nvarchar(max) NOT NULL CHECK (Name <> ''),
Surname nvarchar(max) NOT NULL CHECK (Surname <> ''),
Premium money NOT NULL DEFAULT 0 CHECK (Premium >= 0),
Salary money NOT NULL DEFAULT 0 CHECK (Salary > 0)
)


--Teachers has too wide name and surname need to configure it more carefully
--Find constraint name, need to maintenance between servers
DECLARE @TeacherNameCheck varchar(50) = (SELECT TOP 1 name
FROM sys.check_constraints
WHERE parent_object_id = OBJECT_ID('dbo.Teachers') AND Name LIKE 'CK__Teachers__Name%');
--Name
EXEC('ALTER TABLE dbo.Teachers DROP CONSTRAINT ['+ @TeacherNameCheck + ']');
ALTER TABLE Teachers
ALTER COLUMN Name nvarchar(100) NOT NULL;
ALTER TABLE Teachers
ADD CONSTRAINT CK__Teachers__Name CHECK(LEN(Name) > 0);
--Surname
DECLARE @TeacherSurNameCheck varchar(50) = (SELECT TOP 1 name
FROM sys.check_constraints
WHERE parent_object_id = OBJECT_ID('dbo.Teachers') AND Name LIKE 'CK__Teachers__Surn%');
EXEC('ALTER TABLE dbo.Teachers DROP CONSTRAINT [' + @TeacherSurNameCheck + ']');
ALTER TABLE Teachers
ALTER COLUMN Surname nvarchar(100);
ALTER TABLE Teachers
ADD CONSTRAINT CK__Teachers__Surname CHECK(LEN(Surname) > 0);

--need to add relation between 
--1-n (Faculties, Departments)
ALTER TABLE Departments
ADD FacultyId varchar(20) NOT NULL FOREIGN KEY REFERENCES Faculties(Id) DEFAULT 'Fct-EMPTY'; -- added empty as default due to warning "cannot add non nullable field"

--n-1 (Groups, Departments)
ALTER TABLE Groups
ADD DepartmentId varchar(20) NOT NULL FOREIGN KEY REFERENCES Departments(Id) DEFAULT 'Dep-EMPTY'; -- added empty as default due to warning "cannot add non nullable field"
--n-n (Groups, Teachers)
CREATE TABLE GroupsTeachers(
Id int IDENTITY(1,1) PRIMARY KEY,--no need sequence as Id just for internal use
GroupId varchar(20) NOT NULL FOREIGN KEY REFERENCES Groups(Id),
TeacherId varchar(20) NOT NULL FOREIGN KEY REFERENCES Teachers(Id)
)
--1-n (Departments, Teachers)
ALTER TABLE Teachers
ADD DepartmentId varchar(20) NOT NULL FOREIGN KEY REFERENCES Departments(Id) DEFAULT 'Dep-EMPTY'; -- added empty as default due to warning "cannot add non nullable field"

--Table group has wrongly added column GroupName need to delete it
DECLARE @GroupGroupNameUnique varchar(50) = (SELECT TOP 1
    i.name 
FROM sys.indexes i
JOIN sys.index_columns ic 
    ON i.object_id = ic.object_id AND i.index_id = ic.index_id
JOIN sys.columns c 
    ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE i.object_id = OBJECT_ID('dbo.Groups')
  AND i.name LIKE 'UQ__Groups_%' AND c.name = 'GroupName');
EXEC('ALTER TABLE dbo.Groups DROP CONSTRAINT [' + @GroupGroupNameUnique + ']');

DECLARE @GroupGroupNameCheck varchar(50) = (SELECT TOP 1 name
FROM sys.check_constraints
WHERE parent_object_id = OBJECT_ID('dbo.Groups') AND Name LIKE 'CK__Groups__GroupNam%');
EXEC('ALTER TABLE dbo.Groups DROP CONSTRAINT [' + @GroupGroupNameCheck + ']');


ALTER TABLE Groups
DROP COLUMN GroupName;

--Table group has wrongly config for column Name
DECLARE @GroupNameCheck varchar(50) = (SELECT TOP 1 name
FROM sys.check_constraints
WHERE parent_object_id = OBJECT_ID('dbo.Groups') AND Name LIKE 'CK__Groups__Name%');
EXEC('ALTER TABLE dbo.Groups DROP CONSTRAINT [' + @GroupNameCheck + ']');
DECLARE @GroupNameUnique varchar(50) = (SELECT TOP 1 name
FROM sys.indexes
WHERE object_id = OBJECT_ID('dbo.Groups') AND Name LIKE 'UQ__Groups%');
EXEC('ALTER TABLE dbo.Groups DROP CONSTRAINT [' + @GroupNameUnique + ']');

ALTER TABLE Groups
ALTER COLUMN Name nvarchar(10) NOT NULL;
ALTER TABLE Groups
ADD CONSTRAINT CK__Groups__Name CHECK(LEN(Name) > 0);
ALTER TABLE Groups
ADD CONSTRAINT UQ__Group_Name UNIQUE (Name);

--Table group has wrongly check for column Year
DECLARE @GroupYearCheck varchar(50) = (SELECT TOP 1 name
FROM sys.check_constraints
WHERE parent_object_id = OBJECT_ID('dbo.Groups') AND Name LIKE 'CK__Groups__Year%');
EXEC('ALTER TABLE dbo.Groups DROP CONSTRAINT [' + @GroupYearCheck + ']');
ALTER TABLE Groups
Add CONSTRAINT CK__Groups__Year CHECK(Year > 0 AND Year <= 5);

--endregion

--region Insert Data
INSERT INTO Faculties(Name) VALUES ('IT');

INSERT INTO Departments(Financing, Name, FacultyId) 
VALUES (3, 'IT-1', (SELECT TOP 1 Id FROM Faculties));

INSERT INTO Groups(Name, Rating, Year, DepartmentId) 
VALUES ('Test-1', '1', 1, (SELECT TOP 1 Id FROM Departments));

INSERT INTO Teachers(EmploymentsDate, Name, Surname, Premium, Salary, DepartmentId)
 VALUES ('2020-02-21', 'John', 'Doe', 2, 2, (SELECT TOP 1 Id FROM Departments));
 
INSERT INTO GroupsTeachers(GroupId, TeacherId) 
VALUES ((SELECT TOP 1 Id FROM Groups), (SELECT TOP 1 Id FROM Teachers));

--endregion
