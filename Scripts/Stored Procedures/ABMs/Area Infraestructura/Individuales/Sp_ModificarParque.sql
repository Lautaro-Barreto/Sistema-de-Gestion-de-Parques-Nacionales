/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para
modificar un parque. 
*/

USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_ModificarParque
	@IdParque INT,
	@Provincia VARCHAR(30) = NULL,
	@TipoParque VARCHAR(30) = NULL,
	@Nombre VARCHAR(80) = NULL,
	@Superficie DECIMAL(14,4) = NULL,
	@Activo BIT = NULL
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		-- Validamos existencia
		IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @IdParque)
		BEGIN
			PRINT('No existe un parque con el Id proporcionado.');
			RETURN;
		END

		-- Modificar Nombre
		IF @Nombre IS NOT NULL AND @Nombre <> ''
		BEGIN
			SET @Nombre = TRIM(@Nombre);
			IF @Nombre LIKE '%[^a-zA-Z ]%' OR LEN(@Nombre) > 25
			BEGIN
				PRINT('El nombre no es v lido');
				RAISERROR('.', 16, 1);
			END

			UPDATE Area_Infraestructura.Parque
			SET Nombre = @Nombre
			WHERE IdParque = @IdParque;
		END

		-- Modificar Provincia
		IF @Provincia IS NOT NULL AND @Provincia <> ''
		BEGIN
			SET @Provincia = TRIM(@Provincia);
			IF @Provincia LIKE '%[^a-zA-Z ]%' OR LEN(@Provincia) > 30
			BEGIN
				PRINT('El apellido no es v lido');
				RAISERROR('.', 16, 1);
			END
			IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Provincia WHERE Nombre = @Provincia)
			BEGIN
				PRINT('La provincia no es valida');
				RAISERROR('.',18,1);
			END
			DECLARE @IdDeProvinciaNueva INT;
			SELECT @IdDeProvinciaNueva = IdProvincia FROM Area_Infraestructura.Provincia WHERE Nombre = @Provincia
			UPDATE Area_Infraestructura.Parque
			SET IdProvincia = @IdDeProvinciaNueva
			WHERE IdParque = @IdParque;
		END

		-- Modificar Tipo de Parque
		IF @TipoParque IS NOT NULL AND @TipoParque <> ''
		BEGIN
			SET @TipoParque = TRIM(@TipoParque);
			IF @TipoParque LIKE '%[^a-zA-Z ]%' OR LEN(@TipoParque) > 30
			BEGIN
				PRINT('El tipo de parque no es valido');
				RAISERROR('.', 16, 1);
			END
			IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Tipo_Parque WHERE Descripcion = @TipoParque)
			BEGIN
				PRINT('El tipo de parque no es valido');
				RAISERROR('.',16,1);
			END
			DECLARE @IdDeTipoParqueNuevo INT;
			SELECT  @IdDeTipoParqueNuevo = IdProvincia FROM Area_Infraestructura.Provincia WHERE Nombre = @Provincia
			UPDATE Area_Infraestructura.Parque
			SET IdTipoParque = @IdDeTipoParqueNuevo
			WHERE IdParque = @IdParque;
		END

		-- Modificar Superficie
		IF @Superficie IS NULL OR @Superficie < 0
		BEGIN
            PRINT('La superficie no es valida');
            RAISERROR('.', 16, 1);
		END
        UPDATE Area_Infraestructura.Parque
		SET Superficie = @Superficie
		WHERE IdParque = @IdParque;

		-- Modficar si esta o no activo
		IF @Activo IS NOT NULL
		BEGIN
			UPDATE Area_Infraestructura.Parque
			SET Activo = @Activo
			WHERE IdParque = @IdParque;
		END

		PRINT('Parque actualizado correctamente.');
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrió  un error al modificar el parque.', 16, 1);
			RETURN;
		END
	END CATCH
END
GO