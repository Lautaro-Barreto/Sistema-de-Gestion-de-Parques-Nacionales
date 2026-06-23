/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 22/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para eliminar  guía. 
*/

CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_EliminarGuia
    @IdGuia INT
AS
BEGIN 
    BEGIN TRY 
        SET NOCOUNT ON;
        -- Validar que el guía exista
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Sp_)
        

        DELETE FROM Area_Excursiones.Guia
        WHERE IdGuia = @IdGuia
        PRINT 'Guia eliminado Correctamente'
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