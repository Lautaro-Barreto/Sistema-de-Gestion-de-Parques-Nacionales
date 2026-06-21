
/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 20/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación de los Roles otorgando sus accesos
y permisos correspondientes a los distintos usuarios de la DB

*/
USE SGParquesNacionales;
GO

-- ---------------------------------------------------------
--  CREACIÓN DE ROLES
-- ---------------------------------------------------------
--El archivo se encuentra dividido en:
/*Alta Direccion: Se trata de la jerarquía mas alta de permisos.
Guardaparques: Estos roles engloban a los  permisos de los guardaparques, dividiendoles en dos categorías,
El trabajador y el administrador o coordinador de guardaparques.
Guias y Excursiones: Trata roles de guias, estableciendo una jerarquía entre ellos y creando el rol de coordinador
de actividades, que podría ser dividido entre los distintos guías por lo que debe estar separado.
Concesiones: Trata los roles relacionados a las concesiones, con la misma jerarquía de un jefe coordinador y 
el administrador particular de esa concesión. Además se creo un rol para el punto de vista de la empresa concesionaria.
Operativos: Incluyendo un rol para generar la boletería o la venta de entradas y el Sistema ETL que automatiza la carga
masiva de entradas. Se agrega el rol del comprador con pocos permisos, pero es un usuario*/

PRINT 'Iniciando creación de Roles de Seguridad...';
PRINT '//////////////////////////////////////////////////////'


-- ---------------------------------------------------------
-- 1. ALTA DIRECCIÓN
-- ---------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Rol_Agente_Gobierno' AND type = 'R')
BEGIN
    CREATE ROLE Rol_Agente_Gobierno;
    PRINT '>> Rol creado: Rol_Agente_Gobierno';
END

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Rol_Administrador_Parque' AND type = 'R')
BEGIN
    CREATE ROLE Rol_Administrador_Parque;
    PRINT '>> Rol creado: Rol_Administrador_Parque';
END

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Rol_Administrador' AND type = 'R')
BEGIN
    CREATE ROLE Rol_Administrador;
    PRINT '>> Rol creado: Rol_Administrador';
END
-- ---------------------------------------------------------
-- 2. GUARDAPARQUES
-- ---------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Rol_Jefe_Guardaparques' AND type = 'R')
BEGIN
    CREATE ROLE Rol_Jefe_Guardaparques;
    PRINT '>> Rol creado: Rol_Jefe_Guardaparques';
END

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Rol_Guardaparque_Base' AND type = 'R')
BEGIN
    CREATE ROLE Rol_Guardaparque_Base;
    PRINT '>> Rol creado: Rol_Guardaparque_Base';
END

-- ---------------------------------------------------------
-- 3. GUÍAS Y EXCURSIONES
-- ---------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Rol_Coord_Actividades' AND type = 'R')
BEGIN
    CREATE ROLE Rol_Coord_Actividades;
    PRINT '>> Rol creado: Rol_Coord_Actividades';
END

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Rol_Jefe_Guias' AND type = 'R')
BEGIN
    CREATE ROLE Rol_Jefe_Guias;
    PRINT '>> Rol creado: Rol_Jefe_Guias';
END

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Rol_Guia_Base' AND type = 'R')
BEGIN
    CREATE ROLE Rol_Guia_Base;
    PRINT '>> Rol creado: Rol_Guia_Base';
END

-- ---------------------------------------------------------
-- 4. CONCESIONES
-- ---------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Rol_Jefe_Concesiones' AND type = 'R')
BEGIN
    CREATE ROLE Rol_Jefe_Concesiones;
    PRINT '>> Rol creado: Rol_Jefe_Concesiones';
END

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Rol_Admin_Concesion' AND type = 'R')
BEGIN
    CREATE ROLE Rol_Admin_Concesion;
    PRINT '>> Rol creado: Rol_Admin_Concesion';
END

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Rol_Concesionante' AND type = 'R')
BEGIN
    CREATE ROLE Rol_Concesionante;
    PRINT '>> Rol creado: Rol_Concesionante';
END

-- ---------------------------------------------------------
-- 5. OPERATIVA Y SISTEMAS
-- ---------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Rol_Boleteria' AND type = 'R')
BEGIN
    CREATE ROLE Rol_Boleteria;
    PRINT '>> Rol creado: Rol_Boleteria';
END

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Rol_Sistema_ETL' AND type = 'R')
BEGIN
    CREATE ROLE Rol_Sistema_ETL;
    PRINT '>> Rol creado: Rol_Sistema_ETL';
END

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Rol_Comprador' AND type = 'R')
BEGIN
    CREATE ROLE Rol_Comprador;
    PRINT '>> Rol creado: Rol_Comprador';
END
PRINT '//////////////////////////////////////////////////////////';
PRINT 'Creación de roles finalizada con éxito.';
PRINT '//////////////////////////////////////////////////////////';
GO

-- ---------------------------------------------------------
--  ASIGNACIÓN DE PERMISOS 
-- ---------------------------------------------------------
USE master
-- ////////////////////////////////////////////////////////////
--                      A. Rol Boletería
-- ////////////////////////////////////////////////////////////
--  No puede hacer nada manual, para eso están los SPs.
GRANT EXECUTE ON OBJECT::Area_Negocios.SP_CrearVenta TO Rol_Boleteria;
GRANT EXECUTE ON OBJECT::Area_Negocios.SP_CrearFormaDePago TO Rol_Boleteria;
GRANT EXECUTE ON OBJECT::Area_Negocios.SP_CrearDetalleVentaEntrada TO Rol_Boleteria;
GRANT EXECUTE ON OBJECT::Area_Comercial.SP_CrearEntrada TO Rol_Boleteria;
GRANT EXECUTE ON OBJECT::Area_Excursiones.SP_CrearContratacionActividad TO Rol_Boleteria;


GRANT EXECUTE ON OBJECT::Area_Negocios.SP_EliminarDetalleVentaEntrada TO Rol_Boleteria;
GRANT EXECUTE ON OBJECT::Area_Negocios.SP_EliminarFormaDePago TO Rol_Boleteria;
GRANT EXECUTE ON OBJECT::Area_Negocios.SP_EliminarDetalleVentaEntrada TO Rol_Boleteria;
GRANT EXECUTE ON OBJECT::Area_Negocios.SP_EliminarEntrada TO Rol_Boleteria;
GRANT EXECUTE ON OBJECT::Area_Excursiones.SP_EliminarContratacionActividad TO Rol_Boleteria;

GRANT EXECUTE ON OBJECT::Area_Negocios.SP_ModificarDetalleVentaEntrada TO Rol_Boleteria;
GRANT EXECUTE ON OBJECT::Area_Negocios.SP_ModificarFormaDePago TO Rol_Boleteria;
GRANT EXECUTE ON OBJECT::Area_Negocios.SP_ModificarFormaDePago TO Rol_Boleteria;
GRANT EXECUTE ON OBJECT::Area_Excursiones.SP_ModificarContratacionActividad TO Rol_Boleteria;
--GRANT EXECUTE ON OBJECT::Area_Negocios.SP_ModificarVenta TO Rol_Boleteria;

DENY SELECT, INSERT, UPDATE, DELETE ON OBJECT::Area_Negocios.Venta TO Rol_Boleteria;
GO

-- ////////////////////////////////////////////////////////////
--              B. Rol Jefe de Guardaparques
-- ////////////////////////////////////////////////////////////
-- Puede leer las vistas seguras y tiene permisos explícitos para abrir la llave simétrica
GRANT SELECT ON OBJECT::Area_Infraestructura.Vista_Guardaparques_Seguros TO Rol_Jefe_Guardaparques;

-- Permisos criptográficos vitales para ver los datos sensitivos
GRANT VIEW DEFINITION ON SYMMETRIC KEY::SymKey_DNI_SGPN TO Rol_Jefe_Guardaparques;
GRANT CONTROL ON CERTIFICATE::Certificado_DNI_SGPN TO Rol_Jefe_Guardaparques; 

GRANT EXECUTE ON OBJECT::Area_Infraestructura.SP_CrearGuardaparque TO Rol_Jefe_Guardaparques;
GRANT EXECUTE ON OBJECT::Area_Infraestructura.SP_ModificarGuardaparque TO Rol_Jefe_Guardaparques;
GRANT EXECUTE ON OBJECT::Area_Infraestructura.SP_EliminarGuardaparque TO Rol_Jefe_Guardaparques;


/* cambiar para despues:*/
GRANT SELECT ON OBJECT::Area_Negocios.Concesion TO Rol_Jefe_Guardaparques;
GRANT SELECT ON OBJECT::Area_Excursiones.Actividad TO Rol_Jefe_Guardaparques;
GRANT SELECT ON OBJECT::Area_Excursiones.Tipo_Actividad TO Rol_Jefe_Guardaparques;


--No podria crear ni eliminar, pero si modificar el parque
GRANT EXECUTE ON OBJECT::Area_Infraestructura.Sp_ModificarParque TO Rol_Jefe_Guardaparques;
GO

-- ////////////////////////////////////////////////////////////
-- C. Rol Sistema de Cargas Masivas
-- ////////////////////////////////////////////////////////////
-- Permisos totales pero ÚNICAMENTE sobre la tabla temporal (Staging)
-- Damos permiso SOLO para ejecutar el SP, la tabla temporal se maneja sola
GRANT EXECUTE ON OBJECT::Area_Negocios.Sp_ImportarDatosEmpresas TO Rol_Sistema_ETL;

-- Bloqueo absoluto por las dudas
DENY INSERT, UPDATE, DELETE ON SCHEMA::Area_Infraestructura TO Rol_Sistema_ETL;
DENY INSERT, UPDATE, DELETE ON SCHEMA::Area_Excursiones TO Rol_Sistema_ETL;
--Nunca está de más.
GO

-- ////////////////////////////////////////////////////////////
--              D. Rol Agente de gobierno
-- ////////////////////////////////////////////////////////////
-- Control total sobre los parquees (excluyendo las concesiones de cada uno)
GRANT EXECUTE ON OBJECT::Area_Infraestructura.SP_CrearParque TO Rol_Agente_Gobierno;
GRANT EXECUTE ON OBJECT::Area_Infraestructura.Sp_ModificarParque TO Rol_Agente_Gobierno;
GRANT EXECUTE ON OBJECT::Area_Infraestructura.SP_EliminarParque TO Rol_Agente_Gobierno;

GRANT EXECUTE ON OBJECT::Area_Negocios.SP_CrearEmpresaConcesionaria TO Rol_Agente_Gobierno;
GRANT EXECUTE ON OBJECT::Area_Infraestructura.SP_CrearTipoParque TO Rol_Agente_Gobierno;
GRANT EXECUTE ON OBJECT::Area_Infraestructura.SP_CrearProvincia TO Rol_Agente_Gobierno;
GRANT EXECUTE ON OBJECT::Area_Infraestructura.SP_CrearRegion TO Rol_Agente_Gobierno;

GRANT EXECUTE ON OBJECT::Area_Negocios.SP_ModificarEmpresaConcesionaria TO Rol_Agente_Gobierno;
GRANT EXECUTE ON OBJECT::Area_Infraestructura.SP_ModificarTipoParque TO Rol_Agente_Gobierno;
GRANT EXECUTE ON OBJECT::Area_Infraestructura.SP_ModificarProvincia TO Rol_Agente_Gobierno;
GRANT EXECUTE ON OBJECT::Area_Infraestructura.SP_ModificarRegion TO Rol_Agente_Gobierno;

GRANT EXECUTE ON OBJECT::Area_Negocios.SP_EliminarEmpresaConcesionaria TO Rol_Agente_Gobierno;
GRANT EXECUTE ON OBJECT::Area_Infraestructura.SP_EliminarProvincia TO Rol_Agente_Gobierno;
GRANT EXECUTE ON OBJECT::Area_Infraestructura.SP_EliminarRegion TO Rol_Agente_Gobierno;
GRANT EXECUTE ON OBJECT::Area_Infraestructura.SP_EliminarTipoParque TO Rol_Agente_Gobierno;
GO
-- ////////////////////////////////////////////////////////////
--              E. Rol Administrador
-- ////////////////////////////////////////////////////////////
-- Control total sobre la base de datos
GRANT CONTROL ON DATABASE::SGParquesNacionales TO Rol_Administrador;

GO

-- ////////////////////////////////////////////////////////////
--              F. Rol Administrador_Parque
-- ////////////////////////////////////////////////////////////
-- Tiene los permisos que le corresponden a su parque.
GRANT EXECUTE ON OBJECT::Area_Infraestructura.Sp_ModificarParque TO Rol_Administrador_Parque;


GRANT EXECUTE ON OBJECT::Area_Negocios.SP_CrearEmpresaConcesionaria TO Rol_Administrador_Parque;
GRANT EXECUTE ON OBJECT::Area_Negocios.SP_CrearConcesion TO Rol_Administrador_Parque;
GRANT EXECUTE ON OBJECT::Area_Negocios.SP_CrearCanon TO Rol_Administrador_Parque;
GRANT EXECUTE ON OBJECT::Area_Negocios.SP_CrearTipoActividadConcesion TO Rol_Administrador_Parque;
GRANT EXECUTE ON OBJECT::Area_Negocios.SP_CrearEstadoCanon TO Rol_Administrador_Parque;
GRANT EXECUTE ON OBJECT::Area_Negocios.SP_CrearPagoCanon TO Rol_Administrador_Parque;
GRANT EXECUTE ON OBJECT::Area_Infraestructura.SP_CrearGuardaparque TO Rol_Administrador_Parque;
GRANT EXECUTE ON OBJECT::Area_Excursiones.SP_CrearGuia TO Rol_Administrador_Parque;


GRANT EXECUTE ON OBJECT::Area_Negocios.SP_ModificarEmpresaConcesionaria TO Rol_Administrador_Parque;
GRANT EXECUTE ON OBJECT::Area_Negocios.SP_ModificarConcesion TO Rol_Administrador_Parque;
GRANT EXECUTE ON OBJECT::Area_Negocios.SP_ModificarCanon TO Rol_Administrador_Parque;
GRANT EXECUTE ON OBJECT::Area_Negocios.SP_ModificarTipoActividadConcesion TO Rol_Administrador_Parque;
GRANT EXECUTE ON OBJECT::Area_Negocios.SP_ModificarEstadoCanon TO Rol_Administrador_Parque;
GRANT EXECUTE ON OBJECT::Area_Negocios.SP_ModificarPagoCanon TO Rol_Administrador_Parque;
GRANT EXECUTE ON OBJECT::Area_Excursiones.SP_ModificarGuia TO Rol_Administrador_Parque;
GRANT EXECUTE ON OBJECT::Area_Excursiones.SP_ModificarGuardaparque TO Rol_Administrador_Parque;


GRANT EXECUTE ON OBJECT::Area_Negocios.SP_EliminarEmpresaConcesionaria TO Rol_Administrador_Parque;
GRANT EXECUTE ON OBJECT::Area_Negocios.SP_EliminarConcesion TO Rol_Administrador_Parque;
GRANT EXECUTE ON OBJECT::Area_Negocios.SP_EliminarCanon TO Rol_Administrador_Parque;
GRANT EXECUTE ON OBJECT::Area_Negocios.SP_EliminarTipoActividadConcesion TO Rol_Administrador_Parque;
GRANT EXECUTE ON OBJECT::Area_Negocios.SP_EliminarEstadoCanon TO Rol_Administrador_Parque;
GRANT EXECUTE ON OBJECT::Area_Negocios.SP_EliminarPagoCanon TO Rol_Administrador_Parque;
GRANT EXECUTE ON OBJECT::Area_Excursiones.SP_EliminarGuia TO Rol_Administrador_Parque;
GRANT EXECUTE ON OBJECT::Area_Excursiones.SP_EliminarGuardaparque TO Rol_Administrador_Parque;

GO

-- ////////////////////////////////////////////////////////////
--              G. Rol Guardaparque Común
-- ////////////////////////////////////////////////////////////
--Solo puede visualizar lo suyo
GRANT EXECUTE ON OBJECT::Area_Infraestructura.Sp_ModificarParque TO Rol_Guardaparque_Base;

GRANT EXECUTE ON OBJECT::Area_Infraestructura.SP_ModificarGuardaparque TO Rol_Guardaparque_Base

GRANT SELECT ON OBJECT::Area_Negocios.Concesion TO Rol_Guardaparque_Base;
GRANT SELECT ON OBJECT::Area_Excursiones.Actividad TO Rol_Guardaparque_Base;
GRANT SELECT ON OBJECT::Area_Excursiones.Tipo_Actividad TO Rol_Guardaparque_Base;
GO
-- ////////////////////////////////////////////////////////////
--              H. Rol Coordinador de Actividades
-- ////////////////////////////////////////////////////////////
--Se encarga de modificar y cambiar las actividades del parque.

GRANT EXECUTE ON OBJECT::Area_Excursiones.SP_CrearActividad TO Rol_Coord_Actividades;
GRANT EXECUTE ON OBJECT::Area_Excursiones.SP_CrearTipoActividad TO Rol_Coord_Actividades;

GRANT EXECUTE ON OBJECT::Area_Excursiones.Sp_ModificarActividad TO Rol_Coord_Actividades;
GRANT EXECUTE ON OBJECT::Area_Excursiones.SP_ModificarTipoActividad TO Rol_Coord_Actividades;

GRANT EXECUTE ON OBJECT::Area_Excursiones.Sp_EliminarActividad TO Rol_Coord_Actividades;
GRANT EXECUTE ON OBJECT::Area_Excursiones.SP_EliminarTipoActividad TO Rol_Coord_Actividades;

GRANT SELECT ON OBJECT::Area_Excursiones.Guia TO Rol_Coord_Actividades;

GO
-- ////////////////////////////////////////////////////////////
--              I. Rol Jefe de Guias
-- ////////////////////////////////////////////////////////////
--El si puede agregar y modificar nuevos guías.
GRANT EXECUTE ON OBJECT::Area_Excursiones.SP_CrearContratacionActividad TO Rol_Jefe_Guias;
GRANT EXECUTE ON OBJECT::Area_Excursiones.SP_CrearGuia TO Rol_Jefe_Guias;
GRANT EXECUTE ON OBJECT::Area_Excursiones.SP_CrearHabilitacion TO Rol_Jefe_Guias;
GRANT EXECUTE ON OBJECT::Area_Excursiones.SP_CrearHabilitacion_Guia TO Rol_Jefe_Guias;

GRANT EXECUTE ON OBJECT::Area_Excursiones.SP_ModificarGuia TO Rol_Jefe_Guias;
GRANT EXECUTE ON OBJECT::Area_Excursiones.SP_ModificarContratacionActividad TO Rol_Jefe_Guias;
GRANT EXECUTE ON OBJECT::Area_Excursiones.SP_ModificarHabilitacion TO Rol_Jefe_Guias;
GRANT EXECUTE ON OBJECT::Area_Excursiones.SP_ModificarHabilitacion_Guia TO Rol_Jefe_Guias;


GRANT EXECUTE ON OBJECT::Area_Excursiones.SP_EliminarHabilitacion TO Rol_Jefe_Guias;
GRANT EXECUTE ON OBJECT::Area_Excursiones.SP_EliminarGuia TO Rol_Jefe_Guias;
GRANT EXECUTE ON OBJECT::Area_Excursiones.SP_EliminarContratacionActividad TO Rol_Jefe_Guias;
grant execute on object::Area_Excursiones.SP_EliminarHabilitacion_Guia TO Rol_Jefe_Guias;


GRANT VIEW DEFINITION ON SYMMETRIC KEY::SymKey_DNI_SGPN TO Rol_Jefe_Guias;
GRANT CONTROL ON CERTIFICATE::Certificado_DNI_SGPN TO Rol_Jefe_Guias; 

GRANT EXECUTE ON OBJECT::Area_Excursiones.SP_ConsultarGuias_GuiaJefe TO Rol_Jefe_Guias;


GO
--Faltaría un :
--GRANT SELECT,UPDATE ON OBJECT::Area_Excursiones.Guia
--GRANT SELECT ON OBJECT::Area_Excursiones.Habilitacion

-- ////////////////////////////////////////////////////////////
--              J. Rol de Guias
-- ////////////////////////////////////////////////////////////
--Solo deberían poder ver a los suyos y sus modificaciones

GRANT SELECT ON OBJECT::Area_Excursiones.Guia TO Rol_Guia_Base;
GRANT SELECT ON OBJECT::Area_Excursiones.Habilitacion TO Rol_Guia_Base;
GRANT SELECT ON OBJECT::Area_Excursiones.Habilitacion_Guia TO Rol_Guia_Base;

--Modificarse a si mismo.
GRANT EXECUTE ON OBJECT::Area_Excursiones.SP_ModificarGuia TO Rol_Guia_Base;

GRANT SELECT ON OBJECT::Area_Excursiones.Actividad TO Rol_Guia_Base;
GRANT SELECT ON OBJECT::Area_Excursiones.Tipo_Actividad TO Rol_Guia_Base;

GRANT EXECUTE ON OBJECT::Area_Excursiones.SP_ConsultarMisDatos_Guia TO Rol_Guia_Base;

GO
-- ////////////////////////////////////////////////////////////
--              K. Rol de Jefe de concesiones
-- ////////////////////////////////////////////////////////////


GRANT EXECUTE ON OBJECT::Area_Negocios.SP_CrearCanon TO Rol_Jefe_Concesiones;
GRANT EXECUTE ON OBJECT::Area_Negocios.SP_CrearEstadoCanon TO Rol_Jefe_Concesiones;
GRANT EXECUTE ON OBJECT::Area_Negocios.SP_CrearPagoCanon TO Rol_Admin_Concesion;


GRANT EXECUTE ON OBJECT::Area_Negocios.SP_ModificarConcesion TO Rol_Jefe_Concesiones;
GRANT EXECUTE ON OBJECT::Area_Negocios.SP_ModificarCanon TO Rol_Jefe_Concesiones;
GRANT EXECUTE ON OBJECT::Area_Negocios.SP_ModificarEstadoCanon TO Rol_Jefe_Concesiones;
GRANT EXECUTE ON OBJECT::Area_Negocios.SP_ModificarPagoCanon TO Rol_Jefe_Concesiones;



GRANT EXECUTE ON OBJECT::Area_Negocios.SP_EliminarCanon TO Rol_Jefe_Concesiones;

GRANT EXECUTE ON OBJECT::Area_Negocios.SP_EliminarEstadoCanon TO Rol_Jefe_Concesiones;
GRANT EXECUTE ON OBJECT::Area_Negocios.SP_EliminarPagoCanon TO Rol_Jefe_Concesiones;

GO
-- ////////////////////////////////////////////////////////////
--              L. Rol de Admin de concesiones
-- ////////////////////////////////////////////////////////////

GRANT EXECUTE ON OBJECT::Area_Negocios.SP_CrearEmpresaConcesionaria TO Rol_Admin_Concesion;
GRANT EXECUTE ON OBJECT::Area_Negocios.SP_CrearConcesion TO Rol_Admin_Concesion;
GRANT EXECUTE ON OBJECT::Area_Negocios.SP_CrearTipoActividadConcesion TO Rol_Admin_Concesion;


GRANT EXECUTE ON OBJECT::Area_Negocios.SP_ModificarEmpresaConcesionaria TO Rol_Admin_Concesion;
GRANT EXECUTE ON OBJECT::Area_Negocios.SP_ModificarTipoActividadConcesion TO Rol_Admin_Concesion;
GRANT EXECUTE ON OBJECT::Area_Negocios.SP_ModificarConcesion TO Rol_Admin_Concesion;

GRANT EXECUTE ON OBJECT::Area_Negocios.SP_EliminarEmpresaConcesionaria TO Rol_Admin_Concesion;
GRANT EXECUTE ON OBJECT::Area_Negocios.SP_EliminarConcesion TO Rol_Admin_Concesion;
GRANT EXECUTE ON OBJECT::Area_Negocios.SP_EliminarTipoActividadConcesion TO Rol_Admin_Concesion;

GRANT SELECT ON OBJECT::Area_Negocios.Canon TO Rol_Admin_Concesion;

go
-- ////////////////////////////////////////////////////////////
--              M. Rol de Concesionante
-- ////////////////////////////////////////////////////////////
GRANT SELECT ON OBJECT::Area_Negocios.Concesion TO Rol_Concesionante;
GRANT SELECT ON OBJECT::Area_Negocios.Tipo_Actividad_Concesion TO Rol_Concesionante;
GRANT SELECT ON OBJECT::Area_Negocios.Canon TO Rol_Concesionante;
go
-- ////////////////////////////////////////////////////////////
--              N. Rol de Comprador
-- ////////////////////////////////////////////////////////////
GRANT SELECT ON OBJECT::Area_Comercial.Entrada TO Rol_Comprador;
GRANT SELECT ON OBJECT::Area_Comercial.Venta TO Rol_Comprador;
GRANT SELECT On object::Area_Comercial.Detalle_Venta_Entrada TO Rol_Comprador;
GO
-- ////////////////////////////////////////////////////////////