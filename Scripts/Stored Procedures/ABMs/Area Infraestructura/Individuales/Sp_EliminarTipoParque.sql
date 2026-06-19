/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para
eliminar un tipo de parque. 
*/

USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_EliminarTipoParque
	@IdTipoParque INT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		-- Validamos existencia
		IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Tipo_Parque WHERE IdTipoParque = @IdTipoParque)
		BEGIN
			PRINT('No existe un tipo de parque con el Id proporcionado.');
			RETURN;
		END

        -- Seteamos en null el tipo para los parques que lo tengan asignado
        UPDATE Area_Infraestructura.Parque
        SET IdTipoParque = NULL
        WHERE IdTipoParque = @IdTipoParque;

		-- Eliminar tipo de parque
		DELETE FROM Area_Infraestructura.Tipo_Parque
		WHERE IdTipoParque = @IdTipoParque;

	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrió  un error al eliminar el tipo de parque.', 16, 1);
			RETURN;
		END
	END CATCH
END
GO