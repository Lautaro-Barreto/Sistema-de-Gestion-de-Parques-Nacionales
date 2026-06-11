/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Trigger que actualiza el registro histórico
de trabajos de un guardaparque cuando se registra su fecha de finalización de trabajo en un determinado
parque. 
*/

-- ############################# INCOMPLETO ################################################################

USE SGParquesNacionales
GO

CREATE OR ALTER TRIGGER Area_Infraestructura.Tg_ActualizarHistorialTrabajoGuardaparque
ON Area_Infraestructura.Guardaparque
AFTER UPDATE
AS
BEGIN
    BEGIN TRY
        IF UPDATE(Fecha_Egreso)
        BEGIN
            INSERT INTO Area_Infraestructura.HistorialTrabajoGuardaparque (IdGuardaparque, IdParque, Fecha_Ingreso, Fecha_Egreso)
            SELECT g.IdGuardaparque, g.IdParque, g.Fecha_Ingreso, g.Fecha_Egreso
            FROM INSERTED g
            INNER JOIN DELETED d ON g.IdGuardaparque = d.IdGuardaparque
            WHERE d.Fecha_Egreso IS NULL AND g.Fecha_Egreso IS NOT NULL
        END
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY()>10
        BEGIN	
            RAISERROR('Algo salio mal al actualizar el historial de trabajos del guardaparque',16,1);
            RETURN;
        END
    END CATCH
END
GO