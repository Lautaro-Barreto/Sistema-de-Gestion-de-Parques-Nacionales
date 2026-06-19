/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para
modificar un tipo de parque. 
*/

USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_ModificarRegion
	@IdRegion INT,
	@Nombre VARCHAR(50) = NULL
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

		-- Modificar Nombre
		IF @Nombre IS NOT NULL AND @Nombre <> ''
		BEGIN
			SET @Nombre = TRIM(@Nombre);
			IF @Nombre LIKE '%[^a-zA-Z ]%' OR LEN(@Nombre) > 50
			BEGIN
				PRINT('El nombre no es válido');
				RAISERROR('.', 16, 1);
			END

			UPDATE Area_Infraestructura.Region
			SET Nombre = @Nombre
			WHERE IdRegion = @IdRegion;
		END

	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrió  un error al modificar la región.', 16, 1);
			RETURN;
		END
	END CATCH
END
GO