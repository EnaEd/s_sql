-- Вивести номери корпусів, якщо сумарний фонд фінансування розташованих у них кафедр перевищує 100000.
SELECT Building
FROM Departments
GROUP BY Building
HAVING SUM(Financing) > 100000;
-- Вивести назви груп 5-го курсу кафедри «Software Development», які мають понад 10 пар на перший тиждень.
SELECT g.Name
FROM Groups g
JOIN Departments d ON g.DepartmentId = d.Id
JOIN GroupsLectures gl ON gl.GroupId = g.Id
JOIN Lectures l ON l.Id = gl.LectureId
WHERE g.Year = 5
  AND d.Name = 'Software Development'
  AND DATEPART(WEEK, l.Date) = 1
GROUP BY g.Name
HAVING COUNT(*) > 10;
-- Вивести назви груп, які мають рейтинг (середній рейтинг усіх студентів групи) більший, ніж рейтинг групи «D221».
WITH GroupRatings AS (
    SELECT g.Id, g.Name, AVG(s.Rating * 1.0) AS AvgRating
    FROM Groups g
    JOIN GroupsStudents gs ON gs.GroupId = g.Id
    JOIN Students s ON s.Id = gs.StudentId
    GROUP BY g.Id, g.Name
)
SELECT Name
FROM GroupRatings
WHERE AvgRating > (
    SELECT AvgRating
    FROM GroupRatings
    WHERE Name = 'D221'
);
-- Вивести прізвища та імена викладачів, ставка яких вища за середню ставку про­фесорів.
SELECT Surname, Name
FROM Teachers
WHERE Salary > (
    SELECT AVG(Salary)
    FROM Teachers
    WHERE IsProfessor = 1
);
-- Вивести назви груп, які мають більше одного куратора.
SELECT g.Name
FROM Groups g
JOIN GroupsCurators gc ON gc.GroupId = g.Id
GROUP BY g.Name
HAVING COUNT(gc.CuratorId) > 1;
-- Вивести назви груп, які мають рейтинг (середній рейтинг усіх студентів групи) менший, ніж мінімальний рейтинг груп 5-го курсу.
WITH GroupRatings AS (
    SELECT g.Id, g.Name, g.Year, AVG(s.Rating * 1.0) AS AvgRating
    FROM Groups g
    JOIN GroupsStudents gs ON gs.GroupId = g.Id
    JOIN Students s ON s.Id = gs.StudentId
    GROUP BY g.Id, g.Name, g.Year
)
SELECT Name
FROM GroupRatings
WHERE AvgRating < (
    SELECT MIN(AvgRating)
    FROM GroupRatings
    WHERE Year = 5
);
-- Вивести назви факультетів, сумарний фонд фінансування кафедр яких більший за сумарний фонд фінансування кафедр факультету «Сomputer Science».
WITH FacultyFinancing AS (
    SELECT f.Id, f.Name, SUM(d.Financing) AS TotalFin
    FROM Faculties f
    JOIN Departments d ON d.FacultyId = f.Id
    GROUP BY f.Id, f.Name
)
SELECT Name
FROM FacultyFinancing
WHERE TotalFin > (
    SELECT TotalFin
    FROM FacultyFinancing
    WHERE Name = 'Computer Science'
);
-- Вивести назви дисциплін та повні імена викладачів, які читають найбільшу кіль­кість лекцій з них.
WITH LectureCounts AS (
    SELECT 
        s.Id AS SubjectId,
        s.Name AS SubjectName,
        t.Id AS TeacherId,
        t.Name + ' ' + t.Surname AS TeacherName,
        COUNT(*) AS LectureCount
    FROM Lectures l
    JOIN Subjects s ON s.Id = l.SubjectId
    JOIN Teachers t ON t.Id = l.TeacherId
    GROUP BY s.Id, s.Name, t.Id, t.Name, t.Surname
),
MaxLectures AS (
    SELECT SubjectId, MAX(LectureCount) AS MaxCount
    FROM LectureCounts
    GROUP BY SubjectId
)
SELECT lc.SubjectName, lc.TeacherName
FROM LectureCounts lc
JOIN MaxLectures ml 
    ON lc.SubjectId = ml.SubjectId 
   AND lc.LectureCount = ml.MaxCount;
-- Вивести назву дисципліни, за якою читається найменше лекцій.
WITH SubjectCounts AS (
    SELECT s.Name, COUNT(l.Id) AS LectureCount
    FROM Subjects s
    LEFT JOIN Lectures l ON l.SubjectId = s.Id
    GROUP BY s.Name
)
SELECT Name
FROM SubjectCounts
WHERE LectureCount = (
    SELECT MIN(LectureCount) FROM SubjectCounts
);
-- Вивести кількість студентів та дисциплін, що читаються на кафедрі «Software Development».
SELECT 
    COUNT(DISTINCT gs.StudentId) AS StudentsCount,
    COUNT(DISTINCT l.SubjectId) AS SubjectsCount
FROM Departments d
JOIN Groups g ON g.DepartmentId = d.Id
LEFT JOIN GroupsStudents gs ON gs.GroupId = g.Id
LEFT JOIN GroupsLectures gl ON gl.GroupId = g.Id
LEFT JOIN Lectures l ON l.Id = gl.LectureId
WHERE d.Name = 'Software Development';