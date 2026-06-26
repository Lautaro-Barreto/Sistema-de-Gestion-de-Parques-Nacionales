/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 20/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de crear el store procedure encargado de que un guía
jefe pueda consultar los datos de los demás guías, y al tener los privilegios pueda observar
datos sensibles.

*/

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