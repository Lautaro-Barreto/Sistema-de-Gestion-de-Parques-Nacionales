/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 22/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de testear la creación de habilitaciones por actividad mediante su SP.
*/

USE SGParquesNacionales
GO

BEGIN TRAN; -- 1. Iniciamos la transacción de prueba

    PRINT('--- PREPARACIÓN DE DATOS (Arrange) ---')
    
    -- Insertamos una Habilitación de prueba
    SET IDENTITY_INSERT Area_Excursiones.Habilitacion ON;
    INSERT INTO Area_Excursiones.Habilitacion(IdHabilitaciones, Descripcion) 
    VALUES (999, 'Habilitación de Alta Montaña Test');
    SET IDENTITY_INSERT Area_Excursiones.Habilitacion OFF;

    -- Preparamos dependencias para crear Actividades (Tipo y Parque)
    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad ON;
    INSERT INTO Area_Excursiones.Tipo_Actividad(IdTipoActividad, Descripcion) 
    VALUES (999, 'Aventura Test');
    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad OFF;

    SET IDENTITY_INSERT Area_Infraestructura.Parque ON;
    INSERT INTO Area_Infraestructura.Parque(IdParque, Nombre, Superficie) 
    VALUES (999, 'Parque Nacional Test', 50000);
    SET IDENTITY_INSERT Area_Infraestructura.Parque OFF;

    -- Insertamos dos Actividades: Una Activa (999) y una Inactiva (998)
    SET IDENTITY_INSERT Area_Excursiones.Actividad ON;
    INSERT INTO Area_Excursiones.Actividad(IdActividad, IdTipoActividad, IdParque, Nombre, Costo, Duracion, Cupo_Maximo, Activo) 
    VALUES (999, 999, 999, 'Trekking Activo Test', 15000, 4, 20, 1);
    
    INSERT INTO Area_Excursiones.Actividad(IdActividad, IdTipoActividad, IdParque, Nombre, Costo, Duracion, Cupo_Maximo, Activo) 
    VALUES (998, 999, 999, 'Trekking Inactivo Test', 15000, 4, 20, 0);
    SET IDENTITY_INSERT Area_Excursiones.Actividad OFF;


--                          TEST 1
    PRINT ''
    PRINT 'TEST 1: Crear una asignación válida'
    BEGIN TRY 
        EXEC Area_Excursiones.Sp_CrearHabilitacionesPorActividad
            @IdActividad = 999,
            @IdHabilitaciones = 999;
            
        PRINT 'Sp Ejecutado sin errores. RESULTADO TEST 1: PASÓ'
    END TRY
    BEGIN CATCH 
        PRINT 'Error inesperado: '+ ERROR_MESSAGE()
        PRINT 'RESULTADO TEST 1: FALLÓ'
    END CATCH

    -- Validación visual
    SELECT * FROM Area_Excursiones.Habilitaciones_por_Actividad 
    WHERE IdActividad = 999 AND IdHabilitacion = 999


--                          TEST 2
    PRINT ''
    PRINT 'TEST 2: Intentar asignar con un IdHabilitaciones Inexistente'
    BEGIN TRY
        EXEC Area_Excursiones.Sp_CrearHabilitacionesPorActividad 
            @IdActividad = 999, 
            @IdHabilitaciones = -1; -- ESTO DEBERÍA HACER FALLAR AL SP
            
        PRINT 'RESULTADO TEST 2: FALLÓ (El SP permitió la inserción)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 2: PASÓ (El SP bloqueó correctamente)';
    END CATCH


--                          TEST 3
    PRINT ''
    PRINT 'TEST 3: Intentar asignar con un IdActividad Inexistente'
    BEGIN TRY
        EXEC Area_Excursiones.Sp_CrearHabilitacionesPorActividad 
            @IdActividad = -1, -- ESTO DEBERÍA HACER FALLAR AL SP
            @IdHabilitaciones = 999; 
            
        PRINT 'RESULTADO TEST 3: FALLÓ (El SP permitió la inserción)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 3: PASÓ (El SP bloqueó correctamente)';
    END CATCH


--                          TEST 4
    PRINT ''
    PRINT 'TEST 4: Intentar asignar una Actividad que está Inactiva (Activo = 0)'
    BEGIN TRY
        EXEC Area_Excursiones.Sp_CrearHabilitacionesPorActividad 
            @IdActividad = 998, -- ES LA ACTIVIDAD INACTIVA
            @IdHabilitaciones = 999; 
            
        PRINT 'RESULTADO TEST 4: FALLÓ (El SP no validó el Activo = 1)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 4: PASÓ (El SP detectó que no estaba activa)';
    END CATCH


--                          TEST 5
    PRINT ''
    PRINT 'TEST 5: Intentar duplicar la misma asignación'
    BEGIN TRY
        -- Como ya se insertó en el TEST 1, volver a correrlo debería violar la PK compuesta
        EXEC Area_Excursiones.Sp_CrearHabilitacionesPorActividad 
            @IdActividad = 999, 
            @IdHabilitaciones = 999; 
            
        PRINT 'RESULTADO TEST 5: FALLÓ (Permitió duplicados, revisar PK en la tabla Habilitaciones_por_Actividad)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 5: PASÓ (El motor frenó el duplicado correctamente)';
    END CATCH


ROLLBACK TRAN; -- Deshacemos TODO para no dejar basura en la BD.
PRINT '';
PRINT 'Prueba finalizada. Base de datos restaurada.';
GO