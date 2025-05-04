IF NOT EXISTS (
    SELECT name FROM sys.databases WHERE name = 'violencia-db'
)
BEGIN
    CREATE DATABASE [violencia-db];
END
