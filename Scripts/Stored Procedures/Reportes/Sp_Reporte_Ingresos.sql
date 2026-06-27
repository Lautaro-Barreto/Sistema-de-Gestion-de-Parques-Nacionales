/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de generar el reporte de visitas por semana, mes y año, por parque
*/
USE SGParquesNacionales
GO
CREATE OR ALTER PROCEDURE Area_Comercial.Sp_ReporteIngresos AS
BEGIN 
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
            p.Monto_Abonado -- ¡OJO ACA! Reemplazá 'Monto_Abonado' por tu columna real de dinero
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
    WHERE pq.Activo = 1 -- Solo parques activos (si aplica)
    FOR XML PATH('Parque'), ROOT('IngresosParques'), TYPE;
END
GO



