/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para modificar un descuento asociado a un parque.  
*/

USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Comercial.Sp_ModificarDescuentoParque
    @IdDescuento INT,
    @Descripcion VARCHAR(100) = NULL,
    @Porcentaje DECIMAL(2,2) = NULL
AS
BEGIN
    BEGIN TRY

        --El descuento debe estar cargado en la DB
        IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Descuento_Parque WHERE IdDescuento = @IdDescuento)
        BEGIN
            PRINT('Descuento inexistente')
            RAISERROR('.', 16, 1)
        END

        --La descripción debe ser válida si se proporciona
        IF @Descripcion IS NOT NULL AND (@Descripcion ='' OR @Descripcion LIKE '%[^a-zA-Z ]%' OR LEN(@Descripcion) > 100)
        BEGIN
            PRINT('La descripción ingresada no es válida')
            RAISERROR('.', 16,1)
        END
        SET @Descripcion = TRIM(@Descripcion)

        --El porcentaje de descuento debe ser mayor a cero
        IF @Porcentaje IS NOT NULL AND @Porcentaje <= 0
        BEGIN
            PRINT('Porcentaje de descuento no válido')
            RAISERROR('.', 16, 1)
        END
    END TRY

    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
        BEGIN	
            RAISERROR('Algo salió mal en la modificación del descuento', 16, 1);
            RETURN;
        END
    END CATCH

    UPDATE Area_Comercial.Descuento_Parque
    SET 
    Descripcion = @Descripcion,
    Porcentaje = @Porcentaje
    WHERE IdDescuento = @IdDescuento;
END
GO