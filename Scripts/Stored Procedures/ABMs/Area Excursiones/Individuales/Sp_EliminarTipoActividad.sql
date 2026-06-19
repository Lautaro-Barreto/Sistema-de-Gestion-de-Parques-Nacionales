/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 11/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para modificar un tipo de actividad. 
*/

USE SGParquesNacionales
GO

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