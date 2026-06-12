/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para
eliminar una provincia. 
*/

USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_EliminarProvincia
	@IdProvincia INT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		-- Validamos existencia
		IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Provincia WHERE IdProvincia = @IdProvincia)
		BEGIN
			PRINT('No existe una provincia con el Id proporcionado.');
			RETURN;
		END

        -- Seteamos en null la región para los parques que lo tengan asignado
        UPDATE Area_Infraestructura.Parque
        SET IdProvincia = NULL
        WHERE IdProvincia = @IdProvincia;

		-- Eliminar provincia
		DELETE FROM Area_Infraestructura.Provincia
		WHERE IdProvincia = @IdProvincia;

	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrió  un error al eliminar la provincia.', 16, 1);
			RETURN;
		END
	END CATCH
END
GO