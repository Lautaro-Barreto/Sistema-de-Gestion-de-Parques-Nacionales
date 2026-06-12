/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 12/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga del Stored Procedure utilizado para modificar una 
Empresa Concesionaria.
*/

USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Negocios.SP_ModificarEmpresaConcesionaria
	@IdEmpresaConcesionaria INT,
	@Nombre varchar(80)
AS
BEGIN
	BEGIN TRY

		--Busca la Empresa Concesionaria en la base de datos
		IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Empresa_Concesionaria WHERE IdEmpresa = @IdEmpresaConcesionaria)
        BEGIN
            PRINT('Empresa Concesionaria inexistente')
            RAISERROR('Empresa Inexistente', 16, 1)
        END

		-- El nuevo nombre debe ser valido
		IF @Nombre IS NOT NULL AND @Nombre <> '' AND @Nombre LIKE '%[^a-zA-Z ]%' AND LEN(@Nombre) < 80
		BEGIN
			UPDATE Area_Negocios.Empresa_Concesionaria
			SET Nombre = @Nombre
			WHERE IdEmpresa = @IdEmpresaConcesionaria;
		END
        ELSE
        BEGIN
            -- Lanzar el error
			PRINT('El Nuevo nombre de la empresa no es valido.');
			RAISERROR('.', 16, 1);
        END
	END TRY
	BEGIN CATCH
        -- Lanzar Rollback
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en la modifiacion de la forma de pago', 16, 1);
			ROLLBACK;
		END
	END CATCH
END
GO