/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 12/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga del testing del Stored Procedure de la eliminacion de una
Empresa Concesionaria.
*/
USE SGParquesNacionales
GO
--DELETE FROM Area_Negocios.Empresa_Concesionaria
--SELECT * FROM Area_Negocios.Empresa_Concesionaria

--Preparacion de Testeo:
--Preparacion del entorno de testing:
--      específico
-- 1. VACIADO DE TABLAS
-- ==========================================================================================
DELETE FROM Area_Negocios.Pago_Canon;
DELETE FROM Area_Negocios.Canon;
DELETE FROM Area_Negocios.Concesion;
DELETE FROM Area_Negocios.Empresa_Concesionaria;
GO

--Creamos
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Empresa Volatil S.A.';
GO

-- Creamos los cánones con fechas válidas a futuro
--SELECT * FROM Area_Negocios.Empresa_Concesionaria
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Winguluy'
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Cardenal.  d df '
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Jumbolan'


--Casos  Exitosos.
--Primero busco una que si exista independiente del id.
DECLARE @IdEmpresaBorrar INT = (SELECT MAX(IdEmpresa) FROM Area_Negocios.Empresa_Concesionaria);
EXEC Area_Negocios.SP_EliminarEmpresaConcesionaria @IdEmpresa = @IdEmpresaBorrar;

GO
-- Casos No Permitidos:

-- No existe la empresa buscada
EXEC Area_Negocios.SP_EliminarEmpresaConcesionaria 9999
--Resultado: Algo salio mal en la eliminacion de la empresa
-- La empresa ya está inactiva o borrada

DECLARE @IdEmpresaBorrar INT = (SELECT MAX(IdEmpresa) FROM Area_Negocios.Empresa_Concesionaria where Estado=0);
EXEC Area_Negocios.SP_EliminarEmpresaConcesionaria @IdEmpresa = @IdEmpresaBorrar;
--Resultado: No existe empresa concesionaria activa con ese ID
