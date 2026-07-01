/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 01/07/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de consultar el historial completo de ventas (tickets) de un parque específico, detallando la cantidad y montos de entradas y actividades.
*/
USE SGParquesNacionales
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