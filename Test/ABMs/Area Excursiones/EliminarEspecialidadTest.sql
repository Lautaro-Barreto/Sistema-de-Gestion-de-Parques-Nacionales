/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 23/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de testear la eliminación de una Especialidad,
#             incluyendo la reasignación de la especialidad por defecto (Id = 1) a sus guías asociados.
*/

USE SGParquesNacionales
GO

PRINT('===================================================================')
PRINT('--- INICIANDO BATERÍA DE PRUEBAS: Sp_EliminarEspecialidad ---')
PRINT('===================================================================')

-------------------------------------------------------------------------
-- TEST 1: Eliminar una Especialidad sin guías asociados
-------------------------------------------------------------------------
PRINT ''
PRINT '--- TEST 1: Eliminar una Especialidad sin guías asociados ---'
BEGIN TRAN; 

    -- 1. ARRANGE
    SET IDENTITY_INSERT Area_Excursiones.Especialidad ON;
    INSERT INTO Area_Excursiones.Especialidad (IdEspecialidad, Descripcion) 
    VALUES (999, 'Especialidad A Eliminar');
    SET IDENTITY_INSERT Area_Excursiones.Especialidad OFF;

    PRINT '>>> ANTES DE ELIMINAR: Verificando Especialidad a eliminar (Id = 999) <<<'
    SELECT IdEspecialidad, Descripcion FROM Area_Excursiones.Especialidad WHERE IdEspecialidad = 999;

    -- 2. ACT & ASSERT
    BEGIN TRY
        EXEC Area_Excursiones.Sp_EliminarEspecialidad @IdEspecialidad = 999;

        PRINT 'RESULTADO TEST 1: PASÓ (SP Ejecutado sin errores)'
        
        PRINT '>>> DESPUÉS DE ELIMINAR: Verificando que la Especialidad ya no existe (Grilla vacía) <<<'
        SELECT IdEspecialidad, Descripcion FROM Area_Excursiones.Especialidad WHERE IdEspecialidad = 999;

        -- Verificamos que realmente se haya borrado
        IF NOT EXISTS(SELECT 1 FROM Area_Excursiones.Especialidad WHERE IdEspecialidad = 999) 
        BEGIN
            PRINT '-> ÉXITO: La especialidad fue eliminada de la base de datos.'
        END
        ELSE
        BEGIN
            PRINT '-> FALLA: El SP se ejecutó pero la especialidad sigue existiendo.'
        END
    END TRY
    BEGIN CATCH
        PRINT 'RESULTADO TEST 1: FALLÓ - Error inesperado: '+ ERROR_MESSAGE()
    END CATCH

-- 3. TEARDOWN
IF @@TRANCOUNT > 0 ROLLBACK TRAN; 


-------------------------------------------------------------------------
-- TEST 2: Eliminar Especialidad y verificar reasignación de Guías (Id = 1)
-------------------------------------------------------------------------
PRINT ''
PRINT '--- TEST 2: Eliminar Especialidad y verificar reasignación de Guías ---'
BEGIN TRAN;

    -- 1. ARRANGE
    -- Aseguramos que la especialidad por defecto (Id = 1) exista en la prueba
    IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Especialidad WHERE IdEspecialidad = 1)
    BEGIN
        SET IDENTITY_INSERT Area_Excursiones.Especialidad ON;
        INSERT INTO Area_Excursiones.Especialidad (IdEspecialidad, Descripcion) VALUES (1, 'Especialidad Por Defecto');
        SET IDENTITY_INSERT Area_Excursiones.Especialidad OFF;
    END

    -- Insertamos la especialidad a eliminar
    SET IDENTITY_INSERT Area_Excursiones.Especialidad ON;
    INSERT INTO Area_Excursiones.Especialidad (IdEspecialidad, Descripcion) VALUES (999, 'Especialidad Temporal');
    SET IDENTITY_INSERT Area_Excursiones.Especialidad OFF;

    -- Insertamos las dependencias para poder crear un guía
    SET IDENTITY_INSERT Area_Infraestructura.Parque ON;
    INSERT INTO Area_Infraestructura.Parque(IdParque, Nombre, Superficie) VALUES (999, 'Parque Test', 50000);
    SET IDENTITY_INSERT Area_Infraestructura.Parque OFF;

    -- Insertamos un guía asociado a la especialidad temporal (999)
    SET IDENTITY_INSERT Area_Excursiones.Guia ON;
    INSERT INTO Area_Excursiones.Guia (IdGuia, DNI, IdParque, IdEspecialidad, Nombre, Apellido, Titulo)
    VALUES (999, '12345678', 999, 999, 'Guia', 'Test', 'Titulo Test');
    SET IDENTITY_INSERT Area_Excursiones.Guia OFF;

    PRINT '>>> ANTES DE ELIMINAR: Estado de las Especialidades (1 y 999) y del Guía (Asociado a 999) <<<'
    SELECT IdEspecialidad, Descripcion FROM Area_Excursiones.Especialidad WHERE IdEspecialidad IN (1, 999);
    SELECT IdGuia, Nombre, Apellido, IdEspecialidad FROM Area_Excursiones.Guia WHERE IdGuia = 999;

    -- 2. ACT & ASSERT
    BEGIN TRY
        EXEC Area_Excursiones.Sp_EliminarEspecialidad @IdEspecialidad = 999;

        PRINT 'RESULTADO TEST 2: PASÓ (SP Ejecutado sin errores)'
        
        PRINT '>>> DESPUÉS DE ELIMINAR: Estado de las Especialidades y del Guía (Debería tener IdEspecialidad = 1) <<<'
        SELECT IdEspecialidad, Descripcion FROM Area_Excursiones.Especialidad WHERE IdEspecialidad IN (1, 999);
        SELECT IdGuia, Nombre, Apellido, IdEspecialidad FROM Area_Excursiones.Guia WHERE IdGuia = 999;

        -- Verificamos 2 cosas: Que la especialidad no exista y que el guía tenga ahora la especialidad 1
        IF NOT EXISTS(SELECT 1 FROM Area_Excursiones.Especialidad WHERE IdEspecialidad = 999) 
           AND EXISTS(SELECT 1 FROM Area_Excursiones.Guia WHERE IdGuia = 999 AND IdEspecialidad = 1)
        BEGIN
            PRINT '-> ÉXITO: La especialidad fue eliminada y el guía fue reasignado a la especialidad por defecto (1).'
        END
        ELSE
        BEGIN
            PRINT '-> FALLA: No se completó la reasignación en cascada correctamente.'
        END
    END TRY
    BEGIN CATCH
        PRINT 'RESULTADO TEST 2: FALLÓ - Error inesperado: '+ ERROR_MESSAGE()
    END CATCH

-- 3. TEARDOWN
IF @@TRANCOUNT > 0 ROLLBACK TRAN; 


-------------------------------------------------------------------------
-- TEST 3: Intentar Eliminar una Especialidad Inexistente
-------------------------------------------------------------------------
PRINT ''
PRINT '--- TEST 3: Intentar Eliminar una Especialidad Inexistente ---'
BEGIN TRAN;

    -- 1. ARRANGE: No insertamos nada, queremos que falle.

    -- 2. ACT & ASSERT
    BEGIN TRY
        -- Usamos un ID que sabemos que no existe
        EXEC Area_Excursiones.Sp_EliminarEspecialidad @IdEspecialidad = 888;

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