/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Descripción: Test de Sp_EliminarTipoParque
*/
USE SGParquesNacionales
GO

-- 1. Prueba de eliminacion exitosa de un tipo de parque
-- Preparamos entorno
INSERT INTO Area_Infraestructura.Tipo_Parque (Descripcion) VALUES ('Tipo a Eliminar');
DECLARE @Id INT = SCOPE_IDENTITY();
-- Ejecutamos
EXEC Area_Infraestructura.Sp_EliminarTipoParque @IdTipoParque = @Id;
-- Limpiamos
DELETE FROM Area_Infraestructura.Tipo_Parque WHERE IdTipoParque = @Id;
GO

-- 2. Prueba de fallo por Id inexistente
EXEC Area_Infraestructura.Sp_EliminarTipoParque @IdTipoParque = -1;
GO
