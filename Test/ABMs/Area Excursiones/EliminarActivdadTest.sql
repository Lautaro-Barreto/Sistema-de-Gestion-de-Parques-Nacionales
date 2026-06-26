/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del script de pruebas (Test) para la eliminación de una actividad.
*/

USE SGParquesNacionales
GO

BEGIN TRAN; -- 1. Iniciamos la transacción de prueba

-- A. PREPARAR (Arrange)
    PRINT('======================================================')
    PRINT('--- PREPARANDO DATOS DE PRUEBA ---')
    PRINT('======================================================')
    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad ON;
    Insert into Area_Excursiones.Tipo_Actividad(IdTipoActividad, Descripcion) VALUES (999, 'Aventura Test')
    SET IDENTITY_INSERT Area_Excursiones.Tipo_Actividad OFF;

    SET IDENTITY_INSERT Area_Infraestructura.Parque ON;
    INSERT INTO Area_Infraestructura.Parque(IdParque, Nombre, Superficie) VALUES (999, 'Parque Nacional Test', 50000)
    SET IDENTITY_INSERT Area_Infraestructura.Parque OFF;
    DECLARE @NombrePrueba VARCHAR(50) = 'Trekking de Prueba 123';


    -- 2. Insertamos Actividades de prueba (Una ACTIVA y otra INACTIVA)
    SET IDENTITY_INSERT Area_Excursiones.Actividad ON;
    INSERT INTO Area_Excursiones.Actividad (IdActividad, IdTipoActividad, IdParque, Nombre, Costo, Duracion, Cupo_maximo, Activo)
    VALUES 
    (999, 999, 999, 'Actividad ACTIVA', 1500.00, 2, 10, 1),  -- Activo = 1
    (998, 999, 999, 'Actividad INACTIVA', 1500.00, 2, 10, 0); -- Activo = 0
    SET IDENTITY_INSERT Area_Excursiones.Actividad OFF;

    select * FROM Area_Excursiones.Actividad
    
    PRINT ''
    PRINT('--- TEST 1: Eliminar Actividad ---')
    BEGIN TRY
        EXEC Area_Excursiones.Sp_EliminarActividad
        @IdActividad = 999

        PRINT 'RESULTADO TEST 1: PASÓ (SP Ejecutado sin errores)'
    END TRY

    BEGIN CATCH
        PRINT 'RESULTADO TEST 1: FALLÓ - Error inesperado: '+ ERROR_MESSAGE()
    END CATCH
    select * FROM Area_Excursiones.Actividad
    PRINT ''
    PRINT('--- TEST 2: Eliminar Actividad ya eliminada ---')
    BEGIN TRY
        EXEC Area_Excursiones.Sp_EliminarActividad
        @IdActividad = 999

        PRINT 'RESULTADO TEST 2: FALLÓ (SP eliminó una actividad ya eliminada)'
    END TRY
    BEGIN CATCH
        PRINT 'Excepción controlada capturada: ' + ERROR_MESSAGE();
        PRINT 'RESULTADO TEST 2: PASÓ (El SP bloqueó correctamente la actividad Eliminada)';
    END CATCH    

ROLLBACK TRAN
