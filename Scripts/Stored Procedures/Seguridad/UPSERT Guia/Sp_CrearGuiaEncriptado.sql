
/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 20/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de modificar el store procedure para la inserción de Guia,
con la actualización del dni como dato cifrado.

*/



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
            RAISERROR('El Parque no existe.', 16, 1)
        END

        --La especialidad debe estar en la db
        IF NOT EXISTS(SELECT 1 FROM Area_Excursiones.Especialidad WHERE IdEspecialidad = @idEspecialidad)
        BEGIN
            RAISERROR('La especialidad no existe.', 16, 1)
            
        END
        --validar que el dni sea válido
        IF (@DNI LIKE '%[^0-9]%' OR LEN(@DNI) NOT BETWEEN 7 AND 8)
        BEGIN
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
