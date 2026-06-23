/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 11/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para eliminar un registro de Guía y todas sus dependencias. 
*/

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