-- Вивести назви аудиторій, де читає лекції викладач «Edward Hopper».
SELECT DISTINCT lr.Name
FROM Teachers t
JOIN Lectures l ON l.TeacherId = t.Id
JOIN Schedules s ON s.LectureId = l.Id
JOIN LectureRooms lr ON lr.Id = s.LectureRoomId
WHERE t.Name = 'Edward'
  AND t.Surname = 'Hopper';
-- Вивести прізвища асистентів, які читають лекції у групі «F505».
SELECT DISTINCT t.Surname
FROM Assistants a
JOIN Teachers t ON t.Id = a.TeacherId
JOIN Lectures l ON l.TeacherId = t.Id
JOIN GroupsLectures gl ON gl.LectureId = l.Id
JOIN Groups g ON g.Id = gl.GroupId
WHERE g.Name = 'F505';
-- Вивести дисципліни, які читає викладач «Alex Carmack» для груп 5 курсу.
SELECT DISTINCT s.Name
FROM Teachers t
JOIN Lectures l ON l.TeacherId = t.Id
JOIN Subjects s ON s.Id = l.SubjectId
JOIN GroupsLectures gl ON gl.LectureId = l.Id
JOIN Groups g ON g.Id = gl.GroupId
WHERE t.Name = 'Alex'
  AND t.Surname = 'Carmack'
  AND g.Year = 5;
-- Вивести прізвища викладачів, які не читають лекції у понеділок.
SELECT t.Surname
FROM Teachers t
WHERE t.Id NOT IN (
    SELECT DISTINCT l.TeacherId
    FROM Lectures l
    JOIN Schedules s ON s.LectureId = l.Id
    WHERE s.DayOfWeek = 1
);
-- Вивести назви аудиторій, із зазначенням їх корпусів, у яких немає лекцій у середу другого тижня на третій парі.
SELECT lr.Name, lr.Building
FROM LectureRooms lr
WHERE NOT EXISTS (
    SELECT 1
    FROM Schedules s
    WHERE s.LectureRoomId = lr.Id
      AND s.DayOfWeek = 3
      AND s.Week = 2
      AND s.Class = 3
);
-- Вивести повні імена викладачів факультету «Computer Science», які не курирують групи кафедри «Software Development».
SELECT DISTINCT t.Name + ' ' + t.Surname AS FullName
FROM Teachers t
JOIN Deans d ON d.TeacherId = t.Id
JOIN Faculties f ON f.DeanId = d.Id
WHERE f.Name = 'Computer Science'
  AND t.Id NOT IN (
      SELECT t2.Id
      FROM Teachers t2
      JOIN Curators c ON c.TeacherId = t2.Id
      JOIN GroupsCurators gc ON gc.CuratorId = c.Id
      JOIN Groups g ON g.Id = gc.GroupId
      JOIN Departments dep ON dep.Id = g.DepartmentId
      WHERE dep.Name = 'Software Development'
  );
-- Вивести список номерів усіх корпусів, які є у таблицях факультетів, кафедр та аудиторій.
SELECT Building FROM Faculties
UNION
SELECT Building FROM Departments
UNION
SELECT Building FROM LectureRooms;
-- Вивести повні імена викладачів у такому порядку: декани факультетів, завідувачі кафедр, викладачі, куратори, асистенти.
SELECT t.Name + ' ' + t.Surname AS FullName, 1 AS SortOrder
FROM Teachers t
JOIN Deans d ON d.TeacherId = t.Id

UNION ALL

SELECT t.Name + ' ' + t.Surname, 2
FROM Teachers t
JOIN Heads h ON h.TeacherId = t.Id

UNION ALL

SELECT t.Name + ' ' + t.Surname, 3
FROM Teachers t

UNION ALL

SELECT t.Name + ' ' + t.Surname, 4
FROM Teachers t
JOIN Curators c ON c.TeacherId = t.Id

UNION ALL

SELECT t.Name + ' ' + t.Surname, 5
FROM Teachers t
JOIN Assistants a ON a.TeacherId = t.Id

ORDER BY SortOrder;
-- Вивести дні тижня (без повторень), в які є заняття в аудиторіях «A311» та «A104» корпусу 6.
SELECT DISTINCT s.DayOfWeek
FROM Schedules s
JOIN LectureRooms lr ON lr.Id = s.LectureRoomId
WHERE lr.Building = 6
  AND lr.Name IN ('A311', 'A104');