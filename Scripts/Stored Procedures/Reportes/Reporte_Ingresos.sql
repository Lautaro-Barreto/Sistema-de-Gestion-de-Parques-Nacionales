/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de generar el reporte de visitas por semana, mes y año, por parque
*/
USE SGParquesNacionales
GO
WITH IngresosEntradas AS(
    SELECT v.IdParque,
    YEAR(v.Fecha) AS AÑO,
    MONTH(v.Fecha) AS MES,
    DATEPART(WEEK,v.Fecha) AS SEMANA,
    SUM(Cantidad) AS [Cantidad Entradas],
    SUM(Subtotal) AS [Ingresos Entradas]
    FROM Area_Comercial.Detalle_Venta_Entrada d
    JOIN Area_Comercial.Venta v ON v.IdVenta = d.IdVenta
    GROUP BY v.IdParque, YEAR(v.Fecha), MONTH(v.Fecha), DATEPART(WEEK,v.Fecha)
),

IngresosActividades AS(
    SELECT  
    v.IdParque,
    YEAR(v.Fecha) AS AÑO,
    MONTH(v.Fecha) AS MES,
    DATEPART(WEEK,v.Fecha) AS SEMANA,
    SUM(c.Monto) AS [Ingresos Actividades]
    FROM Area_Excursiones.Contratacion_Actividad c
    JOIN Area_Comercial.Venta v ON v.IdVenta = c.IdVenta
    GROUP BY v.IdParque, YEAR(v.Fecha), MONTH(v.Fecha), DATEPART(WEEK,v.Fecha)
),

IngresosConceciones AS(
    SELECT 
    cs.IdParque,
    YEAR(p.Fecha_Pago) AS AÑO,
    MONTH(p.Fecha_Pago) AS MES,
    DATEPART(WEEK,p.Fecha_Pago) AS SEMANA,
    SUM(p.IdPagoCanon) AS [Ingresos Concesiones]

    FROM Area_Negocios.Pago_Canon p
    JOIN Area_Negocios.Canon c ON c.IdCanon = p.IdCanon
    JOIN Area_Negocios.Concesion cs ON cs.IdConcesion = c.IdConcesion
    GROUP BY cs.IdParque, YEAR(p.Fecha_Pago), MONTH(p.Fecha_Pago), DATEPART(WEEK,p.Fecha_Pago)
)

SELECT p.Nombre AS Parque,
COALESCE(e.AÑO, a.AÑO,c.AÑO) AS AÑO,
COALESCE(e.MES, a.MES, c.MES) AS MES,
COALESCE(e.SEMANA, a.SEMANA, c.SEMANA) AS SEMANA,
ISNULL(e.[Cantidad Entradas], 0) AS [Total Entradas],
ISNULL(e.[Ingresos Entradas], 0) AS [Ingesos Entradas],
ISNULL(a.[Ingresos Actividades], 0) AS[Ingesos Actividades],
ISNULL(c.[Ingresos Concesiones], 0) AS [Ingesos Concesiones]
FROM Area_Infraestructura.Parque p
FULL JOIN IngresosEntradas e ON e.IdParque = p.IdParque
FULL JOIN IngresosActividades a ON a.IdParque = p.IdParque
FULL JOIN IngresosConceciones c ON c.IdParque = p.IdParque