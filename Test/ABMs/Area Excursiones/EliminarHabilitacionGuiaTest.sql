/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 23/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de testear la desvinculación entre un Guía y una 
#             Habilitación, utilizando transacciones aisladas por cada test.
*/

USE SGParquesNacionales
GO

PRINT('========================================================================================')
PRINT('--- INICIANDO BATERÍA DE PRUEBAS: Sp_EliminarHabilitacionGuia ---')
PRINT('========================================================================================')

-------------------------------------------------------------------------
-- TEST 1: Eliminar la vinculación exitosamente
-------------------------------------------------------------------------
PRINT ''
PRINT '--- TEST 1: Eliminar vinculación entre Guía y Habilitación ---'
BEGIN TRAN; 

    -- 1. ARRANGE (Preparar dependencias completas)
    
    -- Dependencias del Guía
    SET IDENTITY_INSERT Area_Infraestructura.Parque ON;
    INSERT INTO Area_Infraestructura.Parque(IdParque, Nombre, Superficie) VALUES (999, 'Parque Test', 50000);
    SET IDENTITY_INSERT Area_Infraestructura.Parque OFF;

    SET IDENTITY_INSERT Area_Excursiones.Especialidad ON;
    INSERT INTO Area_Excursiones.Especialidad(IdEspecialidad, Descripcion) VALUES (999, 'Especialidad Test');
    SET IDENTITY_INSERT Area_Excursiones.Especialidad OFF;

    -- Insertamos el Guía (Id=999) y la Habilitación (Id=999)
    SET IDENTITY_INSERT Area_Excursiones.Guia ON;
    INSERT INTO Area_Excursiones.Guia (IdGuia, DNI, IdParque, IdEspecialidad, Nombre, Apellido, Titulo)
    VALUES (999, '12345678', 999, 999, 'Guia', 'Test', 'Guia Experto');
    SET IDENTITY_INSERT Area_Excursiones.Guia OFF;

    SET IDENTITY_INSERT Area_Excursiones.Habilitacion ON;
    INSERT INTO Area_Excursiones.Habilitacion (IdHabilitaciones, Descripcion) 
    VALUES (999, 'Habilitacion Test Vinculacion');
    SET IDENTITY_INSERT Area_Excursiones.Habilitacion OFF;

    -- VINCULAMOS EL GUÍA CON LA HABILITACIÓN
    INSERT INTO Area_Excursiones.Habilitacion_Guia (IdGuia, IdHabilitacion) VALUES (999, 999);

    PRINT '>>> ANTES DE ELIMINAR: Verificando la vinculación (Debería devolver 1 fila) <<<'
    SELECT IdGuia, IdHabilitacion FROM Area_Excursiones.Habilitacion_Guia WHERE IdGuia = 999 AND IdHabilitacion = 999;

    -- 2. ACT & ASSERT
    BEGIN TRY
        EXEC Area_Excursiones.Sp_EliminarHabilitacionGuia @IdHabilitacion = 999, @IdGuia = 999;

        PRINT 'RESULTADO TEST 1: PASÓ (SP Ejecutado sin errores)'
        
        PRINT '>>> DESPUÉS DE ELIMINAR: Verificando que la vinculación ya no existe (Grilla vacía) <<<'
        SELECT IdGuia, IdHabilitacion FROM Area_Excursiones.Habilitacion_Guia WHERE IdGuia = 999 AND IdHabilitacion = 999;

        -- Verificamos que se haya borrado
        IF NOT EXISTS(SELECT 1 FROM Area_Excursiones.Habilitacion_Guia WHERE IdGuia = 999 AND IdHabilitacion = 999) 
        BEGIN
            PRINT '-> ÉXITO: El registro fue eliminado correctamente de Habilitacion_Guia.'
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
-- TEST 2: Intentar Eliminar con una Habilitación Inexistente
-------------------------------------------------------------------------
PRINT ''
PRINT '--- TEST 2: Intentar Eliminar con una Habilitación Inexistente ---'
BEGIN TRAN;

    -- 1. ARRANGE
    SET IDENTITY_INSERT Area_Infraestructura.Parque ON;
    INSERT INTO Area_Infraestructura.Parque(IdParque, Nombre, Superficie) VALUES (999, 'Parque Test', 50000);
    SET IDENTITY_INSERT Area_Infraestructura.Parque OFF;

    SET IDENTITY_INSERT Area_Excursiones.Especialidad ON;
    INSERT INTO Area_Excursiones.Especialidad(IdEspecialidad, Descripcion) VALUES (999, 'Especialidad Test');
    SET IDENTITY_INSERT Area_Excursiones.Especialidad OFF;

    -- Insertamos solo el Guía válido
    SET IDENTITY_INSERT Area_Excursiones.Guia ON;
    INSERT INTO Area_Excursiones.Guia (IdGuia, DNI, IdParque, IdEspecialidad, Nombre, Apellido, Titulo)
    VALUES (999, '12345678', 999, 999, 'Guia', 'Test', 'Guia Experto');
    SET IDENTITY_INSERT Area_Excursiones.Guia OFF;

    -- 2. ACT & ASSERT
    BEGIN TRY
        -- Usamos un ID de habilitación inexistente (888)
        EXEC Area_Excursiones.Sp_EliminarHabilitacionGuia @IdHabilitacion = 888, @IdGuia = 999;
        
        PRINT 'RESULTADO TEST 2: FALLÓ (El SP no validó la existencia de la habilitación)'
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 2: PASÓ (El SP bloqueó correctamente la habilitación inexistente)';
    END CATCH

-- 3. TEARDOWN
IF @@TRANCOUNT > 0 ROLLBACK TRAN; 


-------------------------------------------------------------------------
-- TEST 3: Intentar Eliminar con un Guía Inexistente
-------------------------------------------------------------------------
PRINT ''
PRINT '--- TEST 3: Intentar Eliminar con un Guía Inexistente ---'
BEGIN TRAN;

    -- 1. ARRANGE
    -- Insertamos solo la Habilitación válida
    SET IDENTITY_INSERT Area_Excursiones.Habilitacion ON;
    INSERT INTO Area_Excursiones.Habilitacion (IdHabilitaciones, Descripcion) 
    VALUES (999, 'Habilitacion Test');
    SET IDENTITY_INSERT Area_Excursiones.Habilitacion OFF;

    -- 2. ACT & ASSERT
    BEGIN TRY
        -- Usamos un IdGuia que sabemos que no existe (888)
        EXEC Area_Excursiones.Sp_EliminarHabilitacionGuia @IdHabilitacion = 999, @IdGuia = 888;
        
        PRINT 'RESULTADO TEST 3: FALLÓ (El SP no validó la existencia del guía)'
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 3: PASÓ (El SP bloqueó correctamente la falta de guía)';
    END CATCH

-- 3. TEARDOWN
IF @@TRANCOUNT > 0 ROLLBACK TRAN; 


-------------------------------------------------------------------------
-- TEST 4: Intentar Eliminar una vinculación inexistente
-------------------------------------------------------------------------
PRINT ''
PRINT '--- TEST 4: Intentar Eliminar una vinculación inexistente (Existen pero no están unidos) ---'
BEGIN TRAN;

    -- 1. ARRANGE
    SET IDENTITY_INSERT Area_Infraestructura.Parque ON;
    INSERT INTO Area_Infraestructura.Parque(IdParque, Nombre, Superficie) VALUES (999, 'Parque Test', 50000);
    SET IDENTITY_INSERT Area_Infraestructura.Parque OFF;

    SET IDENTITY_INSERT Area_Excursiones.Especialidad ON;
    INSERT INTO Area_Excursiones.Especialidad(IdEspecialidad, Descripcion) VALUES (999, 'Especialidad Test');
    SET IDENTITY_INSERT Area_Excursiones.Especialidad OFF;

    SET IDENTITY_INSERT Area_Excursiones.Guia ON;
    INSERT INTO Area_Excursiones.Guia (IdGuia, DNI, IdParque, IdEspecialidad, Nombre, Apellido, Titulo)
    VALUES (999, '12345678', 999, 999, 'Guia', 'Test', 'Guia Experto');
    SET IDENTITY_INSERT Area_Excursiones.Guia OFF;

    SET IDENTITY_INSERT Area_Excursiones.Habilitacion ON;
    INSERT INTO Area_Excursiones.Habilitacion (IdHabilitaciones, Descripcion) 
    VALUES (999, 'Habilitacion Test');
    SET IDENTITY_INSERT Area_Excursiones.Habilitacion OFF;

    -- A PROPÓSITO: NO HACEMOS EL INSERT EN Habilitacion_Guia

    -- 2. ACT & ASSERT
    BEGIN TRY
        EXEC Area_Excursiones.Sp_EliminarHabilitacionGuia @IdHabilitacion = 999, @IdGuia = 999;
        
        PRINT 'RESULTADO TEST 4: FALLÓ (El SP intentó eliminar una relación que no existía)'
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 4: PASÓ (El SP detectó que no estaban vinculados)';
    END CATCH

-- 3. TEARDOWN
IF @@TRANCOUNT > 0 ROLLBACK TRAN; 

PRINT ''
PRINT('======================================================')
PRINT('--- FIN DE LA BATERÍA DE PRUEBAS ---')
PRINT('======================================================')
GO