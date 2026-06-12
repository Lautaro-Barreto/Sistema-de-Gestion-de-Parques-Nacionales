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

CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_ModificarTipoParque
	@IdTipoParque INT,
	@Descripcion VARCHAR(50) = NULL
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		-- Validamos existencia
		IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.TipoParque WHERE IdTipoParque = @IdTipoParque)
		BEGIN
			PRINT('No existe un tipo de parque con el Id proporcionado.');
			RETURN;
		END

		-- Modificar Descripción
		IF @Descripcion IS NOT NULL AND @Descripcion <> ''
		BEGIN
			SET @Descripcion = TRIM(@Descripcion);
			IF @Descripcion LIKE '%[^a-zA-Z ]%' OR LEN(@Descripcion) > 50
			BEGIN
				PRINT('La descripción no es válida');
				RAISERROR('.', 16, 1);
			END

			UPDATE Area_Infraestructura.TipoParque
			SET Descripcion = @Descripcion
			WHERE IdTipoParque = @IdTipoParque;
		END

	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrió  un error al modificar el tipo de parque.', 16, 1);
			RETURN;
		END
	END CATCH
END
GO