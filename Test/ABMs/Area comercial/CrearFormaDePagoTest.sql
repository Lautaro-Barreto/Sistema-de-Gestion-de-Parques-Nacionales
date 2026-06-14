/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 13/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de testear la creación de una forma de pago,
verificando que no se pueda crear una forma de pago con datos inválidos.
*/

USE SGParquesNacionales
GO

--Test 1: Creación exitosa
BEGIN TRY
	EXEC Area_Comercial.SP_CrearFormaDePago @Descripcion = 'FormaDePagoTest'

	SELECT * FROM Area_Comercial.Tipo_Visitante
	WHERE Descripcion = 'FormaDePagoTest'
END TRY
BEGIN CATCH
	PRINT 'Error al crear la forma de pago: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 2: Descripción inválida (vacía)
BEGIN TRY
	EXEC Area_Comercial.SP_CrearFormaDePago @Descripcion = ''
END TRY
BEGIN CATCH
	PRINT 'Error al crear la forma de pago: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 3: Descripción inválida (con caracteres que no sean letras)
BEGIN TRY
	EXEC Area_Comercial.SP_CrearFormaDePago @Descripcion = '$#F0rm4D3Pag0#"'
END TRY
BEGIN CATCH
	PRINT 'Error al crear la forma de pago: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 4: Descripción inválida (supera el tamaño declarado)
BEGIN TRY
	EXEC Area_Comercial.SP_CrearFormaDePago @Descripcion = 'FormaDePagoTestFormaDePagoTestFormaDePagoTest'
END TRY
BEGIN CATCH
	PRINT 'Error al crear la forma de pago: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 5: La descripción ya existe
BEGIN TRY
	EXEC Area_Comercial.SP_CrearFormaDePago @Descripcion = 'FormaDePagoTest'
END TRY
BEGIN CATCH
	PRINT 'Error al crear la forma de pago: ' + ERROR_MESSAGE();
END CATCH
GO