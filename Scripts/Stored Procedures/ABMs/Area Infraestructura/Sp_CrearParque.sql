/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para
crear un parque nacional. 
*/

use SGParquesNacionales
go

CREATE OR ALTER PROCEDURE Area_Infraestructura.SP_CrearParque 
	@Nombre VARCHAR(80),
	@TipoParqueDesc VARCHAR(50),
	@Provincia VARCHAR(80),
	@Superficie DECIMAL(14,4)
AS
BEGIN
	BEGIN TRY
			
			-- Validamos nombre ingresado. Si es valido, limpiamos el string
			IF @Nombre ='' OR @Nombre LIKE '%[^a-zA-Z ]%' OR LEN(@Nombre) > 80
			BEGIN
				PRINT('El nombre ingresado no es valido')
				RAISERROR('.', 16,1)
			END
			SET @Nombre = TRIM(@Nombre)

			-- El nombre no puede ser repetido
			SET NOCOUNT ON;
			DECLARE @IdParqueRepetido INT;
			SELECT @IdParqueRepetido = p.IdParque FROM Area_Infraestructura.Parque p WHERE p.Nombre = @Nombre;
			IF @IdParqueRepetido IS NOT NULL
			BEGIN
				PRINT('Ya existe un parque con ese nombre')
				RETURN @IdParqueRepetido;
			END

			-- Validamos provincia ingresada
			IF @Provincia = '' OR @Provincia LIKE '%[^a-zA-Z ]%' OR LEN(@Provincia) > 80
			BEGIN
				PRINT('La provincia ingresada no es valida')
				RAISERROR('.', 16,1)
			END

			-- La provincia debe existir en la bbdd
			DECLARE @IdProvincia INT;
			SELECT @IdProvincia = pr.IdProvincia FROM Area_Infraestructura.Provincia pr WHERE pr.Nombre = @Provincia;
			IF @IdProvincia IS NULL
			BEGIN
				PRINT('La provincia ingresada no existe')
				RAISERROR('.', 16,1)
			END

			-- Validamos tipo de parque ingresado
			IF @TipoParqueDesc = '' OR @TipoParqueDesc LIKE '%[^a-zA-Z ]%' OR LEN(@TipoParqueDesc) > 80
			BEGIN
				PRINT('El tipo de parque ingresado no es valido')
				RAISERROR('.', 16,1)
			END

			-- EL tipo de parque debe estar cargado en la bbdd
			DECLARE @IdTipoParque INT;
			SELECT @IdTipoParque = t.IdTipoParque FROM Area_Infraestructura.Tipo_Parque t WHERE t.Descripcion = @TipoParqueDesc;
			IF @IdTipoParque IS NULL
			BEGIN
				PRINT('El tipo de parque ingresado no existe')
				RAISERROR('.', 16,1)
			END

			-- La superficie debe ser un valor decimal valido
			IF @Superficie = 0
			BEGIN
				PRINT('El valor de la superficie no es una dimension valida')
				RAISERROR('.', 16,1)
			END

	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY()>10
		BEGIN	
			RAISERROR('Algo salio mal en el registro del parque',16,1);
			RETURN;
		END
	END CATCH

	INSERT INTO Area_Infraestructura.Parque(IdProvincia, IdTipoParque, Nombre, Superficie, Activo) VALUES
	(@IdProvincia, @IdTipoParque, @Nombre, @Superficie, 1);
	DECLARE @IdNuevoParque INT
	SET @IdNuevoParque = SCOPE_IDENTITY()
	RETURN @IdNuevoParque
END
GO