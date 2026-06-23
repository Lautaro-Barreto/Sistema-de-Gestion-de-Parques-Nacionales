/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 20/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de crear el store procedure para que los guías,
puedan visualizar sus datos tal cuál como se espera, sin poder visualizar datos de otros guías
(sería fallo de seguridad).

*/

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