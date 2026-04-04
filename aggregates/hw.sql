-- Вивести кількість викладачів кафедри «Software Development».
select count(t.Id) from Departments d
join Groups g on d.Id = g.DepartmentId
join GroupsTeachers gt on g.Id = gt.GroupId
join Teachers t on gt.TeacherId = t.Id
where d.Name='Software Development';

-- Вивести кількість лекцій, які читає викладач «Dave McQueen».
select count(distinct l.Id) from Lectures l
join Teachers t on l.TeacherId = t.Id
where t.Name = 'Dave McQueen';

-- Вивести кількість занять, які проводяться в аудиторії «D201».
select count(SubjectId) from Lectures l
where l.LectureRoom = 'D201'
;
-- Вивести назви аудиторій та кількість лекцій, що проводяться в них.
select l.LectureRoom, count(SubjectId) from Lectures l
group by l.LectureRoom;
-- Вивести кількість студентів, які відвідують лекції викладача «Jack Underhill».
select count(s.Id) from GroupsTeachers gt
join Studetns s on s.grouping_id() = gt.GroupId
where gt.TeacherId = (select Id from Teachers where Name = 'Jack Underhill');
-- Вивести середню ставку викладачів факультету «Computer Science».
select t.Name,avg(t.Salary) from Departments d
join Groups g on d.Id = g.DepartmentId
join GroupsTeachers gt on g.Id = gt.GroupId
join Teachers t on gt.TeacherId = t.Id
where d.Name='Software Development'
group by t.Name;
-- Вивести мінімальну та максимальну кількість студентів серед усіх груп.
select t.GroupId, min(countteacher),max(countteacher) from (
select GroupId, count(TeacherId) countTeacher from GroupsTeachers
group by GroupId) t
group by t.GroupId
;
-- Вивести середній фонд фінансування кафедр.
select d.Id, avg(f.Financing) from Departments d
join Faculties f on d.FacultyId = f.Id
group by d.Id

-- Вивести повні імена викладачів та кількість читаних ними дисциплін.
select t.Name, count(distinct l.SubjectId) from Lectures l
join Teachers t on l.TeacherId = t.Id
group by t.Name;
-- Вивести кількість лекцій щодня протягом тижня.
select gl.DayOfWeek, count(gl.LectureId) from GroupsLectures gl
group by gl.DayOfWeek;

