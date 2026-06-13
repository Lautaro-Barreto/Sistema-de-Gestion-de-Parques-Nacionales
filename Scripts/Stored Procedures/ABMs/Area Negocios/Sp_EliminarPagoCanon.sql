/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 12/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la eliminación de un Pago de Canon
utilizando un Store Procedure. 
*/


CREATE OR ALTER PROCEDURE Area_Negocios.SP_EliminarPagoCanon
    @IdPagoCanon INT
AS
BEGIN
    BEGIN TRY

        -- Validamos que la id ingresado exista en la Base de Datos
        DECLARE @IdPagoCanonExiste INT;
        SELECT @IdPagoCanonExiste = IdPagoCanon FROM Area_Negocios.Pago_Canon WHERE IdPagoCanon = @IdPagoCanon;
        IF @IdPagoCanonExiste IS NULL
        BEGIN
            PRINT('No existe un Pago de Canon con ese Id')
            RAISERROR('PagoCanon Inexistente',16,1)
        END
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY()>10
        BEGIN	
            RAISERROR('Algo salio mal en la eliminación del Pago de Canon',16,1);
            RETURN;
        END
    END CATCH
    DELETE FROM Area_Negocios.Pago_Canon WHERE IdPagoCanon = @IdPagoCanon;
END
GO