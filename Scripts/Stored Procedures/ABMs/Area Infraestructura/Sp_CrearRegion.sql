/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para
crear una region. 
*/

use SGParquesNacionales
go

CREATE OR ALTER PROCEDURE Area_Infraestructura.SP_CrearRegion
    @Nombre VARCHAR(80)
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
        DECLARE @IdRegionRepetida INT;
        SELECT @IdRegionRepetida = r.IdRegion FROM Area_Infraestructura.Region r WHERE r.Nombre = @Nombre;
        IF @IdRegionRepetida IS NOT NULL
        BEGIN
            PRINT('Ya existe una region con ese nombre')
            RETURN @IdRegionRepetida;
        END
        
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY()>10
        BEGIN	
            RAISERROR('Algo salio mal en el registro de la region',16,1);
            RETURN;
        END
    END CATCH
    
    INSERT INTO Area_Infraestructura.Region(Nombre) VALUES (@Nombre)
    DECLARE @IdNuevaRegion INT
	SET @IdNuevaRegion = SCOPE_IDENTITY()
	RETURN @IdNuevaRegion
END
GO
