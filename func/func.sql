USE academy;
GO
IF OBJECT_ID('dbo.Students', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Students
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Name NVARCHAR(200) NOT NULL,
        Surname NVARCHAR(200) NOT NULL,
        GroupId VARCHAR(20) NOT NULL,
        CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
        UpdatedDate DATETIME NULL,

        CONSTRAINT FK_Students_Groups
            FOREIGN KEY (GroupId) REFERENCES dbo.Groups(Id)
    );
END;
GO

IF OBJECT_ID('dbo.Lecturers', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Lecturers
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Name NVARCHAR(200) NOT NULL,
        Surname NVARCHAR(200) NULL,
        DepartmentId VARCHAR(20) NOT NULL,

        CONSTRAINT FK_Lecturers_Departments
            FOREIGN KEY (DepartmentId) REFERENCES dbo.Departments(Id)
    );
END;
GO

--1
CREATE OR ALTER FUNCTION dbo.GetUniqueStudentsCount()
RETURNS INT
AS
BEGIN
    DECLARE @Result INT;

    SELECT @Result = COUNT(DISTINCT Id)
    FROM dbo.Students;

    RETURN ISNULL(@Result, 0);
END;
GO

--2
CREATE OR ALTER FUNCTION dbo.GetAverageStudentsCountByFaculty
(
    @FacultyName NVARCHAR(200)
)
RETURNS FLOAT
AS
BEGIN
    DECLARE @Result FLOAT;

    SELECT @Result = AVG(CAST(GroupStudents.StudentCount AS FLOAT))
    FROM
    (
        SELECT 
            g.Id AS GroupId,
            COUNT(s.Id) AS StudentCount
        FROM dbo.Groups AS g
        INNER JOIN dbo.Departments AS d
            ON g.DepartmentId = d.Id
        INNER JOIN dbo.Faculties AS f
            ON d.FacultyId = f.Id
        LEFT JOIN dbo.Students AS s
            ON s.GroupId = g.Id
        WHERE f.Name = @FacultyName
        GROUP BY g.Id
    ) AS GroupStudents;

    RETURN ISNULL(@Result, 0);
END;
GO
--3
CREATE OR ALTER FUNCTION dbo.GetAverageStudentsCountByDepartments()
RETURNS TABLE
AS
RETURN
(
    SELECT
        d.Name AS DepartmentName,
        COUNT(s.Id) AS TotalStudentsCount,
        CAST(COUNT(s.Id) AS FLOAT) / NULLIF(COUNT(DISTINCT g.Id), 0) AS AverageStudentsPerGroup
    FROM dbo.Departments AS d
    LEFT JOIN dbo.Groups AS g
        ON g.DepartmentId = d.Id
    LEFT JOIN dbo.Students AS s
        ON s.GroupId = g.Id
    GROUP BY 
        d.Id,
        d.Name
);
GO

--4

CREATE OR ALTER FUNCTION dbo.GetLastAddedStudent()
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 1
        s.Id,
        s.Name,
        s.Surname,
        g.Name AS GroupName,
        f.Name AS FacultyName
    FROM dbo.Students AS s
    INNER JOIN dbo.Groups AS g
        ON s.GroupId = g.Id
    INNER JOIN dbo.Departments AS d
        ON g.DepartmentId = d.Id
    INNER JOIN dbo.Faculties AS f
        ON d.FacultyId = f.Id
    ORDER BY s.Id DESC
);
GO
--5

CREATE OR ALTER FUNCTION dbo.GetFirstAddedStudent()
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 1
        s.Id,
        s.Name,
        s.Surname,
        g.Name AS GroupName,
        f.Name AS FacultyName
    FROM dbo.Students AS s
    INNER JOIN dbo.Groups AS g
        ON s.GroupId = g.Id
    INNER JOIN dbo.Departments AS d
        ON g.DepartmentId = d.Id
    INNER JOIN dbo.Faculties AS f
        ON d.FacultyId = f.Id
    ORDER BY s.Id ASC
);
GO

--6
CREATE OR ALTER FUNCTION dbo.GetStudentsByFacultyAndDepartment
(
    @FacultyName NVARCHAR(200),
    @DepartmentName NVARCHAR(200)
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        s.Id,
        s.Name,
        s.Surname,
        g.Name AS GroupName,
        d.Name AS DepartmentName,
        f.Name AS FacultyName
    FROM dbo.Students AS s
    INNER JOIN dbo.Groups AS g
        ON s.GroupId = g.Id
    INNER JOIN dbo.Departments AS d
        ON g.DepartmentId = d.Id
    INNER JOIN dbo.Faculties AS f
        ON d.FacultyId = f.Id
    WHERE f.Name = @FacultyName
      AND d.Name = @DepartmentName
);
GO
--7

CREATE OR ALTER FUNCTION dbo.GetStudentsByGroupYear
(
    @Year INT
)
RETURNS @Result TABLE
(
    Id INT,
    Name NVARCHAR(200),
    Surname NVARCHAR(200),
    GroupName NVARCHAR(20),
    GroupYear INT,
    DepartmentName NVARCHAR(200),
    FacultyName NVARCHAR(200)
)
AS
BEGIN
    INSERT INTO @Result
    (
        Id,
        Name,
        Surname,
        GroupName,
        GroupYear,
        DepartmentName,
        FacultyName
    )
    SELECT
        s.Id,
        s.Name,
        s.Surname,
        g.Name AS GroupName,
        g.Year AS GroupYear,
        d.Name AS DepartmentName,
        f.Name AS FacultyName
    FROM dbo.Students AS s
    INNER JOIN dbo.Groups AS g
        ON s.GroupId = g.Id
    INNER JOIN dbo.Departments AS d
        ON g.DepartmentId = d.Id
    INNER JOIN dbo.Faculties AS f
        ON d.FacultyId = f.Id
    WHERE g.Year = @Year;

    RETURN;
END;
GO
--8

CREATE OR ALTER TRIGGER dbo.trg_Students_InsteadOfInsert
ON dbo.Students
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE s
    SET 
        s.Name = i.Name,
        s.Surname = i.Surname,
        s.GroupId = i.GroupId,
        s.UpdatedDate = GETDATE()
    FROM dbo.Students AS s
    INNER JOIN inserted AS i
        ON s.Name = i.Name
       AND s.Surname = i.Surname
       AND s.GroupId = i.GroupId;

    INSERT INTO dbo.Students
    (
        Name,
        Surname,
        GroupId,
        CreatedDate
    )
    SELECT
        i.Name,
        i.Surname,
        i.GroupId,
        GETDATE()
    FROM inserted AS i
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.Students AS s
        WHERE s.Name = i.Name
          AND s.Surname = i.Surname
          AND s.GroupId = i.GroupId
    );
END;
GO

--9

IF OBJECT_ID('dbo.LecturersArchive', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.LecturersArchive
    (
        ArchiveId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Id INT NOT NULL,
        Name NVARCHAR(200) NOT NULL,
        Surname NVARCHAR(200) NULL,
        DepartmentId VARCHAR(20) NOT NULL,
        DeletedDate DATETIME NOT NULL
    );
END;
GO

--10

CREATE OR ALTER TRIGGER dbo.trg_Lecturers_InsteadOfInsert
ON dbo.Lecturers
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM inserted AS i
        WHERE
        (
            SELECT COUNT(*)
            FROM dbo.Lecturers AS l
            WHERE l.DepartmentId = i.DepartmentId
        ) >= 5
    )
    BEGIN
        RAISERROR(N'На цій кафедрі вже працює 5 або більше викладачів. Додавання заборонено.', 16, 1);
        RETURN;
    END;

    INSERT INTO dbo.Lecturers
    (
        Name,
        Surname,
        DepartmentId
    )
    SELECT
        i.Name,
        i.Surname,
        i.DepartmentId
    FROM inserted AS i;
END;
GO

--11
--create folder 
--C:\Backup
BACKUP DATABASE academy
TO DISK = 'C:\Backup\academy.bak'
WITH FORMAT,
     INIT,
     NAME = 'Full Backup of academy';
GO
BACKUP LOG academy
TO DISK = 'C:\Backup\academy_log.trn'
WITH INIT,
     NAME = 'Transaction Log Backup of academy';
GO