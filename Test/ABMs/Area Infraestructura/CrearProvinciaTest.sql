/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Descripción: Test de SP_CrearProvincia
*/
USE SGParquesNacionales
GO

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
