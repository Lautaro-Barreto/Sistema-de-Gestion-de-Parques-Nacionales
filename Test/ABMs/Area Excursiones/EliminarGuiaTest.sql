/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 23/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de testear la eliminación de un Guía y sus dependencias, 
#             utilizando el enfoque de Aislamiento por Test para evitar colisiones de transacciones.
*/

USE SGParquesNacionales
GO

PRINT('======================================================')
PRINT('--- INICIANDO BATERÍA DE PRUEBAS: Sp_EliminarGuia ---')
PRINT('======================================================')

-------------------------------------------------------------------------
-- TEST 1: Eliminar Guía y sus dependencias exitosamente
-------------------------------------------------------------------------
PRINT ''
PRINT '--- TEST 1: Eliminar Guía y sus dependencias ---'
BEGIN TRAN; -- Abrimos transacción SOLO para el Test 1

    -- 1. ARRANGE: Insertamos todos los datos necesarios para probar la eliminación
    SET IDENTITY_INSERT Area_Infraestructura.Parque ON;
    INSERT INTO Area_Infraestructura.Parque(IdParque, Nombre, Superficie) 
    VALUES (999, 'Parque Nacional Test', 50000);
    SET IDENTITY_INSERT Area_Infraestructura.Parque OFF;

    SET IDENTITY_INSERT Area_Excursiones.Especialidad ON;
    INSERT INTO Area_Excursiones.Especialidad(IdEspecialidad, Descripcion) 
    VALUES (999, 'Especialidad Test');
    SET IDENTITY_INSERT Area_Excursiones.Especialidad OFF;

    SET IDENTITY_INSERT Area_Excursiones.Guia ON;
    INSERT INTO Area_Excursiones.Guia (IdGuia, DNI, IdParque, IdEspecialidad, Nombre, Apellido, Titulo)
    VALUES (999, '12345678', 999, 999, 'Guia', 'Test', 'Guia Experto');
    SET IDENTITY_INSERT Area_Excursiones.Guia OFF;

    -- Dependencias extras para probar la eliminación en cascada
    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad ON;
    INSERT INTO Area_Excursiones.Tipo_Actividad(IdTipoActividad, Descripcion) 
    VALUES (999, 'Aventura Test');
    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad OFF;

    SET IDENTITY_INSERT Area_Excursiones.Actividad ON;
    INSERT INTO Area_Excursiones.Actividad(IdActividad, IdTipoActividad, IdParque, Nombre, Costo, Duracion, Cupo_maximo, Activo) 
    VALUES (999, 999, 999, 'Actividad Test Guia', 1500, 2, 10, 1);
    SET IDENTITY_INSERT Area_Excursiones.Actividad OFF;

    SET IDENTITY_INSERT Area_Excursiones.Habilitacion ON;
    INSERT INTO Area_Excursiones.Habilitacion(IdHabilitaciones, Descripcion) VALUES (999, 'Habilitación Test');
    SET IDENTITY_INSERT Area_Excursiones.Habilitacion OFF;

    -- Asociamos el Guía con la Actividad y la Habilitación
    INSERT INTO Area_Excursiones.Guias_por_actividad (IdGuia, IdActividad) 
    VALUES (999, 999);
    INSERT INTO Area_Excursiones.Habilitacion_Guia (IdGuia, IdHabilitacion) 
    VALUES (999, 999);

    SELECT * FROM Area_Excursiones.Guia 
    -- 2. ACT & ASSERT
    BEGIN TRY
        EXEC Area_Excursiones.Sp_EliminarGuia @IdGuia = 999;

        PRINT 'RESULTADO TEST 1: PASÓ (SP Ejecutado sin errores)'
        
        -- Verificación adicional de que ya no existe en la base
        IF NOT EXISTS(SELECT 1 FROM Area_Excursiones.Guia WHERE IdGuia = 999) 
        BEGIN
            PRINT '-> ÉXITO: El guía y sus dependencias fueron eliminados correctamente.'
        END
    END TRY
    BEGIN CATCH
        PRINT 'RESULTADO TEST 1: FALLÓ - Error inesperado: '+ ERROR_MESSAGE()
    END CATCH

    SELECT * FROM Area_Excursiones.Guia 
-- 3. TEARDOWN: Limpiamos este test
IF @@TRANCOUNT > 0 ROLLBACK TRAN; 


-------------------------------------------------------------------------
-- TEST 2: Eliminar Guía Inexistente
-------------------------------------------------------------------------
PRINT ''
PRINT '--- TEST 2: Intentar Eliminar un Guía Inexistente ---'
BEGIN TRAN; -- Abrimos una NUEVA transacción SOLO para el Test 2

    -- 1. ARRANGE: No insertamos ningún guía para forzar el error.

    -- 2. ACT & ASSERT
    BEGIN TRY
        EXEC Area_Excursiones.Sp_EliminarGuia @IdGuia = 999;

        PRINT 'RESULTADO TEST 2: FALLÓ (El SP permitió eliminar un guía inexistente)'
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 2: PASÓ (El SP bloqueó correctamente la eliminación y lanzó el error)';
    END CATCH

-- 3. TEARDOWN: Limpiamos este test.
-- Si el SP falló, ya hizo su propio ROLLBACK, por lo que @@TRANCOUNT será 0.
-- El IF previene que el motor intente hacer rollback de algo que ya no existe (evitando tu error rojo).
IF @@TRANCOUNT > 0 ROLLBACK TRAN; 

PRINT ''
PRINT('======================================================')
PRINT('--- FIN DE LA BATERÍA DE PRUEBAS ---')
PRINT('======================================================')
GO