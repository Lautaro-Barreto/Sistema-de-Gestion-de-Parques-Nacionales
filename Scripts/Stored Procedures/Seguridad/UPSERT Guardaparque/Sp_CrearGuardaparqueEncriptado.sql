
/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 19/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de modificar el store procedure para la inserción de Guardparques,
con la actualización del dni como dato cifrado.

*/

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
        INSERT INTO Area_Infraestructura.Guardaparque (Nombre, Apellido, Dni, Fecha_Ingreso, Fecha_Egreso,Activo)
        VALUES ( 
            @Nombre, 
            @Apellido, 
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
/*SELECT * FROM Area_Infraestructura.Guardaparque
INSERT INTO Area_Infraestructura.Region (Nombre) VALUES ('Region GP');
DECLARE @IdReg INT = SCOPE_IDENTITY();
INSERT INTO Area_Infraestructura.Provincia (Nombre, IdRegion) VALUES ('Provincia GP', @IdReg);
DECLARE @IdProv INT = SCOPE_IDENTITY();
INSERT INTO Area_Infraestructura.Tipo_Parque (Descripcion) VALUES ('Tipo GP');
DECLARE @IdTipo INT = SCOPE_IDENTITY();
INSERT INTO Area_Infraestructura.Parque (Nombre, Superficie, IdProvincia, IdTipoParque, Activo) VALUES ('Parque GP', 100, @IdProv, @IdTipo, 1);
-- Ejecutamos la prueba
EXEC Area_Infraestructura.SP_CrearGuardaParque
    @Nombre = 'Juancho',
    @Apellido = 'Papanatas',
    @Dni = '12325378',
    @Parque = 'Parque GP',
    @Fecha_Ingreso = '2023-01-01',
    @Fecha_Egreso = '2023-12-31',
    @Activo = 1;*/