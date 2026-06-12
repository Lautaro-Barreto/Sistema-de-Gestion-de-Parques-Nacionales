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

EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Winguluy'
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Cardenal'
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Jumbolan'


--Casos  Exitosos.

EXEC Area_Negocios.SP_EliminarEmpresaConcesionaria @IdEmpresa = 1

EXEC Area_Negocios.SP_EliminarEmpresaConcesionaria 2

GO
-- Casos No Permitidos:

-- No existe la empresa buscada
EXEC Area_Negocios.SP_EliminarEmpresaConcesionaria 5
--Resultado: Algo salio mal en la eliminacion del guardaparque

-- La empresa ya está inactiva o borrada
EXEC Area_Negocios.SP_EliminarEmpresaConcesionaria 1
--Resultado: Algo salio mal en la modifiacion de la Empresa
