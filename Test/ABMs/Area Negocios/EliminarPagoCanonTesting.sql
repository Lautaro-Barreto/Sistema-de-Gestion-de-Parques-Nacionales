/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 12/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga del testing del Stored Procedure de la eliminación de un
Pago del canon. 
*/
USE SGParquesNacionales
GO

-- ==========================================================================================
-- 1. VACIADO DE TABLAS
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

--Preparacion del Entorno de Testing:
-- ==========================================================================================
-- 2. PREPARACIÓN DEL ENTORNO
EXEC Area_Infraestructura.Sp_CrearRegion 'Noreste';
EXEC Area_Infraestructura.Sp_CrearProvincia 'Misiones', 'Noreste';
EXEC Area_Infraestructura.Sp_CrearTipoParque 'Selva';
EXEC Area_Infraestructura.Sp_CrearParque 'Parque Nacional Iguazú', 'Selva', 'Misiones', 50000.00;

EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Empresa Pago Test';
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Actividad X';
EXEC Area_Negocios.SP_CrearEstadoCanon 'Vigente';
GO

DECLARE @IdEmpresa INT = (SELECT MAX(IdEmpresa) FROM Area_Negocios.Empresa_Concesionaria);
DECLARE @IdActividad INT = (SELECT MAX(IdTipoActividadConcesion) FROM Area_Negocios.Tipo_Actividad_Concesion);
DECLARE @IdParque INT = (SELECT MAX(IdParque) FROM Area_Infraestructura.Parque);
DECLARE @FechaIn DATE = CAST(GETDATE() AS DATE);
DECLARE @FechaFin DATE = DATEADD(year, 1, CAST(GETDATE() AS DATE));

EXEC Area_Negocios.SP_CrearConcesion @IdActividad, @IdEmpresa, @IdParque, @FechaIn, @FechaFin;

DECLARE @IdConcesion INT = (SELECT MAX(IdConcesion) FROM Area_Negocios.Concesion);
DECLARE @IdEstado INT = (SELECT MAX(IdEstadoCanon) FROM Area_Negocios.Estado_Canon);
DECLARE @Vencimiento DATE = DATEADD(month, 1, CAST(GETDATE() AS DATE));

EXEC Area_Negocios.SP_CrearCanon @IdEstado, @IdConcesion, 500.00, @Vencimiento;

DECLARE @IdCanon INT = (SELECT MAX(IdCanon) FROM Area_Negocios.Canon);
DECLARE @FechaPago DATE = CAST(GETDATE() AS DATE);
EXEC Area_Negocios.SP_CrearPagoCanon @IdCanon, 500.00, @FechaPago;
GO


--Casos  Exitosos.
--SElect * FROM Area_Negocios.Pago_Canon
DECLARE @IdPagoBorrar INT = (SELECT MAX(IdPagoCanon) FROM Area_Negocios.Pago_Canon);
EXEC Area_Negocios.SP_EliminarPagoCanon @IdPagoCanon = @IdPagoBorrar;


-- Casos No Permitidos:

-- Pago de Canon  Inexistente
EXEC Area_Negocios.SP_EliminarPagoCanon NULL
--Resultado: Algo salio mal en la eliminación del Pago de Canon

-- Pago de Canon  Inexistente
EXEC Area_Negocios.SP_EliminarPagoCanon 9999
--Resultado: Algo salio mal en la eliminación del Pago de Canon
