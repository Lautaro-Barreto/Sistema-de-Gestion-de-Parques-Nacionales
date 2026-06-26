/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del script de pruebas (Test) para la modificación de una Habilitación asignada a un Guía.
*/

USE SGParquesNacionales
GO

BEGIN TRAN; -- 1. Iniciamos la transacción de prueba

-- A. PREPARAR (Arrange)
    PRINT('======================================================')
    PRINT('--- PREPARANDO DATOS DE PRUEBA ---')
    PRINT('======================================================')
    
    -- 1. Insertamos datos base (Parque y Especialidad)
    SET IDENTITY_INSERT Area_Infraestructura.Parque ON;
    INSERT INTO Area_Infraestructura.Parque(IdParque, Nombre, Superficie) VALUES (999, 'Parque Nacional Test', 50000);
    SET IDENTITY_INSERT Area_Infraestructura.Parque OFF;

    SET IDENTITY_INSERT Area_Excursiones.Especialidad ON;
    INSERT INTO Area_Excursiones.Especialidad(IdEspecialidad, Descripcion) VALUES (999, 'Especialidad Test');
    SET IDENTITY_INSERT Area_Excursiones.Especialidad OFF;

    -- 2. Insertamos Guías de prueba. 
    -- Guía 999: Tendrá la habilitación asignada.
    -- Guía 998: NO tendrá la habilitación asignada (para testear relaciones inexistentes).
    SET IDENTITY_INSERT Area_Excursiones.Guia ON;
    INSERT INTO Area_Excursiones.Guia (IdGuia, DNI, IdParque, IdEspecialidad, Nombre, Apellido, Titulo)
    VALUES 
    (999, '11111111', 999, 999, 'Guia', 'Prueba', 'Titulo Test'),
    (998, '22222222', 999, 999, 'Guia', 'Sin Habilitación', 'Titulo Test');
    SET IDENTITY_INSERT Area_Excursiones.Guia OFF;

    -- 3. Insertamos Habilitación de prueba
    SET IDENTITY_INSERT Area_Excursiones.Habilitacion ON;
    INSERT INTO Area_Excursiones.Habilitacion (IdHabilitaciones, Descripcion) VALUES (999, 'Habilitación de Alta Montaña');
    SET IDENTITY_INSERT Area_Excursiones.Habilitacion OFF;

    -- Preparamos fechas útiles para las pruebas
    DECLARE @FechaHoy DATE = GETDATE();
    DECLARE @FechaFutura DATE = DATEADD(year, 1, @FechaHoy);
    DECLARE @FechaMasFutura DATE = DATEADD(year, 2, @FechaHoy);
    DECLARE @FechaPasada DATE = DATEADD(year, -1, @FechaHoy);

    -- 4. INSERTAMOS LA ASIGNACIÓN ORIGINAL (Solo al guía 999)
    INSERT INTO Area_Excursiones.Habilitacion_Guia (IdGuia, IdHabilitacion, Fecha_Inicio_Validez, Fecha_Fin_Validez)
    VALUES (999, 999, @FechaHoy, @FechaFutura);


-------------------------------- TEST 1 ------------------------------------------------------------------------
    PRINT ''
    PRINT('--- TEST 1: Modificar fechas a una Habilitación existente válida (Happy Path) ---')

    BEGIN TRY 
        -- Modificamos para extender su validez 1 año más en el futuro
        EXEC Area_Excursiones.Sp_ModificarHabilitacionesGuia
                @IdGuia = 999,      
                @IdHabilitacion = 999, 
                @FechaInicio = @FechaHoy,
                @FechaFin = @FechaMasFutura;
                
        PRINT 'RESULTADO TEST 1: PASÓ (SP Ejecutado sin errores y se modificó la asignación)'
    END TRY
    BEGIN CATCH 
        PRINT 'RESULTADO TEST 1: FALLÓ - Error inesperado: '+ ERROR_MESSAGE()
    END CATCH

    -- Verificar que la modificación se aplicó (La Fecha_Fin_Validez ahora debería ser @FechaMasFutura)
    SELECT * FROM Area_Excursiones.Habilitacion_Guia WHERE IdGuia = 999 AND IdHabilitacion = 999;


-------------------------------- TEST 2 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 2: Intentar modificar Habilitación de un Guía INEXISTENTE ---'

    BEGIN TRY
            EXEC Area_Excursiones.Sp_ModificarHabilitacionesGuia 
                @IdGuia = -1, -- ESTE GUIA NO EXISTE     
                @IdHabilitacion = 999, 
                @FechaInicio = @FechaHoy,
                @FechaFin = @FechaFutura;
                
            PRINT 'RESULTADO TEST 2: FALLÓ (El SP permitió modificar a un guía inexistente)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 2: PASÓ (El SP bloqueó correctamente al guía inexistente)';
    END CATCH


-------------------------------- TEST 3 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 3: Intentar modificar una Habilitación INEXISTENTE ---'

    BEGIN TRY
            EXEC Area_Excursiones.Sp_ModificarHabilitacionesGuia 
                @IdGuia = 999,      
                @IdHabilitacion = -1, -- ESTA HABILITACION NO EXISTE
                @FechaInicio = @FechaHoy,
                @FechaFin = @FechaFutura;
                
            PRINT 'RESULTADO TEST 3: FALLÓ (El SP permitió usar una habilitación inexistente)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 3: PASÓ (El SP bloqueó correctamente la habilitación inexistente)';
    END CATCH


-------------------------------- TEST 4 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 4: Intentar modificar una Asignación que NO EXISTE ---'
    BEGIN TRY
        -- Usamos el Guía 998, que existe pero NUNCA se le asignó la habilitación 999
        EXEC Area_Excursiones.Sp_ModificarHabilitacionesGuia 
            @IdGuia = 998,      
            @IdHabilitacion = 999, 
            @FechaInicio = @FechaHoy,
            @FechaFin = @FechaFutura;
            
        PRINT 'RESULTADO TEST 4: FALLÓ (El SP modificó un registro que no existía)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 4: PASÓ (El SP detectó que el guía no tenía esa habilitación asignada)';
    END CATCH

-------------------------------- TEST 5 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 5: Intentar modificar poniendo FechaFin < FechaInicio ---'
    BEGIN TRY
        EXEC Area_Excursiones.Sp_ModificarHabilitacionesGuia 
            @IdGuia = 999,      
            @IdHabilitacion = 999, 
            @FechaInicio = @FechaFutura, -- Inicio en el futuro
            @FechaFin = @FechaHoy;       -- Fin hoy (INCORRECTO)
            
        PRINT 'RESULTADO TEST 5: FALLÓ (El SP permitió una fecha fin menor a la fecha de inicio)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 5: PASÓ (El SP validó correctamente el rango de fechas)';
    END CATCH


-------------------------------- TEST 6 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 6: Intentar modificar poniendo FechaFin ya vencida (Menor a GETDATE) ---'
    BEGIN TRY
        EXEC Area_Excursiones.Sp_ModificarHabilitacionesGuia 
            @IdGuia = 999,      
            @IdHabilitacion = 999, 
            @FechaInicio = @FechaHoy, 
            @FechaFin = @FechaPasada; -- Terminó hace un año (INCORRECTO)
            
        PRINT 'RESULTADO TEST 6: FALLÓ (El SP permitió poner una fecha fin ya vencida)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 6: PASÓ (El SP detectó que la fecha fin es menor a la actual y bloqueó)';
    END CATCH

-------------------------------- FIN DE PRUEBAS ----------------------------------------------------------------

ROLLBACK TRAN; -- 4. Deshacemos TODO para no dejar basura en la BD.
PRINT '';
PRINT 'Pruebas finalizadas. Base de datos restaurada (ROLLBACK ejecutado).';
GO