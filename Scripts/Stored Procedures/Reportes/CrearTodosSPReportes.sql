/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de generar el reporte de Parques y conseciones relacionadas
*/
USE SGParquesNacionales
--REPORTE VISITAS 
GO
CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_ReporteVisitas @Parque VARCHAR(80)
AS
BEGIN
    -- 1. Declarar variable para almacenar el ID del parque
    DECLARE @IdParque INT;
    -- 2. Buscar el ID del parque en base al nombre ingresado
    SELECT @IdParque = IdParque 
    FROM Area_Infraestructura.Parque 
    WHERE Nombre = @Parque AND Activo = 1;
    -- 3. Verificación: Si @IdParque es NULL, el parque no existe
    IF @IdParque IS NULL
    BEGIN
        -- Lanzamos un error personalizado y detenemos el procedimiento
        ;THROW 50000, 'Error: El nombre del parque ingresado no existe en la base de datos.', 1;
        RETURN;
    END

        SELECT p.Nombre AS PARQUE,
        YEAR(e.Fecha_Acceso) AS AÑO,
        MONTH(e.Fecha_Acceso) AS MES,
        DATEPART(WEEK, e.Fecha_Acceso) AS SEMANA,
        COUNT(e.IdEntrada) AS 'TOTAL VISITAS'
        FROM Area_Infraestructura.Parque p 
        JOIN Area_Comercial.Entrada e ON e.IdParque = p.IdParque
        WHERE p.Activo = 1 AND p.IdParque = @IdParque
        GROUP BY p.Nombre, YEAR(e.Fecha_Acceso), MONTH(e.Fecha_Acceso), DATEPART(WEEK, e.Fecha_Acceso)
        ORDER BY PARQUE, AÑO, MES, SEMANA

END 
GO

--REPORTE INGRESOS
GO
CREATE OR ALTER PROCEDURE Area_Comercial.Sp_ReporteIngresos @Parque VARCHAR(80)
AS
BEGIN 
    -- 1. Declarar variable para almacenar el ID del parque
    DECLARE @IdParque INT;

    -- 2. Buscar el ID del parque en base al nombre ingresado
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

    WITH TodosLosIngresos AS (
        -- 1. Traemos solo lo de Entradas
        SELECT 
            v.IdParque, 
            YEAR(v.Fecha) AS AÑO, MONTH(v.Fecha) AS MES, DATEPART(WEEK,v.Fecha) AS SEMANA,
            d.Cantidad AS CantidadEntradas, 
            d.Subtotal AS IngresosEntradas, 
            0 AS IngresosActividades, 
            0 AS IngresosConcesiones
        FROM Area_Comercial.Detalle_Venta_Entrada d
        INNER JOIN Area_Comercial.Venta v ON v.IdVenta = d.IdVenta

        UNION ALL

        -- 2. Traemos solo lo de Actividades
        SELECT 
            v.IdParque, 
            YEAR(v.Fecha), MONTH(v.Fecha), DATEPART(WEEK,v.Fecha),
            0, 0, 
            c.Monto, 
            0
        FROM Area_Excursiones.Contratacion_Actividad c
        INNER JOIN Area_Comercial.Venta v ON v.IdVenta = c.IdVenta

        UNION ALL

        -- 3. Traemos solo lo de Concesiones
        SELECT 
            cs.IdParque, 
            YEAR(p.Fecha_Pago), MONTH(p.Fecha_Pago), DATEPART(WEEK,p.Fecha_Pago),
            0, 0, 0, 
            p.Monto_Abonado -- 
        FROM Area_Negocios.Pago_Canon p
        INNER JOIN Area_Negocios.Canon c ON c.IdCanon = p.IdCanon
        INNER JOIN Area_Negocios.Concesion cs ON cs.IdConcesion = c.IdConcesion
    )


    -- La consulta XML
    SELECT 
        pq.Nombre AS [@Nombre], -- El parque como atributo
        (
            -- Subconsulta para agrupar los ingresos de ese parque
            SELECT 
                t.AÑO AS [@Año],
                t.MES AS [@Mes],
                t.SEMANA AS [@Semana],
                ISNULL(SUM(t.CantidadEntradas), 0) AS [TotalEntradas],
                ISNULL(SUM(t.IngresosEntradas), 0) AS [IngresosEntradas],
                ISNULL(SUM(t.IngresosActividades), 0) AS [IngresosActividades],
                ISNULL(SUM(t.IngresosConcesiones), 0) AS [IngresosConcesiones]
            FROM TodosLosIngresos t
            WHERE t.IdParque = pq.IdParque
            GROUP BY t.AÑO, t.MES, t.SEMANA
            FOR XML PATH('ReporteSemanal'), TYPE
        )
    FROM Area_Infraestructura.Parque pq
    WHERE pq.Activo = 1 AND pq.IdParque = @IdParque-- Solo parques activos
    FOR XML PATH('Parque'), ROOT('IngresosParques'), TYPE;
END
GO

--REPORTE DEUDORES

CREATE OR ALTER PROCEDURE Area_Negocios.Sp_ReporteDeudores AS
BEGIN 
    WITH MesesAtrasados AS(
    SELECT c.IdConcesion, 
    COUNT(c.IdCanon) AS [Cantidad Meses Atrasados],
    SUM(c.Monto_Mensual - ISNULL(p.MontoAbonado, 0)) AS DEUDA
    FROM Area_Negocios.Canon c

    LEFT JOIN (
        SELECT IdCanon, SUM(Monto_Abonado) AS MontoAbonado
        FROM Area_Negocios.Pago_Canon
        GROUP BY IdCanon
    ) p ON p.IdCanon = c.IdCanon

    WHERE  c.Fecha_Vencimiento < GETDATE()
    AND (p.MontoAbonado IS NULL OR p.MontoAbonado < c.Monto_Mensual)
    GROUP BY c.IdConcesion 
)

SELECT e.Nombre AS [Empresa Concesionaria], 
c.IdConcesion  AS [Id Concesión],
m.[Cantidad Meses Atrasados], 
m.DEUDA AS [Deuda Total]
FROM Area_Negocios.Empresa_Concesionaria e
JOIN Area_Negocios.Concesion c ON c.IdEmpresa = e.IdEmpresa
JOIN MesesAtrasados m ON m.IdConcesion = c.IdConcesion

END 
GO
--REPORTE MATRIZ DE VISITAS
CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_Reporte_VisitasAnuales 
    @Año INT
AS 
BEGIN 
    WITH VistasMensuales AS(
        SELECT  
        p.Nombre AS Parque,
        e.IdEntrada AS Entradas,
        MONTH(e.Fecha_Acceso) AS Mes
        FROM Area_Comercial.Entrada e
        JOIN Area_Infraestructura.Parque p ON p.IdParque = e.IdParque
        WHERE YEAR(e.Fecha_Acceso) = @Año
    )
    SELECT Parque,
    ISNULL([1], 0) AS Enero,
    ISNULL([2], 0) AS Febrero,
    ISNULL([3], 0) AS Marzo,
    ISNULL([4], 0) AS Abril,
    ISNULL([5], 0) AS Mayo,
    ISNULL([6], 0) AS Junio,
    ISNULL([7], 0) AS Julio,
    ISNULL([8], 0) AS Agosto,
    ISNULL([9], 0) AS Septiembre,
    ISNULL([10], 0) AS Octubre,
    ISNULL([11], 0) AS Noviembre,
    ISNULL([12], 0) AS Diciembre
    FROM VistasMensuales
    PIVOT(COUNT(Entradas) FOR Mes IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
    )AS pvt
END
GO

--REPORTES PARQUES Y CONSECIONES XML
CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_ReporteParquesYConcesionesXML
AS
BEGIN 
SELECT
p.IdParque AS [@Id], 
        p.Nombre AS [NombreParque],
        
        -- SUBCONSULTA CORRELACIONADA: Construye el vector anidado de concesiones
        (
            SELECT 
                c.IdConcesion AS [@IdConcesion],
                c.Fecha_Inicio AS [FechaInicio],
                c.Fecha_Fin AS [FechaFin],
                e.Nombre AS [Titular],
                ta.Descripcion AS [ServicioPrestado]
            FROM Area_Negocios.Concesion c
            INNER JOIN Area_Negocios.Empresa_Concesionaria e ON c.IdEmpresa = e.IdEmpresa
            LEFT JOIN Area_Negocios.Tipo_Actividad_Concesion ta ON c.IdTipoActividadConcesion = ta.IdTipoActividadConcesion
            WHERE c.IdParque = p.IdParque -- Relación jerárquica con el parque externo
            FOR XML PATH('Concesion'), TYPE -- Genera los nodos hijos como XML 
        ) AS [Concesiones] -- Nombre del nodo contenedor del vector

    FROM Area_Infraestructura.Parque p
    WHERE p.Activo = 1 -- Filtro de borrado lógico 
    FOR XML PATH('Parque'), ROOT('Parques'), TYPE; 
    -- 'Parque' define el nodo de cada fila, 'ROOT' envuelve todo en una etiqueta contenedora.

END 
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

GO

CREATE OR ALTER PROCEDURE Area_Comercial.Sp_HistorialVentasParque
@NombreParque VARCHAR(80)
AS
BEGIN 
    -- Evitamos mensajes de recuento de filas para optimizar el rendimiento
    SET NOCOUNT ON;

    -- 1. Declaración y búsqueda del IdParque
    DECLARE @IdParque INT;
    
    SELECT @IdParque = IdParque 
    FROM Area_Infraestructura.Parque 
    WHERE Nombre = @NombreParque AND Activo = 1; 

    -- 2. Verificación: Si el parque no existe o está dado de baja
    IF @IdParque IS NULL
    BEGIN
        ;THROW 50000, 'Error: El nombre del parque ingresado no existe en la base de datos o no se encuentra activo.', 1;
        RETURN;
    END;

    -- 3. Uso de CTE para calcular los detalles del ticket de forma agrupada
    WITH CTE_Entradas AS (
        SELECT 
            dve.IdVenta,
            SUM(dve.Cantidad) AS CantidadEntradas,
            SUM(dve.Subtotal) AS MontoTotalEntradas 
        FROM Area_Comercial.Detalle_Venta_Entrada dve
        INNER JOIN Area_Comercial.Venta v ON v.IdVenta = dve.IdVenta
        WHERE v.IdParque = @IdParque
        GROUP BY dve.IdVenta
    ),
    CTE_Actividades AS (
        SELECT 
            ca.IdVenta,
            COUNT(ca.IdContratacion) AS CantidadActividades,
            SUM(ca.Monto) AS MontoTotalActividades
        FROM Area_Excursiones.Contratacion_Actividad ca
        INNER JOIN Area_Comercial.Venta v ON v.IdVenta = ca.IdVenta
        WHERE v.IdParque = @IdParque AND ca.Activo = 1
        GROUP BY ca.IdVenta
    )

    -- 4. Consulta final: Historial de tickets cruzado con sus acumulados
    SELECT 
        p.Nombre AS [Nombre del Parque],
        v.IdVenta AS [Nro de Ticket],
        v.Fecha AS [Fecha de Venta],
        pv.Descripcion AS [Punto de Venta],
        fp.Descripcion AS [Forma de Pago],
        ISNULL(ce.CantidadEntradas, 0) AS [Entradas Vendidas],
        ISNULL(ca.CantidadActividades, 0) AS [Actividades Contratadas],
        -- Sumamos los montos de las dos CTE para obtener el total final del ticket factura
        (ISNULL(ce.MontoTotalEntradas, 0) + ISNULL(ca.MontoTotalActividades, 0)) AS [Total Facturado]
    FROM Area_Comercial.Venta v
    INNER JOIN Area_Comercial.Punto_De_Venta pv ON v.IdPuntoDeVenta = pv.IdPuntoDeVenta
    INNER JOIN Area_Comercial.Forma_De_Pago fp ON v.IdFormaDePago = fp.IdFormaDePago
    LEFT JOIN CTE_Entradas ce ON v.IdVenta = ce.IdVenta
    LEFT JOIN CTE_Actividades ca ON v.IdVenta = ca.IdVenta
    JOIN Area_Infraestructura.Parque p ON v.IdParque = p.IdParque
    WHERE v.IdParque = @IdParque
    ORDER BY v.Fecha DESC; -- Ordenamos para ver las ventas más recientes primero

END
GO