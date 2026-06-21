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
    @IdGuia INT
AS
BEGIN
    BEGIN TRY
        -- LO NUEVO:
        -- Validamos que el usuario que ejecuta (CURRENT_USER) coincida con el nombre del guía que busca.
        IF NOT EXISTS (
            SELECT 1 FROM Area_Excursiones.Guia 
            WHERE IdGuia = @IdGuia AND Nombre = CONVERT(VARCHAR(30), CURRENT_USER)
        )
        BEGIN
            PRINT 'Lo siento, no puede acceder a datos que no le pertenecen'
            RAISERROR('Acceso denegado: No tiene permisos para consultar datos de otros empleados.', 16, 1);
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
        WHERE IdGuia = @IdGuia;

        CLOSE SYMMETRIC KEY SymKey_DNI_SGPN;
        
    END TRY
    BEGIN CATCH
        IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'SymKey_DNI_SGPN')
        BEGIN
            CLOSE SYMMETRIC KEY SymKey_DNI_SGPN;
        END

        RAISERROR('Acceso denegado: No tiene permisos para consultar datos de otros empleados.', 16, 1);
    END CATCH
END
GO