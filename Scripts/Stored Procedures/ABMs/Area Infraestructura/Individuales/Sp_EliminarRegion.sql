/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para
eliminar una región. 
*/

USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_EliminarRegion
	@IdRegion INT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		-- Validamos existencia
		IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Region WHERE IdRegion = @IdRegion)
		BEGIN
			PRINT('No existe una región con el Id proporcionado.');
			RETURN;
		END

        -- Seteamos en null la región para las provincias que la tengan asignado
        UPDATE Area_Infraestructura.Provincia
        SET IdRegion = NULL
        WHERE IdRegion = @IdRegion;

		-- Eliminar región
		DELETE FROM Area_Infraestructura.Region
		WHERE IdRegion = @IdRegion;

	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrió  un error al eliminar la región.', 16, 1);
			RETURN;
		END
	END CATCH
END
GO