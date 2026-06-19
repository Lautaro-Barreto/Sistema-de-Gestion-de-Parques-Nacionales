/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 12/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación de una Empresa Concesionaria mediante
un Store Procedure. 
*/

USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Negocios.SP_CrearEmpresaConcesionaria
	@Nombre varchar(150)
AS
BEGIN
	BEGIN TRY
        -- Validamos nombre ingresado.
        IF  @Nombre IS NULL OR @Nombre ='' OR NOT @Nombre NOT LIKE '%[^a-zA-ZñÑ ]%' OR LEN(@Nombre) > 80 
        BEGIN
            PRINT('El nombre de la empresa ingresado no es valido')
            RAISERROR('Nombre Invalido', 16,1)
        END
        -- Se busca que el nombre no sea repetido
        DECLARE @IdNombreEmpresaRepe INT;
        SELECT @IdNombreEmpresaRepe = IdEmpresa FROM Area_Negocios.Empresa_Concesionaria WHERE Nombre = @Nombre;
        IF @IdNombreEmpresaRepe IS NOT NULL
        BEGIN
            PRINT('Ya existe una empresa con ese nombre')
            RAISERROR('Nombre Invalido',16,1)
        END
        INSERT INTO Area_Negocios.Empresa_Concesionaria(Nombre, Estado) VALUES (@Nombre, 1)
    END TRY
    BEGIN CATCH
        -- Lanzamos Rollback
            RAISERROR('Algo salio mal en el registro del nombre de la empresa',16,1);
            RETURN;
    END CATCH
    
END
GO
