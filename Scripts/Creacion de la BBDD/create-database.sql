-- =============================================
-- Create database template
-- =============================================
USE master
GO

-- Drop the database if it already exists
IF  EXISTS (
	SELECT name 
		FROM sys.databases 
		WHERE name = N'[SGParquesNacionales]'
)
DROP DATABASE [SGParquesNacionales]
GO

CREATE DATABASE [SGParquesNacionales]
GO

