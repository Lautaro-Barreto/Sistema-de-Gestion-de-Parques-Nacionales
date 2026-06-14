/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para eliminar un descuento asociado a un parque.  
*/

USE SGParquesNacionales
GO
CREATE OR ALTER PROCEDURE Area_Comercial.Sp_EliminarDescuentoParque
    @IdDescuento INT
AS
BEGIN
    BEGIN TRY

    --El descuento debe estar cargado en la DB
    IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Descuento_Parque WHERE IdDescuento = @IdDescuento)
        BEGIN
            PRINT('Descuento inexistente')
            RAISERROR('.', 16, 1)
        END
    END TRY

    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
        BEGIN	
            RAISERROR('Algo salio mal en la eliminación del descuento', 16, 1);
            RETURN;
        END
    END CATCH

    DELETE FROM Area_Comercial.Descuento_Parque WHERE IdDescuento = @IdDescuento;
END
GO