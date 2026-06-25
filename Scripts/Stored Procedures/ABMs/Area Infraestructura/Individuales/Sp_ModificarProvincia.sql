/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para
modificar una provincia. 
*/

USE SGParquesNacionales
go

CREATE OR ALTER PROCEDURE Area_Infraestructura.SP_ModificarProvincia
    @IdProvincia INT,
    @Nombre VARCHAR(80) = NULL,
    @NombreRegion VARCHAR(30) = NULL
AS
BEGIN
    BEGIN TRY

        -- Validamos que la provincia exista
        IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Provincia WHERE IdProvincia = @IdProvincia)
        BEGIN
            RAISERROR('La provincia ingresada no existe', 16,1)
        END

        -- Validamos nombre ingresado. Si es valido, quitamos espacios al string
        IF @Nombre is not null AND (@Nombre ='' OR @Nombre LIKE '%[^a-zA-Z ]%' OR LEN(@Nombre) > 80)
        BEGIN
            RAISERROR('El nombre ingresado no es valido', 16,1)
            RETURN;
        END
        SET @Nombre = TRIM(@Nombre)

        -- El nombre no puede ser repetido
        SET NOCOUNT ON;
        DECLARE @IdProvinciaRepetida INT;
        SELECT @IdProvinciaRepetida = p.IdProvincia FROM Area_Infraestructura.Provincia p WHERE p.Nombre = @Nombre;
        IF @IdProvinciaRepetida IS NOT NULL
        BEGIN
            RAISERROR('Ya existe una provincia con ese nombre', 16,1)
            RETURN @IdProvinciaRepetida;
        END

        -- Validamos region ingresada. Si es valida, quitamos espacios al string
        IF @NombreRegion is not null AND (@NombreRegion = '' OR @NombreRegion LIKE '%[^a-zA-Z ]%' OR LEN(@NombreRegion) > 80)
        BEGIN
            RAISERROR('La region ingresada no es valida', 16,1)
            RETURN;
        END
        SET @NombreRegion = TRIM(@NombreRegion)

        -- La region debe existir en la bbdd
        DECLARE @IdRegion INT;
        SELECT @IdRegion = r.IdRegion FROM Area_Infraestructura.Region r WHERE r.Nombre = @NombreRegion;
        IF @IdRegion IS NULL
        BEGIN
            RAISERROR('La region ingresada no existe', 16,1)
            RETURN;
        END

        UPDATE Area_Infraestructura.Provincia SET Nombre = @Nombre, IDRegion = @IdRegion WHERE IdProvincia = @IdProvincia
    
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY()>10
        BEGIN	
            DECLARE @ErrorMessage VARCHAR(255) = ERROR_MESSAGE();
            RAISERROR('Algo salio mal en el registro de la provincia: %s', 16,1, @ErrorMessage);
            RETURN;
        END
    END CATCH
END
GO
