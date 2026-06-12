/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 12/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga del Stored Procedure utilizado para crear 
un Tipo de Actividad de una Concesion.
*/
USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Negocios.SP_CrearTipoActividadConcesion
	@Descripcion varchar(150)
AS
BEGIN
	BEGIN TRY
        -- Validamos descripcion ingresada.
        IF @Descripcion ='' OR @Descripcion LIKE '%[^a-zA-Z ]%' OR LEN(@Descripcion)>100 OR @Descripcion IS NULL
        BEGIN
            PRINT('La descripcion ingresada no es valida')
            RAISERROR('Descripcion Invalida', 16,1)
        END
        -- Validamos que la descripcion no se encuentra ya registrada
        IF EXISTS (SELECT 1 FROM Area_Negocios.Tipo_Actividad_Concesion WHERE Descripcion = @Descripcion)
        BEGIN
            PRINT('La descripcion ingresada ya se encuentra registrada')
            RAISERROR('Descripcion Invalida', 16,1)
        END
    END TRY
    BEGIN CATCH
        -- Lanzamos RETURN
        IF ERROR_SEVERITY()>10
        BEGIN	
            RAISERROR('Algo salio mal en la creación del Tipo de actividad de Concesion',16,1);
            RETURN;
        END
    END CATCH
    INSERT INTO Area_Negocios.Tipo_Actividad_Concesion(Descripcion) VALUES (@Descripcion)
END
GO