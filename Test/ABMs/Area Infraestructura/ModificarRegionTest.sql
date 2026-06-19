/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Descripción: Test de Sp_ModificarRegion
*/
USE SGParquesNacionales
GO

-- 1. Prueba de modificacion exitosa de una region
-- Preparamos entorno
INSERT INTO Area_Infraestructura.Region (Nombre) VALUES ('Region a Modificar');
DECLARE @Id INT = SCOPE_IDENTITY();
-- Ejecutamos
EXEC Area_Infraestructura.Sp_ModificarRegion @IdRegion = @Id, @Nombre = 'Region Modificada';
-- Limpiamos
DELETE FROM Area_Infraestructura.Region WHERE IdRegion = @Id;
GO

-- 2. Prueba de fallo por Id inexistente
EXEC Area_Infraestructura.Sp_ModificarRegion @IdRegion = -1, @Nombre = 'Region Fallida';
GO

-- 3. Prueba de fallo por nombre invalido
-- Preparamos entorno
INSERT INTO Area_Infraestructura.Region (Nombre) VALUES ('Region M2');
DECLARE @Id2 INT = SCOPE_IDENTITY();
-- Ejecutamos
EXEC Area_Infraestructura.Sp_ModificarRegion @IdRegion = @Id2, @Nombre = '';
-- Limpiamos
DELETE FROM Area_Infraestructura.Region WHERE IdRegion = @Id2;
GO
