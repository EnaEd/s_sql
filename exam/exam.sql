SET NOCOUNT ON;

/*
    EXAM SCRIPT (MS SQL Server)
    Country <- Authors
    Country <- Shops
    Themes  <- Books
    Authors <- Books
    Books   <- Sales
    Shops   <- Sales
*/

IF DB_ID(N'BookStoreExam') IS NULL
BEGIN
    CREATE DATABASE BookStoreExam;
END;
GO

USE BookStoreExam;
GO

/* -----------------------------
   0) Перестворення об'єктів
------------------------------*/
IF OBJECT_ID(N'dbo.trg_Books_PriceHistory', N'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_Books_PriceHistory;
GO

IF OBJECT_ID(N'dbo.usp_ReportBooksByCountryAndDate', N'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_ReportBooksByCountryAndDate;
GO

IF OBJECT_ID(N'dbo.usp_RegisterBookSale', N'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_RegisterBookSale;
GO

IF OBJECT_ID(N'dbo.ufn_AuthorSalesSummary', N'IF') IS NOT NULL
    DROP FUNCTION dbo.ufn_AuthorSalesSummary;
GO

IF OBJECT_ID(N'dbo.vw_AuthorsRevenueOverN', N'V') IS NOT NULL
    DROP VIEW dbo.vw_AuthorsRevenueOverN;
GO

IF OBJECT_ID(N'dbo.ShopAuthors', N'U') IS NOT NULL
    DROP TABLE dbo.ShopAuthors;

IF OBJECT_ID(N'dbo.BooksPriceHistory', N'U') IS NOT NULL
    DROP TABLE dbo.BooksPriceHistory;

IF OBJECT_ID(N'dbo.Sales', N'U') IS NOT NULL
    DROP TABLE dbo.Sales;

IF OBJECT_ID(N'dbo.Books', N'U') IS NOT NULL
    DROP TABLE dbo.Books;

IF OBJECT_ID(N'dbo.Shops', N'U') IS NOT NULL
    DROP TABLE dbo.Shops;

IF OBJECT_ID(N'dbo.Authors', N'U') IS NOT NULL
    DROP TABLE dbo.Authors;

IF OBJECT_ID(N'dbo.Themes', N'U') IS NOT NULL
    DROP TABLE dbo.Themes;

IF OBJECT_ID(N'dbo.Country', N'U') IS NOT NULL
    DROP TABLE dbo.Country;
GO

/* -----------------------------
   1) Створення таблиць (як на фото)
------------------------------*/
CREATE TABLE dbo.Country (
    ID_COUNTRY  INT IDENTITY(1,1) PRIMARY KEY,
    NameCountry NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE dbo.Themes (
    ID_THEME   INT IDENTITY(1,1) PRIMARY KEY,
    NameTheme  NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE dbo.Authors (
    ID_AUTHOR   INT IDENTITY(1,1) PRIMARY KEY,
    FirstName   NVARCHAR(100) NOT NULL,
    LastName    NVARCHAR(100) NOT NULL,
    ID_COUNTRY  INT NOT NULL,
    CONSTRAINT FK_Authors_Country
        FOREIGN KEY (ID_COUNTRY) REFERENCES dbo.Country(ID_COUNTRY)
);

CREATE TABLE dbo.Shops (
    ID_SHOP     INT IDENTITY(1,1) PRIMARY KEY,
    NameShop    NVARCHAR(150) NOT NULL,
    ID_COUNTRY  INT NOT NULL,
    CONSTRAINT FK_Shops_Country
        FOREIGN KEY (ID_COUNTRY) REFERENCES dbo.Country(ID_COUNTRY)
);

CREATE TABLE dbo.Books (
    ID_BOOK         INT IDENTITY(1,1) PRIMARY KEY,
    Namebook        NVARCHAR(200) NOT NULL,
    ID_THEME        INT NOT NULL,
    ID_AUTHOR       INT NOT NULL,
    Price           DECIMAL(10,2) NOT NULL CHECK (Price >= 0),
    DrawingOfBook   INT NOT NULL CHECK (DrawingOfBook >= 0), -- залишок/тираж для продажу
    DateOfPublish   DATE NOT NULL,
    Pages           INT NOT NULL CHECK (Pages > 0),
    CONSTRAINT FK_Books_Themes
        FOREIGN KEY (ID_THEME) REFERENCES dbo.Themes(ID_THEME),
    CONSTRAINT FK_Books_Authors
        FOREIGN KEY (ID_AUTHOR) REFERENCES dbo.Authors(ID_AUTHOR)
);

CREATE TABLE dbo.Sales (
    ID_SALE      INT IDENTITY(1,1) PRIMARY KEY,
    ID_BOOK      INT NOT NULL,
    DateOfSale   DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
    Price        DECIMAL(10,2) NOT NULL CHECK (Price >= 0),
    Quantity     INT NOT NULL CHECK (Quantity > 0),
    ID_SHOP      INT NOT NULL,
    CONSTRAINT FK_Sales_Books
        FOREIGN KEY (ID_BOOK) REFERENCES dbo.Books(ID_BOOK),
    CONSTRAINT FK_Sales_Shops
        FOREIGN KEY (ID_SHOP) REFERENCES dbo.Shops(ID_SHOP)
);

/* Додаткові таблиці для завдань */
CREATE TABLE dbo.BooksPriceHistory (
    ID_HISTORY    INT IDENTITY(1,1) PRIMARY KEY,
    BookName      NVARCHAR(200) NOT NULL,
    ChangeDate    DATETIME2(0) NOT NULL,
    OldPrice      DECIMAL(10,2) NOT NULL,
    NewPrice      DECIMAL(10,2) NOT NULL
);

CREATE TABLE dbo.ShopAuthors (
    ID_ROW         INT IDENTITY(1,1) PRIMARY KEY,
    AuthorFullName NVARCHAR(201) NOT NULL,
    ShopName       NVARCHAR(150) NOT NULL,
    CountryName    NVARCHAR(100) NOT NULL
);
GO

/* -----------------------------
   2) Тестові дані
------------------------------*/
INSERT INTO dbo.Country (NameCountry)
VALUES
(N'Україна'),
(N'Польща'),
(N'Німеччина'),
(N'Франція');

INSERT INTO dbo.Themes (NameTheme)
VALUES
(N'SQL'),
(N'Backend'),
(N'Data Science'),
(N'Architecture');

INSERT INTO dbo.Authors (FirstName, LastName, ID_COUNTRY)
VALUES
(N'Іван', N'Коваленко', 1),
(N'Олена', N'Шевченко', 1),
(N'Jan', N'Nowak', 2),
(N'Hans', N'Muller', 3),
(N'Pierre', N'Dupont', 4);

INSERT INTO dbo.Shops (NameShop, ID_COUNTRY)
VALUES
(N'BookHub Kyiv', 1),
(N'BookHub Lviv', 1),
(N'ReadMore Warsaw', 2),
(N'PaperHouse Berlin', 3);

INSERT INTO dbo.Books (Namebook, ID_THEME, ID_AUTHOR, Price, DrawingOfBook, DateOfPublish, Pages)
VALUES
(N'SQL від нуля', 1, 1, 450.00, 500, '2024-03-01', 340),
(N'Advanced T-SQL', 1, 1, 700.00, 300, '2025-01-15', 620),
(N'Backend Patterns', 2, 2, 620.00, 250, '2023-09-10', 510),
(N'Python для аналітики', 3, 3, 550.00, 400, '2025-06-20', 410),
(N'Microservices in Practice', 4, 4, 800.00, 180, '2022-11-05', 780),
(N'Clean Data Pipelines', 3, 5, 680.00, 220, '2025-09-12', 780),
(N'Short SQL Notes', 1, 2, 290.00, 600, '2026-01-10', 120);

INSERT INTO dbo.Sales (ID_BOOK, DateOfSale, Price, Quantity, ID_SHOP)
VALUES
(1, DATEADD(MONTH, -3,  SYSDATETIME()), 450.00, 20, 1),
(1, DATEADD(MONTH, -2,  SYSDATETIME()), 430.00, 12, 2),
(1, DATEADD(MONTH, -1,  SYSDATETIME()), 450.00, 15, 3),
(2, DATEADD(MONTH, -5,  SYSDATETIME()), 700.00, 8,  1),
(2, DATEADD(MONTH, -4,  SYSDATETIME()), 680.00, 7,  2),
(3, DATEADD(MONTH, -8,  SYSDATETIME()), 620.00, 10, 2),
(3, DATEADD(MONTH, -7,  SYSDATETIME()), 620.00, 6,  4),
(4, DATEADD(MONTH, -2,  SYSDATETIME()), 550.00, 9,  3),
(5, DATEADD(MONTH, -14, SYSDATETIME()), 800.00, 5,  4), -- поза останнім роком
(6, DATEADD(MONTH, -1,  SYSDATETIME()), 680.00, 11, 4),
(7, DATEADD(DAY, -10,   SYSDATETIME()), 290.00, 30, 1);
GO

/* -----------------------------
   3) Завдання 1
   Уявлення: автори, чиї продажі за останній рік > N грн.
   N у вью фіксуємо як 10000 (за потреби змініть у HAVING)
------------------------------*/
CREATE VIEW dbo.vw_AuthorsRevenueOverN
AS
SELECT
    a.ID_AUTHOR,
    a.FirstName,
    a.LastName,
    SUM(s.Price * s.Quantity) AS TotalRevenueLastYear
FROM dbo.Authors AS a
JOIN dbo.Books   AS b ON b.ID_AUTHOR = a.ID_AUTHOR
JOIN dbo.Sales   AS s ON s.ID_BOOK   = b.ID_BOOK
WHERE s.DateOfSale >= DATEADD(YEAR, -1, CAST(SYSDATETIME() AS DATE))
GROUP BY a.ID_AUTHOR, a.FirstName, a.LastName
HAVING SUM(s.Price * s.Quantity) > 10000;
GO

/* -----------------------------
   4) Завдання 2
   Заповнення ShopAuthors авторами, книги яких
   продаються більш ніж в одному магазині
------------------------------*/
TRUNCATE TABLE dbo.ShopAuthors;

INSERT INTO dbo.ShopAuthors (AuthorFullName, ShopName, CountryName)
SELECT DISTINCT
    CONCAT(a.FirstName, N' ', a.LastName) AS AuthorFullName,
    sh.NameShop,
    c.NameCountry
FROM dbo.Authors a
JOIN dbo.Books   b  ON b.ID_AUTHOR = a.ID_AUTHOR
JOIN dbo.Sales   s  ON s.ID_BOOK   = b.ID_BOOK
JOIN dbo.Shops   sh ON sh.ID_SHOP  = s.ID_SHOP
JOIN dbo.Country c  ON c.ID_COUNTRY = sh.ID_COUNTRY
WHERE a.ID_AUTHOR IN (
    SELECT b2.ID_AUTHOR
    FROM dbo.Books b2
    JOIN dbo.Sales s2 ON s2.ID_BOOK = b2.ID_BOOK
    GROUP BY b2.ID_AUTHOR
    HAVING COUNT(DISTINCT s2.ID_SHOP) > 1
);
GO

/* -----------------------------
   5) Завдання 3
   Процедура: книги авторів з країни X, видані після дати Y
------------------------------*/
CREATE PROCEDURE dbo.usp_ReportBooksByCountryAndDate
    @CountryName NVARCHAR(100),
    @AfterDate   DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF @AfterDate > CAST(SYSDATETIME() AS DATE)
    BEGIN
        THROW 51001, N'Помилка: вказана дата більша за поточну.', 1;
    END;

    SELECT
        b.ID_BOOK,
        b.Namebook,
        b.DateOfPublish,
        b.Pages,
        b.Price,
        a.FirstName,
        a.LastName,
        c.NameCountry
    FROM dbo.Books b
    JOIN dbo.Authors a ON a.ID_AUTHOR = b.ID_AUTHOR
    JOIN dbo.Country c ON c.ID_COUNTRY = a.ID_COUNTRY
    WHERE c.NameCountry = @CountryName
      AND b.DateOfPublish > @AfterDate
    ORDER BY b.DateOfPublish, b.Namebook;
END;
GO

/* -----------------------------
   6) Завдання 4
   Функція: ПІБ + сумарна кількість проданих книг автора
------------------------------*/
CREATE FUNCTION dbo.ufn_AuthorSalesSummary
(
    @FirstName NVARCHAR(100),
    @LastName  NVARCHAR(100)
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        CONCAT(a.FirstName, N' ', a.LastName) AS AuthorFullName,
        COALESCE(SUM(s.Quantity), 0) AS TotalSoldQuantity
    FROM dbo.Authors a
    LEFT JOIN dbo.Books b ON b.ID_AUTHOR = a.ID_AUTHOR
    LEFT JOIN dbo.Sales s ON s.ID_BOOK = b.ID_BOOK
    WHERE a.FirstName = @FirstName
      AND a.LastName  = @LastName
    GROUP BY a.FirstName, a.LastName
);
GO

/* -----------------------------
   7) Завдання 5
   Процедура реєстрації продажу (транзакція + перевірка залишку)
------------------------------*/
CREATE PROCEDURE dbo.usp_RegisterBookSale
    @BookID      INT,
    @ShopID      INT,
    @SalePrice   DECIMAL(10,2),
    @Quantity    INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @Quantity <= 0
        THROW 51002, N'Помилка: кількість повинна бути більшою за 0.', 1;

    IF @SalePrice < 0
        THROW 51003, N'Помилка: ціна продажу не може бути від''ємною.', 1;

    BEGIN TRAN;

    DECLARE @CurrentStock INT;

    SELECT @CurrentStock = b.DrawingOfBook
    FROM dbo.Books b WITH (UPDLOCK, HOLDLOCK)
    WHERE b.ID_BOOK = @BookID;

    IF @CurrentStock IS NULL
    BEGIN
        ROLLBACK TRAN;
        THROW 51004, N'Помилка: книгу не знайдено.', 1;
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.Shops WHERE ID_SHOP = @ShopID)
    BEGIN
        ROLLBACK TRAN;
        THROW 51005, N'Помилка: магазин не знайдено.', 1;
    END;

    IF @CurrentStock < @Quantity
    BEGIN
        ROLLBACK TRAN;
        THROW 51006, N'Помилка: недостатня кількість екземплярів книги на складі.', 1;
    END;

    UPDATE dbo.Books
    SET DrawingOfBook = DrawingOfBook - @Quantity
    WHERE ID_BOOK = @BookID;

    INSERT INTO dbo.Sales (ID_BOOK, DateOfSale, Price, Quantity, ID_SHOP)
    VALUES (@BookID, SYSDATETIME(), @SalePrice, @Quantity, @ShopID);

    COMMIT TRAN;
END;
GO

/* -----------------------------
   8) Завдання 6
   Тригер для історії зміни ціни книги
------------------------------*/
CREATE TRIGGER dbo.trg_Books_PriceHistory
ON dbo.Books
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.BooksPriceHistory (BookName, ChangeDate, OldPrice, NewPrice)
    SELECT
        i.Namebook,
        SYSDATETIME(),
        d.Price,
        i.Price
    FROM inserted i
    JOIN deleted  d ON d.ID_BOOK = i.ID_BOOK
    WHERE ISNULL(d.Price, -1) <> ISNULL(i.Price, -1);
END;
GO

/* -----------------------------
   9) Завдання 7
   UNION-звіт: автори країн, що написали
   найбільш і найменш об'ємні книги (з урахуванням нічиїх)
------------------------------*/
WITH BooksWithGeo AS
(
    SELECT
        a.FirstName,
        a.LastName,
        c.NameCountry,
        b.Namebook,
        b.Pages
    FROM dbo.Books b
    JOIN dbo.Authors a ON a.ID_AUTHOR = b.ID_AUTHOR
    JOIN dbo.Country c ON c.ID_COUNTRY = a.ID_COUNTRY
),
MaxPages AS
(
    SELECT MAX(Pages) AS MaxP FROM BooksWithGeo
),
MinPages AS
(
    SELECT MIN(Pages) AS MinP FROM BooksWithGeo
)
SELECT
    N'MAX' AS ReportType,
    CONCAT(w.FirstName, N' ', w.LastName) AS AuthorFullName,
    w.NameCountry,
    w.Namebook,
    w.Pages
FROM BooksWithGeo w
CROSS JOIN MaxPages m
WHERE w.Pages = m.MaxP

UNION

SELECT
    N'MIN' AS ReportType,
    CONCAT(w.FirstName, N' ', w.LastName) AS AuthorFullName,
    w.NameCountry,
    w.Namebook,
    w.Pages
FROM BooksWithGeo w
CROSS JOIN MinPages m
WHERE w.Pages = m.MinP
ORDER BY ReportType DESC, AuthorFullName, Namebook;
GO

/* -----------------------------
   Приклади викликів
------------------------------*/
-- SELECT * FROM dbo.vw_AuthorsRevenueOverN;
-- SELECT * FROM dbo.ShopAuthors;
-- EXEC dbo.usp_ReportBooksByCountryAndDate @CountryName = N'Україна', @AfterDate = '2023-01-01';
-- SELECT * FROM dbo.ufn_AuthorSalesSummary(N'Іван', N'Коваленко');
-- EXEC dbo.usp_RegisterBookSale @BookID = 1, @ShopID = 1, @SalePrice = 445.00, @Quantity = 3;
-- UPDATE dbo.Books SET Price = Price + 20 WHERE ID_BOOK = 1;
-- SELECT * FROM dbo.BooksPriceHistory ORDER BY ID_HISTORY DESC;
