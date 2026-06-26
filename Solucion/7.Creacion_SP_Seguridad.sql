/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 26/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script unifica la creación o alteración de todos los store procedures
usados en el apartado de seguridad
*/

USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Infraestructura.SP_ConsultarDatosParque_Guardaparque
    @NombreParque varchar(50)
AS
BEGIN
    BEGIN TRY
        --Buscar para este Guardaparque el parque que quiere ver
        --y comprobar que está asociado al mismo.
        DECLARE @IdParque INT;
        SELECT @IdParque = IdParque FROM Area_Infraestructura.Parque WHERE Nombre = @NombreParque
        IF @IdParque IS NULL
        BEGIN
            PRINT 'No se encontró el parque a acceder.'
            RAISERROR('La operación no se pudo completar: Parque inexistente',16,1);
        END
        --Ahora fijarnos que el guardaparque esté asociado al parque
        IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Guardaparque WHERE IdParque = @IdParque 
                        AND (IS_ROLEMEMBER('Rol_Guardaparque_Base') = 1 OR 
                        IS_ROLEMEMBER('Rol_Jefe_Guardaparques') = 1))
        BEGIN   
                PRINT 'Permiso Denegado: No puede acceder a ver la información del parque.'
                RAISERROR('La operación no se pudo completar: Permiso denegado',16,1);
        END
        SELECT 
            *
        FROM Area_Infraestructura.Parque
        WHERE IdParque = @IdParque;

        PRINT '#Viendo: Información del parque';
    END TRY
    BEGIN CATCH
        RAISERROR('Algo salió mal en la operación: No se pudo mostrar la información del parque', 16, 1);
    END CATCH
END
GO

--///////////////////////////////////////////////7
USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Excursiones.SP_ConsultarGuias_GuiaJefe
AS
BEGIN
    BEGIN TRY
        -- Abrimos la llave simétrica en la sesión actual
        OPEN SYMMETRIC KEY SymKey_DNI_SGPN DECRYPTION BY CERTIFICATE Certificado_DNI_SGPN;
        -- Retornamos el listado completo desencriptando al vuelo
        SELECT 
            IdGuia,
            Nombre,
            Apellido,
            CONVERT(CHAR(8), DecryptByKey(DNI)) AS DNI_TextoClaro,
            Titulo
        FROM Area_Excursiones.Guia;

        PRINT '#Viendo: Guias'
        -- Cerramos la llave inmediatamente
        CLOSE SYMMETRIC KEY SymKey_DNI_SGPN;

    END TRY
    BEGIN CATCH
        -- Nunca está demás check si se abrió
        IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'SymKey_DNI_SGPN')
        BEGIN
            CLOSE SYMMETRIC KEY SymKey_DNI_SGPN;
        END
        RAISERROR('Algo salió mal en la operación: No se pudo mostrar los guías', 16, 1);
    
    END CATCH
END
GO
--//////////////////////////////////////////////////////
USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Excursiones.SP_ConsultarMisDatos_Guia
    @Nombre varchar(30),
    @Apellido varchar(30)
AS
BEGIN
    BEGIN TRY
         IF( @Nombre IS NULL OR LEN(@Nombre) = 0)
        BEGIN
             PRINT 'El nombre debe tener entre 1 y 30 caracteres.'
            RAISERROR('No se pudo completar la operación.', 16, 1)         
        END
         IF( @Apellido IS NULL OR LEN(@Apellido) = 0)
        BEGIN
            PRINT 'El apellido debe tener entre 1 y 30 caracteres.'
            RAISERROR('No se pudo completar la operación.', 16, 1)         
        END

        -- LO NUEVO:
        -- Validamos que el usuario que ejecuta (CURRENT_USER) coincida con el nombre del guía que busca.
        
        IF NOT EXISTS (
            SELECT 1 FROM Area_Excursiones.Guia 
            WHERE Nombre = CONVERT(VARCHAR(30), CURRENT_USER)
        )
        BEGIN
            PRINT 'Lo siento, no puede acceder a datos que no le pertenecen'
            RAISERROR('Acceso denegado: No tiene permisos para consultar datos de otros empleados.', 16, 1);
        END
        --Ahora valido que esté tratando de ver sus datos.
        IF NOT EXISTS (
            SELECT 1 FROM Area_Excursiones.Guia 
            WHERE Nombre = @Nombre AND Apellido = @Apellido
        )
        BEGIN
            PRINT 'No se encontró el guía con ese nombre/Apellido.'
            RAISERROR('No se pudo completar la operación.', 16, 1);
        END
        -- Si pasó la validación, abrimos llave y mostramos SOLO su fila
        
        OPEN SYMMETRIC KEY SymKey_DNI_SGPN DECRYPTION BY CERTIFICATE Certificado_DNI_SGPN;
        SELECT 
            IdGuia,
            Nombre,
            Apellido,
            CONVERT(CHAR(8), DecryptByKey(DNI)) AS DNI_TextoClaro,
            Titulo
        FROM Area_Excursiones.Guia
        WHERE Nombre = Nombre AND Apellido = @Apellido
        PRINT '#Viendo: Tus datos'
        CLOSE SYMMETRIC KEY SymKey_DNI_SGPN;
        
    END TRY
    BEGIN CATCH
        IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'SymKey_DNI_SGPN')
        BEGIN
            CLOSE SYMMETRIC KEY SymKey_DNI_SGPN;
        END

        RAISERROR('La operación no se pudo completar: Ocurrió un error.', 16, 1);
    END CATCH
END
GO
--///////////////////////////////////////////////////////
USE SGParquesNacionales
GO
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_ModificarGuia
    @IdGuia INT,
    @Dni CHAR(8),
    @IdParque INT,
    @IdEspecialidad INT,
    @Nombre VARCHAR(30),
    @Apellido VARCHAR(30),
    @Titulo VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY 
        -- Validar que el guia exista
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Guia WHERE IdGuia = @IdGuia)
        BEGIN
            RAISERROR('El guia con el Id proporcionado no existe.', 16, 1)

        END
        -- Validar que el parque exista
        IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @IdParque)
        BEGIN
            RAISERROR('El parque con el Id proporcionado no existe.', 16, 1)
            
        END
        -- Validar que la especialidad exista
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Especialidad WHERE IdEspecialidad = @IdEspecialidad)
        BEGIN
            RAISERROR('La especialidad con el Id proporcionado no existe.', 16, 1)
            
        END
        --validar que el dni sea válido
        IF (@DNI LIKE '%[^0-9]%' OR LEN(@DNI) NOT BETWEEN 7 AND 8)
        BEGIN
            RAISERROR('DNI inválido: debe contener solo números y tener entre 7 y 8 dígitos.', 16, 1);
        END

        --Para validar los repetidos toca abrir la llave
        OPEN SYMMETRIC KEY SymKey_DNI_SGPN DECRYPTION BY CERTIFICATE Certificado_DNI_SGPN;

        --Ahora desencripta el dni para la comparación
        DECLARE @IdGuiaRepetido INT
        SELECT @IdGuiaRepetido = IdGuia FROM Area_Excursiones.Guia WHERE DecryptByKey(DNI) = @Dni AND IdGuia != @IdGuia
        IF @IdGuiaRepetido IS NOT NULL
        BEGIN
            --cierra la llave  y manda el error
            CLOSE SYMMETRIC KEY SymKey_DNI_SGPN;
            PRINT 'Error: El DNI proporcionado ya está registrado para otro guía.'
            RAISERROR('El DNI proporcionado ya está registrado para otro guía. Guia Numero: %d', 16, 1, @IdGuiaRepetido)
        END

        --validar que el nombre, apellido y título sean válidos
        IF @Nombre IS NULL OR LEN(@Nombre) = 0
        BEGIN
            CLOSE SYMMETRIC KEY SymKey_DNI_SGPN;
            RAISERROR('El nombre debe tener entre 1 y 30 caracteres.', 16, 1) 
        END

        IF @Apellido IS NULL OR LEN(@Apellido) = 0
        BEGIN
            CLOSE SYMMETRIC KEY SymKey_DNI_SGPN;
            RAISERROR('El apellido debe tener entre 1 y 30 caracteres.', 16, 1)   
        END

        IF @Titulo IS NULL OR LEN(@Titulo) = 0
        BEGIN
            CLOSE SYMMETRIC KEY SymKey_DNI_SGPN;    
            RAISERROR('El título debe tener entre 1 y 30 caracteres.', 16, 1)
            
        END

        -- Modificar el guia
        UPDATE Area_Excursiones.Guia
        SET DNI = EncryptByKey(Key_GUID('SymKey_DNI_SGPN'),@Dni),
            IdParque = @IdParque,
            IdEspecialidad = @IdEspecialidad,
            Nombre = @Nombre,
            Apellido = @Apellido,
            Titulo = @Titulo
        WHERE IdGuia = @IdGuia
        
        CLOSE SYMMETRIC KEY SymKey_DNI_SGPN;
        PRINT 'Operación exitosa: Guía modificado.'
    END TRY

    BEGIN CATCH

        --IMPORTANTISIMO: Si la llave no cerró, cerrarla
        IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'SymKey_DNI_SGPN')
        BEGIN
            CLOSE SYMMETRIC KEY SymKey_DNI_SGPN;
        END
        --Nunca está demás
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END 
GO
--///////////////////////////////////////////////////////////
USE SGParquesNacionales
go

CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_CrearGuia
    @DNI CHAR(8),
    @idParque INT,
    @idEspecialidad INT,
    @Nombre VARCHAR(30),
    @Apellido VARCHAR(30),
    @Titulo VARCHAR(30)

AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        --El parque debe estar en la db
        IF NOT EXISTS(SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @idParque)
        BEGIN
            PRINT 'El parque ingresado no existe.';
            RAISERROR('El Parque no existe.', 16, 1)
        END

        --La especialidad debe estar en la db
        IF NOT EXISTS(SELECT 1 FROM Area_Excursiones.Especialidad WHERE IdEspecialidad = @idEspecialidad)
        BEGIN
            PRINT 'La especialidad del guía no se encuentra registrada.';
            RAISERROR('La especialidad no existe.', 16, 1)
            
        END
        --validar que el dni sea válido
        IF (@DNI LIKE '%[^0-9]%' OR LEN(@DNI) NOT BETWEEN 7 AND 8)
        BEGIN
            PRINT('DNI inválido: debe contener solo números y tener entre 7 y 8 dígitos.');
            RAISERROR('DNI inválido: debe contener solo números y tener entre 7 y 8 dígitos.', 16, 1);
        END
        --El dni no debe existir en la db 
        --Pero para comprobar esto necesito abrir la llave de encriptación
        OPEN SYMMETRIC KEY SymKey_DNI_SGPN DECRYPTION BY CERTIFICATE Certificado_DNI_SGPN
        
        IF EXISTS (SELECT 1 FROM Area_Excursiones.Guia WHERE DecryptByKey(DNI) = @DNI)
        BEGIN
            CLOSE SYMMETRIC KEY SymKey_DNI_SGPN ;
            PRINT 'El dni ya se encuentra registrado.'
            RAISERROR('El DNI proporcionado ya está registrado para otro guía.', 16, 1)
        END

        IF( @Nombre IS NULL OR LEN(@Nombre) = 0)
        BEGIN
             PRINT 'El nombre debe tener entre 1 y 30 caracteres.'
            CLOSE SYMMETRIC KEY SymKey_DNI_SGPN ;
            RAISERROR('El nombre debe tener entre 1 y 30 caracteres.', 16, 1)
            
        END

        IF( @Apellido IS NULL OR LEN(@Apellido) = 0)
        BEGIN
             PRINT 'El apellido debe tener entre 1 y 30 caracteres.'
            CLOSE SYMMETRIC KEY SymKey_DNI_SGPN ;
            RAISERROR('El apellido debe tener entre 1 y 30 caracteres.', 16, 1)
            
        END

        IF( @Titulo IS NULL OR LEN(@Titulo) = 0)
        BEGIN
             PRINT 'El Titulo no es válido debe tener entre 1 y 30 caracteres.'
            CLOSE SYMMETRIC KEY SymKey_DNI_SGPN ;
            RAISERROR('El título debe tener entre 1 y 30 caracteres.', 16, 1)
            
        END
        --Reabro la llave por si hubo error.
          IF NOT EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'SymKey_DNI_SGPN')
        BEGIN
            OPEN SYMMETRIC KEY SymKey_DNI_SGPN DECRYPTION BY CERTIFICATE Certificado_DNI_SGPN;
        END

        --Ahora si la inserción
        INSERT INTO Area_Excursiones.Guia (DNI, IdParque, IdEspecialidad, Nombre, Apellido, Titulo)
        VALUES (EncryptByKey(Key_GUID('SymKey_DNI_SGPN'),@DNI), @idParque, @idEspecialidad, @Nombre, @Apellido, @Titulo)
        DECLARE @Id_NuevoGuia INT
        SET @Id_NuevoGuia = SCOPE_IDENTITY()
        
        --Ahora cerramos 
        CLOSE SYMMETRIC KEY SymKey_DNI_SGPN;
        PRINT 'Guia Creado exitósamente'
        RETURN @Id_NuevoGuia

    END TRY

    BEGIN CATCH

        --IMPORTANTISIMO: Si la llave no cerró, cerrarla
        IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'SymKey_DNI_SGPN')
        BEGIN
            CLOSE SYMMETRIC KEY SymKey_DNI_SGPN;
        END
        --Nunca está demás

        RAISERROR('Algo salio mal en la creación del Guia',16,1);
		RETURN;
    END CATCH

END
GO
--/////////////////////////////////////////////////////////////
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
			OPEN SYMMETRIC KEY SymKey_DNI_SGPN DECRYPTION BY CERTIFICATE Certificado_DNI_SGPN;
			
			IF EXISTS (
				SELECT 1 FROM Area_Infraestructura.Guardaparque 
				WHERE DecryptByKey(DNI) = @DNI AND IdGuardaparque <> @IdGuardaparque
			)
			BEGIN
				 CLOSE SYMMETRIC KEY SymKey_DNI_SGPN; 
				PRINT('Ya existe otro guardaparque con el DNI ingresado.');
				RAISERROR('.', 16, 1);
			END

			UPDATE Area_Infraestructura.Guardaparque
			SET DNI = EncryptByKey(Key_GUID('SymKey_DNI_SGPN'),@DNI)
			WHERE IdGuardaparque = @IdGuardaparque;

			 CLOSE SYMMETRIC KEY SymKey_DNI_SGPN; 
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
		-- Debemos validar si la llave quedó abierta en memoria y obligar su cierre.
        IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'SymKey_DNI_SGPN')
        BEGIN
            CLOSE SYMMETRIC KEY SymKey_DNI_SGPN;
        END
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrió  un error al modificar el guardaparque.', 16, 1);
			RETURN;
		END
	END CATCH
END
GO
--//////////////////////////////////////////////////////////////
USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Infraestructura.SP_CrearGuardaparque
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
			IF @Nombre ='' OR @Nombre LIKE '%[^a-zA-ZñÑ ]%' OR LEN(@Nombre) > 30
			BEGIN
				PRINT('El nombre ingresado no es valido')
				RAISERROR('.', 16,1)
			END
			SET @Nombre = TRIM(@Nombre)
		-- Validamos apellido ingresado. Si es valido, quitamos espacios al string
			IF @Apellido ='' OR @Apellido LIKE '%[^a-zA-ZñÑ ]%' OR LEN(@Apellido) > 30
			BEGIN
				PRINT('El apellido ingresado no es valido')
				RAISERROR('.', 16,1)
			END
			SET @Apellido = TRIM(@Apellido)	
        -- Validación común del dni.
        IF @Dni IS NULL OR @Dni = ''
        BEGIN
            PRINT('El DNI ingresado no es válido');
            RAISERROR('El formato del DNI no es válido.', 16, 1);
        END
        -- El parque debe existir en la BBDD
			DECLARE @IdParque INT;
			SELECT @IdParque = p.IdParque FROM Area_Infraestructura.Parque p WHERE p.Nombre = @Parque;
			IF @IdParque IS NULL
			BEGIN
				PRINT('El parque ingresado no existe')
				RAISERROR('Parque Inválido', 16,1)
			END
        IF @Fecha_Ingreso IS NULL
        BEGIN
				PRINT('La fecha de ingreso no puede ser vacía')
				RAISERROR('Fecha Inválida', 16,1)
		END
        IF @Fecha_Egreso IS NULL
        BEGIN
				PRINT('La fecha de egreso no puede ser vacía')
				RAISERROR('Fecha Inválida', 16,1)
		END
        IF @Fecha_Ingreso  > @Fecha_Egreso
        BEGIN
				PRINT('La fecha de ingreso debe ser anterior a la fecha de Egreso')
				RAISERROR('Fechas Inválida', 16,1)
		END
        -- LO NUEVO ES ESTO:
        -- Para validar duplicados de un dato cifrado, no se puede hacer SELECT directo.
        -- Tenemos que abrir la llave para poder comparar los datos existentes.
        OPEN SYMMETRIC KEY SymKey_DNI_SGPN DECRYPTION BY CERTIFICATE Certificado_DNI_SGPN;

        --Si existe está duplicado (no van a robar identidad)
        IF EXISTS (
            SELECT 1 FROM Area_Infraestructura.Guardaparque 
            WHERE DecryptByKey(Dni) = @Dni
        )
        BEGIN
            -- Vital Cerrar la s llave antes de abortar
            CLOSE SYMMETRIC KEY SymKey_DNI_SGPN; 
            RAISERROR('Ya existe un Guardaparque registrado con ese DNI.', 16, 1);
        END

        --Re abro la llave por si hubo error  
        IF NOT EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'SymKey_DNI_SGPN')
        BEGIN
            OPEN SYMMETRIC KEY SymKey_DNI_SGPN DECRYPTION BY CERTIFICATE Certificado_DNI_SGPN;
        END

        -- Insertamos aplicando EncryptByKey en la columna Dni
        INSERT INTO Area_Infraestructura.Guardaparque (Nombre, Apellido, IdParque,Dni, Fecha_Ingreso, Fecha_Egreso,Activo)
        VALUES ( 
            @Nombre, 
            @Apellido, 
            @IdParque,
            EncryptByKey(Key_GUID('SymKey_DNI_SGPN'), @Dni), 
            @Fecha_Ingreso,
            @Fecha_Egreso,
            @Activo
        );

        -- CLAVE DE SEGURIDAD: Cerramos la llave inmediatamente después de usarla
        CLOSE SYMMETRIC KEY SymKey_DNI_SGPN;
        PRINT 'Guardaparque Creado Exitósamente'
    END TRY
    BEGIN CATCH
        -- SEGURO DE DBA: 
        -- Debemos validar si la llave quedó abierta en memoria y obligar su cierre.
        IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'SymKey_DNI_SGPN')
        BEGIN
            CLOSE SYMMETRIC KEY SymKey_DNI_SGPN;
        END

        RAISERROR('Algo salio mal en la creación del guardaparque',16,1);
		RETURN;
    END CATCH
END
GO