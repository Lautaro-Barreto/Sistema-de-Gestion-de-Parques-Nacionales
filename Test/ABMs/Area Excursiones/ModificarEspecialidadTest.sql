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
    
    SET IDENTITY_INSERT Area_Excursiones.Especialidad ON;
    INSERT INTO Area_Excursiones.Especialidad (IdEspecialidad, Descripcion)
    VALUES (999, 'Sedentarismo')
    SET IDENTITY_INSERT Area_Excursiones.Especialidad OFF;

-------------------------------- TEST 1 ------------------------------------------------------------------------
    PRINT ''
    PRINT('--- TEST 1: Modificar una Especialidad ---')

    
    BEGIN TRY
        EXEC Area_Excursiones.Sp_ModificarEspecialidad 
        @idEspecialidad = 999,
        @Descripcion = 'Caminatas'
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
        EXEC Area_Excursiones.Sp_ModificarEspecialidad 
        @idEspecialidad = 999,
        @Descripcion = ''
        PRINT 'RESULTADO TEST 2: FALLÓ (El SP creo una especialidad invalida)';

    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 2: PASÓ (El SP bloqueó correctamente la modificacion)';
    END CATCH

-------------------------------- TEST 3 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 3: Intentar crear una especialidad con Id invalido ---'

    BEGIN TRY
        EXEC Area_Excursiones.Sp_ModificarEspecialidad 
        @idEspecialidad = -1,
        @Descripcion = 'Bajar Montañas'
        PRINT 'RESULTADO TEST 3: FALLÓ (El SP modfico un registro inexistente)';

    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 2: PASÓ (El SP bloqueó correctamente la modificacion)';
    END CATCH
     SELECT * FROM Area_Excursiones.Especialidad

ROLLBACK TRAN 
GO