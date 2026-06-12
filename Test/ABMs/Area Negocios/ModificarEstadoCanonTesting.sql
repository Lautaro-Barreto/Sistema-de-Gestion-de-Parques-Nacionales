/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 12/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga del testing del Stored Procedure utilizado para
modificar Estado_Canon.
*/
USE SGParquesNacionales
GO

--SELECT * FROM Area_Negocios.Estado_Canon

--Preparacion del Entorno
EXEC Area_Negocios.SP_CrearEstadoCanon 'Pagado'
EXEC Area_Negocios.SP_CrearEstadoCanon 'Deuda'

--Caso  Exitoso.

EXEC Area_Negocios.SP_ModificarEstadoCanon 1,'Deuda'
EXEC Area_Negocios.SP_ModificarEstadoCanon 2,'Pagado'

-- Casos no Permitidos:

-- Nombre Vacío
EXEC Area_Negocios.SP_ModificarEstadoCanon  1,''
--Resultado: Algo salio mal en la modifiacion del Estado del Canon

--Nombre muy grande
EXEC Area_Negocios.SP_ModificarEstadoCanon  2,'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAbbbbbbbbbbAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbAAAbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbAAAbbbb'
--Resultado: Algo salio mal en la modifiacion del Estado del Canon

-- Nombre no compuesto por letras
EXEC Area_Negocios.SP_ModificarEstadoCanon  1,'123'
--Resultado: Algo salio mal en la modifiacion del Estado del Canon

-- Nombre nulo
EXEC Area_Negocios.SP_ModificarEstadoCanon  1,NULL
--Resultado: Algo salio mal en la modifiacion del Estado del Canon

-- Identificador Inexistente
EXEC Area_Negocios.SP_ModificarEstadoCanon  5,'Pagado'
--Resultado: Algo salio mal en la modifiacion del Estado del Canon