/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 11/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para eliminar un tipo de visitante. 
*/

USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Comercial.SP_EliminarTipoDeVisitante
	@IdTipoVisitante INT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		--El tipo de visitante debe estar cargado en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Tipo_Visitante WHERE IdTipoVisitante = @IdTipoVisitante)
        BEGIN
            PRINT('Tipo de visitante inexistente')
            RAISERROR('.', 16, 1)
        END
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en la eliminacion del tipo de visitante', 16, 1);
			RETURN;
		END
	END CATCH

	DELETE FROM Area_Comercial.Entrada WHERE IdTipoVisitante = @IdTipoVisitante
	DELETE FROM Area_Comercial.Tipo_Visitante WHERE IdTipoVisitante = @IdTipoVisitante
END
GO