ALTER TABLE Teachers 
ADD Position nvarchar(20);

-- Вивести таблицю кафедр, але розташувати її поля у зворотному порядку.
select FacultyId,Name,Financing,Id from Departments;

-- Вивести назви груп та їх рейтинги, використовуючи, як назви полів, що виводяться, «Group Name» та «Group Rating» відповідно.
select Name AS GroupName, Rating AS GroupRating from Groups;

-- Вивести для викладачів їхнє прізвище, відсоток ставки по відношенню до надбавки та відсоток ставки по відношенню до зарплати (сума ставки та надбавки).
select Surname, Premium,Salary, Salary/Premium*100 AS Percentage from Teachers;

-- Вивести таблицю факультетів у вигляді одного поля у такому форматі: «The dean of faculty [faculty] is [dean].».
select 'The name of faculty '+ Id + ' is ' + Name from Faculties;

-- Вивести прізвища викладачів, які є професорами та ставка яких перевищує 1050.
select Surname from Teachers where Premium > 1050 and Position = 'Professor'; 

-- Вивести назви кафедр, фонд фінансування яких менший за 11000 або більше 25000.
select Name, Financing from Departments where Financing < 11000 or Financing > 25000;

-- Вивести назви факультетів, окрім факультету «Computer Science».
select Name from Faculties where Name <> 'Computer Science';

-- Вивести прізвища та посади викладачів, які не є професорами.
select Surname, Position from Teachers WHERE Position <> 'Professor';

-- Вивести прізвища, посади, ставки та надбавки асистентів, у яких надбавка у діа­пазоні від 160 до 550.
select Surname, Position, Premium, Salary from Teachers where Premium BETWEEN 160 AND 500 AND Position='Assistant';

-- Вивести прізвища та ставки асистентів.
select Surname, Salary from Teachers where Position='Assistant';

-- Вивести прізвища та посади викладачів, які були прийняті на роботу до 01.01.2000.
select Surname, Position from Teachers where EmploymentsDate < '2000-01-01';

-- Вивести назви кафедр, які в алфавітному порядку розміщуються до кафедри «Software Development». Поле, що виводиться повинно мати назву «Name of Department».
select Name AS 'Name of Deparment' from Departments order by Name;

-- Вивести прізвища асистентів, які мають зарплату (сума ставки та надбавки) не більше 1200.
select Surname from Teachers where Salary+Premium < 1200 and Position = 'Assistant';

-- Вивести назви груп 5-го курсу, які мають рейтинг у діапазоні від 2 до 4.
select Name from Groups where Rating BETWEEN 2 AND 4 and Year = 5;

-- Вивести прізвища асистентів зі ставкою менше 550 або надбавкою менше 200.
SELECT Surname from Teachers where (Salary < 550 or Premium < 200) and Position = 'Assistant';