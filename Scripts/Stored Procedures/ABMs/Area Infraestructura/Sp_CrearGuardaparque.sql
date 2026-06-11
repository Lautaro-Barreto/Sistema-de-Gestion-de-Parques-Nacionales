/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para
crear un guardaparque. 
*/

CREATE OR ALTER PROCEDURE Area_Infraestructura.SP_CrearGuardaParque
	@Nombre VARCHAR(30),
	@Apellido VARCHAR(30),
	@Dni CHAR(8),
	@Parque VARCHAR(80),
	@Fecha_Ingreso DATE,
	@Fecha_Egreso DATE,
	@Activo BIT
AS
BEGIN
	BEGIN TRY
			
			-- Validamos nombre ingresado. Si es valido, quitamos espacios al string
			IF @Nombre ='' OR @Nombre LIKE '%[^a-zA-Z ]%' OR LEN(@Nombre) > 30
			BEGIN
				PRINT('El nombre ingresado no es valido')
				RAISERROR('.', 16,1)
			END
			SET @Nombre = TRIM(@Nombre)
			
			-- Validamos apellido ingresado. Si es valido, quitamos espacios al string
			IF @Apellido ='' OR @Apellido LIKE '%[^a-zA-Z ]%' OR LEN(@Apellido) > 30
			BEGIN
				PRINT('El apellido ingresado no es valido')
				RAISERROR('.', 16,1)
			END
			SET @Apellido = TRIM(@Apellido)

			-- El dni no puede ser repetido
			SET NOCOUNT ON;
			DECLARE @IdGuardaRepetido INT;
			SELECT @IdGuardaRepetido = g.IdGuardaparque FROM Area_Infraestructura.Guardaparque g WHERE g.Dni = @Dni;
			IF @IdGuardaRepetido IS NOT NULL
			BEGIN
				PRINT('Ya existe un guardaparque con ese dni')
				RETURN @IdGuardaRepetido;
			END

			-- El parque debe existir en la BBDD
			DECLARE @IdParque INT;
			SELECT @IdParque = p.IdParque FROM Area_Infraestructura.Parque p WHERE p.Nombre = @Parque;
			IF @IdParque IS NULL
			BEGIN
				PRINT('El parque ingresado no existe')
				RAISERROR('.', 16,1)
			END

			-- El campo activo solo puede ser 0 o 1
			IF @Activo NOT IN (0,1)
			BEGIN
				PRINT('El campo activo solo puede ser 0 o 1')
				RAISERROR('.', 16,1)
			END

			-- validaciones de fechas

			 -- La fecha de egreso no puede ser menor a la fecha de ingreso
			IF @Fecha_Egreso < @Fecha_Ingreso
			BEGIN
				PRINT('La fecha de egreso no puede ser menor a la fecha de ingreso')
				RAISERROR('.', 16,1)
			END

            DECLARE @FechaActual DATE
			SET @FechaActual = GETDATE()
			
			 -- La fecha de ingreso no puede ser mayor a la fecha actual
			IF @Fecha_Ingreso > @FechaActual
			BEGIN
				PRINT('La fecha de ingreso no puede ser mayor a la fecha actual')
				RAISERROR('.', 16,1)
			END

			 -- La fecha de egreso no puede ser mayor a la fecha actual
			IF @Fecha_Egreso > @FechaActual
			BEGIN
				PRINT('La fecha de egreso no puede ser mayor a la fecha actual')
				RAISERROR('.', 16,1)
			END

	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY()>10
		BEGIN	
			RAISERROR('Algo salio mal en el registro del guardaparque',16,1);
			RETURN;
		END
	END CATCH

	INSERT INTO Area_Infraestructura.Guardaparque(Nombre, Apellido, Dni, IdParque, Fecha_Ingreso, Fecha_Egreso, Activo) VALUES
	(@Nombre, @Apellido, @Dni, @IdParque, @Fecha_Ingreso, @Fecha_Egreso, @Activo);
	DECLARE @IdNuevoGuardaparque INT
	SET @IdNuevoGuardaparque = SCOPE_IDENTITY()
	RETURN @IdNuevoGuardaparque
END
GO

