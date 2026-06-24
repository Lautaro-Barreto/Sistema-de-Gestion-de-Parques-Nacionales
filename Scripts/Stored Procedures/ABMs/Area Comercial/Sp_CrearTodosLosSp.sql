/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 19/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación de todos los  Stored Procedure utilizado para
crear, modificar y eliminar las tablas del esquema Area_Comercial. 
*/
--Primero usar la BD
USE SGParquesNacionales
GO

-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LOS DESCUENTOS DE PARQUE
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Comercial.Sp_CrearDescuentoParque
    @IdParque INT,
    @Descripcion VARCHAR(100),
    @Porcentaje DECIMAL(2,2)
AS
BEGIN
    BEGIN TRY

        --El parque debe estar cargado en la DB
        IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @IdParque)
        BEGIN
            PRINT('Parque inexistente')
            RAISERROR('.', 16, 1)
        END

        --La descripción no puede ser nula o vacía
		IF @Descripcion ='' OR @Descripcion LIKE '%[^a-zA-Z ]%' OR LEN(@Descripcion) > 100
		BEGIN
			PRINT('La descripción ingresada no es válida')
			RAISERROR('.', 16,1)
		END
		SET @Descripcion = TRIM(@Descripcion)

        --El porcentaje de descuento debe ser mayor a cero
        IF @Porcentaje <= 0
        BEGIN
            PRINT('Porcentaje de descuento no válido')
            RAISERROR('.', 16, 1)
        END
    END TRY

    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
        BEGIN	
            RAISERROR('Algo salió mal en la creación del descuento', 16, 1);
            RETURN;
        END
    END CATCH

    INSERT INTO Area_Comercial.Descuento_Parque(IdParque, Descripcion, Porcentaje) VALUES
    (@IdParque, @Descripcion, @Porcentaje);
END
GO



-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LOS DETALLE DE VENTA DE ENTRADA
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Comercial.SP_CrearDetalleVentaEntrada
	@IdVenta INT,
	@IdEntrada INT,
	@Cantidad INT,
	@Subtotal DECIMAL(13,3)
AS
BEGIN
	BEGIN TRY
		--La venta debe estar cargada en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Venta WHERE IdVenta = @IdVenta)
        BEGIN
            PRINT('Venta inexistente')
            RAISERROR('.', 16, 1)
        END

		--La entrada debe estar cargada en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Entrada WHERE IdEntrada = @IdEntrada)
        BEGIN
            PRINT('Entrada inexistente')
            RAISERROR('.', 16, 1)
        END

		--La cantidad debe ser mayor a cero
		IF @Cantidad <= 0
			BEGIN
				PRINT('La cantidad no es valida')
				RAISERROR('.', 16, 1)
			END

		--El subtotal debe ser mayor a cero
		IF @Subtotal <= 0
			BEGIN
				PRINT('El subtotal no es valido')
				RAISERROR('.', 16, 1)
			END
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en el registro del detalle de venta de entradas', 16, 1);
			RETURN;
		END
	END CATCH

	INSERT INTO Area_Comercial.Detalle_Venta_Entrada(IdVenta, IdEntrada, Cantidad, Subtotal) VALUES
	(@IdVenta, @IdEntrada, @Cantidad, @Subtotal);
END
GO
-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LAS ENTRADAS
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Comercial.SP_CrearEntrada
	@IdParque INT,
	@IdTipoVisitante INT,
	@Precio DECIMAL(13,3),
	@Fecha_Acceso DATE
AS
BEGIN
	BEGIN TRY

		--El parque debe estar cargado en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @IdParque)
        BEGIN
            PRINT('Parque inexistente')
            RAISERROR('.', 16, 1)
        END

		--El tipo de visitante debe estar cargado en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Tipo_Visitante WHERE IdTipoVisitante = @IdTipoVisitante)
        BEGIN
            PRINT('Tipo de visitante inexistente')
            RAISERROR('.', 16, 1)
        END

		--El campo fecha de acceso debe tener un valor
		IF @Fecha_Acceso IS NULL
		BEGIN
            PRINT('La fecha de acceso no puede ser nula')
            RAISERROR('.', 16, 1)
        END

		--El precio debe ser mayor a cero
		IF @Precio <= 0
			BEGIN
				PRINT('El total no es valido')
				RAISERROR('.', 16, 1)
			END
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en el registro de la entrada', 16, 1);
			RETURN;
		END
	END CATCH

	INSERT INTO Area_Comercial.Entrada( IdParque, IdTipoVisitante, Precio, Fecha_Acceso) VALUES
	( @IdParque, @IdTipoVisitante, @Precio, @Fecha_Acceso);
	DECLARE @IdNuevaEntrada INT
	SET @IdNuevaEntrada = SCOPE_IDENTITY()
	RETURN @IdNuevaEntrada
END
GO
-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LAS FORMAS DE PAGO
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Comercial.SP_CrearFormaDePago
	@Descripcion VARCHAR(30)
AS
BEGIN
	BEGIN TRY
		--Se valida la descripcion ingresada
		IF @Descripcion = '' OR @Descripcion LIKE '%[^a-zA-Z ]%' OR LEN(@Descripcion) > 30
		BEGIN
			PRINT('La descripcion ingresada no es valida')
			RAISERROR('.', 16, 1)
		END
		SET @Descripcion = TRIM(@Descripcion)

		--La descripcion es unica
		IF EXISTS (SELECT 1 FROM Area_Comercial.Forma_De_Pago WHERE Descripcion = @Descripcion)
        BEGIN
            PRINT('Ya existe una forma de pago con esa descripcion')
            RAISERROR('.', 16, 1)
        END
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en el registro de la forma de pago', 16, 1);
			RETURN;
		END
	END CATCH

	INSERT INTO Area_Comercial.Forma_De_Pago(Descripcion) VALUES
	(@Descripcion);
	DECLARE @IdNuevaFormaDePago INT
	SET @IdNuevaFormaDePago = SCOPE_IDENTITY()
	RETURN @IdNuevaFormaDePago
END
GO
-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LOS PUNTOS DE VENTA
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Comercial.SP_CrearPuntoDeVenta
	@Descripcion VARCHAR(30)
AS
BEGIN
	BEGIN TRY
		--Se valida la descripcion ingresada
		IF @Descripcion = '' OR @Descripcion LIKE '%[^a-zA-Z ]%' OR LEN(@Descripcion) > 30
		BEGIN
			PRINT('La descripcion ingresada no es valida')
			RAISERROR('.', 16, 1)
		END
		SET @Descripcion = TRIM(@Descripcion)

		--La descripcion es unica
		IF EXISTS (SELECT 1 FROM Area_Comercial.Punto_De_Venta WHERE Descripcion = @Descripcion)
        BEGIN
            PRINT('Ya existe un punto de venta con esa descripcion')
            RAISERROR('.', 16, 1)
        END
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en el registro del punto de venta', 16, 1);
			RETURN;
		END
	END CATCH

	INSERT INTO Area_Comercial.Punto_De_Venta(Descripcion) VALUES
	(@Descripcion);
	DECLARE @IdNuevoPuntoDeVenta INT
	SET @IdNuevoPuntoDeVenta = SCOPE_IDENTITY()
	RETURN @IdNuevoPuntoDeVenta
END
GO
-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LOS TIPOS DE VISITANTE
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Comercial.SP_CrearTipoVisitante
	@Descripcion VARCHAR(30)
AS
BEGIN
	BEGIN TRY
		--Se valida la descripcion ingresada
		IF @Descripcion = '' OR @Descripcion LIKE '%[^a-zA-Z ]%' OR LEN(@Descripcion) > 30
		BEGIN
			PRINT('La descripcion ingresada no es valida')
			RAISERROR('.', 16, 1)
		END
		SET @Descripcion = TRIM(@Descripcion)

		--La descripcion es unica
		IF EXISTS (SELECT 1 FROM Area_Comercial.Tipo_Visitante WHERE Descripcion = @Descripcion)
        BEGIN
            PRINT('Ya existe un tipo de visitante con esa descripcion')
            RAISERROR('.', 16, 1)
        END
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en el registro del tipo de visitante', 16, 1);
			RETURN;
		END
	END CATCH

	INSERT INTO Area_Comercial.Tipo_Visitante(Descripcion) VALUES
	(@Descripcion);
	DECLARE @IdNuevoTipoVisitante INT
	SET @IdNuevoTipoVisitante = SCOPE_IDENTITY()
	RETURN @IdNuevoTipoVisitante
END
GO
-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LAS VENTAS
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Comercial.SP_CrearVenta
	@IdPuntoDeVenta INT,
	@IdParque INT,
	@IdFormaDePago INT,
	@Fecha DATE,
	@Total DECIMAL(13,3)
AS
BEGIN
	BEGIN TRY
		--El punto de venta debe estar cargado en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Punto_De_Venta WHERE IdPuntoDeVenta = @IdPuntoDeVenta)
        BEGIN
            PRINT('Punto de venta inexistente')
            RAISERROR('.', 16, 1)
        END

		--El parque debe estar cargado en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @IdParque)
        BEGIN
            PRINT('Parque inexistente')
            RAISERROR('.', 16, 1)
        END

		--La forma de pago debe estar cargada en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Forma_De_Pago WHERE IdFormaDePago = @IdFormaDePago)
        BEGIN
            PRINT('Forma de pago inexistente')
            RAISERROR('.', 16, 1)
        END

		--El campo fecha debe tener un valor
		IF @Fecha IS NULL
		BEGIN
            PRINT('La fecha no puede ser nula')
            RAISERROR('.', 16, 1)
        END

		--El total debe ser un numero positivo
		IF @Total < 0
			BEGIN
				PRINT('El total no es valido')
				RAISERROR('.', 16, 1)
			END
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en el registro de la venta', 16, 1);
			RETURN;
		END
	END CATCH

	INSERT INTO Area_Comercial.Venta(IdPuntoDeVenta, IdParque, IdFormaDePago, Fecha, Total) VALUES
	(@IdPuntoDeVenta, @IdParque, @IdFormaDePago, @Fecha, @Total);
	DECLARE @IdNuevaVenta INT
	SET @IdNuevaVenta = SCOPE_IDENTITY()
	RETURN @IdNuevaVenta
END
GO
-- //////////////////////////////////////////////////////////////
--    CREACIÓN DE LAS TARIFAS DE PARQUE POR TIPO DE VISITANTE
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Comercial.Sp_CrearPrecioParqueTipoVisitante
    @Parque VARCHAR(80),
    @TipoVisitante VARCHAR(30),
    @Precio DECIMAL(14,4)
AS
BEGIN
BEGIN TRY
    
    SET NOCOUNT ON;

    DECLARE @IdParque INT;
    DECLARE @IdTipoVisitante INT;

    -- Validar que el parque exista
    SELECT @IdParque = IdParque FROM Area_Infraestructura.Parque WHERE Nombre = @Parque;
    IF @IdParque IS NULL
    BEGIN
        RAISERROR('El parque especificado no existe.', 16, 1);
        RETURN;
    END

    -- Validar que el tipo de visitante exista
    SELECT @IdTipoVisitante = IdTipoVisitante FROM Area_Comercial.Tipo_Visitante WHERE Descripcion = @TipoVisitante;
    IF @IdTipoVisitante IS NULL
    BEGIN
        RAISERROR('El tipo de visitante especificado no existe.', 16, 1);
        RETURN;
    END

    -- Validar que el precio sea positivo
    IF @Precio <= 0
    BEGIN
        RAISERROR('El precio debe ser un valor positivo.', 16, 1);
        RETURN;
    END

    -- Insertar el precio en la tabla Precio_Parque_Tipo_Visitante
	INSERT INTO Area_Comercial.Precio_Parque_Tipo_Visitante (IdParque, IdTipoVisitante, Precio)
    VALUES (@IdParque, @IdTipoVisitante, @Precio);

END TRY
BEGIN CATCH
    IF ERROR_SEVERITY() > 10
    BEGIN
        DECLARE @ErrorMessage VARCHAR(255) = ERROR_MESSAGE();	
        RAISERROR(@ErrorMessage, 16, 1);
    END
END CATCH
END
GO

-- //////////////////////////////////////////////////////////////
--                  Apartado 2: Sps de Modificación
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
--                  MODIFICACIÓN DE LOS DESCUENTOS POR PARQUE
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Comercial.Sp_ModificarDescuentoParque
    @IdDescuento INT,
    @Descripcion VARCHAR(100) = NULL,
    @Porcentaje DECIMAL(2,2) = NULL
AS
BEGIN
    BEGIN TRY

        --El descuento debe estar cargado en la DB
        IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Descuento_Parque WHERE IdDescuento = @IdDescuento)
        BEGIN
            PRINT('Descuento inexistente')
            RAISERROR('.', 16, 1)
        END

        --La descripción debe ser válida si se proporciona
        IF @Descripcion IS NOT NULL AND (@Descripcion ='' OR @Descripcion LIKE '%[^a-zA-Z ]%' OR LEN(@Descripcion) > 100)
        BEGIN
            PRINT('La descripción ingresada no es válida')
            RAISERROR('.', 16,1)
        END
        SET @Descripcion = TRIM(@Descripcion)

        --El porcentaje de descuento debe ser mayor a cero
        IF @Porcentaje IS NOT NULL AND @Porcentaje <= 0
        BEGIN
            PRINT('Porcentaje de descuento no válido')
            RAISERROR('.', 16, 1)
        END
    END TRY

    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
        BEGIN	
            RAISERROR('Algo salió mal en la modificación del descuento', 16, 1);
            RETURN;
        END
    END CATCH

    UPDATE Area_Comercial.Descuento_Parque
    SET 
    Descripcion = @Descripcion,
    Porcentaje = @Porcentaje
    WHERE IdDescuento = @IdDescuento;
END
GO
-- //////////////////////////////////////////////////////////////
--                  MODIFICACIÓN DE LAS FORMAS DE PAGO
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Comercial.SP_ModificarFormaDePago
	@IdFormaDePago INT,
	@Descripcion VARCHAR(30)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		--La forma de pago debe estar cargada en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Forma_De_Pago WHERE IdFormaDePago = @IdFormaDePago)
        BEGIN
            PRINT('Forma de pago inexistente')
            RAISERROR('.', 16, 1)
        END

		--Se valida la descripcion
		IF @Descripcion IS NOT NULL AND @Descripcion <> ''
		BEGIN
			SET @Descripcion = TRIM(@Descripcion);
			IF @Descripcion LIKE '%[^a-zA-Z ]%' OR LEN(@Descripcion) > 30
			BEGIN
				PRINT('La descripcion no es valida');
				RAISERROR('.', 16, 1);
			END

			UPDATE Area_Comercial.Forma_De_Pago
			SET Descripcion = @Descripcion
			WHERE IdFormaDePago = @IdFormaDePago;
		END
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en la modifiacion de la forma de pago', 16, 1);
			RETURN;
		END
	END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--                  MODIFICACIÓN DE LOS PUNTOS DE VENTA
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Comercial.SP_ModificarPuntoDeVenta
	@IdPuntoDeVenta INT,
	@Descripcion VARCHAR(30)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		--El punto de venta debe estar cargado en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Punto_De_Venta WHERE IdPuntoDeVenta = @IdPuntoDeVenta)
        BEGIN
            PRINT('Punto de venta inexistente')
            RAISERROR('.', 16, 1)
        END

		--Se valida la descripcion
		IF @Descripcion IS NOT NULL AND @Descripcion <> ''
		BEGIN
			SET @Descripcion = TRIM(@Descripcion);
			IF @Descripcion LIKE '%[^a-zA-Z ]%' OR LEN(@Descripcion) > 30
			BEGIN
				PRINT('La descripcion no es valida');
				RAISERROR('.', 16, 1);
			END

			UPDATE Area_Comercial.Punto_De_Venta
			SET Descripcion = @Descripcion
			WHERE IdPuntoDeVenta = @IdPuntoDeVenta;
		END
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en la modifiacion del punto de venta', 16, 1);
			RETURN;
		END
	END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--                  MODIFICACIÓN DE LOS TIPOS DE VISITANTE
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Comercial.SP_ModificarTipoVisitante
	@IdTipoVisitante INT,
	@Descripcion VARCHAR(30)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		--El tipo de visitante debe estar cargado en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Tipo_Visitante WHERE IdTipoVisitante = @IdTipoVisitante)
        BEGIN
            PRINT('Tipo de visitante inexistente')
            RAISERROR('.', 16, 1)
        END

		--Se valida la descripcion
		IF @Descripcion IS NOT NULL AND @Descripcion <> ''
		BEGIN
			SET @Descripcion = TRIM(@Descripcion);
			IF @Descripcion LIKE '%[^a-zA-Z ]%' OR LEN(@Descripcion) > 30
			BEGIN
				PRINT('La descripcion no es valida');
				RAISERROR('.', 16, 1);
			END

			UPDATE Area_Comercial.Tipo_Visitante
			SET Descripcion = @Descripcion
			WHERE IdTipoVisitante = @IdTipoVisitante;
		END
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en la modifiacion del tipo de visitante', 16, 1);
			RETURN;
		END
	END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--  MODIFICACIÓN DE LAS TARIFAS DE PARQUE POR TIPO DE VISITANTE
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Comercial.Sp_ModificarPrecioParqueTipoVisitante
    @Parque VARCHAR(80),
    @TipoVisitante VARCHAR(30),
    @Precio DECIMAL(14,4)
AS
BEGIN
BEGIN TRY
    
    SET NOCOUNT ON;

    DECLARE @IdParque INT;
    DECLARE @IdTipoVisitante INT;

    -- Validar que el parque exista
    SELECT @IdParque = IdParque FROM Area_Infraestructura.Parque WHERE Nombre = @Parque;
    IF @IdParque IS NULL
    BEGIN
        RAISERROR('El parque especificado no existe.', 16, 1);
        RETURN;
    END

    -- Validar que el tipo de visitante exista
    SELECT @IdTipoVisitante = IdTipoVisitante FROM Area_Comercial.Tipo_Visitante WHERE Descripcion = @TipoVisitante;
    IF @IdTipoVisitante IS NULL
    BEGIN
        RAISERROR('El tipo de visitante especificado no existe.', 16, 1);
        RETURN;
    END

    -- Validar que el precio sea positivo
    IF @Precio <= 0
    BEGIN
        RAISERROR('El precio debe ser un valor positivo.', 16, 1);
        RETURN;
    END

    -- Actualizar el precio en la tabla Precio_Parque_Tipo_Visitante
    UPDATE Area_Comercial.Precio_Parque_Tipo_Visitante
    SET Precio = @Precio
    WHERE IdParque = @IdParque AND IdTipoVisitante = @IdTipoVisitante;

END TRY
BEGIN CATCH
    IF ERROR_SEVERITY() > 10
    BEGIN
        DECLARE @ErrorMessage VARCHAR(255) = ERROR_MESSAGE();	
        RAISERROR(@ErrorMessage, 16, 1);
    END
END CATCH
END
GO

-- //////////////////////////////////////////////////////////////
--                  Apartado 3: Sps de Eliminación
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
--                  ELIMINACIÓN DE DESCUENTO PARQUE
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Comercial.Sp_EliminarDescuentoParque
    @IdDescuento INT
AS
BEGIN
    BEGIN TRY

    --El descuento debe estar cargado en la DB
    IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Descuento_Parque WHERE IdDescuento = @IdDescuento)
        BEGIN
            PRINT('Descuento inexistente')
            RAISERROR('.', 16, 1)
        END
    END TRY

    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
        BEGIN	
            RAISERROR('Algo salio mal en la eliminación del descuento', 16, 1);
            RETURN;
        END
    END CATCH

    DELETE FROM Area_Comercial.Descuento_Parque WHERE IdDescuento = @IdDescuento;
END
GO
-- //////////////////////////////////////////////////////////////
--                  ELIMINACIÓN DE DETALLE VENTA ENTRADA
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Comercial.SP_EliminarDetalleVentaEntrada
	@IdDetalle INT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		--El detalle debe estar cargado en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Detalle_Venta_Entrada WHERE IdDetalle = @IdDetalle)
        BEGIN
            PRINT('Detalle de venta inexistente')
            RAISERROR('.', 16, 1)
        END
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en la eliminacion del detalle de venta de entradas', 16, 1);
			RETURN;
		END
	END CATCH

	DELETE FROM Area_Comercial.Detalle_Venta_Entrada WHERE IdDetalle = @IdDetalle
END
GO

-- //////////////////////////////////////////////////////////////
--                  ELIMINACIÓN DE FORMA DE PAGO
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Comercial.SP_EliminarFormaDePago
	@IdFormaDePago INT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		--La forma de pago debe estar cargada en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Forma_De_Pago WHERE IdFormaDePago = @IdFormaDePago)
        BEGIN
            PRINT('Forma de pago inexistente')
            RAISERROR('.', 16, 1)
        END
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en la eliminacion de la forma de pago', 16, 1);
			RETURN;
		END
	END CATCH

	DELETE FROM Area_Comercial.Venta WHERE IdFormaDePago = @IdFormaDePago
	DELETE FROM Area_Comercial.Forma_De_Pago WHERE IdFormaDePago = @IdFormaDePago
END
GO

-- //////////////////////////////////////////////////////////////
--                  ELIMINACIÓN DE PUNTO DE VENTA
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Comercial.SP_EliminarPuntoDeVenta
	@IdPuntoDeVenta INT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		--El punto de venta debe estar cargado en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Punto_De_Venta WHERE IdPuntoDeVenta = @IdPuntoDeVenta)
        BEGIN
            PRINT('Punto de venta inexistente')
            RAISERROR('.', 16, 1)
        END
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en la eliminacion del punto de venta', 16, 1);
			RETURN;
		END
	END CATCH

	DELETE FROM Area_Comercial.Venta WHERE IdPuntoDeVenta = @IdPuntoDeVenta
	DELETE FROM Area_Comercial.Punto_De_Venta WHERE IdPuntoDeVenta = @IdPuntoDeVenta
END
GO

-- //////////////////////////////////////////////////////////////
--                  ELIMINACIÓN DE TIPO DE VISITANTE
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Comercial.SP_EliminarTipoDeVisitante
	@IdTipoVisitante INT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		--El tipo de visitante debe estar cargado en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Tipo_Visitante WHERE IdTipoVisitante = @IdTipoVisitante)
        BEGIN
            PRINT('Tipo de visitante inexistente')
            RAISERROR('.', 16, 1)
        END
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en la eliminacion del tipo de visitante', 16, 1);
			RETURN;
		END
	END CATCH

	DELETE FROM Area_Comercial.Entrada WHERE IdTipoVisitante = @IdTipoVisitante
	DELETE FROM Area_Comercial.Tipo_Visitante WHERE IdTipoVisitante = @IdTipoVisitante
END
GO

-- //////////////////////////////////////////////////////////////
--     ELIMINACION DE TARIFAS DE PARQUE POR TIPO DE VISITANTE
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Comercial.Sp_EliminarPrecioParqueTipoVisitante
    @Parque VARCHAR(80),
    @TipoVisitante VARCHAR(30)
AS
BEGIN
BEGIN TRY
    
    SET NOCOUNT ON;

    DECLARE @IdParque INT;
    DECLARE @IdTipoVisitante INT;

    -- Validar que el parque exista
    SELECT @IdParque = IdParque FROM Area_Infraestructura.Parque WHERE Nombre = @Parque;
    IF @IdParque IS NULL
    BEGIN
        RAISERROR('El parque especificado no existe.', 16, 1);
        RETURN;
    END

    -- Validar que el tipo de visitante exista
    SELECT @IdTipoVisitante = IdTipoVisitante FROM Area_Comercial.Tipo_Visitante WHERE Descripcion = @TipoVisitante;
    IF @IdTipoVisitante IS NULL
    BEGIN
        RAISERROR('El tipo de visitante especificado no existe.', 16, 1);
        RETURN;
    END

    -- Eliminar la tarifa en la tabla Precio_Parque_Tipo_Visitante
    DELETE FROM Area_Comercial.Precio_Parque_Tipo_Visitante
    WHERE IdParque = @IdParque AND IdTipoVisitante = @IdTipoVisitante;

END TRY
BEGIN CATCH
    IF ERROR_SEVERITY() > 10
    BEGIN
        DECLARE @ErrorMessage VARCHAR(255) = ERROR_MESSAGE();	
        RAISERROR(@ErrorMessage, 16, 1);
    END
END CATCH
END
GO