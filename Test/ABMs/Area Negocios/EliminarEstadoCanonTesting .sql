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

--Preparacion del Entorno

EXEC Area_Negocios.SP_CrearEstadoCanon 'Pagado'
EXEC Area_Negocios.SP_CrearEstadoCanon 'Deuda'
EXEC Area_Negocios.SP_CrearEstadoCanon 'Deuda'

--Caso  Exitoso.

EXEC Area_Negocios.SP_EliminarEstadoCanon 1
EXEC Area_Negocios.SP_EliminarEstadoCanon 2

-- Casos no Permitidos:

-- Identificador Nulo
EXEC Area_Negocios.SP_EliminarEstadoCanon  NULL
--Resultado: Algo salio mal en la eliminacion del Estado de Canon

-- Identificador no Encontrado
EXEC Area_Negocios.SP_EliminarEstadoCanon 17
--Resultado: Algo salio mal en la eliminacion del Estado de Canon