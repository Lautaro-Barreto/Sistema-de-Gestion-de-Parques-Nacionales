/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 12/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga del testing del Stored Procedure utilizado para
Eliminar un Canon.
*/
USE SGParquesNacionales
GO

--SELECT * FROM Area_Negocios.Canon

-- ==========================================================================================
-- 1. VACIADO DE TABLAS (Orden inverso a las FK para evitar conflictos)
-- DE SER NECESARIO SE ELIMINAN LAS ANTERIORES PARA PROBAR CON TRANQUILIDAD.
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

EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Empresa Canon Test';
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Boleteria Temporal';
EXEC Area_Negocios.SP_CrearEstadoCanon 'Vigente';
GO

DECLARE @IdEmpresa INT = (SELECT MAX(IdEmpresa) FROM Area_Negocios.Empresa_Concesionaria);
DECLARE @IdActividad INT = (SELECT MAX(IdTipoActividadConcesion) FROM Area_Negocios.Tipo_Actividad_Concesion);
DECLARE @IdParque INT = (SELECT MAX(IdParque) FROM Area_Infraestructura.Parque);
DECLARE @FechaIn DATE = CAST(GETDATE() AS DATE);
DECLARE @FechaFin DATE = DATEADD(year, 1, CAST(GETDATE() AS DATE));

-- Creamos Concesion
EXEC Area_Negocios.SP_CrearConcesion @IdActividad, @IdEmpresa, @IdParque, @FechaIn, @FechaFin;
GO

-- Creamos 2 Cánones
DECLARE @IdConcesion INT = (SELECT MAX(IdConcesion) FROM Area_Negocios.Concesion);
DECLARE @IdEstado INT = (SELECT MAX(IdEstadoCanon) FROM Area_Negocios.Estado_Canon);
DECLARE @Vencimiento1 DATE = DATEADD(month, 1, CAST(GETDATE() AS DATE));
DECLARE @Vencimiento2 DATE = DATEADD(month, 2, CAST(GETDATE() AS DATE));

EXEC Area_Negocios.SP_CrearCanon @IdEstado, @IdConcesion, 45000.00, @Vencimiento1; -- Canon para bloquear con pago
EXEC Area_Negocios.SP_CrearCanon @IdEstado, @IdConcesion, 55000.00, @Vencimiento2; -- Canon a eliminar
GO

--Caso  Exitoso.
EXEC Area_Negocios.SP_EliminarCanon @IdCanon=2


-- Casos no Permitidos:

-- Canon Nulo
EXEC Area_Negocios.SP_EliminarCanon NULL
--Resultado: Algo salio mal en la eliminación del Canon


-- Canon Inexistente
EXEC Area_Negocios.SP_EliminarCanon 99
--Resultado: Algo salio mal en la eliminación del Canon
