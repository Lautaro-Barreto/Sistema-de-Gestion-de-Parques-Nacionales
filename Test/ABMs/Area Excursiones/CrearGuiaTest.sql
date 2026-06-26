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
    PRINT('--- TEST 1: Crear un Guía válido (Happy Path) ---')
    PRINT('======================================================')
    
    -- Le pedimos permiso a SQL para insertar el ID 999 manualmente en Parque y Especialidad para las pruebas
    SET IDENTITY_INSERT Area_Infraestructura.Parque ON;
    INSERT INTO Area_Infraestructura.Parque(IdParque, Nombre, Superficie) VALUES (999, 'Parque Nacional Test', 50000);
    SET IDENTITY_INSERT Area_Infraestructura.Parque OFF;

    SET IDENTITY_INSERT Area_Excursiones.Especialidad ON;
    INSERT INTO Area_Excursiones.Especialidad(IdEspecialidad, Descripcion) VALUES (999, 'Especialidad Test');
    SET IDENTITY_INSERT Area_Excursiones.Especialidad OFF;

    DECLARE @DniPrueba CHAR(8) = '12345678';

-- B. EJECUTAR (Act)
    BEGIN TRY 
        DECLARE @idDevuelto INT
        
        EXEC @idDevuelto = Area_Excursiones.Sp_CrearGuia
                @DNI = @DniPrueba, 
                @idParque = 999, 
                @idEspecialidad = 999, 
                @Nombre = 'Juan', 
                @Apellido = 'Perez Test', 
                @Titulo = 'Guía de Alta Montaña';
                
        PRINT 'RESULTADO TEST 1: PASÓ (SP Ejecutado sin errores)'
    END TRY
    BEGIN CATCH 
        PRINT 'RESULTADO TEST 1: FALLÓ - Error inesperado: '+ ERROR_MESSAGE()
    END CATCH

-- C. VALIDACIÓN
    SELECT * FROM Area_Excursiones.Guia WHERE IdGuia = @idDevuelto


-------------------------------- TEST 2 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 2: Intentar crear guía con IdParque Inexistente ---'

    BEGIN TRY
            EXEC Area_Excursiones.Sp_CrearGuia 
                @DNI = '87654321', 
                @idParque = -1, -- ESTO DEBERÍA HACER FALLAR AL SP
                @idEspecialidad = 999, 
                @Nombre = 'Maria', 
                @Apellido = 'Gomez', 
                @Titulo = 'Guía Local';
                
            PRINT 'RESULTADO TEST 2: FALLÓ (El SP permitió crear un guía con un parque inválido)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 2: PASÓ (El SP bloqueó correctamente la inserción)';
    END CATCH


-------------------------------- TEST 3 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 3: Intentar crear un guía con Especialidad Inexistente ---'
    BEGIN TRY
        EXEC Area_Excursiones.Sp_CrearGuia 
            @DNI = '87654321', 
            @idParque = 999, 
            @idEspecialidad = -1, -- ESTO DEBERÍA HACER FALLAR AL SP
            @Nombre = 'Maria', 
            @Apellido = 'Gomez', 
            @Titulo = 'Guía Local';
            
        PRINT 'RESULTADO TEST 3: FALLÓ (El SP permitió crear un guía con una especialidad inválida)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 3: PASÓ (El SP bloqueó correctamente la inserción)';
    END CATCH

-------------------------------- TEST 4 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 4: Intentar crear un guía con DNI inválido (Contiene letras) ---'
    BEGIN TRY
        EXEC Area_Excursiones.Sp_CrearGuia 
            @DNI = '1234ABCD', -- ESTO DEBERÍA HACER FALLAR AL SP
            @idParque = 999, 
            @idEspecialidad = 999, 
            @Nombre = 'Pedro', 
            @Apellido = 'Ramirez', 
            @Titulo = 'Guía Local';
            
        PRINT 'RESULTADO TEST 4: FALLÓ (El SP permitió crear un guía con un DNI inválido)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 4: PASÓ (El SP bloqueó correctamente la inserción)';
    END CATCH

-------------------------------- TEST 5 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 5: Intentar crear un guía con DNI inválido (Menos de 7 dígitos) ---'
    BEGIN TRY
        EXEC Area_Excursiones.Sp_CrearGuia 
            @DNI = '12345', -- ESTO DEBERÍA HACER FALLAR AL SP
            @idParque = 999, 
            @idEspecialidad = 999, 
            @Nombre = 'Pedro', 
            @Apellido = 'Ramirez', 
            @Titulo = 'Guía Local';
            
        PRINT 'RESULTADO TEST 5: FALLÓ (El SP permitió crear un guía con un DNI corto)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 5: PASÓ (El SP bloqueó correctamente la inserción)';
    END CATCH

-------------------------------- TEST 6 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 6: Intentar crear un guía con un DNI ya existente ---'
    BEGIN TRY
        -- Usamos el @DniPrueba que insertamos exitosamente en el TEST 1
        EXEC Area_Excursiones.Sp_CrearGuia 
            @DNI = @DniPrueba, -- ESTO DEBERÍA HACER FALLAR AL SP POR DUPLICADO
            @idParque = 999, 
            @idEspecialidad = 999, 
            @Nombre = 'Clon', 
            @Apellido = 'De Juan', 
            @Titulo = 'Guía Copia';
            
        PRINT 'RESULTADO TEST 6: FALLÓ (El SP permitió crear un guía con un DNI repetido)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 6: PASÓ (El SP bloqueó correctamente la inserción)';
    END CATCH

-------------------------------- TEST 7 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 7: Intentar crear un guía con Nombre vacío ---'
    BEGIN TRY
        EXEC Area_Excursiones.Sp_CrearGuia 
            @DNI = '11223344', 
            @idParque = 999, 
            @idEspecialidad = 999, 
            @Nombre = '', -- ESTO DEBERÍA HACER FALLAR AL SP
            @Apellido = 'Lopez', 
            @Titulo = 'Guía Local';
            
        PRINT 'RESULTADO TEST 7: FALLÓ (El SP permitió crear un guía sin nombre)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 7: PASÓ (El SP bloqueó correctamente la inserción)';
    END CATCH

-------------------------------- TEST 8 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 8: Intentar crear un guía con Apellido NULO ---'
    BEGIN TRY
        EXEC Area_Excursiones.Sp_CrearGuia 
            @DNI = '11223344', 
            @idParque = 999, 
            @idEspecialidad = 999, 
            @Nombre = 'Carlos', 
            @Apellido = NULL, -- ESTO DEBERÍA HACER FALLAR AL SP
            @Titulo = 'Guía Local';
            
        PRINT 'RESULTADO TEST 8: FALLÓ (El SP permitió crear un guía sin apellido)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 8: PASÓ (El SP bloqueó correctamente la inserción)';
    END CATCH

-------------------------------- TEST 9 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 9: Intentar crear un guía con Título vacío ---'
    BEGIN TRY
        EXEC Area_Excursiones.Sp_CrearGuia 
            @DNI = '11223344', 
            @idParque = 999, 
            @idEspecialidad = 999, 
            @Nombre = 'Carlos', 
            @Apellido = 'Lopez', 
            @Titulo = ''; -- ESTO DEBERÍA HACER FALLAR AL SP
            
        PRINT 'RESULTADO TEST 9: FALLÓ (El SP permitió crear un guía sin título)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 9: PASÓ (El SP bloqueó correctamente la inserción)';
    END CATCH

-------------------------------- FIN DE PRUEBAS ----------------------------------------------------------------

-- Muestra cómo quedó la tabla de guías (Debería haber solo 1 nuevo, el del Test 1)
SELECT * FROM Area_Excursiones.Guia WHERE DNI = @DniPrueba;

ROLLBACK TRAN; -- 4. Deshacemos TODO para no dejar basura en la BD.
PRINT '';
PRINT 'Pruebas finalizadas. Base de datos restaurada (ROLLBACK ejecutado).';
GO