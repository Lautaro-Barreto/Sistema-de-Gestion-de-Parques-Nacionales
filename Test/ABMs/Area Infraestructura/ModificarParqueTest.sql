/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Descripción: Test de Sp_ModificarParque
*/
USE SGParquesNacionales
GO

-- 1. Prueba de modificacion exitosa de un parque
-- Preparamos entorno
INSERT INTO Area_Infraestructura.Region (Nombre) VALUES ('Region PM');
DECLARE @IdReg INT = SCOPE_IDENTITY();
INSERT INTO Area_Infraestructura.Provincia (Nombre, IdRegion) VALUES ('Provincia PM', @IdReg);
DECLARE @IdProv INT = SCOPE_IDENTITY();
INSERT INTO Area_Infraestructura.Tipo_Parque (Descripcion) VALUES ('Tipo PM');
DECLARE @IdTipo INT = SCOPE_IDENTITY();
INSERT INTO Area_Infraestructura.Parque (Nombre, Superficie, IdProvincia, IdTipoParque, Activo) VALUES ('Parque a Modificar', 100, @IdProv, @IdTipo, 1);
DECLARE @Id INT = SCOPE_IDENTITY();
-- Ejecutamos
EXEC Area_Infraestructura.Sp_ModificarParque @IdParque = @Id, @Nombre = 'Parque Modificado', @Superficie = 200;
-- Limpiamos
DELETE FROM Area_Infraestructura.Parque WHERE IdParque = @Id;
DELETE FROM Area_Infraestructura.Provincia WHERE IdProvincia = @IdProv;
DELETE FROM Area_Infraestructura.Region WHERE IdRegion = @IdReg;
DELETE FROM Area_Infraestructura.Tipo_Parque WHERE IdTipoParque = @IdTipo;
GO

-- 2. Prueba de fallo por Id inexistente
EXEC Area_Infraestructura.Sp_ModificarParque @IdParque = -1, @Nombre = 'Parque Fallido';
GO
