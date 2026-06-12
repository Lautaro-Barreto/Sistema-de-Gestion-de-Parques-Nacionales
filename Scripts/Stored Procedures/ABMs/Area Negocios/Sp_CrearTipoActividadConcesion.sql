/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 12/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga del Stored Procedure utilizado para crear 
un Tipo de Actividad de una Concesion.
*/
CREATE OR ALTER PROCEDURE Area_Negocios.SP_CrearTipoActividadConcesion
	@Descripcion varchar(100)
AS
BEGIN
	BEGIN TRY
        -- Validamos descripcion ingresada.
        IF @Descripcion ='' OR @Descripcion NOT LIKE '%[^a-zA-Z ]%' OR LEN(@Descripcion) > 100
        BEGIN
            PRINT('La descripcion ingresada no es valido')
            RAISERROR('Descripcion Invalida', 16,1)
        END
        
    END TRY
    BEGIN CATCH
        -- Lanzamos Rollback
        IF ERROR_SEVERITY()>10
        BEGIN	
            RAISERROR('Algo salio mal en la creación del Tipo de actividad de Concesion',16,1);
            ROLLBACK;
        END
    END CATCH
    INSERT INTO Area_Negocios.Tipo_Actividad_Concesion(Descripcion) VALUES (@Descripcion)
END
GO