/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 12/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga del testing del Stored Procedure de la creación de un
Tipo de actividad Concesion. 
*/
USE SGParquesNacionales
GO


--Select * from Area_Negocios.Tipo_Actividad_Concesion
--Casos  Exitosos.

EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Pizzeria'
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Puesto de Nachos'
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Taqueria'



-- Casos No Permitidos:

-- Nombre Vacío
EXEC Area_Negocios.SP_CrearTipoActividadConcesion ''
--Resultado: Algo salio mal en el registro del nombre de la empresa

--Nombre Nulo
EXEC Area_Negocios.SP_CrearTipoActividadConcesion NULL
--Resultado: Algo salio mal en la creación del Tipo de actividad de Concesion

--Nombre muy grande
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAbbbb'
--Resultado: Algo salio mal en la creación del Tipo de actividad de Concesion

-- Nombre no compuesto por letras
EXEC Area_Negocios.SP_CrearTipoActividadConcesion '123'
--Resultado: Algo salio mal en la creación del Tipo de actividad de Concesion

-- Nombre Repetido
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Pizzeria'
--Resultado: Algo salio mal en la creación del Tipo de actividad de Concesion
