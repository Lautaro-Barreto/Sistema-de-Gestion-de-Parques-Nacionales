-- =============================================
-- Create database template
-- =============================================
USE master
GO

-- Drop the database if it already exists
IF  EXISTS (SELECT name FROM sys.databases WHERE name = 'SGParquesNacionales')
BEGIN
	-- Forzar modo SINGLE_USER y cerrar todas las conexiones
	print('altering database to single user');
	ALTER DATABASE SGParquesNacionales
	SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	-- Eliminar la base
	print('deleting database');
	DROP DATABASE SGParquesNacionales;
	print('deleted database');
	CREATE DATABASE SGParquesNacionales;
	print('created database SGParquesNacionales')
END
GO

