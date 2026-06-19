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
	@Descripcion varchar(150)
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
		IF @Descripcion IS  NULL OR @Descripcion = '' OR @Descripcion LIKE '%[^a-zA-ZñÑ. ]%' OR LEN(@Descripcion) > 100
		BEGIN
			PRINT('La nueva descripción no es válida.');
			RAISERROR('Descripcion Invalida', 16, 1);
		END

		--La nueva Descripcion no puede ser una repetida
		IF EXISTS (SELECT 1 FROM Area_Negocios.Tipo_Actividad_Concesion WHERE Descripcion = @Descripcion AND IdTipoActividadConcesion <> @IdTipoActividadConcesion)
		BEGIN
			-- Lanzar el error
			PRINT('La nueva descripción ya se encuentra registrada.');
			RAISERROR('Descripcion Invalida', 16, 1);
		END
		UPDATE Area_Negocios.Tipo_Actividad_Concesion
			SET Descripcion = @Descripcion
			WHERE IdTipoActividadConcesion = @IdTipoActividadConcesion;
	END TRY
	BEGIN CATCH
        -- Lanzar return
			RAISERROR('Algo salio mal en la modificación del Tipo De Actividad de la concesion', 16, 1);
			Return;
	END CATCH
END
GO