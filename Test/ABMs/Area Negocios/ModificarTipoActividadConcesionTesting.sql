/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 12/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga del testing del Stored Procedure de la modificar de un
Tipo de actividad Concesion. 
*/
USE SGParquesNacionales
GO


--Select * from Area_Negocios.Tipo_Actividad_Concesion

--Preparacion del entorno de testing:
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Pizzeria'
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Puesto de Nachos'
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Taqueria'
GO
--Casos  Exitosos.

EXEC Area_Negocios.SP_ModificarTipoActividadConcesion 1,'Pastaria'
EXEC Area_Negocios.SP_ModificarTipoActividadConcesion 2,'Puesto de Hotdogs'

--EXEC Area_Negocios.SP_ModificarTipoActividadConcesion 2,'Puesto de Nachos'


-- Casos No Permitidos:

-- Nombre Vacío
EXEC Area_Negocios.SP_ModificarTipoActividadConcesion 1,''
--Resultado: Algo salio mal en la modificacion del Tipo De Actividad de la concesion

--Nombre Nulo
EXEC Area_Negocios.SP_ModificarTipoActividadConcesion 1,NULL
--Resultado: Algo salio mal en la modificacion del Tipo De Actividad de la concesion

--Nombre muy grande
EXEC Area_Negocios.SP_ModificarTipoActividadConcesion 1,'AAAAAAAAAAAAAAADVVVVAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAbbbb'
--Resultado: Algo salio mal en la modificación del Tipo De Actividad de la concesion

-- Nombre no compuesto por letras
EXEC Area_Negocios.SP_ModificarTipoActividadConcesion 1,'123'
--Resultado: Algo salio mal en la modificación del Tipo De Actividad de la concesion

-- Nombre Repetido
EXEC Area_Negocios.SP_ModificarTipoActividadConcesion 1,'Taqueria'
--Resultado: Algo salio mal en la modificación del Tipo De Actividad de la concesion

--Identificador inexistente
EXEC Area_Negocios.SP_ModificarTipoActividadConcesion 99,'Taqueria'
--Resultado: Algo salio mal en la modificación del Tipo De Actividad de la concesion