/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de consultar la información general y las métricas operativas de un parque específico.
*/
USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_ReporteOperativoParque
@NombreParque VARCHAR(80)
AS
BEGIN 
    -- 1. Declaración y búsqueda del IdParque
    DECLARE @IdParque INT;
    
    SELECT @IdParque = IdParque 
    FROM Area_Infraestructura.Parque 
    WHERE Nombre = @NombreParque AND Activo = 1;

    -- 2. Verificación: Si @IdParque es NULL, el parque no existe o fue dado de baja lógica
    IF @IdParque IS NULL
    BEGIN
        -- Lanzamos un error personalizado y detenemos el procedimiento
        ;THROW 50000, 'Error: El nombre del parque ingresado no existe en la base de datos o no se encuentra activo.', 1;
        RETURN;
    END;

    -- 3. Uso de CTE para calcular métricas operativas de forma aislada
    WITH CTE_Actividades AS (
        SELECT IdParque, COUNT(IdActividad) AS ActividadesDisponibles
        FROM Area_Excursiones.Actividad
        WHERE Activo = 1 AND IdParque = @IdParque
        GROUP BY IdParque
    ),
    CTE_Guardaparques AS (
        SELECT IdParque, COUNT(IdGuardaparque) AS GuardaparquesActivos
        FROM Area_Infraestructura.Guardaparque 
        WHERE Activo = 1 AND IdParque = @IdParque
        GROUP BY IdParque
    )

    -- 4. Consulta final: Cruzamos la info estática del parque con las métricas de los CTE
    SELECT 
        p.Nombre AS [Nombre del Parque],
        p.Superficie AS [Superficie (Hectáreas)],
        tp.Descripcion AS [Tipo de Parque],
        prov.Nombre AS [Provincia],
        r.Nombre AS [Región],

        -- Usamos ISNULL para que muestre 0 en lugar de NULL si no hay registros en los CTE
        ISNULL(ca.ActividadesDisponibles, 0) AS [Total Actividades Disponibles],
        ISNULL(cg.GuardaparquesActivos, 0) AS [Total Guardaparques Activos]
    FROM Area_Infraestructura.Parque p
    INNER JOIN Area_Infraestructura.Tipo_Parque tp ON p.IdTipoParque = tp.IdTipoParque
    
    INNER JOIN Area_Infraestructura.Provincia prov ON p.IdProvincia = prov.IdProvincia 
    JOIN Area_Infraestructura.Region r ON prov.IdRegion = r.IdRegion
    LEFT JOIN CTE_Actividades ca ON ca.IdParque = p.IdParque
    LEFT JOIN CTE_Guardaparques cg ON cg.IdParque = p.IdParque
    WHERE p.IdParque = @IdParque;

END