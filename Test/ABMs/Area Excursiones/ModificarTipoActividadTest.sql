/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del script de pruebas (Test) para la modificacion de un tipo de actividad
*/

USE SGParquesNacionales
GO

BEGIN TRAN; -- 1. Iniciamos la transacción de prueba

-- A. PREPARAR (Arrange)
    PRINT('======================================================')
    PRINT('--- PREPARANDO DATOS DE PRUEBA ---')
    PRINT('======================================================')
    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad ON;
    INSERT INTO Area_Excursiones.Tipo_Actividad(IdTipoActividad, Descripcion) VALUES (999, 'Aventura Test');
    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad OFF;
-------------------------------- TEST 1 ------------------------------------------------------------------------
    PRINT ''
    PRINT('--- TEST 1: Crear un tipo de actividad ---')

    
    BEGIN TRY
        EXEC Area_Excursiones.Sp_ModificarTipoActividad
        @IdTipoActividad = 999,
        @Descripcion = 'Recorrer montañas'
        PRINT 'RESULTADO TEST 1: PASÓ (SP Ejecutado sin errores)'
    END TRY

    BEGIN CATCH
        PRINT 'RESULTADO TEST 1: FALLÓ - Error inesperado: '+ ERROR_MESSAGE()
    END CATCH 

    SELECT * FROM Area_Excursiones.Tipo_Actividad

-------------------------------- TEST 2 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 2: Intentar modifico un tipo de actividad sin descripcion ---'

    BEGIN TRY
        EXEC Area_Excursiones.SP_ModificarTipoActividad
        @IdTipoActividad = 999,
        @Descripcion = ''
        PRINT 'RESULTADO TEST 2: FALLÓ (El SP creo un tipo de actividad invalido)';

    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 2: PASÓ (El SP bloqueó correctamente la modificacion)';
    END CATCH

-------------------------------- TEST 2 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 2: Intentar modifico un tipo de actividad con id inexistente ---'

    BEGIN TRY
        EXEC Area_Excursiones.SP_ModificarTipoActividad
        @IdTipoActividad = -1,
        @Descripcion = 'Correr el colectivo'
        PRINT 'RESULTADO TEST 2: FALLÓ (El SP creo un tipo de actividad invalido)';

    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 2: PASÓ (El SP bloqueó correctamente la modificacion)';
    END CATCH

ROLLBACK TRAN
GO