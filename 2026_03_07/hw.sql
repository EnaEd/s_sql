--
CREATE TABLE Curators(
Id INT PRIMARY KEY,
Name VARCHAR(255) NOT NULL,
Surname VARCHAR(255) NOT NULL
)
ALTER TABLE Faculties
 ADD Financing MONEY NOT NULL DEFAULT 0

CREATE TABLE GroupsCurators(
Id INT PRIMARY KEY IDENTITY,
GroupId varchar(20) REFERENCES Groups(Id),
CuratorId INT REFERENCES Curators(Id)
)
CREATE TABLE Subjects(
Id INT PRIMARY KEY IDENTITY,
Name VARCHAR(100) NOT NULL UNIQUE CHECK(len(Name)>0),
)

CREATE TABLE Lectures(
Id INT PRIMARY KEY IDENTITY,
LectureRoom varchar(20) not null,
SubjectId INT REFERENCES Subjects(Id),
TeacherId varchar(20) REFERENCES dbo.Teachers(Id),
)

CREATE TABLE GroupsLectures(
Id INT PRIMARY KEY IDENTITY,
GroupId varchar(20) REFERENCES Groups(Id),
LectureId INT REFERENCES Lectures(Id)
)
--
-- Вивести всі можливі пари рядків викладачів та груп.
select GroupId, TeacherId from GroupsTeachers; -- with direct many to many table

select gl.GroupId, L.TeacherId from GroupsLectures gl -- without direct many to many table
JOIN Lectures L ON gl.LectureId = L.Id;

-- Вивести назви факультетів, на яких фонд фінансування кафедр перевищує фонд фінансування факультету.
select F.Name from Faculties F
JOIN Departments D ON F.Id =D.FacultyId
WHERE D.Financing > F.Financing;

-- Вивести прізвища кураторів груп та назви груп, які вони курують.
select C.Name, G.Name from Curators C
JOIN GroupsCurators GC ON C.Id = GC.CuratorId
JOIN Groups G ON GC.GroupId = G.Id;

-- Вивести прізвища викладачів, які читають лекції у групі «P107».
select T.Name from Teachers T
JOIN GroupsTeachers GT ON T.Id = GT.TeacherId
JOIN Groups G ON GT.GroupId = G.Id
where G.Name = 'P107';

-- Вивести прізвища викладачів та назви факультетів, на яких вони читають лекції.
select T.Name AS TeacherName, F.Name AS FacultyName  from Teachers T
JOIN GroupsTeachers GT ON T.Id = GT.TeacherId
JOIN Groups G ON GT.GroupId = G.Id
JOIN Departments D ON G.DepartmentId = D.Id
JOIN Faculties F ON D.FacultyId = F.Id
;
-- Виведіть назви кафедр та назви груп, які до них відносяться.
select D.Name, G.Name from Departments D
JOIN Groups G ON D.Id = G.DepartmentId;

-- Виведіть назви предметів, які викладає викладач «Samantha Adams».
select S.Name from Lectures L
JOIN Subjects S ON L.SubjectId = S.Id
JOIN Teachers T ON L.TeacherId = T.Id 
where T.Name = 'Samantha' AND T.Surname = 'Adams';

-- Виведіть назви кафедр, на яких викладається предмет «Теорія баз даних».
select D.Name from Departments D
JOIN Groups G ON D.Id = G.DepartmentId
join GroupsLectures GL on G.Id = GL.GroupId
join Subjects S ON GL.LectureId = S.Id
where S.Name=N'Теория баз данных';

-- Виведіть назви груп, які належать до факультету «Комп'ютерні науки».
select G.Name from Faculties f
JOIN  Departments D ON f.Id = D.FacultyId
JOIN Groups G ON D.Id = G.DepartmentId
WHERE F.Name='Commputer Science'

-- Виведіть назви груп 5-го курсу, а також назви факультетів, до яких вони відносяться.
select G.Name, f.Name from Faculties f
JOIN  Departments D ON f.Id = D.FacultyId
JOIN Groups G ON D.Id = G.DepartmentId
WHERE G.Year=5

-- Вивести прізвища викладачів та лекції, які вони читають (назви дисциплін та груп),
-- причому вивести лише ті лекції, які читаються в аудиторії «B103».
select  T.Surname, S.Name, G.Name from Lectures L
JOIN Subjects S ON L.SubjectId = S.Id
JOIN Teachers T ON L.TeacherId = T.Id 
JOIN GroupsLectures GL on L.Id = GL.LectureId
JOIN Groups G ON GL.GroupId = G.Id
WHERE L.LectureRoom = 'B103';

