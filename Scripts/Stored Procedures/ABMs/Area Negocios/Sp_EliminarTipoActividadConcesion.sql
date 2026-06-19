/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 12/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la eliminación de un Tipo Actividad Concesion
utilizando un Store Procedure. 
*/


CREATE OR ALTER PROCEDURE Area_Negocios.SP_EliminarTipoActividadConcesion
    @IdTipoActividadConcesion INT
AS
BEGIN
    BEGIN TRY
        -- Validamos que la id ingresado exista en la Base de Datos
        DECLARE @IdTipoActividadConcesionExiste INT;
        SELECT @IdTipoActividadConcesionExiste = IdTipoActividadConcesion FROM Area_Negocios.Tipo_Actividad_Concesion WHERE IdTipoActividadConcesion = @IdTipoActividadConcesion;
        IF @IdTipoActividadConcesionExiste IS NULL
        BEGIN
            PRINT('No existe un Tipo de Actividad con ese Id')
            RAISERROR('TipoActividadConcesion Inexistente',16,1)
        END
        --Reviso que la la actividad no se asocie a concesiones
        IF EXISTS (SELECT 1 FROM Area_Negocios.Concesion WHERE IdTipoActividadConcesion = @IdTipoActividadConcesion)
        BEGIN
            PRINT('No existe un Tipo de Actividad con ese Id')
            RAISERROR('No se puede eliminar el Tipo de Actividad debido a que existen concesiones vigentes que dependen de él.', 16, 1);
        END
        DELETE FROM Area_Negocios.Tipo_Actividad_Concesion WHERE IdTipoActividadConcesion = @IdTipoActividadConcesion;
    END TRY
    BEGIN CATCH
            RAISERROR('Algo salio mal en la eliminación del Tipo de Actividad Concesion',16,1);
            RETURN;
    END CATCH
    
END
GO