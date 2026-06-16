/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Descripción: Test de Sp_EliminarRegion
*/
USE SGParquesNacionales
GO

-- 1. Prueba de eliminacion exitosa de una region
-- Preparamos entorno
INSERT INTO Area_Infraestructura.Region (Nombre) VALUES ('Region a Eliminar');
DECLARE @Id INT = SCOPE_IDENTITY();
-- Ejecutamos
EXEC Area_Infraestructura.Sp_EliminarRegion @IdRegion = @Id;
-- Validamos que ya no este (o nos aseguramos que este limpio por si fallo la prueba)
DELETE FROM Area_Infraestructura.Region WHERE IdRegion = @Id;
GO

-- 2. Prueba de fallo por Id inexistente
EXEC Area_Infraestructura.Sp_EliminarRegion @IdRegion = -1;
GO
