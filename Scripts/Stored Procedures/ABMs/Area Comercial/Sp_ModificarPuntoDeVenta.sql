/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 11/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para modificar un punto de venta.
*/

USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Comercial.SP_ModificarPuntoDeVenta
	@IdPuntoDeVenta INT,
	@Descripcion INT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		--El punto de venta debe estar cargado en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Punto_De_Venta WHERE IdPuntoDeVenta = @IdPuntoDeVenta)
        BEGIN
            PRINT('Punto de venta inexistente')
            RAISERROR('.', 16, 1)
        END

		--Se valida la descripcion
		IF @Descripcion IS NOT NULL AND @Descripcion <> ''
		BEGIN
			SET @Descripcion = TRIM(@Descripcion);
			IF @Descripcion LIKE '%[^a-zA-Z ]%' OR LEN(@Descripcion) > 30
			BEGIN
				PRINT('La descripcion no es valida');
				RAISERROR('.', 16, 1);
			END

			UPDATE Area_Comercial.Punto_De_Venta
			SET Descripcion = @Descripcion
			WHERE IdPuntoDeVenta = @IdPuntoDeVenta;
		END
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en la modifiacion del punto de venta', 16, 1);
			RETURN;
		END
	END CATCH
END
GO