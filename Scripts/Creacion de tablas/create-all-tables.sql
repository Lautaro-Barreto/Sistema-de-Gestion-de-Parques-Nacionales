/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación, en orden,
 de todas las tablas y esquemas necesarios para el correcto funcionamiento de la base de datos. 
*/

USE SGParquesNacionales
GO

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
        IdPuntoDeVenta INT,
        IdParque INT,
        IdFormaDePago INT,
        Fecha DATE,
        Total DECIMAL(10,2),

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
        IdTipoVisitante INT,
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
        IdVenta INT,
        IdEntrada INT,
        Cantidad INT,
        Subtotal DECIMAL(10,2),

        PRIMARY KEY (IdVenta, IdEntrada),
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
        IdTipoVisitante INT, 
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