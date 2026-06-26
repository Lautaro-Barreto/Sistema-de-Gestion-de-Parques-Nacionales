/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 20/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación de los Roles otorgando sus accesos
y permisos correspondientes a los distintos usuarios de la DB

*/

/*Veamos si existe las master keys:
SELECT 
    *
FROM sys.symmetric_keys
WHERE name = '##MS_DatabaseMasterKey##';
*/
--Lógica de UPSERT para la master key 

USE SGParquesNacionales
GO

BEGIN TRY
    IF NOT EXISTS (SELECT * FROM  sys.symmetric_keys WHERE symmetric_key_id = 101)
    BEGIN
        CREATE MASTER KEY ENCRYPTION BY PASSWORD = '#Unlam_PasswordFuerte2026-1989!'
        PRINT '¡Se creó la llave maestra correctamente!'
    END
ELSE
BEGIN
    PRINT 'La llave maestra ya se encuentra creada'
    RAISERROR('Llave Maestra ya creada.', 16, 1);
END
END TRY
BEGIN CATCH
    RAISERROR('No es posible generar: Llave Maestra ya creada.', 16, 1)
END CATCH
GO

--Poder se puede comprobar que existe:
SELECT 
    *
FROM sys.symmetric_keys
GO
--DROP MASTER KEY
--Un certificado de seguridad es el API o intermediario entre la master key
--y la simetrica
-- Funciona como un intermediario para proteger la llave simétrica.

BEGIN TRY
    IF NOT EXISTS (SELECT * FROM sys.certificates WHERE name = 'Certificado_DNI_SGPN')
    BEGIN
        CREATE CERTIFICATE Certificado_DNI_SGPN WITH SUBJECT = 
        'Certificado para proteger los DNIs del sistema SGPN';
        PRINT '¡Se creó el certificado correctamente!'
    END
    ELSE
    BEGIN
        PRINT 'El certificado Ya se encuentra creado'
        RAISERROR('Certificado ya creado.', 16, 1)
    END
END TRY
BEGIN CATCH
    RAISERROR('No es posible realizar la operación: Certificado ya creado.', 16, 1)
END CATCH
GO
--Aca comprobamos que ahora existe
SELECT 
    name, 
    certificate_id, 
    pvt_key_encryption_type_desc AS tipo_cifrado, 
    start_date AS fecha_inicio, 
    issuer_name AS emisor,
    subject
FROM sys.certificates;
GO

--Ahora si puedo crear la llave simétrica 
BEGIN TRY
    IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = 'SymKey_DNI_SGPN')
    BEGIN
        CREATE SYMMETRIC KEY SymKey_DNI_SGPN
        WITH ALGORITHM = AES_256
        ENCRYPTION BY CERTIFICATE Certificado_DNI_SGPN;
        PRINT '¡Se creó la llave simetrica correctamente!'
    END
    ELSE
    BEGIN
        PRINT 'La llave Ya se encuentra creada'
        RAISERROR('Llave Simétrica ya creada.', 16, 1)
    END
END TRY
BEGIN CATCH
    RAISERROR('No es posible realizar la operación: Llave Simétrica ya creada.', 16, 1)
END CATCH
GO
/* ¿Porque AES_256? Bueno: es el estándar criptográfico actual más robusto para proteger datos sensibles
y funciona bien para este caso, en lugar de usar otro más antiguo y pesado*/

--Si se creo:
SELECT 
    *
FROM sys.symmetric_keys
GO
