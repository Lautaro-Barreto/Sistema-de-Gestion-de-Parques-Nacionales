/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 22/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de crear un store procedure para que los guardaparques
puedan consultar los datos de su parque.
*/

USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Infraestructura.SP_ConsultarDatosParque_Guardaparque
    @NombreParque varchar(50)
AS
BEGIN
    BEGIN TRY
        --Buscar para este Guardaparque el parque que quiere ver
        --y comprobar que está asociado al mismo.
        DECLARE @IdParque INT;
        SELECT @IdParque = IdParque FROM Area_Infraestructura.Parque WHERE Nombre = @NombreParque
        IF @IdParque IS NULL
        BEGIN
            PRINT 'No se encontró el parque a acceder.'
            RAISERROR('La operación no se pudo completar: Parque inexistente',16,1);
        END
        --Ahora fijarnos que el guardaparque esté asociado al parque
        IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Guardaparque WHERE IdParque = @IdParque 
                        AND (IS_ROLEMEMBER('Rol_Guardaparque_Base') = 1 OR 
                        IS_ROLEMEMBER('Rol_Jefe_Guardaparques') = 1))
        BEGIN   
                PRINT 'Permiso Denegado: No puede acceder a ver la información del parque.'
                RAISERROR('La operación no se pudo completar: Permiso denegado',16,1);
        END
        SELECT 
            *
        FROM Area_Infraestructura.Parque
        WHERE IdParque = @IdParque;

        PRINT '#Viendo: Información del parque';
    END TRY
    BEGIN CATCH
        RAISERROR('Algo salió mal en la operación: No se pudo mostrar la información del parque', 16, 1);
    END CATCH
END
GO