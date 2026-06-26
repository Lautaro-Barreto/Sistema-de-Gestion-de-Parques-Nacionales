/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 23/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de testear la eliminación de una Habilitación y sus 
#             dependencias (Guías y Actividades), utilizando transacciones aisladas por test.
*/

USE SGParquesNacionales
GO

PRINT('========================================================================')
PRINT('--- INICIANDO BATERÍA DE PRUEBAS: Sp_EliminarHabilitacion ---')
PRINT('========================================================================')

-------------------------------------------------------------------------
-- TEST 1: Eliminar la Habilitación y sus dependencias exitosamente
-------------------------------------------------------------------------
PRINT ''
PRINT '--- TEST 1: Eliminar la Habilitación y sus dependencias (Guías y Actividades) ---'
BEGIN TRAN; 

    -- 1. ARRANGE (Preparar dependencias completas)
    
    -- Insertar la Habilitación que vamos a eliminar
    SET IDENTITY_INSERT Area_Excursiones.Habilitacion ON;
    INSERT INTO Area_Excursiones.Habilitacion (IdHabilitaciones, Descripcion) 
    VALUES (999, 'Habilitacion A Eliminar Test');
    SET IDENTITY_INSERT Area_Excursiones.Habilitacion OFF;

    -- Preparar dependencias para poder insertar un Guía y una Actividad
    SET IDENTITY_INSERT Area_Infraestructura.Parque ON;
    INSERT INTO Area_Infraestructura.Parque(IdParque, Nombre, Superficie) VALUES (999, 'Parque Test', 50000);
    SET IDENTITY_INSERT Area_Infraestructura.Parque OFF;

    SET IDENTITY_INSERT Area_Excursiones.Especialidad ON;
    INSERT INTO Area_Excursiones.Especialidad(IdEspecialidad, Descripcion) VALUES (999, 'Especialidad Test');
    SET IDENTITY_INSERT Area_Excursiones.Especialidad OFF;

    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad ON;
    INSERT INTO Area_Excursiones.Tipo_Actividad(IdTipoActividad, Descripcion) VALUES (999, 'Aventura Test');
    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad OFF;

    -- Insertar el Guía (999) y la Actividad (999)
    SET IDENTITY_INSERT Area_Excursiones.Guia ON;
    INSERT INTO Area_Excursiones.Guia (IdGuia, DNI, IdParque, IdEspecialidad, Nombre, Apellido, Titulo)
    VALUES (999, '12345678', 999, 999, 'Guia', 'Test', 'Guia Experto');
    SET IDENTITY_INSERT Area_Excursiones.Guia OFF;

    SET IDENTITY_INSERT Area_Excursiones.Actividad ON;
    INSERT INTO Area_Excursiones.Actividad(IdActividad, IdTipoActividad, IdParque, Nombre, Costo, Duracion, Cupo_maximo, Activo) 
    VALUES (999, 999, 999, 'Actividad Test Habilitacion', 1500, 2, 10, 1);
    SET IDENTITY_INSERT Area_Excursiones.Actividad OFF;

    -- VINCULAR LA HABILITACIÓN CON EL GUÍA Y CON LA ACTIVIDAD
    INSERT INTO Area_Excursiones.Habilitacion_Guia (IdGuia, IdHabilitacion) VALUES (999, 999);
    INSERT INTO Area_Excursiones.Habilitaciones_por_Actividad (IdHabilitacion, IdActividad) VALUES (999, 999);

    PRINT '>>> ANTES DE ELIMINAR: Verificando las vinculaciones y la habilitación <<<'
    SELECT IdHabilitaciones, Descripcion FROM Area_Excursiones.Habilitacion WHERE IdHabilitaciones = 999;
    SELECT IdGuia, IdHabilitacion AS 'IdHabilitacion en Guia' FROM Area_Excursiones.Habilitacion_Guia WHERE IdHabilitacion = 999;
    SELECT IdActividad, IdHabilitacion AS 'IdHabilitacion en Actividad' FROM Area_Excursiones.Habilitaciones_por_Actividad WHERE IdHabilitacion = 999;

    -- 2. ACT & ASSERT
    BEGIN TRY
        EXEC Area_Excursiones.Sp_EliminarHabilitacion @IdHabilitacion = 999;

        PRINT 'RESULTADO TEST 1: PASÓ (SP Ejecutado sin errores)'
        
        PRINT '>>> DESPUÉS DE ELIMINAR: Verificando que todo se haya borrado (Grillas vacías) <<<'
        SELECT IdHabilitaciones, Descripcion FROM Area_Excursiones.Habilitacion WHERE IdHabilitaciones = 999;
        SELECT IdGuia, IdHabilitacion FROM Area_Excursiones.Habilitacion_Guia WHERE IdHabilitacion = 999;
        SELECT IdActividad, IdHabilitacion FROM Area_Excursiones.Habilitaciones_por_Actividad WHERE IdHabilitacion = 999;

        -- Verificamos que realmente no exista nada en ninguna de las 3 tablas
        IF NOT EXISTS(SELECT 1 FROM Area_Excursiones.Habilitacion WHERE IdHabilitaciones = 999) 
           AND NOT EXISTS(SELECT 1 FROM Area_Excursiones.Habilitacion_Guia WHERE IdHabilitacion = 999)
           AND NOT EXISTS(SELECT 1 FROM Area_Excursiones.Habilitaciones_por_Actividad WHERE IdHabilitacion = 999)
        BEGIN
            PRINT '-> ÉXITO: La habilitación y todas sus dependencias fueron eliminadas correctamente.'
        END
        ELSE
        BEGIN
            PRINT '-> FALLA: El SP se ejecutó pero quedaron registros huérfanos o la habilitación no se borró.'
        END
    END TRY
    BEGIN CATCH
        PRINT 'RESULTADO TEST 1: FALLÓ - Error inesperado: '+ ERROR_MESSAGE()
    END CATCH

-- 3. TEARDOWN
IF @@TRANCOUNT > 0 ROLLBACK TRAN; 


-------------------------------------------------------------------------
-- TEST 2: Intentar Eliminar una Habilitación Inexistente
-------------------------------------------------------------------------
PRINT ''
PRINT '--- TEST 2: Intentar Eliminar una Habilitación Inexistente ---'
BEGIN TRAN;

    -- 1. ARRANGE
    -- No insertamos ninguna habilitación para forzar el error.

    -- 2. ACT & ASSERT
    BEGIN TRY
        -- Usamos un IdHabilitacion que sabemos que no existe (888)
        EXEC Area_Excursiones.Sp_EliminarHabilitacion @IdHabilitacion = 888;
        
        PRINT 'RESULTADO TEST 2: FALLÓ (El SP permitió borrar saltándose la validación de existencia)'
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 2: PASÓ (El SP bloqueó correctamente la eliminación de un ID inexistente)';
    END CATCH

-- 3. TEARDOWN
-- Si el SP falló, ya hizo su propio ROLLBACK adentro del CATCH. 
-- El IF protege la ejecución del script.
IF @@TRANCOUNT > 0 ROLLBACK TRAN; 

PRINT ''
PRINT('======================================================')
PRINT('--- FIN DE LA BATERÍA DE PRUEBAS ---')
PRINT('======================================================')
GO