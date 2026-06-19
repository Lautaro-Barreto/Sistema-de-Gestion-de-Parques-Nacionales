/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 12/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga del testing del Stored Procedure utilizado para
Eliminar Estado_Canon.
*/
USE SGParquesNacionales
GO

--SELECT * FROM Area_Negocios.Estado_Canon
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
--Preparacion del Entorno

EXEC Area_Infraestructura.Sp_CrearRegion 'Noreste';
EXEC Area_Infraestructura.Sp_CrearProvincia 'Misiones', 'Noreste';
EXEC Area_Infraestructura.Sp_CrearTipoParque 'Selva';
EXEC Area_Infraestructura.Sp_CrearParque 'Parque Nacional Iguazú', 'Selva', 'Misiones', 50000.00;

EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Empresa Estado Test';
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Actividad X';

-- Creamos 2 estados
EXEC Area_Negocios.SP_CrearEstadoCanon 'Estado Bloqueado';
EXEC Area_Negocios.SP_CrearEstadoCanon 'Estado Descartable';
GO
--Caso  Exitoso.
--Nuevamente busco un estado de canon
DECLARE @IdEstadoBorrar INT = (SELECT MAX(IdEstadoCanon) FROM Area_Negocios.Estado_Canon);
EXEC Area_Negocios.SP_EliminarEstadoCanon @IdEstadoCanon = @IdEstadoBorrar;

-- Casos no Permitidos:

-- Identificador Nulo
EXEC Area_Negocios.SP_EliminarEstadoCanon  NULL
--Resultado: Algo salio mal en la eliminacion del Estado de Canon

-- Identificador no Encontrado
EXEC Area_Negocios.SP_EliminarEstadoCanon 99999
--Resultado: Algo salio mal en la eliminacion del Estado de Canon+


-- Intentar borrar una que ya tiene canon asociado (Estado en uso por un Canon)
--Primero lo creamos
--Selecciono un id empresa y actividad y parque, buscando el maximo para que no interfiera
--el identity de las claves primarias.
DECLARE @IdEmpresa INT = (SELECT MAX(IdEmpresa) FROM Area_Negocios.Empresa_Concesionaria where Estado=1);
DECLARE @IdActividad INT = (SELECT MAX(IdTipoActividadConcesion) FROM Area_Negocios.Tipo_Actividad_Concesion);
DECLARE @IdParque INT = (SELECT MAX(IdParque) FROM Area_Infraestructura.Parque);
--La fecha de inicio es ahora y la de fin es un año despues
DECLARE @FechaIn DATE = CAST(GETDATE() AS DATE);
DECLARE @FechaFin DATE = DATEADD(year, 1, CAST(GETDATE() AS DATE));
--Finalmente creo la concesión
EXEC Area_Negocios.SP_CrearConcesion @IdActividad, @IdEmpresa, @IdParque, @FechaIn, @FechaFin;
--Ahora selecciono la concesión (la última creada)
DECLARE @IdConcesion INT = (SELECT MAX(IdConcesion) FROM Area_Negocios.Concesion);
DECLARE @IdEstadoBloqueado INT = (SELECT MIN(IdEstadoCanon) FROM Area_Negocios.Estado_Canon);
DECLARE @Vencimiento DATE = DATEADD(month, 1, CAST(GETDATE() AS DATE));


--Con el canon creado, su estado no se podría borrar
EXEC Area_Negocios.SP_CrearCanon @IdEstadoBloqueado, @IdConcesion, 500.00, @Vencimiento;
EXEC Area_Negocios.SP_EliminarEstadoCanon @IdEstadoCanon = @IdEstadoBloqueado;
GO