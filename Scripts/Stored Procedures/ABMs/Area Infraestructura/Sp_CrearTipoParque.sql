/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para
crear un tipo de parque. 
*/

use SGParquesNacionales
go

CREATE OR ALTER PROCEDURE Area_Infraestructura.SP_CrearTipoParque
    @Descripcion VARCHAR(50)
AS
BEGIN
    BEGIN TRY

        -- Validamos descripcion ingresada. Si es valida, quitamos espacios al string
        IF @Descripcion ='' OR @Descripcion LIKE '%[^a-zA-Z ]%' OR LEN(@Descripcion) > 50
        BEGIN
            PRINT('La descripcion ingresada no es valida')
            RAISERROR('.', 16,1)
        END
        SET @Descripcion = TRIM(@Descripcion)

        -- La descripcion no puede ser repetida
        SET NOCOUNT ON;
        DECLARE @IdTipoParqueRepetido INT;
        SELECT @IdTipoParqueRepetido = tp.IdTipoParque FROM Area_Infraestructura.Tipo_Parque tp WHERE tp.Descripcion = @Descripcion;
        IF @IdTipoParqueRepetido IS NOT NULL
        BEGIN
            PRINT('Ya existe un tipo de parque con esa descripcion')
            RETURN @IdTipoParqueRepetido;
        END

    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY()>10
        BEGIN	
            RAISERROR('Algo salio mal en el registro deL tipo de parque',16,1);
            RETURN;
        END
    END CATCH

    INSERT INTO Area_Infraestructura.Tipo_Parque(Descripcion) VALUES (@Descripcion)
    DECLARE @IdNuevoTipoParque INT
	SET @IdNuevoTipoParque = SCOPE_IDENTITY()
	RETURN @IdNuevoTipoParque
END
GO