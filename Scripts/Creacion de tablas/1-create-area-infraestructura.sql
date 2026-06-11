-- =============================================
--      		ÁREA DE INFRAESTRUCTURA
-- =============================================
/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del esquema "Parques" y de las
tablas asociadas a la lógica del mismo. 
*/

USE SGParquesNacionales
GO


--1. Creación del  esquema "Parques"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Area_Infraestructura') 
BEGIN
	EXEC('CREATE SCHEMA Area_Infraestructura')
END
GO


--2. Creación de la tabla "Region"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Area_Infraestructura' AND TABLE_NAME='Region')
BEGIN 
	CREATE TABLE Area_Infraestructura.Region (
		IdRegion INT IDENTITY(1,1) primary key,
		Nombre VARCHAR(80)
	)
END
GO

--3. Creación de la tabla "Provincia"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Area_Infraestructura' AND TABLE_NAME='Provincia')
BEGIN 
	CREATE TABLE Area_Infraestructura.Provincia (
		IdProvincia INT IDENTITY(1,1) primary key,
		IdRegion INT,
		Nombre VARCHAR(80),
		CONSTRAINT Fk_Provincia_De_Region FOREIGN KEY (IdRegion) REFERENCES Area_Infraestructura.Region(IdRegion)
	)
END
GO

--4.Creación de la tabla "Tipo_Parque"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Area_Infraestructura' AND TABLE_NAME='Tipo_Parque')
BEGIN 
	CREATE TABLE Area_Infraestructura.Tipo_Parque (
		IdTipoParque INT IDENTITY(1,1) primary key,
		Descripcion VARCHAR(50)
	)
END
GO

--5. Creación de la tabla "Parque"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Area_Infraestructura' AND TABLE_NAME='Parque')
BEGIN 
	CREATE TABLE Area_Infraestructura.Parque (
		IdParque INT IDENTITY(1,1) primary key,
		IdProvincia INT,
		IdTipoParque INT,
		Nombre VARCHAR(80),
		Superficie DECIMAL(14,4),
		CONSTRAINT Fk_Parque_Provincia FOREIGN KEY (IdProvincia) REFERENCES Area_Infraestructura.Provincia(IdProvincia),
		CONSTRAINT Fk_Parque_TipoParque FOREIGN KEY (IdTipoParque) REFERENCES Area_Infraestructura.Tipo_Parque(IdTipoParque)
	)
END
GO


--6. Creación de la tabla "Guardaparque"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Area_Infraestructura' AND TABLE_NAME='Guardaparque')
BEGIN 
	CREATE TABLE Area_Infraestructura.Guardaparque (
		IdGuardaparque INT IDENTITY(1,1) primary key,
		IdParque INT,
		Dni CHAR(8),
		Nombre VARCHAR(30),
		Apellido VARCHAR(30),
		Fecha_Ingreso DATE,
		Fecha_Egreso DATE,
		Activo BIT,
		CONSTRAINT Fk_Guardaparque_Parque FOREIGN KEY (IdParque) REFERENCES Area_Infraestructura.Parque(IdParque)
	)
END
GO

--7. Creación de la tabla "Historial_Trabajo_Guardaparque"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Area_Infraestructura' AND TABLE_NAME='Historial_Trabajo_Guardaparque')
BEGIN 
	CREATE TABLE Area_Infraestructura.Historial_Trabajo_Guardaparque (
		IdHistorial INT IDENTITY(1,1),
		IdParque INT,
		IdGuardaparque INT,
		Fecha_Inicio DATE,
		Fecha_Fin DATE,
		Motivo_Egreso VARCHAR(80),
		CONSTRAINT Pk_Guardaparque_Historial PRIMARY KEY (IdHistorial, IdGuardaparque),
		CONSTRAINT Fk_Historial_Trabajo_Guardaparque_Parque FOREIGN KEY (IdParque) REFERENCES Area_Infraestructura.Parque(IdParque),
		CONSTRAINT Fk_Historial_Trabajo_Guardaparque_Guardaparque FOREIGN KEY (IdGuardaparque) REFERENCES Area_Infraestructura.Guardaparque(IdGuardaparque)
	)
END
GO
