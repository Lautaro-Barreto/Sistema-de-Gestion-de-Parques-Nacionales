/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 12/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la eliminación de un Canon
utilizando un Store Procedure. 
*/


CREATE OR ALTER PROCEDURE Area_Negocios.SP_EliminarCanon
    @IdCanon INT
AS
BEGIN
    BEGIN TRY

        -- Validamos que la id canon ingresado exista en la Base de Datos
        DECLARE @IdCanonExiste INT;
        SELECT @IdCanonExiste = IdCanon FROM Area_Negocios.Canon WHERE IdCanon = @IdCanon;
        IF @IdCanonExiste IS NULL
        BEGIN
            PRINT('No existe un Canon con ese Identificador')
            RAISERROR('Canon Inexistente',16,1)
        END
        IF EXISTS (SELECT 1 FROM Area_Negocios.Pago_Canon WHERE IdCanon = @IdCanon)
        BEGIN
            PRINT('El canon ingresado tiene pagos asociados')
            RAISERROR('No se puede eliminar el Canon porque posee registros de pagos asociados.', 16, 1);
        END
         DELETE FROM Area_Negocios.Canon WHERE IdCanon = @IdCanon;
    END TRY
    BEGIN CATCH	
            RAISERROR('Algo salio mal en la eliminación del Canon',16,1);
            RETURN;
    END CATCH
   
END
GO