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
    PRINT 'Creado Usuario UsuarioGuiaTest';
    CREATE USER UsuarioGuiaTest WITHOUT LOGIN;
END
GO

-- Le asigno el rol que le  corresponde
ALTER ROLE Rol_Guia_Base ADD MEMBER UsuarioGuiaTest;
GO

--///////////////////////////////////////////////////////////////
--Lo creo en la tabla de guías asi simulamos que si existe
--Para eso preparamos rapidamente el entorno de el:
PRINT '///////////////////////////////////////////////////////////'
PRINT 'Creando entorno de pruebas para Inserción de Guia:'
PRINT 'Creando Region...'
INSERT INTO Area_Infraestructura.Region (Nombre) VALUES ('Region P');
DECLARE @IdReg INT = SCOPE_IDENTITY();
PRINT 'Creando Provincia...'
INSERT INTO Area_Infraestructura.Provincia (Nombre, IdRegion) VALUES ('Provincia P', @IdReg);
PRINT 'Creando Tipo Parque...'
INSERT INTO Area_Infraestructura.Tipo_Parque (Descripcion) VALUES ('Tipo P');
-- Ejecutamos
PRINT 'Creando Parque...'
EXEC Area_Infraestructura.SP_CrearParque 
    @Nombre = 'Parque P', 
    @TipoParqueDesc = 'Tipo P', 
    @Provincia = 'Provincia P', 
    @Superficie = 1000.5;
GO
--Ahora inserto la especialidad:
PRINT 'Creando Especialidad...'
EXEC Area_Excursiones.Sp_CrearEspecialidad 
        @Descripcion = 'Sedentarismo'
GO
PRINT 'Creando Guia...'
EXEC Area_Excursiones.Sp_CrearGuia @DNI = '47093989',
    @idParque = 1,
    @idEspecialidad = 1,
    @Nombre ='UsuarioGuiaTest',
    @Apellido= 'ApellidoPrueba',
    @Titulo ='Tecnicatura en Turismo'

PRINT 'Entorno de pruebas Finalizado Exitosamente'
PRINT '//////////////////////////////////////////////////////'
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

PRINT '--- PRUEBA 1: Lectura de tablas permitidas (PERMISIÓN ESPERADA)---'
-- Esto debe funcionar porque tiene GRANT explícito (temporalmente).
PRINT '--- Ver  sus propios datos:----'

EXEC  Area_Excursiones.SP_ConsultarMisDatos_Guia @Nombre='UsuarioGuiaTest',@Apellido='ApellidoPrueba'


SELECT TOP 5 * FROM Area_Excursiones.Habilitacion;
GO
--Resultado: Es capaz de visualizar sus datos correctamente o las habilitaciones


PRINT '--- PRUEBA 2: Ejecución del SP de Modificación (DENEGADO ESPERADO) ---'
-- Esto no debe funcionar
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

PRINT '--- PRUEBA 5: Intento de ver a los demás guias (PERMISIÓN CON RESTRICCIÓN ESPERADA) ---'
SELECT * FROM Area_Excursiones.Vista_Guias_Seguros
GO
--Resultado: Puede ver a sus compañeros exceptuando sus datos de DNI, ya que se encuentran encriptados.

PRINT '--- PRUEBA 6: Intento de agregar un nuevo guía(DENEGADO ESPERADO) ---'
EXEC Area_Excursiones.Sp_CrearGuia @DNI = '51770000',
    @idParque = 1,
    @idEspecialidad = 1,
    @Nombre ='GuiaLeandro',
    @Apellido= 'ApellidoGuiaLeandro',
    @Titulo ='Curso de Turismo'
GO
--resultado: Se denegó el permiso EXECUTE en el objeto 'Sp_CrearGuia'
-- ///////////////////////////////////////////////////////////////


REVERT;
GO