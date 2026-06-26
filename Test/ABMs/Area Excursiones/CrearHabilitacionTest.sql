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
    PRINT('--- TEST 1: Crear una habilitación válida ---')
    PRINT('======================================================')

    BEGIN TRY
        EXEC Area_Excursiones.Sp_CrearHabilitacion
        @Descripcion = 'Primeros auxilios'
        PRINT 'RESULTADO TEST 1: PASÓ (SP Ejecutado sin errores)'
    END TRY

    BEGIN CATCH
        PRINT 'RESULTADO TEST 1: FALLÓ - Error inesperado: '+ ERROR_MESSAGE()
    END CATCH 

    SELECT * FROM Area_Excursiones.Habilitacion

-------------------------------- TEST 2 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 2: Intentar crear una habilitacion sin descripcion ---'

    BEGIN TRY
        EXEC Area_Excursiones.Sp_CrearHabilitacion
        @Descripcion = ''
        PRINT 'RESULTADO TEST 2: FALLÓ (El SP creo una habilitacion invalida)';

    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 2: PASÓ (El SP bloqueó correctamente la modificacion)';
    END CATCH


ROLLBACK TRAN
GO
