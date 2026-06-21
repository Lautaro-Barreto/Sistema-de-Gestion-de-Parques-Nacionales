/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del script de pruebas (Test) para la modificación de una Actividad.
*/

USE SGParquesNacionales
GO

BEGIN TRAN; -- 1. Iniciamos la transacción de prueba

-- A. PREPARAR (Arrange)
    PRINT('======================================================')
    PRINT('--- PREPARANDO DATOS DE PRUEBA ---')
    PRINT('======================================================')
    
    -- Insertamos Parque de prueba
    SET IDENTITY_INSERT Area_Infraestructura.Parque ON;
    INSERT INTO Area_Infraestructura.Parque(IdParque, Nombre, Superficie) VALUES (999, 'Parque Nacional Test', 50000);
    SET IDENTITY_INSERT Area_Infraestructura.Parque OFF;

    -- Insertamos Tipo de Actividad de prueba
    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad ON;
    INSERT INTO Area_Excursiones.Tipo_Actividad(IdTipoActividad, Descripcion) VALUES (999, 'Aventura Test');
    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad OFF;

    -- Insertamos Actividad original de prueba (Aseguramos que Activo = 1 para que el SP la encuentre)
    SET IDENTITY_INSERT Area_Excursiones.Actividad ON;
    INSERT INTO Area_Excursiones.Actividad (IdActividad, IdTipoActividad, IdParque, Nombre, Costo, Duracion, Cupo_maximo, Activo)
    VALUES (999, 999, 999, 'Actividad Original', 1500.00, 2, 10, 1);
    INSERT INTO Area_Excursiones.Actividad (IdActividad, IdTipoActividad, IdParque, Nombre, Costo, Duracion, Cupo_maximo, Activo)
    VALUES (998, 999, 999, 'Actividad Original', 1500.00, 2, 10, 0);
    SET IDENTITY_INSERT Area_Excursiones.Actividad OFF;

    SELECT * FROM Area_Excursiones.actividad
-------------------------------- TEST 1 ------------------------------------------------------------------------
    PRINT ''
    PRINT('--- TEST 1: Modificar una Actividad válida (Happy Path) ---')

    BEGIN TRY 
        EXEC Area_Excursiones.Sp_ModificarActividad
                @IdActividad = 999,
                @IdTipoActividad = 999,
                @IdParque = 999, 
                @Nombre = 'Actividad Modificada 123', 
                @Costo = 2500.50, 
                @Duracion = 4,
                @Cupo_maximo = 20;
                
        PRINT 'RESULTADO TEST 1: PASÓ (SP Ejecutado sin errores)'
    END TRY
    BEGIN CATCH 
        PRINT 'RESULTADO TEST 1: FALLÓ - Error inesperado: '+ ERROR_MESSAGE()
    END CATCH

    -- Mostrar cómo quedó tras el test 1
    SELECT * FROM Area_Excursiones.Actividad WHERE IdActividad = 999;


-------------------------------- TEST 2 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 2: Intentar modificar una Actividad Inexistente ---'

    BEGIN TRY
            EXEC Area_Excursiones.Sp_ModificarActividad 
                @IdActividad = -1, -- ESTA ACTIVIDAD NO EXISTE
                @IdTipoActividad = 999,
                @IdParque = 999, 
                @Nombre = 'Test Fallido', 
                @Costo = 2500, 
                @Duracion = 4,
                @Cupo_maximo = 20;
                
            PRINT 'RESULTADO TEST 2: FALLÓ (El SP permitió modificar una actividad inexistente)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 2: PASÓ (El SP bloqueó correctamente la modificación)';
    END CATCH


-------------------------------- TEST 3 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 3: Intentar modificar asignando un Tipo de Actividad Inexistente ---'

    BEGIN TRY
            EXEC Area_Excursiones.Sp_ModificarActividad 
                @IdActividad = 999,
                @IdTipoActividad = -1, -- ESTE TIPO DE ACTIVIDAD NO EXISTE
                @IdParque = 999, 
                @Nombre = 'Test Fallido', 
                @Costo = 2500, 
                @Duracion = 4,
                @Cupo_maximo = 20;
                
            PRINT 'RESULTADO TEST 3: FALLÓ (El SP permitió modificar con un tipo de actividad inválido)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 3: PASÓ (El SP bloqueó correctamente la modificación)';
    END CATCH


-------------------------------- TEST 4 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 4: Intentar modificar asignando un Parque Inexistente ---'
    BEGIN TRY
        EXEC Area_Excursiones.Sp_ModificarActividad 
            @IdActividad = 999,
            @IdTipoActividad = 999,
            @IdParque = -1, -- ESTE PARQUE NO EXISTE
            @Nombre = 'Test Fallido', 
            @Costo = 2500, 
            @Duracion = 4,
            @Cupo_maximo = 20;
            
        PRINT 'RESULTADO TEST 4: FALLÓ (El SP permitió modificar con un parque inválido)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 4: PASÓ (El SP bloqueó correctamente la modificación)';
    END CATCH

-------------------------------- TEST 5 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 5: Intentar modificar dejando el Nombre vacío ---'
    BEGIN TRY
        EXEC Area_Excursiones.Sp_ModificarActividad 
            @IdActividad = 999,
            @IdTipoActividad = 999,
            @IdParque = 999, 
            @Nombre = '', -- NOMBRE VACIO
            @Costo = 2500, 
            @Duracion = 4,
            @Cupo_maximo = 20;
            
        PRINT 'RESULTADO TEST 5: FALLÓ (El SP permitió modificar dejando el nombre vacío)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 5: PASÓ (El SP bloqueó correctamente la modificación)';
    END CATCH

-------------------------------- TEST 6 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 6: Intentar modificar dejando el Nombre en NULO ---'
    BEGIN TRY
        EXEC Area_Excursiones.Sp_ModificarActividad 
            @IdActividad = 999,
            @IdTipoActividad = 999,
            @IdParque = 999, 
            @Nombre = NULL, -- NOMBRE NULO
            @Costo = 2500, 
            @Duracion = 4,
            @Cupo_maximo = 20;
            
        PRINT 'RESULTADO TEST 6: FALLÓ (El SP permitió modificar dejando el nombre en nulo)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 6: PASÓ (El SP bloqueó correctamente la modificación)';
    END CATCH

-------------------------------- TEST 7 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 7: Intentar modificar asignando un Costo Negativo ---'
    BEGIN TRY
        EXEC Area_Excursiones.Sp_ModificarActividad 
            @IdActividad = 999,
            @IdTipoActividad = 999,
            @IdParque = 999, 
            @Nombre = 'Test Fallido', 
            @Costo = -100.50,  -- COSTO NEGATIVO
            @Duracion = 4,
            @Cupo_maximo = 20;
            
        PRINT 'RESULTADO TEST 7: FALLÓ (El SP permitió modificar con un costo negativo)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 7: PASÓ (El SP bloqueó correctamente la modificación)';
    END CATCH

-------------------------------- TEST 8 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 8: Intentar modificar asignando una Duración Cero o Negativa ---'
    BEGIN TRY
        EXEC Area_Excursiones.Sp_ModificarActividad 
            @IdActividad = 999,
            @IdTipoActividad = 999,
            @IdParque = 999, 
            @Nombre = 'Test Fallido', 
            @Costo = 2500, 
            @Duracion = 0, -- DURACION INVALIDA (Tirará error si es <= 0)
            @Cupo_maximo = 20;
            
        PRINT 'RESULTADO TEST 8: FALLÓ (El SP permitió modificar con una duración cero o negativa)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 8: PASÓ (El SP bloqueó correctamente la modificación)';
    END CATCH

-------------------------------- TEST 9 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 9: Intentar modificar asignando un Cupo Máximo Cero o Negativo ---'
    BEGIN TRY
        EXEC Area_Excursiones.Sp_ModificarActividad 
            @IdActividad = 999,
            @IdTipoActividad = 999,
            @IdParque = 999, 
            @Nombre = 'Test Fallido', 
            @Costo = 2500, 
            @Duracion = 4, 
            @Cupo_maximo = -5; -- CUPO MAXIMO INVALIDO (Tirará error si es <= 0)
            
        PRINT 'RESULTADO TEST 9: FALLÓ (El SP permitió modificar con un cupo máximo cero o negativo)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 9: PASÓ (El SP bloqueó correctamente la modificación)';
    END CATCH

-------------------------------- TEST 10 ------------------------------------------------------------------------
    PRINT ''
    PRINT('--- TEST 10: Modificar una Actividad Inactiva ---')

    BEGIN TRY 
        EXEC Area_Excursiones.Sp_ModificarActividad
                @IdActividad = 998,
                @IdTipoActividad = 999,
                @IdParque = 999, 
                @Nombre = 'Actividad ', 
                @Costo = 200.50, 
                @Duracion = 1,
                @Cupo_maximo = 22;
                
        PRINT 'RESULTADO TEST 10: FALLÓ (El SP permitió modificar con una actividad inactiva)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 10: PASÓ (El SP bloqueó correctamente la modificación)';
    END CATCH

-------------------------------- FIN DE PRUEBAS ----------------------------------------------------------------

ROLLBACK TRAN; -- 4. Deshacemos TODO para no dejar basura en la BD.
PRINT '';
PRINT 'Pruebas finalizadas. Base de datos restaurada (ROLLBACK ejecutado).';
GO