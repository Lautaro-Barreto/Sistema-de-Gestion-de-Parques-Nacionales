/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para crear una venta.
*/

USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Comercial.SP_CrearVenta
	@IdPuntoDeVenta INT,
	@IdParque INT,
	@IdFormaDePago INT,
	@Fecha DATE,
	@Total DECIMAL(13,3)
AS
BEGIN
	BEGIN TRY
		--El punto de venta debe estar cargado en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Punto_De_Venta WHERE IdPuntoDeVenta = @IdPuntoDeVenta)
        BEGIN
            PRINT('Punto de venta inexistente')
            RAISERROR('.', 16, 1)
        END

		--El parque debe estar cargado en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @IdParque)
        BEGIN
            PRINT('Parque inexistente')
            RAISERROR('.', 16, 1)
        END

		--La forma de pago debe estar cargada en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Forma_De_Pago WHERE IdFormaDePago = @IdFormaDePago)
        BEGIN
            PRINT('Forma de pago inexistente')
            RAISERROR('.', 16, 1)
        END

		--El campo fecha debe tener un valor
		IF @Fecha IS NULL
		BEGIN
            PRINT('La fecha no puede ser nula')
            RAISERROR('.', 16, 1)
        END

		--El total debe ser un numero positivo
		IF @Total < 0
			BEGIN
				PRINT('El total no es valido')
				RAISERROR('.', 16, 1)
			END
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en el registro de la venta', 16, 1);
			RETURN;
		END
	END CATCH

	INSERT INTO Area_Comercial.Venta(IdPuntoDeVenta, IdParque, IdFormaDePago, Fecha, Total) VALUES
	(@IdPuntoDeVenta, @IdParque, @IdFormaDePago, @Fecha, @Total);
	DECLARE @IdNuevaVenta INT
	SET @IdNuevaVenta = SCOPE_IDENTITY()
	RETURN @IdNuevaVenta
END
GO