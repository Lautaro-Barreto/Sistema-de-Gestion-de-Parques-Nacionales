/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 19/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripcion: Este script se encarga de testear los Stored Procedures de creacion, eliminacion y
modificacion de las tablas del esquema Area_Infraestructura.
*/

USE SGParquesNacionales
GO

-- ===========================================================================================
--                                 Pruebas de creacion
-- ===========================================================================================

-- 1. PARQUE
-- 1. Prueba de creacion exitosa de un parque
-- Preparamos las dependencias
INSERT INTO Area_Infraestructura.Region (Nombre) VALUES ('Region P');
DECLARE @IdReg INT = SCOPE_IDENTITY();
INSERT INTO Area_Infraestructura.Provincia (Nombre, IdRegion) VALUES ('Provincia P', @IdReg);
INSERT INTO Area_Infraestructura.Tipo_Parque (Descripcion) VALUES ('Tipo P');
-- Ejecutamos
EXEC Area_Infraestructura.SP_CrearParque 
    @Nombre = 'Parque P', 
    @TipoParqueDesc = 'Tipo P', 
    @Provincia = 'Provincia P', 
    @Superficie = 1000.5;
-- Limpiamos la prueba
DELETE FROM Area_Infraestructura.Parque WHERE Nombre = 'Parque P';
DELETE FROM Area_Infraestructura.Provincia WHERE Nombre = 'Provincia P';
DELETE FROM Area_Infraestructura.Region WHERE Nombre = 'Region P';
DELETE FROM Area_Infraestructura.Tipo_Parque WHERE Descripcion = 'Tipo P';
GO

-- 2. Prueba de fallo por nombre de parque vacio
EXEC Area_Infraestructura.SP_CrearParque @Nombre = '', @TipoParqueDesc = 'Tipo P', @Provincia = 'Provincia P', @Superficie = 1000.5;
GO

-- 3. Prueba de fallo por provincia inexistente
EXEC Area_Infraestructura.SP_CrearParque @Nombre = 'Parque F', @TipoParqueDesc = 'Tipo P', @Provincia = 'Provincia Inexistente', @Superficie = 1000.5;
GO

-- 4. Prueba de fallo por tipo de parque inexistente
-- Preparamos dependencias
INSERT INTO Area_Infraestructura.Region (Nombre) VALUES ('Region F');
DECLARE @IdReg INT = SCOPE_IDENTITY();
INSERT INTO Area_Infraestructura.Provincia (Nombre, IdRegion) VALUES ('Provincia F', @IdReg);
-- Ejecutamos
EXEC Area_Infraestructura.SP_CrearParque @Nombre = 'Parque F2', @TipoParqueDesc = 'Tipo Inexistente', @Provincia = 'Provincia F', @Superficie = 1000.5;
-- Limpiamos
DELETE FROM Area_Infraestructura.Provincia WHERE Nombre = 'Provincia F';
DELETE FROM Area_Infraestructura.Region WHERE Nombre = 'Region F';
GO

-- 5. Prueba de fallo por superficie invalida
EXEC Area_Infraestructura.SP_CrearParque @Nombre = 'Parque F3', @TipoParqueDesc = 'Tipo P', @Provincia = 'Provincia P', @Superficie = 0;
GO


-- 2. REGION
-- 1. Prueba de creacion exitosa de una region
EXEC Area_Infraestructura.SP_CrearRegion @Nombre = 'Region Prueba 1';
-- Limpiamos la prueba
DELETE FROM Area_Infraestructura.Region WHERE Nombre = 'Region Prueba 1';
GO

-- 2. Prueba de fallo por nombre vacio
EXEC Area_Infraestructura.SP_CrearRegion @Nombre = '';
GO

-- 3. Prueba de fallo por nombre con caracteres invalidos
EXEC Area_Infraestructura.SP_CrearRegion @Nombre = 'Region_2@';
GO

-- 4. Prueba de fallo por region repetida
-- Preparamos el entorno
INSERT INTO Area_Infraestructura.Region (Nombre) VALUES ('Region Repetida');
-- Ejecutamos la prueba (debe fallar y retornar el id)
EXEC Area_Infraestructura.SP_CrearRegion @Nombre = 'Region Repetida';
-- Limpiamos la prueba
DELETE FROM Area_Infraestructura.Region WHERE Nombre = 'Region Repetida';
GO


-- 3. PROVINCIA
-- 1. Prueba de creacion exitosa de una provincia
-- Preparamos la region
INSERT INTO Area_Infraestructura.Region (Nombre) VALUES ('Region P');
EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Provincia P', @NombreRegion = 'Region P';
-- Limpiamos la prueba
DELETE FROM Area_Infraestructura.Provincia WHERE Nombre = 'Provincia P';
DELETE FROM Area_Infraestructura.Region WHERE Nombre = 'Region P';
GO

-- 2. Prueba de fallo por nombre de provincia vacio
EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = '', @NombreRegion = 'Region P';
GO

-- 3. Prueba de fallo por provincia repetida
-- Preparamos el entorno
INSERT INTO Area_Infraestructura.Region (Nombre) VALUES ('Region R');
INSERT INTO Area_Infraestructura.Provincia (Nombre, IDRegion) VALUES ('Provincia Repetida', (SELECT IdRegion FROM Area_Infraestructura.Region WHERE Nombre = 'Region R'));
-- Ejecutamos la prueba (debe fallar y retornar el id)
EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Provincia Repetida', @NombreRegion = 'Region R';
-- Limpiamos la prueba
DELETE FROM Area_Infraestructura.Provincia WHERE Nombre = 'Provincia Repetida';
DELETE FROM Area_Infraestructura.Region WHERE Nombre = 'Region R';
GO

-- 4. Prueba de fallo por region inexistente
EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Provincia F', @NombreRegion = 'Region Inexistente';
GO


-- 4. TIPO_DE_PARQUE
-- 1. Prueba de creacion exitosa de un tipo de parque
EXEC Area_Infraestructura.SP_CrearTipoParque @Descripcion = 'Tipo Prueba 1';
-- Limpiamos la prueba
DELETE FROM Area_Infraestructura.Tipo_Parque WHERE Descripcion = 'Tipo Prueba 1';
GO

-- 2. Prueba de fallo por descripcion vacia
EXEC Area_Infraestructura.SP_CrearTipoParque @Descripcion = '';
GO

-- 3. Prueba de fallo por descripcion con caracteres invalidos
EXEC Area_Infraestructura.SP_CrearTipoParque @Descripcion = 'Tipo_Prueba_123';
GO

-- 4. Prueba de fallo por descripcion repetida
-- Preparamos el entorno
INSERT INTO Area_Infraestructura.Tipo_Parque (Descripcion) VALUES ('Tipo Repetido');
-- Ejecutamos la prueba (debe fallar y retornar el id)
EXEC Area_Infraestructura.SP_CrearTipoParque @Descripcion = 'Tipo Repetido';
-- Limpiamos la prueba
DELETE FROM Area_Infraestructura.Tipo_Parque WHERE Descripcion = 'Tipo Repetido';
GO


-- 5. GUARDAPARQUE
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


-- ===========================================================================================
--                               Pruebas de modificacion
-- ===========================================================================================

-- 1. PARQUE
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


-- 2. REGION
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


-- 3. TIPO_DE_PARQUE
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


-- 4. GUARDAPARQUE
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


-- ===========================================================================================
--                                Pruebas de eliminacion
-- ===========================================================================================

-- 1. PARQUE
-- 1. Prueba de eliminacion (borrado logico) exitosa de un parque
-- Preparamos entorno
INSERT INTO Area_Infraestructura.Region (Nombre) VALUES ('Region PE');
DECLARE @IdReg INT = SCOPE_IDENTITY();
INSERT INTO Area_Infraestructura.Provincia (Nombre, IdRegion) VALUES ('Provincia PE', @IdReg);
DECLARE @IdProv INT = SCOPE_IDENTITY();
INSERT INTO Area_Infraestructura.Tipo_Parque (Descripcion) VALUES ('Tipo PE');
DECLARE @IdTipo INT = SCOPE_IDENTITY();
INSERT INTO Area_Infraestructura.Parque (Nombre, Superficie, IdProvincia, IdTipoParque, Activo) VALUES ('Parque a Eliminar', 100, @IdProv, @IdTipo, 1);
DECLARE @Id INT = SCOPE_IDENTITY();
-- Ejecutamos
EXEC Area_Infraestructura.Sp_EliminarParque @IdParque = @Id;
-- Limpiamos
DELETE FROM Area_Infraestructura.Parque WHERE IdParque = @Id;
DELETE FROM Area_Infraestructura.Provincia WHERE IdProvincia = @IdProv;
DELETE FROM Area_Infraestructura.Region WHERE IdRegion = @IdReg;
DELETE FROM Area_Infraestructura.Tipo_Parque WHERE IdTipoParque = @IdTipo;
GO

-- 2. Prueba de fallo por Id inexistente
EXEC Area_Infraestructura.Sp_EliminarParque @IdParque = -1;
GO


-- 2. REGION
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


-- 3. PROVINCIA
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


-- 4. TIPO_DE_PARQUE
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


-- 5. GUARDAPARQUE
-- 1. Prueba de eliminacion exitosa de un guardaparque
-- Preparamos entorno
INSERT INTO Area_Infraestructura.Region (Nombre) VALUES ('Region GPE');
DECLARE @IdReg INT = SCOPE_IDENTITY();
INSERT INTO Area_Infraestructura.Provincia (Nombre, IdRegion) VALUES ('Provincia GPE', @IdReg);
DECLARE @IdProv INT = SCOPE_IDENTITY();
INSERT INTO Area_Infraestructura.Tipo_Parque (Descripcion) VALUES ('Tipo GPE');
DECLARE @IdTipo INT = SCOPE_IDENTITY();
INSERT INTO Area_Infraestructura.Parque (Nombre, Superficie, IdProvincia, IdTipoParque, Activo) VALUES ('Parque GPE', 100, @IdProv, @IdTipo, 1);
DECLARE @IdParque INT = SCOPE_IDENTITY();
INSERT INTO Area_Infraestructura.Guardaparque (Nombre, Apellido, Dni, IdParque, Fecha_Ingreso, Fecha_Egreso, Activo) VALUES ('Juan', 'Perez', '11112222', @IdParque, '2023-01-01', '2023-12-31', 1);
DECLARE @Id INT = SCOPE_IDENTITY();
-- Ejecutamos
EXEC Area_Infraestructura.Sp_EliminarGuardaparque @IdGuardaparque = @Id;
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
EXEC Area_Infraestructura.Sp_EliminarGuardaparque @IdGuardaparque = -1;
GO
