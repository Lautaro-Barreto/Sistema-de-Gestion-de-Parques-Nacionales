/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 13/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de testear la eliminación de un punto de venta,
verificando que no se pueda eliminar un punto de venta inexistente.
*/

USE SGParquesNacionales
GO

--Se crea un punto de venta de prueba para realizar los tests. El ID de este caso será 1
BEGIN TRY
	EXEC Area_Comercial.SP_CrearPuntoDeVenta @Descripcion = 'PuntoDeVentaTest'
END TRY
BEGIN CATCH
	PRINT 'Error al crear el punto de venta: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 1: Caso exitoso
BEGIN TRY
	EXEC Area_Comercial.SP_EliminarPuntoDeVenta @IdPuntoDeVenta = 1
END TRY
BEGIN CATCH
	PRINT 'Error al eliminar el punto de venta: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 2: El punto de venta no está cargado en la DB
BEGIN TRY
	EXEC Area_Comercial.SP_EliminarPuntoDeVenta @IdPuntoDeVenta = 3
END TRY
BEGIN CATCH
	PRINT 'Error al eliminar el punto de venta: ' + ERROR_MESSAGE();
END CATCH
GO