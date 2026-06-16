/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Descripción: Test de Sp_ModificarGuardaparque
*/
USE SGParquesNacionales
GO

-- 1. Prueba de modificacion exitosa de un guardaparque
-- Preparamos entorno
INSERT INTO Area_Infraestructura.Region (Nombre) VALUES ('Region GPM');
DECLARE @IdReg INT = SCOPE_IDENTITY();
INSERT INTO Area_Infraestructura.Provincia (Nombre, IdRegion) VALUES ('Provincia GPM', @IdReg);
DECLARE @IdProv INT = SCOPE_IDENTITY();
INSERT INTO Area_Infraestructura.Tipo_Parque (Descripcion) VALUES ('Tipo GPM');
DECLARE @IdTipo INT = SCOPE_IDENTITY();
INSERT INTO Area_Infraestructura.Parque (Nombre, Superficie, IdProvincia, IdTipoParque, Activo) VALUES ('Parque GPM', 100, @IdProv, @IdTipo, 1);
DECLARE @IdParque INT = SCOPE_IDENTITY();
INSERT INTO Area_Infraestructura.Guardaparque (Nombre, Apellido, Dni, IdParque, Fecha_Ingreso, Fecha_Egreso, Activo) VALUES ('Juan', 'Perez', '33334444', @IdParque, '2023-01-01', '2023-12-31', 1);
DECLARE @Id INT = SCOPE_IDENTITY();
-- Ejecutamos
EXEC Area_Infraestructura.Sp_ModificarGuardaparque @IdGuardaparque = @Id, @Nombre = 'Pedro', @Apellido = 'Gomez';
-- Limpiamos
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Area_Infraestructura.Guardaparque') AND name = 'IdGuardaparque')
BEGIN
    DELETE FROM Area_Infraestructura.Guardaparque WHERE IdGuardaparque = @Id;
END
ELSE
BEGIN
    DELETE FROM Area_Infraestructura.Guardaparque WHERE Id_Guardaparque = @Id;
END
DELETE FROM Area_Infraestructura.Parque WHERE IdParque = @IdParque;
DELETE FROM Area_Infraestructura.Provincia WHERE IdProvincia = @IdProv;
DELETE FROM Area_Infraestructura.Region WHERE IdRegion = @IdReg;
DELETE FROM Area_Infraestructura.Tipo_Parque WHERE IdTipoParque = @IdTipo;
GO

-- 2. Prueba de fallo por Id inexistente
EXEC Area_Infraestructura.Sp_ModificarGuardaparque @IdGuardaparque = -1, @Nombre = 'Fallo';
GO
