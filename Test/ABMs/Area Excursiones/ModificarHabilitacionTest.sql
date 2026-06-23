/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del script de pruebas (Test) para la creacion de un Guía.
*/

USE SGParquesNacionales
GO

BEGIN TRAN; -- 1. Iniciamos la transacción de prueba

-- A. PREPARAR (Arrange)
    PRINT('======================================================')
    PRINT('--- TEST 1: Modificar una Habilitacion Valida ---')
    PRINT('======================================================')

    SET IDENTITY_INSERT Area_Excursiones.Habilitacion ON;
    INSERT INTO Area_Excursiones.Habilitacion(IdHabilitaciones, Descripcion) 
    VALUES (999, 'Habilitación de Alta Montaña Test');
    SET IDENTITY_INSERT Area_Excursiones.Habilitacion OFF;

    SELECT * FROM Area_Excursiones.Habilitacion
    
    BEGIN TRY
        EXEC Area_Excursiones.Sp_ModificarHabilitacion
        @IdHabilitacion = 999,
        @Descripcion = 'Primeros auxilios'
        PRINT 'RESULTADO TEST 1: PASÓ (SP Ejecutado sin errores)'
    END TRY

    BEGIN CATCH
        PRINT 'RESULTADO TEST 1: FALLÓ - Error inesperado: '+ ERROR_MESSAGE()
    END CATCH 

    SELECT * FROM Area_Excursiones.Habilitacion

-------------------------------- TEST 2 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 2: Intentar modificar una habilitacion sin descripcion ---'

    BEGIN TRY
        EXEC Area_Excursiones.Sp_ModificarHabilitacion
        @IdHabilitacion = 999,
        @Descripcion = ''
        PRINT 'RESULTADO TEST 2: FALLÓ (El SP modificó una actividad con una descripcion vacia)';

    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 2: PASÓ (El SP bloqueó correctamente la modificacion)';
    END CATCH

-------------------------------- TEST 3 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 3: Intentar modificar una habilitacion con ID inexistente ---'

    BEGIN TRY
        EXEC Area_Excursiones.Sp_ModificarHabilitacion
        @IdHabilitacion = 998,
        @Descripcion = 'Paseador'
        PRINT 'RESULTADO TEST 3: FALLÓ (El SP creo un tipo de actividad invalido)';

    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 3: PASÓ (El SP bloqueó correctamente la modificacion)';
    END CATCH

ROLLBACK TRAN
GO
