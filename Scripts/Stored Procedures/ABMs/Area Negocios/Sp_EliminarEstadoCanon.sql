/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 12/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la eliminación de un Estado Canon
utilizando un Store Procedure. 
*/
USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Negocios.SP_EliminarEstadoCanon
    @IdEstadoCanon INT
AS
BEGIN
    BEGIN TRY
        -- Validamos que la id ingresado exista en la Base de Datos
        DECLARE @IdEstadoCanonExiste INT;
        SELECT @IdEstadoCanonExiste = IdEstadoCanon FROM Area_Negocios.Estado_Canon WHERE IdEstadoCanon = @IdEstadoCanon;
        IF @IdEstadoCanonExiste IS NULL
        BEGIN
            PRINT('No existe un Estado de Canon con ese Id')
            RAISERROR('EstadoCanon Inexistente',16,1)
        END
        --No puede tener Canones asociados
        IF EXISTS (SELECT 1 FROM Area_Negocios.Canon WHERE IdEstado = @IdEstadoCanon)
        BEGIN
            PRINT('No existe un Estado de Canon con ese Id')
            RAISERROR('No se puede eliminar el Estado de Canon porque está siendo utilizado por registros de la tabla Canon.', 16, 1);
        END

        DELETE FROM Area_Negocios.Estado_Canon WHERE IdEstadoCanon = @IdEstadoCanon;
    END TRY
    BEGIN CATCH
            RAISERROR('Algo salio mal en la eliminacion del Estado de Canon',16,1);
            RETURN;
    END CATCH
    
END
GO