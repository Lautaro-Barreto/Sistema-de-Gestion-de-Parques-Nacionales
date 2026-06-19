/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 11/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para eliminar una habilitacion de guía. 
*/
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_EliminarHabilitacionesPorActividad
    @IdActividad INT,
    @IdHabilitacion INT
AS

BEGIN 
    BEGIN TRY 
        SET NOCOUNT ON;
        -- Validar que la actividad exista
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Actividad WHERE IdActividad = @IdActividad )
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