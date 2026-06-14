/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 13/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de testear la modificación de un tipo de visitante,
verificando que no se pueda modificar un tipo de visitante que no existe o con datos inválidos.
*/

USE SGParquesNacionales
GO

--Se crea un tipo de visitante de prueba para realizar los tests. El ID de este caso será 1
BEGIN TRY
	EXEC Area_Comercial.SP_CrearTipoVisitante @Descripcion = 'TipoVisitanteTest'
END TRY
BEGIN CATCH
	PRINT 'Error al crear el tipo de visitante: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 1: Caso exitoso
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarTipoVisitante
		@IdTipoVisitante = 1,
		@Descripcion = 'TipoVisitanteModificado'

	SELECT * FROM Area_Comercial.Forma_De_Pago
	WHERE IdFormaDePago = 1
END TRY
BEGIN CATCH
	PRINT 'Error al modificar el tipo de visitante: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 2: Descripción inválida (vacía)
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarTipoVisitante
		@IdTipoVisitante = 1,
		@Descripcion = ''
END TRY
BEGIN CATCH
	PRINT 'Error al modificar el tipo de visitante: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 3: Descripción inválida (con caracteres que no son letras)
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarTipoVisitante
		@IdTipoVisitante = 1,
		@Descripcion = '123TipoVisitanteModificado&#'
END TRY
BEGIN CATCH
	PRINT 'Error al modificar el tipo de visitante: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 4: Descripción inválida (supera el tamaño declarado)
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarTipoVisitante
		@IdTipoVisitante = 1,
		@Descripcion = 'TipoVisitanteModificadoTipoVisitanteModificado'
END TRY
BEGIN CATCH
	PRINT 'Error al modificar el tipo de visitante: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 5: El tipo de visitante no está cargado en la DB
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarTipoVisitante
		@IdTipoVisitante = 3,
		@Descripcion = 'TipoVisitanteModificado'
END TRY
BEGIN CATCH
	PRINT 'Error al modificar el tipo de visitante: ' + ERROR_MESSAGE();
END CATCH
GO