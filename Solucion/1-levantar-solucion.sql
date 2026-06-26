/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: En este sript se levanta la solución completa, creando tanto la base de datos como todos sus objetos
*/

-- =============================================
--			CREACION DE LA BASE DE DATOS
-- =============================================

USE master
go

IF NOT EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = 'SGParquesNacionales')
BEGIN
	CREATE DATABASE SGParquesNacionales
	COLLATE Latin1_General_CI_AS;
END
GO

USE SGParquesNacionales
GO

set nocount on;
go

--Habilitamos las apis

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ole Automation Procedures', 1;
RECONFIGURE;

-- ===========================================================================================
--                      Creación de tablas del área de infraestructura
-- ===========================================================================================

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
        Activo BIT DEFAULT 1,
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
		Activo BIT DEFAULT 1,
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

-- ===========================================================================================
--                          Creación de tablas del Área Comercial
-- ===========================================================================================

--1. Creación del esquema "Area_Comercial"
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Area_Comercial')
BEGIN
    EXEC('CREATE SCHEMA Area_Comercial')
END
GO

--2. Creación de la tabla "Punto_De_Venta"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Area_Comercial' AND TABLE_NAME = 'Punto_De_Venta')
BEGIN
    CREATE TABLE Area_Comercial.Punto_De_Venta(
        IdPuntoDeVenta SMALLINT IDENTITY(1,1) PRIMARY KEY,
        Descripcion VARCHAR(100)
    )
END
GO

--3. Creación de la tabla "Forma_De_Pago"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Area_Comercial' AND TABLE_NAME = 'Forma_De_Pago')
BEGIN
    CREATE TABLE Area_Comercial.Forma_De_Pago(
        IdFormaDePago TINYINT IDENTITY(1,1) PRIMARY KEY,
        Descripcion VARCHAR(100)
    )
END
GO

--4. Creación de la tabla "Venta"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Area_Comercial' AND TABLE_NAME = 'Venta')
BEGIN
    CREATE TABLE Area_Comercial.Venta(
        IdVenta INT IDENTITY(1,1) PRIMARY KEY,
        IdPuntoDeVenta SMALLINT,
        IdParque INT,
        IdFormaDePago TINYINT,
        Fecha DATE,
        Total DECIMAL(38,3),

        FOREIGN KEY (IdPuntoDeVenta) REFERENCES Area_Comercial.Punto_De_Venta(IdPuntoDeVenta),
        FOREIGN KEY (IdParque) REFERENCES Area_Infraestructura.Parque(IdParque),
        FOREIGN KEY (IdFormaDePago) REFERENCES Area_Comercial.Forma_De_Pago(IdFormaDePago)
    )
END
GO

--5. Creación de la tabla "Tipo_Visitante"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Area_Comercial' AND TABLE_NAME = 'Tipo_Visitante')
BEGIN
    CREATE TABLE Area_Comercial.Tipo_Visitante(
        IdTipoVisitante TINYINT IDENTITY(1,1) PRIMARY KEY,
        Descripcion VARCHAR(100)
    )
END
GO

--6. Creación de la tabla "Entrada"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Area_Comercial' AND TABLE_NAME = 'Entrada')
BEGIN
    CREATE TABLE Area_Comercial.Entrada(
        IdEntrada INT IDENTITY(1,1) PRIMARY KEY,
        IdParque INT,
        IdTipoVisitante TINYINT,
        Precio DECIMAL(10,2),
        Fecha_Acceso DATE,

        FOREIGN KEY (IdParque) REFERENCES Area_Infraestructura.Parque(IdParque),
        FOREIGN KEY (IdTipoVisitante) REFERENCES Area_Comercial.Tipo_Visitante(IdTipoVisitante)
    )
END
GO

--7. Creación de la tabla "Detalle_Venta_Entrada"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Area_Comercial' AND TABLE_NAME = 'Detalle_Venta_Entrada')
BEGIN
    CREATE TABLE Area_Comercial.Detalle_Venta_Entrada(
        IdDetalle INT Identity(1,1) PRIMARY KEY,
        IdVenta INT,
        IdEntrada INT,
        Cantidad INT,
        Subtotal DECIMAL(10,2),

        FOREIGN KEY (IdVenta) REFERENCES Area_Comercial.Venta(IdVenta),
        FOREIGN KEY (IdEntrada) REFERENCES Area_Comercial.Entrada(IdEntrada)
    )
END
GO

-- 8. Creación de la tabla "Precio_Parque_Tipo_Visitante"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Area_Comercial' AND TABLE_NAME = 'Precio_Parque_Tipo_Visitante')
BEGIN
    CREATE TABLE Area_Comercial.Precio_Parque_Tipo_Visitante(
        IdPrecioParqueTipoVis SMALLINT IDENTITY(1,1) PRIMARY KEY,
        IdParque INT, 
        IdTipoVisitante TINYINT, 
        Precio DECIMAL(10,2), 

        FOREIGN KEY (IdParque) REFERENCES Area_Infraestructura.Parque(IdParque),
        FOREIGN KEY (IdTipoVisitante) REFERENCES Area_Comercial.Tipo_Visitante(IdTipoVisitante)
    )
END
GO


--9. Creación de la tabla "Descuento_Parque"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Area_Comercial' AND TABLE_NAME = 'Descuento_Parque')
BEGIN
    CREATE TABLE Area_Comercial.Descuento_Parque(
        IdDescuento TINYINT IDENTITY(1,1) PRIMARY KEY,
        IdParque INT,
        Porcentaje DECIMAL(2,2),
        Descripcion VARCHAR(100),

        FOREIGN KEY (IdParque) REFERENCES Area_Infraestructura.Parque(IdParque)
    )
END
GO

--10. Creación de la tabla "Feriado_Nacional"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Area_Comercial' AND TABLE_NAME = 'Feriado_Nacional')
BEGIN
    CREATE TABLE Area_Comercial.Feriado_Nacional(
        IdFeriado TINYINT IDENTITY(1,1) PRIMARY KEY,
        Fecha DATE,
        Tipo VARCHAR(50),
        Descripcion VARCHAR(100)
    )
END

-- ===========================================================================================
--                          Creación de tablas del Área de Excursiones
-- ===========================================================================================

IF NOT EXISTS(SELECT * FROM sys.schemas WHERE name = 'Area_Excursiones')
BEGIN
        EXEC ('CREATE SCHEMA Area_Excursiones')
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE 
TABLE_SCHEMA = 'Area_Excursiones' AND TABLE_NAME = 'Habilitacion')
BEGIN 
        CREATE TABLE Area_Excursiones.Habilitacion(
            IdHabilitaciones INT identity(1,1) PRIMARY KEY,
            Descripcion VARCHAR(50)
        )
END 
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE 
TABLE_SCHEMA = 'Area_Excursiones' AND TABLE_NAME = 'Especialidad')
BEGIN
        CREATE TABLE Area_Excursiones.Especialidad(
            IdEspecialidad INT IDENTITY(1,1) PRIMARY KEY,
            Descripcion VARCHAR(50)
        )
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE 
TABLE_SCHEMA = 'Area_Excursiones' AND TABLE_NAME = 'Tipo_Actividad')
BEGIN 
        CREATE TABLE Area_Excursiones.Tipo_Actividad(
            idTipoActividad INT identity(1,1) PRIMARY KEY,
            Descripcion VARCHAR(50)
        )
END 
GO

IF NOT EXISTS( SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE 
TABLE_SCHEMA = 'Area_Excursiones' AND TABLE_NAME = 'Actividad')
BEGIN 
        CREATE TABLE Area_Excursiones.Actividad(
            IdActividad INT identity(1,1) PRIMARY KEY,
            IdTipoActividad INT NOT NULL,
            IdParque INT NOT NULL,
            Nombre VARCHAR(30),
            Costo DECIMAL(10,2),
            Duracion INT,
            Cupo_maximo INT,
            Activo BIT NOT NULL DEFAULT 1,
            CONSTRAINT FK_Actividad_Tipo FOREIGN KEY (IdTipoActividad) REFERENCES Area_Excursiones.Tipo_Actividad(IdTipoActividad),
            CONSTRAINT FK_Actividad_Parque FOREIGN KEY (IdParque) REFERENCES Area_Infraestructura.Parque(IdParque)
        );
END
GO

IF NOT EXISTS( SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE 
TABLE_SCHEMA = 'Area_Excursiones' AND TABLE_NAME = 'Guia')
BEGIN 
        CREATE TABLE Area_Excursiones.Guia(
            IdGuia INT IDENTITY(1,1),
            DNI char(8) NOT NULL,
            IdParque INT,
            IdEspecialidad INT,

            Nombre varchar(30),
            Apellido VARCHAR(30),
            Titulo VARCHAR(30),

            CONSTRAINT PK_Guia PRIMARY KEY(idGuia),
            CONSTRAINT FK_Guia_Parque FOREIGN KEY(IdParque) REFERENCES Area_Infraestructura.Parque(IdParque),
            CONSTRAINT FK_Guia_Especialidad FOREIGN KEY (IdEspecialidad) REFERENCES Area_Excursiones.Especialidad(IdEspecialidad)
        )
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE 
TABLE_SCHEMA = 'Area_Excursiones' AND TABLE_NAME = 'Contratacion_Actividad')
BEGIN 
        CREATE TABLE Area_Excursiones.Contratacion_Actividad(
            IdContratacion INT identity(1,1) PRIMARY KEY,
            Monto DECIMAL(10,2),
            IdVenta INT,
            IdActividad INT,
            Fecha_Contratacion DATE,
            Activo BIT NOT NULL DEFAULT 1,
            CONSTRAINT FK_Contratacion_Actividad_Venta FOREIGN KEY (idVenta) REFERENCES Area_Comercial.Venta(IdVenta),
            CONSTRAINT FK_Contratacion_Actividad_Actividad FOREIGN KEY (idActividad) REFERENCES Area_Excursiones.Actividad(IdActividad),
        )
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE 
TABLE_SCHEMA = 'Area_Excursiones' AND TABLE_NAME = 'Guias_por_Actividad')
BEGIN 
        CREATE TABLE Area_Excursiones.Guias_por_Actividad(
            IdGuia INT NOT NULL,
            IdActividad INT NOT NULL,

            CONSTRAINT PK_Guia_por_Actividad PRIMARY KEY(idGuia, IdActividad),
            CONSTRAINT FK_Guia_por_Actividad_Guia FOREIGN KEY (idGuia) REFERENCES Area_Excursiones.Guia(IdGuia),
            CONSTRAINT FK_Guia_por_Actividad_Actividad FOREIGN KEY (IdActividad) REFERENCES Area_Excursiones.Actividad(IdActividad)
        )
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE 
TABLE_SCHEMA = 'Area_Excursiones' AND TABLE_NAME = 'Habilitacion_Guia')
BEGIN 
        CREATE TABLE Area_Excursiones.Habilitacion_Guia(
            IdGuia INT NOT NULL,
            IdHabilitacion INT NOT NULL,
            Fecha_Inicio_Validez DATE,
            Fecha_Fin_Validez DATE,
            CONSTRAINT PK_Habilitacion_Guia PRIMARY KEY(IdGuia, IdHabilitacion),
            CONSTRAINT FK_Habilitacion_Guia_Guia FOREIGN KEY(IdGuia) REFERENCES Area_Excursiones.Guia(IdGuia),
            CONSTRAINT FK_Habilitacion_Guia_Habilitacion FOREIGN KEY(IdHabilitacion) REFERENCES Area_Excursiones.Habilitacion(IdHabilitaciones)
        )
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'Area_Excursiones' AND TABLE_NAME = 'Habilitaciones_por_Actividad')
BEGIN 
        CREATE TABLE Area_Excursiones.Habilitaciones_por_Actividad(
            IdActividad INT NOT NULL,
            IdHabilitacion INT NOT NULL,
            CONSTRAINT PK_Habilitacion_por_Actividad PRIMARY KEY(IdActividad, IdHabilitacion),
            CONSTRAINT FK_Habilitacion_por_Actividad_Actividad FOREIGN KEY(IdActividad) REFERENCES Area_Excursiones.Actividad(IdActividad),
            CONSTRAINT FK_Habilitacion_por_Actividad_Habilitacion FOREIGN KEY(IdHabilitacion) REFERENCES Area_Excursiones.Habilitacion(IdHabilitaciones)
        )
END
GO


-- ===========================================================================================
--                          Creación de tablas del Área de Negocios
-- ===========================================================================================

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
        Nombre varchar(120),
        Estado BIT DEFAULT 1
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

-----------------------------------------------------------------------
--                  CREACIÓN DE LOS SP DEL AREA COMERCIAL           --
-----------------------------------------------------------------------

-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LOS DESCUENTOS DE PARQUE
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Comercial.Sp_CrearDescuentoParque
    @IdParque INT,
    @Descripcion VARCHAR(100),
    @Porcentaje DECIMAL(2,2)
AS
BEGIN
    BEGIN TRY

        --El parque debe estar cargado en la DB
        IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @IdParque)
        BEGIN
            PRINT('Parque inexistente')
            RAISERROR('.', 16, 1)
        END

        --La descripción no puede ser nula o vacía
		IF @Descripcion ='' OR @Descripcion LIKE '%[^a-zA-Z ]%' OR LEN(@Descripcion) > 100
		BEGIN
			PRINT('La descripción ingresada no es válida')
			RAISERROR('.', 16,1)
		END
		SET @Descripcion = TRIM(@Descripcion)

        --El porcentaje de descuento debe ser mayor a cero
        IF @Porcentaje <= 0
        BEGIN
            PRINT('Porcentaje de descuento no válido')
            RAISERROR('.', 16, 1)
        END
    END TRY

    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
        BEGIN	
            RAISERROR('Algo salió mal en la creación del descuento', 16, 1);
            RETURN;
        END
    END CATCH

    INSERT INTO Area_Comercial.Descuento_Parque(IdParque, Descripcion, Porcentaje) VALUES
    (@IdParque, @Descripcion, @Porcentaje);
END
GO



-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LOS DETALLE DE VENTA DE ENTRADA
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Comercial.SP_CrearDetalleVentaEntrada
	@IdVenta INT,
	@IdEntrada INT,
	@Cantidad INT,
	@Subtotal DECIMAL(13,3)
AS
BEGIN
	BEGIN TRY
		--La venta debe estar cargada en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Venta WHERE IdVenta = @IdVenta)
        BEGIN
            PRINT('Venta inexistente')
            RAISERROR('.', 16, 1)
        END

		--La entrada debe estar cargada en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Entrada WHERE IdEntrada = @IdEntrada)
        BEGIN
            PRINT('Entrada inexistente')
            RAISERROR('.', 16, 1)
        END

		--La cantidad debe ser mayor a cero
		IF @Cantidad <= 0
			BEGIN
				PRINT('La cantidad no es valida')
				RAISERROR('.', 16, 1)
			END

		--El subtotal debe ser mayor a cero
		IF @Subtotal <= 0
			BEGIN
				PRINT('El subtotal no es valido')
				RAISERROR('.', 16, 1)
			END
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en el registro del detalle de venta de entradas', 16, 1);
			RETURN;
		END
	END CATCH

	INSERT INTO Area_Comercial.Detalle_Venta_Entrada(IdVenta, IdEntrada, Cantidad, Subtotal) VALUES
	(@IdVenta, @IdEntrada, @Cantidad, @Subtotal);
END
GO
-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LAS ENTRADAS
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Comercial.SP_CrearEntrada
	@IdParque INT,
	@IdTipoVisitante INT,
	@Precio DECIMAL(13,3),
	@Fecha_Acceso DATE
AS
BEGIN
	BEGIN TRY

		--El parque debe estar cargado en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @IdParque)
        BEGIN
            PRINT('Parque inexistente')
            RAISERROR('.', 16, 1)
        END

		--El tipo de visitante debe estar cargado en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Tipo_Visitante WHERE IdTipoVisitante = @IdTipoVisitante)
        BEGIN
            PRINT('Tipo de visitante inexistente')
            RAISERROR('.', 16, 1)
        END

		--El campo fecha de acceso debe tener un valor
		IF @Fecha_Acceso IS NULL
		BEGIN
            PRINT('La fecha de acceso no puede ser nula')
            RAISERROR('.', 16, 1)
        END

		--El precio debe ser mayor a cero
		IF @Precio <= 0
			BEGIN
				PRINT('El total no es valido')
				RAISERROR('.', 16, 1)
			END
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en el registro de la entrada', 16, 1);
			RETURN;
		END
	END CATCH

	INSERT INTO Area_Comercial.Entrada( IdParque, IdTipoVisitante, Precio, Fecha_Acceso) VALUES
	( @IdParque, @IdTipoVisitante, @Precio, @Fecha_Acceso);
	DECLARE @IdNuevaEntrada INT
	SET @IdNuevaEntrada = SCOPE_IDENTITY()
	RETURN @IdNuevaEntrada
END
GO
-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LAS FORMAS DE PAGO
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Comercial.SP_CrearFormaDePago
	@Descripcion VARCHAR(30)
AS
BEGIN
	BEGIN TRY
		--Se valida la descripcion ingresada
		IF @Descripcion = '' OR @Descripcion LIKE '%[^a-zA-Z ]%' OR LEN(@Descripcion) > 30
		BEGIN
			PRINT('La descripcion ingresada no es valida')
			RAISERROR('.', 16, 1)
		END
		SET @Descripcion = TRIM(@Descripcion)

		--La descripcion es unica
		IF EXISTS (SELECT 1 FROM Area_Comercial.Forma_De_Pago WHERE Descripcion = @Descripcion)
        BEGIN
            PRINT('Ya existe una forma de pago con esa descripcion')
            RAISERROR('.', 16, 1)
        END
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en el registro de la forma de pago', 16, 1);
			RETURN;
		END
	END CATCH

	INSERT INTO Area_Comercial.Forma_De_Pago(Descripcion) VALUES
	(@Descripcion);
	DECLARE @IdNuevaFormaDePago INT
	SET @IdNuevaFormaDePago = SCOPE_IDENTITY()
	RETURN @IdNuevaFormaDePago
END
GO
-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LOS PUNTOS DE VENTA
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Comercial.SP_CrearPuntoDeVenta
	@Descripcion VARCHAR(30)
AS
BEGIN
	BEGIN TRY
		--Se valida la descripcion ingresada
		IF @Descripcion = '' OR @Descripcion LIKE '%[^a-zA-Z ]%' OR LEN(@Descripcion) > 30
		BEGIN
			PRINT('La descripcion ingresada no es valida')
			RAISERROR('.', 16, 1)
		END
		SET @Descripcion = TRIM(@Descripcion)

		--La descripcion es unica
		IF EXISTS (SELECT 1 FROM Area_Comercial.Punto_De_Venta WHERE Descripcion = @Descripcion)
        BEGIN
            PRINT('Ya existe un punto de venta con esa descripcion')
            RAISERROR('.', 16, 1)
        END
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en el registro del punto de venta', 16, 1);
			RETURN;
		END
	END CATCH

	INSERT INTO Area_Comercial.Punto_De_Venta(Descripcion) VALUES
	(@Descripcion);
	DECLARE @IdNuevoPuntoDeVenta INT
	SET @IdNuevoPuntoDeVenta = SCOPE_IDENTITY()
	RETURN @IdNuevoPuntoDeVenta
END
GO
-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LOS TIPOS DE VISITANTE
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Comercial.SP_CrearTipoVisitante
	@Descripcion VARCHAR(30)
AS
BEGIN
	BEGIN TRY
		--Se valida la descripcion ingresada
		IF @Descripcion = '' OR @Descripcion LIKE '%[^a-zA-Z ]%' OR LEN(@Descripcion) > 30
		BEGIN
			PRINT('La descripcion ingresada no es valida')
			RAISERROR('.', 16, 1)
		END
		SET @Descripcion = TRIM(@Descripcion)

		--La descripcion es unica
		IF EXISTS (SELECT 1 FROM Area_Comercial.Tipo_Visitante WHERE Descripcion = @Descripcion)
        BEGIN
            PRINT('Ya existe un tipo de visitante con esa descripcion')
            RAISERROR('.', 16, 1)
        END
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en el registro del tipo de visitante', 16, 1);
			RETURN;
		END
	END CATCH

	INSERT INTO Area_Comercial.Tipo_Visitante(Descripcion) VALUES
	(@Descripcion);
	DECLARE @IdNuevoTipoVisitante INT
	SET @IdNuevoTipoVisitante = SCOPE_IDENTITY()
	RETURN @IdNuevoTipoVisitante
END
GO
-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LAS VENTAS
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Comercial.SP_CrearVenta
	@IdPuntoDeVenta INT,
	@IdParque INT,
	@IdFormaDePago INT,
	@Fecha DATE,
	@Total DECIMAL(38,3)
AS
BEGIN
	BEGIN TRY
		--El punto de venta debe estar cargado en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Punto_De_Venta WHERE IdPuntoDeVenta = @IdPuntoDeVenta)
        BEGIN
            PRINT('Punto de venta inexistente')
            RAISERROR('.', 16, 1)
        END

		--El parque debe estar cargado en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @IdParque)
        BEGIN
            PRINT('Parque inexistente')
            RAISERROR('.', 16, 1)
        END

		--La forma de pago debe estar cargada en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Forma_De_Pago WHERE IdFormaDePago = @IdFormaDePago)
        BEGIN
            PRINT('Forma de pago inexistente')
            RAISERROR('.', 16, 1)
        END

		--El campo fecha debe tener un valor
		IF @Fecha IS NULL
		BEGIN
            PRINT('La fecha no puede ser nula')
            RAISERROR('.', 16, 1)
        END

		--El total debe ser un numero positivo
		IF @Total < 0
			BEGIN
				PRINT('El total no es valido')
				RAISERROR('.', 16, 1)
			END
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en el registro de la venta', 16, 1);
			RETURN;
		END
	END CATCH

	INSERT INTO Area_Comercial.Venta(IdPuntoDeVenta, IdParque, IdFormaDePago, Fecha, Total) VALUES
	(@IdPuntoDeVenta, @IdParque, @IdFormaDePago, @Fecha, @Total);
	DECLARE @IdNuevaVenta INT
	SET @IdNuevaVenta = SCOPE_IDENTITY()
	RETURN @IdNuevaVenta
END
GO
-- //////////////////////////////////////////////////////////////
--    CREACIÓN DE LAS TARIFAS DE PARQUE POR TIPO DE VISITANTE
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Comercial.Sp_CrearPrecioParqueTipoVisitante
    @Parque VARCHAR(80),
    @TipoVisitante VARCHAR(30),
    @Precio DECIMAL(14,4)
AS
BEGIN
BEGIN TRY
    
    SET NOCOUNT ON;

    DECLARE @IdParque INT;
    DECLARE @IdTipoVisitante INT;

    -- Validar que el parque exista
    SELECT @IdParque = IdParque FROM Area_Infraestructura.Parque WHERE Nombre = @Parque;
    IF @IdParque IS NULL
    BEGIN
        RAISERROR('El parque especificado no existe.', 16, 1);
        RETURN;
    END

    -- Validar que el tipo de visitante exista
    SELECT @IdTipoVisitante = IdTipoVisitante FROM Area_Comercial.Tipo_Visitante WHERE Descripcion = @TipoVisitante;
    IF @IdTipoVisitante IS NULL
    BEGIN
        RAISERROR('El tipo de visitante especificado no existe.', 16, 1);
        RETURN;
    END

    -- Validar que el precio sea positivo
    IF @Precio <= 0
    BEGIN
        RAISERROR('El precio debe ser un valor positivo.', 16, 1);
        RETURN;
    END

    -- Insertar el precio en la tabla Precio_Parque_Tipo_Visitante
	INSERT INTO Area_Comercial.Precio_Parque_Tipo_Visitante (IdParque, IdTipoVisitante, Precio)
    VALUES (@IdParque, @IdTipoVisitante, @Precio);

END TRY
BEGIN CATCH
    IF ERROR_SEVERITY() > 10
    BEGIN
        DECLARE @ErrorMessage VARCHAR(255) = ERROR_MESSAGE();	
        RAISERROR(@ErrorMessage, 16, 1);
    END
END CATCH
END
GO

-- //////////////////////////////////////////////////////////////
--                  Apartado 2: Sps de Modificación
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
--                  MODIFICACIÓN DE LOS DESCUENTOS POR PARQUE
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Comercial.Sp_ModificarDescuentoParque
    @IdDescuento INT,
    @Descripcion VARCHAR(100) = NULL,
    @Porcentaje DECIMAL(2,2) = NULL
AS
BEGIN
    BEGIN TRY

        --El descuento debe estar cargado en la DB
        IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Descuento_Parque WHERE IdDescuento = @IdDescuento)
        BEGIN
            PRINT('Descuento inexistente')
            RAISERROR('.', 16, 1)
        END

        --La descripción debe ser válida si se proporciona
        IF @Descripcion IS NOT NULL AND (@Descripcion ='' OR @Descripcion LIKE '%[^a-zA-Z ]%' OR LEN(@Descripcion) > 100)
        BEGIN
            PRINT('La descripción ingresada no es válida')
            RAISERROR('.', 16,1)
        END
        SET @Descripcion = TRIM(@Descripcion)

        --El porcentaje de descuento debe ser mayor a cero
        IF @Porcentaje IS NOT NULL AND @Porcentaje <= 0
        BEGIN
            PRINT('Porcentaje de descuento no válido')
            RAISERROR('.', 16, 1)
        END
    END TRY

    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
        BEGIN	
            RAISERROR('Algo salió mal en la modificación del descuento', 16, 1);
            RETURN;
        END
    END CATCH

    UPDATE Area_Comercial.Descuento_Parque
    SET 
    Descripcion = @Descripcion,
    Porcentaje = @Porcentaje
    WHERE IdDescuento = @IdDescuento;
END
GO
-- //////////////////////////////////////////////////////////////
--                  MODIFICACIÓN DE LAS FORMAS DE PAGO
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Comercial.SP_ModificarFormaDePago
	@IdFormaDePago INT,
	@Descripcion VARCHAR(30)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		--La forma de pago debe estar cargada en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Forma_De_Pago WHERE IdFormaDePago = @IdFormaDePago)
        BEGIN
            PRINT('Forma de pago inexistente')
            RAISERROR('.', 16, 1)
        END

		--Se valida la descripcion
		IF @Descripcion IS NOT NULL AND @Descripcion <> ''
		BEGIN
			SET @Descripcion = TRIM(@Descripcion);
			IF @Descripcion LIKE '%[^a-zA-Z ]%' OR LEN(@Descripcion) > 30
			BEGIN
				PRINT('La descripcion no es valida');
				RAISERROR('.', 16, 1);
			END

			UPDATE Area_Comercial.Forma_De_Pago
			SET Descripcion = @Descripcion
			WHERE IdFormaDePago = @IdFormaDePago;
		END
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en la modifiacion de la forma de pago', 16, 1);
			RETURN;
		END
	END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--                  MODIFICACIÓN DE LOS PUNTOS DE VENTA
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Comercial.SP_ModificarPuntoDeVenta
	@IdPuntoDeVenta INT,
	@Descripcion VARCHAR(30)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		--El punto de venta debe estar cargado en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Punto_De_Venta WHERE IdPuntoDeVenta = @IdPuntoDeVenta)
        BEGIN
            PRINT('Punto de venta inexistente')
            RAISERROR('.', 16, 1)
        END

		--Se valida la descripcion
		IF @Descripcion IS NOT NULL AND @Descripcion <> ''
		BEGIN
			SET @Descripcion = TRIM(@Descripcion);
			IF @Descripcion LIKE '%[^a-zA-Z ]%' OR LEN(@Descripcion) > 30
			BEGIN
				PRINT('La descripcion no es valida');
				RAISERROR('.', 16, 1);
			END

			UPDATE Area_Comercial.Punto_De_Venta
			SET Descripcion = @Descripcion
			WHERE IdPuntoDeVenta = @IdPuntoDeVenta;
		END
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en la modifiacion del punto de venta', 16, 1);
			RETURN;
		END
	END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--                  MODIFICACIÓN DE LOS TIPOS DE VISITANTE
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Comercial.SP_ModificarTipoVisitante
	@IdTipoVisitante INT,
	@Descripcion VARCHAR(30)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		--El tipo de visitante debe estar cargado en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Tipo_Visitante WHERE IdTipoVisitante = @IdTipoVisitante)
        BEGIN
            PRINT('Tipo de visitante inexistente')
            RAISERROR('.', 16, 1)
        END

		--Se valida la descripcion
		IF @Descripcion IS NOT NULL AND @Descripcion <> ''
		BEGIN
			SET @Descripcion = TRIM(@Descripcion);
			IF @Descripcion LIKE '%[^a-zA-Z ]%' OR LEN(@Descripcion) > 30
			BEGIN
				PRINT('La descripcion no es valida');
				RAISERROR('.', 16, 1);
			END

			UPDATE Area_Comercial.Tipo_Visitante
			SET Descripcion = @Descripcion
			WHERE IdTipoVisitante = @IdTipoVisitante;
		END
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en la modifiacion del tipo de visitante', 16, 1);
			RETURN;
		END
	END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--  MODIFICACIÓN DE LAS TARIFAS DE PARQUE POR TIPO DE VISITANTE
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Comercial.Sp_ModificarPrecioParqueTipoVisitante
    @Parque VARCHAR(80),
    @TipoVisitante VARCHAR(30),
    @Precio DECIMAL(14,4)
AS
BEGIN
BEGIN TRY
    
    SET NOCOUNT ON;

    DECLARE @IdParque INT;
    DECLARE @IdTipoVisitante INT;

    -- Validar que el parque exista
    SELECT @IdParque = IdParque FROM Area_Infraestructura.Parque WHERE Nombre = @Parque;
    IF @IdParque IS NULL
    BEGIN
        RAISERROR('El parque especificado no existe.', 16, 1);
        RETURN;
    END

    -- Validar que el tipo de visitante exista
    SELECT @IdTipoVisitante = IdTipoVisitante FROM Area_Comercial.Tipo_Visitante WHERE Descripcion = @TipoVisitante;
    IF @IdTipoVisitante IS NULL
    BEGIN
        RAISERROR('El tipo de visitante especificado no existe.', 16, 1);
        RETURN;
    END

    -- Validar que el precio sea positivo
    IF @Precio <= 0
    BEGIN
        RAISERROR('El precio debe ser un valor positivo.', 16, 1);
        RETURN;
    END

    -- Actualizar el precio en la tabla Precio_Parque_Tipo_Visitante
    UPDATE Area_Comercial.Precio_Parque_Tipo_Visitante
    SET Precio = @Precio
    WHERE IdParque = @IdParque AND IdTipoVisitante = @IdTipoVisitante;

END TRY
BEGIN CATCH
    IF ERROR_SEVERITY() > 10
    BEGIN
        DECLARE @ErrorMessage VARCHAR(255) = ERROR_MESSAGE();	
        RAISERROR(@ErrorMessage, 16, 1);
    END
END CATCH
END
GO

-- //////////////////////////////////////////////////////////////
--                  Apartado 3: Sps de Eliminación
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
--                  ELIMINACIÓN DE DESCUENTO PARQUE
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Comercial.Sp_EliminarDescuentoParque
    @IdDescuento INT
AS
BEGIN
    BEGIN TRY

    --El descuento debe estar cargado en la DB
    IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Descuento_Parque WHERE IdDescuento = @IdDescuento)
        BEGIN
            PRINT('Descuento inexistente')
            RAISERROR('.', 16, 1)
        END
    END TRY

    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
        BEGIN	
            RAISERROR('Algo salio mal en la eliminación del descuento', 16, 1);
            RETURN;
        END
    END CATCH

    DELETE FROM Area_Comercial.Descuento_Parque WHERE IdDescuento = @IdDescuento;
END
GO
-- //////////////////////////////////////////////////////////////
--                  ELIMINACIÓN DE DETALLE VENTA ENTRADA
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Comercial.SP_EliminarDetalleVentaEntrada
	@IdDetalle INT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		--El detalle debe estar cargado en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Detalle_Venta_Entrada WHERE IdDetalle = @IdDetalle)
        BEGIN
            PRINT('Detalle de venta inexistente')
            RAISERROR('.', 16, 1)
        END
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en la eliminacion del detalle de venta de entradas', 16, 1);
			RETURN;
		END
	END CATCH

	DELETE FROM Area_Comercial.Detalle_Venta_Entrada WHERE IdDetalle = @IdDetalle
END
GO

-- //////////////////////////////////////////////////////////////
--                  ELIMINACIÓN DE FORMA DE PAGO
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Comercial.SP_EliminarFormaDePago
	@IdFormaDePago INT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		--La forma de pago debe estar cargada en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Forma_De_Pago WHERE IdFormaDePago = @IdFormaDePago)
        BEGIN
            PRINT('Forma de pago inexistente')
            RAISERROR('.', 16, 1)
        END
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en la eliminacion de la forma de pago', 16, 1);
			RETURN;
		END
	END CATCH

	DELETE FROM Area_Comercial.Venta WHERE IdFormaDePago = @IdFormaDePago
	DELETE FROM Area_Comercial.Forma_De_Pago WHERE IdFormaDePago = @IdFormaDePago
END
GO

-- //////////////////////////////////////////////////////////////
--                  ELIMINACIÓN DE PUNTO DE VENTA
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Comercial.SP_EliminarPuntoDeVenta
	@IdPuntoDeVenta INT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		--El punto de venta debe estar cargado en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Punto_De_Venta WHERE IdPuntoDeVenta = @IdPuntoDeVenta)
        BEGIN
            PRINT('Punto de venta inexistente')
            RAISERROR('.', 16, 1)
        END
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en la eliminacion del punto de venta', 16, 1);
			RETURN;
		END
	END CATCH

	DELETE FROM Area_Comercial.Venta WHERE IdPuntoDeVenta = @IdPuntoDeVenta
	DELETE FROM Area_Comercial.Punto_De_Venta WHERE IdPuntoDeVenta = @IdPuntoDeVenta
END
GO

-- //////////////////////////////////////////////////////////////
--                  ELIMINACIÓN DE TIPO DE VISITANTE
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Comercial.SP_EliminarTipoDeVisitante
	@IdTipoVisitante INT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		--El tipo de visitante debe estar cargado en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Tipo_Visitante WHERE IdTipoVisitante = @IdTipoVisitante)
        BEGIN
            PRINT('Tipo de visitante inexistente')
            RAISERROR('.', 16, 1)
        END
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en la eliminacion del tipo de visitante', 16, 1);
			RETURN;
		END
	END CATCH

	DELETE FROM Area_Comercial.Entrada WHERE IdTipoVisitante = @IdTipoVisitante
	DELETE FROM Area_Comercial.Tipo_Visitante WHERE IdTipoVisitante = @IdTipoVisitante
END
GO

-- //////////////////////////////////////////////////////////////
--     ELIMINACION DE TARIFAS DE PARQUE POR TIPO DE VISITANTE
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Comercial.Sp_EliminarPrecioParqueTipoVisitante
    @Parque VARCHAR(80),
    @TipoVisitante VARCHAR(30)
AS
BEGIN
BEGIN TRY
    
    SET NOCOUNT ON;

    DECLARE @IdParque INT;
    DECLARE @IdTipoVisitante INT;

    -- Validar que el parque exista
    SELECT @IdParque = IdParque FROM Area_Infraestructura.Parque WHERE Nombre = @Parque;
    IF @IdParque IS NULL
    BEGIN
        RAISERROR('El parque especificado no existe.', 16, 1);
        RETURN;
    END

    -- Validar que el tipo de visitante exista
    SELECT @IdTipoVisitante = IdTipoVisitante FROM Area_Comercial.Tipo_Visitante WHERE Descripcion = @TipoVisitante;
    IF @IdTipoVisitante IS NULL
    BEGIN
        RAISERROR('El tipo de visitante especificado no existe.', 16, 1);
        RETURN;
    END

    -- Eliminar la tarifa en la tabla Precio_Parque_Tipo_Visitante
    DELETE FROM Area_Comercial.Precio_Parque_Tipo_Visitante
    WHERE IdParque = @IdParque AND IdTipoVisitante = @IdTipoVisitante;

END TRY
BEGIN CATCH
    IF ERROR_SEVERITY() > 10
    BEGIN
        DECLARE @ErrorMessage VARCHAR(255) = ERROR_MESSAGE();	
        RAISERROR(@ErrorMessage, 16, 1);
    END
END CATCH
END
GO

-----------------------------------------------------------------------
--                  CREACIÓN DE LOS SP DEL AREA DE EXCURSIONES      --
-----------------------------------------------------------------------

-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LAS ACTIVIDADES
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_CrearActividad
    @tipoActividad INT,
    @idParque INT,
    @Nombre VARCHAR(30),
    @Costo decimal(10, 2),
    @Duracion INT,
    @Cupo_maximo INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        --El tipo de Actividad debe estar en la db
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Tipo_Actividad WHERE IdTipoActividad = @tipoActividad)
        BEGIN
            RAISERROR('El tipo de actividad no existe.', 16, 1)
            
        END
        --El parque debe estar en la db
        IF NOT EXISTS(SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @idParque)
        BEGIN
            RAISERROR('El Parque no existe.', 16, 1)
            
        END

        IF @Costo < 0
        BEGIN
            RAISERROR('El costo no puede ser negativo.', 16, 1)
            
        END 
        IF @Duracion <= 0
        BEGIN  
            RAISERROR('La duración debe ser positiva.', 16, 1)
            
        END
        IF @Cupo_maximo <= 0 
        BEGIN
            RAISERROR('El cupo máximo debe ser positivo.', 16, 1)
            

        END
        IF( @Nombre IS NULL OR LEN(@Nombre) = 0)
        BEGIN
            RAISERROR('El nombre debe tener entre 1 y 30 caracteres.', 16, 1)
            
        END


    INSERT INTO Area_Excursiones.Actividad (IdTipoActividad, IdParque, Nombre, Costo, Duracion, Cupo_maximo)
    VALUES (@tipoActividad, @idParque, @Nombre, @Costo, @Duracion, @Cupo_maximo)
    DECLARE @Id_NuevaActividad INT 
    SET @Id_NuevaActividad = SCOPE_IDENTITY()
    RETURN @Id_NuevaActividad

    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END
GO
-- //////////////////////////////////////////////////////////////
--            CREACIÓN DE LA CONTRATACION DE ACTIVIDADES
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_CrearContratacion_Actividad
    @IdVenta INT, 
    @IdActividad INT,
    @Monto decimal(10, 2),
    @FechaContratacion DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Actividad WHERE IdActividad = @IdActividad AND Activo = 1)
        BEGIN
            RAISERROR('La actividad no existe.', 16, 1)
        END

        IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Venta WHERE IdVenta = @IdVenta)
        BEGIN
            RAISERROR('La venta no existe.', 16, 1)
        END

        IF @Monto < 0
        BEGIN
            RAISERROR('El monto no puede ser negativo.', 16, 1)
        END

    INSERT INTO Area_Excursiones.Contratacion_Actividad (IdVenta, IdActividad, Monto, Fecha_Contratacion)
    VALUES (@IdVenta, @IdActividad, @Monto, @FechaContratacion)
    DECLARE @idNueva_ContratacionActividad INT
    SET @idNueva_ContratacionActividad = SCOPE_IDENTITY()   
    RETURN @idNueva_ContratacionActividad


    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH


END
GO
-- //////////////////////////////////////////////////////////////
--            CREACIÓN DE LA ESPECIALIDAD
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_CrearEspecialidad
    @Descripcion VARCHAR(50)
AS 
BEGIN 
    SET NOCOUNT ON;
    BEGIN TRY
        IF @Descripcion IS NULL OR LEN(@Descripcion) = 0
        BEGIN
            RAISERROR('La descripción debe tener entre 1 y 50 caracteres.', 16, 1)
        END

        INSERT INTO Area_Excursiones.Especialidad (Descripcion)
        VALUES (@Descripcion)
        DECLARE @idNuevo_Especialidad INT
        SET @idNuevo_Especialidad = SCOPE_IDENTITY()
        RETURN @idNuevo_Especialidad

    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;
        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END
GO
-- //////////////////////////////////////////////////////////////
--            CREACIÓN DE LOS GUIAS
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_CrearGuia
    @DNI CHAR(8),
    @idParque INT,
    @idEspecialidad INT,
    @Nombre VARCHAR(30),
    @Apellido VARCHAR(30),
    @Titulo VARCHAR(30)

AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        --El parque debe estar en la db
        IF NOT EXISTS(SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @idParque)
        BEGIN
            RAISERROR('El Parque no existe.', 16, 1)
        END

        --La especialidad debe estar en la db
        IF NOT EXISTS(SELECT 1 FROM Area_Excursiones.Especialidad WHERE IdEspecialidad = @idEspecialidad)
        BEGIN
            RAISERROR('La especialidad no existe.', 16, 1)
            
        END
        --validar que el dni sea válido
        IF (@DNI LIKE '%[^0-9]%' OR LEN(@DNI) NOT BETWEEN 7 AND 8)
        BEGIN
            RAISERROR('DNI inválido: debe contener solo números y tener entre 7 y 8 dígitos.', 16, 1);
        END

        --El dni no debe existir en la db 
        DECLARE @IdGuiaRepetido INT
        SELECT @IdGuiaRepetido = IdGuia FROM Area_Excursiones.Guia WHERE DNI = @Dni
        IF @IdGuiaRepetido IS NOT NULL
        BEGIN
            RAISERROR('El DNI proporcionado ya está registrado para otro guía.', 16, 1)
            RETURN @IdGuiaRepetido 
        END

        IF( @Nombre IS NULL OR LEN(@Nombre) = 0)
        BEGIN
            RAISERROR('El nombre debe tener entre 1 y 30 caracteres.', 16, 1)
            
        END

        IF( @Apellido IS NULL OR LEN(@Apellido) = 0)
        BEGIN
            RAISERROR('El apellido debe tener entre 1 y 30 caracteres.', 16, 1)
            
        END

        IF( @Titulo IS NULL OR LEN(@Titulo) = 0)
        BEGIN
            RAISERROR('El título debe tener entre 1 y 30 caracteres.', 16, 1)
            
        END

        INSERT INTO Area_Excursiones.Guia (DNI, IdParque, IdEspecialidad, Nombre, Apellido, Titulo)
        VALUES (@DNI, @idParque, @idEspecialidad, @Nombre, @Apellido, @Titulo)
        DECLARE @Id_NuevoGuia INT
        SET @Id_NuevoGuia = SCOPE_IDENTITY()
        RETURN @Id_NuevoGuia

    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END
GO
-- //////////////////////////////////////////////////////////////
--            CREACIÓN DE LOS GUIAS POR ACTIVIDAD
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_CrearGuiasPorActividad
    @IdGuia INT,
    @IdActividad INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        --Validamos que el guia y la actividad existan
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Guia WHERE IdGuia = @IdGuia)
        BEGIN
            RAISERROR('El guía no existe.', 16, 1)
        END

        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Actividad WHERE IdActividad = @IdActividad AND Activo = 1)
        BEGIN
            RAISERROR('La actividad no existe.', 16, 1)
        END
        --ahora debemos validar que el guia tenga la HABILITACION para esa actividad
        IF NOT EXISTS (
            -- 1er nivel: Agarramos todas las habilitaciones que pide la actividad
            SELECT 1 FROM Area_Excursiones.Habilitaciones_por_Actividad ha
            WHERE ha.IdActividad = @IdActividad
            AND NOT EXISTS (
                -- 2do nivel: nos fijamos si alguna de esas NO la tiene el guía (o está vencida)
                SELECT 1 FROM Area_Excursiones.Habilitacion_Guia hg 
                WHERE hg.IdGuia = @IdGuia
                AND hg.IdHabilitacion = ha.IdHabilitacion
                AND hg.Fecha_Fin_Validez >= GETDATE() --la habilitación debe estar vigente
            )
        )
        BEGIN 
            -- Si llegamos acá, significa que la doble negación fue verdadera.
            -- NO hay ninguna habilitación exigida que el guía NO tenga. 
            -- Por lo tanto, LAS TIENE TODAS.
            INSERT INTO Area_Excursiones.Guias_por_actividad (IdGuia, IdActividad) 
            VALUES (@IdGuia, @IdActividad);
        END
        ELSE
        BEGIN
            RAISERROR('El guía no tiene la habilitación necesaria para esta actividad.', 16, 1)
        END

    END TRY


    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END

GO
-- //////////////////////////////////////////////////////////////
--            CREACIÓN DE LAS HABILITACIONES
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_CrearHabilitacion
    @Descripcion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @Descripcion IS NULL OR LEN(@Descripcion) = 0
        BEGIN
            RAISERROR('La descripción debe tener entre 1 y 50 caracteres.', 16, 1)
            
        END

    INSERT INTO Area_Excursiones.Habilitacion (Descripcion)
    VALUES (@Descripcion)
    DECLARE @idNueva_Habilitacion INT
    SET @idNueva_Habilitacion = SCOPE_IDENTITY()
    RETURN @idNueva_Habilitacion
    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END
GO

-- //////////////////////////////////////////////////////////////
--            CREACIÓN DE LAS HABILITACIONES POR ACTIVIDAD
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_CrearHabilitacionesPorActividad
    @IdActividad INT,
    @IdHabilitaciones INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validar que la habilitación exista
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Habilitacion WHERE IdHabilitaciones = @IdHabilitaciones)
        BEGIN
            RAISERROR('La habilitación con el Id proporcionado no existe.', 16, 1)
            RETURN
        END

        -- Validar que la actividad exista
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Actividad WHERE IdActividad = @IdActividad AND Activo = 1)
        BEGIN
            RAISERROR('La actividad con el Id proporcionado no existe.', 16, 1)
            RETURN
        END

        INSERT INTO Area_Excursiones.Habilitaciones_por_Actividad(IdHabilitacion, IdActividad)
        VALUES (@IdHabilitaciones, @IdActividad)

    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END
GO
-- //////////////////////////////////////////////////////////////
--            CREACIÓN DE LAS HABILITACIONES DEL GUIA
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_CrearHabilitacionGuia
    @IdGuia INT,
    @IdHabilitacion INT,
    @FechaInicio DATE,
    @FechaFin DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Guia WHERE IdGuia = @IdGuia)
        BEGIN
            RAISERROR('El guía no existe.', 16, 1)
            
        END

        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Habilitacion WHERE IdHabilitaciones = @IdHabilitacion)
        BEGIN
            RAISERROR('La habilitación no existe.', 16, 1)
            
        END

        IF @FechaFin < @FechaInicio
        BEGIN
            RAISERROR('La fecha de fin de la validez de la habilitacion no puede ser anterior a la fecha de inicio de la misma.', 16, 1)
        END
        
        IF @FechaFin < GETDATE()
        BEGIN
            RAISERROR('La fecha de la finalizacion de la validez de la habilitacion no puede ser anterior a la fecha actual.', 16, 1)
        END
            
        
    INSERT INTO Area_Excursiones.Habilitacion_Guia (IdGuia, IdHabilitacion, Fecha_Inicio_Validez, Fecha_Fin_Validez)
    VALUES (@IdGuia, @IdHabilitacion, @FechaInicio, @FechaFin)
    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END
GO
-- //////////////////////////////////////////////////////////////
--            CREACIÓN DE LOS TIPOS DE ACTIVIDAD
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Excursiones.SP_CrearTipoActividad
    @Descripcion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @Descripcion IS NULL OR LEN(@Descripcion) = 0
        BEGIN
            RAISERROR('La descripción debe tener entre 1 y 50 caracteres.', 16, 1)
        END

    INSERT INTO Area_Excursiones.Tipo_Actividad (Descripcion)
    VALUES (@Descripcion)
    DECLARE @idNuevo_TipoActividad INT
    SET @idNuevo_TipoActividad = SCOPE_IDENTITY()
    RETURN @idNuevo_TipoActividad
    
    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END
GO

-- //////////////////////////////////////////////////////////////
--            Apartado 3: Sps de Modificación 
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
--            MODIFICACIÓN DE ACTIVIDAD
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_ModificarActividad
    @IdActividad INT,
    @IdTipoActividad INT,
    @IdParque INT,
    @Nombre VARCHAR(30),
    @Costo DECIMAL(10, 2),
    @Duracion INT,
    @Cupo_maximo INT
AS
BEGIN

    BEGIN TRY
        -- Validar que la actividad exista
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Actividad WHERE IdActividad = @IdActividad AND Activo = 1)
        BEGIN
            RAISERROR('La actividad con el Id proporcionado no existe.', 16, 1)
            RETURN
        END
        -- Validar que el tipo de actividad exista
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Tipo_Actividad WHERE IdTipoActividad = @IdTipoActividad)
        BEGIN
            RAISERROR('El tipo de actividad con el Id proporcionado no existe.', 16, 1)
            RETURN
        END
        -- Validar que el parque exista
        IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @IdParque)
        BEGIN
            RAISERROR('El parque con el Id proporcionado no existe.', 16, 1)
            RETURN
        END
        --validar que el nombre sea valido
        IF @Nombre IS NULL OR LEN(@Nombre) = 0
        BEGIN
            RAISERROR('El nombre debe tener entre 1 y 30 caracteres.', 16, 1)
            RETURN
        END
        --validar que el costo sea positivo
        IF @Costo < 0
        BEGIN
            RAISERROR('El costo no puede ser negativo.', 16, 1)
            RETURN
        END
        --validar la duración y el cupo máximo sean positivos
        IF @Duracion <= 0
        BEGIN
            RAISERROR('La duración debe ser un valor positivo.', 16, 1)
            RETURN
        END 
        IF @Cupo_maximo <= 0
        BEGIN
            RAISERROR('El cupo máximo debe ser un valor positivo.', 16, 1)
            RETURN
        END

    UPDATE Area_Excursiones.Actividad
    SET IdTipoActividad = @IdTipoActividad,
        IdParque = @IdParque,
        Nombre = @Nombre,
        Costo = @Costo,
        Duracion = @Duracion,
        Cupo_maximo = @Cupo_maximo
    WHERE IdActividad = @IdActividad

    END TRY

BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END 
GO
-- //////////////////////////////////////////////////////////////
--            MODIFICACIÓN DE CONTRATACIÓN DE ACTIVIDAD
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_ModificarContratacionActividad
    @IdContratacionActividad INT,
    @IdActividad INT,
    @IdVenta INT, 
    @Monto DECIMAL(10, 2),
    @FechaContratacion DATE

AS
BEGIN
    BEGIN TRY
        -- Validar que la contratación de actividad exista
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Contratacion_Actividad WHERE IdContratacion = @IdContratacionActividad AND Activo = 1)
        BEGIN
            RAISERROR('La contratación de actividad con el Id proporcionado no existe.', 16, 1)
        END
        -- Validar que la actividad exista
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Actividad WHERE IdActividad = @IdActividad AND Activo = 1)
        BEGIN
            RAISERROR('La actividad con el Id proporcionado no existe.', 16, 1)
            
        END
        -- Validar que la venta exista
        IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Venta WHERE IdVenta = @IdVenta)
        BEGIN
            RAISERROR('La venta con el Id proporcionado no existe.', 16, 1)
            
        END
        --validar que el monto sea positivo
        IF @Monto < 0
        BEGIN
            RAISERROR('El monto no puede ser negativo.', 16, 1)
            
        END
        --validar que la fecha de contratación no sea futura
        IF @FechaContratacion > GETDATE()
        BEGIN
            RAISERROR('La fecha de contratación no puede ser futura.', 16, 1)
        END

    UPDATE Area_Excursiones.Contratacion_Actividad 
    SET IdActividad = @IdActividad,
        IdVenta = @IdVenta,
        Monto = @Monto,
        Fecha_Contratacion = @FechaContratacion
    WHERE IdContratacion = @IdContratacionActividad
    
    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH


END
GO
-- //////////////////////////////////////////////////////////////
--            MODIFICACIÓN DE ESPECIALIDADES
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_ModificarEspecialidad
    @IdEspecialidad INT,
    @Descripcion VARCHAR(50)
AS
BEGIN
    BEGIN TRY
        -- Validar que la especialidad exista
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Especialidad WHERE IdEspecialidad = @IdEspecialidad)
        BEGIN
            RAISERROR('La especialidad con el Id proporcionado no existe.', 16, 1)
            RETURN
        END
        --validar que la descripción sea válida
        IF @Descripcion IS NULL OR LEN(@Descripcion) = 0
        BEGIN
            RAISERROR('La descripción debe tener entre 1 y 50 caracteres.', 16, 1)
            RETURN
        END

        -- Modificar la especialidad
        UPDATE Area_Excursiones.Especialidad
        SET Descripcion = @Descripcion
        WHERE IdEspecialidad = @IdEspecialidad

    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END
GO
-- //////////////////////////////////////////////////////////////
--            MODIFICACIÓN DE GUIAS
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_ModificarGuia
    @IdGuia INT,
    @Dni CHAR(8),
    @IdParque INT,
    @IdEspecialidad INT,
    @Nombre VARCHAR(30),
    @Apellido VARCHAR(30),
    @Titulo VARCHAR(30)
AS
BEGIN

    BEGIN TRY 
        -- Validar que el guia exista
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Guia WHERE IdGuia = @IdGuia)
        BEGIN
            RAISERROR('El guia con el Id proporcionado no existe.', 16, 1)

        END
        -- Validar que el parque exista
        IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @IdParque)
        BEGIN
            RAISERROR('El parque con el Id proporcionado no existe.', 16, 1)
            
        END
        -- Validar que la especialidad exista
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Especialidad WHERE IdEspecialidad = @IdEspecialidad)
        BEGIN
            RAISERROR('La especialidad con el Id proporcionado no existe.', 16, 1)
            
        END
        --validar que el dni sea válido
        IF (@DNI LIKE '%[^0-9]%' OR LEN(@DNI) NOT BETWEEN 7 AND 8)
        BEGIN
            RAISERROR('DNI inválido: debe contener solo números y tener entre 7 y 8 dígitos.', 16, 1);
        END

        
        IF EXISTS(SELECT 1 FROM Area_Excursiones.Guia WHERE DNI = @Dni AND IdGuia != @IdGuia)
        BEGIN
            RAISERROR('El DNI proporcionado ya está registrado para otro guía.', 16, 1)
        END

        --validar que el nombre, apellido y título sean válidos
        IF @Nombre IS NULL OR LEN(@Nombre) = 0
        BEGIN
            RAISERROR('El nombre debe tener entre 1 y 30 caracteres.', 16, 1) 
        END

        IF @Apellido IS NULL OR LEN(@Apellido) = 0
        BEGIN
            RAISERROR('El apellido debe tener entre 1 y 30 caracteres.', 16, 1)   
        END

        IF @Titulo IS NULL OR LEN(@Titulo) = 0
        BEGIN
            RAISERROR('El título debe tener entre 1 y 30 caracteres.', 16, 1)
            
        END

        -- Modificar el guia
        UPDATE Area_Excursiones.Guia
        SET DNI = @Dni,
            IdParque = @IdParque,
            IdEspecialidad = @IdEspecialidad,
            Nombre = @Nombre,
            Apellido = @Apellido,
            Titulo = @Titulo
        WHERE IdGuia = @IdGuia

    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END 
GO
-- //////////////////////////////////////////////////////////////
--            MODIFICACIÓN DE HABILITACIONES
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_ModificarHabilitacion
    @IdHabilitacion INT,
    @Descripcion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validar que la habilitación exista
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Habilitacion WHERE IdHabilitaciones = @IdHabilitacion)
        BEGIN
            RAISERROR('La habilitación con el Id proporcionado no existe.', 16, 1)
        END

        IF @Descripcion IS NULL OR LEN(@Descripcion) = 0
        BEGIN
            RAISERROR('La descripción debe tener entre 1 y 50 caracteres.', 16, 1)
        END

        UPDATE Area_Excursiones.Habilitacion
        SET Descripcion = @Descripcion
        WHERE IdHabilitaciones = @IdHabilitacion

    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END
GO
-- //////////////////////////////////////////////////////////////
--            MODIFICACIÓN DE HABILITACIONES DE GUIA
-- //////////////////////////////////////////////////////////////


CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_ModificarHabilitacionesGuia
    @IdGuia INT,
    @IdHabilitacion INT,
    @FechaInicio DATE,
    @FechaFin DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY 
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Guia WHERE IdGuia = @IdGuia)
        BEGIN
            RAISERROR('El guía no existe.', 16, 1)
        END

        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Habilitacion WHERE IdHabilitaciones = @IdHabilitacion)
        BEGIN
            RAISERROR('La habilitación no existe.', 16, 1)
        END

        IF @FechaFin < @FechaInicio
        BEGIN
            RAISERROR('La fecha de fin de la validez de la habilitacion no puede ser anterior a la fecha de inicio de la misma.', 16, 1)
        END

        IF NOT EXISTS( SELECT 1 FROM Area_Excursiones.Habilitacion_Guia WHERE IdGuia = @IdGuia AND IdHabilitacion = @IdHabilitacion )
        BEGIN 
            RAISERROR('El guia no tiene asignada la habilitacion que se desea modificar.',16,1)
        END 
                
        
        IF @FechaFin < GETDATE()
        BEGIN
            RAISERROR('La fecha de la finalizacion de la validez de la habilitacion no puede ser anterior a la fecha actual.', 16, 1)
        END

        UPDATE Area_Excursiones.Habilitacion_Guia
        SET Fecha_Inicio_Validez = @FechaInicio,
            Fecha_Fin_Validez = @FechaFin
        WHERE IdGuia = @IdGuia AND IdHabilitacion = @IdHabilitacion

    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH


END 
GO
-- //////////////////////////////////////////////////////////////
--            MODIFICACIÓN DE TIPO DE ACTIVIDAD
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_ModificarTipoActividad
    @idTipoActividad INT,
    @Descripcion VARCHAR(50)
AS

BEGIN
    SET NOCOUNT ON
    BEGIN TRY 
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Tipo_Actividad WHERE idTipoActividad = @idTipoActividad)
        BEGIN 
            RAISERROR('El tipo de actividad que se quiere modificar no existe',16,1)
        END 

        --validamos la descripcion
        IF @Descripcion IS NULL OR LEN(@Descripcion) = 0
        BEGIN 
            RAISERROR('Debe ingresar una descripcion valida',16,1)
        END

        UPDATE Area_Excursiones.Tipo_Actividad 
        SET Descripcion  = @Descripcion
        WHERE IdTipoActividad = @idTipoActividad

    END TRY 

    BEGIN CATCH 
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH 
END 
GO

-- //////////////////////////////////////////////////////////////
--            APARTADO 3: SPs de ELIMINACIÓN
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
--            ELIMINACIÓN DE ACTIVIDAD
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_EliminarActividad
    @IdActividad INT
AS

BEGIN 
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS( SELECT 1 FROM Area_Excursiones.Actividad WHERE IdActividad = @IdActividad AND Activo = 1  )
        BEGIN  
            RAISERROR('La actividad no existe o ya se encuentra dada de baja.', 16, 1);
        END 

        UPDATE Area_Excursiones.Actividad 
        SET Activo = 0
        WHERE IdActividad = @IdActividad
    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END 
GO

-- //////////////////////////////////////////////////////////////
--            ELIMINACIÓN DE CONTRATACIÓN DE ACTIVIDAD
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_EliminarContratacionActividad
    @IdContratacion INT
AS

BEGIN 
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS( SELECT 1 FROM Area_Excursiones.Contratacion_Actividad WHERE IdContratacion = @IdContratacion AND Activo = 1  )
        BEGIN  
            RAISERROR('La contratacion no existe o ya se encuentra dada de baja.', 16, 1);
        END 

        UPDATE Area_Excursiones.Contratacion_Actividad
        SET Activo = 0
        WHERE IdContratacion = @IdContratacion
    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END 
GO
-- //////////////////////////////////////////////////////////////
--            ELIMINACIÓN DE ESPECIALIDAD
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_EliminarEspecialidad
    @IdEspecialidad INT
AS
BEGIN 
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION
            -- Validar que la especialidad exista
            IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Especialidad WHERE IdEspecialidad = @IdEspecialidad)
            BEGIN
                RAISERROR('La especialidad con el Id proporcionado no existe.', 16, 1)
            END
            UPDATE Area_Excursiones.Guia SET IdEspecialidad = 1 --Establecemos la especialidad por defecto a los guías que tengan la especialidad que se va a eliminar
            WHERE IdEspecialidad = @IdEspecialidad

            DELETE FROM Area_Excursiones.Especialidad
            WHERE IdEspecialidad = @IdEspecialidad
        COMMIT TRANSACTION

    END TRY

    BEGIN CATCH
        IF @@TRANCOUNT > 0 
            ROLLBACK TRANSACTION

        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END
GO
-- //////////////////////////////////////////////////////////////
--            ELIMINACIÓN DE GUIAS POR ACTIVIDAD
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_ElimnarGuiasPorActividad
    @IdActividad INT,
    @IdGuia INT
AS
BEGIN 
    BEGIN TRY 
        SET NOCOUNT ON;
        -- Validar que la actividad exista
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Actividad WHERE IdActividad = @IdActividad AND Activo = 1 )
        BEGIN
            RAISERROR('La actividad con el Id proporcionado no existe.', 16, 1)
        END
        --Validar que el guía exista 
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Guia WHERE IdGuia = @IdGuia)
        BEGIN
            RAISERROR('El guía con el Id proporcionado no existe.', 16, 1)
        END
        --Validar que ese guia tenga esa actividad para eliminarla 
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Guias_por_Actividad WHERE IdActividad = @IdActividad AND IdGuia = @IdGuia)
        BEGIN
            RAISERROR('La actividad no está asignada al guía proporcionado.', 16, 1)
        END

        DELETE FROM Area_Excursiones.Guias_por_Actividad
        WHERE IdActividad = @IdActividad AND IdGuia = @IdGuia

    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END 
GO

-- //////////////////////////////////////////////////////////////
--            ELIMINACIÓN DE HABILITACIONES
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_EliminarHabilitacion
    @IdHabilitacion INT
AS
BEGIN 
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION
            -- Validar que la habilitación exista
            IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Habilitacion WHERE IdHabilitaciones = @IdHabilitacion)
            BEGIN
                RAISERROR('La habilitación con el Id proporcionado no existe.', 16, 1)
            END
            --eliminamos las asociaciones de los guias 
            DELETE FROM Area_Excursiones.Habilitacion_Guia
            WHERE IdHabilitacion = @IdHabilitacion
            --eliminamos las asociaciones de las actividades
            DELETE FROM Area_Excursiones.Habilitaciones_por_Actividad
            WHERE IdHabilitacion = @IdHabilitacion
            --eliminamos la habilitacion
            DELETE FROM Area_Excursiones.Habilitacion
            WHERE IdHabilitaciones = @IdHabilitacion
        COMMIT TRANSACTION

    END TRY
    BEGIN CATCH
        --si hubo un error y la transaccion quedó abierta, revertimos
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION 
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- //////////////////////////////////////////////////////////////
--            ELIMINACIÓN DE HABILITACIONES POR ACTIVIDAD
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_EliminarHabilitacionesPorActividad
    @IdActividad INT,
    @IdHabilitacion INT
AS

BEGIN 
    BEGIN TRY 
        SET NOCOUNT ON;
        -- Validar que la actividad exista
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Actividad WHERE IdActividad = @IdActividad AND Activo = 1 )
        BEGIN
            RAISERROR('La actividad con el Id proporcionado no existe.', 16, 1)
        END
        --Validar que la habilitación exista 
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Habilitacion WHERE IdHabilitaciones = @IdHabilitacion)
        BEGIN
            RAISERROR('La habilitación con el Id proporcionado no existe.', 16, 1)
        END
        --Validar que esa habilitación tenga esa actividad para eliminarla 
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Habilitaciones_por_Actividad WHERE IdActividad = @IdActividad AND IdHabilitacion = @IdHabilitacion)
        BEGIN
            RAISERROR('La actividad no tiene asignada la habilitación proporcionada.', 16, 1)
        END

        DELETE FROM Area_Excursiones.Habilitaciones_por_Actividad
        WHERE IdActividad = @IdActividad AND IdHabilitacion = @IdHabilitacion

    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END     
GO
-- //////////////////////////////////////////////////////////////
--            ELIMINACIÓN DE HABILITACIONES DE GUIA
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_EliminarHabilitacionGuia
    @IdHabilitacion INT,
    @IdGuia INT
AS
BEGIN
    BEGIN TRY 
        SET NOCOUNT ON;
        -- Validar que la habilitación exista
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Habilitacion WHERE IdHabilitaciones = @IdHabilitacion )
        BEGIN
            RAISERROR('La habilitación con el Id proporcionado no existe.', 16, 1)
        END
        --Validar que el guía exista 
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Guia WHERE IdGuia = @IdGuia)
        BEGIN
            RAISERROR('El guía con el Id proporcionado no existe.', 16, 1)
        END
        --Validar que ese guia tenga esa habilitacion para eliminarla 
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Habilitacion_Guia WHERE IdHabilitacion = @IdHabilitacion AND IdGuia = @IdGuia)
        BEGIN
            RAISERROR('La habilitación no está asignada al guía proporcionado.', 16, 1)
        END

        DELETE FROM Area_Excursiones.Habilitacion_Guia
        WHERE IdHabilitacion = @IdHabilitacion AND IdGuia = @IdGuia

    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END 
GO
-- //////////////////////////////////////////////////////////////
--            ELIMINACIÓN DE TIPO DE ACTIVIDAD
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_EliminarTipoActividad
    @idTipoActividad INT 
AS

BEGIN
    SET NOCOUNT ON 
    BEGIN TRY 
        BEGIN TRANSACTION
            IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Tipo_Actividad WHERE idTipoActividad = @idTipoActividad)
            BEGIN 
                RAISERROR('El tipo de actividad que se quiere elimnar no existe',16,1)
            END 

            UPDATE Area_Excursiones.Actividad 
            SET IdTipoActividad = 1
            WHERE IdTipoActividad = @idTipoActividad

            DELETE FROM Area_Excursiones.Tipo_Actividad
            WHERE idTipoActividad = @idTipoActividad
        COMMIT TRANSACTION
    END TRY 

    BEGIN CATCH
        --si hubo un error y la transaccion quedó abierta, revertimos
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION 
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END 
GO

-- //////////////////////////////////////////////////////////////
--            ELIMINACIÓN DE GUIA
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_EliminarGuia
    @IdGuia INT
AS
BEGIN 
    BEGIN TRY 
        SET NOCOUNT ON;

        -- Validar que el guía exista antes de intentar eliminarlo
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Guia WHERE IdGuia = @IdGuia)
        BEGIN
            RAISERROR('El guía con el Id proporcionado no existe.', 16, 1)
        END

        -- Iniciamos una transacción para asegurar la integridad de los datos
        BEGIN TRANSACTION;

        -- 1. Eliminar dependencias en la tabla Guias_por_actividad
        DELETE FROM Area_Excursiones.Guias_por_actividad
        WHERE IdGuia = @IdGuia;

        -- 2. Eliminar dependencias en la tabla Habilitaciones_Guias
        DELETE FROM Area_Excursiones.Habilitacion_Guia
        WHERE IdGuia = @IdGuia;

        -- 3. Finalmente, eliminar el registro de la tabla principal Guia
        DELETE FROM Area_Excursiones.Guia
        WHERE IdGuia = @IdGuia;

        -- Si llegamos hasta acá sin errores, confirmamos los cambios
        COMMIT TRANSACTION;

    END TRY

    BEGIN CATCH
        -- Si ocurre un error y hay una transacción abierta, deshacemos todos los cambios
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END 
GO

-----------------------------------------------------------------------
--                  CREACIÓN DE LOS SP DEL AREA INFRAESTRUCTURA      --
-----------------------------------------------------------------------

-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LOS GUARDAPARQUES
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Infraestructura.SP_CrearGuardaParque
	@Nombre VARCHAR(30),
	@Apellido VARCHAR(30),
	@Dni CHAR(8),
	@Parque VARCHAR(80),
	@Fecha_Ingreso DATE,
	@Fecha_Egreso DATE,
	@Activo BIT
AS
BEGIN
	BEGIN TRY
			
			-- Validamos nombre ingresado. Si es valido, quitamos espacios al string
			IF @Nombre ='' OR @Nombre LIKE '%[^a-zA-Z ]%' OR LEN(@Nombre) > 30
			BEGIN
				PRINT('El nombre ingresado no es valido')
				RAISERROR('.', 16,1)
			END
			SET @Nombre = TRIM(@Nombre)
			
			-- Validamos apellido ingresado. Si es valido, quitamos espacios al string
			IF @Apellido ='' OR @Apellido LIKE '%[^a-zA-Z ]%' OR LEN(@Apellido) > 30
			BEGIN
				PRINT('El apellido ingresado no es valido')
				RAISERROR('.', 16,1)
			END
			SET @Apellido = TRIM(@Apellido)

			-- El dni no puede ser repetido
			SET NOCOUNT ON;
			DECLARE @IdGuardaRepetido INT;
			SELECT @IdGuardaRepetido = g.IdGuardaparque FROM Area_Infraestructura.Guardaparque g WHERE g.Dni = @Dni;
			IF @IdGuardaRepetido IS NOT NULL
			BEGIN
				PRINT('Ya existe un guardaparque con ese dni')
				RETURN @IdGuardaRepetido;
			END

			-- El parque debe existir en la BBDD
			DECLARE @IdParque INT;
			SELECT @IdParque = p.IdParque FROM Area_Infraestructura.Parque p WHERE p.Nombre = @Parque;
			IF @IdParque IS NULL
			BEGIN
				PRINT('El parque ingresado no existe')
				RAISERROR('.', 16,1)
			END

			-- El campo activo solo puede ser 0 o 1
			IF @Activo NOT IN (0,1)
			BEGIN
				PRINT('El campo activo solo puede ser 0 o 1')
				RAISERROR('.', 16,1)
			END

			-- validaciones de fechas

			 -- La fecha de egreso no puede ser menor a la fecha de ingreso
			IF @Fecha_Egreso < @Fecha_Ingreso
			BEGIN
				PRINT('La fecha de egreso no puede ser menor a la fecha de ingreso')
				RAISERROR('.', 16,1)
			END

            DECLARE @FechaActual DATE
			SET @FechaActual = GETDATE()
			
			 -- La fecha de ingreso no puede ser mayor a la fecha actual
			IF @Fecha_Ingreso > @FechaActual
			BEGIN
				PRINT('La fecha de ingreso no puede ser mayor a la fecha actual')
				RAISERROR('.', 16,1)
			END

			 -- La fecha de egreso no puede ser mayor a la fecha actual
			IF @Fecha_Egreso > @FechaActual
			BEGIN
				PRINT('La fecha de egreso no puede ser mayor a la fecha actual')
				RAISERROR('.', 16,1)
			END

	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY()>10
		BEGIN	
			RAISERROR('Algo salio mal en el registro del guardaparque',16,1);
			RETURN;
		END
	END CATCH

	INSERT INTO Area_Infraestructura.Guardaparque(Nombre, Apellido, Dni, IdParque, Fecha_Ingreso, Fecha_Egreso, Activo) VALUES
	(@Nombre, @Apellido, @Dni, @IdParque, @Fecha_Ingreso, @Fecha_Egreso, @Activo);
	DECLARE @IdNuevoGuardaparque INT
	SET @IdNuevoGuardaparque = SCOPE_IDENTITY()
	RETURN @IdNuevoGuardaparque
END
GO

-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LOS PARQUES
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Infraestructura.SP_CrearParque 
	@Nombre VARCHAR(80),
	@TipoParqueDesc VARCHAR(50),
	@Provincia VARCHAR(80),
	@Superficie DECIMAL(14,4)
AS
BEGIN
	BEGIN TRY
			
			-- Validamos nombre ingresado. Si es valido, limpiamos el string
			IF @Nombre ='' OR @Nombre LIKE '%[^a-zA-Z ]%' OR LEN(@Nombre) > 80
			BEGIN
				PRINT('El nombre ingresado no es valido')
				RAISERROR('.', 16,1)
			END
			SET @Nombre = TRIM(@Nombre)

			-- El nombre no puede ser repetido
			SET NOCOUNT ON;
			DECLARE @IdParqueRepetido INT;
			SELECT @IdParqueRepetido = p.IdParque FROM Area_Infraestructura.Parque p WHERE p.Nombre = @Nombre;
			IF @IdParqueRepetido IS NOT NULL
			BEGIN
				PRINT('Ya existe un parque con ese nombre')
				RETURN @IdParqueRepetido;
			END

			-- Validamos provincia ingresada
			IF @Provincia = '' OR @Provincia LIKE '%[^a-zA-Z ]%' OR LEN(@Provincia) > 80
			BEGIN
				PRINT('La provincia ingresada no es valida')
				RAISERROR('.', 16,1)
			END

			-- La provincia debe existir en la bbdd
			DECLARE @IdProvincia INT;
			SELECT @IdProvincia = pr.IdProvincia FROM Area_Infraestructura.Provincia pr WHERE pr.Nombre = @Provincia;
			IF @IdProvincia IS NULL
			BEGIN
				PRINT('La provincia ingresada no existe')
				RAISERROR('.', 16,1)
			END

			-- Validamos tipo de parque ingresado
			IF @TipoParqueDesc = '' OR @TipoParqueDesc LIKE '%[^a-zA-Z ]%' OR LEN(@TipoParqueDesc) > 80
			BEGIN
				PRINT('El tipo de parque ingresado no es valido')
				RAISERROR('.', 16,1)
			END

			-- EL tipo de parque debe estar cargado en la bbdd
			DECLARE @IdTipoParque INT;
			SELECT @IdTipoParque = t.IdTipoParque FROM Area_Infraestructura.Tipo_Parque t WHERE t.Descripcion = @TipoParqueDesc;
			IF @IdTipoParque IS NULL
			BEGIN
				PRINT('El tipo de parque ingresado no existe')
				RAISERROR('.', 16,1)
			END

			-- La superficie debe ser un valor decimal valido
			IF @Superficie = 0
			BEGIN
				PRINT('El valor de la superficie no es una dimension valida')
				RAISERROR('.', 16,1)
			END

	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY()>10
		BEGIN	
			RAISERROR('Algo salio mal en el registro del parque',16,1);
			RETURN;
		END
	END CATCH

	INSERT INTO Area_Infraestructura.Parque(IdProvincia, IdTipoParque, Nombre, Superficie, Activo) VALUES
	(@IdProvincia, @IdTipoParque, @Nombre, @Superficie, 1);
	DECLARE @IdNuevoParque INT
	SET @IdNuevoParque = SCOPE_IDENTITY()
	RETURN @IdNuevoParque
END
GO
-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LAS REGIONES
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Infraestructura.SP_CrearRegion
    @Nombre VARCHAR(80)
AS
BEGIN
    BEGIN TRY

        -- Validamos nombre ingresado. Si es valido, quitamos espacios al string
        IF @Nombre ='' OR @Nombre LIKE '%[^a-zA-Z ]%' OR LEN(@Nombre) > 80
        BEGIN
            PRINT('El nombre ingresado no es valido')
            RAISERROR('.', 16,1)
        END
        SET @Nombre = TRIM(@Nombre)

        -- El nombre no puede ser repetido
        SET NOCOUNT ON;
        DECLARE @IdRegionRepetida INT;
        SELECT @IdRegionRepetida = r.IdRegion FROM Area_Infraestructura.Region r WHERE r.Nombre = @Nombre;
        IF @IdRegionRepetida IS NOT NULL
        BEGIN
            PRINT('Ya existe una region con ese nombre')
            RETURN @IdRegionRepetida;
        END
        
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY()>10
        BEGIN	
            RAISERROR('Algo salio mal en el registro de la region',16,1);
            RETURN;
        END
    END CATCH
    
    INSERT INTO Area_Infraestructura.Region(Nombre) VALUES (@Nombre)
    DECLARE @IdNuevaRegion INT
	SET @IdNuevaRegion = SCOPE_IDENTITY()
	RETURN @IdNuevaRegion
END
GO

-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LAS PROVINCIAS
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Infraestructura.SP_CrearProvincia
    @Nombre VARCHAR(80),
    @NombreRegion VARCHAR(30)
AS
BEGIN
    BEGIN TRY
        -- Validamos nombre ingresado. Si es valido, quitamos espacios al string
        IF @Nombre ='' OR @Nombre LIKE '%[^a-zA-Z ]%' OR LEN(@Nombre) > 80
        BEGIN
            PRINT('El nombre ingresado no es valido')
            RAISERROR('.', 16,1)
        END
        SET @Nombre = TRIM(@Nombre)

        -- El nombre no puede ser repetido
        SET NOCOUNT ON;
        DECLARE @IdProvinciaRepetida INT;
        SELECT @IdProvinciaRepetida = p.IdProvincia FROM Area_Infraestructura.Provincia p WHERE p.Nombre = @Nombre;
        IF @IdProvinciaRepetida IS NOT NULL
        BEGIN
            PRINT('Ya existe una provincia con ese nombre')
            RETURN @IdProvinciaRepetida;
        END

        -- Validamos region ingresada. Si es valida, quitamos espacios al string
        IF @NombreRegion = '' OR @NombreRegion LIKE '%[^a-zA-Z ]%' OR LEN(@NombreRegion) > 80
        BEGIN
            PRINT('La region ingresada no es valida')
            RAISERROR('.', 16,1)
        END
        SET @NombreRegion = TRIM(@NombreRegion)

        -- La region debe existir en la bbdd
        DECLARE @IdRegion INT;
        SELECT @IdRegion = r.IdRegion FROM Area_Infraestructura.Region r WHERE r.Nombre = @NombreRegion;
        IF @IdRegion IS NULL
        BEGIN
            PRINT('La region ingresada no existe')
            RAISERROR('.', 16,1)
        END
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY()>10
        BEGIN	
            RAISERROR('Algo salio mal en el registro de la provincia',16,1);
            RETURN;
        END
    END CATCH
    
    INSERT INTO Area_Infraestructura.Provincia(Nombre, IDRegion) VALUES (@Nombre, @IdRegion)
    DECLARE @IdNuevaProvincia INT
	SET @IdNuevaProvincia = SCOPE_IDENTITY()
	RETURN @IdNuevaProvincia
END
GO
-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LOS TIPOS DE PARQUE
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Infraestructura.SP_CrearTipoParque
    @Descripcion VARCHAR(50)
AS
BEGIN
    BEGIN TRY

        -- Validamos descripcion ingresada. Si es valida, quitamos espacios al string
        IF @Descripcion ='' OR @Descripcion LIKE '%[^a-zA-Z ]%' OR LEN(@Descripcion) > 50
        BEGIN
            PRINT('La descripcion ingresada no es valida')
            RAISERROR('.', 16,1)
        END
        SET @Descripcion = TRIM(@Descripcion)

        -- La descripcion no puede ser repetida
        SET NOCOUNT ON;
        DECLARE @IdTipoParqueRepetido INT;
        SELECT @IdTipoParqueRepetido = tp.IdTipoParque FROM Area_Infraestructura.Tipo_Parque tp WHERE tp.Descripcion = @Descripcion;
        IF @IdTipoParqueRepetido IS NOT NULL
        BEGIN
            PRINT('Ya existe un tipo de parque con esa descripcion')
            RETURN @IdTipoParqueRepetido;
        END

    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY()>10
        BEGIN	
            RAISERROR('Algo salio mal en el registro deL tipo de parque',16,1);
            RETURN;
        END
    END CATCH

    INSERT INTO Area_Infraestructura.Tipo_Parque(Descripcion) VALUES (@Descripcion)
    DECLARE @IdNuevoTipoParque INT
	SET @IdNuevoTipoParque = SCOPE_IDENTITY()
	RETURN @IdNuevoTipoParque
END
GO

-- //////////////////////////////////////////////////////////////
--                  APARTADO 2: SPs de Modificación
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
--                  MODIFICACIÓN DE GUARDAPARQUES
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_ModificarGuardaparque
    @IdGuardaparque INT,
    @Dni CHAR(8) = NULL,
    @Nombre VARCHAR(30) = NULL,
    @Apellido VARCHAR(30) = NULL,
    @Fecha_Ingreso DATE = NULL,
    @Fecha_Egreso DATE = NULL
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		-- Validamos existencia
		IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Guardaparque WHERE IdGuardaparque = @IdGuardaparque)
		BEGIN
			PRINT('No existe un guardaparque con el Id proporcionado.');
			RETURN;
		END

		-- Modificar Nombre
		IF @Nombre IS NOT NULL AND @Nombre <> ''
		BEGIN
			SET @Nombre = TRIM(@Nombre);
			IF @Nombre LIKE '%[^a-zA-Z ]%' OR LEN(@Nombre) > 25
			BEGIN
				PRINT('El nombre no es v lido');
				RAISERROR('.', 16, 1);
			END

			UPDATE Area_Infraestructura.Guardaparque
			SET Nombre = @Nombre
			WHERE IdGuardaparque = @IdGuardaparque;
		END

		-- Modificar Apellido
		IF @Apellido IS NOT NULL AND @Apellido <> ''
		BEGIN
			SET @Apellido = TRIM(@Apellido);
			IF @Apellido LIKE '%[^a-zA-Z ]%' OR LEN(@Apellido) > 25
			BEGIN
				PRINT('El apellido no es v lido');
				RAISERROR('.', 16, 1);
			END

			UPDATE Area_Infraestructura.Guardaparque
			SET Apellido = @Apellido
			WHERE IdGuardaparque = @IdGuardaparque;
		END

		-- Modificar DNI
		IF @DNI IS NOT NULL AND @DNI <> ''
		BEGIN
			SET @DNI = TRIM(@DNI);
			IF @DNI LIKE '%[^0-9]%' OR LEN(@DNI) > 10
			BEGIN
				PRINT('El DNI no es v lido');
				RAISERROR('.', 16, 1);
			END

			-- Validar que no exista otro guardaparque con el mismo DNI
			IF EXISTS (
				SELECT 1 FROM Area_Infraestructura.Guardaparque 
				WHERE DNI = @DNI AND IdGuardaparque <> @IdGuardaparque
			)
			BEGIN
				PRINT('Ya existe otro guardaparque con el DNI ingresado.');
				RAISERROR('.', 16, 1);
			END

			UPDATE Area_Infraestructura.Guardaparque
			SET DNI = @DNI
			WHERE IdGuardaparque = @IdGuardaparque;
		END

        -- Modificar Fecha de Ingreso
        IF @Fecha_Ingreso IS NOT NULL
        BEGIN
            IF @Fecha_Ingreso > GETDATE()
            BEGIN
                PRINT('La fecha de ingreso no puede ser futura.');
                RAISERROR('.', 16, 1);
            END

            UPDATE Area_Infraestructura.Guardaparque
            SET Fecha_Ingreso = @Fecha_Ingreso
            WHERE IdGuardaparque = @IdGuardaparque;
        END

        -- Modificar Fecha de Egreso
        IF @Fecha_Egreso IS NOT NULL
        BEGIN
            IF @Fecha_Egreso < @Fecha_Ingreso OR @Fecha_Egreso > GETDATE()
            BEGIN
                PRINT('La fecha de egreso no puede ser anterior a la fecha de ingreso.');
                RAISERROR('.', 16, 1);
            END

            UPDATE Area_Infraestructura.Guardaparque
            SET Fecha_Egreso = @Fecha_Egreso
            WHERE IdGuardaparque = @IdGuardaparque;
        END

		PRINT('Guardaparque actualizado correctamente.');
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrió  un error al modificar el guardaparque.', 16, 1);
			RETURN;
		END
	END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--                  MODIFICACIÓN DE PARQUES
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_ModificarParque
	@IdParque INT,
	@Provincia VARCHAR(30) = NULL,
	@TipoParque VARCHAR(30) = NULL,
	@Nombre VARCHAR(80) = NULL,
	@Superficie DECIMAL(14,4) = NULL,
	@Activo BIT = NULL
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		-- Validamos existencia
		IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @IdParque)
		BEGIN
			PRINT('No existe un parque con el Id proporcionado.');
			RETURN;
		END

		-- Modificar Nombre
		IF @Nombre IS NOT NULL AND @Nombre <> ''
		BEGIN
			SET @Nombre = TRIM(@Nombre);
			IF @Nombre LIKE '%[^a-zA-Z ]%' OR LEN(@Nombre) > 25
			BEGIN
				PRINT('El nombre no es v lido');
				RAISERROR('.', 16, 1);
			END

			UPDATE Area_Infraestructura.Parque
			SET Nombre = @Nombre
			WHERE IdParque = @IdParque;
		END

		-- Modificar Provincia
		IF @Provincia IS NOT NULL AND @Provincia <> ''
		BEGIN
			SET @Provincia = TRIM(@Provincia);
			IF @Provincia LIKE '%[^a-zA-Z ]%' OR LEN(@Provincia) > 30
			BEGIN
				PRINT('El apellido no es v lido');
				RAISERROR('.', 16, 1);
			END
			IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Provincia WHERE Nombre = @Provincia)
			BEGIN
				PRINT('La provincia no es valida');
				RAISERROR('.',18,1);
			END
			DECLARE @IdDeProvinciaNueva INT;
			SELECT @IdDeProvinciaNueva = IdProvincia FROM Area_Infraestructura.Provincia WHERE Nombre = @Provincia
			UPDATE Area_Infraestructura.Parque
			SET IdProvincia = @IdDeProvinciaNueva
			WHERE IdParque = @IdParque;
		END

		-- Modificar Tipo de Parque
		IF @TipoParque IS NOT NULL AND @TipoParque <> ''
		BEGIN
			SET @TipoParque = TRIM(@TipoParque);
			IF @TipoParque LIKE '%[^a-zA-Z ]%' OR LEN(@TipoParque) > 30
			BEGIN
				PRINT('El tipo de parque no es valido');
				RAISERROR('.', 16, 1);
			END
			IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Tipo_Parque WHERE Descripcion = @TipoParque)
			BEGIN
				PRINT('El tipo de parque no es valido');
				RAISERROR('.',16,1);
			END
			DECLARE @IdDeTipoParqueNuevo INT;
			SELECT  @IdDeTipoParqueNuevo = IdProvincia FROM Area_Infraestructura.Provincia WHERE Nombre = @Provincia
			UPDATE Area_Infraestructura.Parque
			SET IdTipoParque = @IdDeTipoParqueNuevo
			WHERE IdParque = @IdParque;
		END

		-- Modificar Superficie
		IF @Superficie IS NULL OR @Superficie < 0
		BEGIN
            PRINT('La superficie no es valida');
            RAISERROR('.', 16, 1);
		END
        UPDATE Area_Infraestructura.Parque
		SET Superficie = @Superficie
		WHERE IdParque = @IdParque;

		-- Modficar si esta o no activo
		IF @Activo IS NOT NULL
		BEGIN
			UPDATE Area_Infraestructura.Parque
			SET Activo = @Activo
			WHERE IdParque = @IdParque;
		END

		PRINT('Parque actualizado correctamente.');
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrió  un error al modificar el parque.', 16, 1);
			RETURN;
		END
	END CATCH
END
GO

-- //////////////////////////////////////////////////////////////
--                  MODIFICACIÓN DE REGIONES
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Infraestructura.SP_ModificarProvincia
    @IdProvincia INT,
    @Nombre VARCHAR(80) = NULL,
    @NombreRegion VARCHAR(30) = NULL
AS
BEGIN
    BEGIN TRY

        -- Validamos que la provincia exista
        IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Provincia WHERE IdProvincia = @IdProvincia)
        BEGIN
            RAISERROR('La provincia ingresada no existe', 16,1)
        END

        -- Validamos nombre ingresado. Si es valido, quitamos espacios al string
        IF @Nombre is not null AND (@Nombre ='' OR @Nombre LIKE '%[^a-zA-Z ]%' OR LEN(@Nombre) > 80)
        BEGIN
            RAISERROR('El nombre ingresado no es valido', 16,1)
            RETURN;
        END
        SET @Nombre = TRIM(@Nombre)

        -- El nombre no puede ser repetido
        SET NOCOUNT ON;
        DECLARE @IdProvinciaRepetida INT;
        SELECT @IdProvinciaRepetida = p.IdProvincia FROM Area_Infraestructura.Provincia p WHERE p.Nombre = @Nombre;
        IF @IdProvinciaRepetida IS NOT NULL
        BEGIN
            RAISERROR('Ya existe una provincia con ese nombre', 16,1)
            RETURN @IdProvinciaRepetida;
        END

        -- Validamos region ingresada. Si es valida, quitamos espacios al string
        IF @NombreRegion is not null AND (@NombreRegion = '' OR @NombreRegion LIKE '%[^a-zA-Z ]%' OR LEN(@NombreRegion) > 80)
        BEGIN
            RAISERROR('La region ingresada no es valida', 16,1)
            RETURN;
        END
        SET @NombreRegion = TRIM(@NombreRegion)

        -- La region debe existir en la bbdd
        DECLARE @IdRegion INT;
        SELECT @IdRegion = r.IdRegion FROM Area_Infraestructura.Region r WHERE r.Nombre = @NombreRegion;
        IF @IdRegion IS NULL
        BEGIN
            RAISERROR('La region ingresada no existe', 16,1)
            RETURN;
        END

        UPDATE Area_Infraestructura.Provincia SET Nombre = @Nombre, IDRegion = @IdRegion WHERE IdProvincia = @IdProvincia
    
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY()>10
        BEGIN	
            DECLARE @ErrorMessage VARCHAR(255) = ERROR_MESSAGE();
            RAISERROR('Algo salio mal en el registro de la provincia: %s', 16,1, @ErrorMessage);
            RETURN;
        END
    END CATCH
END
GO


-- //////////////////////////////////////////////////////////////
--                  MODIFICACIÓN DE REGIONES
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_ModificarTipoParque
	@IdTipoParque INT,
	@Descripcion VARCHAR(50) = NULL
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		-- Validamos existencia
		IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Tipo_Parque WHERE IdTipoParque = @IdTipoParque)
		BEGIN
			PRINT('No existe un tipo de parque con el Id proporcionado.');
			RETURN;
		END

		-- Modificar Descripción
		IF @Descripcion IS NOT NULL AND @Descripcion <> ''
		BEGIN
			SET @Descripcion = TRIM(@Descripcion);
			IF @Descripcion LIKE '%[^a-zA-Z ]%' OR LEN(@Descripcion) > 50
			BEGIN
				PRINT('La descripción no es válida');
				RAISERROR('.', 16, 1);
			END

			UPDATE Area_Infraestructura.Tipo_Parque
			SET Descripcion = @Descripcion
			WHERE IdTipoParque = @IdTipoParque;
		END

	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrió  un error al modificar el tipo de parque.', 16, 1);
			RETURN;
		END
	END CATCH
END
GO

-- //////////////////////////////////////////////////////////////
--                  MODIFICACIÓN DE TIPOS DE PARQUE
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_ModificarRegion
	@IdRegion INT,
	@Nombre VARCHAR(50) = NULL
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		-- Validamos existencia
		IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Region WHERE IdRegion = @IdRegion)
		BEGIN
			PRINT('No existe una región con el Id proporcionado.');
			RETURN;
		END

		-- Modificar Nombre
		IF @Nombre IS NOT NULL AND @Nombre <> ''
		BEGIN
			SET @Nombre = TRIM(@Nombre);
			IF @Nombre LIKE '%[^a-zA-Z ]%' OR LEN(@Nombre) > 50
			BEGIN
				PRINT('El nombre no es válido');
				RAISERROR('.', 16, 1);
			END

			UPDATE Area_Infraestructura.Region
			SET Nombre = @Nombre
			WHERE IdRegion = @IdRegion;
		END

	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrió  un error al modificar la región.', 16, 1);
			RETURN;
		END
	END CATCH
END
GO

-- //////////////////////////////////////////////////////////////
--                  APARTADO 3: SPs de Eliminación
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
--                  ELIMINACIÓN DE GUARDAPARQUES
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Infraestructura.SP_EliminarGuardaparque
    @IdGuardaparque INT
AS
BEGIN
    BEGIN TRY

        -- Validamos que el IdGuardaparque ingresado exista en la BBDD
        SET NOCOUNT ON;
        DECLARE @IdGuardaparqueExistente INT;
        SELECT @IdGuardaparqueExistente = g.IdGuardaparque FROM Area_Infraestructura.Guardaparque g WHERE g.IdGuardaparque = @IdGuardaparque;
        IF @IdGuardaparqueExistente IS NULL
        BEGIN
            PRINT('No existe un guardaparque con ese Id')
            RETURN;
        END

    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY()>10
        BEGIN	
            RAISERROR('Algo salio mal en la eliminacion del guardaparque',16,1);
            RETURN;
        END
    END CATCH
    DELETE FROM Area_Infraestructura.Historial_Trabajo_Guardaparque WHERE IdGuardaparque = @IdGuardaparque;
    DELETE FROM Area_Infraestructura.Guardaparque WHERE IdGuardaparque = @IdGuardaparque;
END
GO
-- //////////////////////////////////////////////////////////////
--                  ELIMINACIÓN DE PARQUES
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_EliminarParque
    @IdParque INT
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        -- Validamos existencia
        IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @IdParque)
        BEGIN
            PRINT('No existe un parque con el Id proporcionado.');
            RAISERROR('', 16, 1);
            RETURN;
        END

        -- Borrado lógico del parque
        UPDATE Area_Infraestructura.Parque
        SET Activo = 0
        WHERE IdParque = @IdParque;

    END TRY

    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
        BEGIN
            RAISERROR('Ocurrió un error al eliminar el parque.', 16, 1);
            RETURN;
        END
    END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--                  ELIMINACIÓN DE PROVINCIA
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_EliminarProvincia
	@IdProvincia INT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		-- Validamos existencia
		IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Provincia WHERE IdProvincia = @IdProvincia)
		BEGIN
			PRINT('No existe una provincia con el Id proporcionado.');
			RETURN;
		END

        -- Seteamos en null la región para los parques que lo tengan asignado
        UPDATE Area_Infraestructura.Parque
        SET IdProvincia = NULL
        WHERE IdProvincia = @IdProvincia;

		-- Eliminar provincia
		DELETE FROM Area_Infraestructura.Provincia
		WHERE IdProvincia = @IdProvincia;

	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrió  un error al eliminar la provincia.', 16, 1);
			RETURN;
		END
	END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--                  ELIMINACIÓN DE REGIÓN
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_EliminarRegion
	@IdRegion INT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		-- Validamos existencia
		IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Region WHERE IdRegion = @IdRegion)
		BEGIN
			PRINT('No existe una región con el Id proporcionado.');
			RETURN;
		END

        -- Seteamos en null la región para las provincias que la tengan asignado
        UPDATE Area_Infraestructura.Provincia
        SET IdRegion = NULL
        WHERE IdRegion = @IdRegion;

		-- Eliminar región
		DELETE FROM Area_Infraestructura.Region
		WHERE IdRegion = @IdRegion;

	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrió  un error al eliminar la región.', 16, 1);
			RETURN;
		END
	END CATCH
END
GO

-----------------------------------------------------------------------
--                  CREACIÓN DE LOS SP DEL AREA DE NEGOCIOS          --
-----------------------------------------------------------------------

-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LOS CANONES
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Negocios.SP_CrearCanon
    @IdEstado INTEGER,
    @IdConcesion INTEGER,
    @Monto_Mensual DECIMAL(13,3),
    @Fecha_Vencimiento DATE
AS
BEGIN
	BEGIN TRY
        -- Busca el IdEstado en la tabla de Estados.
       IF NOT EXISTS ( SELECT 1 FROM Area_Negocios.Estado_Canon WHERE IdEstadoCanon = @IdEstado)
        BEGIN
            PRINT('No Existe el Estado de canon Ingresado')
            RAISERROR('EstadoCanon Invalido',16,1)
        END
        --Busca el IdConcesion en la tabla de Concesiones.
        IF NOT EXISTS ( SELECT 1 FROM Area_Negocios.Concesion WHERE IdConcesion = @IdConcesion)
        BEGIN
            PRINT('No Existe la Concesión Ingresada')
            RAISERROR('Concesión Invalida',16,1)
        END

        -- Valida el Monto ingresado
        IF @Monto_Mensual IS NULL OR  @Monto_Mensual <= 0 
        BEGIN
            PRINT('El Monto Ingresado no es valido, debe ser mayor a 0')
            RAISERROR('Monto Invalido',16,1)
        END
        -- Valida la fecha ingresada, comprobando que no sea nula.
		IF @Fecha_Vencimiento IS NULL
		BEGIN
            PRINT('La fecha no puede ser nula')
            RAISERROR('Fecha Invalida', 16, 1)
        END

        IF @Fecha_Vencimiento < CAST(GETDATE() AS DATE)
        BEGIN
            RAISERROR('La fecha de vencimiento no puede ser anterior a la fecha actual.', 16, 1);
            RAISERROR('Fecha Invalida', 16, 1)
        END
            INSERT INTO Area_Negocios.Canon(IdEstado,IdConcesion,Monto_Mensual,Fecha_Vencimiento) VALUES (@IdEstado,@IdConcesion,@Monto_Mensual,@Fecha_Vencimiento)

    END TRY
    BEGIN CATCH
        -- Lanzamos return
            DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
            DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
            DECLARE @ErrorState INT = ERROR_STATE();
            RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
            Return;
    END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LAS CONCESIONES
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Negocios.SP_CrearConcesion
    @IdTipoActividadConcesion INTEGER,
    @IdEmpresa INTEGER,
    @IdParque INTEGER,
    @Fecha_Inicio DATE,
    @Fecha_Fin DATE
AS
BEGIN
	BEGIN TRY
        -- Busca el Id del TipoActividad en la tabla de Tipo_Actividad_Concesion.
       IF NOT EXISTS ( SELECT 1 FROM Area_Negocios.Tipo_Actividad_Concesion WHERE IdTipoActividadConcesion = @IdTipoActividadConcesion)
        BEGIN
            RAISERROR('No Existe el Tipo de actividad de concesion ingresada',16,1)
        END
        --Busca la empresa en la tabla de Empresa_Concesionaria.
        --No solo verificar si existe si no si está activa también
        IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Empresa_Concesionaria WHERE IdEmpresa = @IdEmpresa AND Estado = 1)
        BEGIN
            RAISERROR('No Existe la Empresa concesionaria o no esta activa actualmente',16,1)
        END
        --Busca el parque en la tabla de Parques
        IF NOT EXISTS ( SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @IdParque)
        BEGIN
            RAISERROR('No Existe el parque Ingresado',16,1)
        END

        -- Valida la fecha de inicio ingresada, comprobando que no sea nula.
		IF @Fecha_Inicio IS NULL
		BEGIN
            RAISERROR('La fecha de Inicio no puede ser nula', 16, 1)
        END
        -- Valida la fecha de fin ingresada, comprobando que no sea nula.
		IF @Fecha_Fin IS NULL
		BEGIN
            RAISERROR('La fecha de Fin no puede ser nula', 16, 1)
        END

        --Obviamente la fecha de Fin debe ser mayor que la de inicio y no puede finalizar el mismo día que inicia la concesión, ya que no tendría sentido.
        IF @Fecha_Fin <= @Fecha_Inicio
        BEGIN
            RAISERROR('La fecha de finalización debe ser estrictamente posterior a la fecha de inicio.', 16, 1);
        END

        INSERT INTO Area_Negocios.Concesion(IdTipoActividadConcesion,IdEmpresa,IdParque,Fecha_Inicio,Fecha_Fin) VALUES (@IdTipoActividadConcesion,@IdEmpresa,@IdParque,@Fecha_Inicio,@Fecha_Fin)

    END TRY
    BEGIN CATCH
        -- Lanzamos return	
        DECLARE @ErrorMessage VARCHAR(255) = ERROR_MESSAGE();
        RAISERROR('Error al crear la Concesión: %s', 16, 1, @ErrorMessage);
        Return;
    END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--              CREACIÓN DE LAS EMPRESAS CONCESIONARIAS
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Negocios.SP_CrearEmpresaConcesionaria
	@Nombre varchar(150)
AS
BEGIN
	BEGIN TRY
        -- Validamos nombre ingresado.
        IF  @Nombre IS NULL OR @Nombre ='' OR NOT @Nombre NOT LIKE '%[^a-zA-ZñÑ. ]%' OR LEN(@Nombre) > 80 
        BEGIN
            PRINT('El nombre de la empresa ingresado no es valido')
            RAISERROR('Nombre Invalido', 16,1)
        END
        -- Se busca que el nombre no sea repetido
        DECLARE @IdNombreEmpresaRepe INT;
        SELECT @IdNombreEmpresaRepe = IdEmpresa FROM Area_Negocios.Empresa_Concesionaria WHERE Nombre = @Nombre;
        IF @IdNombreEmpresaRepe IS NOT NULL
        BEGIN
            PRINT('Ya existe una empresa con ese nombre')
            RAISERROR('Nombre Invalido',16,1)
        END
        INSERT INTO Area_Negocios.Empresa_Concesionaria(Nombre, Estado) VALUES (@Nombre, 1)
    END TRY
    BEGIN CATCH
        -- Lanzamos Rollback
            RAISERROR('Algo salio mal en el registro del nombre de la empresa',16,1);
            RETURN;
    END CATCH
    
END
GO
-- //////////////////////////////////////////////////////////////
--              CREACIÓN DE LOS ESTADOS DE CANON
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Negocios.SP_CrearEstadoCanon
	@Descripcion varchar(150)
AS
BEGIN
	BEGIN TRY
        -- Validamos descripcion ingresada.
        IF @Descripcion IS NULL OR @Descripcion ='' OR @Descripcion LIKE '%[^a-zA-ZñÑ. ]%'  OR LEN(@Descripcion) > 100
        BEGIN
            PRINT('La descripcion ingresada no es valida')
            RAISERROR('Descripcion Invalida', 16,1)
        END
        -- Validamos que la descripcion no se encuentra ya registrada
        IF EXISTS (SELECT 1 FROM Area_Negocios.Estado_Canon WHERE Descripcion = @Descripcion)
        BEGIN
            PRINT('La descripcion ingresada ya se encuentra registrada')
            RAISERROR('Descripcion Invalida', 16,1)
        END
        INSERT INTO Area_Negocios.Estado_Canon(Descripcion) VALUES (@Descripcion)  
    END TRY
    BEGIN CATCH
        -- Lanzamos Return
            RAISERROR('Algo salio mal en la creación del estado del canon',16,1);
            RETURN;
    END CATCH
     
END
GO

-- //////////////////////////////////////////////////////////////
--              CREACIÓN DE LOS PAGOS DE CANON
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Negocios.SP_CrearPagoCanon
	@IdCanon INTEGER,
    @Monto_Abonado DECIMAL(13,3),
    @Fecha_Pago DATE
AS
BEGIN
	BEGIN TRY
        -- Busca el IdCanon en la tabla de Canon.
        --Verifica que existe
       IF NOT EXISTS ( SELECT 1 FROM Area_Negocios.Canon WHERE IdCanon = @IdCanon)
        BEGIN
            PRINT('No Existe el Canon Ingresado')
            RAISERROR('Canon Invalido',16,1)
        END
        -- Valida el Monto ingresado
        IF  @Monto_Abonado IS NULL OR  @Monto_Abonado <= 0 
        BEGIN
            PRINT('El Monto Ingresado no es valido')
            RAISERROR('Monto Invalido',16,1)
        END
        -- Valida la fecha ingresada, comprobando que no sea nula.
		IF @Fecha_Pago IS NULL
		BEGIN
            PRINT('La fecha no puede ser nula')
            RAISERROR('Fecha Invalida', 16, 1)
        END
        INSERT INTO Area_Negocios.Pago_Canon(IdCanon,Monto_Abonado,Fecha_Pago) VALUES (@IdCanon,@Monto_Abonado,@Fecha_Pago)
    END TRY
    BEGIN CATCH
        -- Lanzamos return	
            RAISERROR('Algo salio mal en la creación del pago del canon',16,1);
            Return;
    END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--              CREACIÓN DE LOS TIPOS DE ACTIVIDAD
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Negocios.SP_CrearTipoActividadConcesion
	@Descripcion varchar(150)
AS
BEGIN
	BEGIN TRY
        -- Validamos descripcion ingresada.
        IF @Descripcion IS NULL OR @Descripcion ='' OR @Descripcion LIKE '%[^a-zA-ZñÑ. ]%' OR LEN(@Descripcion)>100 
        BEGIN
            PRINT('La descripcion ingresada no es valida')
            RAISERROR('Descripcion Invalida', 16,1)
        END
        -- Validamos que la descripcion no se encuentra ya registrada
        IF EXISTS (SELECT 1 FROM Area_Negocios.Tipo_Actividad_Concesion WHERE Descripcion = @Descripcion)
        BEGIN
            PRINT('La descripcion ingresada ya se encuentra registrada')
            RAISERROR('Descripcion Invalida', 16,1)
        END
        INSERT INTO Area_Negocios.Tipo_Actividad_Concesion(Descripcion) VALUES (@Descripcion)
    END TRY
    BEGIN CATCH
        -- Lanzamos RETURN
            RAISERROR('Algo salio mal en la creación del Tipo de actividad de Concesion',16,1);
            RETURN;
    END CATCH
    
END
GO

-- //////////////////////////////////////////////////////////////
--              Apartado 2: SPs de Modificación
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
--              MODIFICACIÓN DE LOS CANON
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Negocios.SP_ModificarCanon
	@IdCanon Integer,
	@IdEstadoCanon INT,
    @IdConcesion INTEGER,
    @Monto_Mensual DECIMAL(13,3),
    @Fecha_Vencimiento DATE
AS
BEGIN
	BEGIN TRY
		--Busca el Canon verificando que existe en la base de datos
		IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Canon WHERE IdCanon = @IdCanon)
        BEGIN
            PRINT('Canon inexistente')
            RAISERROR('Canon Inexistente', 16, 1)
        END
		--Busca el Estado Canon verificando que existe en la base de datos
		IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Estado_Canon WHERE IdEstadoCanon = @IdEstadoCanon)
        BEGIN
            PRINT('Estado de Canon inexistente')
            RAISERROR('Estado de Canon Inexistente', 16, 1)
        END

		--Busca la Concesión verificando que existe en la base de datos
		IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Concesion WHERE IdConcesion = @IdConcesion)
        BEGIN
            PRINT('Concesión inexistente')
            RAISERROR('Concesión Inexistente', 16, 1)
        END
		 -- Valida el Monto ingresado
        IF NOT @Monto_Mensual > 0 OR @Monto_Mensual IS NULL 
        BEGIN
            PRINT('El Monto Ingresado no es valido')
            RAISERROR('Monto Invalido',16,1)
        END
        -- Valida la fecha ingresada, comprobando que no sea nula.
		IF @Fecha_Vencimiento IS NULL
		BEGIN
            PRINT('La fecha no puede ser nula')
            RAISERROR('Fecha Invalida', 16, 1)
        END
		IF @Fecha_Vencimiento < CAST(GETDATE() AS DATE)
		BEGIN
			PRINT('La fecha no puede ser anterior al dia actual')
			RAISERROR('La fecha de vencimiento no puede ser anterior a la fecha actual.', 16, 1);
		END
		UPDATE Area_Negocios.Canon 
		SET  IdEstado = @IdEstadoCanon,
		IdConcesion = @IdConcesion,
		Monto_Mensual = @Monto_Mensual,
		Fecha_Vencimiento = @Fecha_Vencimiento
		WHERE IdCanon = @IdCanon 
	END TRY
	BEGIN CATCH
        -- Lanzar return
			RAISERROR('Algo salio mal en la modificación del Canon', 16, 1);
			RETURN;
	END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--              MODIFICACIÓN DE LAS CONCESIONES
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Negocios.SP_ModificarConcesion
    @IdConcesion INTEGER,
    @IdTipoActividadConcesion INTEGER,
    @IdEmpresa INTEGER,
    @IdParque INTEGER,
    @Fecha_Inicio DATE,
    @Fecha_Fin DATE
AS
BEGIN
	BEGIN TRY

        -- Se verifica que la concesión exista
        IF NOT EXISTS ( SELECT 1 FROM Area_Negocios.Concesion WHERE IdConcesion = @IdConcesion)
        BEGIN
            PRINT('No Existe la concesión ingresada')
            RAISERROR('Concesión Invalida',16,1)
        END
        -- Busca el Id del TipoActividad en la tabla de Tipo_Actividad_Concesion.
       IF NOT EXISTS ( SELECT 1 FROM Area_Negocios.Tipo_Actividad_Concesion WHERE IdTipoActividadConcesion = @IdTipoActividadConcesion)
        BEGIN
            PRINT('No Existe el Tipo de actividad ingresada')
            RAISERROR('TipoActividad Invalida',16,1)
        END
        --Busca la empresa en la tabla de Empresa_Concesionaria.
        --No solo verificar si existe si no si está activa también
        IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Empresa_Concesionaria WHERE IdEmpresa = @IdEmpresa AND Estado = 1)
        BEGIN
            PRINT('No Existe la Empresa concesionaria o no esta activa actualmente')
            RAISERROR('EmpresaConcesionaria Invalida',16,1)
        END
        --Busca el parque en la tabla de Parques
        IF NOT EXISTS ( SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @IdParque)
        BEGIN
            PRINT('No Existe el parque Ingresado')
            RAISERROR('Parque Invalido',16,1)
        END

        -- Valida la fecha de inicio ingresada, comprobando que no sea nula.
		IF @Fecha_Inicio IS NULL
		BEGIN
            PRINT('La fecha de Inicio no puede ser nula')
            RAISERROR('Fecha Inicio Inválida', 16, 1)
        END
        -- Valida la fecha de fin ingresada, comprobando que no sea nula.
		IF @Fecha_Fin IS NULL
		BEGIN
            PRINT('La fecha de Fin no puede ser nula')
            RAISERROR('Fecha Fin Inválida', 16, 1)
        END

        UPDATE Area_Negocios.Concesion
        SET IdTipoActividadConcesion=@IdTipoActividadConcesion,
        IdEmpresa=@IdEmpresa,
        IdParque=@IdParque,
        Fecha_Inicio=@Fecha_Inicio,
        Fecha_Fin=@Fecha_Fin
        WHERE IdConcesion=@IdConcesion

    END TRY
    BEGIN CATCH
        -- Lanzamos return
            RAISERROR('Algo salio mal en la modificación de la Concesión',16,1);
            Return;
    END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--              MODIFICACIÓN DE LAS EMPRESAS
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Negocios.SP_ModificarEmpresaConcesionaria
	@IdEmpresaConcesionaria INT,
	@Nombre varchar(150),
	@Estado bit
AS
BEGIN
	BEGIN TRY

		--Busca la Empresa Concesionaria en la base de datos
		IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Empresa_Concesionaria WHERE IdEmpresa = @IdEmpresaConcesionaria)
        BEGIN
            PRINT('Empresa Concesionaria inexistente')
            RAISERROR('Empresa Inexistente', 16, 1)
        END

		-- El nuevo nombre debe ser valido
		IF @Nombre IS NULL OR @Nombre='' OR @Nombre LIKE '%[^a-zA-ZñÑ. ]%' OR LEN(@Nombre) > 80
		BEGIN
			PRINT('El Nuevo nombre de la empresa no es valido.');
			RAISERROR('EmpresaConcesionaria Invalida', 16, 1);
		END
		-- La modificacion de Nombre no puede estar repetida.
		IF EXISTS (SELECT 1 FROM Area_Negocios.Empresa_Concesionaria WHERE Nombre = @Nombre AND IdEmpresa <> @IdEmpresaConcesionaria)
        BEGIN
			-- Lanzar el error
			PRINT('La empresa ya se encuentra registrada.');
			RAISERROR('EmpresaConcesionaria Invalida', 16, 1);
		END
		-- El estado no puede ser vacio
		IF @Estado IS NULL
		BEGIN
			PRINT('No puede colocar un estado vacío')
			RAISERROR('Estado Invalido', 16, 1);
		END
			UPDATE Area_Negocios.Empresa_Concesionaria
			SET Nombre = @Nombre, Estado = @Estado
			WHERE IdEmpresa = @IdEmpresaConcesionaria; 

	END TRY
	BEGIN CATCH
			RAISERROR('Algo salio mal en la modificación de la Empresa', 16, 1);
			RETURN;
	END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--              MODIFICACIÓN DEL ESTADO DEL CANON
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Negocios.SP_ModificarEstadoCanon
	@IdEstadoCanon INT,
	@Descripcion varchar(150)
AS
BEGIN
	BEGIN TRY
		--Busca el Estado Canon verificando que existe en la base de datos
		IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Estado_Canon WHERE IdEstadoCanon = @IdEstadoCanon)
        BEGIN
            PRINT('Estado Canon inexistente')
            RAISERROR('Estado Canon Inexistente', 16, 1)
        END

		-- La nueva descripcion debe ser valida
		-- 2. Validar formato de la descripción
        IF @Descripcion IS NULL OR @Descripcion = '' OR LEN(@Descripcion) > 100
        BEGIN
            RAISERROR('La nueva descripción no es válida o excede el límite de caracteres.', 16, 1);
        END

        IF @Descripcion LIKE '%[^a-zA-ZñÑ. ]%'
        BEGIN
			PRINT('La nueva descripción no es valida.');
            RAISERROR('La descripción contiene caracteres no permitidos (solo letras y espacios).', 16, 1);
        END

        -- 3. Validar duplicados EXCLUYENDO el registro actual
        IF EXISTS (SELECT 1 FROM Area_Negocios.Estado_Canon WHERE Descripcion = @Descripcion AND IdEstadoCanon <> @IdEstadoCanon)
        BEGIN
			PRINT('La nueva descripción se encuentra repetida y ya existe.');
            RAISERROR('Ya existe otro Estado de Canon con esa misma descripción.', 16, 1);
        END
		UPDATE Area_Negocios.Estado_Canon
        SET Descripcion = @Descripcion
        WHERE IdEstadoCanon = @IdEstadoCanon;
	END TRY
	BEGIN CATCH
        -- Lanzar Rollback
			RAISERROR('Algo salio mal en la modificación del Estado del Canon', 16, 1);
			RETURN;
	END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--              MODIFICACIÓN DEL PAGO DEL CANON
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Negocios.SP_ModificarPagoCanon
	@IdPagoCanon INT,
	@IdCanon INT,
	@Monto_Abonado DECIMAL(13,3),
    @Fecha_Pago DATE
AS
BEGIN
	BEGIN TRY
		--Busca el Pago Canon verificando que existe en la base de datos
		IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Pago_Canon WHERE IdPagoCanon = @IdPagoCanon)
        BEGIN
            PRINT('Pago de Canon inexistente')
            RAISERROR('PagoCanon Inexistente', 16, 1)
        END
		-- Busca el IdCanon en la tabla de Canon.
        IF NOT EXISTS ( SELECT 1 FROM Area_Negocios.Canon WHERE IdCanon = @IdCanon)
        BEGIN
            PRINT('No Existe el Canon Ingresado')
            RAISERROR('Canon Invalido',16,1)
        END
		-- Valida el Monto ingresado
        IF NOT @Monto_Abonado > 0 OR @Monto_Abonado IS NULL
        BEGIN
            PRINT('El Monto Ingresado no es valido')
            RAISERROR('Monto Invalido',16,1)
        END
        -- Valida la fecha ingresada, comprobando que no sea nula.
		IF @Fecha_Pago IS NULL
		BEGIN
            PRINT('La fecha no puede ser nula')
            RAISERROR('Fecha Invalida', 16, 1)
        END
		--Se completa la operación
	UPDATE Area_Negocios.Pago_Canon SET Monto_Abonado = @Monto_Abonado,
			IdCanon = @IdCanon,
			Fecha_Pago = @Fecha_Pago
			WHERE IdPagoCanon = @IdPagoCanon;
	END TRY
	BEGIN CATCH
        -- Lanzar RETURN
			RAISERROR('Algo salio mal en la modificación del Pago del Canon', 16, 1);
			RETURN;
	END CATCH
	

END
GO

-- //////////////////////////////////////////////////////////////
--              MODIFICACIÓN DE TIPO DE ACTIVIDAD
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Negocios.SP_ModificarTipoActividadConcesion
	@IdTipoActividadConcesion INT,
	@Descripcion varchar(150)
AS
BEGIN
	BEGIN TRY
		--Busca el id verificando que existe en la base de datos
		IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Tipo_Actividad_Concesion WHERE IdTipoActividadConcesion = @IdTipoActividadConcesion)
        BEGIN
            PRINT('Tipo de Actividad inexistente')
            RAISERROR('TipoActividadConcesion Inexistente', 16, 1)
        END

		-- La nueva descripcion debe ser valida
		IF @Descripcion IS  NULL OR @Descripcion = '' OR @Descripcion LIKE '%[^a-zA-ZñÑ. ]%' OR LEN(@Descripcion) > 100
		BEGIN
			PRINT('La nueva descripción no es válida.');
			RAISERROR('Descripcion Invalida', 16, 1);
		END

		--La nueva Descripcion no puede ser una repetida
		IF EXISTS (SELECT 1 FROM Area_Negocios.Tipo_Actividad_Concesion WHERE Descripcion = @Descripcion AND IdTipoActividadConcesion <> @IdTipoActividadConcesion)
		BEGIN
			-- Lanzar el error
			PRINT('La nueva descripción ya se encuentra registrada.');
			RAISERROR('Descripcion Invalida', 16, 1);
		END
		UPDATE Area_Negocios.Tipo_Actividad_Concesion
			SET Descripcion = @Descripcion
			WHERE IdTipoActividadConcesion = @IdTipoActividadConcesion;
	END TRY
	BEGIN CATCH
        -- Lanzar return
			RAISERROR('Algo salio mal en la modificación del Tipo De Actividad de la concesion', 16, 1);
			Return;
	END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--              Apartado 3: Sps de Eliminación
-- //////////////////////////////////////////////////////////////

-- //////////////////////////////////////////////////////////////
--              ELIMINACIÓN DE CANON
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Negocios.SP_EliminarCanon
    @IdCanon INT
AS
BEGIN
    BEGIN TRY

        -- Validamos que la id canon ingresado exista en la Base de Datos
        DECLARE @IdCanonExiste INT;
        SELECT @IdCanonExiste = IdCanon FROM Area_Negocios.Canon WHERE IdCanon = @IdCanon;
        IF @IdCanonExiste IS NULL
        BEGIN
            PRINT('No existe un Canon con ese Identificador')
            RAISERROR('Canon Inexistente',16,1)
        END
        IF EXISTS (SELECT 1 FROM Area_Negocios.Pago_Canon WHERE IdCanon = @IdCanon)
        BEGIN
            PRINT('El canon ingresado tiene pagos asociados')
            RAISERROR('No se puede eliminar el Canon porque posee registros de pagos asociados.', 16, 1);
        END
         DELETE FROM Area_Negocios.Canon WHERE IdCanon = @IdCanon;
    END TRY
    BEGIN CATCH	
            RAISERROR('Algo salio mal en la eliminación del Canon',16,1);
            RETURN;
    END CATCH
   
END
GO
-- //////////////////////////////////////////////////////////////
--              ELIMINACIÓN DE CONCESION
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Negocios.SP_EliminarConcesion
    @IdConcesion INTEGER
AS
BEGIN
	BEGIN TRY

        -- Se verifica que la concesión exista
        IF NOT EXISTS ( SELECT 1 FROM Area_Negocios.Concesion WHERE IdConcesion = @IdConcesion)
        BEGIN
            PRINT('No Existe la concesión ingresada')
            RAISERROR('Concesión Invalida',16,1)
        END
        --Viendo que no hayan canones para esa concesión
        IF EXISTS (SELECT 1 FROM Area_Negocios.Canon WHERE IdConcesion = @IdConcesion)
        BEGIN
            PRINT('La concesión ingresada tiene canones asociados')
            RAISERROR('No se puede eliminar la Concesión porque tiene históricos de cánones vinculados.', 16, 1);
        END

        DELETE FROM Area_Negocios.Concesion WHERE IdConcesion=@IdConcesion
    END TRY
    BEGIN CATCH
        -- Lanzamos return
            RAISERROR('Algo salio mal en la eliminación de la Concesión',16,1);
            Return;
    END CATCH
END
GO

-- //////////////////////////////////////////////////////////////
--              ELIMINACIÓN DE EMPRESA
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Negocios.SP_EliminarEmpresaConcesionaria
    @IdEmpresa INT
AS
BEGIN
    BEGIN TRY
        -- Validamos que la id ingresado exista en la Base de Datos
        --Validamos que la empresa si este actualmente activa
        DECLARE @IdEmpresaExiste INT;
        SELECT @IdEmpresaExiste = IdEmpresa FROM Area_Negocios.Empresa_Concesionaria WHERE IdEmpresa = @IdEmpresa AND Estado = 1;
        IF @IdEmpresaExiste IS NULL
        BEGIN
            PRINT('No existe una Empresa Concesionaria activa con ese Id')
            RAISERROR('Empresa Inexistente',16,1)
        END
        
        UPDATE Area_Negocios.Empresa_Concesionaria SET Estado = 0 WHERE IdEmpresa = @IdEmpresa
    END TRY
    BEGIN CATCH
            RAISERROR('Algo salio mal en la eliminacion de la empresa concesionaria',16,1);
            RETURN;
    END CATCH
    --DELETE FROM Area_Negocios.Empresa_Concesionaria WHERE IdEmpresa = @IdEmpresa;
    
END
GO

-- //////////////////////////////////////////////////////////////
--              ELIMINACIÓN DE ESTADO DE CANON
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Negocios.SP_EliminarEstadoCanon
    @IdEstadoCanon INT
AS
BEGIN
    BEGIN TRY
        -- Validamos que la id ingresado exista en la Base de Datos
        DECLARE @IdEstadoCanonExiste INT;
        SELECT @IdEstadoCanonExiste = IdEstadoCanon FROM Area_Negocios.Estado_Canon WHERE IdEstadoCanon = @IdEstadoCanon;
        IF @IdEstadoCanonExiste IS NULL
        BEGIN
            PRINT('No existe un Estado de Canon con ese Id')
            RAISERROR('EstadoCanon Inexistente',16,1)
        END
        --No puede tener Canones asociados
        IF EXISTS (SELECT 1 FROM Area_Negocios.Canon WHERE IdEstado = @IdEstadoCanon)
        BEGIN
            PRINT('No existe un Estado de Canon con ese Id')
            RAISERROR('No se puede eliminar el Estado de Canon porque está siendo utilizado por registros de la tabla Canon.', 16, 1);
        END

        DELETE FROM Area_Negocios.Estado_Canon WHERE IdEstadoCanon = @IdEstadoCanon;
    END TRY
    BEGIN CATCH
            RAISERROR('Algo salio mal en la eliminacion del Estado de Canon',16,1);
            RETURN;
    END CATCH
    
END
GO

-- //////////////////////////////////////////////////////////////
--              ELIMINACIÓN DE PAGO DE CANON
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Negocios.SP_EliminarPagoCanon
    @IdPagoCanon INT
AS
BEGIN
    BEGIN TRY

        -- Validamos que la id ingresado exista en la Base de Datos
        DECLARE @IdPagoCanonExiste INT;
        SELECT @IdPagoCanonExiste = IdPagoCanon FROM Area_Negocios.Pago_Canon WHERE IdPagoCanon = @IdPagoCanon;
        IF @IdPagoCanonExiste IS NULL
        BEGIN
            PRINT('No existe un Pago de Canon con ese Id')
            RAISERROR('PagoCanon Inexistente',16,1)
        END
         DELETE FROM Area_Negocios.Pago_Canon WHERE IdPagoCanon = @IdPagoCanon;
    END TRY
    BEGIN CATCH
            RAISERROR('Algo salio mal en la eliminación del Pago de Canon',16,1);
            RETURN;
    END CATCH
   
END
GO
-- //////////////////////////////////////////////////////////////
--              ELIMINACIÓN DE TIPO DE ACTIVIDAD 
-- //////////////////////////////////////////////////////////////


CREATE OR ALTER PROCEDURE Area_Negocios.SP_EliminarTipoActividadConcesion
    @IdTipoActividadConcesion INT
AS
BEGIN
    BEGIN TRY
        -- Validamos que la id ingresado exista en la Base de Datos
        DECLARE @IdTipoActividadConcesionExiste INT;
        SELECT @IdTipoActividadConcesionExiste = IdTipoActividadConcesion FROM Area_Negocios.Tipo_Actividad_Concesion WHERE IdTipoActividadConcesion = @IdTipoActividadConcesion;
        IF @IdTipoActividadConcesionExiste IS NULL
        BEGIN
            PRINT('No existe un Tipo de Actividad con ese Id')
            RAISERROR('TipoActividadConcesion Inexistente',16,1)
        END
        --Reviso que la la actividad no se asocie a concesiones
        IF EXISTS (SELECT 1 FROM Area_Negocios.Concesion WHERE IdTipoActividadConcesion = @IdTipoActividadConcesion)
        BEGIN
            PRINT('No se puede eliminar poque existen concesiones asignadas a esta actividad.')
            RAISERROR('No se puede eliminar el Tipo de Actividad debido a que existen concesiones vigentes que dependen de él.', 16, 1);
        END
        DELETE FROM Area_Negocios.Tipo_Actividad_Concesion WHERE IdTipoActividadConcesion = @IdTipoActividadConcesion;
    END TRY
    BEGIN CATCH
            RAISERROR('Algo salio mal en la eliminación del Tipo de Actividad Concesion',16,1);
            RETURN;
    END CATCH
    
END
GO

---------------------------------------------------------------
--              OBTENER FERIADOS DESDE API                   --
---------------------------------------------------------------
/*
#Descripción: Este script se encarga de consultar a una API externa para obtener los feriados nacionales
y validar si una fecha dada es un feriado o no. Para esto se utiliza la API de argentinadatos.com, que devuelve
los feriados nacionales de un año determinado.

Documentación de la API: https://argentinadatos.com/docs/operations/get-feriados

Devuelve los feriados del año indicado (o del año actual si no se especifica).
GET /v1/feriados/{año}
Parámetros

Año de consulta
Tipo integer Requerido
Ejemplo 2026
Mínimo 2016
Máximo 2026

Formato de respuesta

[
    {
        "fecha": "string",  
        "tipo": "string",  
        "nombre": "string"
    }
]
*/

CREATE OR ALTER PROCEDURE Area_Comercial.SP_ObtenerFeriadosDesdeAPI 
    @Fecha DATE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION
            PRINT 'Obteniendo feriados nacionales desde la API de argentinadatos.com...'        

            DECLARE @Object INT
            DECLARE @json TABLE(respuesta NVARCHAR(MAX))	--Usamos una tabla variable
            DECLARE @respuesta NVARCHAR(MAX)
            --Concatenamos la URL con el año de la fecha que recibimos por parámetro, para obtener los feriados de ese año.
            DECLARE @url NVARCHAR(200) = 'https://api.argentinadatos.com/v1/feriados/' + CAST(YEAR(@Fecha) AS CHAR(4))

            EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT	--Creamos una instancia del objeto OLE, que nos permite hacer los llamados.
            EXEC sp_OAMethod @Object, 'OPEN', NULL, 'GET', @url, 'FALSE' --Definimos algunas propiedades del objeto para hacer una llamada HTTP Get.
            EXEC sp_OAMethod @Object, 'SEND' 
            EXEC sp_OAMethod @Object, 'RESPONSETEXT', @respuesta OUTPUT --Guardamos la respuesta de la API en una variable.

            PRINT 'Feriados obtenidos desde la API. Parseando respuesta...'

            INSERT @json 
            EXEC sp_OAGetProperty @Object, 'RESPONSETEXT' --Obtenemos el valor de la propiedad 'RESPONSETEXT' del objeto OLE luego de realizar la consulta.

            DECLARE @datos NVARCHAR(MAX) = (SELECT respuesta FROM @json)
            
            -- Insertamos en la tabla de feriados nacionales los feriados obtenidos desde la API para el año de la fecha que recibimos por parámetro.  
            INSERT INTO Area_Comercial.Feriado_Nacional (Fecha, Tipo, Descripcion)
            SELECT Fecha, Tipo, Nombre FROM OPENJSON(@datos)
            WITH
            (
                [Fecha] date '$.fecha',
                [Tipo] nvarchar(40) '$.tipo',
                [Nombre] nvarchar(30) '$.nombre'
            )
            PRINT 'Feriados nacionales insertados en la base de datos correctamente.'
        COMMIT TRANSACTION;      
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
        BEGIN	
            RAISERROR('Algo salió mal al obtener los feriados nacionales desde la API de argentinadatos.com', 16, 1);
            RETURN;
        END
    END CATCH
END
GO


---------------------------------------------------------------
--              VALIDAR FERIADO                              --
---------------------------------------------------------------
/*
#Descripción: Este script se encarga de consultar a una API externa para obtener los feriados nacionales
y validar si una fecha dada es un feriado o no. Para esto se utiliza la API de argentinadatos.com, que devuelve
los feriados nacionales de un año determinado.

Documentación de la API: https://argentinadatos.com/docs/operations/get-feriados

Devuelve los feriados del año indicado (o del año actual si no se especifica).
GET /v1/feriados/{año}
Parámetros

Año de consulta
Tipo integer Requerido
Ejemplo 2026
Mínimo 2016
Máximo 2026

Formato de respuesta

[
    {
        "fecha": "string",  
        "tipo": "string",  
        "nombre": "string"
    }
]
*/

GO

CREATE OR ALTER PROCEDURE Area_Comercial.Sp_ValidarFeriado
    @Fecha DATE,
    @EsFeriado BIT OUTPUT
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        -- Primero revisamos la tabla de feriados nacionales que tenemos cargada en la DB para chequear que estén cargados los feriados del año de la fecha que recibimos por parámetro. Si no hay ningún
        -- feriado cargado para ese año, consultamos a la API y cargamos los feriados obtenidos en la tabla de la DB para futuras consultas.
        IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Feriado_Nacional WHERE YEAR(Fecha) = YEAR(@Fecha))
        BEGIN
            EXEC Area_Comercial.SP_ObtenerFeriadosDesdeAPI @Fecha;
        END
        ELSE
        BEGIN
            -- Si ya tenemos los feriados cargados para ese año, validamos si la fecha que recibimos por parámetro es un feriado o no.
            IF EXISTS (SELECT 1 FROM Area_Comercial.Feriado_Nacional WHERE Fecha = @Fecha)
                SET @EsFeriado = 1
            ELSE
                SET @EsFeriado = 0
        END
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
        BEGIN	
            RAISERROR('Algo salió mal al obtener los feriados nacionales desde la API de argentinadatos.com', 16, 1);
            RETURN;
        END
    END CATCH
END
go

---------------------------------------------------------------
--              REGISTRAR VENTA DE ENTRADAS                  --
---------------------------------------------------------------

/*
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para
generar un registro en la tabla de ventas que se asocie con un detalle de venta y una contratación. 

	-- Crea cada entrada y calcula el subtotal en base a una nueva tabla que tiene la asignación de precios entre cada parque y tipo de visitante (Area_Comercial.Precio_Parque_Tipo_Visitante)
	-- Crea un detalle y lo asocia con esas entradas
	-- También recibe un tipo de actividad, así que asocia una contratación de actividad con la venta (se tiene que fijar el tema de los cupos de cada una también)
	-- Suma los subtotales de las entradas y de las contrataciones, setea un total en la venta y la registra
	-- Se usa la API https://api.argentinadatos.com/v1/feriados para validar que la fecha de la venta no sea un feriado nacional, y en caso de serlo, aplicar un descuento del 10% sobre el total de la venta.
*/

CREATE OR ALTER PROCEDURE Area_Comercial.Sp_RegistrarVentaEntradas
	@Parque VARCHAR(80),
    @CantidadEntradas INT,
    @TipoVisitante VARCHAR(30),
    @Actividad VARCHAR(80),
	@Fecha DATE,
	@IdPuntoDeVenta INT,
	@FormaDePago VARCHAR(30)
AS
BEGIN
    BEGIN TRY
	BEGIN TRANSACTION;
        SET NOCOUNT ON;

		DECLARE @IdParque INT;
		DECLARE @IdActividadIngresada INT;
		DECLARE @IdFormaDePago INT;
		DECLARE @SubTotal DECIMAL(14,4) = 0.0;
		DECLARE @Total DECIMAL(14,4) = 0.0;
		DECLARE @IdTipoVisitante INT;

		-- ================================================================================================================
		--											VALIDACIONES
		-- ================================================================================================================

		--El parque debe estar cargado en la DB
		SELECT @IdParque = IdParque FROM Area_Infraestructura.Parque WHERE Nombre = @Parque;
		IF @IdParque IS NULL
        BEGIN
            RAISERROR('Parque inexistente', 16, 1)
        END

		--La cantidad de entradas debe ser mayor a cero
		IF @CantidadEntradas <= 0
		BEGIN
			RAISERROR('La cantidad de entradas debe ser mayor a cero', 16, 1)
		END

		--El tipo de visitante debe estar cargado en la DB
		SELECT @IdTipoVisitante = IdTipoVisitante FROM Area_Comercial.Tipo_Visitante WHERE Descripcion = @TipoVisitante;
		IF @IdTipoVisitante IS NULL
        BEGIN
            RAISERROR('Tipo de visitante inexistente', 16, 1)
        END

		-- El parque debe tener tarifas cargadas para el tipo de visitante seleccionado
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Precio_Parque_Tipo_Visitante WHERE IdParque = @IdParque AND IdTipoVisitante = (SELECT IdTipoVisitante FROM Area_Comercial.Tipo_Visitante WHERE Descripcion = @TipoVisitante))
		BEGIN
			RAISERROR('No hay tarifas cargadas para el tipo de visitante seleccionado en el parque especificado', 16, 1)
		END

		--El punto de venta debe estar cargado en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Punto_De_Venta WHERE IdPuntoDeVenta = @IdPuntoDeVenta)
        BEGIN
            RAISERROR('Punto de venta inexistente', 16, 1)
        END

		--La forma de pago debe estar cargada en la DB
		SELECT @IdFormaDePago = IdFormaDePago FROM Area_Comercial.Forma_De_Pago WHERE Descripcion = @FormaDePago;
		IF @IdFormaDePago IS NULL
        BEGIN
            RAISERROR('Forma de pago inexistente', 16, 1)
        END

		--El campo fecha debe tener un valor
		IF @Fecha IS NULL
		BEGIN
            RAISERROR('La fecha no puede ser nula', 16, 1)
        END

		--La actividad (si se ingresó, porque puede ser null) debe estar cargada en la DB
		IF @Actividad IS NOT NULL
		BEGIN
			SELECT @IdActividadIngresada = IdActividad FROM Area_Excursiones.Actividad WHERE Nombre = @Actividad
			AND IdParque = @IdParque
			IF @IdActividadIngresada IS NULL
			BEGIN
				RAISERROR('Actividad inexistente', 16, 1)
			END
			
			-- La actividad debe estar vinculada al parque seleccionado
			IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Actividad WHERE IdActividad = @IdActividadIngresada AND IdParque = @IdParque)
			BEGIN
				RAISERROR('La actividad seleccionada no está disponible para el parque seleccionado', 16, 1)
			END

			--La actividad debe tener cupos disponibles para la fecha de la venta
			DECLARE @CuposDisponibles INT
			DECLARE @CupoMaximoActividad INT
			DECLARE @CantidadContratacionesActividad INT

			SET @CupoMaximoActividad = (SELECT Cupo_maximo FROM Area_Excursiones.Actividad WHERE IdActividad = @IdActividadIngresada)

			SELECT @CantidadContratacionesActividad = COUNT(*) FROM Area_Excursiones.Contratacion_Actividad CA
			INNER JOIN Area_Excursiones.Actividad A ON CA.IdActividad = A.IdActividad
			WHERE CA.IdActividad = @IdActividadIngresada AND CA.Fecha_Contratacion = @Fecha

			SET @CuposDisponibles = @CupoMaximoActividad - @CantidadContratacionesActividad

			IF @CuposDisponibles <= 0
			BEGIN
				RAISERROR('No hay cupos disponibles para la actividad seleccionada en la fecha indicada', 16, 1)
			END
		END

		-- ================================================================================================================
		--							CÁLCULO DE PRECIOS, DESCUENTOS, SUBTOTALES Y TOTALES
		-- ================================================================================================================

		DECLARE @PrecioEntrada DECIMAL(14,4)
		DECLARE @PorcentajeDescuento DECIMAL(5,2)
		SELECT @PrecioEntrada = Precio FROM Area_Comercial.Precio_Parque_Tipo_Visitante WHERE IdParque = @IdParque AND IdTipoVisitante = @IdTipoVisitante;	
		SET @Subtotal = @CantidadEntradas * @PrecioEntrada;

		--Validamos si la fecha es un feriado nacional, y en caso de serlo, verificamos
		--si existe un descuento aplicable sobre el total de la venta para ese parque
		DECLARE @EsFeriado BIT
		EXEC Area_Comercial.Sp_ValidarFeriado @Fecha = @Fecha, @EsFeriado = @EsFeriado OUTPUT
		IF @EsFeriado = 1
		BEGIN
			SELECT @PorcentajeDescuento = Porcentaje FROM Area_Comercial.Descuento_Parque WHERE IdParque = @IdParque AND (Descripcion LIKE '%feriado%' OR Descripcion LIKE '%Feriado%')
			SET @Subtotal = @Subtotal - (@Subtotal * @PorcentajeDescuento)
			PRINT('La fecha corresponde con un feriado, se aplicó un descuento del ' + CAST(@PorcentajeDescuento AS VARCHAR(10)) + '%')
		END

		SET @Total = @Subtotal;

		--Obtencion del precio de la actividad
		IF @Actividad IS NOT NULL
			BEGIN
			DECLARE @PrecioActividad DECIMAL(14,4)
			SELECT @PrecioActividad = Costo FROM Area_Excursiones.Actividad WHERE Nombre = @Actividad
			IF @PrecioActividad IS NULL
			BEGIN
				RAISERROR('Error al obtener el precio de la actividad', 16, 1)
			END
			SET @Total = @Total + (@PrecioActividad * @CantidadEntradas);
		END
		
		-- ================================================================================================================
		--				REGISTRO DE LA VENTA, DETALLE DE VENTA, ENTRADAS Y CONTRATACIÓN DE ACTIVIDAD
		-- ================================================================================================================

		--Registramos la venta
		INSERT INTO Area_Comercial.Venta(IdPuntoDeVenta, IdParque, IdFormaDePago, Fecha, Total) VALUES
		(@IdPuntoDeVenta, @IdParque, @IdFormaDePago, @Fecha, @Total);
		DECLARE @IdNuevaVenta INT
		SET @IdNuevaVenta = SCOPE_IDENTITY()

		--Creamos el detalle de venta de entradas y las entradas asociadas a ese detalle
		DECLARE @CantidadEntradasContador INT;
		SET @CantidadEntradasContador = @CantidadEntradas;

		while @CantidadEntradasContador > 0
		BEGIN
			DECLARE @IdEntrada INT
			INSERT INTO Area_Comercial.Entrada(IdParque, IdTipoVisitante, Precio, Fecha_Acceso) VALUES
			(@IdParque, @IdTipoVisitante, @PrecioEntrada, @Fecha);
			SET @IdEntrada = SCOPE_IDENTITY()

			EXEC Area_Comercial.SP_CrearDetalleVentaEntrada @IdVenta = @IdNuevaVenta, @IdEntrada = @IdEntrada, @Cantidad = 1, @Subtotal = @PrecioEntrada

			SET @CantidadEntradasContador = @CantidadEntradasContador - 1
		END

		--Si la actividad fue ingresada, creamos la contratación y la asociamos con la venta
		IF @Actividad IS NOT NULL
		BEGIN
			SET @CantidadEntradasContador = @CantidadEntradas;
			WHILE @CantidadEntradasContador > 0
			BEGIN
				EXEC Area_Excursiones.Sp_CrearContratacion_Actividad @IdVenta = @IdNuevaVenta, @IdActividad = @IdActividadIngresada,  @Monto = @PrecioActividad, @FechaContratacion = @Fecha  
				SET @CantidadEntradasContador = @CantidadEntradasContador - 1
			END
		END
	COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			DECLARE @ErrorMessage VARCHAR(255) = ERROR_MESSAGE();	
			RAISERROR(@ErrorMessage, 16, 1);
			ROLLBACK TRANSACTION;
			RETURN;
		END
	END CATCH
	RETURN @IdNuevaVenta
END
GO

---------------------------------------------------------------
--              REGISTRAR PAGO DE CANON                     --
---------------------------------------------------------------

/*
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para registrar el pago de un 
canon, actualizar su estado y generar el próximo canon a pagar.   

-- Determinar el estado posterior al pago basado en las fechas
-- Si el pago se realiza antes o en la fecha de vencimiento, el estado será "Saldado en Término"
-- Si el pago se realiza después de la fecha de vencimiento, el estado será "Saldado con Atraso"
-- Validar que el monto abonado sea suficiente para cubrir el canon

*/

CREATE OR ALTER PROCEDURE Area_Negocios.SP_Registrar_Pago_Canon
    @IdCanon INT,
    @IdConcesion INT,
    @Monto_Abonado DECIMAL(13,3),
    @Fecha_Pago DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Obtener la info del canon que se intenta pagar
    DECLARE @IdEstadoActual INT, @Fecha_Vencimiento DATE, @Monto_Mensual DECIMAL(13,3);
    
    SELECT @IdEstadoActual = IdEstado, @Fecha_Vencimiento = Fecha_Vencimiento, @Monto_Mensual = Monto_Mensual
    FROM Area_Negocios.Canon
    WHERE IdCanon = @IdCanon AND IdConcesion = @IdConcesion;

    IF @IdEstadoActual IS NULL
    BEGIN
        RAISERROR('El Canon especificado no existe.', 16, 1);
        RETURN;
    END

    -- Validar que no esté exento o ya cancelado
    DECLARE @IdExento INT = (SELECT IdEstadoCanon FROM Area_Negocios.Estado_Canon WHERE Descripcion = 'Exento');
    DECLARE @IdSaldadoTermino INT = (SELECT IdEstadoCanon FROM Area_Negocios.Estado_Canon WHERE Descripcion = 'Saldado en Término');
    DECLARE @IdSaldadoAtraso INT = (SELECT IdEstadoCanon FROM Area_Negocios.Estado_Canon WHERE Descripcion = 'Saldado con Atraso');

    IF @IdEstadoActual = @IdExento
    BEGIN
        RAISERROR('El canon especificado está exento. No requiere pago.', 16, 1);
        RETURN;
    END

    IF @IdEstadoActual IN (@IdSaldadoTermino, @IdSaldadoAtraso)
    BEGIN
        RAISERROR('El canon especificado ya se encuentra saldado.', 16, 1);
        RETURN;
    END

    IF @Monto_Abonado < @Monto_Mensual
    BEGIN
        RAISERROR('El monto abonado no es suficiente para cubrir el canon.', 16, 1);
        RETURN;
    END

    DECLARE @NuevoEstado INT;
    IF @Fecha_Pago <= @Fecha_Vencimiento
        SET @NuevoEstado = @IdSaldadoTermino;
    ELSE
        SET @NuevoEstado = @IdSaldadoAtraso;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Insertar el recibo en la tabla de Pagos
        INSERT INTO Area_Negocios.Pago_Canon (IdCanon, Monto_Abonado, Fecha_Pago)
        VALUES (@IdCanon, @Monto_Abonado, @Fecha_Pago);

        -- 2. Actualizar el Canon pagado para cerrarlo
        UPDATE Area_Negocios.Canon
        SET IdEstado = @NuevoEstado
        WHERE IdCanon = @IdCanon;

        -- 3. Emitir el nuevo Canon para la próxima cuota (30 días después del vencimiento original)
        DECLARE @IdVigente INT = (SELECT IdEstadoCanon FROM Area_Negocios.Estado_Canon WHERE Descripcion = 'Vigente');
        
        INSERT INTO Area_Negocios.Canon (IdConcesion, IdEstado, Monto_Mensual, Fecha_Vencimiento)
        VALUES (
            @IdConcesion, 
            @IdVigente, 
            @Monto_Mensual,
            DATEADD(DAY, 30, @Fecha_Vencimiento)
        );

        COMMIT TRANSACTION;
        PRINT 'Pago registrado correctamente. Nuevo canon emitido.';

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR (@ErrorMsg, 16, 1);
    END CATCH
END
GO

---------------------------------------------------------------
--                  IMPORTACIÓN DE DATOS                     --
---------------------------------------------------------------

-- //////////////////////////////////////////////////////////////
--              IMPORTACION DE DATOS DE EMPRESAS
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Negocios.Sp_ImportarDatosEmpresas
    @RutaArchivoEmpresas VARCHAR(255),
    @CrearConcesiones BIT = 0 -- Parámetro opcional para decidir si se crean concesiones automáticamente
AS
BEGIN
    BEGIN TRY
    BEGIN TRANSACTION;
    SET NOCOUNT ON;
      
        -- Verificar que el archivo existe
        DECLARE @ExisteArchivo INT;
        EXEC master.dbo.xp_fileexist @RutaArchivoEmpresas, @ExisteArchivo OUTPUT;
        IF @ExisteArchivo = 0
        BEGIN
            RAISERROR('El archivo no existe o no es accesible.', 16, 1);
            RETURN;
        END

        IF OBJECT_ID('tempdb..#Staging_Organizaciones') IS NULL
        BEGIN
            CREATE TABLE #Staging_Organizaciones (
                IdStaging INT IDENTITY(1,1) PRIMARY KEY,
                Organizacion VARCHAR(255) COLLATE Latin1_General_CI_AS,
                Rubro VARCHAR(255) COLLATE Latin1_General_CI_AS,
                Provincia VARCHAR(80) COLLATE Latin1_General_CI_AS,
                Fecha_Distincion DATE
            );
        END

        -- Importar los datos del archivo CSV a la tabla temporal de staging
        IF OBJECT_ID('tempdb..#Staging_Raw_CSV') IS NULL
        BEGIN
            -- Adaptado a las 14 columnas del CSV
            CREATE TABLE #Staging_Raw_CSV (
                organizacion VARCHAR(255), 
                rubro VARCHAR(255),
                subrubro VARCHAR(255),
                calle VARCHAR(255),
                numero VARCHAR(50),
                pais VARCHAR(50),
                provincia VARCHAR(80),
                ciudad VARCHAR(80),
                telefono VARCHAR(50),
                facebook VARCHAR(255),
                web VARCHAR(255),
                programa VARCHAR(255),
                fecha_distincion VARCHAR(50),
                fecha_revalidacion VARCHAR(50)
            );
        END

        DECLARE @Sql NVARCHAR(MAX);
        SET @Sql = N'
        BULK INSERT #Staging_Raw_CSV
        FROM ''' + @RutaArchivoEmpresas + '''
        WITH (FORMAT = ''CSV'', FIELDQUOTE = ''"'', FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0a'', FIRSTROW = 2, CODEPAGE = ''65001'');';

        EXEC sp_executesql @sql;

        -- Insertar los datos desde la tabla de staging a la tabla global de staging, realizando las transformaciones necesarias
        INSERT INTO #Staging_Organizaciones (Organizacion, Rubro, Provincia, Fecha_Distincion)
        SELECT 
            organizacion,
            rubro,
            provincia,
            TRY_CAST(fecha_distincion AS DATE)
        FROM #Staging_Raw_CSV
        WHERE organizacion IS NOT NULL AND organizacion <> '';
        -- select * from #Staging_Organizaciones;

        -- 1. Insertar Estados de Canon (si no existen)
        IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Estado_Canon where Descripcion IN ('Vigente', 'Adeudado', 'Saldado en Término', 'Saldado con Atraso', 'Exento', 'Extinguido'))
        BEGIN
            INSERT INTO Area_Negocios.Estado_Canon (Descripcion) 
            VALUES ('Vigente'), ('Adeudado'), ('Saldado en Término'), ('Saldado con Atraso'), ('Exento'), ('Extinguido');
        END

        -- 2. Insertar o actualizar Empresas Concesionarias
        MERGE Area_Negocios.Empresa_Concesionaria AS Target
        USING (SELECT DISTINCT Organizacion FROM #Staging_Organizaciones WHERE Organizacion IS NOT NULL AND Organizacion <> '') AS Source
        ON Target.Nombre = Source.Organizacion
        WHEN MATCHED THEN
            UPDATE SET Nombre = Source.Organizacion
        WHEN NOT MATCHED THEN
            INSERT (Nombre) VALUES (Source.Organizacion);

        -- 3. Insertar o actualizar Tipos de Actividad
        MERGE Area_Negocios.Tipo_Actividad_Concesion AS Target
        USING(
            SELECT DISTINCT Rubro 
            FROM #Staging_Organizaciones s
            WHERE NOT EXISTS (SELECT 1 FROM Area_Negocios.Tipo_Actividad_Concesion t WHERE t.Descripcion = s.Rubro)
        ) AS Source
        ON Target.Descripcion = Source.Rubro
        WHEN MATCHED THEN
            UPDATE SET Descripcion = Source.Rubro
        WHEN NOT MATCHED THEN
            INSERT (Descripcion) VALUES (Source.Rubro);

        -- Generar las Concesiones solo si se indica
        IF @CrearConcesiones = 1
        BEGIN
            -- 4. Crear Concesiones para cada Empresa Concesionaria existente, asignando un tipo de actividad aleatorio y un parque aleatorio de la provincia
            -- de la empresa en el csv
            DECLARE @MinId INT = (select MIN(IdEmpresa) FROM Area_Negocios.Empresa_Concesionaria);
            DECLARE @MaxId INT = (select MAX(IdEmpresa) FROM Area_Negocios.Empresa_Concesionaria);
            WHILE @MinId <= @MaxId
            BEGIN

                DECLARE @EmpresaNombre VARCHAR(255) = (select TOP 1 Nombre FROM Area_Negocios.Empresa_Concesionaria WHERE IdEmpresa = @MinId);
                DECLARE @RandomTipoAct INT = (SELECT TOP 1 IdTipoActividadConcesion FROM Area_Negocios.Tipo_Actividad_Concesion ORDER BY NEWID());
                DECLARE @RandomParque INT = 
                (SELECT TOP 1 IdParque FROM Area_Infraestructura.Parque 
                where IdProvincia = 
                    (SELECT TOP 1 IdProvincia FROM Area_Infraestructura.Provincia 
                    WHERE Nombre =
                     (SELECT TOP 1 Provincia FROM #Staging_Organizaciones 
                        WHERE Organizacion = @EmpresaNombre
                            --(SELECT TOP 1 Nombre FROM Area_Negocios.Empresa_Concesionaria WHERE Nombre = @EmpresaNombre)
                        )
                    )
                    ORDER BY NEWID());


                IF @RandomParque IS NULL
                BEGIN
                    SET @RandomParque = (SELECT TOP 1 IdParque FROM Area_Infraestructura.Parque ORDER BY NEWID());
                END

                DECLARE @FechaIni DATE = DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365, GETDATE());
                DECLARE @FechaFin DATE = DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 365 + 365, GETDATE());
                
                IF @EmpresaNombre IS NOT NULL
                BEGIN
                    EXECUTE Area_Negocios.SP_CrearConcesion 
                    @IdTipoActividadConcesion = @RandomTipoAct, 
                    @IdEmpresa = @MinId, 
                    @IdParque = @RandomParque, 
                    @Fecha_Inicio = @FechaIni, 
                    @Fecha_Fin = @FechaFin;
                END

                SET @MinId = @MinId + 1;
            END

            -- 5. Generar el Primer Canon de cada Concesión recién creada
            DECLARE @IdVigente INT = (SELECT IdEstadoCanon FROM Area_Negocios.Estado_Canon WHERE Descripcion = 'Vigente');
            
            INSERT INTO Area_Negocios.Canon (IdConcesion, IdEstado, Monto_Mensual, Fecha_Vencimiento)
            SELECT 
                c.IdConcesion,
                @IdVigente,
                CASE 
                    -- Rangos aleatorios según rubro
                    WHEN tac.Descripcion LIKE '%Alojamiento%' THEN 300000 + (ABS(CHECKSUM(NEWID())) % 200000)
                    WHEN tac.Descripcion LIKE '%Gastronomía%' THEN 150000 + (ABS(CHECKSUM(NEWID())) % 100000)
                    ELSE 50000 + (ABS(CHECKSUM(NEWID())) % 50000)
                END,
                DATEADD(DAY, 7 + (ABS(CHECKSUM(NEWID())) % 24), GETDATE())
            FROM Area_Negocios.Concesion c
            INNER JOIN Area_Negocios.Tipo_Actividad_Concesion tac ON c.IdTipoActividadConcesion = tac.IdTipoActividadConcesion
            WHERE NOT EXISTS (SELECT 1 FROM Area_Negocios.Canon ca WHERE ca.IdConcesion = c.IdConcesion);
        END

        COMMIT TRANSACTION;
        
        IF @CrearConcesiones = 1
            PRINT 'Negocios y concesiones creados con éxito.';
        ELSE
            PRINT 'Negocios creados con éxito.';

        DROP TABLE #Staging_Organizaciones;
        DROP TABLE #Staging_Raw_CSV;
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
        BEGIN
            DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
            DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
            DECLARE @ErrorState INT = ERROR_STATE();
            RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
            ROLLBACK TRANSACTION;
            DROP TABLE IF EXISTS #Staging_Organizaciones;
            DROP TABLE IF EXISTS #Staging_Raw_CSV;
            RETURN;
        END
    END CATCH
END
go

-- //////////////////////////////////////////////////////////////
--              IMPORTACIÓN DE DATOS DE PARQUES
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_ImportarDatosParquesCSVTemporal
    @RutaArchivo VARCHAR(500)
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        IF OBJECT_ID('tempdb..##Staging_Parques') IS NULL
        BEGIN
            RAISERROR('La tabla temporal de staging no existe. Estas llamando a este procedimiento sin haber ejecutado primero el procedimiento principal de importación?', 16, 1);
            RETURN;
        END

        -- Paso 1: Crear una tabla Raw para absorber las 15 columnas del CSV
        IF OBJECT_ID('tempdb..#Staging_Raw_CSV') IS NULL
        BEGIN 
            CREATE TABLE #Staging_Raw_CSV (
                [Provincia] VARCHAR(255),
                [Área Protegida] VARCHAR(255),
                [Año de Creacion] VARCHAR(50),
                [Región] VARCHAR(255),
                [Superficie (HA)] VARCHAR(50), -- Lo importamos como VARCHAR para luego convertirlo a DECIMAL, así evitamos errores por formatos numéricos raros o celdas vacías
                [Latitud] VARCHAR(50),
                [Longitud] VARCHAR(50),
                [Instrumento de creación] VARCHAR(500),
                [Ecorregiones] VARCHAR(500),
                [Cat. internacional] VARCHAR(255),
                [Especies registradas] VARCHAR(50),
                [Animales] VARCHAR(50),
                [Bacterias] VARCHAR(50),
                [Hongos] VARCHAR(50),
                [Plantas] VARCHAR(50)
            );
        END

        -- Paso 2: Leer el archivo CSV y volcarlo en la tabla Raw
        DECLARE @sql NVARCHAR(MAX);
        SET @sql = N'
        BULK INSERT #Staging_Raw_CSV
        FROM ''' + @RutaArchivo + '''
        WITH (
            FORMAT = ''CSV'',            -- Interpreta correctamente los textos entre comillas dobles
            FIELDQUOTE = ''"'',
            FIELDTERMINATOR = '','',     -- Separador de columnas
            ROWTERMINATOR = ''\n'',      -- Separador de filas
            FIRSTROW = 3,              -- Saltea el título general y los encabezados de las columnas
            CODEPAGE = ''65001''         -- Usa UTF-8 para que acentos y eñes (ej. "Región") se lean perfecto
        );'

        EXEC sp_executesql @sql;

        -- Paso 3: Pasar solo los datos que nos importan a la tabla Staging oficial (con su formato correcto)
        INSERT INTO ##Staging_Parques (Provincia, Parque, Region, Superficie)
        SELECT 
            Provincia,
            [Área Protegida],
            [Región],
            -- Usamos TRY_CAST por si alguna superficie viene vacía o con un guión '-' en el CSV
            TRY_CAST([Superficie (HA)] AS DECIMAL(14,4)) 
        FROM #Staging_Raw_CSV
        WHERE [Área Protegida] IS NOT NULL AND [Área Protegida] <> '' 
        AND (
                [Área Protegida] LIKE '%Parque%' 
                OR 
                [Área Protegida] LIKE '%Reserva%' 
                OR 
                [Área Protegida] LIKE '%Monumento%'
        );

        -- Paso 4: Limpieza de la tabla Raw temporal
        DROP TABLE #Staging_Raw_CSV;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
    DROP TABLE IF EXISTS #Staging_Raw_CSV; -- Aseguramos eliminar la tabla raw si quedó por algún error
END
go

CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_ImportarDatosParquesXMLTemporal
    @RutaArchivo VARCHAR(500)
AS
BEGIN
    BEGIN TRY

        SET NOCOUNT ON;
/*         IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'U' AND name = 'Staging_Raw_CSV')
        BEGIN
            RAISERROR('El archivo no existe o no es accesible.', 16, 1);
            RETURN;
        END */
        IF OBJECT_ID('tempdb..##Staging_Parques') IS NULL
        BEGIN
            PRINT 'La tabla temporal de staging no existe. Estas llamando a este procedimiento sin haber ejecutado primero el procedimiento principal de importación?';
            RETURN;
        END

        DECLARE @sql NVARCHAR(MAX);
        SET @sql = N'
        DECLARE @XmlData XML;

        -- 1. Cargamos el archivo físico a una variable XML en memoria
        SELECT @XmlData = CAST(BulkColumn AS XML)
        FROM OPENROWSET(BULK ''' + @RutaArchivo + ''', SINGLE_BLOB) AS Archivo;

        -- 2. Declaramos el "Namespace" oficial de Excel (OpenXML) para poder leer sus nodos
        WITH XMLNAMESPACES (''http://schemas.openxmlformats.org/spreadsheetml/2006/main'' AS ns)

        -- 3. Extraemos e insertamos los datos navegando por el árbol XML
        INSERT INTO Area_Infraestructura.##Staging_Parques (Provincia, Parque, Region, Superficie)
        SELECT 
            -- Leemos el texto dentro de <is><t>
            Pref.value(''(ns:c[substring(@r, 1, 1)="A"]/ns:is/ns:t)[1]'', ''VARCHAR(80)'') AS Provincia,
            Pref.value(''(ns:c[substring(@r, 1, 1)="B"]/ns:is/ns:t)[1]'', ''VARCHAR(80)'') AS Area_Protegida,
            Pref.value(''(ns:c[substring(@r, 1, 1)="D"]/ns:is/ns:t)[1]'', ''VARCHAR(80)'') AS Region,
            -- Como es numérico, Excel lo guarda como <v>
            Pref.value(''(ns:c[substring(@r, 1, 1)="E"]/ns:v)[1]'', ''DECIMAL(14,4)'') AS Superficie

        FROM @XmlData.nodes(''//ns:sheetData/ns:row'') AS T(Pref) -- Iteramos por cada fila (<row>) del Excel
        WHERE 
            Pref.value(''(@r)[1]'', ''INT'') >= 3 -- Empezamos en la fila 3 (saltando el súper-título y los encabezados)
            AND (
            Pref.value(''(ns:c[substring(@r, 1, 1)="B"]/ns:is/ns:t)[1]'', ''VARCHAR(80)'') LIKE ''%Parque%'' 
            OR 
            Pref.value(''(ns:c[substring(@r, 1, 1)="B"]/ns:is/ns:t)[1]'', ''VARCHAR(80)'') LIKE ''%Reserva%''
            OR 
            Pref.value(''(ns:c[substring(@r, 1, 1)="B"]/ns:is/ns:t)[1]'', ''VARCHAR(80)'') LIKE ''%Monumento%''
            )
        ORDER BY Pref.value(''(ns:c[substring(@r, 1, 1)="B"]/ns:is/ns:t)[1]'', ''VARCHAR(80)'');';
        
        EXEC sp_executesql @sql;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_ImportarDatosParques
    @RutaArchivoParques VARCHAR(500)
AS
BEGIN

    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..##Staging_Parques') IS NULL
    BEGIN 
        CREATE TABLE ##Staging_Parques (
            IdStaging INT IDENTITY(1,1) PRIMARY KEY,
            Provincia VARCHAR(80) COLLATE Latin1_General_CI_AS,
            Parque VARCHAR(80) COLLATE Latin1_General_CI_AS,
            Region VARCHAR(80) COLLATE Latin1_General_CI_AS,
            Superficie DECIMAL(14,4)
        )
    END
    BEGIN TRY

        -- Verificar que el archivo existe
        DECLARE @ExisteArchivo INT;
        EXEC master.dbo.xp_fileexist @RutaArchivoParques, @ExisteArchivo OUTPUT;
        IF @ExisteArchivo = 0
        BEGIN
            RAISERROR('El archivo no existe o no es accesible.', 16, 1);
            RETURN;
        END

        -- Dependiendo si es csv o xml, ejecutamos uno u otro procedimiento de importación a la tabla temporal de staging
        -- Los datasets originiales no cuentan con un tipo de parque, por lo que es necesario leer un segundo 
        -- Dataset para asignarlos, aunque temporalmente se inserta un tipo de parque "no especificado" para luego actualizarlo con el dataset correcto
        IF right(@RutaArchivoParques, 4) = '.csv'
        BEGIN      
             EXEC Area_Infraestructura.Sp_ImportarDatosParquesCSVTemporal @RutaArchivoParques;
        END
        ELSE IF right(@RutaArchivoParques, 4) = '.xml'
        BEGIN
            EXEC Area_Infraestructura.Sp_ImportarDatosParquesXMLTemporal @RutaArchivoParques;
        END
        ELSE
        BEGIN
            RAISERROR('Formato de archivo no soportado. Solo se permiten archivos .csv o .xml', 16, 1);
            RETURN;
        END

            BEGIN TRANSACTION;

            IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Tipo_Parque WHERE Descripcion = 'Parque Nacional')
            INSERT INTO Area_Infraestructura.Tipo_Parque (Descripcion) VALUES ('Parque Nacional');

            IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Tipo_Parque WHERE Descripcion = 'Reserva Natural')
                INSERT INTO Area_Infraestructura.Tipo_Parque (Descripcion) VALUES ('Reserva Natural');

            IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Tipo_Parque WHERE Descripcion = 'Monumento Natural')
                INSERT INTO Area_Infraestructura.Tipo_Parque (Descripcion) VALUES ('Monumento Natural');

            IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Tipo_Parque WHERE Descripcion = 'Otro / No Especificado')
                INSERT INTO Area_Infraestructura.Tipo_Parque (Descripcion) VALUES ('Otro / No Especificado');

            -- Se crean los tipos de visitantes si no existen
            IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Tipo_Visitante WHERE Descripcion = 'Residente')
            BEGIN
                EXEC Area_Comercial.Sp_CrearTipoVisitante @Descripcion = 'Residente';
            END
            IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Tipo_Visitante WHERE Descripcion = 'No residente')
            BEGIN
                EXEC Area_Comercial.Sp_CrearTipoVisitante @Descripcion = 'No residente';
            END

            -- Paso 1: Insertar o actualizar Regiones            
            MERGE Area_Infraestructura.Region AS Target
            USING (
                SELECT DISTINCT s.Region
                FROM ##Staging_Parques s
                WHERE s.Region IS NOT NULL AND s.Region <> ''
            ) AS Source
            ON Target.Nombre = Source.Region
            WHEN MATCHED THEN
                UPDATE SET Nombre = Source.Region
            WHEN NOT MATCHED THEN
                INSERT (Nombre) VALUES (Source.Region);

            -- Paso 2: Insertar Provincias faltantes (Asignándoles la FK de Región correspondiente)
            MERGE Area_Infraestructura.Provincia AS Target
            USING (
                SELECT DISTINCT r.IdRegion, s.Provincia
                FROM ##Staging_Parques s
                INNER JOIN Area_Infraestructura.Region r ON s.Region = r.Nombre
                WHERE s.Provincia IS NOT NULL AND s.Provincia <> ''
            ) AS Source
            ON Target.Nombre = Source.Provincia
            WHEN MATCHED THEN
                UPDATE SET IdRegion = Source.IdRegion
            WHEN NOT MATCHED THEN
                INSERT (IdRegion, Nombre) VALUES (Source.IdRegion, Source.Provincia);

           -- Paso 3: Insertar o actualizar Parques (Asignándoles la FK de Provincia correspondiente, y el tipo de parque evaluando su nombre)
            MERGE Area_Infraestructura.Parque AS Target
            USING (
                SELECT DISTINCT 
                    p.IdProvincia,
                    tp.IdTipoParque,
                    s.Parque,
                    s.Superficie
                FROM ##Staging_Parques s
                INNER JOIN Area_Infraestructura.Provincia p ON s.Provincia = p.Nombre
                
                -- Evaluamos el nombre del área en Staging y lo unimos con su descripción real
                INNER JOIN Area_Infraestructura.Tipo_Parque tp ON tp.Descripcion = 
                    CASE 
                        WHEN s.Parque LIKE '%Parque%' THEN 'Parque Nacional'
                        WHEN s.Parque LIKE '%Reserva%' THEN 'Reserva Natural'
                        WHEN s.Parque LIKE '%Monumento%' THEN 'Monumento Natural'
                        ELSE 'Otro / No Especificado'
                    END
                    
                WHERE s.Parque IS NOT NULL AND s.Parque <> ''
            ) AS Source
            ON Target.Nombre = Source.Parque AND Target.IdProvincia = Source.IdProvincia
            WHEN MATCHED THEN
                UPDATE SET 
                    IdTipoParque = Source.IdTipoParque,
                    Superficie = Source.Superficie
            WHEN NOT MATCHED THEN
                INSERT (IdProvincia, IdTipoParque, Nombre, Superficie)
                VALUES (Source.IdProvincia, Source.IdTipoParque, Source.Parque, Source.Superficie);                

        COMMIT TRANSACTION;
        PRINT 'Migración de datos completada con éxito.';

        -- Precios y Descuentos para cada Parque
        -- Precios aleatorios entre $2000 y $5000 para Residentes, y $10000 y $25000 para No Residentes
        INSERT INTO Area_Comercial.Precio_Parque_Tipo_Visitante (IdParque, IdTipoVisitante, Precio)
        SELECT p.IdParque, tv.IdTipoVisitante,
            CASE WHEN tv.Descripcion = 'Residente' 
                THEN 2000 + (ABS(CHECKSUM(NEWID())) % 3000)
                ELSE 10000 + (ABS(CHECKSUM(NEWID())) % 15000) END
        FROM Area_Infraestructura.Parque p
        CROSS JOIN Area_Comercial.Tipo_Visitante tv
            WHERE NOT EXISTS (
                SELECT 1 FROM Area_Comercial.Precio_Parque_Tipo_Visitante px 
                WHERE px.IdParque = p.IdParque AND px.IdTipoVisitante = tv.IdTipoVisitante
    );

    -- Descuento del 10% por feriado para TODOS los parques
    INSERT INTO Area_Comercial.Descuento_Parque (IdParque, Descripcion, Porcentaje)
    SELECT IdParque, 'Descuento por Feriado Nacional', 0.10
    FROM Area_Infraestructura.Parque p
    WHERE NOT EXISTS (SELECT 1 FROM Area_Comercial.Descuento_Parque d WHERE d.IdParque = p.IdParque);

    DROP TABLE ##Staging_Parques;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
        DROP TABLE IF EXISTS ##Staging_Parques;
    END CATCH
END
GO

-- //////////////////////////////////////////////////////////////
--              IMPORTACIÓN DE DATOS DE VISITAS
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Comercial.Sp_ImportarDatosVisitasPorRegionYTipoVisitante
    @RutaArchivoVisitas VARCHAR(255),
    @Año INT,
    @Mes INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Primero se chequea que el archivo exista
    DECLARE @ExisteArchivo INT;
    EXEC master.dbo.xp_fileexist @RutaArchivoVisitas, @ExisteArchivo OUTPUT;
    IF @ExisteArchivo = 0
    BEGIN
        RAISERROR('El archivo no existe o no es accesible.', 16, 1);
        RETURN;
    END

    -- Se crea una tabla temporal para absorber las 5 columnas del CSV
    IF OBJECT_ID('tempdb..#Staging_Visitas_Raw_CSV') IS NULL
    BEGIN
        CREATE TABLE #Staging_Visitas_Raw_CSV (
            [indice_tiempo] VARCHAR(50) COLLATE Latin1_General_CI_AS,
            [region_de_destino] VARCHAR(255) COLLATE Latin1_General_CI_AS,
            [origen_visitantes] VARCHAR(255) COLLATE Latin1_General_CI_AS,
            [visitas] VARCHAR(50) COLLATE Latin1_General_CI_AS,
            [observaciones] VARCHAR(300) COLLATE Latin1_General_CI_AS
        );
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        -- Se lee el archivo CSV y se vuelca en la tabla Raw
        DECLARE @sql NVARCHAR(MAX);
        SET @sql = N'
        BULK INSERT #Staging_Visitas_Raw_CSV
        FROM ''' + @RutaArchivoVisitas + '''
        WITH (
            FORMAT = ''CSV'',            -- Interpreta correctamente los textos entre comillas dobles
            FIELDQUOTE = ''"'',
            FIELDTERMINATOR = '','',     -- Separador de columnas
            ROWTERMINATOR = ''0x0a'',      -- Separador de filas
            FIRSTROW = 2,              -- Saltea los encabezados de las columnas
            CODEPAGE = ''65001''         -- Usa UTF-8 para que acentos y eñes (ej. "Región") se lean perfecto
        );'

        EXEC sp_executesql @sql;
        -- print 'Datos importados a tabla temporal. Listo para procesar datos.';
        -- Se realiza un mapeo de las regiones a excepción de la Patagonia (porque tiene región Norte y Austral).
        UPDATE #Staging_Visitas_Raw_CSV
            SET region_de_destino = CASE LOWER(TRIM(region_de_destino))
                WHEN 'buenos aires' THEN 'Región Centro'
                WHEN 'cordoba'      THEN 'Región Centro Este'
                WHEN 'cuyo'         THEN 'Región Centro'
                WHEN 'litoral'      THEN 'Región Noroeste'
                WHEN 'norte'        THEN 'Región Noroeste'
                ELSE region_de_destino
            END;
        -- print 'Mapeo de regiones completado.';
        -- Las dos regiones de la Patagonia tendrán los mismos datos
        INSERT INTO #Staging_Visitas_Raw_CSV ([indice_tiempo], [region_de_destino], [origen_visitantes], [visitas], [observaciones])
        SELECT [indice_tiempo], r.region, [origen_visitantes], [visitas], [observaciones]
        FROM #Staging_Visitas_Raw_CSV
        CROSS JOIN (VALUES ('Región Patagonia Norte'), ('Región Patagonia Austral')) AS r(region)
        WHERE LOWER(TRIM(region_de_destino)) = 'patagonia';

        -- Se eliminan las filas originales sin mapear
        DELETE FROM #Staging_Visitas_Raw_CSV
        WHERE LOWER(TRIM(region_de_destino)) = 'patagonia'
        -- print 'Filas originales eliminadas.';

        -- Se crea una tabla temporal para almacenar los datos ya procesados y casteados
        IF OBJECT_ID('tempdb..#VisitasProcesadas') IS NULL
        BEGIN
            CREATE TABLE #VisitasProcesadas (
                ID INT IDENTITY(1,1) PRIMARY KEY,
                FechaMes DATE,
                RegionCSV VARCHAR(50),
                OrigenCSV VARCHAR(50),
                TotalVisitas INT
            );
        END

        -- Se crean los tipos de visitantes si no existen
        IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Tipo_Visitante WHERE Descripcion = 'Residente')
        BEGIN
            EXEC Area_Comercial.Sp_CrearTipoVisitante @Descripcion = 'Residente';
        END
        IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Tipo_Visitante WHERE Descripcion = 'No residente')
        BEGIN
            EXEC Area_Comercial.Sp_CrearTipoVisitante @Descripcion = 'No residente';
        END

        -- Filtrar y castear los datos base
        INSERT INTO #VisitasProcesadas (FechaMes, RegionCSV, OrigenCSV, TotalVisitas)
        SELECT 
            TRY_CAST([indice_tiempo] AS DATE),
            [region_de_destino],
            CASE 
                WHEN [origen_visitantes] = 'residentes' THEN 'Residente'
                WHEN [origen_visitantes] = 'no residentes' THEN 'No residente'
                ELSE [origen_visitantes]
            END,
            TRY_CAST([visitas] AS INT)
        FROM #Staging_Visitas_Raw_CSV
        WHERE [origen_visitantes] <> 'total'
          AND TRY_CAST([visitas] AS INT) > 0
          AND YEAR(TRY_CAST([indice_tiempo] AS DATE)) = @Año
          AND MONTH(TRY_CAST([indice_tiempo] AS DATE)) = @Mes;
        -- print 'Datos procesados y casteados. Listo para registrar ventas.';

        -- Se crean las ventas de entradas que corresponden a un parque random
        -- de la region de destino para un año y mes determinados
        DECLARE @MinId INT = 1;
        DECLARE @MaxId INT;
        SELECT @MaxId = ISNULL(MAX(ID), 0) FROM #VisitasProcesadas;

        WHILE @MinId <= @MaxId
        BEGIN
            DECLARE @FechaMesFila DATE, @RegionCSV VARCHAR(50), @OrigenCSV VARCHAR(30), @TotalVisitasFila INT;
            SELECT 
                @FechaMesFila = FechaMes, 
                @RegionCSV = RegionCSV, 
                @OrigenCSV = OrigenCSV, 
                @TotalVisitasFila = TotalVisitas
            FROM #VisitasProcesadas 
            WHERE ID = @MinId;

            -- Dividir las visitas de este mes en 4 semanas
            DECLARE @Semana INT = 1;
            WHILE @Semana <= 4
            BEGIN
                DECLARE @VisitasSemana INT = CEILING(@TotalVisitasFila / 4.0);
                
                -- Seleccionar un día al azar dentro de la semana evaluada
                DECLARE @StartDay INT = (@Semana - 1) * 7 + 1;
                DECLARE @EndDay INT = IIF(@Semana = 4, DAY(EOMONTH(@FechaMesFila)), @Semana * 7);
                DECLARE @RandomDay INT = @StartDay + ABS(CHECKSUM(NEWID())) % (@EndDay - @StartDay + 1);
                DECLARE @FechaVenta DATE = DATEADD(DAY, @RandomDay - 1, @FechaMesFila);
                -- print 'Fecha de venta generada: ' + CAST(@FechaVenta AS VARCHAR);

                -- Seleccionar una Forma de Pago aleatoria
                DECLARE @DescFormaDePago VARCHAR(30) = NULL;
                SELECT TOP 1 @DescFormaDePago = Descripcion FROM Area_Comercial.Forma_De_Pago ORDER BY NEWID();
                -- print 'Forma de pago seleccionada: ' + @DescFormaDePago;

                -- Seleccionar un Punto de Venta aleatorio
                DECLARE @IdPdv INT = NULL;
                SELECT TOP 1 @IdPdv = IdPuntoDeVenta FROM Area_Comercial.Punto_De_Venta ORDER BY NEWID();
                -- print 'Punto de venta seleccionado: ' + CAST(@IdPdv AS VARCHAR);

                -- Seleccionar un parque random de la región de destino
                -- Seleccionar un parque random de la región de destino QUE YA TENGA TARIFA
                DECLARE @ParqueRandom VARCHAR(80) = (
                    SELECT TOP 1 p.Nombre 
                    FROM Area_Infraestructura.Parque p
                    JOIN Area_Infraestructura.Provincia pr ON p.IdProvincia = pr.IdProvincia
                    JOIN Area_Infraestructura.Region r ON pr.IdRegion = r.IdRegion
                    -- Joineamos con tu tabla de tarifas y tipos de visitante
                    JOIN Area_Comercial.Precio_Parque_Tipo_Visitante t ON p.IdParque = t.IdParque
                    JOIN Area_Comercial.Tipo_Visitante tv ON t.IdTipoVisitante = tv.IdTipoVisitante
                    WHERE r.Nombre = @RegionCSV
                      AND tv.Descripcion = @OrigenCSV -- Filtramos por Residente/No residente
                    ORDER BY NEWID()
                );

                -- Solo ejecutamos la venta si encontró un parque válido
                IF @ParqueRandom IS NOT NULL
                BEGIN
                    EXEC Area_Comercial.Sp_RegistrarVentaEntradas
                        @Parque = @ParqueRandom, 
                        @CantidadEntradas = @VisitasSemana,
                        @TipoVisitante = @OrigenCSV,
                        @Actividad = NULL, 
                        @Fecha = @FechaVenta,
                        @IdPuntoDeVenta = @IdPdv,
                        @FormaDePago = @DescFormaDePago;
                END
                -- Si @ParqueRandom es NULL, termina la vuelta del bucle sin hacer nada (lo saltea).

                SET @Semana = @Semana + 1;
            END
            SET @MinId = @MinId + 1;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
    DROP TABLE IF EXISTS #Staging_Visitas_Raw_CSV;
    DROP TABLE IF EXISTS #VisitasProcesadas;
END
go

-- ===========================================================================================
--                                          SEED DATA
-- ===========================================================================================

CREATE OR ALTER PROCEDURE Area_Comercial.Sp_AreaComercialSeed
    @PuntosDeVenta BIT = 1,
    @FormasDePago BIT = 1,
    @TiposVisitantes BIT = 1,
    @HistorialVentas BIT = 1
AS
BEGIN
    BEGIN TRY
        set nocount on;
        BEGIN TRANSACTION;

        -- ==============================================================================
        --   CREACIÓN DE PUNTOS DE VENTA, FORMAS DE PAGO Y TIPOS DE VISITANTES
        -- ==============================================================================

        IF @PuntosDeVenta = 1 AND NOT EXISTS (SELECT 1 FROM Area_Comercial.Punto_De_Venta where Descripcion IN ('Boletería Principal', 'Web'))
        BEGIN
            EXEC Area_Comercial.SP_CrearPuntoDeVenta 'Boletería Principal';
            EXEC Area_Comercial.SP_CrearPuntoDeVenta 'Web';
        END

        IF @FormasDePago = 1 AND NOT EXISTS (SELECT 1 FROM Area_Comercial.Forma_De_Pago where Descripcion IN ('Efectivo', 'Tarjeta de Credito', 'Tarjeta de Debito', 'Transferencia'))
        BEGIN
            EXEC Area_Comercial.SP_CrearFormaDePago 'Efectivo';
            EXEC Area_Comercial.SP_CrearFormaDePago 'Tarjeta de Credito';
            EXEC Area_Comercial.SP_CrearFormaDePago 'Tarjeta de Debito';
            EXEC Area_Comercial.SP_CrearFormaDePago 'Transferencia';
        END

        IF @TiposVisitantes = 1 AND NOT EXISTS (SELECT 1 FROM Area_Comercial.Tipo_Visitante where Descripcion IN ('Residente', 'No residente'))
        BEGIN
            EXEC Area_Comercial.Sp_CrearTipoVisitante 'Residente';
            EXEC Area_Comercial.Sp_CrearTipoVisitante 'No residente';
        END

        -- ==============================================================================
        --                          REGISTRO DE VENTAS SIMULADAS
        -- ==============================================================================  
        
        -- Registrar historial de ventas simulado: 5 ventas para cada parque con distinta cantidad de entradas
        IF @HistorialVentas = 1
        BEGIN
            DECLARE @MinId INT = (select MIN(IdParque) FROM Area_Infraestructura.Parque);
            DECLARE @MaxId INT = (SELECT MAX(IdParque) FROM Area_Infraestructura.Parque);
            WHILE @MinId <= @MaxId
            BEGIN
                DECLARE @V_ParqueNombre VARCHAR(80) = (SELECT Nombre FROM Area_Infraestructura.Parque WHERE IdParque = @MinId);
                DECLARE @V_ActividadNombre VARCHAR(80) = (SELECT TOP 1 Nombre FROM Area_Excursiones.Actividad WHERE IdParque = @MinId ORDER BY NEWID());
                IF @V_ActividadNombre IS NOT NULL AND @V_ParqueNombre IS NOT NULL
                BEGIN
                    DECLARE @ventasSimuladas INT = 0;
                    while @ventasSimuladas < 5
                    BEGIN
                        DECLARE @V_TipoVisitante VARCHAR(30) = CASE WHEN RAND() > 0.5 THEN 'Residente' ELSE 'No residente' END;
                        DECLARE @V_PuntoDeVenta INT = (SELECT TOP 1 IdPuntoDeVenta FROM Area_Comercial.Punto_De_Venta ORDER BY NEWID());
                        DECLARE @V_FormaPago VARCHAR(30) = (SELECT TOP 1 Descripcion FROM Area_Comercial.Forma_De_Pago ORDER BY NEWID());
                        DECLARE @V_Fecha DATE = DATEADD(DAY, -CAST(RAND() * 180 AS INT), GETDATE());
                        DECLARE @V_CantEntradas INT = CAST(RAND() * 5 + 1 AS INT);
                        IF @V_ParqueNombre IS NOT NULL AND @V_ActividadNombre IS NOT NULL AND @V_PuntoDeVenta IS NOT NULL AND @V_FormaPago IS NOT NULL
                        BEGIN
                            BEGIN TRY
                                EXEC Area_Comercial.Sp_RegistrarVentaEntradas
                                    @Parque = @V_ParqueNombre,
                                    @CantidadEntradas = @V_CantEntradas,
                                    @TipoVisitante = @V_TipoVisitante,
                                    @Actividad = @V_ActividadNombre,
                                    @Fecha = @V_Fecha,
                                    @IdPuntoDeVenta = @V_PuntoDeVenta,
                                    @FormaDePago = @V_FormaPago;
                            END TRY
                            BEGIN CATCH
                                DECLARE @ErrorMessageInterno VARCHAR(255) = ERROR_MESSAGE();
                                RAISERROR('Error al generar venta de prueba para el parque %s y la actividad %s: %s', 16, 1, @V_ParqueNombre, @V_ActividadNombre, @ErrorMessageInterno);
                            END CATCH
                        END
                        SET @ventasSimuladas = @ventasSimuladas + 1;
                    END
                END

                SET @MinId = @MinId + 1;
            END
        END
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage VARCHAR(255) = ERROR_MESSAGE();
        RAISERROR('Error al generar seed data del área comercial: %s', 16, 1, @ErrorMessage);
    END CATCH
END
go

CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_AreaExcursionesSeed
    @Actividades BIT = 1,
    @Guias BIT = 1,
    @Asignaciones BIT = 1
AS
BEGIN
    BEGIN TRY
        set nocount on;
        BEGIN TRANSACTION;

            -- ==============================================================================
            --     CREACIÓN DE ACTIVIDADES, GUÍAS Y ASIGNACIÓN DE ESPECIALIDADES
            -- ==============================================================================

            IF @Actividades = 1
            BEGIN
                -- Creación de 30 Actividades distribuidas en los Parques
                -- cada actividad debe tener una habilitacion 
                IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Tipo_Actividad)
                BEGIN
                    EXEC Area_Excursiones.Sp_CrearTipoActividad 'Senderismo';
                    EXEC Area_Excursiones.Sp_CrearTipoActividad 'Trekking';
                    EXEC Area_Excursiones.Sp_CrearTipoActividad 'Navegacion';
                    EXEC Area_Excursiones.Sp_CrearTipoActividad 'Cabalgata';
                    EXEC Area_Excursiones.Sp_CrearTipoActividad 'Avistaje de Aves';
                    EXEC Area_Excursiones.Sp_CrearTipoActividad 'Observacion de Flora/Fauna';
                END

                IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Habilitacion)
                BEGIN
                    INSERT INTO Area_Excursiones.Habilitacion (Descripcion) VALUES 
                    ('Primeros Auxilios y RCP'), 
                    ('Rescate Acuático y Buceo'), 
                    ('Alta Montaña y Escalada'), 
                    ('Supervivencia en Entornos Extremos'), 
                    ('Observación de Flora y Fauna Local');
                END

                IF (SELECT COUNT(*) FROM Area_Excursiones.Actividad) < 30
                BEGIN
                    DECLARE @cantActividades INT = 0;
                    WHILE @cantActividades < 30
                    BEGIN
                        DECLARE @IdTipoActividad INT, @IdParque INT;
                        DECLARE @NombreTipoActividad VARCHAR(30) ;
                        DECLARE @NombreActividad VARCHAR(30) = 'Tour Guiado';
                        DECLARE @Costo decimal(10, 2) = 5000 + (ABS(CHECKSUM(NEWID())) % 10000);
                        DECLARE @Duracion INT = 2 + (ABS(CHECKSUM(NEWID())) % 6);
                        DECLARE @Cupo_maximo INT = 20 + (ABS(CHECKSUM(NEWID())) % 30);

                        SET @IdTipoActividad = (SELECT TOP 1 IdTipoActividad FROM Area_Excursiones.Tipo_Actividad ORDER BY NEWID());
                        SET @NombreTipoActividad = (SELECT TOP 1 Descripcion FROM Area_Excursiones.Tipo_Actividad WHERE IdTipoActividad = @IdTipoActividad);
                        SET @NombreActividad = @NombreActividad + ' ' + @NombreTipoActividad;
                        
                        SET @IdParque = (SELECT TOP 1 IdParque FROM Area_Infraestructura.Parque ORDER BY NEWID());

                        EXEC Area_Excursiones.Sp_CrearActividad
                            @tipoActividad = @IdTipoActividad,
                            @idParque = @IdParque,
                            @Nombre = @NombreActividad,
                            @Costo = @Costo,
                            @Duracion = @Duracion,
                            @Cupo_maximo = @Cupo_maximo

                        -- Asignar requisitos (1 o 2 habilitaciones por actividad)
                        INSERT INTO Area_Excursiones.Habilitaciones_por_Actividad (IdActividad, IdHabilitacion)
                        SELECT A.IdActividad, H.IdHabilitaciones
                        FROM Area_Excursiones.Actividad A
                        CROSS APPLY (
                            -- Selecciona 1 o 2 habilitaciones aleatorias para cada actividad
                            SELECT TOP (1 + ABS(CHECKSUM(NEWID())) % 2) IdHabilitaciones 
                            FROM Area_Excursiones.Habilitacion ORDER BY NEWID()
                        ) H
                        WHERE NOT EXISTS (
                            SELECT 1 FROM Area_Excursiones.Habilitaciones_por_Actividad HA 
                            WHERE HA.IdActividad = A.IdActividad AND HA.IdHabilitacion = H.IdHabilitaciones
                        );

                        SET @cantActividades = @cantActividades + 1;
                    END
                END
            END

            -- Creación de 20 Guías con especialidades asignados a actividades de sus respectivos parques
            -- cada guia debe cumplir con todas las habilitaciones de las actividades que se realizan en su parque asignado, por lo que se asigna la habilitacion 
            -- al guia y luego se relaciona el guia con las actividades de su parque que correspondan a esa habilitacion

            EXEC Area_Excursiones.Sp_CrearEspecialidad 'Especialidad en Senderismo';
            EXEC Area_Excursiones.Sp_CrearEspecialidad 'Especialidad en Trekking';
            EXEC Area_Excursiones.Sp_CrearEspecialidad 'Especialidad en Rafting';
            EXEC Area_Excursiones.Sp_CrearEspecialidad 'Especialidad en Cabalgatas';
            EXEC Area_Excursiones.Sp_CrearEspecialidad 'Especialidad en Avistaje de Aves';

            IF @Guias = 1
            BEGIN
                DECLARE @NomYApeGuias TABLE (id INT IDENTITY(1,1), nombre VARCHAR(30), apellido VARCHAR(30));
                INSERT INTO @NomYApeGuias VALUES
                ('Thom', 'Yorke'), ('Jonny', 'Greenwood'), 
                ('Colin', 'Greenwood'), ('Ed', 'O''Brien'),
                ('Phil', 'Selway'), ('Robert', 'Smith'),
                ('Simon', 'Gallup'), ('Jason', 'Cooper'), 
                ('Roger', 'O''Donnell'), ('Reeves', 'Gabrels'),
                ('Michael', 'Dempsey'), ('Andy', 'Anderson'),
                ('Perry', 'Bamonte'), ('Nicholas', 'Matthews'),
                ('Johnny', 'Braddock'), ('Adam', 'Virostko'),
                ('Dan', 'Juarez'), ('Bradley', 'Iverson'),
                ('Ray', 'Toro'), ('Mikey', 'Way');

                DECLARE @TotalGuias INT = (SELECT COUNT(*) FROM Area_Excursiones.Guia WHERE Nombre LIKE 'GuiaNom%');
                DECLARE @RandParqueGuia INT;
                DECLARE @RandEspId INT;
                DECLARE @DniGuia CHAR(8);
                DECLARE @NomGuia VARCHAR(30);
                DECLARE @ApeGuia VARCHAR(30);
                DECLARE @TituloGuia VARCHAR(30);

                -- Declaración y asignación dinámica de los límites
                DECLARE @limInf INT = 1;
                DECLARE @limSup INT = (SELECT COUNT(*) FROM @NomYApeGuias) + 1;
                IF @TotalGuias < 20
                BEGIN
                    DECLARE @GuiaNo INT = 1;
                    WHILE @GuiaNo <= 20
                    BEGIN
                        SET @RandParqueGuia = (SELECT TOP 1 IdParque FROM Area_Infraestructura.Parque ORDER BY NEWID());
                        SET @RandEspId = (SELECT TOP 1 IdEspecialidad FROM Area_Excursiones.Especialidad ORDER BY NEWID());
                        SET @DniGuia = CAST(CAST(RAND() * 89999999 + 10000000 AS INT) AS CHAR(8));
                        SET @NomGuia = (SELECT nombre FROM @NomYApeGuias WHERE id = CAST(RAND()*(@limSup - @limInf)+@limInf AS INT));
                        SET @ApeGuia = (SELECT apellido FROM @NomYApeGuias WHERE id = CAST(RAND()*(@limSup - @limInf)+@limInf AS INT));
                        SET @TituloGuia = 'Licenciado en turismo';
                        INSERT INTO Area_Excursiones.Guia (DNI, IdParque, IdEspecialidad, Nombre, Apellido, Titulo)
                        VALUES (@DniGuia, @RandParqueGuia, @RandEspId, @NomGuia, @ApeGuia, @TituloGuia);
                        DECLARE @NewGuiaId INT = SCOPE_IDENTITY();
                        SET @GuiaNo = @GuiaNo + 1;
                    END
                END;
                -- Eliminamos los guias repetidos
                -- Acá los parámetros por los que partimos son los que se van a contar como repetidos
                WITH cte(idGuia, nombre, apellido, ocurrencias) AS (
                    SELECT idGuia, nombre, apellido, 
                    ROW_NUMBER() OVER(PARTITION BY nombre, apellido ORDER BY idGuia) as duplicados
                    from Area_Excursiones.Guia
                )
                delete from cte where ocurrencias > 1;

                -- Asignar Habilitaciones a los Guías
                INSERT INTO Area_Excursiones.Habilitacion_Guia (IdGuia, IdHabilitacion, Fecha_Inicio_Validez, Fecha_Fin_Validez)
                SELECT 
                    G.IdGuia, 
                    H.IdHabilitaciones, 
                    DATEADD(DAY, -30, GETDATE()), -- Inicio hace 30 días
                    DATEADD(DAY, 365, GETDATE())  -- Vence en 1 año
                FROM Area_Excursiones.Guia G
                CROSS APPLY (
                    -- Truco: Si el ID del guía es par, le damos TODAS las habilitaciones (Guía Maestro).
                    -- Si es impar, le damos solo 2 aleatorias. Esto garantiza que haya asignaciones exitosas.
                    SELECT TOP (CASE WHEN G.IdGuia % 2 = 0 THEN 5 ELSE 2 END) IdHabilitaciones
                    FROM Area_Excursiones.Habilitacion ORDER BY NEWID()
                ) H
                WHERE NOT EXISTS (
                    SELECT 1 FROM Area_Excursiones.Habilitacion_Guia HG 
                    WHERE HG.IdGuia = G.IdGuia AND HG.IdHabilitacion = H.IdHabilitaciones
                );
            END

            -- ==============================================================================
            -- ASIGNACIÓN DE GUÍAS A ACTIVIDADES (respetando las habilitaciones requeridas)
            -- ==============================================================================
            
            if @Asignaciones = 1
            BEGIN
                IF OBJECT_ID('tempdb..#ParejasValidas') IS NULL
                BEGIN
                    CREATE TABLE #ParejasValidas (Id INT IDENTITY(1,1), IdGuia INT, IdActividad INT);
                END

                -- Filtramos usando exactamente la misma lógica de doble negación del SP
                INSERT INTO #ParejasValidas (IdGuia, IdActividad)
                SELECT G.IdGuia, A.IdActividad
                FROM Area_Excursiones.Guia G
                CROSS JOIN Area_Excursiones.Actividad A
                WHERE NOT EXISTS (
                    SELECT 1 FROM Area_Excursiones.Habilitaciones_por_Actividad HA
                    WHERE HA.IdActividad = A.IdActividad
                    AND NOT EXISTS (
                        SELECT 1 FROM Area_Excursiones.Habilitacion_Guia HG 
                        WHERE HG.IdGuia = G.IdGuia AND HG.IdHabilitacion = HA.IdHabilitacion 
                        AND HG.Fecha_Fin_Validez >= GETDATE()
                    )
                )
                AND NOT EXISTS (
                    -- Evitamos insertar si la pareja ya existe en Guias_por_Actividad
                    SELECT 1 FROM Area_Excursiones.Guias_por_Actividad GA 
                    WHERE GA.IdGuia = G.IdGuia AND GA.IdActividad = A.IdActividad
                );

                -- Ejecutamos el SP iterando la tabla temporal
                DECLARE @MaxId INT = (SELECT ISNULL(MAX(Id), 0) FROM #ParejasValidas);
                DECLARE @Iterador INT = 1;
                DECLARE @IdGuiaActual INT, @IdActividadActual INT;

                WHILE @Iterador <= @MaxId
                BEGIN
                    SELECT @IdGuiaActual = IdGuia, @IdActividadActual = IdActividad 
                    FROM #ParejasValidas WHERE Id = @Iterador;

                    EXEC Area_Excursiones.Sp_CrearGuiasPorActividad 
                        @IdGuia = @IdGuiaActual, 
                        @IdActividad = @IdActividadActual;

                    SET @Iterador = @Iterador + 1;
                END
                DROP TABLE IF EXISTS #ParejasValidas;
            END

        COMMIT TRANSACTION
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage VARCHAR(255) = ERROR_MESSAGE();
        RAISERROR('Error al generar seed data del área de excursiones: %s', 16, 1, @ErrorMessage);
        ROLLBACK TRANSACTION;
    END CATCH
END
go

CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_AreaInfraSeed
    @Regiones INT = 1,
    @Provincias INT = 1,
    @TiposParque INT = 1,
    @TiposVisitante INT = 1,
    @Parques INT = 1,
    @Guardaparques INT = 1
AS
BEGIN
    BEGIN TRY
        set nocount on;
        BEGIN TRANSACTION;

        -- ==============================================================================
        --  CREACION DE REGIONES, PROVINCIAS, TIPOS DE PARQUE Y TIPOS DE VISITANTE
        -- ==============================================================================

        IF @Regiones = 1 AND NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Region)
        BEGIN
            EXEC Area_Infraestructura.SP_CrearRegion 'Región Centro Este';
            EXEC Area_Infraestructura.SP_CrearRegion 'Región Centro';
            EXEC Area_Infraestructura.SP_CrearRegion 'Región Noreste';
            EXEC Area_Infraestructura.SP_CrearRegion 'Región Noroeste';
            EXEC Area_Infraestructura.SP_CrearRegion 'Región Patagonia Austral';
            EXEC Area_Infraestructura.SP_CrearRegion 'Región Patagonia Norte';
        END

        IF @Provincias = 1 AND NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Provincia)
        BEGIN
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Cordoba', @NombreRegion = 'Región Centro';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'La Rioja', @NombreRegion = 'Región Centro';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'San Juan', @NombreRegion = 'Región Centro';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'San Luis', @NombreRegion = 'Región Centro';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Mendoza', @NombreRegion = 'Región Centro';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Buenos Aires', @NombreRegion = 'Región Centro Este';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Entre Rios', @NombreRegion = 'Región Centro Este';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Santa Fe', @NombreRegion = 'Región Centro Este';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Chaco', @NombreRegion = 'Región Noreste';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Corrientes', @NombreRegion = 'Región Noreste';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Formosa', @NombreRegion = 'Región Noreste';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Misiones', @NombreRegion = 'Región Noreste';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Jujuy', @NombreRegion = 'Región Noroeste';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Santiago Del Estero', @NombreRegion = 'Región Noroeste';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Salta', @NombreRegion = 'Región Noroeste';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Tucuman', @NombreRegion = 'Región Noroeste';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Santa Cruz', @NombreRegion = 'Región Patagonia Austral';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Tierra Del Fuego', @NombreRegion = 'Región Patagonia Austral';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Chubut', @NombreRegion = 'Región Patagonia Norte';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'La Pampa', @NombreRegion = 'Región Patagonia Norte';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Neuquen', @NombreRegion = 'Región Patagonia Norte';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Rio Negro', @NombreRegion = 'Región Patagonia Norte';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Catamarca', @NombreRegion = 'Región Noroeste';
        END

        -- Inserción de Tipos de Parque y Tipos de Visitante
        IF @TiposParque = 1 AND NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Tipo_Parque where Descripcion  in ('Parque Nacional', 'Reserva Natural', 'Monumento Natural'))
        BEGIN
            EXEC Area_Infraestructura.SP_CrearTipoParque 'Parque Nacional';
            EXEC Area_Infraestructura.SP_CrearTipoParque 'Reserva Natural';
            EXEC Area_Infraestructura.SP_CrearTipoParque 'Monumento Natural';
        END

        IF @TiposVisitante = 1 AND NOT EXISTS (SELECT 1 FROM Area_Comercial.Tipo_Visitante where Descripcion in ('Residente', 'No residente'))
        BEGIN
            EXEC Area_Comercial.SP_CrearTipoVisitante 'Residente';
            EXEC Area_Comercial.SP_CrearTipoVisitante 'No residente';
        END

        -- ==============================================================================
        --      CREACIÓN DE PARQUES, CON PRECIOS Y DESCUENTOS PARA CADA UNO
        -- ==============================================================================

        -- Inserción de 10 Parques (Seed Data)
        IF @Parques = 1 AND NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Parque WHERE Nombre IN ('Parque Nacional De Los Payasos', 'Monumento Natural El Nahual', 'Parque Nacional Los Chicos del Chaco', 'Reserva Natural Hnatiuk', 'Monumento Natural Los Héroes de Malvinas', 'Reserva Natural Península del Libertador', 'Monumento Natural Los Héroes de Malvinas', 'Parque Nacional Agustina', 'Parque Nacional Semilla', 'Reserva Natural Bossero'))
        BEGIN
            EXEC Area_Infraestructura.SP_CrearParque @Nombre = 'Parque Nacional De Los Payasos', @Provincia = 'Buenos Aires', @TipoParqueDesc = 'Parque Nacional', @Superficie = 263000.00;
            EXEC Area_Infraestructura.SP_CrearParque @Nombre = 'Monumento Natural El Nahual', @Provincia = 'Rio Negro', @TipoParqueDesc = 'Monumento Natural', @Superficie = 150000.00;
            EXEC Area_Infraestructura.SP_CrearParque @Nombre = 'Parque Nacional Los Chicos del Chaco', @Provincia = 'Chaco', @TipoParqueDesc = 'Parque Nacional', @Superficie = 180000.00;
            EXEC Area_Infraestructura.SP_CrearParque @Nombre = 'Reserva Natural Hnatiuk', @Provincia = 'Santa Cruz', @TipoParqueDesc = 'Reserva Natural', @Superficie = 200000.00;
            EXEC Area_Infraestructura.SP_CrearParque @Nombre = 'Monumento Natural Los Héroes de Malvinas', @Provincia = 'Tierra del Fuego', @TipoParqueDesc = 'Monumento Natural', @Superficie = 150000.00;
            EXEC Area_Infraestructura.SP_CrearParque @Nombre = 'Reserva Natural Península del Libertador', @Provincia = 'Santa Cruz', @TipoParqueDesc = 'Reserva Natural', @Superficie = 150000.00;
            EXEC Area_Infraestructura.SP_CrearParque @Nombre = 'Monumento Natural Los Héroes de la Patria', @Provincia = 'Misiones', @TipoParqueDesc = 'Monumento Natural', @Superficie = 150000.00;
            EXEC Area_Infraestructura.SP_CrearParque @Nombre = 'Parque Nacional Agustina', @Provincia = 'Chubut', @TipoParqueDesc = 'Parque Nacional', @Superficie = 10000.00;
            EXEC Area_Infraestructura.SP_CrearParque @Nombre = 'Parque Nacional Semilla', @Provincia = 'Mendoza', @TipoParqueDesc = 'Parque Nacional', @Superficie = 130000.00;
            EXEC Area_Infraestructura.SP_CrearParque @Nombre = 'Reserva Natural Bossero', @Provincia = 'Buenos Aires', @TipoParqueDesc = 'Reserva Natural', @Superficie = 12000.00;

            -- Precios y Descuentos para cada Parque
            -- Precios aleatorios entre $2000 y $5000 para Residentes, y $10000 y $25000 para No Residentes
            INSERT INTO Area_Comercial.Precio_Parque_Tipo_Visitante (IdParque, IdTipoVisitante, Precio)
            SELECT p.IdParque, tv.IdTipoVisitante,
                CASE WHEN tv.Descripcion = 'Residente' 
                    THEN 2000 + (ABS(CHECKSUM(NEWID())) % 3000)
                    ELSE 10000 + (ABS(CHECKSUM(NEWID())) % 15000) END
            FROM Area_Infraestructura.Parque p
            CROSS JOIN Area_Comercial.Tipo_Visitante tv
            WHERE NOT EXISTS (
                SELECT 1 FROM Area_Comercial.Precio_Parque_Tipo_Visitante px 
                WHERE px.IdParque = p.IdParque AND px.IdTipoVisitante = tv.IdTipoVisitante
            );

            -- Descuento del 10% por feriado para TODOS los parques
            INSERT INTO Area_Comercial.Descuento_Parque (IdParque, Descripcion, Porcentaje)
            SELECT IdParque, 'Descuento por Feriado Nacional', 0.10
            FROM Area_Infraestructura.Parque p
            WHERE NOT EXISTS (SELECT 1 FROM Area_Comercial.Descuento_Parque d WHERE d.IdParque = p.IdParque);
        END



        -- ==============================================================================
        --      CREACIÓN Y ASIGNACIÓN DE GUARDAPARQUES A LOS PARQUES
        -- ==============================================================================

        IF @Guardaparques = 1 AND NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Guardaparque)
        BEGIN
            -- Creación de 20 Guardaparques
            DECLARE @TotalGuardaparques INT = (SELECT COUNT(*) FROM Area_Infraestructura.Guardaparque WHERE Nombre LIKE 'GpNom%');
            
            DECLARE @nombresYapellidos TABLE (id INT IDENTITY(1,1), nombre VARCHAR(30), apellido VARCHAR(30));
            DECLARE @limInf INT = 1;
            DECLARE @limSup INT = 20;

            insert into @nombresYapellidos values ('Agustina', 'Losada'), ('Lautaro', 'Barreto'), ('Guillermo', 'Hnatiuk'), ('Facundo', 'Bossero'), ('Jair', 'Perez'), ('Julio', 'Bossero'), ('Elias', 'Joseph'), ('Federico', 'Martinez'), ('Tiago', 'Pujia'), ('Cecilia', 'Gonzalez'),
                                        ('Tyler', 'Joseph'), ('Gerard', 'Way'), ('William', 'Afton'), ('Daniel', 'Velazquez'), ('Agustin', 'Claure'), ('Jeremias', 'Gutierrez'), ('Federico', 'Pezzola'), ('Franco', 'Conde'), ('Francisco', 'Comerci'), ('Sofia', 'Salvia');

            -- Asignación de guardaparques a parques de manera aleatoria
            IF @TotalGuardaparques < 20
            BEGIN
                DECLARE @GpNo INT = 1;
                WHILE @GpNo <= 20
                BEGIN
                    DECLARE @RandParqueGp INT = (SELECT TOP 1 IdParque FROM Area_Infraestructura.Parque ORDER BY NEWID());
                    DECLARE @DniGp CHAR(8) = CAST(CAST(RAND() * 89999999 + 10000000 AS INT) AS CHAR(8));
                    DECLARE @NomGp VARCHAR(30) = (SELECT nya.nombre FROM @nombresYapellidos nya WHERE nya.id = CAST(RAND()*(@limSup - @limInf)+@limInf AS INT));
                    DECLARE @ApeGp VARCHAR(30) = (SELECT nya.apellido FROM @nombresYapellidos nya WHERE nya.id = CAST(RAND()*(@limSup - @limInf)+@limInf AS INT));
                    DECLARE @Ingreso DATE = DATEADD(DAY, -CAST(RAND() * 3000 AS INT), GETDATE());
                    INSERT INTO Area_Infraestructura.Guardaparque (IdParque, Dni, Nombre, Apellido, Fecha_Ingreso, Activo)
                    VALUES (@RandParqueGp, @DniGp, @NomGp, @ApeGp, @Ingreso, 1);
                    SET @GpNo = @GpNo + 1;
                END
            END;
            -- Eliminamos los guardaparques repetidos
            -- Acá los parámetros por los que partimos son los que se van a contar como repetidos
            WITH cte(idGuardaparques, nombre, apellido, ocurrencias) AS (
                SELECT idGuardaparque, nombre, apellido, 
                ROW_NUMBER() OVER(PARTITION BY nombre, apellido ORDER BY idGuardaparque) as duplicados
                from Area_Infraestructura.Guardaparque
            )
            delete from cte where ocurrencias > 1;
        END

        COMMIT TRANSACTION
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage VARCHAR(255) = ERROR_MESSAGE();
        RAISERROR('Error al generar seed data del área de infraestructura: %s', 16, 1, @ErrorMessage);
        ROLLBACK TRANSACTION;
    END CATCH
END
go

CREATE OR ALTER PROCEDURE Area_Negocios.Sp_AreaNegociosSeed
    @Empresas BIT = 1,
    @Concesiones BIT = 1
AS
BEGIN
    BEGIN TRY
        set nocount on;
        BEGIN TRANSACTION;

        -- Crear al menos 5 empresas concesionarias
        IF @Empresas = 1 AND NOT EXISTS (SELECT 1 FROM Area_Negocios.Empresa_Concesionaria)
        BEGIN
            EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Agus Inc.';
            EXEC Area_Negocios.Sp_CrearEmpresaConcesionaria 'Umbrella Corp';
            EXEC Area_Negocios.Sp_CrearEmpresaConcesionaria 'YPF';
            EXEC Area_Negocios.Sp_CrearEmpresaConcesionaria 'Freddy Fazbears Pizza';
            EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Claure y Co.';

            EXEC Area_Negocios.SP_CrearTipoActividadConcesion @Descripcion = 'Regadero';
            EXEC Area_Negocios.SP_CrearTipoActividadConcesion @Descripcion = 'Restaurante';

        END
       
        -- Crear al menos 10 Concesiones
        IF @Concesiones = 1
        BEGIN
            DECLARE @TotalConcesiones INT = (SELECT COUNT(*) FROM Area_Negocios.Concesion);
            IF @TotalConcesiones < 10
            BEGIN
                DECLARE @ConNo INT = 1;
                WHILE @ConNo <= 10
                    BEGIN
                    DECLARE @RandParqueCon INT = (SELECT TOP 1 IdParque FROM Area_Infraestructura.Parque ORDER BY NEWID());
                    DECLARE @RandEmpId INT = (SELECT TOP 1 IdEmpresa FROM Area_Negocios.Empresa_Concesionaria ORDER BY NEWID());
                    DECLARE @RandTipoConId INT = (SELECT TOP 1 IdTipoActividadConcesion FROM Area_Negocios.Tipo_Actividad_Concesion ORDER BY NEWID());
                    DECLARE @FInicio DATE = DATEADD(DAY, -CAST(RAND() * 365 AS INT), GETDATE());
                    DECLARE @FFin DATE = DATEADD(YEAR, 5, @FInicio);
                    EXEC Area_Negocios.SP_CrearConcesion @RandTipoConId, @RandEmpId, @RandParqueCon, @FInicio, @FFin
                    SET @ConNo = @ConNo + 1;
                END
            END
        END

        COMMIT TRANSACTION;
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage VARCHAR(255) = ERROR_MESSAGE();
        RAISERROR('Error al generar seed data del área de negocios: %s', 16, 1, @ErrorMessage);
    END CATCH
END
go

CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_ReporteVisitasParque
@IdParque INT 
AS
BEGIN
    BEGIN TRY

        IF NOT EXISTS(SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @IdParque AND Activo = 1)
        BEGIN 
            RAISERROR('El parque proporcionado no existe o no está disponible.',16,1)
        END 

        SELECT p.Nombre AS PARQUE,
        YEAR(e.Fecha_Acceso) AS AÑO,
        MONTH(e.Fecha_Acceso) AS MES,
        DATEPART(WEEK, e.Fecha_Acceso) AS SEMANA,
        COUNT(e.IdEntrada) AS 'TOTAL VISITAS'
        FROM Area_Infraestructura.Parque p 
        JOIN Area_Comercial.Entrada e ON e.IdParque = p.IdParque
        WHERE p.IdParque = @IdParque
        GROUP BY p.Nombre, YEAR(e.Fecha_Acceso), MONTH(e.Fecha_Acceso), DATEPART(WEEK, e.Fecha_Acceso)
        ORDER BY AÑO, MES, SEMANA
    END TRY
    BEGIN CATCH 
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH 
END 
GO
