/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 11/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para eliminar una habilitacion de guía. 
*/

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