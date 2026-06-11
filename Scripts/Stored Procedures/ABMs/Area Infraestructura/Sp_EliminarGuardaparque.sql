/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para
eliminar un guardaparque. 
*/

use SGParquesNacionales
go

CREATE OR ALTER PROCEDURE Area_Infraestructura.SP_EliminarGuardaparque
    @IdGuardaparque INT
AS
BEGIN
    BEGIN TRY

        -- Validamos que el IdGuardaparque ingresado exista en la BBDD
        SET NOCOUNT ON;
        DECLARE @IdGuardaparqueExistente INT;
        SELECT @IdGuardaparqueExistente = g.IdGuardaparque FROM Area_Infraestructura.Guardaparque g WHERE g.IdGuardaparque = @IdGuardaparque;
        IF @IdGuardaparqueExistente IS NULL
        BEGIN
            PRINT('No existe un guardaparque con ese Id')
            RETURN;
        END

    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY()>10
        BEGIN	
            RAISERROR('Algo salio mal en la eliminacion del guardaparque',16,1);
            RETURN;
        END
    END CATCH
    DELETE FROM Area_Infraestructura.HistorialTrabajoGuardaparque WHERE IdGuardaparque = @IdGuardaparque;
    DELETE FROM Area_Infraestructura.Guardaparque WHERE IdGuardaparque = @IdGuardaparque;
END
GO