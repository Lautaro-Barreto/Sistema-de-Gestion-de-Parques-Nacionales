/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 11/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para eliminar una forma de pago. 
*/

USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Comercial.SP_EliminarFormaDePago
	@IdFormaDePago INT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		--La forma de pago debe estar cargada en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Forma_De_Pago WHERE IdFormaDePago = @IdFormaDePago)
        BEGIN
            PRINT('Forma de pago inexistente')
            RAISERROR('.', 16, 1)
        END
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en la eliminacion de la forma de pago', 16, 1);
			RETURN;
		END
	END CATCH

	DELETE FROM Area_Comercial.Venta WHERE IdFormaDePago = @IdFormaDePago
	DELETE FROM Area_Comercial.Forma_De_Pago WHERE IdFormaDePago = @IdFormaDePago
END
GO