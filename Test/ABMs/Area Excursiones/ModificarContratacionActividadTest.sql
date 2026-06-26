/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del script de pruebas (Test) para la modificación de una Contratación de Actividad.
*/

USE SGParquesNacionales
GO

BEGIN TRAN; -- 1. Iniciamos la transacción de prueba

    -- Declaramos las fechas en variables globales del lote para evitar errores de sintaxis en el EXEC
    DECLARE @FechaHoy DATE = GETDATE();
    DECLARE @FechaFutura DATE = DATEADD(day, 10, GETDATE());

-- A. PREPARAR (Arrange)
    PRINT('======================================================')
    PRINT('--- PREPARANDO DATOS DE PRUEBA ---')
    PRINT('======================================================')
    
    -- 1. Insertamos datos base (Parque y Tipo_Actividad)
    SET IDENTITY_INSERT Area_Infraestructura.Parque ON;
    INSERT INTO Area_Infraestructura.Parque(IdParque, Nombre, Superficie) VALUES (999, 'Parque Nacional Test', 50000);
    SET IDENTITY_INSERT Area_Infraestructura.Parque OFF;

    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad ON;
    INSERT INTO Area_Excursiones.Tipo_Actividad(IdTipoActividad, Descripcion) VALUES (999, 'Aventura Test');
    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad OFF;

    -- 2. Insertamos Actividades de prueba (Una ACTIVA y otra INACTIVA)
    SET IDENTITY_INSERT Area_Excursiones.Actividad ON;
    INSERT INTO Area_Excursiones.Actividad (IdActividad, IdTipoActividad, IdParque, Nombre, Costo, Duracion, Cupo_maximo, Activo)
    VALUES 
    (999, 999, 999, 'Actividad ACTIVA', 1500.00, 2, 10, 1),  -- Activo = 1
    (998, 999, 999, 'Actividad INACTIVA', 1500.00, 2, 10, 0); -- Activo = 0
    SET IDENTITY_INSERT Area_Excursiones.Actividad OFF;

    -- 3. Insertamos una Venta de prueba
    SET IDENTITY_INSERT Area_Comercial.Venta ON;
    INSERT INTO Area_Comercial.Venta (IdVenta, Fecha) 
    VALUES (999, @FechaHoy);
    SET IDENTITY_INSERT Area_Comercial.Venta OFF;

    -- 4. Insertamos la Contratación Original a modificar (Asegurando Activo = 1)
    SET IDENTITY_INSERT Area_Excursiones.Contratacion_Actividad ON;
    INSERT INTO Area_Excursiones.Contratacion_Actividad (IdContratacion, IdVenta, IdActividad, Monto, Fecha_Contratacion, Activo)
    VALUES (999, 999, 999, 5000.00, @FechaHoy, 1);
    SET IDENTITY_INSERT Area_Excursiones.Contratacion_Actividad OFF;


-------------------------------- TEST 1 ------------------------------------------------------------------------
    PRINT ''
    PRINT('--- TEST 1: Modificar Contratación Válida (Happy Path) ---')

    BEGIN TRY 
        EXEC Area_Excursiones.Sp_ModificarContratacionActividad
                @IdContratacionActividad = 999,
                @IdActividad = 999, 
                @IdVenta = 999, 
                @Monto = 15000.50, -- Monto Modificado
                @FechaContratacion = @FechaHoy;
                
        PRINT 'RESULTADO TEST 1: PASÓ (SP Ejecutado sin errores)'
    END TRY
    BEGIN CATCH 
        PRINT 'RESULTADO TEST 1: FALLÓ - Error inesperado: '+ ERROR_MESSAGE()
    END CATCH

    -- Verificar que la modificación se aplicó correctamente
    SELECT * FROM Area_Excursiones.Contratacion_Actividad WHERE IdContratacion = 999;


-------------------------------- TEST 2 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 2: Intentar Modificar una Contratación INEXISTENTE ---'

    BEGIN TRY
            EXEC Area_Excursiones.Sp_ModificarContratacionActividad
                @IdContratacionActividad = -1, -- ESTA CONTRATACION NO EXISTE
                @IdActividad = 999, 
                @IdVenta = 999, 
                @Monto = 15000.50,
                @FechaContratacion = @FechaHoy;
                
            PRINT 'RESULTADO TEST 2: FALLÓ (El SP permitió modificar una contratación inexistente)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 2: PASÓ (El SP bloqueó correctamente la contratación inexistente)';
    END CATCH


-------------------------------- TEST 3 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 3: Intentar Modificar asignando una Actividad INEXISTENTE ---'

    BEGIN TRY
            EXEC Area_Excursiones.Sp_ModificarContratacionActividad
                @IdContratacionActividad = 999,
                @IdActividad = -1, -- ESTA ACTIVIDAD NO EXISTE
                @IdVenta = 999, 
                @Monto = 15000.50,
                @FechaContratacion = @FechaHoy;
                
            PRINT 'RESULTADO TEST 3: FALLÓ (El SP permitió asignar una actividad inexistente)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 3: PASÓ (El SP bloqueó correctamente la actividad inexistente)';
    END CATCH


-------------------------------- TEST 4 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 4: Intentar Modificar asignando una Actividad INACTIVA ---'

    BEGIN TRY
            EXEC Area_Excursiones.Sp_ModificarContratacionActividad
                @IdContratacionActividad = 999,
                @IdActividad = 998, -- ACTIVIDAD INACTIVA (Activo = 0)
                @IdVenta = 999, 
                @Monto = 15000.50,
                @FechaContratacion = @FechaHoy;
                
            PRINT 'RESULTADO TEST 4: FALLÓ (El SP permitió asignar una actividad inactiva)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 4: PASÓ (El SP bloqueó la asignación a una actividad inactiva)';
    END CATCH


-------------------------------- TEST 5 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 5: Intentar Modificar asignando una Venta INEXISTENTE ---'
    BEGIN TRY
        EXEC Area_Excursiones.Sp_ModificarContratacionActividad
            @IdContratacionActividad = 999,
            @IdActividad = 999, 
            @IdVenta = -1, -- ESTA VENTA NO EXISTE
            @Monto = 15000.50,
            @FechaContratacion = @FechaHoy;
            
        PRINT 'RESULTADO TEST 5: FALLÓ (El SP permitió asignar a una venta inexistente)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 5: PASÓ (El SP validó correctamente la existencia de la venta)';
    END CATCH

-------------------------------- TEST 6 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 6: Intentar Modificar asignando un Monto NEGATIVO ---'
    BEGIN TRY
        EXEC Area_Excursiones.Sp_ModificarContratacionActividad
            @IdContratacionActividad = 999,
            @IdActividad = 999, 
            @IdVenta = 999, 
            @Monto = -500.00, -- MONTO NEGATIVO
            @FechaContratacion = @FechaHoy;
            
        PRINT 'RESULTADO TEST 6: FALLÓ (El SP permitió modificar con monto negativo)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 6: PASÓ (El SP detectó el monto negativo y bloqueó la operación)';
    END CATCH

-------------------------------- TEST 7 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 7: Intentar Modificar asignando una Fecha Futura ---'
    BEGIN TRY
        EXEC Area_Excursiones.Sp_ModificarContratacionActividad
            @IdContratacionActividad = 999,
            @IdActividad = 999, 
            @IdVenta = 999, 
            @Monto = 15000.50, 
            @FechaContratacion = @FechaFutura; -- FECHA FUTURA (A través de variable)
            
        PRINT 'RESULTADO TEST 7: FALLÓ (El SP permitió asignar una fecha en el futuro)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 7: PASÓ (El SP bloqueó correctamente la fecha futura)';
    END CATCH


-------------------------------- FIN DE PRUEBAS ----------------------------------------------------------------

ROLLBACK TRAN; -- 4. Deshacemos TODO para no dejar basura en la BD.
PRINT '';
PRINT 'Pruebas finalizadas. Base de datos restaurada (ROLLBACK ejecutado).';
GO