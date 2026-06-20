/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 19/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de probar una vista para comprobar que; al iniciar sesión con
cierto rol (Guia_Basico) los permisos se encuentran correctamente asignados.

*/

USE SGParquesNacionales;
GO

-- /////////////////////////////////////////////////////////////////////////////
--          Uso de un usuario fabricado
-- /////////////////////////////////////////////////////////////////////////////
-- Creamos un usuario "fantasma" solo para testear
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'UsuarioGuiaTest')
BEGIN
    CREATE USER UsuarioGuiaTest WITHOUT LOGIN;
END
GO

-- Metemos al usuario de prueba en la bolsa del rol que creaste
ALTER ROLE Rol_Guia_Base ADD MEMBER UsuarioGuiaTest;
GO
-- /////////////////////////////////////////////////////////////////////////////
-- FANTASMEADA (Simulo ser ese usuario para testing)
-- /////////////////////////////////////////////////////////////////////////////
PRINT '--- Cambiando contexto a UsuarioGuiaTest ---';
EXECUTE AS USER = 'UsuarioGuiaTest';
GO
--/////////////////////////////////////////////////////////////////////////////
-- Verificamos quiénes somos ahora en el sistema (Debería decir "UsuarioGuiaTest")
SELECT CURRENT_USER AS 'Usuario Actual';
GO

PRINT '--- PRUEBA 1: Lectura de tablas permitidas (ÉXITO ESPERADO) ---'
-- Esto debe funcionar porque tiene GRANT explícito (temporalmente).
SELECT TOP 5 * FROM Area_Excursiones.Guia;
SELECT TOP 5 * FROM Area_Excursiones.Habilitacion;
GO
--Resultado:
PRINT '--- PRUEBA 2: Ejecución del SP de Modificación (ÉXITO ESPERADO) ---'
-- Esto debe funcionar( no se frena por seguridad, sino por los parámetros. Es decir si le permite la ejecución del sp)
EXEC Area_Excursiones.SP_ModificarGuia @IdGuia = 1, @Nombre = 'Test', @Apellido = 'Test', @DNI = '11111111';
GO
--Resultado:

PRINT '--- PRUEBA 3: Intento de borrar un Guía (DENEGADO ESPERADO) ---'
-- Esto DEBE tirar un error
DELETE FROM Area_Excursiones.Guia WHERE IdGuia = 1;
GO
--Resultado: Se denegó el permiso DELETE en el objeto 'Guia', base de datos 'SGParquesNacionales', esquema 'Area_Excursiones'.

PRINT '--- PRUEBA 4: Intento de ver otra área del sistema (DENEGADO ESPERADO) ---'
-- Esto DEBE tirar error, porque el Guía no tiene permisos
SELECT * FROM Area_Infraestructura.Parque;
GO
--Resultado: Se denegó el permiso SELECT en el objeto 'Parque', base de datos 'SGParquesNacionales', esquema 'Area_Infraestructura'.

-- ///////////////////////////////////////////////////////////////
-- 4. LOGOUT para volver al modo DB

REVERT;
GO