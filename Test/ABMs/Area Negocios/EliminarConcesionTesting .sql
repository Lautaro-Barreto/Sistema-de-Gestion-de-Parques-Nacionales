/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 12/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga del testing del Stored Procedure utilizado para
eliminar una Concesion.
*/
USE SGParquesNacionales
GO

--SELECT * FROM Area_Negocios.Concesion
--Preparacion del entorno de testing:
--      específico
-- ==========================================================================================
-- 1. VACIADO DE TABLAS
-- DE ser necesario únicamente
DELETE FROM Area_Negocios.Pago_Canon;
DELETE FROM Area_Negocios.Canon;
DELETE FROM Area_Negocios.Concesion;
DELETE FROM Area_Negocios.Estado_Canon;
DELETE FROM Area_Negocios.Tipo_Actividad_Concesion;
DELETE FROM Area_Negocios.Empresa_Concesionaria;
DELETE FROM Area_Infraestructura.Parque;
DELETE FROM Area_Infraestructura.Tipo_Parque;
DELETE FROM Area_Infraestructura.Provincia;
DELETE FROM Area_Infraestructura.Region;
GO

-- 2. PREPARACIÓN DEL ENTORNO
-- ==========================================================================================
EXEC Area_Infraestructura.Sp_CrearRegion 'Noreste';
EXEC Area_Infraestructura.Sp_CrearProvincia 'Misiones', 'Noreste';
EXEC Area_Infraestructura.Sp_CrearTipoParque 'Selva';
EXEC Area_Infraestructura.Sp_CrearParque 'Parque Nacional Iguazú', 'Selva', 'Misiones', 50000.00;

EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Empresa Concesion Test';
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Boleteria Temporal';
EXEC Area_Negocios.SP_CrearEstadoCanon 'Vigente';
GO

-- Creamos 2 Concesiones
DECLARE @IdEmpresa INT = (SELECT MAX(IdEmpresa) FROM Area_Negocios.Empresa_Concesionaria);
DECLARE @IdActividad INT = (SELECT MAX(IdTipoActividadConcesion) FROM Area_Negocios.Tipo_Actividad_Concesion);
DECLARE @IdParque INT = (SELECT MAX(IdParque) FROM Area_Infraestructura.Parque);
DECLARE @FechaIn DATE = CAST(GETDATE() AS DATE);
DECLARE @FechaFin DATE = DATEADD(year, 1, CAST(GETDATE() AS DATE));

EXEC Area_Negocios.SP_CrearConcesion @IdActividad, @IdEmpresa, @IdParque, @FechaIn, @FechaFin; -- Para bloquear
EXEC Area_Negocios.SP_CrearConcesion @IdActividad, @IdEmpresa, @IdParque, @FechaIn, @FechaFin; -- Para borrar
GO
--Caso  Exitoso.
EXEC Area_Negocios.SP_EliminarConcesion @IdConcesion=3

-- Casos no Permitidos:

-- Concesion Nula
EXEC Area_Negocios.SP_EliminarConcesion  NULL
--Resultado: Algo salio mal en la eliminación de la Concesión

-- Concesion no encontrada
EXEC Area_Negocios.SP_EliminarConcesion 99
--Resultado: Algo salio mal en la eliminación de la Concesión


-- Intentar borrar una concesion pero que ya tiene canones.
--Primero la declaro:
DECLARE @IdConcesionBloqueada INT = (SELECT MIN(IdConcesion) FROM Area_Negocios.Concesion);
DECLARE @IdEstado INT = (SELECT MAX(IdEstadoCanon) FROM Area_Negocios.Estado_Canon);
DECLARE @Vencimiento DATE = DATEADD(month, 1, CAST(GETDATE() AS DATE));

EXEC Area_Negocios.SP_CrearCanon @IdEstado, @IdConcesionBloqueada, 1000.00, @Vencimiento;
EXEC Area_Negocios.SP_EliminarConcesion @IdConcesion = @IdConcesionBloqueada;
GO
--En efecto, no se puede eliminar porque tiene canon asociados
--Resultado: Algo salio mal en la eliminación de la Concesión

