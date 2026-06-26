/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado testear la creacion de actividades
*/

USE SGParquesNacionales
GO

BEGIN TRAN; -- 1. Iniciamos la transacción de prueba
-- A. PREPARAR (Arrange)
    PRINT('---Test 1: Crear una actividad valida ---')
    -- Le pedimos permiso a SQL para insertar el ID 999 manualmente en Tipo_Actividad
    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad ON;
    Insert into Area_Excursiones.Tipo_Actividad(IdTipoActividad, Descripcion) VALUES (999, 'Aventura Test')
    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad OFF;

    SET IDENTITY_INSERT Area_Infraestructura.Parque ON;
    INSERT INTO Area_Infraestructura.Parque(IdParque, Nombre, Superficie) VALUES (999, 'Parque Nacional Test', 50000)
    SET IDENTITY_INSERT Area_Infraestructura.Parque OFF;
    DECLARE @NombrePrueba VARCHAR(50) = 'Trekking de Prueba 123';
-- B. EJECUTAR (Act)
-- Llamar al Stored Procedure usando un bloque TRY...CATCH
    BEGIN TRY 
        DECLARE @idDevuelto INT
        
        EXEC @idDevuelto = Area_Excursiones.Sp_CrearActividad
                @tipoActividad = 999, 
                @IdParque = 999, 
                @Nombre = @NombrePrueba, 
                @Costo = 15000.50, 
                @Duracion = 4, 
                @Cupo_Maximo = 20;
        PRINT 'Sp Ejecutado sin errores de sintaxis'
    END TRY
    BEGIN CATCH 
        PRINT 'Error insesperado: '+ ERROR_MESSAGE()
    END CATCH
--Validacion:
    SELECT * FROM Area_Excursiones.Actividad WHERE @idDevuelto = IdActividad


--                          TEST 2
    PRINT ''
    PRINT 'TEST 2: Intentar crear actividad con IdParque Inexistente'

    BEGIN TRY
            EXEC Area_Excursiones.Sp_CrearActividad 
                @TipoActividad = 999, 
                @IdParque = -1, -- ESTO DEBERÍA HACER FALLAR AL SP
                @Nombre = 'Actividad Imposible', 
                @Costo = 5000, 
                @Duracion = 2, 
                @Cupo_Maximo = 10;
                
            -- Si la ejecución llega a esta línea, significa que el SP no validó el error.
            PRINT 'RESULTADO TEST 2: FALLÓ (El SP permitió crear una actividad con un parque inválido o saltó un error genérico de SQL en vez del tuyo)';
    END TRY
    BEGIN CATCH
        -- 3. VALIDAR
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 2: PASÓ (El SP bloqueó correctamente la inserción)';
    END CATCH


----                                TEST 3
    PRINT ''
    PRINT 'TEST 3: Intentar crear una actividad con un Tipo de Actividad Inexistente  '
    BEGIN TRY
        EXEC Area_Excursiones.Sp_CrearActividad 
            @TipoActividad = -1, -- ESTO DEBERÍA HACER FALLAR AL SP
            @IdParque = 999, 
            @Nombre = 'Actividad Imposible', 
            @Costo = 5000, 
            @Duracion = 2, 
            @Cupo_Maximo = 10;
            
        -- Si la ejecución llega a esta línea, significa que el SP no validó el error.
        PRINT 'RESULTADO TEST 3: FALLÓ El SP permitió crear una actividad con un parque inválido ';
    END TRY
    BEGIN CATCH
        -- 3. VALIDAR
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 3: PASÓ (El SP bloqueó correctamente la inserción)';
    END CATCH

-----                   TEST 4
    PRINT ''
    PRINT 'TEST 4: Intentar crear una actividad con un costo NEGATIVO  '
    BEGIN TRY
        EXEC Area_Excursiones.Sp_CrearActividad 
            @TipoActividad = 999, 
            @IdParque = 999, 
            @Nombre = 'Actividad Imposible', 
            @Costo = -1, -- ESTO DEBERÍA HACER FALLAR AL SP
            @Duracion = 2, 
            @Cupo_Maximo = 10;
            
        -- Si la ejecución llega a esta línea, significa que el SP no validó el error.
        PRINT 'RESULTADO TEST 4: FALLÓ El SP permitió crear una actividad con un monto negativo';
    END TRY
    BEGIN CATCH
        -- 3. VALIDAR
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 4: PASÓ (El SP bloqueó correctamente la inserción)';
    END CATCH

------              TEST 5

    PRINT ''
    PRINT 'TEST 5: Intentar crear una actividad con una DURACION NEGATIVA  '
    BEGIN TRY
        EXEC Area_Excursiones.Sp_CrearActividad 
            @TipoActividad = 999, 
            @IdParque = 999, 
            @Nombre = 'Actividad Imposible', 
            @Costo = 5000, 
            @Duracion = -2, -- ESTO DEBERÍA HACER FALLAR AL SP
            @Cupo_Maximo = 10;
            
        -- Si la ejecución llega a esta línea, significa que el SP no validó el error.
        PRINT 'RESULTADO TEST 5: FALLÓ El SP permitió crear una actividad con una duracion negativa ';
    END TRY
    BEGIN CATCH
        -- 3. VALIDAR
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 5: PASÓ (El SP bloqueó correctamente la inserción)';
    END CATCH

--------------------------------TEST 6 ------------------------------------------------------------------------


    PRINT ''
    PRINT 'TEST 6: Intentar crear una actividad con un CUPO MAXIMO NEGATIVO  '
    BEGIN TRY
        EXEC Area_Excursiones.Sp_CrearActividad 
            @TipoActividad = 999, 
            @IdParque = 999, 
            @Nombre = 'Actividad Imposible', 
            @Costo = 5000, 
            @Duracion = 10, 
            @Cupo_Maximo = -2;-- ESTO DEBERÍA HACER FALLAR AL SP
            
        -- Si la ejecución llega a esta línea, significa que el SP no validó el error.
        PRINT 'RESULTADO TEST 6: FALLÓ El SP permitió crear una actividad con un cupo maximo negativo ';
    END TRY
    BEGIN CATCH
        -- 3. VALIDAR
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 6: PASÓ (El SP bloqueó correctamente la inserción)';
    END CATCH

-------------------------------------------TEST 7----------------------------------------------------------------------------------
    PRINT ''
    PRINT 'TEST 7: Intentar crear una actividad con un Nombre invalido  '
    BEGIN TRY
        EXEC Area_Excursiones.Sp_CrearActividad 
            @TipoActividad = 999, 
            @IdParque = 999, 
            @Nombre = '', 
            @Costo = 5000, 
            @Duracion = 10, 
            @Cupo_Maximo = 2;-- ESTO DEBERÍA HACER FALLAR AL SP
            
        -- Si la ejecución llega a esta línea, significa que el SP no validó el error.
        PRINT 'RESULTADO TEST 7: FALLÓ El SP permitió crear una actividad con un cupo maximo negativo ';
    END TRY
    BEGIN CATCH
        -- 3. VALIDAR
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 7: PASÓ (El SP bloqueó correctamente la inserción)';
    END CATCH
--------------------------------------------TEST 8----------------------------------------------------------------
    PRINT ''
    PRINT 'TEST 8: Intentar crear una actividad con un Nombre de actividad Existente  '
    BEGIN TRY
        EXEC Area_Excursiones.Sp_CrearActividad 
            @TipoActividad = 999, 
            @IdParque = 999, 
            @Nombre = @NombrePrueba,
            @Costo = 5000, 
            @Duracion = 10, 
            @Cupo_Maximo = 5;-- ESTO DEBERÍA HACER FALLAR AL SP
            
        -- Si la ejecución llega a esta línea, significa que el SP no validó el error.
        PRINT 'RESULTADO TEST 8: FALLÓ El SP permitió crear una actividad con un nombre de actividad repetido ';
    END TRY
    BEGIN CATCH
        -- 3. VALIDAR
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 8: PASÓ (El SP bloqueó correctamente la inserción)';
    END CATCH


select * FROM Area_Excursiones.Actividad
ROLLBACK TRAN; -- 4. Deshacemos TODO para no dejar basura en la BD.
PRINT 'Prueba finalizada. Base de datos restaurada.';
GO 