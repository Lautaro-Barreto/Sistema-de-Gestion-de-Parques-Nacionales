/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para modificar una contratación de actividad.
*/

USE SGParquesNacionales
GO

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