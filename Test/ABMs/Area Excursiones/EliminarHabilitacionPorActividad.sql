/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 23/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de testear la desvinculación entre una Actividad y una 
#             Habilitación, utilizando transacciones aisladas por cada test.
*/

USE SGParquesNacionales
GO

PRINT('========================================================================================')
PRINT('--- INICIANDO BATERÍA DE PRUEBAS: Sp_EliminarHabilitacionesPorActividad ---')
PRINT('========================================================================================')

-------------------------------------------------------------------------
-- TEST 1: Eliminar la vinculación exitosamente
-------------------------------------------------------------------------
PRINT ''
PRINT '--- TEST 1: Eliminar vinculación entre Actividad y Habilitación ---'
BEGIN TRAN; 

    -- 1. ARRANGE (Preparar dependencias completas)
    
    -- Dependencias de Actividad
    SET IDENTITY_INSERT Area_Infraestructura.Parque ON;
    INSERT INTO Area_Infraestructura.Parque(IdParque, Nombre, Superficie) VALUES (999, 'Parque Test', 50000);
    SET IDENTITY_INSERT Area_Infraestructura.Parque OFF;

    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad ON;
    INSERT INTO Area_Excursiones.Tipo_Actividad(IdTipoActividad, Descripcion) VALUES (999, 'Aventura Test');
    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad OFF;

    -- Insertamos la Actividad (Id=999) y la Habilitación (Id=999)
    SET IDENTITY_INSERT Area_Excursiones.Actividad ON;
    INSERT INTO Area_Excursiones.Actividad(IdActividad, IdTipoActividad, IdParque, Nombre, Costo, Duracion, Cupo_maximo, Activo) 
    VALUES (999, 999, 999, 'Actividad Test Hab', 1500, 2, 10, 1);
    SET IDENTITY_INSERT Area_Excursiones.Actividad OFF;

    SET IDENTITY_INSERT Area_Excursiones.Habilitacion ON;
    INSERT INTO Area_Excursiones.Habilitacion (IdHabilitaciones, Descripcion) 
    VALUES (999, 'Habilitacion Test Vinculacion');
    SET IDENTITY_INSERT Area_Excursiones.Habilitacion OFF;

    -- VINCULAMOS LA ACTIVIDAD CON LA HABILITACIÓN
    INSERT INTO Area_Excursiones.Habilitaciones_por_Actividad (IdActividad, IdHabilitacion) VALUES (999, 999);

    PRINT '>>> ANTES DE ELIMINAR: Verificando la vinculación (Debería devolver 1 fila) <<<'
    SELECT IdActividad, IdHabilitacion FROM Area_Excursiones.Habilitaciones_por_Actividad WHERE IdActividad = 999 AND IdHabilitacion = 999;

    -- 2. ACT & ASSERT
    BEGIN TRY
        EXEC Area_Excursiones.Sp_EliminarHabilitacionesPorActividad @IdActividad = 999, @IdHabilitacion = 999;

        PRINT 'RESULTADO TEST 1: PASÓ (SP Ejecutado sin errores)'
        
        PRINT '>>> DESPUÉS DE ELIMINAR: Verificando que la vinculación ya no existe (Grilla vacía) <<<'
        SELECT IdActividad, IdHabilitacion FROM Area_Excursiones.Habilitaciones_por_Actividad WHERE IdActividad = 999 AND IdHabilitacion = 999;

        -- Verificamos que se haya borrado
        IF NOT EXISTS(SELECT 1 FROM Area_Excursiones.Habilitaciones_por_Actividad WHERE IdActividad = 999 AND IdHabilitacion = 999) 
        BEGIN
            PRINT '-> ÉXITO: El registro fue eliminado correctamente de Habilitaciones_por_Actividad.'
        END
        ELSE
        BEGIN
            PRINT '-> FALLA: El SP se ejecutó pero la vinculación sigue existiendo.'
        END
    END TRY
    BEGIN CATCH
        PRINT 'RESULTADO TEST 1: FALLÓ - Error inesperado: '+ ERROR_MESSAGE()
    END CATCH

-- 3. TEARDOWN
IF @@TRANCOUNT > 0 ROLLBACK TRAN; 


-------------------------------------------------------------------------
-- TEST 2: Intentar Eliminar con una Actividad Inexistente (o Inactiva)
-------------------------------------------------------------------------
PRINT ''
PRINT '--- TEST 2: Intentar Eliminar con una Actividad Inactiva (Activo = 0) ---'
BEGIN TRAN;

    -- 1. ARRANGE
    SET IDENTITY_INSERT Area_Infraestructura.Parque ON;
    INSERT INTO Area_Infraestructura.Parque(IdParque, Nombre, Superficie) VALUES (999, 'Parque Test', 50000);
    SET IDENTITY_INSERT Area_Infraestructura.Parque OFF;

    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad ON;
    INSERT INTO Area_Excursiones.Tipo_Actividad(IdTipoActividad, Descripcion) VALUES (999, 'Aventura Test');
    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad OFF;

    -- Insertamos Actividad INACTIVA (Activo = 0)
    SET IDENTITY_INSERT Area_Excursiones.Actividad ON;
    INSERT INTO Area_Excursiones.Actividad(IdActividad, IdTipoActividad, IdParque, Nombre, Costo, Duracion, Cupo_maximo, Activo) 
    VALUES (998, 999, 999, 'Actividad Inactiva Test', 1500, 2, 10, 0);
    SET IDENTITY_INSERT Area_Excursiones.Actividad OFF;

    -- 2. ACT & ASSERT
    BEGIN TRY
        -- Usamos el ID de la actividad inactiva (998)
        EXEC Area_Excursiones.Sp_EliminarHabilitacionesPorActividad @IdActividad = 998, @IdHabilitacion = 999;
        
        PRINT 'RESULTADO TEST 2: FALLÓ (El SP permitió borrar saltándose la validación de Activo = 1)'
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 2: PASÓ (El SP bloqueó correctamente la actividad inactiva/inexistente)';
    END CATCH

-- 3. TEARDOWN
IF @@TRANCOUNT > 0 ROLLBACK TRAN; 


-------------------------------------------------------------------------
-- TEST 3: Intentar Eliminar con una Habilitación Inexistente
-------------------------------------------------------------------------
PRINT ''
PRINT '--- TEST 3: Intentar Eliminar con una Habilitación Inexistente ---'
BEGIN TRAN;

    -- 1. ARRANGE
    SET IDENTITY_INSERT Area_Infraestructura.Parque ON;
    INSERT INTO Area_Infraestructura.Parque(IdParque, Nombre, Superficie) VALUES (999, 'Parque Test', 50000);
    SET IDENTITY_INSERT Area_Infraestructura.Parque OFF;

    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad ON;
    INSERT INTO Area_Excursiones.Tipo_Actividad(IdTipoActividad, Descripcion) VALUES (999, 'Aventura Test');
    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad OFF;

    -- Insertamos Actividad válida
    SET IDENTITY_INSERT Area_Excursiones.Actividad ON;
    INSERT INTO Area_Excursiones.Actividad(IdActividad, IdTipoActividad, IdParque, Nombre, Costo, Duracion, Cupo_maximo, Activo) 
    VALUES (999, 999, 999, 'Actividad Test', 1500, 2, 10, 1);
    SET IDENTITY_INSERT Area_Excursiones.Actividad OFF;

    -- 2. ACT & ASSERT
    BEGIN TRY
        -- Usamos un IdHabilitacion que sabemos que no existe (888)
        EXEC Area_Excursiones.Sp_EliminarHabilitacionesPorActividad @IdActividad = 999, @IdHabilitacion = 888;
        
        PRINT 'RESULTADO TEST 3: FALLÓ (El SP no validó la existencia de la habilitación)'
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 3: PASÓ (El SP bloqueó correctamente la falta de habilitación)';
    END CATCH

-- 3. TEARDOWN
IF @@TRANCOUNT > 0 ROLLBACK TRAN; 


-------------------------------------------------------------------------
-- TEST 4: Intentar Eliminar una vinculación inexistente
-------------------------------------------------------------------------
PRINT ''
PRINT '--- TEST 4: Intentar Eliminar una vinculación inexistente (Existen pero no están unidas) ---'
BEGIN TRAN;

    -- 1. ARRANGE
    SET IDENTITY_INSERT Area_Infraestructura.Parque ON;
    INSERT INTO Area_Infraestructura.Parque(IdParque, Nombre, Superficie) VALUES (999, 'Parque Test', 50000);
    SET IDENTITY_INSERT Area_Infraestructura.Parque OFF;

    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad ON;
    INSERT INTO Area_Excursiones.Tipo_Actividad(IdTipoActividad, Descripcion) VALUES (999, 'Aventura Test');
    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad OFF;

    SET IDENTITY_INSERT Area_Excursiones.Actividad ON;
    INSERT INTO Area_Excursiones.Actividad(IdActividad, IdTipoActividad, IdParque, Nombre, Costo, Duracion, Cupo_maximo, Activo) 
    VALUES (999, 999, 999, 'Actividad Test', 1500, 2, 10, 1);
    SET IDENTITY_INSERT Area_Excursiones.Actividad OFF;

    SET IDENTITY_INSERT Area_Excursiones.Habilitacion ON;
    INSERT INTO Area_Excursiones.Habilitacion (IdHabilitaciones, Descripcion) 
    VALUES (999, 'Habilitacion Test');
    SET IDENTITY_INSERT Area_Excursiones.Habilitacion OFF;

    -- A PROPÓSITO: NO HACEMOS EL INSERT EN Habilitaciones_por_Actividad

    -- 2. ACT & ASSERT
    BEGIN TRY
        EXEC Area_Excursiones.Sp_EliminarHabilitacionesPorActividad @IdActividad = 999, @IdHabilitacion = 999;
        
        PRINT 'RESULTADO TEST 4: FALLÓ (El SP intentó eliminar una relación que no existía)'
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 4: PASÓ (El SP detectó que no estaban vinculadas)';
    END CATCH

-- 3. TEARDOWN
IF @@TRANCOUNT > 0 ROLLBACK TRAN; 

PRINT ''
PRINT('======================================================')
PRINT('--- FIN DE LA BATERÍA DE PRUEBAS ---')
PRINT('======================================================')
GO