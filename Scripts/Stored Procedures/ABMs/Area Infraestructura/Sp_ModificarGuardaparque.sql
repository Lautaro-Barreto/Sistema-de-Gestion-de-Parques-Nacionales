/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para
modificar un guardaparque. 
*/

USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_ModificarGuardaparque
    @IdGuardaparque INT,
    @Dni CHAR(8) = NULL,
    @Nombre VARCHAR(30) = NULL,
    @Apellido VARCHAR(30) = NULL,
    @Fecha_Ingreso DATE = NULL,
    @Fecha_Egreso DATE = NULL
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		-- Validamos existencia
		IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Guardaparque WHERE IdGuardaparque = @IdGuardaparque)
		BEGIN
			PRINT('No existe un guardaparque con el Id proporcionado.');
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

			UPDATE Area_Infraestructura.Guardaparque
			SET Nombre = @Nombre
			WHERE IdGuardaparque = @IdGuardaparque;
		END

		-- Modificar Apellido
		IF @Apellido IS NOT NULL AND @Apellido <> ''
		BEGIN
			SET @Apellido = TRIM(@Apellido);
			IF @Apellido LIKE '%[^a-zA-Z ]%' OR LEN(@Apellido) > 25
			BEGIN
				PRINT('El apellido no es v lido');
				RAISERROR('.', 16, 1);
			END

			UPDATE Area_Infraestructura.Guardaparque
			SET Apellido = @Apellido
			WHERE IdGuardaparque = @IdGuardaparque;
		END

		-- Modificar DNI
		IF @DNI IS NOT NULL AND @DNI <> ''
		BEGIN
			SET @DNI = TRIM(@DNI);
			IF @DNI LIKE '%[^0-9]%' OR LEN(@DNI) > 10
			BEGIN
				PRINT('El DNI no es v lido');
				RAISERROR('.', 16, 1);
			END

			-- Validar que no exista otro guardaparque con el mismo DNI
			IF EXISTS (
				SELECT 1 FROM Area_Infraestructura.Guardaparque 
				WHERE DNI = @DNI AND IdGuardaparque <> @IdGuardaparque
			)
			BEGIN
				PRINT('Ya existe otro guardaparque con el DNI ingresado.');
				RAISERROR('.', 16, 1);
			END

			UPDATE Area_Infraestructura.Guardaparque
			SET DNI = @DNI
			WHERE IdGuardaparque = @IdGuardaparque;
		END

        -- Modificar Fecha de Ingreso
        IF @Fecha_Ingreso IS NOT NULL
        BEGIN
            IF @Fecha_Ingreso > GETDATE()
            BEGIN
                PRINT('La fecha de ingreso no puede ser futura.');
                RAISERROR('.', 16, 1);
            END

            UPDATE Area_Infraestructura.Guardaparque
            SET Fecha_Ingreso = @Fecha_Ingreso
            WHERE IdGuardaparque = @IdGuardaparque;
        END

        -- Modificar Fecha de Egreso
        IF @Fecha_Egreso IS NOT NULL
        BEGIN
            IF @Fecha_Egreso < @Fecha_Ingreso OR @Fecha_Egreso > GETDATE()
            BEGIN
                PRINT('La fecha de egreso no puede ser anterior a la fecha de ingreso.');
                RAISERROR('.', 16, 1);
            END

            UPDATE Area_Infraestructura.Guardaparque
            SET Fecha_Egreso = @Fecha_Egreso
            WHERE IdGuardaparque = @IdGuardaparque;
        END

		PRINT('Guardaparque actualizado correctamente.');
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrió  un error al modificar el guardaparque.', 16, 1);
			RETURN;
		END
	END CATCH
END
GO