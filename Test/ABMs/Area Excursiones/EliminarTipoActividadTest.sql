/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 23/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de testear la eliminación de un Tipo de Actividad,
#             incluyendo la reasignación de las actividades a su tipo por defecto (Id = 1).
*/

USE SGParquesNacionales
GO

PRINT('========================================================================================')
PRINT('--- INICIANDO BATERÍA DE PRUEBAS: Sp_EliminarTipoActividad ---')
PRINT('========================================================================================')

-------------------------------------------------------------------------
-- TEST 1: Eliminar un Tipo de Actividad sin actividades asociadas
-------------------------------------------------------------------------
PRINT ''
PRINT '--- TEST 1: Eliminar un Tipo de Actividad sin actividades asociadas ---'
BEGIN TRAN; 

    -- 1. ARRANGE
    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad ON;
    INSERT INTO Area_Excursiones.Tipo_Actividad (IdTipoActividad, Descripcion) 
    VALUES (999, 'Tipo A Eliminar Test');
    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad OFF;

    PRINT '>>> ANTES DE ELIMINAR: Verificando Tipo de Actividad (Id = 999) <<<'
    SELECT IdTipoActividad, Descripcion FROM Area_Excursiones.Tipo_Actividad WHERE IdTipoActividad = 999;

    -- 2. ACT & ASSERT
    BEGIN TRY
        EXEC Area_Excursiones.Sp_EliminarTipoActividad @idTipoActividad = 999;

        PRINT 'RESULTADO TEST 1: PASÓ (SP Ejecutado sin errores)'
        
        PRINT '>>> DESPUÉS DE ELIMINAR: Verificando que ya no existe (Grilla vacía) <<<'
        SELECT IdTipoActividad, Descripcion FROM Area_Excursiones.Tipo_Actividad WHERE IdTipoActividad = 999;

        -- Verificamos que realmente se haya borrado
        IF NOT EXISTS(SELECT 1 FROM Area_Excursiones.Tipo_Actividad WHERE IdTipoActividad = 999) 
        BEGIN
            PRINT '-> ÉXITO: El Tipo de Actividad fue eliminado de la base de datos.'
        END
        ELSE
        BEGIN
            PRINT '-> FALLA: El SP se ejecutó pero el registro sigue existiendo.'
        END
    END TRY
    BEGIN CATCH
        PRINT 'RESULTADO TEST 1: FALLÓ - Error inesperado: '+ ERROR_MESSAGE()
    END CATCH

-- 3. TEARDOWN
IF @@TRANCOUNT > 0 ROLLBACK TRAN; 


-------------------------------------------------------------------------
-- TEST 2: Eliminar Tipo de Actividad y verificar reasignación (Id = 1)
-------------------------------------------------------------------------
PRINT ''
PRINT '--- TEST 2: Eliminar Tipo de Actividad y verificar reasignación a Id = 1 ---'
BEGIN TRAN;

    -- 1. ARRANGE
    -- Aseguramos que el tipo de actividad por defecto (Id = 1) exista en la prueba
    IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Tipo_Actividad WHERE IdTipoActividad = 1)
    BEGIN
        SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad ON;
        INSERT INTO Area_Excursiones.Tipo_Actividad (IdTipoActividad, Descripcion) VALUES (1, 'Tipo Actividad Por Defecto');
        SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad OFF;
    END

    -- Insertamos el Tipo de Actividad que vamos a eliminar
    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad ON;
    INSERT INTO Area_Excursiones.Tipo_Actividad (IdTipoActividad, Descripcion) VALUES (999, 'Tipo Temporal');
    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad OFF;

    -- Insertamos el Parque necesario para crear la actividad
    SET IDENTITY_INSERT Area_Infraestructura.Parque ON;
    INSERT INTO Area_Infraestructura.Parque(IdParque, Nombre, Superficie) VALUES (999, 'Parque Test', 50000);
    SET IDENTITY_INSERT Area_Infraestructura.Parque OFF;

    -- Insertamos una Actividad asociada al Tipo_Actividad temporal (999)
    SET IDENTITY_INSERT Area_Excursiones.Actividad ON;
    INSERT INTO Area_Excursiones.Actividad(IdActividad, IdTipoActividad, IdParque, Nombre, Costo, Duracion, Cupo_maximo, Activo) 
    VALUES (999, 999, 999, 'Actividad Test Reemplazo', 1500, 2, 10, 1);
    SET IDENTITY_INSERT Area_Excursiones.Actividad OFF;

    PRINT '>>> ANTES DE ELIMINAR: Estado de los Tipos (1 y 999) y de la Actividad (Asociada a 999) <<<'
    SELECT IdTipoActividad, Descripcion FROM Area_Excursiones.Tipo_Actividad WHERE IdTipoActividad IN (1, 999);
    SELECT IdActividad, Nombre, IdTipoActividad FROM Area_Excursiones.Actividad WHERE IdActividad = 999;

    -- 2. ACT & ASSERT
    BEGIN TRY
        EXEC Area_Excursiones.Sp_EliminarTipoActividad @idTipoActividad = 999;

        PRINT 'RESULTADO TEST 2: PASÓ (SP Ejecutado sin errores)'
        
        PRINT '>>> DESPUÉS DE ELIMINAR: Estado de los Tipos y de la Actividad (Debería tener IdTipoActividad = 1) <<<'
        SELECT IdTipoActividad, Descripcion FROM Area_Excursiones.Tipo_Actividad WHERE IdTipoActividad IN (1, 999);
        SELECT IdActividad, Nombre, IdTipoActividad FROM Area_Excursiones.Actividad WHERE IdActividad = 999;

        -- Verificamos: Que el tipo 999 no exista y que la actividad tenga ahora el tipo 1
        IF NOT EXISTS(SELECT 1 FROM Area_Excursiones.Tipo_Actividad WHERE IdTipoActividad = 999) 
           AND EXISTS(SELECT 1 FROM Area_Excursiones.Actividad WHERE IdActividad = 999 AND IdTipoActividad = 1)
        BEGIN
            PRINT '-> ÉXITO: El Tipo de Actividad fue eliminado y la actividad se reasignó correctamente al tipo por defecto (1).'
        END
        ELSE
        BEGIN
            PRINT '-> FALLA: No se completó la reasignación en cascada correctamente o no se borró el tipo.'
        END
    END TRY
    BEGIN CATCH
        PRINT 'RESULTADO TEST 2: FALLÓ - Error inesperado: '+ ERROR_MESSAGE()
    END CATCH

-- 3. TEARDOWN
IF @@TRANCOUNT > 0 ROLLBACK TRAN; 


-------------------------------------------------------------------------
-- TEST 3: Intentar Eliminar un Tipo de Actividad Inexistente
-------------------------------------------------------------------------
PRINT ''
PRINT '--- TEST 3: Intentar Eliminar un Tipo de Actividad Inexistente ---'
BEGIN TRAN;

    -- 1. ARRANGE: No insertamos nada, queremos que falle.

    -- 2. ACT & ASSERT
    BEGIN TRY
        -- Usamos un ID que sabemos que no existe
        EXEC Area_Excursiones.Sp_EliminarTipoActividad @idTipoActividad = 888;

        PRINT 'RESULTADO TEST 3: FALLÓ (El SP permitió eliminar un registro inexistente)'
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 3: PASÓ (El SP detectó que no existe y lanzó el error)';
    END CATCH

-- 3. TEARDOWN
IF @@TRANCOUNT > 0 ROLLBACK TRAN; 

PRINT ''
PRINT('======================================================')
PRINT('--- FIN DE LA BATERÍA DE PRUEBAS ---')
PRINT('======================================================')
GO