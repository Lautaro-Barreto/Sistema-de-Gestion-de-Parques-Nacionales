/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 12/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga del testing del Stored Procedure de la modificacion de una
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

EXEC Area_Negocios.SP_ModificarEmpresaConcesionaria @IdEmpresaConcesionaria = 1,@Nombre = 'Enterprise'

EXEC Area_Negocios.SP_ModificarEmpresaConcesionaria 2,'Ayudin'

EXEC Area_Negocios.SP_ModificarEmpresaConcesionaria 3,'Lavryol'

GO
-- Casos No Permitidos:

-- Nombre Vacío
EXEC Area_Negocios.SP_ModificarEmpresaConcesionaria 1,''
--Resultado: Algo salio mal en la modifiacion de la Empresa

--Nombre Nulo
EXEC Area_Negocios.SP_ModificarEmpresaConcesionaria 1, NULL
--Resultado: Algo salio mal en la modifiacion de la Empresa


--Nombre muy grande
EXEC Area_Negocios.SP_ModificarEmpresaConcesionaria 1, 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAbbbb'
--Resultado: Algo salio mal en la modifiacion de la Empresa

-- Nombre no compuesto por letras
EXEC Area_Negocios.SP_ModificarEmpresaConcesionaria 1,'123'
--Resultado: Algo salio mal en la modifiacion de la Empresa


-- Nombre Repetido
EXEC Area_Negocios.SP_ModificarEmpresaConcesionaria 1,'Lavryol'
--Resultado: Algo salio mal en la modifiacion de la Empresa