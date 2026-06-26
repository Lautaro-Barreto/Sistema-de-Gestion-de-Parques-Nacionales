/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 13/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripci�n: Este script se encarga de testear la modificaci�n de un punto de venta,
verificando que no se pueda modificar un punto de venta que no existe o con datos inv�lidos.
*/

USE SGParquesNacionales
GO

--Se crea un punto de venta de prueba para realizar los tests. El ID de este caso ser� 1
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

--Test 2: Descripci�n inv�lida (vac�a)
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarPuntoDeVenta
		@IdPuntoDeVenta = 1,
		@Descripcion = ''
END TRY
BEGIN CATCH
	PRINT 'Error al modificar el punto de venta: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 3: Descripci�n inv�lida (con caracteres que no son letras)
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarPuntoDeVenta
		@IdPuntoDeVenta = 1,
		@Descripcion = '|||PuntoDeVentaModificado'
END TRY
BEGIN CATCH
	PRINT 'Error al modificar el punto de venta: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 4: Descripci�n inv�lida (supera el tama�o declarado)
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarPuntoDeVenta
		@IdPuntoDeVenta = 1,
		@Descripcion = 'PuntoDeVentaModificadoPuntoDeVentaModificadoPuntoDeVentaModificadoPuntoDeVentaModificadoPuntoDeVentaModificadoPuntoDeVentaModificado'
END TRY
BEGIN CATCH
	PRINT 'Error al modificar el punto de venta: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 5: El punto de venta no est� cargado en la DB
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarPuntoDeVenta 3, 'PuntoDeVentaModificado'
		@IdPuntoDeVenta = 3,
		@Descripcion = 'PuntoDeVentaModificado'
END TRY
BEGIN CATCH
	PRINT 'Error al modificar el punto de venta: ' + ERROR_MESSAGE();
END CATCH
GO