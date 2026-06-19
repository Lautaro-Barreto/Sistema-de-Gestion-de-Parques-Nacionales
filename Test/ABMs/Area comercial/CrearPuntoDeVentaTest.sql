/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 13/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripci�n: Este script se encarga de testear la creaci�n de un punto de venta,
verificando que no se pueda crear un punto de venta con datos inv�lidos.
*/

USE SGParquesNacionales
GO

--Test 1: Creaci�n exitosa
BEGIN TRY
	EXEC Area_Comercial.SP_CrearPuntoDeVenta @Descripcion = 'PuntoDeVentaTest'

	SELECT * FROM Area_Comercial.Punto_De_Venta
	WHERE Descripcion = 'PuntoDeVentaTest'
END TRY
BEGIN CATCH
	PRINT 'Error al crear el punto de venta: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 2: Descripci�n inv�lida (vac�a)
BEGIN TRY
	EXEC Area_Comercial.SP_CrearPuntoDeVenta @Descripcion = ''
END TRY
BEGIN CATCH
	PRINT 'Error al crear el punto de venta: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 3: Descripci�n inv�lida (con caracteres que no sean letras)
BEGIN TRY
	EXEC Area_Comercial.SP_CrearPuntoDeVenta @Descripcion = '+PuntoD3V3ntaT3st.'
END TRY
BEGIN CATCH
	PRINT 'Error al crear el punto de venta: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 4: Descripci�n inv�lida (supera el tama�o declarado)
BEGIN TRY
	EXEC Area_Comercial.SP_CrearPuntoDeVenta @Descripcion = 'PuntoDeVentaTestPuntoDeVentaTestPuntoDeVentaTestPuntoDeVentaTestPuntoDeVentaTestPuntoDeVentaTestPuntoDeVentaTest'
END TRY
BEGIN CATCH
	PRINT 'Error al crear el punto de venta: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 5: La descripci�n ya existe
BEGIN TRY
	EXEC Area_Comercial.SP_CrearPuntoDeVenta @Descripcion = 'PuntoDeVentaTest'
END TRY
BEGIN CATCH
	PRINT 'Error al crear el punto de venta: ' + ERROR_MESSAGE();
END CATCH
GO