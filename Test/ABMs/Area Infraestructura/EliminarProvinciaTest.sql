/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Descripción: Test de Sp_EliminarProvincia
*/
USE SGParquesNacionales
GO

-- 1. Prueba de eliminacion exitosa de una provincia
-- Preparamos entorno
INSERT INTO Area_Infraestructura.Region (Nombre) VALUES ('Region Para Prov E');
DECLARE @IdReg INT = SCOPE_IDENTITY();
INSERT INTO Area_Infraestructura.Provincia (Nombre, IdRegion) VALUES ('Provincia a Eliminar', @IdReg);
DECLARE @Id INT = SCOPE_IDENTITY();
-- Ejecutamos
EXEC Area_Infraestructura.Sp_EliminarProvincia @IdProvincia = @Id;
-- Limpiamos
DELETE FROM Area_Infraestructura.Provincia WHERE IdProvincia = @Id;
DELETE FROM Area_Infraestructura.Region WHERE IdRegion = @IdReg;
GO

-- 2. Prueba de fallo por Id inexistente
EXEC Area_Infraestructura.Sp_EliminarProvincia @IdProvincia = -1;
GO
