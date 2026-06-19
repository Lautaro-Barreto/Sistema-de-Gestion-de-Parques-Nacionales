/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 12/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga del testing del Stored Procedure de la eliminar de un
Tipo de actividad Concesion. 
*/
USE SGParquesNacionales
GO

DELETE FROM Area_Negocios.Pago_Canon;
DELETE FROM Area_Negocios.Canon;
DELETE FROM Area_Negocios.Concesion;
DELETE FROM Area_Negocios.Tipo_Actividad_Concesion;
DELETE FROM Area_Negocios.Empresa_Concesionaria;
DELETE FROM Area_Infraestructura.Parque;
DELETE FROM Area_Infraestructura.Tipo_Parque;
DELETE FROM Area_Infraestructura.Provincia;
DELETE FROM Area_Infraestructura.Region;
GO
--Select * from Area_Negocios.Tipo_Actividad_Concesion

-- 2. PREPARACIÓN DEL ENTORNO
-- ==========================================================================================
EXEC Area_Infraestructura.Sp_CrearRegion 'Noreste';
EXEC Area_Infraestructura.Sp_CrearProvincia 'Misiones', 'Noreste';
EXEC Area_Infraestructura.Sp_CrearTipoParque 'Selva';
EXEC Area_Infraestructura.Sp_CrearParque 'Parque Nacional Iguazú', 'Selva', 'Misiones', 50000.00;

EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Empresa Actividad Test';

-- Creamos 2 actividades
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Actividad Bloqueada';
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Actividad Efimera';
GO
--Casos  Exitosos.

DECLARE @IdActividadBorrar INT = (SELECT MAX(IdTipoActividadConcesion) FROM Area_Negocios.Tipo_Actividad_Concesion);
EXEC Area_Negocios.SP_EliminarTipoActividadConcesion @IdTipoActividadConcesion = @IdActividadBorrar;


-- Casos No Permitidos:

--Identificador Nulo
EXEC Area_Negocios.SP_EliminarTipoActividadConcesion NULL
--Resultado: Algo salio mal en la eliminación del Tipo de Actividad Concesion

--Identificador inexistente
EXEC Area_Negocios.SP_EliminarTipoActividadConcesion 9999
--Resultado: Algo salio mal en la eliminación del Tipo de Actividad Concesion

-- Integridad  (Actividad asignada a una Concesion)
DECLARE @IdEmpresa INT = (SELECT MAX(IdEmpresa) FROM Area_Negocios.Empresa_Concesionaria);
DECLARE @IdActividadBloqueada INT = (SELECT MIN(IdTipoActividadConcesion) FROM Area_Negocios.Tipo_Actividad_Concesion);
DECLARE @IdParque INT = (SELECT MAX(IdParque) FROM Area_Infraestructura.Parque);
DECLARE @FechaIn DATE = CAST(GETDATE() AS DATE);
DECLARE @FechaFin DATE = DATEADD(year, 1, CAST(GETDATE() AS DATE));

EXEC Area_Negocios.SP_CrearConcesion @IdActividadBloqueada, @IdEmpresa, @IdParque, @FechaIn, @FechaFin;

EXEC Area_Negocios.SP_EliminarTipoActividadConcesion @IdTipoActividadConcesion = @IdActividadBloqueada;
GO