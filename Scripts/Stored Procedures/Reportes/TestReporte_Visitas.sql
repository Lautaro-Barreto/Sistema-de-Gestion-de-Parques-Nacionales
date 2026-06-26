/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de generar el reporte de visitas por semana, mes y año, por parque
*/
USE SGParquesNacionales
BEGIN TRANSACTION

-- ==========================================
-- 1. TABLAS MAESTRAS (Sin FKs)
-- ==========================================

-- Esquema: Area_Infraestructura
SET IDENTITY_INSERT Area_Infraestructura.Region ON;
INSERT INTO Area_Infraestructura.Region (IdRegion, Nombre) VALUES (1, 'Litoral'), (2, 'Cuyo');
SET IDENTITY_INSERT Area_Infraestructura.Region OFF;

SET IDENTITY_INSERT Area_Infraestructura.Provincia ON;
INSERT INTO Area_Infraestructura.Provincia (IdProvincia, IdRegion, Nombre) VALUES (1, 1, 'Misiones'), (2, 2, 'San Juan');
SET IDENTITY_INSERT Area_Infraestructura.Provincia OFF;

SET IDENTITY_INSERT Area_Infraestructura.Tipo_Parque ON;
INSERT INTO Area_Infraestructura.Tipo_Parque (IdTipoParque, Descripcion) VALUES (1, 'Parque Nacional');
SET IDENTITY_INSERT Area_Infraestructura.Tipo_Parque OFF;

-- Esquema: Area_Comercio
SET IDENTITY_INSERT Area_Comercial.Tipo_Visitante ON;
INSERT INTO Area_Comercial.Tipo_Visitante (IdTipoVisitante, Descripcion) VALUES (1, 'General'), (2, 'Menor');
SET IDENTITY_INSERT Area_Comercial.Tipo_Visitante OFF;

SET IDENTITY_INSERT Area_Comercial.Forma_De_Pago ON;
INSERT INTO Area_Comercial.Forma_De_Pago (IdFormaDePago, Descripcion) VALUES (1, 'Efectivo'), (2, 'Tarjeta');
SET IDENTITY_INSERT Area_Comercial.Forma_De_Pago OFF;

SET IDENTITY_INSERT Area_Comercial.Punto_De_Venta ON;
INSERT INTO Area_Comercial.Punto_De_Venta (IdPuntoDeVenta, Descripcion) VALUES (1, 'Boletería Principal');
SET IDENTITY_INSERT Area_Comercial.Punto_De_Venta OFF;

-- ==========================================
-- 2. TABLA PARQUE (Depende de Provincia y Tipo_Parque)
-- ==========================================
SET IDENTITY_INSERT Area_Infraestructura.Parque ON;
INSERT INTO Area_Infraestructura.Parque (IdParque, IdProvincia, IdTipoParque, Nombre, Superficie, Activo)
VALUES 
(1, 1, 1, 'Parque Nacional Iguazú', 67720, 1),
(2, 2, 1, 'Parque Nacional Talampaya', 215000, 1);
SET IDENTITY_INSERT Area_Infraestructura.Parque OFF;

-- ==========================================
-- 3. TABLA VENTA (Depende de Parque, Forma_De_Pago, Punto_De_Venta)
-- ==========================================
SET IDENTITY_INSERT Area_Comercial.Venta ON;
INSERT INTO Area_Comercial.Venta (IdVenta, IdPuntoDeVenta, IdParque, IdFormaDePago, Fecha, Total)
VALUES 
(1, 1, 1, 1, '2026-01-01', 5000), 
(2, 1, 1, 2, '2026-01-10', 8000), 
(3, 1, 2, 1, '2026-02-05', 3000);
SET IDENTITY_INSERT Area_Comercial.Venta OFF;

-- ==========================================
-- 4. TABLA ENTRADA (Depende de Venta, Parque, Tipo_Visitante)
-- ==========================================
SET IDENTITY_INSERT Area_Comercial.Entrada ON;
INSERT INTO Area_Comercial.Entrada (IdEntrada, IdParque, IdTipoVisitante, Precio, Fecha_Acceso) VALUES (1,  1, 1, 2500, '2026-01-05');
INSERT INTO Area_Comercial.Entrada (IdEntrada, IdParque, IdTipoVisitante, Precio, Fecha_Acceso) VALUES (2,  1, 1, 2500, '2026-01-06');
INSERT INTO Area_Comercial.Entrada (IdEntrada, IdParque, IdTipoVisitante, Precio, Fecha_Acceso) VALUES (3,  1, 1, 2600, '2026-01-12');
INSERT INTO Area_Comercial.Entrada (IdEntrada, IdParque, IdTipoVisitante, Precio, Fecha_Acceso) VALUES (4,  1, 2, 2600, '2026-01-13');
INSERT INTO Area_Comercial.Entrada (IdEntrada, IdParque, IdTipoVisitante, Precio, Fecha_Acceso) VALUES (5,  1, 1, 2800, '2026-01-14');
INSERT INTO Area_Comercial.Entrada (IdEntrada, IdParque, IdTipoVisitante, Precio, Fecha_Acceso) VALUES (6,  1, 1, 2500, '2026-02-10');
INSERT INTO Area_Comercial.Entrada (IdEntrada, IdParque, IdTipoVisitante, Precio, Fecha_Acceso) VALUES (7,  2, 1, 1500, '2026-02-11');
INSERT INTO Area_Comercial.Entrada (IdEntrada, IdParque, IdTipoVisitante, Precio, Fecha_Acceso) VALUES (8,  2, 2, 1500, '2026-02-12');
SET IDENTITY_INSERT Area_Comercial.Entrada OFF;

-- ==========================================
-- 5. TABLA DETALLE_VENTA_ENTRADA (Depende de Venta, Entrada)
-- ==========================================
SET IDENTITY_INSERT Area_Comercial.Detalle_Venta_Entrada ON;
INSERT INTO Area_Comercial.Detalle_Venta_Entrada (IdDetalle, IdVenta, IdEntrada, Subtotal, Cantidad)
VALUES
(1, 1, 1, 2500, 1),
(2, 1, 2, 2500, 1),
(3, 2, 3, 2600, 1),
(4, 2, 4, 2600, 1),
(5, 2, 5, 2800, 1),
(6, 2, 6, 2500, 1),
(7, 3, 7, 1500, 1),
(8, 3, 8, 1500, 1);
SET IDENTITY_INSERT Area_Comercial.Detalle_Venta_Entrada OFF;

    
    SELECT * FROM Area_Infraestructura.Parque

    EXEC Area_Infraestructura.Sp_ReporteVisitasParque @IdParque = 1

ROLLBACK TRANSACTION