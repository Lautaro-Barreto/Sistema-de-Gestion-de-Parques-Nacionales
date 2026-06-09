/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: En este sript se crea la base de datos "SGParquesNacionales"
*/
-- =============================================
-- _Creación de la Base de datos.
-- =============================================

/*
-- Cambiar al contexto master
USE master;
GO

-- Forzar modo SINGLE_USER y cerrar todas las conexiones
ALTER DATABASE SGParquesNacionales
SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

-- Eliminar la base
DROP DATABASE SGParquesNacionales;
GO
*/


IF NOT EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = 'SGParquesNacionales')
BEGIN
	CREATE DATABASE SGParquesNacionales
	COLLATE Latin1_General_CI_AS;
END
GO

USE SGParquesNacionales
GO