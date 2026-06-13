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
	@Nombre varchar(150),
	@Estado bit
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
		IF @Nombre IS NULL OR @Nombre='' OR @Nombre LIKE '%[^a-zA-ZñÑ ]%' OR LEN(@Nombre) > 80
		BEGIN
			PRINT('El Nuevo nombre de la empresa no es valido.');
			RAISERROR('EmpresaConcesionaria Invalida', 16, 1);
		END
		-- La modificacion de Nombre no puede estar repetida.
		IF EXISTS (SELECT 1 FROM Area_Negocios.Empresa_Concesionaria WHERE Nombre = @Nombre AND IdEmpresa <> @IdEmpresaConcesionaria)
        BEGIN
			-- Lanzar el error
			PRINT('La empresa ya se encuentra registrada.');
			RAISERROR('EmpresaConcesionaria Invalida', 16, 1);
		END
		-- El estado no puede ser vacio
		IF @Estado IS NULL
		BEGIN
			PRINT('No puede colocar un estado vacío')
			RAISERROR('Estado Invalido', 16, 1);
		END
			UPDATE Area_Negocios.Empresa_Concesionaria
			SET Nombre = @Nombre, Estado = @Estado
			WHERE IdEmpresa = @IdEmpresaConcesionaria; 

	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en la modificación de la Empresa', 16, 1);
			RETURN;
		END
	END CATCH
END
GO
