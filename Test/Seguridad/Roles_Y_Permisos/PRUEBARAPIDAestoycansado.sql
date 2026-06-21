/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 21/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de probar las restricciones para roles de Jefes de Guia
y Guias quienes tienen permisos de ejecución de store procedure regulados según el usuario.
La prueba consiste en entrar en el usuario de cada uno para comprobar su forma de ver los datos.

*/
USE SGParquesNacionales
GO

--Preparación del entorno de testing:
--GRANT EXECUTE ON OBJECT::Area_Excursiones.SP_ConsultarGuias_GuiaJefe TO Rol_Jefe_Guias;
--En caso de no haberlo hecho

-- Al Guía común SOLO le damos su SP restringido
--GRANT EXECUTE ON OBJECT::Area_Excursiones.SP_ConsultarMisDatos_Guia TO Rol_Guia_Base;


-- 2. CREACIÓN DE ENTORNO DE PRUEBA (Usuarios simulados)
-- Creamos al Jefe y a un Guía común que se llama "Lautaro"
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'JefeGuiaUser')
BEGIN
    CREATE USER JefeGuiaUser WITHOUT LOGIN;
    PRINT 'Creado Usuario JefeGuiaUser'
END

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Julio')
BEGIN
    CREATE USER Julio WITHOUT LOGIN;
    PRINT 'Creado usuario Julio'
END
GO

-- Los unimos a sus respectivos roles
ALTER ROLE Rol_Jefe_Guias ADD MEMBER JefeGuiaUser;
ALTER ROLE Rol_Guia_Base ADD MEMBER Julio;
GO


-- ==============================================================================
-- 3. EJECUCIÓN DE PRUEBAS DE CONTEXTO
-- ==============================================================================

PRINT '=== TEST 1: El Jefe de Guías consulta todo ===';
EXECUTE AS USER = 'JefeGuiaUser';

-- Debe ver la grilla completa con DNIs abiertos exitosamente
EXEC Area_Excursiones.SP_ConsultarGuias_GuiaJefe; 
REVERT;
GO

PRINT '=== TEST 2: El Guía "Julio" consulta SUS PROPIOS datos (ÉXITO) ===';
EXECUTE AS USER = 'Julio';

-- Buscamos el ID de Lautaro dinámicamente y lo ejecutamos
DECLARE @IdJulito INT = (SELECT IdGuia FROM Area_Excursiones.Guia WHERE Nombre = 'Julio');
EXEC Area_Excursiones.SP_ConsultarMisDatos_Guia @IdGuia = @IdJulito;
REVERT;
GO

PRINT '=== TEST 3: El Guía "Julio" intenta espiar el ID de otro (ERROR ESPERADO) ===';
EXECUTE AS USER = 'Julio';

-- Intenta mandar el ID 999 o de otro compañero. Debe saltar el RAISERROR de seguridad.
EXEC Area_Excursiones.SP_ConsultarMisDatos_Guia @IdGuia = 999;
REVERT;
GO