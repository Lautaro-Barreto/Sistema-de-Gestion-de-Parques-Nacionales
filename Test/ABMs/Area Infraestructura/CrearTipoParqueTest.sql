/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Descripción: Test de SP_CrearTipoParque
*/
USE SGParquesNacionales
GO

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
