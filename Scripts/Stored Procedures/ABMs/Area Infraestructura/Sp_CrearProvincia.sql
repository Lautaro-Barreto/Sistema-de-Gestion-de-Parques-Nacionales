/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para
crear una provincia. 
*/
USE SGParquesNacionales
go
CREATE OR ALTER PROCEDURE Area_Infraestructura.SP_CrearProvincia
    @Nombre VARCHAR(80),
    @NombreRegion VARCHAR(30)
AS
BEGIN
    BEGIN TRY
        -- Validamos nombre ingresado. Si es valido, quitamos espacios al string
        IF @Nombre ='' OR @Nombre LIKE '%[^a-zA-Z ]%' OR LEN(@Nombre) > 80
        BEGIN
            PRINT('El nombre ingresado no es valido')
            RAISERROR('.', 16,1)
        END
        SET @Nombre = TRIM(@Nombre)

        -- El nombre no puede ser repetido
        SET NOCOUNT ON;
        DECLARE @IdProvinciaRepetida INT;
        SELECT @IdProvinciaRepetida = p.IdProvincia FROM Area_Infraestructura.Provincia p WHERE p.Nombre = @Nombre;
        IF @IdProvinciaRepetida IS NOT NULL
        BEGIN
            PRINT('Ya existe una provincia con ese nombre')
            RETURN @IdProvinciaRepetida;
        END

        -- Validamos region ingresada. Si es valida, quitamos espacios al string
        IF @NombreRegion = '' OR @NombreRegion LIKE '%[^a-zA-Z ]%' OR LEN(@NombreRegion) > 80
        BEGIN
            PRINT('La region ingresada no es valida')
            RAISERROR('.', 16,1)
        END
        SET @NombreRegion = TRIM(@NombreRegion)

        -- La region debe existir en la bbdd
        DECLARE @IdRegion INT;
        SELECT @IdRegion = r.IdRegion FROM Area_Infraestructura.Region r WHERE r.Nombre = @NombreRegion;
        IF @IdRegion IS NULL
        BEGIN
            PRINT('La region ingresada no existe')
            RAISERROR('.', 16,1)
        END
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY()>10
        BEGIN	
            RAISERROR('Algo salio mal en el registro de la provincia',16,1);
            RETURN;
        END
    END CATCH
    
    INSERT INTO Area_Infraestructura.Provincia(Nombre, IDRegion) VALUES (@Nombre, @IdRegion)
    DECLARE @IdNuevaProvincia INT
	SET @IdNuevaProvincia = SCOPE_IDENTITY()
	RETURN @IdNuevaProvincia
END
GO
