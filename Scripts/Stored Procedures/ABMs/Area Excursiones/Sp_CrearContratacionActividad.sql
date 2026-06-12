/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para crear un una contratación de actividad.
*/


USE SGParquesNacionales
go
CREATE PROCEDURE Area_Excursiones.Sp_CrearContratacion_Actividad
    @IdVenta INT, 
    @IdActividad INT,
    @Monto decimal(10, 2)
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Actividad WHERE IdActividad = @IdActividad)
        BEGIN
            RAISERROR('La actividad no existe.', 16, 1)
            RETURN  
        END

        IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Venta WHERE IdVenta = @IdVenta)
        BEGIN
            RAISERROR('La venta no existe.', 16, 1)
        END

        IF @Monto < 0
        BEGIN
            RAISERROR('El monto no puede ser negativo.', 16, 1)
        END

    END TRY

    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
        BEGIN
            RAISERROR('Ocurrió un error al crear la contratación de actividad.', 16, 1)
            RETURN
        END
    END CATCH

    INSERT INTO Area_Excursiones.Contratacion_Actividad (IdVenta, IdActividad, Monto)
    VALUES (@IdVenta, @IdActividad, @Monto)
    DECLARE @idNueva_ContratacionActividad INT
    SET @idNueva_ContratacionActividad = SCOPE_IDENTITY()   
    RETURN @idNueva_ContratacionActividad

END
go
