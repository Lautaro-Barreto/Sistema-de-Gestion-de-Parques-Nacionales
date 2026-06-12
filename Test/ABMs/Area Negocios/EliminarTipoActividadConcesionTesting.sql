/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 12/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga del testing del Stored Procedure de la eliminar de un
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

EXEC Area_Negocios.SP_EliminarTipoActividadConcesion 1
EXEC Area_Negocios.SP_EliminarTipoActividadConcesion 2
GO



-- Casos No Permitidos:

--Identificador Nulo
EXEC Area_Negocios.SP_EliminarTipoActividadConcesion NULL
--Resultado: Algo salio mal en la eliminación del Tipo de Actividad Concesion

--Identificador inexistente
EXEC Area_Negocios.SP_EliminarTipoActividadConcesion 99
--Resultado: Algo salio mal en la eliminación del Tipo de Actividad Concesion
