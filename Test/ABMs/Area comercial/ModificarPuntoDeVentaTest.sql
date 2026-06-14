/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 13/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de testear la modificación de un punto de venta,
verificando que no se pueda modificar un punto de venta que no existe o con datos inválidos.
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
	EXEC Area_Comercial.SP_ModificarPuntoDeVenta
		@IdPuntoDeVenta = 1,
		@Descripcion = 'PuntoDeVentaModificado'
END TRY
BEGIN CATCH
	PRINT 'Error al modificar el punto de venta: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 2: Descripción inválida (vacía)
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarPuntoDeVenta
		@IdPuntoDeVenta = 1,
		@Descripcion = ''
END TRY
BEGIN CATCH
	PRINT 'Error al modificar el punto de venta: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 3: Descripción inválida (con caracteres que no son letras)
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarPuntoDeVenta
		@IdPuntoDeVenta = 1,
		@Descripcion = '|||PuntoDeVentaModificado'
END TRY
BEGIN CATCH
	PRINT 'Error al modificar el punto de venta: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 4: Descripción inválida (supera el tamaño declarado)
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarPuntoDeVenta
		@IdPuntoDeVenta = 1,
		@Descripcion = 'PuntoDeVentaModificadoPuntoDeVentaModificado'
END TRY
BEGIN CATCH
	PRINT 'Error al modificar el punto de venta: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 5: El punto de venta no está cargado en la DB
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarPuntoDeVenta 3, 'PuntoDeVentaModificado'
		@IdPuntoDeVenta = 3,
		@Descripcion = 'PuntoDeVentaModificado'
END TRY
BEGIN CATCH
	PRINT 'Error al modificar el punto de venta: ' + ERROR_MESSAGE();
END CATCH
GO