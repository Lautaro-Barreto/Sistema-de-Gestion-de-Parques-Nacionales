/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para crear una forma de pago. 
*/

USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Comercial.SP_CrearFormaDePago
	@Descripcion VARCHAR(30)
AS
BEGIN
	BEGIN TRY
		--Se valida la descripcion ingresada
		IF @Descripcion = '' OR @Descripcion LIKE '%[^a-zA-Z ]%' OR LEN(@Descripcion) > 30
		BEGIN
			PRINT('La descripcion ingresada no es valida')
			RAISERROR('.', 16, 1)
		END
		SET @Descripcion = TRIM(@Descripcion)

		--La descripcion es unica
		IF EXISTS (SELECT 1 FROM Area_Comercial.Forma_De_Pago WHERE Descripcion = @Descripcion)
        BEGIN
            PRINT('Ya existe una forma de pago con esa descripcion')
            RAISERROR('.', 16, 1)
        END
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en el registro de la forma de pago', 16, 1);
			RETURN;
		END
	END CATCH

	INSERT INTO Area_Comercial.Forma_De_Pago(Descripcion) VALUES
	(@Descripcion);
	DECLARE @IdNuevaFormaDePago INT
	SET @IdNuevaFormaDePago = SCOPE_IDENTITY()
	RETURN @IdNuevaFormaDePago
END
GO