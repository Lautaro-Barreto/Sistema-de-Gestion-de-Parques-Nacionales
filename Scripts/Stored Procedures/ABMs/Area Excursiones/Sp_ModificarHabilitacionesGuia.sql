/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para modificar la fecha de validez de una habilitación para un guía.
*/

USE SGParquesNacionales
GO

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