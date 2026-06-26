/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripci�n: Este script se encarga de la creaci�n del Stored Procedure utilizado para crear una entrada.
*/

USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Comercial.SP_CrearEntrada
	@IdParque INT,
	@IdTipoVisitante INT,
	@Precio DECIMAL(13,3),
	@Fecha_Acceso DATE
AS
BEGIN
	BEGIN TRY

		--El parque debe estar cargado en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @IdParque)
        BEGIN
            PRINT('Parque inexistente')
            RAISERROR('.', 16, 1)
        END

		--El tipo de visitante debe estar cargado en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Tipo_Visitante WHERE IdTipoVisitante = @IdTipoVisitante)
        BEGIN
            PRINT('Tipo de visitante inexistente')
            RAISERROR('.', 16, 1)
        END

		--El campo fecha de acceso debe tener un valor
		IF @Fecha_Acceso IS NULL
		BEGIN
            PRINT('La fecha de acceso no puede ser nula')
            RAISERROR('.', 16, 1)
        END

		--El precio debe ser mayor a cero
		IF @Precio <= 0
			BEGIN
				PRINT('El total no es valido')
				RAISERROR('.', 16, 1)
			END
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en el registro de la entrada', 16, 1);
			RETURN;
		END
	END CATCH

	INSERT INTO Area_Comercial.Entrada( IdParque, IdTipoVisitante, Precio, Fecha_Acceso) VALUES
	( @IdParque, @IdTipoVisitante, @Precio, @Fecha_Acceso);
	DECLARE @IdNuevaEntrada INT
	SET @IdNuevaEntrada = SCOPE_IDENTITY()
	RETURN @IdNuevaEntrada
END
GO