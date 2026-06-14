/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 13/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de testear la eliminación de un tipo de visitante,
verificando que no se pueda eliminar un tipo de visitante inexistente.
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
	EXEC Area_Comercial.SP_EliminarTipoVisitante @IdTipoVisitante = 1
END TRY
BEGIN CATCH
	PRINT 'Error al eliminar el tipo de visitante: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 2: El tipo de visitante no está cargado en la DB
BEGIN TRY
	EXEC Area_Comercial.SP_EliminarTipoVisitante @IdTipoVisitante = 3
END TRY
BEGIN CATCH
	PRINT 'Error al eliminar el tipo de visitante: ' + ERROR_MESSAGE();
END CATCH
GO