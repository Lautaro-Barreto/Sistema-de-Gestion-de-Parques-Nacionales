/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de generar el reporte del ranking de las actividades mas demandadas por parque
*/
USE SGParquesNacionales
GO
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_ReporteRankingActividades
@NombreParque VARCHAR(80)
AS
BEGIN 
    DECLARE @Parque VARCHAR(80) = @NombreParque;
    DECLARE @IdParque INT;
    SELECT @IdParque = IdParque 
    FROM Area_Infraestructura.Parque 
    WHERE Nombre = @Parque AND Activo = 1;

    -- 3. Verificación: Si @IdParque es NULL, el parque no existe
    IF @IdParque IS NULL
    BEGIN
        -- Lanzamos un error personalizado y detenemos el procedimiento
        ;THROW 50000, 'Error: El nombre del parque ingresado no existe en la base de datos.', 1;
        RETURN;
    END;

    WITH DemandaActividades AS(
        SELECT 
        v.IdParque AS Parque,
        c.IdActividad AS Actividad, 
        COUNT(c.IdContratacion) as Demanda
        FROM Area_Excursiones.Contratacion_Actividad c
        JOIN Area_Comercial.Venta v ON v.IdVenta = c.IdVenta
        WHERE c.Activo = 1 AND v.IdParque = @IdParque
        GROUP BY v.IdParque, c.IdActividad
    )

    SELECT P.Nombre AS [Nombre Parque], a.Nombre AS [Actividad], d.Demanda AS [Cantidad de Contrataciones], 
    RANK() OVER (PARTITION BY d.Parque ORDER BY d.Demanda DESC) AS [Ranking]
    FROM Area_Infraestructura.Parque p
    JOIN DemandaActividades d ON d.Parque = p.IdParque
    JOIN Area_Excursiones.Actividad a ON a.IdActividad = d.Actividad
    WHERE p.IdParque = @IdParque

END