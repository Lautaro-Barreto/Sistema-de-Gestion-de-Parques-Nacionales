/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 12/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga del testing del Stored Procedure utilizado para
crear Estado_Canon.
*/


--Select * FROM Area_Negocios.Estado_Canon
--Caso  Exitoso.
EXEC Area_Negocios.SP_CrearEstadoCanon 'Pagado'


-- Casos no Permitidos:

-- Nombre Vacío
EXEC Area_Negocios.SP_CrearEstadoCanon ''
--Resultado: Algo salio mal en la creación del estado del canon

--Nombre muy grande
EXEC Area_Negocios.SP_CrearEstadoCanon 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAbbbbbbbbbbAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbAAAbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbAAAbbbb'
--Resultado: Algo salio mal en la creación del estado del canon

-- Nombre no compuesto por letras
EXEC Area_Negocios.SP_CrearEstadoCanon '123'
--Resultado: Algo salio mal en el registro del nombre de la empresa

-- Nombre nulo
EXEC Area_Negocios.SP_CrearEstadoCanon NULL
--Resultado: Algo salio mal en el registro del nombre de la empresa