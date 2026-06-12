/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 12/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga del Stored Procedure utilizado para crear 
un Estado del canon.
*/
CREATE OR ALTER PROCEDURE Area_Negocios.SP_CrearEstadoCanon
	@Descripcion varchar(100)
AS
BEGIN
	BEGIN TRY
        -- Validamos descripcion ingresada.
        IF @Descripcion ='' OR NOT REGEXP_LIKE(@Descripcion,'^[a-zA-ZñÑ\s]+$')  OR LEN(@Descripcion) > 100
        BEGIN
            PRINT('La descripcion ingresada no es valida')
            RAISERROR('Descripcion Invalida', 16,1)
        END
   
    END TRY
    BEGIN CATCH
        -- Lanzamos Return
        IF ERROR_SEVERITY()>10
        BEGIN	
            RAISERROR('Algo salio mal en la creación del estado del canon',16,1);
            RETURN;
        END
    END CATCH
     INSERT INTO Area_Negocios.Estado_Canon(Descripcion) VALUES (@Descripcion)  
END
GO

--Crear estado canon
