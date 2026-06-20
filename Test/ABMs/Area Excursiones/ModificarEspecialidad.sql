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
    INSERT INTO Area_Excursiones.Especialidad (IdEspecialidad, Descripcion)
    VALUES (999, 'Sedentarismo')

-------------------------------- TEST 1 ------------------------------------------------------------------------
    PRINT ''
    PRINT('--- TEST 1: Modificar una Especialidad ---')

    DECLARE @idEspecialidad INT 
    BEGIN TRY
        EXEC @idEspecialidad = Area_Excursiones.Sp_CrearEspecialidad 
        @Descripcion = 'Sedentarismo'
        PRINT 'RESULTADO TEST 1: PASÓ (SP Ejecutado sin errores)'
    END TRY

    BEGIN CATCH
        PRINT 'RESULTADO TEST 1: FALLÓ - Error inesperado: '+ ERROR_MESSAGE()
    END CATCH 

    SELECT * FROM Area_Excursiones.Especialidad

-------------------------------- TEST 2 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 2: Intentar crear una especialidad sin descripcion ---'

    BEGIN TRY
        EXEC @idEspecialidad = Area_Excursiones.Sp_CrearEspecialidad 
        @Descripcion = ''
        PRINT 'RESULTADO TEST 2: FALLÓ (El SP creo una especialidad invalida)';

    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 2: PASÓ (El SP bloqueó correctamente la creacion)';
    END CATCH

ROLLBACK TRAN