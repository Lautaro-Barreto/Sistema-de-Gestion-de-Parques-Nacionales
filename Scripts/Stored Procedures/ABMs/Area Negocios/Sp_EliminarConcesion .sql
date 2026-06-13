/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 12/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga del Stored Procedure utilizado para eliminar 
una Concesion.
*/
USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Negocios.SP_EliminarConcesion
    @IdConcesion INTEGER
AS
BEGIN
	BEGIN TRY

        -- Se verifica que la concesión exista
        IF NOT EXISTS ( SELECT 1 FROM Area_Negocios.Concesion WHERE IdConcesion = @IdConcesion)
        BEGIN
            PRINT('No Existe la concesión ingresada')
            RAISERROR('Concesión Invalida',16,1)
        END
        DELETE FROM Area_Negocios.Concesion WHERE IdConcesion=@IdConcesion

    END TRY
    BEGIN CATCH
        -- Lanzamos return
        IF ERROR_SEVERITY()>10
        BEGIN	
            RAISERROR('Algo salio mal en la eliminación de la Concesión',16,1);
            Return;
        END
    END CATCH
END
GO