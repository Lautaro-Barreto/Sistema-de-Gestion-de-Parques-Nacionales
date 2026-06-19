/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Descripción: Test de Sp_ModificarTipoParque
*/
USE SGParquesNacionales
GO

-- 1. Prueba de modificacion exitosa de un tipo de parque
-- Preparamos entorno
INSERT INTO Area_Infraestructura.Tipo_Parque (Descripcion) VALUES ('Tipo a Modificar');
DECLARE @Id INT = SCOPE_IDENTITY();
-- Ejecutamos
EXEC Area_Infraestructura.Sp_ModificarTipoParque @IdTipoParque = @Id, @Descripcion = 'Tipo Modificado';
-- Limpiamos
DELETE FROM Area_Infraestructura.Tipo_Parque WHERE IdTipoParque = @Id;
GO

-- 2. Prueba de fallo por Id inexistente
EXEC Area_Infraestructura.Sp_ModificarTipoParque @IdTipoParque = -1, @Descripcion = 'Tipo Fallido';
GO

-- 3. Prueba de fallo por descripcion invalida
-- Preparamos entorno
INSERT INTO Area_Infraestructura.Tipo_Parque (Descripcion) VALUES ('Tipo M2');
DECLARE @Id2 INT = SCOPE_IDENTITY();
-- Ejecutamos
EXEC Area_Infraestructura.Sp_ModificarTipoParque @IdTipoParque = @Id2, @Descripcion = '';
-- Limpiamos
DELETE FROM Area_Infraestructura.Tipo_Parque WHERE IdTipoParque = @Id2;
GO
