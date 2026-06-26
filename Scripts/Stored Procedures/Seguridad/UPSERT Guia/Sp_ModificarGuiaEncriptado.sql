/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 21/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la modificación del Stored Procedure utilizado para modificar un guia.
Ahora el SP tiene en cuenta el cifrado de datos protegidos.
*/

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

<<<<<<< HEAD:Scripts/Stored Procedures/Seguridad/UPSERT Guia/Sp_ModificarGuiaEncriptado.sql
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
=======
        DECLARE @IdGuiaRepetido INT
        SELECT @IdGuiaRepetido = IdGuia FROM Area_Excursiones.Guia WHERE DNI = @Dni AND IdGuia != @IdGuia
        IF @IdGuiaRepetido IS NOT NULL
        BEGIN
>>>>>>> feature/ABMs-basicos:Scripts/Stored Procedures/ABMs/Area Excursiones/Individuales/Sp_ModificarGuia.sql
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
