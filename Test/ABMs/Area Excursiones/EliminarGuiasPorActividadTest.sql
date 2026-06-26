/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 23/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de testear la desvinculación entre un Guía y una Actividad,
#             utilizando transacciones aisladas por cada test.
*/

USE SGParquesNacionales
GO

PRINT('========================================================================')
PRINT('--- INICIANDO BATERÍA DE PRUEBAS: Sp_ElimnarGuiasPorActividad ---')
PRINT('========================================================================')

-------------------------------------------------------------------------
-- TEST 1: Eliminar la vinculación exitosamente
-------------------------------------------------------------------------
PRINT ''
PRINT '--- TEST 1: Eliminar vinculación entre Guía y Actividad ---'
BEGIN TRAN; 

    -- 1. ARRANGE (Preparar dependencias completas)
    SET IDENTITY_INSERT Area_Infraestructura.Parque ON;
    INSERT INTO Area_Infraestructura.Parque(IdParque, Nombre, Superficie) VALUES (999, 'Parque Test', 50000);
    SET IDENTITY_INSERT Area_Infraestructura.Parque OFF;

    SET IDENTITY_INSERT Area_Excursiones.Especialidad ON;
    INSERT INTO Area_Excursiones.Especialidad(IdEspecialidad, Descripcion) VALUES (999, 'Especialidad Test');
    SET IDENTITY_INSERT Area_Excursiones.Especialidad OFF;

    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad ON;
    INSERT INTO Area_Excursiones.Tipo_Actividad(IdTipoActividad, Descripcion) VALUES (999, 'Aventura Test');
    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad OFF;

    -- Insertamos el Guía (999) y la Actividad (999)
    SET IDENTITY_INSERT Area_Excursiones.Guia ON;
    INSERT INTO Area_Excursiones.Guia (IdGuia, DNI, IdParque, IdEspecialidad, Nombre, Apellido, Titulo)
    VALUES (999, '12345678', 999, 999, 'Guia', 'Test', 'Guia Experto');
    SET IDENTITY_INSERT Area_Excursiones.Guia OFF;

    SET IDENTITY_INSERT Area_Excursiones.Actividad ON;
    INSERT INTO Area_Excursiones.Actividad(IdActividad, IdTipoActividad, IdParque, Nombre, Costo, Duracion, Cupo_maximo, Activo) 
    VALUES (999, 999, 999, 'Actividad Test Guia', 1500, 2, 10, 1);
    SET IDENTITY_INSERT Area_Excursiones.Actividad OFF;

    -- VINCULAMOS AL GUÍA CON LA ACTIVIDAD
    INSERT INTO Area_Excursiones.Guias_por_Actividad (IdGuia, IdActividad) VALUES (999, 999);

    PRINT '>>> ANTES DE ELIMINAR: Verificando la vinculación (Debería devolver 1 fila) <<<'
    SELECT IdGuia, IdActividad FROM Area_Excursiones.Guias_por_Actividad WHERE IdGuia = 999 AND IdActividad = 999;

    -- 2. ACT & ASSERT
    BEGIN TRY
        -- Usamos el nombre exacto del SP (Sp_ElimnarGuiasPorActividad)
        EXEC Area_Excursiones.Sp_ElimnarGuiasPorActividad @IdActividad = 999, @IdGuia = 999;

        PRINT 'RESULTADO TEST 1: PASÓ (SP Ejecutado sin errores)'
        
        PRINT '>>> DESPUÉS DE ELIMINAR: Verificando que la vinculación ya no existe (Grilla vacía) <<<'
        SELECT IdGuia, IdActividad FROM Area_Excursiones.Guias_por_Actividad WHERE IdGuia = 999 AND IdActividad = 999;

        -- Verificamos que se haya borrado
        IF NOT EXISTS(SELECT 1 FROM Area_Excursiones.Guias_por_Actividad WHERE IdGuia = 999 AND IdActividad = 999) 
        BEGIN
            PRINT '-> ÉXITO: El registro fue eliminado correctamente de Guias_por_Actividad.'
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
    -- Repetimos inserciones base
    SET IDENTITY_INSERT Area_Infraestructura.Parque ON;
    INSERT INTO Area_Infraestructura.Parque(IdParque, Nombre, Superficie) VALUES (999, 'Parque Test', 50000);
    SET IDENTITY_INSERT Area_Infraestructura.Parque OFF;

    SET IDENTITY_INSERT Area_Excursiones.Especialidad ON;
    INSERT INTO Area_Excursiones.Especialidad(IdEspecialidad, Descripcion) VALUES (999, 'Especialidad Test');
    SET IDENTITY_INSERT Area_Excursiones.Especialidad OFF;

    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad ON;
    INSERT INTO Area_Excursiones.Tipo_Actividad(IdTipoActividad, Descripcion) VALUES (999, 'Aventura Test');
    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad OFF;

    SET IDENTITY_INSERT Area_Excursiones.Guia ON;
    INSERT INTO Area_Excursiones.Guia (IdGuia, DNI, IdParque, IdEspecialidad, Nombre, Apellido, Titulo)
    VALUES (999, '12345678', 999, 999, 'Guia', 'Test', 'Guia Experto');
    SET IDENTITY_INSERT Area_Excursiones.Guia OFF;

    -- Insertamos Actividad INACTIVA (Activo = 0)
    SET IDENTITY_INSERT Area_Excursiones.Actividad ON;
    INSERT INTO Area_Excursiones.Actividad(IdActividad, IdTipoActividad, IdParque, Nombre, Costo, Duracion, Cupo_maximo, Activo) 
    VALUES (998, 999, 999, 'Actividad Inactiva Test', 1500, 2, 10, 0);
    SET IDENTITY_INSERT Area_Excursiones.Actividad OFF;

    -- 2. ACT & ASSERT
    BEGIN TRY
        EXEC Area_Excursiones.Sp_ElimnarGuiasPorActividad @IdActividad = 998, @IdGuia = 999;
        PRINT 'RESULTADO TEST 2: FALLÓ (El SP permitió borrar saltándose la validación de Activo = 1)'
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 2: PASÓ (El SP bloqueó correctamente la actividad inactiva/inexistente)';
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
    -- Solo insertamos la actividad activa, pero no el guía
    SET IDENTITY_INSERT Area_Infraestructura.Parque ON;
    INSERT INTO Area_Infraestructura.Parque(IdParque, Nombre, Superficie) VALUES (999, 'Parque Test', 50000);
    SET IDENTITY_INSERT Area_Infraestructura.Parque OFF;

    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad ON;
    INSERT INTO Area_Excursiones.Tipo_Actividad(IdTipoActividad, Descripcion) VALUES (999, 'Aventura Test');
    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad OFF;

    SET IDENTITY_INSERT Area_Excursiones.Actividad ON;
    INSERT INTO Area_Excursiones.Actividad(IdActividad, IdTipoActividad, IdParque, Nombre, Costo, Duracion, Cupo_maximo, Activo) 
    VALUES (999, 999, 999, 'Actividad Test Guia', 1500, 2, 10, 1);
    SET IDENTITY_INSERT Area_Excursiones.Actividad OFF;

    -- 2. ACT & ASSERT
    BEGIN TRY
        -- Usamos un IdGuia que no existe (888)
        EXEC Area_Excursiones.Sp_ElimnarGuiasPorActividad @IdActividad = 999, @IdGuia = 888;
        PRINT 'RESULTADO TEST 3: FALLÓ (El SP no validó la existencia del guía)'
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 3: PASÓ (El SP bloqueó correctamente la falta de guía)';
    END CATCH

-- 3. TEARDOWN
IF @@TRANCOUNT > 0 ROLLBACK TRAN; 


-------------------------------------------------------------------------
-- TEST 4: Intentar Eliminar una vinculación que no existe
-------------------------------------------------------------------------
PRINT ''
PRINT '--- TEST 4: Intentar Eliminar una vinculación inexistente (El Guía y la Actividad existen, pero no están unidos) ---'
BEGIN TRAN;

    -- 1. ARRANGE
    SET IDENTITY_INSERT Area_Infraestructura.Parque ON;
    INSERT INTO Area_Infraestructura.Parque(IdParque, Nombre, Superficie) VALUES (999, 'Parque Test', 50000);
    SET IDENTITY_INSERT Area_Infraestructura.Parque OFF;

    SET IDENTITY_INSERT Area_Excursiones.Especialidad ON;
    INSERT INTO Area_Excursiones.Especialidad(IdEspecialidad, Descripcion) VALUES (999, 'Especialidad Test');
    SET IDENTITY_INSERT Area_Excursiones.Especialidad OFF;

    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad ON;
    INSERT INTO Area_Excursiones.Tipo_Actividad(IdTipoActividad, Descripcion) VALUES (999, 'Aventura Test');
    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad OFF;

    SET IDENTITY_INSERT Area_Excursiones.Guia ON;
    INSERT INTO Area_Excursiones.Guia (IdGuia, DNI, IdParque, IdEspecialidad, Nombre, Apellido, Titulo)
    VALUES (999, '12345678', 999, 999, 'Guia', 'Test', 'Guia Experto');
    SET IDENTITY_INSERT Area_Excursiones.Guia OFF;

    SET IDENTITY_INSERT Area_Excursiones.Actividad ON;
    INSERT INTO Area_Excursiones.Actividad(IdActividad, IdTipoActividad, IdParque, Nombre, Costo, Duracion, Cupo_maximo, Activo) 
    VALUES (999, 999, 999, 'Actividad Test Guia', 1500, 2, 10, 1);
    SET IDENTITY_INSERT Area_Excursiones.Actividad OFF;

    -- A PROPÓSITO: NO HACEMOS EL INSERT EN Guias_por_Actividad

    -- 2. ACT & ASSERT
    BEGIN TRY
        EXEC Area_Excursiones.Sp_ElimnarGuiasPorActividad @IdActividad = 999, @IdGuia = 999;
        PRINT 'RESULTADO TEST 4: FALLÓ (El SP intentó eliminar una relación que no existía)'
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 4: PASÓ (El SP detectó que la actividad no estaba asignada a ese guía)';
    END CATCH

-- 3. TEARDOWN
IF @@TRANCOUNT > 0 ROLLBACK TRAN; 

PRINT ''
PRINT('======================================================')
PRINT('--- FIN DE LA BATERÍA DE PRUEBAS ---')
PRINT('======================================================')
GO