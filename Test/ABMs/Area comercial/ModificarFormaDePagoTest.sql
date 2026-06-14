/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 13/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de testear la modificación de una forma de pago,
verificando que no se pueda modificar una forma de pago que no existe o con datos inválidos.
*/

USE SGParquesNacionales
GO

--Se crea una forma de pago de prueba para realizar los tests. El ID de este caso será 1
BEGIN TRY
	EXEC Area_Comercial.SP_CrearFormaDePago @Descripcion = 'FormaDePagoTest'
END TRY
BEGIN CATCH
	PRINT 'Error al crear la forma de pago: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 1: Caso exitoso
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarFormaDePago
		@IdFormaDePago = 1,
		@Descripcion = 'FormaDePagoModificada'
END TRY
BEGIN CATCH
	PRINT 'Error al modificar la forma de pago: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 2: Descripción inválida (vacía)
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarFormaDePago
		@IdFormaDePago = 1,
		@Descripcion = ''
END TRY
BEGIN CATCH
	PRINT 'Error al modificar la forma de pago: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 3: Descripción inválida (con caracteres que no son letras)
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarFormaDePago
		@IdFormaDePago = 1,
		@Descripcion = 'FormaDePagoModificada505'
END TRY
BEGIN CATCH
	PRINT 'Error al modificar la forma de pago: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 4: Descripción inválida (supera el tamaño declarado)
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarFormaDePago
		@IdFormaDePago = 1,
		@Descripcion = 'FormaDePagoModificadaFormaDePagoModificada'
END TRY
BEGIN CATCH
	PRINT 'Error al modificar la forma de pago: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 5: La forma de pago no está cargada en la DB
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarFormaDePago
		@IdFormaDePago = 3,
		@Descripcion = 'FormaDePagoModificada'
END TRY
BEGIN CATCH
	PRINT 'Error al modificar la forma de pago: ' + ERROR_MESSAGE();
END CATCH
GO