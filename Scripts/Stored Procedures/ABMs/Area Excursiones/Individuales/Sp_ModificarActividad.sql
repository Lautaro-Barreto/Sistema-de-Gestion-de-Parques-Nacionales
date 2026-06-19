/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para modificar una actividad.
*/

USE SGParquesNacionales
GO

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