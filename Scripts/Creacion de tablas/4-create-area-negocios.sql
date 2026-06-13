-- =============================================
--             ÁREA DE NEGOCIOS
-- =============================================
/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del esquema "Parques" y de las
tablas asociadas a la lógica del mismo. 
*/

GO
USE SGParquesNacionales
GO

/*
DROP TABLE IF EXISTS Area_Negocios.EstadoCanon
DROP TABLE IF EXISTS Area_Negocios.Pago_Canon
DROP TABLE IF EXISTS Area_Negocios.Tipo_Actividad_Concesion
DROP TABLE IF EXISTS Area_Negocios.Empresa_Concesionaria


*/

--1. Creación del esquema "Área_Negocios"
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Area_Negocios')
BEGIN
    EXEC('CREATE SCHEMA Area_Negocios')
END
GO

--2. Creación de la tabla "Estado_Canon"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Area_Negocios' AND TABLE_NAME = 'Estado_Canon')
BEGIN
    CREATE TABLE Area_Negocios.Estado_Canon(
        IdEstadoCanon integer identity(1,1) primary key,
        Descripcion varchar(100)
    )
END
GO

--3. Creación de la tabla "Tipo_Actividad_Concesion"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Area_Negocios' AND TABLE_NAME = 'Tipo_Actividad_Concesion')
BEGIN
    CREATE TABLE Area_Negocios.Tipo_Actividad_Concesion(
        IdTipoActividadConcesion INT identity(1,1) primary key,
        Descripcion varchar(100)
    )
END
GO

--4. Creación de la tabla "Empresa_Concesionaria"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Area_Negocios' AND TABLE_NAME = 'Empresa_Concesionaria')
BEGIN
    CREATE TABLE Area_Negocios.Empresa_Concesionaria(
        IdEmpresa integer identity(1,1) primary key,
        Nombre varchar(80),
        Estado BIT
    )
END
GO

--5. Creación de la tabla "Concesion"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Area_Negocios' AND TABLE_NAME = 'Concesion')
BEGIN
    CREATE TABLE Area_Negocios.Concesion(
        IdConcesion integer identity(1,1) primary key,
        IdTipoActividadConcesion integer,
        IdEmpresa integer,
        IdParque integer,
        Fecha_Inicio date,
        Fecha_Fin date,
        CONSTRAINT Fk_Concesion_Tipo_Actividad FOREIGN KEY (IdTipoActividadConcesion) REFERENCES Area_Negocios.Tipo_Actividad_Concesion(IdTipoActividadConcesion),
        CONSTRAINT Fk_Concesion_Empresa FOREIGN KEY (IdEmpresa) REFERENCES Area_Negocios.Empresa_Concesionaria(IdEmpresa),
        CONSTRAINT Fk_Concesion_Parque FOREIGN KEY (IdParque) REFERENCES Area_Infraestructura.Parque(IdParque)
    )
END
GO

--6. Creación de la tabla "Canon"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Area_Negocios' AND TABLE_NAME = 'Canon')
BEGIN
    CREATE TABLE Area_Negocios.Canon(
        IdCanon INT IDENTITY(1,1) PRIMARY KEY,
        IdConcesion INT,
        IdEstado INT,
        Monto_Mensual DECIMAL(13,3),
        Fecha_Vencimiento DATE,
        CONSTRAINT Fk_Canon_Estado_Canon FOREIGN KEY (IdEstado) REFERENCES Area_Negocios.Estado_Canon(IdEstadoCanon),
        CONSTRAINT Fk_Canon_Concesion FOREIGN KEY (IdConcesion) REFERENCES Area_Negocios.Concesion(IdConcesion)
        --FOREIGN KEY (IdConcesion) REFERENCES Area_Negocios.Concesion(IdConcesion)
    )
END
GO

--7. Creación de la tabla "Pago_Canon"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Area_Negocios' AND TABLE_NAME = 'Pago_Canon')
BEGIN
    CREATE TABLE Area_Negocios.Pago_Canon(
        IdPagoCanon INT IDENTITY(1,1) PRIMARY KEY,
        IdCanon INT,
        Monto_Abonado DECIMAL(13,3),
        Fecha_Pago DATE,

        FOREIGN KEY (IdCanon) REFERENCES Area_Negocios.Canon(IdCanon),
    )
END
GO