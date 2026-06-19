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
		-- 2. Validar formato de la descripción
        IF @Descripcion IS NULL OR @Descripcion = '' OR LEN(@Descripcion) > 100
        BEGIN
            RAISERROR('La nueva descripción no es válida o excede el límite de caracteres.', 16, 1);
        END

        IF @Descripcion LIKE '%[^a-zA-ZñÑ ]%'
        BEGIN
			PRINT('La nueva descripción no es valida.');
            RAISERROR('La descripción contiene caracteres no permitidos (solo letras y espacios).', 16, 1);
        END

        -- 3. Validar duplicados EXCLUYENDO el registro actual
        IF EXISTS (SELECT 1 FROM Area_Negocios.Estado_Canon WHERE Descripcion = @Descripcion AND IdEstadoCanon <> @IdEstadoCanon)
        BEGIN
			PRINT('La nueva descripción se encuentra repetida y ya existe.');
            RAISERROR('Ya existe otro Estado de Canon con esa misma descripción.', 16, 1);
        END
		UPDATE Area_Negocios.Estado_Canon
        SET Descripcion = @Descripcion
        WHERE IdEstadoCanon = @IdEstadoCanon;
	END TRY
	BEGIN CATCH
        -- Lanzar Rollback
			RAISERROR('Algo salio mal en la modificación del Estado del Canon', 16, 1);
			RETURN;
	END CATCH
END
GO