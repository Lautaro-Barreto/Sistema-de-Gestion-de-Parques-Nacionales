/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 12/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga del Stored Procedure utilizado para modificar un
Tipo de actividad de concesion.
*/

USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Negocios.SP_ModificarTipoActividadConcesion
	@IdTipoActividadConcesion INT,
	@Descripcion varchar(100)
AS
BEGIN
	BEGIN TRY
		--Busca el id verificando que existe en la base de datos
		IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Tipo_Actividad_Concesion WHERE IdTipoActividadConcesion = @IdTipoActividadConcesion)
        BEGIN
            PRINT('Tipo de Actividad inexistente')
            RAISERROR('TipoActividadConcesion Inexistente', 16, 1)
        END

		-- La nueva descripcion debe ser valida
		IF @Descripcion IS NOT NULL AND @Descripcion <> '' AND @Descripcion LIKE '%[^a-zA-Z ]%' AND LEN(@Descripcion) < 100
		BEGIN
			UPDATE Area_Negocios.Tipo_Actividad_Concesion
			SET Descripcion = @Descripcion
			WHERE IdTipoActividadConcesion = @IdTipoActividadConcesion;
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
			RAISERROR('Algo salio mal en la modifiacion del Tipo De Actividad de la concesion', 16, 1);
			ROLLBACK;
		END
	END CATCH
END
GO