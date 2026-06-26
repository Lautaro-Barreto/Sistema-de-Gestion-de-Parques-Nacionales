-- =============================================
--              ÁREA EXCURSIONES
-- =============================================

/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del esquema "Actividades" y de las
tablas asociadas a la lógica del mismo. 
*/

USE SGParquesNacionales
GO

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
        CREATE TABLE Area_Excursiones.actividad(
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
