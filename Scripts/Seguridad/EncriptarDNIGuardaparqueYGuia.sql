/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 19/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la encriptación de datos Sensibles, creando una jerarquía
Critográfica(la master key, el certificado y la simétrica) y 
una migración segura de datos sensibles a una columna temporal para luego restaurarlos.

*/


USE SGParquesNacionales
GO


-- ==========================================================================================
--MODIFICACIÓN DE ESTRUCTURA Y MIGRACIÓN SEGURA DE DATOS

--COL_LEGTH pregunta si dentro de esa tabla, esa columna es nula. En este caso lo es
--Aún no existe.
--Aunque parezca que el varbinary es enorme. Es porque al encriptar se agregan 
--Datos se sql Server para para la seguridad. Cosas como GUID  de la llave simétrica, padding HMAC que son sellos de seguridad etc.
   PRINT 'Comienzo de encriptación de dnis para: [GUARDAPARQUES]'
BEGIN TRY
    IF COL_LENGTH('Area_Infraestructura.Guardaparque', 'Dni_Encriptado') IS NULL
    BEGIN
        ALTER TABLE Area_Infraestructura.Guardaparque ADD Dni_Encriptado VARBINARY(256);
        PRINT 'Se Agregó columna Dni_Encriptado'
    END
    ELSE
    BEGIN
        PRINT 'Ya se encuentra creado'
        RAISERROR('Ya existe una columna con ese nombre.',16,1);
    END
END TRY
BEGIN CATCH
    RAISERROR('No es posible completar la operación: Ya existe una columna con ese nombre.',16,1);
END CATCH
GO

-- Abrimos la llave simétrica y encriptamos los DNIs existentes
OPEN SYMMETRIC KEY SymKey_DNI_SGPN DECRYPTION BY CERTIFICATE Certificado_DNI_SGPN;
PRINT '[APERTURA] LLave Simétrica: SymKey_DNI_SGPN'

--EncryptByKey se encarga de todo, agrega la encriptación
UPDATE Area_Infraestructura.Guardaparque
SET Dni_Encriptado = EncryptByKey(Key_GUID('SymKey_DNI_SGPN'), Dni)
WHERE Dni IS NOT NULL;
PRINT 'Se transfirieron los datos de la columna "Dni" a la columna "Dni_Encriptado"'
CLOSE SYMMETRIC KEY SymKey_DNI_SGPN;
PRINT '[CIERRE] Llave Simétrica: SymKey_DNI_SGPN'
GO

-- Ahora la columna vieja la saco y me quedo con la nueva 
ALTER TABLE Area_Infraestructura.Guardaparque DROP COLUMN Dni;
EXEC sp_rename 'Area_Infraestructura.Guardaparque.Dni_Encriptado', 'Dni', 'COLUMN';
PRINT 'Se eliminó correctamente la columna Dni'
PRINT 'Se cambió el nombre del objeto Columna Dni_Encriptado a Dni'
GO
PRINT 'Fin operación'
--///////////////////////////////////////////////////////////////////////////////////////
--Lo siguiente es lo mismo pero para los guías de los cualees también se guardan DNIs
PRINT 'Comienzo de encriptación de dnis para: [GUIAS]'
IF COL_LENGTH('Area_Excursiones.Guia', 'Dni_Encriptado') IS NULL
BEGIN
    ALTER TABLE Area_Excursiones.Guia ADD Dni_Encriptado VARBINARY(256);
    PRINT 'Se Agregó columna Dni_Encriptado'
END
GO

--Open a la llave simetrica y le agrego el mismo cert
OPEN SYMMETRIC KEY SymKey_DNI_SGPN DECRYPTION BY CERTIFICATE Certificado_DNI_SGPN;
PRINT '[APERTURA] LLave Simétrica: SymKey_DNI_SGPN'
UPDATE Area_Excursiones.Guia
SET Dni_Encriptado = EncryptByKey(Key_GUID('SymKey_DNI_SGPN'), DNI) -- Respeto mayúsculas de tu script original
WHERE DNI IS NOT NULL;
PRINT 'Se transfirieron los datos de la columna "Dni" a la columna "Dni_Encriptado"'
CLOSE SYMMETRIC KEY SymKey_DNI_SGPN;
PRINT '[CIERRE] Llave Simétrica: SymKey_DNI_SGPN'
GO

-- Sale lo viejo, entra lo fresco
ALTER TABLE Area_Excursiones.Guia DROP COLUMN DNI;
EXEC sp_rename 'Area_Excursiones.Guia.Dni_Encriptado', 'DNI', 'COLUMN';
PRINT 'Se cambió el nombre del objeto Columna Dni_Encriptado a Dni'
GO

PRINT 'Fin operación'