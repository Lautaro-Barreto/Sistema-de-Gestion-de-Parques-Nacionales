/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 11/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para eliminar un detalle de venta de entradas. 
*/

USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Comercial.SP_EliminarDetalleVentaEntrada
	@IdDetalle INT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		--El detalle debe estar cargado en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Detalle_Venta_Entrada WHERE IdDetalle = @IdDetalle)
        BEGIN
            PRINT('Detalle de venta inexistente')
            RAISERROR('.', 16, 1)
        END
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en la eliminacion del detalle de venta de entradas', 16, 1);
			RETURN;
		END
	END CATCH

	DELETE FROM Area_Comercial.Detalle_Venta_Entrada WHERE IdDetalle = @IdDetalle
END
GO