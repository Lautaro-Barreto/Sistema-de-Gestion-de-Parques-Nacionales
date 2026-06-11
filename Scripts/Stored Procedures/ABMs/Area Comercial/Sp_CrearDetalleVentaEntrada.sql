/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para crear un detalle de venta de entradas.
*/

USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Comercial.SP_CrearDetalleVentaEntrada
	@IdVenta INT,
	@IdEntrada INT,
	@Cantidad INT,
	@Subtotal DECIMAL(13,3)
AS
BEGIN
	BEGIN TRY
		--La venta debe estar cargada en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Venta WHERE IdVenta = @IdVenta)
        BEGIN
            PRINT('Venta inexistente')
            RAISERROR('.', 16, 1)
        END

		--La entrada debe estar cargada en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Entrada WHERE IdEntrada = @IdEntrada)
        BEGIN
            PRINT('Entrada inexistente')
            RAISERROR('.', 16, 1)
        END

		--La cantidad debe ser mayor a cero
		IF @Precio <= 0
			BEGIN
				PRINT('La cantidad no es valida')
				RAISERROR('.', 16, 1)
			END

		--El subtotal debe ser mayor a cero
		IF @Subtotal <= 0
			BEGIN
				PRINT('El subtotal no es valido')
				RAISERROR('.', 16, 1)
			END
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en el registro del detalle de venta de entradas', 16, 1);
			RETURN;
		END
	END CATCH

	INSERT INTO Area_Comercial.Detalle_Venta_Entrada(IdVenta, IdEntrada, Cantidad, Subtotal) VALUES
	(@IdVenta, @IdEntrada, @Cantidad, @Subtotal);
	DECLARE @IdNuevoDetalle INT
	SET @IdNuevoDetalle = SCOPE_IDENTITY()
	RETURN @IdNuevoDetalle
END
GO