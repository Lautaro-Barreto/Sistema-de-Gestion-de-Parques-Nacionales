/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del script de pruebas (Test) para la asignación de un Guía a una Actividad.
*/

USE SGParquesNacionales
GO

BEGIN TRAN; -- 1. Iniciamos la transacción de prueba

-- A. PREPARAR (Arrange)
    PRINT('======================================================')
    PRINT('--- PREPARANDO DATOS DE PRUEBA COMPLEJOS ---')
    PRINT('======================================================')
    
    -- 1. Insertamos datos base (Parque, Especialidad, Tipo_Actividad)
    SET IDENTITY_INSERT Area_Infraestructura.Parque ON;
    INSERT INTO Area_Infraestructura.Parque(IdParque, Nombre, Superficie) VALUES (999, 'Parque Nacional Test', 50000);
    SET IDENTITY_INSERT Area_Infraestructura.Parque OFF;

    SET IDENTITY_INSERT Area_Excursiones.Especialidad ON;
    INSERT INTO Area_Excursiones.Especialidad(IdEspecialidad, Descripcion) VALUES (999, 'Especialidad Test');
    SET IDENTITY_INSERT Area_Excursiones.Especialidad OFF;

    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad ON;
    INSERT INTO Area_Excursiones.Tipo_Actividad(IdTipoActividad, Descripcion) VALUES (999, 'Aventura Test');
    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad OFF;

    -- 2. Insertamos Guías de prueba
    -- Guía 999: Tendrá habilitación VIGENTE
    -- Guía 998: Tendrá habilitación VENCIDA
    -- Guía 997: NO tendrá ninguna habilitación cargada
    SET IDENTITY_INSERT Area_Excursiones.Guia ON;
    INSERT INTO Area_Excursiones.Guia (IdGuia, DNI, IdParque, IdEspecialidad, Nombre, Apellido, Titulo)
    VALUES 
    (999, '11111111', 999, 999, 'Guia', 'Apto', 'Titulo'),
    (998, '22222222', 999, 999, 'Guia', 'Vencido', 'Titulo'),
    (997, '33333333', 999, 999, 'Guia', 'SinHabilitacion', 'Titulo');
    SET IDENTITY_INSERT Area_Excursiones.Guia OFF;

    -- 3. Insertamos Actividades de prueba (Una ACTIVA y otra INACTIVA)
    SET IDENTITY_INSERT Area_Excursiones.Actividad ON;
    INSERT INTO Area_Excursiones.Actividad (IdActividad, IdTipoActividad, IdParque, Nombre, Costo, Duracion, Cupo_maximo, Activo)
    VALUES 
    (999, 999, 999, 'Actividad ACTIVA', 1500.00, 2, 10, 1),  -- Activo = 1
    (998, 999, 999, 'Actividad INACTIVA', 1500.00, 2, 10, 0); -- Activo = 0
    SET IDENTITY_INSERT Area_Excursiones.Actividad OFF;

    -- 4. Insertamos Habilitación de prueba
    SET IDENTITY_INSERT Area_Excursiones.Habilitacion ON;
    INSERT INTO Area_Excursiones.Habilitacion (IdHabilitaciones, Descripcion) VALUES (999, 'Escalada Alta Montaña');
    SET IDENTITY_INSERT Area_Excursiones.Habilitacion OFF;

    -- 5. Exigimos esa habilitación a nuestras dos actividades
    INSERT INTO Area_Excursiones.Habilitaciones_por_Actividad (IdActividad, IdHabilitacion)
    VALUES 
    (999, 999), -- A la actividad activa se le exige la habilitación 999
    (998, 999); -- A la actividad inactiva también se le exige la habilitación 999

    -- 6. Otorgamos las habilitaciones a los guías
    -- Al guía 999 se la damos con fecha al futuro (Válida)
    -- Al guía 998 se la damos con fecha al pasado (Vencida)
    INSERT INTO Area_Excursiones.Habilitacion_Guia (IdGuia, IdHabilitacion, Fecha_Fin_Validez)
    VALUES 
    (999, 999, DATEADD(day, 30, GETDATE())),  -- Vence en 30 días
    (998, 999, DATEADD(day, -10, GETDATE())); -- Venció hace 10 días

    SELECT * FROM Area_Excursiones.Guia
    SELECT * FROM Area_Excursiones.actividad
    SELECT * FROM Area_Excursiones.Habilitacion
    SELECT * FROM Area_Excursiones.Habilitacion_Guia
-------------------------------- TEST 1 ------------------------------------------------------------------------
    PRINT ''
    PRINT('--- TEST 1: Asignar un Guía válido y Habilitado a una Actividad Activa (Happy Path) ---')

    BEGIN TRY 
        EXEC Area_Excursiones.Sp_CrearGuiasPorActividad
                @IdGuia = 999,      -- Guía con habilitación vigente
                @IdActividad = 999; -- Actividad activa
                
        PRINT 'RESULTADO TEST 1: PASÓ (SP Ejecutado sin errores y se creó la asignación)'
    END TRY
    BEGIN CATCH 
        PRINT 'RESULTADO TEST 1: FALLÓ - Error inesperado: '+ ERROR_MESSAGE()
    END CATCH

    -- Verificar inserción
    SELECT * FROM Area_Excursiones.Guias_por_actividad WHERE IdGuia = 999 AND IdActividad = 999;


-------------------------------- TEST 2 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 2: Intentar asignar a una Actividad INACTIVA ---'

    BEGIN TRY
            EXEC Area_Excursiones.Sp_CrearGuiasPorActividad 
                @IdGuia = 999,       -- Guía apto
                @IdActividad = 998;  -- Actividad INACTIVA (Activo = 0)
                
            PRINT 'RESULTADO TEST 2: FALLÓ (El SP permitió asignar un guía a una actividad inactiva)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 2: PASÓ (El SP bloqueó la asignación porque la actividad no está activa)';
    END CATCH


-------------------------------- TEST 3 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 3: Intentar asignar un Guía SIN la habilitación requerida ---'

    BEGIN TRY
            EXEC Area_Excursiones.Sp_CrearGuiasPorActividad 
                @IdGuia = 997,      -- Guía que no tiene registros en Habilitacion_Guia
                @IdActividad = 999; -- Actividad activa
                
            PRINT 'RESULTADO TEST 3: FALLÓ (El SP permitió asignar un guía sin la habilitación necesaria)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 3: PASÓ (El SP bloqueó correctamente al guía sin habilitaciones)';
    END CATCH


-------------------------------- TEST 4 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 4: Intentar asignar un Guía con la habilitación VENCIDA ---'
    BEGIN TRY
        EXEC Area_Excursiones.Sp_CrearGuiasPorActividad 
            @IdGuia = 998,      -- Guía cuya fecha fin de validez fue hace 10 días
            @IdActividad = 999; -- Actividad activa
            
        PRINT 'RESULTADO TEST 4: FALLÓ (El SP permitió asignar un guía con la habilitación vencida)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 4: PASÓ (El SP detectó la fecha vencida y bloqueó la asignación)';
    END CATCH

-------------------------------- TEST 5 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 5: Intentar asignar un Guía INEXISTENTE ---'
    BEGIN TRY
        EXEC Area_Excursiones.Sp_CrearGuiasPorActividad 
            @IdGuia = -1, -- ESTE GUIA NO EXISTE
            @IdActividad = 999; 
            
        PRINT 'RESULTADO TEST 5: FALLÓ (El SP permitió asignar un guía fantasma)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 5: PASÓ (El SP bloqueó correctamente)';
    END CATCH

-------------------------------- TEST 6 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 6: Intentar asignar a una Actividad INEXISTENTE ---'
    BEGIN TRY
        EXEC Area_Excursiones.Sp_CrearGuiasPorActividad 
            @IdGuia = 999, 
            @IdActividad = -1; -- ESTA ACTIVIDAD NO EXISTE
            
        PRINT 'RESULTADO TEST 6: FALLÓ (El SP permitió asignar a una actividad fantasma)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 6: PASÓ (El SP bloqueó correctamente)';
    END CATCH

-------------------------------- FIN DE PRUEBAS ----------------------------------------------------------------
    SELECT * FROM Area_Excursiones.Guias_por_Actividad
ROLLBACK TRAN; -- 4. Deshacemos TODO para no dejar basura en la BD.
PRINT '';
PRINT 'Pruebas finalizadas. Base de datos restaurada (ROLLBACK ejecutado).';
GO