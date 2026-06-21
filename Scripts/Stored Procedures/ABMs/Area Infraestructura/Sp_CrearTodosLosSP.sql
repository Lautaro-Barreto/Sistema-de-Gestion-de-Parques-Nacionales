/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 19/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación de todos los  Stored Procedure utilizado para
crear, modificar y eliminar  las tablas del esquema Area_Infraestructura. 
*/

--Primero usar la BD
USE SGParquesNacionales
GO

-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LOS GUARDAPARQUES
-- //////////////////////////////////////////////////////////////


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

-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LOS PARQUES
-- //////////////////////////////////////////////////////////////

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
-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LAS REGIONES
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Infraestructura.SP_CrearRegion
    @Nombre VARCHAR(80)
AS
BEGIN
    BEGIN TRY

        -- Validamos nombre ingresado. Si es valido, quitamos espacios al string
        IF @Nombre ='' OR @Nombre LIKE '%[^a-zA-Z ]%' OR LEN(@Nombre) > 80
        BEGIN
            PRINT('El nombre ingresado no es valido')
            RAISERROR('.', 16,1)
        END
        SET @Nombre = TRIM(@Nombre)

        -- El nombre no puede ser repetido
        SET NOCOUNT ON;
        DECLARE @IdRegionRepetida INT;
        SELECT @IdRegionRepetida = r.IdRegion FROM Area_Infraestructura.Region r WHERE r.Nombre = @Nombre;
        IF @IdRegionRepetida IS NOT NULL
        BEGIN
            PRINT('Ya existe una region con ese nombre')
            RETURN @IdRegionRepetida;
        END
        
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY()>10
        BEGIN	
            RAISERROR('Algo salio mal en el registro de la region',16,1);
            RETURN;
        END
    END CATCH
    
    INSERT INTO Area_Infraestructura.Region(Nombre) VALUES (@Nombre)
    DECLARE @IdNuevaRegion INT
	SET @IdNuevaRegion = SCOPE_IDENTITY()
	RETURN @IdNuevaRegion
END
GO

-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LAS PROVINCIAS
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Infraestructura.SP_CrearProvincia
    @Nombre VARCHAR(80),
    @NombreRegion VARCHAR(30)
AS
BEGIN
    BEGIN TRY
        -- Validamos nombre ingresado. Si es valido, quitamos espacios al string
        IF @Nombre ='' OR @Nombre LIKE '%[^a-zA-Z ]%' OR LEN(@Nombre) > 80
        BEGIN
            PRINT('El nombre ingresado no es valido')
            RAISERROR('.', 16,1)
        END
        SET @Nombre = TRIM(@Nombre)

        -- El nombre no puede ser repetido
        SET NOCOUNT ON;
        DECLARE @IdProvinciaRepetida INT;
        SELECT @IdProvinciaRepetida = p.IdProvincia FROM Area_Infraestructura.Provincia p WHERE p.Nombre = @Nombre;
        IF @IdProvinciaRepetida IS NOT NULL
        BEGIN
            PRINT('Ya existe una provincia con ese nombre')
            RETURN @IdProvinciaRepetida;
        END

        -- Validamos region ingresada. Si es valida, quitamos espacios al string
        IF @NombreRegion = '' OR @NombreRegion LIKE '%[^a-zA-Z ]%' OR LEN(@NombreRegion) > 80
        BEGIN
            PRINT('La region ingresada no es valida')
            RAISERROR('.', 16,1)
        END
        SET @NombreRegion = TRIM(@NombreRegion)

        -- La region debe existir en la bbdd
        DECLARE @IdRegion INT;
        SELECT @IdRegion = r.IdRegion FROM Area_Infraestructura.Region r WHERE r.Nombre = @NombreRegion;
        IF @IdRegion IS NULL
        BEGIN
            PRINT('La region ingresada no existe')
            RAISERROR('.', 16,1)
        END
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY()>10
        BEGIN	
            RAISERROR('Algo salio mal en el registro de la provincia',16,1);
            RETURN;
        END
    END CATCH
    
    INSERT INTO Area_Infraestructura.Provincia(Nombre, IDRegion) VALUES (@Nombre, @IdRegion)
    DECLARE @IdNuevaProvincia INT
	SET @IdNuevaProvincia = SCOPE_IDENTITY()
	RETURN @IdNuevaProvincia
END
GO
-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LOS TIPOS DE PARQUE
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Infraestructura.SP_CrearTipoParque
    @Descripcion VARCHAR(50)
AS
BEGIN
    BEGIN TRY

        -- Validamos descripcion ingresada. Si es valida, quitamos espacios al string
        IF @Descripcion ='' OR @Descripcion LIKE '%[^a-zA-Z ]%' OR LEN(@Descripcion) > 50
        BEGIN
            PRINT('La descripcion ingresada no es valida')
            RAISERROR('.', 16,1)
        END
        SET @Descripcion = TRIM(@Descripcion)

        -- La descripcion no puede ser repetida
        SET NOCOUNT ON;
        DECLARE @IdTipoParqueRepetido INT;
        SELECT @IdTipoParqueRepetido = tp.IdTipoParque FROM Area_Infraestructura.Tipo_Parque tp WHERE tp.Descripcion = @Descripcion;
        IF @IdTipoParqueRepetido IS NOT NULL
        BEGIN
            PRINT('Ya existe un tipo de parque con esa descripcion')
            RETURN @IdTipoParqueRepetido;
        END

    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY()>10
        BEGIN	
            RAISERROR('Algo salio mal en el registro deL tipo de parque',16,1);
            RETURN;
        END
    END CATCH

    INSERT INTO Area_Infraestructura.Tipo_Parque(Descripcion) VALUES (@Descripcion)
    DECLARE @IdNuevoTipoParque INT
	SET @IdNuevoTipoParque = SCOPE_IDENTITY()
	RETURN @IdNuevoTipoParque
END
GO

-- //////////////////////////////////////////////////////////////
--                  APARTADO 2: SPs de Modificación
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
--                  MODIFICACIÓN DE GUARDAPARQUES
-- //////////////////////////////////////////////////////////////
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
-- //////////////////////////////////////////////////////////////
--                  MODIFICACIÓN DE PARQUES
-- //////////////////////////////////////////////////////////////
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
-- //////////////////////////////////////////////////////////////
--                  MODIFICACIÓN DE REGIONES
-- //////////////////////////////////////////////////////////////
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

-- //////////////////////////////////////////////////////////////
--                  MODIFICACIÓN DE TIPOS DE PARQUE
-- //////////////////////////////////////////////////////////////
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

-- //////////////////////////////////////////////////////////////
--                  APARTADO 3: SPs de Eliminación
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
--                  ELIMINACIÓN DE GUARDAPARQUES
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Infraestructura.SP_EliminarGuardaparque
    @IdGuardaparque INT
AS
BEGIN
    BEGIN TRY

        -- Validamos que el IdGuardaparque ingresado exista en la BBDD
        SET NOCOUNT ON;
        DECLARE @IdGuardaparqueExistente INT;
        SELECT @IdGuardaparqueExistente = g.IdGuardaparque FROM Area_Infraestructura.Guardaparque g WHERE g.IdGuardaparque = @IdGuardaparque;
        IF @IdGuardaparqueExistente IS NULL
        BEGIN
            PRINT('No existe un guardaparque con ese Id')
            RETURN;
        END

    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY()>10
        BEGIN	
            RAISERROR('Algo salio mal en la eliminacion del guardaparque',16,1);
            RETURN;
        END
    END CATCH
    DELETE FROM Area_Infraestructura.Historial_Trabajo_Guardaparque WHERE IdGuardaparque = @IdGuardaparque;
    DELETE FROM Area_Infraestructura.Guardaparque WHERE IdGuardaparque = @IdGuardaparque;
END
GO
-- //////////////////////////////////////////////////////////////
--                  ELIMINACIÓN DE PARQUES
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_EliminarParque
    @IdParque INT
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        -- Validamos existencia
        IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @IdParque)
        BEGIN
            PRINT('No existe un parque con el Id proporcionado.');
            RAISERROR('', 16, 1);
            RETURN;
        END

        -- Borrado lógico del parque
        UPDATE Area_Infraestructura.Parque
        SET Activo = 0
        WHERE IdParque = @IdParque;

    END TRY

    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
        BEGIN
            RAISERROR('Ocurrió un error al eliminar el parque.', 16, 1);
            RETURN;
        END
    END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--                  ELIMINACIÓN DE PROVINCIA
-- //////////////////////////////////////////////////////////////

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
-- //////////////////////////////////////////////////////////////
--                  ELIMINACIÓN DE REGIÓN
-- //////////////////////////////////////////////////////////////
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

--///////////////////////////////////////////////////////////////end