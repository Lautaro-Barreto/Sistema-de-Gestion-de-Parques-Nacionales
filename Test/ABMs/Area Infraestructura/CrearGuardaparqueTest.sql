/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Descripción: Test de SP_CrearGuardaParque
*/
USE SGParquesNacionales
GO

-- 1. Prueba de creacion exitosa de un guardaparque
-- Preparamos dependencias
INSERT INTO Area_Infraestructura.Region (Nombre) VALUES ('Region GP');
DECLARE @IdReg INT = SCOPE_IDENTITY();
INSERT INTO Area_Infraestructura.Provincia (Nombre, IdRegion) VALUES ('Provincia GP', @IdReg);
DECLARE @IdProv INT = SCOPE_IDENTITY();
INSERT INTO Area_Infraestructura.Tipo_Parque (Descripcion) VALUES ('Tipo GP');
DECLARE @IdTipo INT = SCOPE_IDENTITY();
INSERT INTO Area_Infraestructura.Parque (Nombre, Superficie, IdProvincia, IdTipoParque, Activo) VALUES ('Parque GP', 100, @IdProv, @IdTipo, 1);
-- Ejecutamos la prueba
EXEC Area_Infraestructura.SP_CrearGuardaParque
    @Nombre = 'Juan',
    @Apellido = 'Perez',
    @Dni = '12345678',
    @Parque = 'Parque GP',
    @Fecha_Ingreso = '2023-01-01',
    @Fecha_Egreso = '2023-12-31',
    @Activo = 1;
-- Limpiamos
DELETE FROM Area_Infraestructura.Guardaparque WHERE Dni = '12345678';
DELETE FROM Area_Infraestructura.Parque WHERE Nombre = 'Parque GP';
DELETE FROM Area_Infraestructura.Provincia WHERE Nombre = 'Provincia GP';
DELETE FROM Area_Infraestructura.Region WHERE Nombre = 'Region GP';
DELETE FROM Area_Infraestructura.Tipo_Parque WHERE Descripcion = 'Tipo GP';
GO

-- 2. Prueba de fallo por nombre invalido
EXEC Area_Infraestructura.SP_CrearGuardaParque @Nombre = '', @Apellido = 'Perez', @Dni = '12345678', @Parque = 'Parque GP', @Fecha_Ingreso = '2023-01-01', @Fecha_Egreso = '2023-12-31', @Activo = 1;
GO

-- 3. Prueba de fallo por parque inexistente
EXEC Area_Infraestructura.SP_CrearGuardaParque @Nombre = 'Juan', @Apellido = 'Perez', @Dni = '12345678', @Parque = 'Parque Falso', @Fecha_Ingreso = '2023-01-01', @Fecha_Egreso = '2023-12-31', @Activo = 1;
GO

-- 4. Prueba de fallo por fechas invalidas (ingreso mayor a egreso)
-- Preparamos el entorno
INSERT INTO Area_Infraestructura.Region (Nombre) VALUES ('Region GP2');
DECLARE @IdReg2 INT = SCOPE_IDENTITY();
INSERT INTO Area_Infraestructura.Provincia (Nombre, IdRegion) VALUES ('Provincia GP2', @IdReg2);
DECLARE @IdProv2 INT = SCOPE_IDENTITY();
INSERT INTO Area_Infraestructura.Tipo_Parque (Descripcion) VALUES ('Tipo GP2');
DECLARE @IdTipo2 INT = SCOPE_IDENTITY();
INSERT INTO Area_Infraestructura.Parque (Nombre, Superficie, IdProvincia, IdTipoParque, Activo) VALUES ('Parque GP2', 100, @IdProv2, @IdTipo2, 1);
-- Ejecutamos la prueba (debe fallar)
EXEC Area_Infraestructura.SP_CrearGuardaParque @Nombre = 'Juan', @Apellido = 'Perez', @Dni = '12345678', @Parque = 'Parque GP2', @Fecha_Ingreso = '2023-12-31', @Fecha_Egreso = '2023-01-01', @Activo = 1;
-- Limpiamos
DELETE FROM Area_Infraestructura.Parque WHERE Nombre = 'Parque GP2';
DELETE FROM Area_Infraestructura.Provincia WHERE Nombre = 'Provincia GP2';
DELETE FROM Area_Infraestructura.Region WHERE Nombre = 'Region GP2';
DELETE FROM Area_Infraestructura.Tipo_Parque WHERE Descripcion = 'Tipo GP2';
GO
