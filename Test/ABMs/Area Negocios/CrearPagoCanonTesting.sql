/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 12/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga del testing del Stored Procedure de la creación de un
Pago del canon. 
*/
USE SGParquesNacionales
GO

--Preparacion del Entorno de Testing:



--Casos  Exitosos.

EXEC Area_Negocios.SP_CrearPagoCanon 1,50000.60,'2026-06-12'
EXEC Area_Negocios.SP_CrearPagoCanon 2,45000.35,'2026-01-01'
EXEC Area_Negocios.SP_CrearPagoCanon 1,30000.00,'2026-02-03'
GO


-- Casos No Permitidos:
-- Canon Asociado Inexistente
EXEC Area_Negocios.SP_CrearPagoCanon 99,50000.60,'2026-05-12'
--Resultado: 

-- Canon Nulo
EXEC Area_Negocios.SP_CrearPagoCanon NULL,50000.60,'2026-05-12'
--Resultado: 

--Importe Nulo
EXEC Area_Negocios.SP_CrearPagoCanon 1,NULL,'2026-05-12'
--Resultado:

--Importe Negativo.
EXEC Area_Negocios.SP_CrearPagoCanon 1,-30000,'2026-05-12'
--Resultado:

--Importe 0 o valor cero.
EXEC Area_Negocios.SP_CrearPagoCanon 1,0,'2026-05-12'
--Resultado:


--Fecha Nula.
EXEC Area_Negocios.SP_CrearPagoCanon 1,0,NULL
--Resultado:

-- Dato no transformable en fecha
EXEC Area_Negocios.SP_CrearPagoCanon 1,0,'Varchar'
--Resultado:



