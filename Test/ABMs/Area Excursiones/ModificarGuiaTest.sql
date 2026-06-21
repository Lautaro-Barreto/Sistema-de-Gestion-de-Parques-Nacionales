/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del script de pruebas (Test) para la modificación de un Guía.
*/

USE SGParquesNacionales
GO

BEGIN TRAN; -- 1. Iniciamos la transacción de prueba

-- A. PREPARAR (Arrange)
    PRINT('======================================================')
    PRINT('--- PREPARANDO DATOS DE PRUEBA ---')
    PRINT('======================================================')
    
    -- Insertamos Parque de prueba
    SET IDENTITY_INSERT Area_Infraestructura.Parque ON;
    INSERT INTO Area_Infraestructura.Parque(IdParque, Nombre, Superficie) VALUES (999, 'Parque Nacional Test', 50000);
    SET IDENTITY_INSERT Area_Infraestructura.Parque OFF;

    -- Insertamos Especialidad de prueba
    SET IDENTITY_INSERT Area_Excursiones.Especialidad ON;
    INSERT INTO Area_Excursiones.Especialidad(IdEspecialidad, Descripcion) VALUES (999, 'Especialidad Test');
    SET IDENTITY_INSERT Area_Excursiones.Especialidad OFF;

    -- Insertamos Guías de prueba. Necesitamos dos para probar que el DNI no choque con el de OTRO guía.
    SET IDENTITY_INSERT Area_Excursiones.Guia ON;
    INSERT INTO Area_Excursiones.Guia (IdGuia, DNI, IdParque, IdEspecialidad, Nombre, Apellido, Titulo)
    VALUES (999, '11111111', 999, 999, 'GuiaOriginal', 'Test', 'Titulo Original');
    
    INSERT INTO Area_Excursiones.Guia (IdGuia, DNI, IdParque, IdEspecialidad, Nombre, Apellido, Titulo)
    VALUES (998, '22222222', 999, 999, 'OtroGuia', 'Test', 'Otro Titulo');
    SET IDENTITY_INSERT Area_Excursiones.Guia OFF;

    SELECT * FROM Area_Excursiones.Guia
-------------------------------- TEST 1 ------------------------------------------------------------------------
    PRINT ''
    PRINT('--- TEST 1: Modificar un Guía válido (Happy Path) ---')

    BEGIN TRY 
        EXEC Area_Excursiones.Sp_ModificarGuia
                @IdGuia = 999,
                @DNI = '33333333', -- Dni nuevo válido
                @idParque = 999, 
                @idEspecialidad = 999, 
                @Nombre = 'Juan Modificado', 
                @Apellido = 'Perez Modificado', 
                @Titulo = 'Guía Experto';
                
        PRINT 'RESULTADO TEST 1: PASÓ (SP Ejecutado sin errores)'
    END TRY
    BEGIN CATCH 
        PRINT 'RESULTADO TEST 1: FALLÓ - Error inesperado: '+ ERROR_MESSAGE()
    END CATCH

    -- Mostrar cómo quedó tras el test 1
    SELECT * FROM Area_Excursiones.Guia WHERE IdGuia = 999;


-------------------------------- TEST 2 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 2: Intentar modificar un Guía Inexistente ---'

    BEGIN TRY
            EXEC Area_Excursiones.Sp_ModificarGuia 
                @IdGuia = -1, -- ESTE GUIA NO EXISTE
                @DNI = '33333333', 
                @idParque = 999, 
                @idEspecialidad = 999, 
                @Nombre = 'Maria', 
                @Apellido = 'Gomez', 
                @Titulo = 'Guía Local';
                
            PRINT 'RESULTADO TEST 2: FALLÓ (El SP permitió modificar un guía inexistente)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 2: PASÓ (El SP bloqueó correctamente la modificación)';
    END CATCH


-------------------------------- TEST 3 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 3: Intentar modificar un guía asignando un IdParque Inexistente ---'

    BEGIN TRY
            EXEC Area_Excursiones.Sp_ModificarGuia 
                @IdGuia = 999,
                @DNI = '33333333', 
                @idParque = -1, -- ESTE PARQUE NO EXISTE
                @idEspecialidad = 999, 
                @Nombre = 'Maria', 
                @Apellido = 'Gomez', 
                @Titulo = 'Guía Local';
                
            PRINT 'RESULTADO TEST 3: FALLÓ (El SP permitió modificar con un parque inválido)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 3: PASÓ (El SP bloqueó correctamente la modificación)';
    END CATCH


-------------------------------- TEST 4 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 4: Intentar modificar un guía asignando una Especialidad Inexistente ---'
    BEGIN TRY
        EXEC Area_Excursiones.Sp_ModificarGuia 
            @IdGuia = 999,
            @DNI = '33333333', 
            @idParque = 999, 
            @idEspecialidad = -1, -- ESTA ESPECIALIDAD NO EXISTE
            @Nombre = 'Maria', 
            @Apellido = 'Gomez', 
            @Titulo = 'Guía Local';
            
        PRINT 'RESULTADO TEST 4: FALLÓ (El SP permitió modificar con una especialidad inválida)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 4: PASÓ (El SP bloqueó correctamente la modificación)';
    END CATCH

-------------------------------- TEST 5 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 5: Intentar modificar con un DNI inválido (Contiene letras) ---'
    BEGIN TRY
        EXEC Area_Excursiones.Sp_ModificarGuia 
            @IdGuia = 999,
            @DNI = '1234ABCD', -- DNI INVALIDO
            @idParque = 999, 
            @idEspecialidad = 999, 
            @Nombre = 'Pedro', 
            @Apellido = 'Ramirez', 
            @Titulo = 'Guía Local';
            
        PRINT 'RESULTADO TEST 5: FALLÓ (El SP permitió modificar con un DNI inválido)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 5: PASÓ (El SP bloqueó correctamente la modificación)';
    END CATCH

-------------------------------- TEST 6 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 6: Intentar modificar con un DNI inválido (Menos de 7 dígitos) ---'
    BEGIN TRY
        EXEC Area_Excursiones.Sp_ModificarGuia 
            @IdGuia = 999,
            @DNI = '12345', -- DNI CORTO
            @idParque = 999, 
            @idEspecialidad = 999, 
            @Nombre = 'Pedro', 
            @Apellido = 'Ramirez', 
            @Titulo = 'Guía Local';
            
        PRINT 'RESULTADO TEST 6: FALLÓ (El SP permitió modificar con un DNI corto)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 6: PASÓ (El SP bloqueó correctamente la modificación)';
    END CATCH

-------------------------------- TEST 7 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 7: Intentar modificar asignando un DNI que ya tiene OTRO guía ---'
    BEGIN TRY
        -- Intentamos asignarle al Guía 999 el DNI que tiene el Guía 998
        EXEC Area_Excursiones.Sp_ModificarGuia 
            @IdGuia = 999,
            @DNI = '22222222', -- CHOQUE CON EL DNI DEL GUIA 998
            @idParque = 999, 
            @idEspecialidad = 999, 
            @Nombre = 'Clon', 
            @Apellido = 'De Juan', 
            @Titulo = 'Guía Copia';
            
        PRINT 'RESULTADO TEST 7: FALLÓ (El SP permitió asignar un DNI que ya pertenece a otro guía)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 7: PASÓ (El SP bloqueó correctamente la modificación)';
    END CATCH

-------------------------------- TEST 8 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 8: Intentar modificar dejando el Nombre vacío ---'
    BEGIN TRY
        EXEC Area_Excursiones.Sp_ModificarGuia 
            @IdGuia = 999,
            @DNI = '33333333', 
            @idParque = 999, 
            @idEspecialidad = 999, 
            @Nombre = '', -- NOMBRE VACIO
            @Apellido = 'Lopez', 
            @Titulo = 'Guía Local';
            
        PRINT 'RESULTADO TEST 8: FALLÓ (El SP permitió modificar dejando el nombre vacío)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 8: PASÓ (El SP bloqueó correctamente la modificación)';
    END CATCH

-------------------------------- TEST 9 ------------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 9: Intentar modificar dejando el Apellido en NULO ---'
    BEGIN TRY
        EXEC Area_Excursiones.Sp_ModificarGuia 
            @IdGuia = 999,
            @DNI = '33333333', 
            @idParque = 999, 
            @idEspecialidad = 999, 
            @Nombre = 'Carlos', 
            @Apellido = NULL, -- APELLIDO NULO
            @Titulo = 'Guía Local';
            
        PRINT 'RESULTADO TEST 9: FALLÓ (El SP permitió modificar dejando el apellido nulo)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 9: PASÓ (El SP bloqueó correctamente la modificación)';
    END CATCH

-------------------------------- TEST 10 -----------------------------------------------------------------------
    PRINT ''
    PRINT '--- TEST 10: Intentar modificar dejando el Título vacío ---'
    BEGIN TRY
        EXEC Area_Excursiones.Sp_ModificarGuia 
            @IdGuia = 999,
            @DNI = '33333333', 
            @idParque = 999, 
            @idEspecialidad = 999, 
            @Nombre = 'Carlos', 
            @Apellido = 'Lopez', 
            @Titulo = ''; -- TITULO VACIO
            
        PRINT 'RESULTADO TEST 10: FALLÓ (El SP permitió modificar dejando el título vacío)';
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 10: PASÓ (El SP bloqueó correctamente la modificación)';
    END CATCH

-------------------------------- FIN DE PRUEBAS ----------------------------------------------------------------

ROLLBACK TRAN; -- 4. Deshacemos TODO para no dejar basura en la BD.
PRINT '';
PRINT 'Pruebas finalizadas. Base de datos restaurada (ROLLBACK ejecutado).';
GO