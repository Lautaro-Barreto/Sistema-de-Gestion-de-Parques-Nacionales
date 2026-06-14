/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 13/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de testear la creación de un tipo de visitante,
verificando que no se pueda crear un tipo de visitante con datos inválidos.
*/

USE SGParquesNacionales
GO

--Test 1: Creación exitosa
BEGIN TRY
	EXEC Area_Comercial.SP_CrearTipoVisitante @Descripcion = 'TipoVisitanteTest'

	SELECT * FROM Area_Comercial.Tipo_Visitante
	WHERE Descripcion = 'TipoVisitanteTest'
END TRY
BEGIN CATCH
	PRINT 'Error al crear el tipo de visitante: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 2: Descripción inválida (vacía)
BEGIN TRY
	EXEC Area_Comercial.SP_CrearTipoVisitante @Descripcion = ''
END TRY
BEGIN CATCH
	PRINT 'Error al crear el tipo de visitante: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 3: Descripción inválida (con caracteres que no sean letras)
BEGIN TRY
	EXEC Area_Comercial.SP_CrearTipoVisitante @Descripcion = 'TipoVisitanteTest&|'
END TRY
BEGIN CATCH
	PRINT 'Error al crear el tipo de visitante: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 4: Descripción inválida (supera el tamaño declarado)
BEGIN TRY
	EXEC Area_Comercial.SP_CrearTipoVisitante @Descripcion = 'TipoVisitanteTestTipoVisitanteTestTipoVisitanteTest'
END TRY
BEGIN CATCH
	PRINT 'Error al crear el tipo de visitante: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 5: La descripción ya existe
BEGIN TRY
	EXEC Area_Comercial.SP_CrearTipoVisitante @Descripcion = 'TipoVisitanteTest'
END TRY
BEGIN CATCH
	PRINT 'Error al crear el tipo de visitante: ' + ERROR_MESSAGE();
END CATCH
GO