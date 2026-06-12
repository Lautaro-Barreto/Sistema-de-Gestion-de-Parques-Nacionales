/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 12/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga del testing del Stored Procedure de la creación de una
Empresa Concesionaria. 
*/
USE SGParquesNacionales
GO

--Casos  Exitosos.

EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Empresa'
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Cardenal'
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Jumbolan'
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Amiguru'
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Reti Marley'


-- Casos No Permitidos:
-- Nombre Vacío
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria ''
--Resultado: Algo salio mal en el registro del nombre de la empresa

--Nombre Nulo
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria NULL

--Nombre muy grande
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAbbbb'
--Resultado: Algo salio mal en el registro del nombre de la empresa

-- Nombre no compuesto por letras
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria '123'
--Resultado: Algo salio mal en el registro del nombre de la empresa


-- Nombre Repetido
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Empresa'
--Resultado: Algo salio mal en el registro del nombre de la empresa
