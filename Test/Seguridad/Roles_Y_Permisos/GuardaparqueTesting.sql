/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 22/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de probar las restricciones para roles de Guardaparques
 quienes tienen permisos de ejecución de store procedure regulados según el usuario.
La prueba consiste en entrar en el usuario para comprobar su forma de ver los datos.

*/
USE SGParquesNacionales
GO

--Preparación del entorno de testing:
PRINT '///////////////////////////////////////////////////////////'
PRINT 'Creando entorno de pruebas para Inserción de Guardaparque:'
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
EXEC Area_Infraestructura.SP_CrearParque 
    @Nombre = 'Parque Pri', 
    @TipoParqueDesc = 'Tipo P', 
    @Provincia = 'Provincia P', 
    @Superficie = 1000.5;
GO
EXEC Area_Infraestructura.SP_CrearGuardaParque
    @Nombre = 'GuardaparqueSislan',
    @Apellido = 'GuardaparqueSilanApellido',
    @Dni = '45470000',
    @Parque = 'Parque P',
    @Fecha_Ingreso = '2025-10-01',
    @Fecha_Egreso = '2026-10-01',
    @Activo = 1;
PRINT 'Entorno de pruebas Finalizado Exitosamente'
PRINT '//////////////////////////////////////////////////////'
GO
--/////////////////////////////////////////////////////////7
--1. Ahora sí creamos el usuario y le asignamos el rol
--Probamos lo del login
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'GuardaparqueSislan_Login')
BEGIN
    CREATE LOGIN GuardaparqueSislan_Login WITH PASSWORD = 'Password#####lanSis';
    PRINT 'Creado Login GuardaparqueSislan_Login con contraseña: Password#####lanSis'
END
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'GuardaparqueSislan')
BEGIN
    CREATE USER GuardaparqueSislan FOR LOGIN GuardaparqueSislan_Login;
    PRINT 'Creado Usuario GuardaparqueSislan enlazado al Login'
END

--  a sus respectivos roles
ALTER ROLE Rol_Guardaparque_Base ADD MEMBER GuardaparqueSislan;
PRINT 'Agregado rol Guardaparque_Base a GuardaparqueSislan';
GO


-- /////////////////////////////////////////////////////////
-- 2. ENTORNO DE PRUEBAS
-- /////////////////////////////////////////////////////////
PRINT 'INICIANDO SESIÓN COMO GUARDAPARQUE...'

-- Simulamos que la aplicación se conectó usando el Login y la contraseña
EXECUTE AS LOGIN = 'GuardaparqueSislan_Login';
GO

-- Comprobamos quiénes somos (GuardaparqueSislan)
SELECT CURRENT_USER AS 'Identidad en la Base de Datos', 
       SUSER_SNAME() AS 'Identidad en el Servidor (Login)';
GO

--////////////////////////////////////////////////////////////
--Comienzan las pruebas
PRINT '-- PRUEBA 1. Consultar datos de su parque(PERMISIÓN ESPERADA)---'
EXEC Area_Infraestructura.SP_ConsultarDatosParque_Guardaparque 'Parque P'
--Resultado: Visualiza los datos correctamente.
GO

PRINT '-- PRUEBA 2. Consultar datos de OTRO parque(DENEGACIÓN ESPERADA)---'
EXEC Area_Infraestructura.SP_ConsultarDatosParque_Guardaparque 'Parque Pri'
--Resultado: Permiso Denegado: No puede acceder a ver la información del parque.
GO

-- Salimos de la sesión y volvemos a ser Administradores
REVERT;
PRINT 'Fin del entorno de pruebas.'
GO