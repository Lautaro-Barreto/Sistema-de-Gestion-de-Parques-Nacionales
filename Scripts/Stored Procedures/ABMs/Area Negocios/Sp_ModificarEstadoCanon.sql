/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 12/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga del Stored Procedure utilizado para modificar un
Pago de canon.
*/

USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Negocios.SP_ModificarEstadoCanon
	@IdEstadoCanon INT,
	@Descripcion varchar(150)
AS
BEGIN
	BEGIN TRY
		--Busca el Estado Canon verificando que existe en la base de datos
		IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Estado_Canon WHERE IdEstadoCanon = @IdEstadoCanon)
        BEGIN
            PRINT('Estado Canon inexistente')
            RAISERROR('Estado Canon Inexistente', 16, 1)
        END

		-- La nueva descripcion debe ser valida
		IF @Descripcion IS NOT NULL AND @Descripcion <> '' AND @Descripcion NOT LIKE '%[^a-zA-Z ]%' AND LEN(@Descripcion) < 100
		BEGIN
			UPDATE Area_Negocios.Estado_Canon
			SET Descripcion = @Descripcion
			WHERE IdEstadoCanon = @IdEstadoCanon;
		END
        ELSE
        BEGIN
            -- Lanzar el error
			PRINT('La nueva descripción no es valida.');
			RAISERROR('Descripcion Invalida', 16, 1);
        END
	END TRY
	BEGIN CATCH
        -- Lanzar Rollback
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en la modificación del Estado del Canon', 16, 1);
			RETURN;
		END
	END CATCH
END
GO