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
		IdRegion integer identity(1,1) primary key,
		Nombre varchar(80)
	)
END
GO

--3. Creación de la tabla "Provincia"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Area_Infraestructura' AND TABLE_NAME='Provincia')
BEGIN 
	CREATE TABLE Area_Infraestructura.Provincia (
		IdProvincia integer identity(1,1) primary key,
		IdRegion integer,
		Nombre varchar(80),
		CONSTRAINT Fk_Provincia_De_Region FOREIGN KEY (IdRegion) REFERENCES Area_Infraestructura.Region(IdRegion)
	)
END
GO

--4.Creación de la tabla "Tipo_Parque"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Area_Infraestructura' AND TABLE_NAME='Tipo_Parque')
BEGIN 
	CREATE TABLE Area_Infraestructura.Tipo_Parque (
		IdTipoParque integer identity(1,1) primary key,
		Descripcion varchar(50)
	)
END
GO

--5. Creación de la tabla "Parque"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Area_Infraestructura' AND TABLE_NAME='Parque')
BEGIN 
	CREATE TABLE Area_Infraestructura.Parque (
		IdParque integer primary key,
		IdProvincia integer,
		IdTipoParque integer,
		Nombre varchar(80),
		Superficie decimal(14,4),
		CONSTRAINT Fk_Parque_Provincia FOREIGN KEY (IdProvincia) REFERENCES Area_Infraestructura.Provincia(IdProvincia),
		CONSTRAINT Fk_Parque_TipoParque FOREIGN KEY (IdTipoParque) REFERENCES Area_Infraestructura.Tipo_Parque(IdTipoParque)
	)
END
GO


--6. Creación de la tabla "Guardaparque"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Area_Infraestructura' AND TABLE_NAME='Guardaparque')
BEGIN 
	CREATE TABLE Area_Infraestructura.Guardaparque (
		IdGuardaparque integer primary key,
		IdParque integer,
		Dni char(8),
		Nombre varchar(30),
		Apellido varchar(30),
		Fecha_Ingreso date,
		Fecha_Egreso date,
		Activo bit,
		CONSTRAINT Fk_Guardaparque_Parque FOREIGN KEY (IdParque) REFERENCES Area_Infraestructura.Parque(IdParque)
	)
END
GO


--7. Creación de la tabla "Historial_Trabajo_Guardaparque"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Area_Infraestructura' AND TABLE_NAME='Historial_Trabajo_Guardaparque')
BEGIN 
	CREATE TABLE Area_Infraestructura.Historial_Trabajo_Guardaparque (
		IdHistorial integer,
		IdParque integer,
		IdGuardaparque integer,
		Fecha_Inicio DATE,
		Fecha_Fin DATE,
		Motivo_Egreso varchar(80),
		CONSTRAINT Pk_Guardaparque_Historial PRIMARY KEY (IdHistorial, IdGuardaparque)
	)
END
GO
