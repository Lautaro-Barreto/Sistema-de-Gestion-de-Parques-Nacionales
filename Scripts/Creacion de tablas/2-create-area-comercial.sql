-- =============================================
--                ÁREA COMERCIAL
-- =============================================

/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: En este script se crea el esquema Area_Comercial y sus respectivas tablas.
*/

USE SGParquesNacionales
GO

--1. Creación del esquema "Area_Comercial"
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Area_Comercial')
BEGIN
    EXEC('CREATE SCHEMA Area_Comercial')
END
GO

--2. Creación de la tabla "Punto_De_Venta"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Area_Comercial' AND TABLE_NAME = 'Punto_De_Venta')
BEGIN
    CREATE TABLE Area_Comercial.Punto_De_Venta(
        IdPuntoDeVenta SMALLINT IDENTITY(1,1) PRIMARY KEY,
        Descripcion VARCHAR(100)
    )
END
GO

--3. Creación de la tabla "Forma_De_Pago"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Area_Comercial' AND TABLE_NAME = 'Forma_De_Pago')
BEGIN
    CREATE TABLE Area_Comercial.Forma_De_Pago(
        IdFormaDePago TINYINT IDENTITY(1,1) PRIMARY KEY,
        Descripcion VARCHAR(100)
    )
END
GO

--4. Creación de la tabla "Venta"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Area_Comercial' AND TABLE_NAME = 'Venta')
BEGIN
    CREATE TABLE Area_Comercial.Venta(
        IdVenta INT IDENTITY(1,1) PRIMARY KEY,
        IdPuntoDeVenta SMALLINT,
        IdParque INT,
        IdFormaDePago TINYINT,
        Fecha DATE,
        Total DECIMAL(10,2),

        FOREIGN KEY (IdPuntoDeVenta) REFERENCES Area_Comercial.Punto_De_Venta(IdPuntoDeVenta),
        FOREIGN KEY (IdParque) REFERENCES Area_Infraestructura.Parque(IdParque),
        FOREIGN KEY (IdFormaDePago) REFERENCES Area_Comercial.Forma_De_Pago(IdFormaDePago)
    )
END
GO

--5. Creación de la tabla "Tipo_Visitante"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Area_Comercial' AND TABLE_NAME = 'Tipo_Visitante')
BEGIN
    CREATE TABLE Area_Comercial.Tipo_Visitante(
        IdTipoVisitante TINYINT IDENTITY(1,1) PRIMARY KEY,
        Descripcion VARCHAR(100)
    )
END
GO

--6. Creación de la tabla "Entrada"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Area_Comercial' AND TABLE_NAME = 'Entrada')
BEGIN
    CREATE TABLE Area_Comercial.Entrada(
        IdEntrada INT IDENTITY(1,1) PRIMARY KEY,
        IdParque INT,
        IdTipoVisitante TINYINT,
        Precio DECIMAL(10,2),
        Fecha_Acceso DATE,

        FOREIGN KEY (IdParque) REFERENCES Area_Infraestructura.Parque(IdParque),
        FOREIGN KEY (IdTipoVisitante) REFERENCES Area_Comercial.Tipo_Visitante(IdTipoVisitante)
    )
END
GO

--7. Creación de la tabla "Detalle_Venta_Entrada"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Area_Comercial' AND TABLE_NAME = 'Detalle_Venta_Entrada')
BEGIN
    CREATE TABLE Area_Comercial.Detalle_Venta_Entrada(
        IdDetalle INT Identity(1,1) PRIMARY KEY,
        IdVenta INT,
        IdEntrada INT,
        Cantidad INT,
        Subtotal DECIMAL(10,2),

        FOREIGN KEY (IdVenta) REFERENCES Area_Comercial.Venta(IdVenta),
        FOREIGN KEY (IdEntrada) REFERENCES Area_Comercial.Entrada(IdEntrada)
    )
END
GO

-- 8. Creación de la tabla "Precio_Parque_Tipo_Visitante"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Area_Comercial' AND TABLE_NAME = 'Precio_Parque_Tipo_Visitante')
BEGIN
    CREATE TABLE Area_Comercial.Precio_Parque_Tipo_Visitante(
        IdPrecioParqueTipoVis SMALLINT IDENTITY(1,1) PRIMARY KEY,
        IdParque INT, 
        IdTipoVisitante TINYINT, 
        Precio DECIMAL(10,2), 

        FOREIGN KEY (IdParque) REFERENCES Area_Infraestructura.Parque(IdParque),
        FOREIGN KEY (IdTipoVisitante) REFERENCES Area_Comercial.Tipo_Visitante(IdTipoVisitante)
    )
END
GO

--9. Creación de la tabla "Descuento_Parque"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Area_Comercial' AND TABLE_NAME = 'Descuento_Parque')
BEGIN
    CREATE TABLE Area_Comercial.Descuento_Parque(
        IdDescuento TINYINT IDENTITY(1,1) PRIMARY KEY,
        IdParque INT,
        Porcentaje DECIMAL(2,2),
        Descripcion VARCHAR(100),

        FOREIGN KEY (IdParque) REFERENCES Area_Infraestructura.Parque(IdParque)
    )
END
GO

--10. Creación de la tabla "Feriado_Nacional"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Area_Comercial' AND TABLE_NAME = 'Feriado_Nacional')
BEGIN
    CREATE TABLE Area_Comercial.Feriado_Nacional(
        IdFeriado TINYINT IDENTITY(1,1) PRIMARY KEY,
        Fecha DATE,
        Tipo VARCHAR(50),
        Descripcion VARCHAR(100)
    )
END