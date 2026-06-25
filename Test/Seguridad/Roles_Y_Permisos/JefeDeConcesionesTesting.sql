/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 24/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de probar los permisos para comprobar que; al iniciar sesión con
cierto rol (JefeDeConcesiones) los permisos se encuentran correctamente asignados.

*/
USE SGParquesNacionales;
GO


-- /////////////////////////////////////////////////////////////////////////////
--          Uso de un usuario fabricado
-- /////////////////////////////////////////////////////////////////////////////
-- Creamos un usuario "fantasma" solo para testear
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'JefeDeConcesionesA')
BEGIN
    PRINT 'Creado Usuario JefeDeConcesionesA';
    CREATE USER JefeDeConcesionesA WITHOUT LOGIN;
END
GO

-- Le asigno el rol que le  corresponde
ALTER ROLE Rol_Jefe_Concesiones ADD MEMBER JefeDeConcesionesA;
GO

--///////////////////////////////////////////////////////////////
            --Creamos un parque para el entorno y una concesión
PRINT '///////////////////////////////////////////////////////////'
PRINT '#Creando entorno de pruebas para Inserción de Concesiones:'
PRINT '#Creando Region...'
INSERT INTO Area_Infraestructura.Region (Nombre) VALUES ('Region E');
DECLARE @IdReg INT = SCOPE_IDENTITY();
PRINT '#Creando Provincia...'
INSERT INTO Area_Infraestructura.Provincia (Nombre, IdRegion) VALUES ('Provincia E', @IdReg);
PRINT '#Creando Tipo Parque...'
INSERT INTO Area_Infraestructura.Tipo_Parque (Descripcion) VALUES ('Tipo E');
PRINT '#Creando Parque...'
EXEC Area_Infraestructura.SP_CrearParque 
    @Nombre = 'Parque E', 
    @TipoParqueDesc = 'Tipo E', 
    @Provincia = 'Provincia E', 
    @Superficie = 1500.5;
GO

GO

--Ahora
PRINT '#Creando Empresa Concesionaria'
INSERT INTO Area_Negocios.Empresa_Concesionaria (Nombre) VALUES ('Empresa E')

PRINT '#Creando Tipo de actividad de concesión...'

INSERT INTO Area_Negocios.Tipo_Actividad_Concesion (Descripcion) VALUES ('Morfología')
PRINT '#Creando Estado de Canon...'
INSERT INTO Area_Negocios.Estado_Canon (Descripcion) VALUES ('Pagado')
DECLARE @IdEstadoCanon INT
DECLARE @IdTipoActividadConcesion INT
SELECT @IdEstadoCanon = MAX(IdEstadoCanon) FROM Area_Negocios.Estado_Canon
SELECT @IdTipoActividadConcesion = MAX(IdTipoActividadConcesion) FROM Area_Negocios.Tipo_Actividad_Concesion
DECLARE @IdParque INT 
SELECT @IdParque = MAX(IdParque) FROM Area_Infraestructura.Parque
DECLARE @IdEmpresa INT
SELECT @IdEmpresa = MAX(IdEmpresa) FROM Area_Negocios.Empresa_Concesionaria

PRINT '#Creando Concesión...'
INSERT INTO Area_Negocios.Concesion (IdTipoActividadConcesion,IdEmpresa,IdParque,Fecha_Inicio,Fecha_Fin)
VALUES (@IdTipoActividadConcesion,@IdEmpresa,@IdParque,'2028-07-1','2030-12-12')

PRINT 'Entorno de pruebas Finalizado Exitosamente'
PRINT '//////////////////////////////////////////////////////'
-- ==============================================================================
--  EJECUCIÓN DE PRUEBAS DE CONTEXTO
-- ==============================================================================

PRINT '=== TEST 1: El Jefe de Concesiones solamente consulta las concesiones (PERMISION ESPERADA)===';
EXECUTE AS USER = 'JefeDeConcesionesA';

-- Debe ver la grilla completa con DNIs abiertos exitosamente
SELECT * FROM Area_Negocios.Concesion

REVERT;
GO

PRINT '=== TEST 2: El Guía "JefeDeConcesionesA" Intenta agregar una concesion (DENEGACIÓN ESPERADA) ===';
-- Buscamos el ID  dinámicamente y lo ejecutamos
DECLARE @IdTipoActividadConcesion INT
DECLARE @IdParque INT
DECLARE @IdEmpresa INT
SELECT @IdParque = MAX(IdParque) FROM Area_Infraestructura.Parque
SELECT @IdTipoActividadConcesion = MAX(IdTipoActividadConcesion) FROM Area_Negocios.Tipo_Actividad_Concesion
SELECT @IdEmpresa = MAX(IdEmpresa) FROM Area_Negocios.Empresa_Concesionaria


EXECUTE AS USER = 'JefeDeConcesionesA';

EXEC Area_Negocios.SP_CrearConcesion @IdTipoActividadConcesion,@IdEmpresa,@IdParque,'2029-01-01','2030-01-01'
REVERT;
GO

PRINT '=== TEST 3: "JefeDeConcesionesA" Intenta MODIFICAR una concesion (PERMISIÓN ESPERADA)  ===';
DECLARE @IdTipoActividadConcesion INT
DECLARE @IdParque INT
DECLARE @IdEmpresa INT
DECLARE @IdConcesion INT
SELECT @IdParque = MAX(IdParque) FROM Area_Infraestructura.Parque
SELECT @IdTipoActividadConcesion = MAX(IdTipoActividadConcesion) FROM Area_Negocios.Tipo_Actividad_Concesion
SELECT @IdEmpresa = MAX(IdEmpresa) FROM Area_Negocios.Empresa_Concesionaria
SELECT @IdConcesion = MAX(IdConcesion) FROM Area_Negocios.Concesion
EXECUTE AS USER = 'JefeDeConcesionesA';

EXEC Area_Negocios.SP_ModificarConcesion @IdConcesion,@IdTipoActividadConcesion,@IdEmpresa,@IdParque,'2027-12-31','2028-12-31'
--Resultado: Permitido
REVERT;
GO
PRINT 'FIN ENTORNO DE PRUEBAS'
PRINT '////////////////////////////////////////////////////7'



