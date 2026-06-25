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
EXEC Area_Excursiones.Sp_CrearGuia @DNI = '21763389',
    @idParque = 1,
    @idEspecialidad = 1,
    @Nombre ='JefeGuiaUser',
    @Apellido= 'ApellidoGuiaPrueba',
    @Titulo ='Licenciatura en Turismo'

EXEC Area_Excursiones.Sp_CrearGuia @DNI = '21760000',
    @idParque = 1,
    @idEspecialidad = 1,
    @Nombre ='GuiaJorge',
    @Apellido= 'ApellidoGuiaJorge',
    @Titulo ='Licenciatura en Turismo'

PRINT 'Entorno de pruebas Finalizado Exitosamente'
PRINT '//////////////////////////////////////////////////////'
GO


IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'JefeGuiaUser')
BEGIN
    CREATE USER JefeGuiaUser WITHOUT LOGIN;
    PRINT 'Creado Usuario JefeGuiaUser'
END
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'GuiaJorge')
BEGIN
    CREATE USER GuiaJorge WITHOUT LOGIN;
    PRINT 'Creado Usuario GuiaJorge';
END

--  a sus respectivos roles
ALTER ROLE Rol_Jefe_Guias ADD MEMBER JefeGuiaUser;
PRINT 'Agregado rol Jefe_Guia a JefeGuiaUser';
GO
ALTER ROLE Rol_Guia_Base ADD MEMBER GuiaJorge;
PRINT 'Agregado rol Guia_Base a GuiaJorge'
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

PRINT '=== TEST 2: El Guía "JefeGuiaUser" consulta SUS PROPIOS datos (ÉXITO) ===';
EXECUTE AS USER = 'JefeGuiaUser';

-- Buscamos el ID de JefeGuiaUser dinámicamente y lo ejecutamos
EXEC Area_Excursiones.SP_ConsultarMisDatos_Guia 'JefeGuiaUser', 'ApellidoGuiaPrueba'
REVERT;
GO

PRINT '=== TEST 3: El Guía "JefeGuiaUser" Quiere cambiar los datos de un Guía ===';
EXECUTE AS USER = 'JefeGuiaUser';
-- Buscamos el ID de algún guía distinto al Jefe dinámicamente y lo ejecutamos

EXEC Area_Excursiones.Sp_ModificarGuia @IdGuia=2,@Dni='21760000',@IdParque=1,@IdEspecialidad=1,@Nombre='GuiaJorge',
                                        @Apellido='ApellidoGuiaJorge',@Titulo='Solo Turismo'
--Resultado: Operación Exitosa: Guía Modificado.
REVERT;
GO

PRINT '=== TEST 4: El Guía "JefeGuiaUser" Quiere Agregar un nuevo Guía ===';
EXECUTE AS USER = 'JefeGuiaUser';
-- Buscamos el ID de algún guía distinto al Jefe dinámicamente y lo ejecutamos

EXEC Area_Excursiones.Sp_CrearGuia @DNI = '51770000',
    @idParque = 1,
    @idEspecialidad = 1,
    @Nombre ='GuiaLeandro',
    @Apellido= 'ApellidoGuiaLeandro',
    @Titulo ='Curso de Turismo'
    --Resultado: Operación Exitosa: Guía Creado Exitósamente
REVERT;

PRINT 'Muestro la tabla sola para observar que se añadío:'
SELECT IdGuia,Nombre,Apellido,Titulo FROM Area_Excursiones.Guia
GO