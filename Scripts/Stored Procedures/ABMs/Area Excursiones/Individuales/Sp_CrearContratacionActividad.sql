/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para crear un una contratación de actividad.
*/

--SELECT * FROM Area_Excursiones.Contratacion_Actividad 
USE SGParquesNacionales
go
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_CrearContratacion_Actividad
    @IdVenta INT, 
    @IdActividad INT,
    @Monto decimal(10, 2),
    @FechaContratacion DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Actividad WHERE IdActividad = @IdActividad AND Activo = 1)
        BEGIN
            RAISERROR('La actividad no existe.', 16, 1)
        END

        IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Venta WHERE IdVenta = @IdVenta)
        BEGIN
            RAISERROR('La venta no existe.', 16, 1)
        END

        IF @Monto < 0
        BEGIN
            RAISERROR('El monto no puede ser negativo.', 16, 1)
        END

    INSERT INTO Area_Excursiones.Contratacion_Actividad (IdVenta, IdActividad, Monto, Fecha_Contratacion)
    VALUES (@IdVenta, @IdActividad, @Monto, @FechaContratacion)
    DECLARE @idNueva_ContratacionActividad INT
    SET @idNueva_ContratacionActividad = SCOPE_IDENTITY()   
    RETURN @idNueva_ContratacionActividad


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
