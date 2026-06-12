/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 12/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la eliminación de una Empresa Concesionaria
utilizando un Store Procedure. 
*/
USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Negocios.SP_EliminarEmpresaConcesionaria
    @IdEmpresa INT
AS
BEGIN
    BEGIN TRY
        -- Validamos que la id ingresado exista en la Base de Datos
        --Validamos que la empresa si este actualmente activa
        DECLARE @IdEmpresaExiste INT;
        SELECT @IdEmpresaExiste = IdEmpresa FROM Area_Negocios.Empresa_Concesionaria WHERE IdEmpresa = @IdEmpresa AND Estado = 1;
        IF @IdEmpresaExiste IS NULL
        BEGIN
            PRINT('No existe una Empresa Concesionaria activa con ese Id')
            RAISERROR('Empresa Inexistente',16,1)
        END
        
        UPDATE Area_Negocios.Empresa_Concesionaria SET Estado = 0 WHERE IdEmpresa = @IdEmpresa
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY()>10
        BEGIN	
            RAISERROR('Algo salio mal en la eliminacion del guardaparque',16,1);
            RETURN;
        END
    END CATCH
    --DELETE FROM Area_Negocios.Empresa_Concesionaria WHERE IdEmpresa = @IdEmpresa;
    
END
GO