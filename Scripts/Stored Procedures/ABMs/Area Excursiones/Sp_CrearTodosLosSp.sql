/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 19/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación de todos los  Stored Procedure utilizado para
crear, modificar y eliminar las tablas del esquema Area_Excursiones. 
*/

--Primero usar la BD
USE SGParquesNacionales
GO

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
--            ELIMINACIÓN DE GUIAS
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