/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 11/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para eliminar un punto de venta. 
*/

USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Comercial.SP_EliminarPuntoDeVenta
	@IdPuntoDeVenta INT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		--El punto de venta debe estar cargado en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Punto_De_Venta WHERE IdPuntoDeVenta = @IdPuntoDeVenta)
        BEGIN
            PRINT('Punto de venta inexistente')
            RAISERROR('.', 16, 1)
        END
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en la eliminacion del punto de venta', 16, 1);
			RETURN;
		END
	END CATCH

	DELETE FROM Area_Comercial.Venta WHERE IdPuntoDeVenta = @IdPuntoDeVenta
	DELETE FROM Area_Comercial.Punto_De_Venta WHERE IdPuntoDeVenta = @IdPuntoDeVenta
END
GO