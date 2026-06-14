/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para
realiszar el borrado lógico de un parque. 
*/

USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_EliminarParque
    @IdParque INT
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        -- Validamos existencia
        IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @IdParque)
        BEGIN
            PRINT('No existe un parque con el Id proporcionado.');
            RAISERROR('', 16, 1);
            RETURN;
        END

        -- Borrado lógico del parque
        UPDATE Area_Infraestructura.Parque
        SET Activo = 0
        WHERE IdParque = @IdParque;

    END TRY

    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
        BEGIN
            RAISERROR('Ocurrió un error al eliminar el parque.', 16, 1);
            RETURN;
        END
    END CATCH
END
