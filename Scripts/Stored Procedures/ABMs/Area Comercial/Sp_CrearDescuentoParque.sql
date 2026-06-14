/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para crear un descuento asociado a un parque.  
*/

USE SGParquesNacionales
GO
CREATE OR ALTER PROCEDURE Area_Comercial.Sp_CrearDescuentoParque
    @IdParque INT,
    @Descripcion VARCHAR(100),
    @Porcentaje DECIMAL(2,2)
AS
BEGIN
    BEGIN TRY

        --El parque debe estar cargado en la DB
        IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @IdParque)
        BEGIN
            PRINT('Parque inexistente')
            RAISERROR('.', 16, 1)
        END

        --La descripción no puede ser nula o vacía
		IF @Descripcion ='' OR @Descripcion LIKE '%[^a-zA-Z ]%' OR LEN(@Descripcion) > 100
		BEGIN
			PRINT('La descripción ingresada no es válida')
			RAISERROR('.', 16,1)
		END
		SET @Descripcion = TRIM(@Descripcion)

        --El porcentaje de descuento debe ser mayor a cero
        IF @Porcentaje <= 0
        BEGIN
            PRINT('Porcentaje de descuento no válido')
            RAISERROR('.', 16, 1)
        END
    END TRY

    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
        BEGIN	
            RAISERROR('Algo salió mal en la creación del descuento', 16, 1);
            RETURN;
        END
    END CATCH

    INSERT INTO Area_Comercial.Descuento_Parque(IdParque, Descripcion, Porcentaje) VALUES
    (@IdParque, @Descripcion, @Porcentaje);
END
GO
