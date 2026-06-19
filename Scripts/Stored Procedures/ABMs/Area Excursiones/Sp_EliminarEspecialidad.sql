/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 11/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para eliminar una especialidad. 
*/

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