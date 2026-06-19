/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Descripción: Test de SP_CrearRegion
*/
USE SGParquesNacionales
GO

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
