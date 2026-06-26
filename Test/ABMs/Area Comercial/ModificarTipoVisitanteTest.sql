/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 13/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripci�n: Este script se encarga de testear la modificaci�n de un tipo de visitante,
verificando que no se pueda modificar un tipo de visitante que no existe o con datos inv�lidos.
*/

USE SGParquesNacionales
GO

--Se crea un tipo de visitante de prueba para realizar los tests. El ID de este caso ser� 1
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

--Test 2: Descripci�n inv�lida (vac�a)
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarTipoVisitante
		@IdTipoVisitante = 1,
		@Descripcion = ''
END TRY
BEGIN CATCH
	PRINT 'Error al modificar el tipo de visitante: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 3: Descripci�n inv�lida (con caracteres que no son letras)
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarTipoVisitante
		@IdTipoVisitante = 1,
		@Descripcion = '123TipoVisitanteModificado&#'
END TRY
BEGIN CATCH
	PRINT 'Error al modificar el tipo de visitante: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 4: Descripci�n inv�lida (supera el tama�o declarado)
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarTipoVisitante
		@IdTipoVisitante = 1,
		@Descripcion = 'TipoVisitanteModificadoTipoVisitanteModificadoTipoVisitanteModificadoTipoVisitanteModificadoTipoVisitanteModificado'
END TRY
BEGIN CATCH
	PRINT 'Error al modificar el tipo de visitante: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 5: El tipo de visitante no est� cargado en la DB
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarTipoVisitante
		@IdTipoVisitante = 3,
		@Descripcion = 'TipoVisitanteModificado'
END TRY
BEGIN CATCH
	PRINT 'Error al modificar el tipo de visitante: ' + ERROR_MESSAGE();
END CATCH
GO