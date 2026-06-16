/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Descripción: Test de SP_CrearParque
*/
USE SGParquesNacionales
GO

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