/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para eliminar una contratacion de actividad.
*/

USE SGParquesNacionales
GO

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