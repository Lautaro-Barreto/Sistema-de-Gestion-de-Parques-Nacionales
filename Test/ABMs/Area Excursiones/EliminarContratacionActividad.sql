/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 23/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de testear la eliminación lógica de una Contratación de Actividad, 
#             utilizando el enfoque de Aislamiento por Test para evitar colisiones de transacciones.
*/

USE SGParquesNacionales
GO

PRINT('========================================================================')
PRINT('--- INICIANDO BATERÍA DE PRUEBAS: Sp_EliminarContratacionActividad ---')
PRINT('========================================================================')

-------------------------------------------------------------------------
-- TEST 1: Eliminar lógicamente una Contratación Activa
-------------------------------------------------------------------------
PRINT ''
PRINT '--- TEST 1: Eliminar lógicamente una Contratación Activa ---'
BEGIN TRAN; 

    -- 1. ARRANGE
    -- Nota: Como no tengo la estructura completa de Contratacion_Actividad, inserto lo mínimo.
    -- Si tu tabla tiene FKs obligatorias (NOT NULL) como IdActividad o Fecha, por favor agregalas en este INSERT.
    SET IDENTITY_INSERT Area_Excursiones.Contratacion_Actividad ON;
    INSERT INTO Area_Excursiones.Contratacion_Actividad (IdContratacion, Activo) 
    VALUES (999, 1);
    SET IDENTITY_INSERT Area_Excursiones.Contratacion_Actividad OFF;

    -- 2. ACT & ASSERT
    BEGIN TRY
        EXEC Area_Excursiones.Sp_EliminarContratacionActividad @IdContratacion = 999;

        PRINT 'RESULTADO TEST 1: PASÓ (SP Ejecutado sin errores)'
        
        -- Verificamos que realmente haya hecho el UPDATE a Activo = 0
        IF EXISTS(SELECT 1 FROM Area_Excursiones.Contratacion_Actividad WHERE IdContratacion = 999 AND Activo = 0) 
        BEGIN
            PRINT '-> ÉXITO: La contratación pasó a estado inactivo (Activo = 0) correctamente.'
        END
        ELSE
        BEGIN
            PRINT '-> FALLA: El SP se ejecutó pero el estado Activo no cambió a 0.'
        END
    END TRY
    BEGIN CATCH
        PRINT 'RESULTADO TEST 1: FALLÓ - Error inesperado: '+ ERROR_MESSAGE()
    END CATCH

-- 3. TEARDOWN: Limpiamos este test
IF @@TRANCOUNT > 0 ROLLBACK TRAN; 


-------------------------------------------------------------------------
-- TEST 2: Intentar Eliminar una Contratación Inexistente
-------------------------------------------------------------------------
PRINT ''
PRINT '--- TEST 2: Intentar Eliminar una Contratación Inexistente ---'
BEGIN TRAN;

    -- 1. ARRANGE: No insertamos nada, queremos que falle.

    -- 2. ACT & ASSERT
    BEGIN TRY
        -- Usamos un ID que sabemos que no existe
        EXEC Area_Excursiones.Sp_EliminarContratacionActividad @IdContratacion = 888;

        PRINT 'RESULTADO TEST 2: FALLÓ (El SP permitió "eliminar" un registro inexistente)'
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 2: PASÓ (El SP detectó que no existe y lanzó el error)';
    END CATCH

-- 3. TEARDOWN
IF @@TRANCOUNT > 0 ROLLBACK TRAN; 


-------------------------------------------------------------------------
-- TEST 3: Intentar Eliminar una Contratación que ya está dada de baja
-------------------------------------------------------------------------
PRINT ''
PRINT '--- TEST 3: Intentar Eliminar una Contratación ya dada de baja ---'
BEGIN TRAN;

    -- 1. ARRANGE: Insertamos una contratación que ya tiene Activo = 0
    SET IDENTITY_INSERT Area_Excursiones.Contratacion_Actividad ON;
    INSERT INTO Area_Excursiones.Contratacion_Actividad (IdContratacion, Activo) 
    VALUES (997, 0);
    SET IDENTITY_INSERT Area_Excursiones.Contratacion_Actividad OFF;

    -- 2. ACT & ASSERT
    BEGIN TRY
        -- Intentamos borrarla de nuevo
        EXEC Area_Excursiones.Sp_EliminarContratacionActividad @IdContratacion = 997;

        PRINT 'RESULTADO TEST 3: FALLÓ (El SP permitió "eliminar" un registro que ya estaba de baja)'
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 3: PASÓ (El SP detectó que ya estaba inactivo y lanzó el error)';
    END CATCH

-- 3. TEARDOWN
IF @@TRANCOUNT > 0 ROLLBACK TRAN; 

PRINT ''
PRINT('======================================================')
PRINT('--- FIN DE PRUEBAS ---')
PRINT('======================================================')
GO