/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 19/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación de todos los  Stored Procedure utilizado para
crear, modificar y eliminar todas las tablas de los cuatro esquemas: Comercial, Excursiones, Infraestructura, Negocios
*/
--Primero usar la BD
USE SGParquesNacionales
GO


-----------------------------------------------------------------------
--                  CREACIÓN DE LOS SP DEL AREA COMERCIAL           --
-----------------------------------------------------------------------

PRINT '-- #INICIO DE CREACIÓN DE SP DE AREA COMERCIAL --'

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
PRINT '-- #FIN DE CREACIÓN DE SP DE AREA COMERCIAL --'
-----------------------------------------------------------------------
--                  CREACIÓN DE LOS SP DEL AREA DE EXCURSIONES      --
-----------------------------------------------------------------------
PRINT '-- #INICIO DE CREACIÓN DE SP DE AREA EXCURSIONES --'

-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LAS ACTIVIDADES
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_CrearActividad
    @tipoActividad INT,
    @idParque INT,
    @Nombre VARCHAR(30),
    @Costo decimal(10, 2),
    @Duracion INT,
    @Cupo_maximo INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        --El tipo de Actividad debe estar en la db
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Tipo_Actividad WHERE IdTipoActividad = @tipoActividad)
        BEGIN
            RAISERROR('El tipo de actividad no existe.', 16, 1)
            
        END
        --El parque debe estar en la db
        IF NOT EXISTS(SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @idParque)
        BEGIN
            RAISERROR('El Parque no existe.', 16, 1)
            
        END

        IF @Costo < 0
        BEGIN
            RAISERROR('El costo no puede ser negativo.', 16, 1)
            
        END 
        IF @Duracion <= 0
        BEGIN  
            RAISERROR('La duración debe ser positiva.', 16, 1)
            
        END
        IF @Cupo_maximo <= 0 
        BEGIN
            RAISERROR('El cupo máximo debe ser positivo.', 16, 1)
            

        END
        IF( @Nombre IS NULL OR LEN(@Nombre) = 0)
        BEGIN
            RAISERROR('El nombre debe tener entre 1 y 30 caracteres.', 16, 1)
            
        END


    INSERT INTO Area_Excursiones.Actividad (IdTipoActividad, IdParque, Nombre, Costo, Duracion, Cupo_maximo)
    VALUES (@tipoActividad, @idParque, @Nombre, @Costo, @Duracion, @Cupo_maximo)
    DECLARE @Id_NuevaActividad INT 
    SET @Id_NuevaActividad = SCOPE_IDENTITY()
    RETURN @Id_NuevaActividad

    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END
GO
-- //////////////////////////////////////////////////////////////
--            CREACIÓN DE LA CONTRATACION DE ACTIVIDADES
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_CrearContratacion_Actividad
    @IdVenta INT, 
    @IdActividad INT,
    @Monto decimal(10, 2),
    @FechaContratacion DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Actividad WHERE IdActividad = @IdActividad AND Activo = 1)
        BEGIN
            RAISERROR('La actividad no existe.', 16, 1)
        END

        IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Venta WHERE IdVenta = @IdVenta)
        BEGIN
            RAISERROR('La venta no existe.', 16, 1)
        END

        IF @Monto < 0
        BEGIN
            RAISERROR('El monto no puede ser negativo.', 16, 1)
        END

    INSERT INTO Area_Excursiones.Contratacion_Actividad (IdVenta, IdActividad, Monto, Fecha_Contratacion)
    VALUES (@IdVenta, @IdActividad, @Monto, @FechaContratacion)
    DECLARE @idNueva_ContratacionActividad INT
    SET @idNueva_ContratacionActividad = SCOPE_IDENTITY()   
    RETURN @idNueva_ContratacionActividad


    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH


END
GO
-- //////////////////////////////////////////////////////////////
--            CREACIÓN DE LA ESPECIALIDAD
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_CrearEspecialidad
    @Descripcion VARCHAR(50)
AS 
BEGIN 
    SET NOCOUNT ON;
    BEGIN TRY
        IF @Descripcion IS NULL OR LEN(@Descripcion) = 0
        BEGIN
            RAISERROR('La descripción debe tener entre 1 y 50 caracteres.', 16, 1)
        END

        INSERT INTO Area_Excursiones.Especialidad (Descripcion)
        VALUES (@Descripcion)
        DECLARE @idNuevo_Especialidad INT
        SET @idNuevo_Especialidad = SCOPE_IDENTITY()
        RETURN @idNuevo_Especialidad

    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;
        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END
GO
-- //////////////////////////////////////////////////////////////
--            CREACIÓN DE LOS GUIAS
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_CrearGuia
    @DNI CHAR(8),
    @idParque INT,
    @idEspecialidad INT,
    @Nombre VARCHAR(30),
    @Apellido VARCHAR(30),
    @Titulo VARCHAR(30)

AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        --El parque debe estar en la db
        IF NOT EXISTS(SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @idParque)
        BEGIN
            RAISERROR('El Parque no existe.', 16, 1)
        END

        --La especialidad debe estar en la db
        IF NOT EXISTS(SELECT 1 FROM Area_Excursiones.Especialidad WHERE IdEspecialidad = @idEspecialidad)
        BEGIN
            RAISERROR('La especialidad no existe.', 16, 1)
            
        END
        --validar que el dni sea válido
        IF (@DNI LIKE '%[^0-9]%' OR LEN(@DNI) NOT BETWEEN 7 AND 8)
        BEGIN
            RAISERROR('DNI inválido: debe contener solo números y tener entre 7 y 8 dígitos.', 16, 1);
        END

        --El dni no debe existir en la db 
        DECLARE @IdGuiaRepetido INT
        SELECT @IdGuiaRepetido = IdGuia FROM Area_Excursiones.Guia WHERE DNI = @Dni
        IF @IdGuiaRepetido IS NOT NULL
        BEGIN
            RAISERROR('El DNI proporcionado ya está registrado para otro guía.', 16, 1)
            RETURN @IdGuiaRepetido 
        END

        IF( @Nombre IS NULL OR LEN(@Nombre) = 0)
        BEGIN
            RAISERROR('El nombre debe tener entre 1 y 30 caracteres.', 16, 1)
            
        END

        IF( @Apellido IS NULL OR LEN(@Apellido) = 0)
        BEGIN
            RAISERROR('El apellido debe tener entre 1 y 30 caracteres.', 16, 1)
            
        END

        IF( @Titulo IS NULL OR LEN(@Titulo) = 0)
        BEGIN
            RAISERROR('El título debe tener entre 1 y 30 caracteres.', 16, 1)
            
        END

        INSERT INTO Area_Excursiones.Guia (DNI, IdParque, IdEspecialidad, Nombre, Apellido, Titulo)
        VALUES (@DNI, @idParque, @idEspecialidad, @Nombre, @Apellido, @Titulo)
        DECLARE @Id_NuevoGuia INT
        SET @Id_NuevoGuia = SCOPE_IDENTITY()
        RETURN @Id_NuevoGuia

    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END
GO
-- //////////////////////////////////////////////////////////////
--            CREACIÓN DE LOS GUIAS POR ACTIVIDAD
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_CrearGuiasPorActividad
    @IdGuia INT,
    @IdActividad INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        --Validamos que el guia y la actividad existan
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Guia WHERE IdGuia = @IdGuia)
        BEGIN
            RAISERROR('El guía no existe.', 16, 1)
        END

        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Actividad WHERE IdActividad = @IdActividad AND Activo = 1)
        BEGIN
            RAISERROR('La actividad no existe.', 16, 1)
        END
        --ahora debemos validar que el guia tenga la HABILITACION para esa actividad
        IF NOT EXISTS (
            -- 1er nivel: Agarramos todas las habilitaciones que pide la actividad
            SELECT 1 FROM Area_Excursiones.Habilitaciones_por_Actividad ha
            WHERE ha.IdActividad = @IdActividad
            AND NOT EXISTS (
                -- 2do nivel: nos fijamos si alguna de esas NO la tiene el guía (o está vencida)
                SELECT 1 FROM Area_Excursiones.Habilitacion_Guia hg 
                WHERE hg.IdGuia = @IdGuia
                AND hg.IdHabilitacion = ha.IdHabilitacion
                AND hg.Fecha_Fin_Validez >= GETDATE() --la habilitación debe estar vigente
            )
        )
        BEGIN 
            -- Si llegamos acá, significa que la doble negación fue verdadera.
            -- NO hay ninguna habilitación exigida que el guía NO tenga. 
            -- Por lo tanto, LAS TIENE TODAS.
            INSERT INTO Area_Excursiones.Guias_por_actividad (IdGuia, IdActividad) 
            VALUES (@IdGuia, @IdActividad);
        END
        ELSE
        BEGIN
            RAISERROR('El guía no tiene la habilitación necesaria para esta actividad.', 16, 1)
        END

    END TRY


    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END

GO
-- //////////////////////////////////////////////////////////////
--            CREACIÓN DE LAS HABILITACIONES
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_CrearHabilitacion
    @Descripcion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @Descripcion IS NULL OR LEN(@Descripcion) = 0
        BEGIN
            RAISERROR('La descripción debe tener entre 1 y 50 caracteres.', 16, 1)
            
        END

    INSERT INTO Area_Excursiones.Habilitacion (Descripcion)
    VALUES (@Descripcion)
    DECLARE @idNueva_Habilitacion INT
    SET @idNueva_Habilitacion = SCOPE_IDENTITY()
    RETURN @idNueva_Habilitacion
    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END
GO

-- //////////////////////////////////////////////////////////////
--            CREACIÓN DE LAS HABILITACIONES POR ACTIVIDAD
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_CrearHabilitacionesPorActividad
    @IdActividad INT,
    @IdHabilitaciones INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validar que la habilitación exista
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Habilitacion WHERE IdHabilitaciones = @IdHabilitaciones)
        BEGIN
            RAISERROR('La habilitación con el Id proporcionado no existe.', 16, 1)
            RETURN
        END

        -- Validar que la actividad exista
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Actividad WHERE IdActividad = @IdActividad AND Activo = 1)
        BEGIN
            RAISERROR('La actividad con el Id proporcionado no existe.', 16, 1)
            RETURN
        END

        INSERT INTO Area_Excursiones.Habilitaciones_por_Actividad(IdHabilitacion, IdActividad)
        VALUES (@IdHabilitaciones, @IdActividad)

    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END
GO
-- //////////////////////////////////////////////////////////////
--            CREACIÓN DE LAS HABILITACIONES DEL GUIA
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_CrearHabilitacionGuia
    @IdGuia INT,
    @IdHabilitacion INT,
    @FechaInicio DATE,
    @FechaFin DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Guia WHERE IdGuia = @IdGuia)
        BEGIN
            RAISERROR('El guía no existe.', 16, 1)
            
        END

        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Habilitacion WHERE IdHabilitaciones = @IdHabilitacion)
        BEGIN
            RAISERROR('La habilitación no existe.', 16, 1)
            
        END

        IF @FechaFin < @FechaInicio
        BEGIN
            RAISERROR('La fecha de fin de la validez de la habilitacion no puede ser anterior a la fecha de inicio de la misma.', 16, 1)
        END
        
        IF @FechaFin < GETDATE()
        BEGIN
            RAISERROR('La fecha de la finalizacion de la validez de la habilitacion no puede ser anterior a la fecha actual.', 16, 1)
        END
            
        
    INSERT INTO Area_Excursiones.Habilitacion_Guia (IdGuia, IdHabilitacion, Fecha_Inicio_Validez, Fecha_Fin_Validez)
    VALUES (@IdGuia, @IdHabilitacion, @FechaInicio, @FechaFin)
    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END
GO
-- //////////////////////////////////////////////////////////////
--            CREACIÓN DE LOS TIPOS DE ACTIVIDAD
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Excursiones.SP_CrearTipoActividad
    @Descripcion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @Descripcion IS NULL OR LEN(@Descripcion) = 0
        BEGIN
            RAISERROR('La descripción debe tener entre 1 y 50 caracteres.', 16, 1)
        END

    INSERT INTO Area_Excursiones.Tipo_Actividad (Descripcion)
    VALUES (@Descripcion)
    DECLARE @idNuevo_TipoActividad INT
    SET @idNuevo_TipoActividad = SCOPE_IDENTITY()
    RETURN @idNuevo_TipoActividad
    
    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END
GO

-- //////////////////////////////////////////////////////////////
--            Apartado 3: Sps de Modificación 
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
--            MODIFICACIÓN DE ACTIVIDAD
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_ModificarActividad
    @IdActividad INT,
    @IdTipoActividad INT,
    @IdParque INT,
    @Nombre VARCHAR(30),
    @Costo DECIMAL(10, 2),
    @Duracion INT,
    @Cupo_maximo INT
AS
BEGIN

    BEGIN TRY
        -- Validar que la actividad exista
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Actividad WHERE IdActividad = @IdActividad AND Activo = 1)
        BEGIN
            RAISERROR('La actividad con el Id proporcionado no existe.', 16, 1)
            RETURN
        END
        -- Validar que el tipo de actividad exista
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Tipo_Actividad WHERE IdTipoActividad = @IdTipoActividad)
        BEGIN
            RAISERROR('El tipo de actividad con el Id proporcionado no existe.', 16, 1)
            RETURN
        END
        -- Validar que el parque exista
        IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @IdParque)
        BEGIN
            RAISERROR('El parque con el Id proporcionado no existe.', 16, 1)
            RETURN
        END
        --validar que el nombre sea valido
        IF @Nombre IS NULL OR LEN(@Nombre) = 0
        BEGIN
            RAISERROR('El nombre debe tener entre 1 y 30 caracteres.', 16, 1)
            RETURN
        END
        --validar que el costo sea positivo
        IF @Costo < 0
        BEGIN
            RAISERROR('El costo no puede ser negativo.', 16, 1)
            RETURN
        END
        --validar la duración y el cupo máximo sean positivos
        IF @Duracion <= 0
        BEGIN
            RAISERROR('La duración debe ser un valor positivo.', 16, 1)
            RETURN
        END 
        IF @Cupo_maximo <= 0
        BEGIN
            RAISERROR('El cupo máximo debe ser un valor positivo.', 16, 1)
            RETURN
        END

    UPDATE Area_Excursiones.Actividad
    SET IdTipoActividad = @IdTipoActividad,
        IdParque = @IdParque,
        Nombre = @Nombre,
        Costo = @Costo,
        Duracion = @Duracion,
        Cupo_maximo = @Cupo_maximo
    WHERE IdActividad = @IdActividad

    END TRY

BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END 
GO
-- //////////////////////////////////////////////////////////////
--            MODIFICACIÓN DE CONTRATACIÓN DE ACTIVIDAD
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_ModificarContratacionActividad
    @IdContratacionActividad INT,
    @IdActividad INT,
    @IdVenta INT, 
    @Monto DECIMAL(10, 2),
    @FechaContratacion DATE

AS
BEGIN
    BEGIN TRY
        -- Validar que la contratación de actividad exista
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Contratacion_Actividad WHERE IdContratacion = @IdContratacionActividad AND Activo = 1)
        BEGIN
            RAISERROR('La contratación de actividad con el Id proporcionado no existe.', 16, 1)
        END
        -- Validar que la actividad exista
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Actividad WHERE IdActividad = @IdActividad AND Activo = 1)
        BEGIN
            RAISERROR('La actividad con el Id proporcionado no existe.', 16, 1)
            
        END
        -- Validar que la venta exista
        IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Venta WHERE IdVenta = @IdVenta)
        BEGIN
            RAISERROR('La venta con el Id proporcionado no existe.', 16, 1)
            
        END
        --validar que el monto sea positivo
        IF @Monto < 0
        BEGIN
            RAISERROR('El monto no puede ser negativo.', 16, 1)
            
        END
        --validar que la fecha de contratación no sea futura
        IF @FechaContratacion > GETDATE()
        BEGIN
            RAISERROR('La fecha de contratación no puede ser futura.', 16, 1)
        END

    UPDATE Area_Excursiones.Contratacion_Actividad 
    SET IdActividad = @IdActividad,
        IdVenta = @IdVenta,
        Monto = @Monto,
        Fecha_Contratacion = @FechaContratacion
    WHERE IdContratacion = @IdContratacionActividad
    
    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH


END
GO
-- //////////////////////////////////////////////////////////////
--            MODIFICACIÓN DE ESPECIALIDADES
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_ModificarEspecialidad
    @IdEspecialidad INT,
    @Descripcion VARCHAR(50)
AS
BEGIN
    BEGIN TRY
        -- Validar que la especialidad exista
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Especialidad WHERE IdEspecialidad = @IdEspecialidad)
        BEGIN
            RAISERROR('La especialidad con el Id proporcionado no existe.', 16, 1)
            RETURN
        END
        --validar que la descripción sea válida
        IF @Descripcion IS NULL OR LEN(@Descripcion) = 0
        BEGIN
            RAISERROR('La descripción debe tener entre 1 y 50 caracteres.', 16, 1)
            RETURN
        END

        -- Modificar la especialidad
        UPDATE Area_Excursiones.Especialidad
        SET Descripcion = @Descripcion
        WHERE IdEspecialidad = @IdEspecialidad

    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END
GO
-- //////////////////////////////////////////////////////////////
--            MODIFICACIÓN DE GUIAS
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_ModificarGuia
    @IdGuia INT,
    @Dni CHAR(8),
    @IdParque INT,
    @IdEspecialidad INT,
    @Nombre VARCHAR(30),
    @Apellido VARCHAR(30),
    @Titulo VARCHAR(30)
AS
BEGIN

    BEGIN TRY 
        -- Validar que el guia exista
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Guia WHERE IdGuia = @IdGuia)
        BEGIN
            RAISERROR('El guia con el Id proporcionado no existe.', 16, 1)

        END
        -- Validar que el parque exista
        IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @IdParque)
        BEGIN
            RAISERROR('El parque con el Id proporcionado no existe.', 16, 1)
            
        END
        -- Validar que la especialidad exista
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Especialidad WHERE IdEspecialidad = @IdEspecialidad)
        BEGIN
            RAISERROR('La especialidad con el Id proporcionado no existe.', 16, 1)
            
        END
        --validar que el dni sea válido
        IF (@DNI LIKE '%[^0-9]%' OR LEN(@DNI) NOT BETWEEN 7 AND 8)
        BEGIN
            RAISERROR('DNI inválido: debe contener solo números y tener entre 7 y 8 dígitos.', 16, 1);
        END

        
        IF EXISTS(SELECT 1 FROM Area_Excursiones.Guia WHERE DNI = @Dni AND IdGuia != @IdGuia)
        BEGIN
            RAISERROR('El DNI proporcionado ya está registrado para otro guía.', 16, 1)
        END

        --validar que el nombre, apellido y título sean válidos
        IF @Nombre IS NULL OR LEN(@Nombre) = 0
        BEGIN
            RAISERROR('El nombre debe tener entre 1 y 30 caracteres.', 16, 1) 
        END

        IF @Apellido IS NULL OR LEN(@Apellido) = 0
        BEGIN
            RAISERROR('El apellido debe tener entre 1 y 30 caracteres.', 16, 1)   
        END

        IF @Titulo IS NULL OR LEN(@Titulo) = 0
        BEGIN
            RAISERROR('El título debe tener entre 1 y 30 caracteres.', 16, 1)
            
        END

        -- Modificar el guia
        UPDATE Area_Excursiones.Guia
        SET DNI = @Dni,
            IdParque = @IdParque,
            IdEspecialidad = @IdEspecialidad,
            Nombre = @Nombre,
            Apellido = @Apellido,
            Titulo = @Titulo
        WHERE IdGuia = @IdGuia

    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END 
GO
-- //////////////////////////////////////////////////////////////
--            MODIFICACIÓN DE HABILITACIONES
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_ModificarHabilitacion
    @IdHabilitacion INT,
    @Descripcion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validar que la habilitación exista
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Habilitacion WHERE IdHabilitaciones = @IdHabilitacion)
        BEGIN
            RAISERROR('La habilitación con el Id proporcionado no existe.', 16, 1)
        END

        IF @Descripcion IS NULL OR LEN(@Descripcion) = 0
        BEGIN
            RAISERROR('La descripción debe tener entre 1 y 50 caracteres.', 16, 1)
        END

        UPDATE Area_Excursiones.Habilitacion
        SET Descripcion = @Descripcion
        WHERE IdHabilitaciones = @IdHabilitacion

    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END
GO
-- //////////////////////////////////////////////////////////////
--            MODIFICACIÓN DE HABILITACIONES DE GUIA
-- //////////////////////////////////////////////////////////////


CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_ModificarHabilitacionesGuia
    @IdGuia INT,
    @IdHabilitacion INT,
    @FechaInicio DATE,
    @FechaFin DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY 
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Guia WHERE IdGuia = @IdGuia)
        BEGIN
            RAISERROR('El guía no existe.', 16, 1)
        END

        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Habilitacion WHERE IdHabilitaciones = @IdHabilitacion)
        BEGIN
            RAISERROR('La habilitación no existe.', 16, 1)
        END

        IF @FechaFin < @FechaInicio
        BEGIN
            RAISERROR('La fecha de fin de la validez de la habilitacion no puede ser anterior a la fecha de inicio de la misma.', 16, 1)
        END

        IF NOT EXISTS( SELECT 1 FROM Area_Excursiones.Habilitacion_Guia WHERE IdGuia = @IdGuia AND IdHabilitacion = @IdHabilitacion )
        BEGIN 
            RAISERROR('El guia no tiene asignada la habilitacion que se desea modificar.',16,1)
        END 
                
        
        IF @FechaFin < GETDATE()
        BEGIN
            RAISERROR('La fecha de la finalizacion de la validez de la habilitacion no puede ser anterior a la fecha actual.', 16, 1)
        END

        UPDATE Area_Excursiones.Habilitacion_Guia
        SET Fecha_Inicio_Validez = @FechaInicio,
            Fecha_Fin_Validez = @FechaFin
        WHERE IdGuia = @IdGuia AND IdHabilitacion = @IdHabilitacion

    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH


END 
GO
-- //////////////////////////////////////////////////////////////
--            MODIFICACIÓN DE TIPO DE ACTIVIDAD
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_ModificarTipoActividad
    @idTipoActividad INT,
    @Descripcion VARCHAR(50)
AS

BEGIN
    SET NOCOUNT ON
    BEGIN TRY 
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Tipo_Actividad WHERE idTipoActividad = @idTipoActividad)
        BEGIN 
            RAISERROR('El tipo de actividad que se quiere modificar no existe',16,1)
        END 

        --validamos la descripcion
        IF @Descripcion IS NULL OR LEN(@Descripcion) = 0
        BEGIN 
            RAISERROR('Debe ingresar una descripcion valida',16,1)
        END

        UPDATE Area_Excursiones.Tipo_Actividad 
        SET Descripcion  = @Descripcion
        WHERE IdTipoActividad = @idTipoActividad

    END TRY 

    BEGIN CATCH 
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH 
END 
GO

-- //////////////////////////////////////////////////////////////
--            APARTADO 3: SPs de ELIMINACIÓN
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
--            ELIMINACIÓN DE ACTIVIDAD
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_EliminarActividad
    @IdActividad INT
AS

BEGIN 
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS( SELECT 1 FROM Area_Excursiones.Actividad WHERE IdActividad = @IdActividad AND Activo = 1  )
        BEGIN  
            RAISERROR('La actividad no existe o ya se encuentra dada de baja.', 16, 1);
        END 

        UPDATE Area_Excursiones.Actividad 
        SET Activo = 0
        WHERE IdActividad = @IdActividad
    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END 
GO

-- //////////////////////////////////////////////////////////////
--            ELIMINACIÓN DE CONTRATACIÓN DE ACTIVIDAD
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_EliminarContratacionActividad
    @IdContratacion INT
AS

BEGIN 
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS( SELECT 1 FROM Area_Excursiones.Contratacion_Actividad WHERE IdContratacion = @IdContratacion AND Activo = 1  )
        BEGIN  
            RAISERROR('La contratacion no existe o ya se encuentra dada de baja.', 16, 1);
        END 

        UPDATE Area_Excursiones.Contratacion_Actividad
        SET Activo = 0
        WHERE IdContratacion = @IdContratacion
    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END 
GO
-- //////////////////////////////////////////////////////////////
--            ELIMINACIÓN DE ESPECIALIDAD
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_EliminarEspecialidad
    @IdEspecialidad INT
AS
BEGIN 
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION
            -- Validar que la especialidad exista
            IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Especialidad WHERE IdEspecialidad = @IdEspecialidad)
            BEGIN
                RAISERROR('La especialidad con el Id proporcionado no existe.', 16, 1)
            END
            UPDATE Area_Excursiones.Guia SET IdEspecialidad = 1 --Establecemos la especialidad por defecto a los guías que tengan la especialidad que se va a eliminar
            WHERE IdEspecialidad = @IdEspecialidad

            DELETE FROM Area_Excursiones.Especialidad
            WHERE IdEspecialidad = @IdEspecialidad
        COMMIT TRANSACTION

    END TRY

    BEGIN CATCH
        IF @@TRANCOUNT > 0 
            ROLLBACK TRANSACTION

        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END
GO
-- //////////////////////////////////////////////////////////////
--            ELIMINACIÓN DE GUIAS POR ACTIVIDAD
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_ElimnarGuiasPorActividad
    @IdActividad INT,
    @IdGuia INT
AS
BEGIN 
    BEGIN TRY 
        SET NOCOUNT ON;
        -- Validar que la actividad exista
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Actividad WHERE IdActividad = @IdActividad AND Activo = 1 )
        BEGIN
            RAISERROR('La actividad con el Id proporcionado no existe.', 16, 1)
        END
        --Validar que el guía exista 
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Guia WHERE IdGuia = @IdGuia)
        BEGIN
            RAISERROR('El guía con el Id proporcionado no existe.', 16, 1)
        END
        --Validar que ese guia tenga esa actividad para eliminarla 
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Guias_por_Actividad WHERE IdActividad = @IdActividad AND IdGuia = @IdGuia)
        BEGIN
            RAISERROR('La actividad no está asignada al guía proporcionado.', 16, 1)
        END

        DELETE FROM Area_Excursiones.Guias_por_Actividad
        WHERE IdActividad = @IdActividad AND IdGuia = @IdGuia

    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END 
GO

-- //////////////////////////////////////////////////////////////
--            ELIMINACIÓN DE HABILITACIONES
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_EliminarHabilitacion
    @IdHabilitacion INT
AS
BEGIN 
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION
            -- Validar que la habilitación exista
            IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Habilitacion WHERE IdHabilitaciones = @IdHabilitacion)
            BEGIN
                RAISERROR('La habilitación con el Id proporcionado no existe.', 16, 1)
            END
            --eliminamos las asociaciones de los guias 
            DELETE FROM Area_Excursiones.Habilitacion_Guia
            WHERE IdHabilitacion = @IdHabilitacion
            --eliminamos las asociaciones de las actividades
            DELETE FROM Area_Excursiones.Habilitaciones_por_Actividad
            WHERE IdHabilitacion = @IdHabilitacion
            --eliminamos la habilitacion
            DELETE FROM Area_Excursiones.Habilitacion
            WHERE IdHabilitaciones = @IdHabilitacion
        COMMIT TRANSACTION

    END TRY
    BEGIN CATCH
        --si hubo un error y la transaccion quedó abierta, revertimos
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION 
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- //////////////////////////////////////////////////////////////
--            ELIMINACIÓN DE HABILITACIONES POR ACTIVIDAD
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_EliminarHabilitacionesPorActividad
    @IdActividad INT,
    @IdHabilitacion INT
AS

BEGIN 
    BEGIN TRY 
        SET NOCOUNT ON;
        -- Validar que la actividad exista
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Actividad WHERE IdActividad = @IdActividad AND Activo = 1 )
        BEGIN
            RAISERROR('La actividad con el Id proporcionado no existe.', 16, 1)
        END
        --Validar que la habilitación exista 
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Habilitacion WHERE IdHabilitaciones = @IdHabilitacion)
        BEGIN
            RAISERROR('La habilitación con el Id proporcionado no existe.', 16, 1)
        END
        --Validar que esa habilitación tenga esa actividad para eliminarla 
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Habilitaciones_por_Actividad WHERE IdActividad = @IdActividad AND IdHabilitacion = @IdHabilitacion)
        BEGIN
            RAISERROR('La actividad no tiene asignada la habilitación proporcionada.', 16, 1)
        END

        DELETE FROM Area_Excursiones.Habilitaciones_por_Actividad
        WHERE IdActividad = @IdActividad AND IdHabilitacion = @IdHabilitacion

    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END     
GO
-- //////////////////////////////////////////////////////////////
--            ELIMINACIÓN DE HABILITACIONES DE GUIA
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_EliminarHabilitacionGuia
    @IdHabilitacion INT,
    @IdGuia INT
AS
BEGIN
    BEGIN TRY 
        SET NOCOUNT ON;
        -- Validar que la habilitación exista
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Habilitacion WHERE IdHabilitaciones = @IdHabilitacion )
        BEGIN
            RAISERROR('La habilitación con el Id proporcionado no existe.', 16, 1)
        END
        --Validar que el guía exista 
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Guia WHERE IdGuia = @IdGuia)
        BEGIN
            RAISERROR('El guía con el Id proporcionado no existe.', 16, 1)
        END
        --Validar que ese guia tenga esa habilitacion para eliminarla 
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Habilitacion_Guia WHERE IdHabilitacion = @IdHabilitacion AND IdGuia = @IdGuia)
        BEGIN
            RAISERROR('La habilitación no está asignada al guía proporcionado.', 16, 1)
        END

        DELETE FROM Area_Excursiones.Habilitacion_Guia
        WHERE IdHabilitacion = @IdHabilitacion AND IdGuia = @IdGuia

    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END 
GO
-- //////////////////////////////////////////////////////////////
--            ELIMINACIÓN DE TIPO DE ACTIVIDAD
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_EliminarTipoActividad
    @idTipoActividad INT 
AS

BEGIN
    SET NOCOUNT ON 
    BEGIN TRY 
        BEGIN TRANSACTION
            IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Tipo_Actividad WHERE idTipoActividad = @idTipoActividad)
            BEGIN 
                RAISERROR('El tipo de actividad que se quiere elimnar no existe',16,1)
            END 

            UPDATE Area_Excursiones.Actividad 
            SET IdTipoActividad = 1
            WHERE IdTipoActividad = @idTipoActividad

            DELETE FROM Area_Excursiones.Tipo_Actividad
            WHERE idTipoActividad = @idTipoActividad
        COMMIT TRANSACTION
    END TRY 

    BEGIN CATCH
        --si hubo un error y la transaccion quedó abierta, revertimos
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION 
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END 
GO

-- //////////////////////////////////////////////////////////////
--            ELIMINACIÓN DE GUIA
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_EliminarGuia
    @IdGuia INT
AS
BEGIN 
    BEGIN TRY 
        SET NOCOUNT ON;

        -- Validar que el guía exista antes de intentar eliminarlo
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Guia WHERE IdGuia = @IdGuia)
        BEGIN
            RAISERROR('El guía con el Id proporcionado no existe.', 16, 1)
        END

        -- Iniciamos una transacción para asegurar la integridad de los datos
        BEGIN TRANSACTION;

        -- 1. Eliminar dependencias en la tabla Guias_por_actividad
        DELETE FROM Area_Excursiones.Guias_por_actividad
        WHERE IdGuia = @IdGuia;

        -- 2. Eliminar dependencias en la tabla Habilitaciones_Guias
        DELETE FROM Area_Excursiones.Habilitacion_Guia
        WHERE IdGuia = @IdGuia;

        -- 3. Finalmente, eliminar el registro de la tabla principal Guia
        DELETE FROM Area_Excursiones.Guia
        WHERE IdGuia = @IdGuia;

        -- Si llegamos hasta acá sin errores, confirmamos los cambios
        COMMIT TRANSACTION;

    END TRY

    BEGIN CATCH
        -- Si ocurre un error y hay una transacción abierta, deshacemos todos los cambios
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END 
GO
PRINT '-- #FIN DE CREACIÓN DE SP DE AREA EXCURSIONES --'
-----------------------------------------------------------------------
--                  CREACIÓN DE LOS SP DEL AREA INFRAESTRUCTURA      --
-----------------------------------------------------------------------
PRINT '-- #INICIO DE CREACIÓN DE SP DE AREA INFRAESTRUCTURA--'
GO

-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LOS GUARDAPARQUES
-- //////////////////////////////////////////////////////////////


CREATE OR ALTER PROCEDURE Area_Infraestructura.SP_CrearGuardaParque
	@Nombre VARCHAR(30),
	@Apellido VARCHAR(30),
	@Dni CHAR(8),
	@Parque VARCHAR(80),
	@Fecha_Ingreso DATE,
	@Fecha_Egreso DATE,
	@Activo BIT
AS
BEGIN
	BEGIN TRY
			
			-- Validamos nombre ingresado. Si es valido, quitamos espacios al string
			IF @Nombre ='' OR @Nombre LIKE '%[^a-zA-Z ]%' OR LEN(@Nombre) > 30
			BEGIN
				PRINT('El nombre ingresado no es valido')
				RAISERROR('.', 16,1)
			END
			SET @Nombre = TRIM(@Nombre)
			
			-- Validamos apellido ingresado. Si es valido, quitamos espacios al string
			IF @Apellido ='' OR @Apellido LIKE '%[^a-zA-Z ]%' OR LEN(@Apellido) > 30
			BEGIN
				PRINT('El apellido ingresado no es valido')
				RAISERROR('.', 16,1)
			END
			SET @Apellido = TRIM(@Apellido)

			-- El dni no puede ser repetido
			SET NOCOUNT ON;
			DECLARE @IdGuardaRepetido INT;
			SELECT @IdGuardaRepetido = g.IdGuardaparque FROM Area_Infraestructura.Guardaparque g WHERE g.Dni = @Dni;
			IF @IdGuardaRepetido IS NOT NULL
			BEGIN
				PRINT('Ya existe un guardaparque con ese dni')
				RETURN @IdGuardaRepetido;
			END

			-- El parque debe existir en la BBDD
			DECLARE @IdParque INT;
			SELECT @IdParque = p.IdParque FROM Area_Infraestructura.Parque p WHERE p.Nombre = @Parque;
			IF @IdParque IS NULL
			BEGIN
				PRINT('El parque ingresado no existe')
				RAISERROR('.', 16,1)
			END

			-- El campo activo solo puede ser 0 o 1
			IF @Activo NOT IN (0,1)
			BEGIN
				PRINT('El campo activo solo puede ser 0 o 1')
				RAISERROR('.', 16,1)
			END

			-- validaciones de fechas

			 -- La fecha de egreso no puede ser menor a la fecha de ingreso
			IF @Fecha_Egreso < @Fecha_Ingreso
			BEGIN
				PRINT('La fecha de egreso no puede ser menor a la fecha de ingreso')
				RAISERROR('.', 16,1)
			END

            DECLARE @FechaActual DATE
			SET @FechaActual = GETDATE()
			
			 -- La fecha de ingreso no puede ser mayor a la fecha actual
			IF @Fecha_Ingreso > @FechaActual
			BEGIN
				PRINT('La fecha de ingreso no puede ser mayor a la fecha actual')
				RAISERROR('.', 16,1)
			END

			 -- La fecha de egreso no puede ser mayor a la fecha actual
			IF @Fecha_Egreso > @FechaActual
			BEGIN
				PRINT('La fecha de egreso no puede ser mayor a la fecha actual')
				RAISERROR('.', 16,1)
			END

	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY()>10
		BEGIN	
			RAISERROR('Algo salio mal en el registro del guardaparque',16,1);
			RETURN;
		END
	END CATCH

	INSERT INTO Area_Infraestructura.Guardaparque(Nombre, Apellido, Dni, IdParque, Fecha_Ingreso, Fecha_Egreso, Activo) VALUES
	(@Nombre, @Apellido, @Dni, @IdParque, @Fecha_Ingreso, @Fecha_Egreso, @Activo);
	DECLARE @IdNuevoGuardaparque INT
	SET @IdNuevoGuardaparque = SCOPE_IDENTITY()
	RETURN @IdNuevoGuardaparque
END
GO

-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LOS PARQUES
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Infraestructura.SP_CrearParque 
	@Nombre VARCHAR(80),
	@TipoParqueDesc VARCHAR(50),
	@Provincia VARCHAR(80),
	@Superficie DECIMAL(14,4)
AS
BEGIN
	BEGIN TRY
			
			-- Validamos nombre ingresado. Si es valido, limpiamos el string
			IF @Nombre ='' OR @Nombre LIKE '%[^a-zA-Z ]%' OR LEN(@Nombre) > 80
			BEGIN
				PRINT('El nombre ingresado no es valido')
				RAISERROR('.', 16,1)
			END
			SET @Nombre = TRIM(@Nombre)

			-- El nombre no puede ser repetido
			SET NOCOUNT ON;
			DECLARE @IdParqueRepetido INT;
			SELECT @IdParqueRepetido = p.IdParque FROM Area_Infraestructura.Parque p WHERE p.Nombre = @Nombre;
			IF @IdParqueRepetido IS NOT NULL
			BEGIN
				PRINT('Ya existe un parque con ese nombre')
				RETURN @IdParqueRepetido;
			END

			-- Validamos provincia ingresada
			IF @Provincia = '' OR @Provincia LIKE '%[^a-zA-Z ]%' OR LEN(@Provincia) > 80
			BEGIN
				PRINT('La provincia ingresada no es valida')
				RAISERROR('.', 16,1)
			END

			-- La provincia debe existir en la bbdd
			DECLARE @IdProvincia INT;
			SELECT @IdProvincia = pr.IdProvincia FROM Area_Infraestructura.Provincia pr WHERE pr.Nombre = @Provincia;
			IF @IdProvincia IS NULL
			BEGIN
				PRINT('La provincia ingresada no existe')
				RAISERROR('.', 16,1)
			END

			-- Validamos tipo de parque ingresado
			IF @TipoParqueDesc = '' OR @TipoParqueDesc LIKE '%[^a-zA-Z ]%' OR LEN(@TipoParqueDesc) > 80
			BEGIN
				PRINT('El tipo de parque ingresado no es valido')
				RAISERROR('.', 16,1)
			END

			-- EL tipo de parque debe estar cargado en la bbdd
			DECLARE @IdTipoParque INT;
			SELECT @IdTipoParque = t.IdTipoParque FROM Area_Infraestructura.Tipo_Parque t WHERE t.Descripcion = @TipoParqueDesc;
			IF @IdTipoParque IS NULL
			BEGIN
				PRINT('El tipo de parque ingresado no existe')
				RAISERROR('.', 16,1)
			END

			-- La superficie debe ser un valor decimal valido
			IF @Superficie = 0
			BEGIN
				PRINT('El valor de la superficie no es una dimension valida')
				RAISERROR('.', 16,1)
			END

	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY()>10
		BEGIN	
			RAISERROR('Algo salio mal en el registro del parque',16,1);
			RETURN;
		END
	END CATCH

	INSERT INTO Area_Infraestructura.Parque(IdProvincia, IdTipoParque, Nombre, Superficie, Activo) VALUES
	(@IdProvincia, @IdTipoParque, @Nombre, @Superficie, 1);
	DECLARE @IdNuevoParque INT
	SET @IdNuevoParque = SCOPE_IDENTITY()
	RETURN @IdNuevoParque
END
GO
-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LAS REGIONES
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Infraestructura.SP_CrearRegion
    @Nombre VARCHAR(80)
AS
BEGIN
    BEGIN TRY

        -- Validamos nombre ingresado. Si es valido, quitamos espacios al string
        IF @Nombre ='' OR @Nombre LIKE '%[^a-zA-Z ]%' OR LEN(@Nombre) > 80
        BEGIN
            PRINT('El nombre ingresado no es valido')
            RAISERROR('.', 16,1)
        END
        SET @Nombre = TRIM(@Nombre)

        -- El nombre no puede ser repetido
        SET NOCOUNT ON;
        DECLARE @IdRegionRepetida INT;
        SELECT @IdRegionRepetida = r.IdRegion FROM Area_Infraestructura.Region r WHERE r.Nombre = @Nombre;
        IF @IdRegionRepetida IS NOT NULL
        BEGIN
            PRINT('Ya existe una region con ese nombre')
            RETURN @IdRegionRepetida;
        END
        
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY()>10
        BEGIN	
            RAISERROR('Algo salio mal en el registro de la region',16,1);
            RETURN;
        END
    END CATCH
    
    INSERT INTO Area_Infraestructura.Region(Nombre) VALUES (@Nombre)
    DECLARE @IdNuevaRegion INT
	SET @IdNuevaRegion = SCOPE_IDENTITY()
	RETURN @IdNuevaRegion
END
GO

-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LAS PROVINCIAS
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Infraestructura.SP_CrearProvincia
    @Nombre VARCHAR(80),
    @NombreRegion VARCHAR(30)
AS
BEGIN
    BEGIN TRY
        -- Validamos nombre ingresado. Si es valido, quitamos espacios al string
        IF @Nombre ='' OR @Nombre LIKE '%[^a-zA-Z ]%' OR LEN(@Nombre) > 80
        BEGIN
            PRINT('El nombre ingresado no es valido')
            RAISERROR('.', 16,1)
        END
        SET @Nombre = TRIM(@Nombre)

        -- El nombre no puede ser repetido
        SET NOCOUNT ON;
        DECLARE @IdProvinciaRepetida INT;
        SELECT @IdProvinciaRepetida = p.IdProvincia FROM Area_Infraestructura.Provincia p WHERE p.Nombre = @Nombre;
        IF @IdProvinciaRepetida IS NOT NULL
        BEGIN
            PRINT('Ya existe una provincia con ese nombre')
            RETURN @IdProvinciaRepetida;
        END

        -- Validamos region ingresada. Si es valida, quitamos espacios al string
        IF @NombreRegion = '' OR @NombreRegion LIKE '%[^a-zA-Z ]%' OR LEN(@NombreRegion) > 80
        BEGIN
            PRINT('La region ingresada no es valida')
            RAISERROR('.', 16,1)
        END
        SET @NombreRegion = TRIM(@NombreRegion)

        -- La region debe existir en la bbdd
        DECLARE @IdRegion INT;
        SELECT @IdRegion = r.IdRegion FROM Area_Infraestructura.Region r WHERE r.Nombre = @NombreRegion;
        IF @IdRegion IS NULL
        BEGIN
            PRINT('La region ingresada no existe')
            RAISERROR('.', 16,1)
        END
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY()>10
        BEGIN	
            RAISERROR('Algo salio mal en el registro de la provincia',16,1);
            RETURN;
        END
    END CATCH
    
    INSERT INTO Area_Infraestructura.Provincia(Nombre, IDRegion) VALUES (@Nombre, @IdRegion)
    DECLARE @IdNuevaProvincia INT
	SET @IdNuevaProvincia = SCOPE_IDENTITY()
	RETURN @IdNuevaProvincia
END
GO
-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LOS TIPOS DE PARQUE
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Infraestructura.SP_CrearTipoParque
    @Descripcion VARCHAR(50)
AS
BEGIN
    BEGIN TRY

        -- Validamos descripcion ingresada. Si es valida, quitamos espacios al string
        IF @Descripcion ='' OR @Descripcion LIKE '%[^a-zA-Z ]%' OR LEN(@Descripcion) > 50
        BEGIN
            PRINT('La descripcion ingresada no es valida')
            RAISERROR('.', 16,1)
        END
        SET @Descripcion = TRIM(@Descripcion)

        -- La descripcion no puede ser repetida
        SET NOCOUNT ON;
        DECLARE @IdTipoParqueRepetido INT;
        SELECT @IdTipoParqueRepetido = tp.IdTipoParque FROM Area_Infraestructura.Tipo_Parque tp WHERE tp.Descripcion = @Descripcion;
        IF @IdTipoParqueRepetido IS NOT NULL
        BEGIN
            PRINT('Ya existe un tipo de parque con esa descripcion')
            RETURN @IdTipoParqueRepetido;
        END

    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY()>10
        BEGIN	
            RAISERROR('Algo salio mal en el registro deL tipo de parque',16,1);
            RETURN;
        END
    END CATCH

    INSERT INTO Area_Infraestructura.Tipo_Parque(Descripcion) VALUES (@Descripcion)
    DECLARE @IdNuevoTipoParque INT
	SET @IdNuevoTipoParque = SCOPE_IDENTITY()
	RETURN @IdNuevoTipoParque
END
GO

-- //////////////////////////////////////////////////////////////
--                  APARTADO 2: SPs de Modificación
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
--                  MODIFICACIÓN DE GUARDAPARQUES
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_ModificarGuardaparque
    @IdGuardaparque INT,
    @Dni CHAR(8) = NULL,
    @Nombre VARCHAR(30) = NULL,
    @Apellido VARCHAR(30) = NULL,
    @Fecha_Ingreso DATE = NULL,
    @Fecha_Egreso DATE = NULL
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		-- Validamos existencia
		IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Guardaparque WHERE IdGuardaparque = @IdGuardaparque)
		BEGIN
			PRINT('No existe un guardaparque con el Id proporcionado.');
			RETURN;
		END

		-- Modificar Nombre
		IF @Nombre IS NOT NULL AND @Nombre <> ''
		BEGIN
			SET @Nombre = TRIM(@Nombre);
			IF @Nombre LIKE '%[^a-zA-Z ]%' OR LEN(@Nombre) > 25
			BEGIN
				PRINT('El nombre no es v lido');
				RAISERROR('.', 16, 1);
			END

			UPDATE Area_Infraestructura.Guardaparque
			SET Nombre = @Nombre
			WHERE IdGuardaparque = @IdGuardaparque;
		END

		-- Modificar Apellido
		IF @Apellido IS NOT NULL AND @Apellido <> ''
		BEGIN
			SET @Apellido = TRIM(@Apellido);
			IF @Apellido LIKE '%[^a-zA-Z ]%' OR LEN(@Apellido) > 25
			BEGIN
				PRINT('El apellido no es v lido');
				RAISERROR('.', 16, 1);
			END

			UPDATE Area_Infraestructura.Guardaparque
			SET Apellido = @Apellido
			WHERE IdGuardaparque = @IdGuardaparque;
		END

		-- Modificar DNI
		IF @DNI IS NOT NULL AND @DNI <> ''
		BEGIN
			SET @DNI = TRIM(@DNI);
			IF @DNI LIKE '%[^0-9]%' OR LEN(@DNI) > 10
			BEGIN
				PRINT('El DNI no es v lido');
				RAISERROR('.', 16, 1);
			END

			-- Validar que no exista otro guardaparque con el mismo DNI
			IF EXISTS (
				SELECT 1 FROM Area_Infraestructura.Guardaparque 
				WHERE DNI = @DNI AND IdGuardaparque <> @IdGuardaparque
			)
			BEGIN
				PRINT('Ya existe otro guardaparque con el DNI ingresado.');
				RAISERROR('.', 16, 1);
			END

			UPDATE Area_Infraestructura.Guardaparque
			SET DNI = @DNI
			WHERE IdGuardaparque = @IdGuardaparque;
		END

        -- Modificar Fecha de Ingreso
        IF @Fecha_Ingreso IS NOT NULL
        BEGIN
            IF @Fecha_Ingreso > GETDATE()
            BEGIN
                PRINT('La fecha de ingreso no puede ser futura.');
                RAISERROR('.', 16, 1);
            END

            UPDATE Area_Infraestructura.Guardaparque
            SET Fecha_Ingreso = @Fecha_Ingreso
            WHERE IdGuardaparque = @IdGuardaparque;
        END

        -- Modificar Fecha de Egreso
        IF @Fecha_Egreso IS NOT NULL
        BEGIN
            IF @Fecha_Egreso < @Fecha_Ingreso OR @Fecha_Egreso > GETDATE()
            BEGIN
                PRINT('La fecha de egreso no puede ser anterior a la fecha de ingreso.');
                RAISERROR('.', 16, 1);
            END

            UPDATE Area_Infraestructura.Guardaparque
            SET Fecha_Egreso = @Fecha_Egreso
            WHERE IdGuardaparque = @IdGuardaparque;
        END

		PRINT('Guardaparque actualizado correctamente.');
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrió  un error al modificar el guardaparque.', 16, 1);
			RETURN;
		END
	END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--                  MODIFICACIÓN DE PARQUES
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_ModificarParque
	@IdParque INT,
	@Provincia VARCHAR(30) = NULL,
	@TipoParque VARCHAR(30) = NULL,
	@Nombre VARCHAR(80) = NULL,
	@Superficie DECIMAL(14,4) = NULL,
	@Activo BIT = NULL
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		-- Validamos existencia
		IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @IdParque)
		BEGIN
			PRINT('No existe un parque con el Id proporcionado.');
			RETURN;
		END

		-- Modificar Nombre
		IF @Nombre IS NOT NULL AND @Nombre <> ''
		BEGIN
			SET @Nombre = TRIM(@Nombre);
			IF @Nombre LIKE '%[^a-zA-Z ]%' OR LEN(@Nombre) > 25
			BEGIN
				PRINT('El nombre no es v lido');
				RAISERROR('.', 16, 1);
			END

			UPDATE Area_Infraestructura.Parque
			SET Nombre = @Nombre
			WHERE IdParque = @IdParque;
		END

		-- Modificar Provincia
		IF @Provincia IS NOT NULL AND @Provincia <> ''
		BEGIN
			SET @Provincia = TRIM(@Provincia);
			IF @Provincia LIKE '%[^a-zA-Z ]%' OR LEN(@Provincia) > 30
			BEGIN
				PRINT('El apellido no es v lido');
				RAISERROR('.', 16, 1);
			END
			IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Provincia WHERE Nombre = @Provincia)
			BEGIN
				PRINT('La provincia no es valida');
				RAISERROR('.',18,1);
			END
			DECLARE @IdDeProvinciaNueva INT;
			SELECT @IdDeProvinciaNueva = IdProvincia FROM Area_Infraestructura.Provincia WHERE Nombre = @Provincia
			UPDATE Area_Infraestructura.Parque
			SET IdProvincia = @IdDeProvinciaNueva
			WHERE IdParque = @IdParque;
		END

		-- Modificar Tipo de Parque
		IF @TipoParque IS NOT NULL AND @TipoParque <> ''
		BEGIN
			SET @TipoParque = TRIM(@TipoParque);
			IF @TipoParque LIKE '%[^a-zA-Z ]%' OR LEN(@TipoParque) > 30
			BEGIN
				PRINT('El tipo de parque no es valido');
				RAISERROR('.', 16, 1);
			END
			IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Tipo_Parque WHERE Descripcion = @TipoParque)
			BEGIN
				PRINT('El tipo de parque no es valido');
				RAISERROR('.',16,1);
			END
			DECLARE @IdDeTipoParqueNuevo INT;
			SELECT  @IdDeTipoParqueNuevo = IdProvincia FROM Area_Infraestructura.Provincia WHERE Nombre = @Provincia
			UPDATE Area_Infraestructura.Parque
			SET IdTipoParque = @IdDeTipoParqueNuevo
			WHERE IdParque = @IdParque;
		END

		-- Modificar Superficie
		IF @Superficie IS NULL OR @Superficie < 0
		BEGIN
            PRINT('La superficie no es valida');
            RAISERROR('.', 16, 1);
		END
        UPDATE Area_Infraestructura.Parque
		SET Superficie = @Superficie
		WHERE IdParque = @IdParque;

		-- Modficar si esta o no activo
		IF @Activo IS NOT NULL
		BEGIN
			UPDATE Area_Infraestructura.Parque
			SET Activo = @Activo
			WHERE IdParque = @IdParque;
		END

		PRINT('Parque actualizado correctamente.');
	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrió  un error al modificar el parque.', 16, 1);
			RETURN;
		END
	END CATCH
END
GO

-- //////////////////////////////////////////////////////////////
--                  MODIFICACIÓN DE REGIONES
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Infraestructura.SP_ModificarProvincia
    @IdProvincia INT,
    @Nombre VARCHAR(80) = NULL,
    @NombreRegion VARCHAR(30) = NULL
AS
BEGIN
    BEGIN TRY

        -- Validamos que la provincia exista
        IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Provincia WHERE IdProvincia = @IdProvincia)
        BEGIN
            RAISERROR('La provincia ingresada no existe', 16,1)
        END

        -- Validamos nombre ingresado. Si es valido, quitamos espacios al string
        IF @Nombre is not null AND (@Nombre ='' OR @Nombre LIKE '%[^a-zA-Z ]%' OR LEN(@Nombre) > 80)
        BEGIN
            RAISERROR('El nombre ingresado no es valido', 16,1)
            RETURN;
        END
        SET @Nombre = TRIM(@Nombre)

        -- El nombre no puede ser repetido
        SET NOCOUNT ON;
        DECLARE @IdProvinciaRepetida INT;
        SELECT @IdProvinciaRepetida = p.IdProvincia FROM Area_Infraestructura.Provincia p WHERE p.Nombre = @Nombre;
        IF @IdProvinciaRepetida IS NOT NULL
        BEGIN
            RAISERROR('Ya existe una provincia con ese nombre', 16,1)
            RETURN @IdProvinciaRepetida;
        END

        -- Validamos region ingresada. Si es valida, quitamos espacios al string
        IF @NombreRegion is not null AND (@NombreRegion = '' OR @NombreRegion LIKE '%[^a-zA-Z ]%' OR LEN(@NombreRegion) > 80)
        BEGIN
            RAISERROR('La region ingresada no es valida', 16,1)
            RETURN;
        END
        SET @NombreRegion = TRIM(@NombreRegion)

        -- La region debe existir en la bbdd
        DECLARE @IdRegion INT;
        SELECT @IdRegion = r.IdRegion FROM Area_Infraestructura.Region r WHERE r.Nombre = @NombreRegion;
        IF @IdRegion IS NULL
        BEGIN
            RAISERROR('La region ingresada no existe', 16,1)
            RETURN;
        END

        UPDATE Area_Infraestructura.Provincia SET Nombre = @Nombre, IDRegion = @IdRegion WHERE IdProvincia = @IdProvincia
    
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY()>10
        BEGIN	
            DECLARE @ErrorMessage VARCHAR(255) = ERROR_MESSAGE();
            RAISERROR('Algo salio mal en el registro de la provincia: %s', 16,1, @ErrorMessage);
            RETURN;
        END
    END CATCH
END
GO


-- //////////////////////////////////////////////////////////////
--                  MODIFICACIÓN DE REGIONES
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_ModificarTipoParque
	@IdTipoParque INT,
	@Descripcion VARCHAR(50) = NULL
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		-- Validamos existencia
		IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Tipo_Parque WHERE IdTipoParque = @IdTipoParque)
		BEGIN
			PRINT('No existe un tipo de parque con el Id proporcionado.');
			RETURN;
		END

		-- Modificar Descripción
		IF @Descripcion IS NOT NULL AND @Descripcion <> ''
		BEGIN
			SET @Descripcion = TRIM(@Descripcion);
			IF @Descripcion LIKE '%[^a-zA-Z ]%' OR LEN(@Descripcion) > 50
			BEGIN
				PRINT('La descripción no es válida');
				RAISERROR('.', 16, 1);
			END

			UPDATE Area_Infraestructura.Tipo_Parque
			SET Descripcion = @Descripcion
			WHERE IdTipoParque = @IdTipoParque;
		END

	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrió  un error al modificar el tipo de parque.', 16, 1);
			RETURN;
		END
	END CATCH
END
GO

-- //////////////////////////////////////////////////////////////
--                  MODIFICACIÓN DE TIPOS DE PARQUE
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_ModificarRegion
	@IdRegion INT,
	@Nombre VARCHAR(50) = NULL
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		-- Validamos existencia
		IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Region WHERE IdRegion = @IdRegion)
		BEGIN
			PRINT('No existe una región con el Id proporcionado.');
			RETURN;
		END

		-- Modificar Nombre
		IF @Nombre IS NOT NULL AND @Nombre <> ''
		BEGIN
			SET @Nombre = TRIM(@Nombre);
			IF @Nombre LIKE '%[^a-zA-Z ]%' OR LEN(@Nombre) > 50
			BEGIN
				PRINT('El nombre no es válido');
				RAISERROR('.', 16, 1);
			END

			UPDATE Area_Infraestructura.Region
			SET Nombre = @Nombre
			WHERE IdRegion = @IdRegion;
		END

	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrió  un error al modificar la región.', 16, 1);
			RETURN;
		END
	END CATCH
END
GO

-- //////////////////////////////////////////////////////////////
--                  APARTADO 3: SPs de Eliminación
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
--                  ELIMINACIÓN DE GUARDAPARQUES
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Infraestructura.SP_EliminarGuardaparque
    @IdGuardaparque INT
AS
BEGIN
    BEGIN TRY

        -- Validamos que el IdGuardaparque ingresado exista en la BBDD
        SET NOCOUNT ON;
        DECLARE @IdGuardaparqueExistente INT;
        SELECT @IdGuardaparqueExistente = g.IdGuardaparque FROM Area_Infraestructura.Guardaparque g WHERE g.IdGuardaparque = @IdGuardaparque;
        IF @IdGuardaparqueExistente IS NULL
        BEGIN
            PRINT('No existe un guardaparque con ese Id')
            RETURN;
        END

    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY()>10
        BEGIN	
            RAISERROR('Algo salio mal en la eliminacion del guardaparque',16,1);
            RETURN;
        END
    END CATCH
    DELETE FROM Area_Infraestructura.Historial_Trabajo_Guardaparque WHERE IdGuardaparque = @IdGuardaparque;
    DELETE FROM Area_Infraestructura.Guardaparque WHERE IdGuardaparque = @IdGuardaparque;
END
GO
-- //////////////////////////////////////////////////////////////
--                  ELIMINACIÓN DE PARQUES
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_EliminarParque
    @IdParque INT
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        -- Validamos existencia
        IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @IdParque)
        BEGIN
            PRINT('No existe un parque con el Id proporcionado.');
            RAISERROR('', 16, 1);
            RETURN;
        END

        -- Borrado lógico del parque
        UPDATE Area_Infraestructura.Parque
        SET Activo = 0
        WHERE IdParque = @IdParque;

    END TRY

    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
        BEGIN
            RAISERROR('Ocurrió un error al eliminar el parque.', 16, 1);
            RETURN;
        END
    END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--                  ELIMINACIÓN DE PROVINCIA
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_EliminarProvincia
	@IdProvincia INT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		-- Validamos existencia
		IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Provincia WHERE IdProvincia = @IdProvincia)
		BEGIN
			PRINT('No existe una provincia con el Id proporcionado.');
			RETURN;
		END

        -- Seteamos en null la región para los parques que lo tengan asignado
        UPDATE Area_Infraestructura.Parque
        SET IdProvincia = NULL
        WHERE IdProvincia = @IdProvincia;

		-- Eliminar provincia
		DELETE FROM Area_Infraestructura.Provincia
		WHERE IdProvincia = @IdProvincia;

	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrió  un error al eliminar la provincia.', 16, 1);
			RETURN;
		END
	END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--                  ELIMINACIÓN DE REGIÓN
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_EliminarRegion
	@IdRegion INT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		-- Validamos existencia
		IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Region WHERE IdRegion = @IdRegion)
		BEGIN
			PRINT('No existe una región con el Id proporcionado.');
			RETURN;
		END

        -- Seteamos en null la región para las provincias que la tengan asignado
        UPDATE Area_Infraestructura.Provincia
        SET IdRegion = NULL
        WHERE IdRegion = @IdRegion;

		-- Eliminar región
		DELETE FROM Area_Infraestructura.Region
		WHERE IdRegion = @IdRegion;

	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrió  un error al eliminar la región.', 16, 1);
			RETURN;
		END
	END CATCH
END
GO
--/////////////////////////////////////////////////////////////
-- Eliminación de Tipo parque
-- /////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_EliminarTipoParque
	@IdTipoParque INT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		-- Validamos existencia
		IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Tipo_Parque WHERE IdTipoParque = @IdTipoParque)
		BEGIN
			PRINT('No existe un tipo de parque con el Id proporcionado.');
			RETURN;
		END

        -- Seteamos en null el tipo para los parques que lo tengan asignado
        UPDATE Area_Infraestructura.Parque
        SET IdTipoParque = NULL
        WHERE IdTipoParque = @IdTipoParque;

		-- Eliminar tipo de parque
		DELETE FROM Area_Infraestructura.Tipo_Parque
		WHERE IdTipoParque = @IdTipoParque;

	END TRY

	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN
			RAISERROR('Ocurrió  un error al eliminar el tipo de parque.', 16, 1);
			RETURN;
		END
	END CATCH
END
GO

PRINT '-- #FIN DE CREACIÓN DE SP DE AREA INFRAESTRUCTURA--'
-----------------------------------------------------------------------
--                  CREACIÓN DE LOS SP DEL AREA DE NEGOCIOS          --
-----------------------------------------------------------------------
PRINT '-- #INICIO DE CREACIÓN DE SP DE AREA DE NEGOCIOS--'
GO
-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LOS CANONES
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Negocios.SP_CrearCanon
    @IdEstado INTEGER,
    @IdConcesion INTEGER,
    @Monto_Mensual DECIMAL(13,3),
    @Fecha_Vencimiento DATE
AS
BEGIN
	BEGIN TRY
        -- Busca el IdEstado en la tabla de Estados.
       IF NOT EXISTS ( SELECT 1 FROM Area_Negocios.Estado_Canon WHERE IdEstadoCanon = @IdEstado)
        BEGIN
            PRINT('No Existe el Estado de canon Ingresado')
            RAISERROR('EstadoCanon Invalido',16,1)
        END
        --Busca el IdConcesion en la tabla de Concesiones.
        IF NOT EXISTS ( SELECT 1 FROM Area_Negocios.Concesion WHERE IdConcesion = @IdConcesion)
        BEGIN
            PRINT('No Existe la Concesión Ingresada')
            RAISERROR('Concesión Invalida',16,1)
        END

        -- Valida el Monto ingresado
        IF @Monto_Mensual IS NULL OR  @Monto_Mensual <= 0 
        BEGIN
            PRINT('El Monto Ingresado no es valido, debe ser mayor a 0')
            RAISERROR('Monto Invalido',16,1)
        END
        -- Valida la fecha ingresada, comprobando que no sea nula.
		IF @Fecha_Vencimiento IS NULL
		BEGIN
            PRINT('La fecha no puede ser nula')
            RAISERROR('Fecha Invalida', 16, 1)
        END

        IF @Fecha_Vencimiento < CAST(GETDATE() AS DATE)
        BEGIN
            RAISERROR('La fecha de vencimiento no puede ser anterior a la fecha actual.', 16, 1);
            RAISERROR('Fecha Invalida', 16, 1)
        END
            INSERT INTO Area_Negocios.Canon(IdEstado,IdConcesion,Monto_Mensual,Fecha_Vencimiento) VALUES (@IdEstado,@IdConcesion,@Monto_Mensual,@Fecha_Vencimiento)

    END TRY
    BEGIN CATCH
        -- Lanzamos return
            DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
            DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
            DECLARE @ErrorState INT = ERROR_STATE();
            RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
            Return;
    END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LAS CONCESIONES
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Negocios.SP_CrearConcesion
    @IdTipoActividadConcesion INTEGER,
    @IdEmpresa INTEGER,
    @IdParque INTEGER,
    @Fecha_Inicio DATE,
    @Fecha_Fin DATE
AS
BEGIN
	BEGIN TRY
        -- Busca el Id del TipoActividad en la tabla de Tipo_Actividad_Concesion.
       IF NOT EXISTS ( SELECT 1 FROM Area_Negocios.Tipo_Actividad_Concesion WHERE IdTipoActividadConcesion = @IdTipoActividadConcesion)
        BEGIN
            RAISERROR('No Existe el Tipo de actividad de concesion ingresada',16,1)
        END
        --Busca la empresa en la tabla de Empresa_Concesionaria.
        --No solo verificar si existe si no si está activa también
        IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Empresa_Concesionaria WHERE IdEmpresa = @IdEmpresa AND Estado = 1)
        BEGIN
            RAISERROR('No Existe la Empresa concesionaria o no esta activa actualmente',16,1)
        END
        --Busca el parque en la tabla de Parques
        IF NOT EXISTS ( SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @IdParque)
        BEGIN
            RAISERROR('No Existe el parque Ingresado',16,1)
        END

        -- Valida la fecha de inicio ingresada, comprobando que no sea nula.
		IF @Fecha_Inicio IS NULL
		BEGIN
            RAISERROR('La fecha de Inicio no puede ser nula', 16, 1)
        END
        -- Valida la fecha de fin ingresada, comprobando que no sea nula.
		IF @Fecha_Fin IS NULL
		BEGIN
            RAISERROR('La fecha de Fin no puede ser nula', 16, 1)
        END

        --Obviamente la fecha de Fin debe ser mayor que la de inicio y no puede finalizar el mismo día que inicia la concesión, ya que no tendría sentido.
        IF @Fecha_Fin <= @Fecha_Inicio
        BEGIN
            RAISERROR('La fecha de finalización debe ser estrictamente posterior a la fecha de inicio.', 16, 1);
        END

        INSERT INTO Area_Negocios.Concesion(IdTipoActividadConcesion,IdEmpresa,IdParque,Fecha_Inicio,Fecha_Fin) VALUES (@IdTipoActividadConcesion,@IdEmpresa,@IdParque,@Fecha_Inicio,@Fecha_Fin)

    END TRY
    BEGIN CATCH
        -- Lanzamos return	
        DECLARE @ErrorMessage VARCHAR(255) = ERROR_MESSAGE();
        RAISERROR('Error al crear la Concesión: %s', 16, 1, @ErrorMessage);
        Return;
    END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--              CREACIÓN DE LAS EMPRESAS CONCESIONARIAS
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Negocios.SP_CrearEmpresaConcesionaria
	@Nombre varchar(150)
AS
BEGIN
	BEGIN TRY
        -- Validamos nombre ingresado.
        IF  @Nombre IS NULL OR @Nombre ='' OR NOT @Nombre NOT LIKE '%[^a-zA-ZñÑ. ]%' OR LEN(@Nombre) > 80 
        BEGIN
            PRINT('El nombre de la empresa ingresado no es valido')
            RAISERROR('Nombre Invalido', 16,1)
        END
        -- Se busca que el nombre no sea repetido
        DECLARE @IdNombreEmpresaRepe INT;
        SELECT @IdNombreEmpresaRepe = IdEmpresa FROM Area_Negocios.Empresa_Concesionaria WHERE Nombre = @Nombre;
        IF @IdNombreEmpresaRepe IS NOT NULL
        BEGIN
            PRINT('Ya existe una empresa con ese nombre')
            RAISERROR('Nombre Invalido',16,1)
        END
        INSERT INTO Area_Negocios.Empresa_Concesionaria(Nombre, Estado) VALUES (@Nombre, 1)
    END TRY
    BEGIN CATCH
        -- Lanzamos Rollback
            RAISERROR('Algo salio mal en el registro del nombre de la empresa',16,1);
            RETURN;
    END CATCH
    
END
GO
-- //////////////////////////////////////////////////////////////
--              CREACIÓN DE LOS ESTADOS DE CANON
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Negocios.SP_CrearEstadoCanon
	@Descripcion varchar(150)
AS
BEGIN
	BEGIN TRY
        -- Validamos descripcion ingresada.
        IF @Descripcion IS NULL OR @Descripcion ='' OR @Descripcion LIKE '%[^a-zA-ZñÑ. ]%'  OR LEN(@Descripcion) > 100
        BEGIN
            PRINT('La descripcion ingresada no es valida')
            RAISERROR('Descripcion Invalida', 16,1)
        END
        -- Validamos que la descripcion no se encuentra ya registrada
        IF EXISTS (SELECT 1 FROM Area_Negocios.Estado_Canon WHERE Descripcion = @Descripcion)
        BEGIN
            PRINT('La descripcion ingresada ya se encuentra registrada')
            RAISERROR('Descripcion Invalida', 16,1)
        END
        INSERT INTO Area_Negocios.Estado_Canon(Descripcion) VALUES (@Descripcion)  
    END TRY
    BEGIN CATCH
        -- Lanzamos Return
            RAISERROR('Algo salio mal en la creación del estado del canon',16,1);
            RETURN;
    END CATCH
     
END
GO

-- //////////////////////////////////////////////////////////////
--              CREACIÓN DE LOS PAGOS DE CANON
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Negocios.SP_CrearPagoCanon
	@IdCanon INTEGER,
    @Monto_Abonado DECIMAL(13,3),
    @Fecha_Pago DATE
AS
BEGIN
	BEGIN TRY
        -- Busca el IdCanon en la tabla de Canon.
        --Verifica que existe
       IF NOT EXISTS ( SELECT 1 FROM Area_Negocios.Canon WHERE IdCanon = @IdCanon)
        BEGIN
            PRINT('No Existe el Canon Ingresado')
            RAISERROR('Canon Invalido',16,1)
        END
        -- Valida el Monto ingresado
        IF  @Monto_Abonado IS NULL OR  @Monto_Abonado <= 0 
        BEGIN
            PRINT('El Monto Ingresado no es valido')
            RAISERROR('Monto Invalido',16,1)
        END
        -- Valida la fecha ingresada, comprobando que no sea nula.
		IF @Fecha_Pago IS NULL
		BEGIN
            PRINT('La fecha no puede ser nula')
            RAISERROR('Fecha Invalida', 16, 1)
        END
        INSERT INTO Area_Negocios.Pago_Canon(IdCanon,Monto_Abonado,Fecha_Pago) VALUES (@IdCanon,@Monto_Abonado,@Fecha_Pago)
    END TRY
    BEGIN CATCH
        -- Lanzamos return	
            RAISERROR('Algo salio mal en la creación del pago del canon',16,1);
            Return;
    END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--              CREACIÓN DE LOS TIPOS DE ACTIVIDAD
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Negocios.SP_CrearTipoActividadConcesion
	@Descripcion varchar(150)
AS
BEGIN
	BEGIN TRY
        -- Validamos descripcion ingresada.
        IF @Descripcion IS NULL OR @Descripcion ='' OR @Descripcion LIKE '%[^a-zA-ZñÑ. ]%' OR LEN(@Descripcion)>100 
        BEGIN
            PRINT('La descripcion ingresada no es valida')
            RAISERROR('Descripcion Invalida', 16,1)
        END
        -- Validamos que la descripcion no se encuentra ya registrada
        IF EXISTS (SELECT 1 FROM Area_Negocios.Tipo_Actividad_Concesion WHERE Descripcion = @Descripcion)
        BEGIN
            PRINT('La descripcion ingresada ya se encuentra registrada')
            RAISERROR('Descripcion Invalida', 16,1)
        END
        INSERT INTO Area_Negocios.Tipo_Actividad_Concesion(Descripcion) VALUES (@Descripcion)
    END TRY
    BEGIN CATCH
        -- Lanzamos RETURN
            RAISERROR('Algo salio mal en la creación del Tipo de actividad de Concesion',16,1);
            RETURN;
    END CATCH
    
END
GO

-- //////////////////////////////////////////////////////////////
--              Apartado 2: SPs de Modificación
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
--              MODIFICACIÓN DE LOS CANON
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Negocios.SP_ModificarCanon
	@IdCanon Integer,
	@IdEstadoCanon INT,
    @IdConcesion INTEGER,
    @Monto_Mensual DECIMAL(13,3),
    @Fecha_Vencimiento DATE
AS
BEGIN
	BEGIN TRY
		--Busca el Canon verificando que existe en la base de datos
		IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Canon WHERE IdCanon = @IdCanon)
        BEGIN
            PRINT('Canon inexistente')
            RAISERROR('Canon Inexistente', 16, 1)
        END
		--Busca el Estado Canon verificando que existe en la base de datos
		IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Estado_Canon WHERE IdEstadoCanon = @IdEstadoCanon)
        BEGIN
            PRINT('Estado de Canon inexistente')
            RAISERROR('Estado de Canon Inexistente', 16, 1)
        END

		--Busca la Concesión verificando que existe en la base de datos
		IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Concesion WHERE IdConcesion = @IdConcesion)
        BEGIN
            PRINT('Concesión inexistente')
            RAISERROR('Concesión Inexistente', 16, 1)
        END
		 -- Valida el Monto ingresado
        IF NOT @Monto_Mensual > 0 OR @Monto_Mensual IS NULL 
        BEGIN
            PRINT('El Monto Ingresado no es valido')
            RAISERROR('Monto Invalido',16,1)
        END
        -- Valida la fecha ingresada, comprobando que no sea nula.
		IF @Fecha_Vencimiento IS NULL
		BEGIN
            PRINT('La fecha no puede ser nula')
            RAISERROR('Fecha Invalida', 16, 1)
        END
		IF @Fecha_Vencimiento < CAST(GETDATE() AS DATE)
		BEGIN
			PRINT('La fecha no puede ser anterior al dia actual')
			RAISERROR('La fecha de vencimiento no puede ser anterior a la fecha actual.', 16, 1);
		END
		UPDATE Area_Negocios.Canon 
		SET  IdEstado = @IdEstadoCanon,
		IdConcesion = @IdConcesion,
		Monto_Mensual = @Monto_Mensual,
		Fecha_Vencimiento = @Fecha_Vencimiento
		WHERE IdCanon = @IdCanon 
	END TRY
	BEGIN CATCH
        -- Lanzar return
			RAISERROR('Algo salio mal en la modificación del Canon', 16, 1);
			RETURN;
	END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--              MODIFICACIÓN DE LAS CONCESIONES
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Negocios.SP_ModificarConcesion
    @IdConcesion INTEGER,
    @IdTipoActividadConcesion INTEGER,
    @IdEmpresa INTEGER,
    @IdParque INTEGER,
    @Fecha_Inicio DATE,
    @Fecha_Fin DATE
AS
BEGIN
	BEGIN TRY

        -- Se verifica que la concesión exista
        IF NOT EXISTS ( SELECT 1 FROM Area_Negocios.Concesion WHERE IdConcesion = @IdConcesion)
        BEGIN
            PRINT('No Existe la concesión ingresada')
            RAISERROR('Concesión Invalida',16,1)
        END
        -- Busca el Id del TipoActividad en la tabla de Tipo_Actividad_Concesion.
       IF NOT EXISTS ( SELECT 1 FROM Area_Negocios.Tipo_Actividad_Concesion WHERE IdTipoActividadConcesion = @IdTipoActividadConcesion)
        BEGIN
            PRINT('No Existe el Tipo de actividad ingresada')
            RAISERROR('TipoActividad Invalida',16,1)
        END
        --Busca la empresa en la tabla de Empresa_Concesionaria.
        --No solo verificar si existe si no si está activa también
        IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Empresa_Concesionaria WHERE IdEmpresa = @IdEmpresa AND Estado = 1)
        BEGIN
            PRINT('No Existe la Empresa concesionaria o no esta activa actualmente')
            RAISERROR('EmpresaConcesionaria Invalida',16,1)
        END
        --Busca el parque en la tabla de Parques
        IF NOT EXISTS ( SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @IdParque)
        BEGIN
            PRINT('No Existe el parque Ingresado')
            RAISERROR('Parque Invalido',16,1)
        END

        -- Valida la fecha de inicio ingresada, comprobando que no sea nula.
		IF @Fecha_Inicio IS NULL
		BEGIN
            PRINT('La fecha de Inicio no puede ser nula')
            RAISERROR('Fecha Inicio Inválida', 16, 1)
        END
        -- Valida la fecha de fin ingresada, comprobando que no sea nula.
		IF @Fecha_Fin IS NULL
		BEGIN
            PRINT('La fecha de Fin no puede ser nula')
            RAISERROR('Fecha Fin Inválida', 16, 1)
        END

        UPDATE Area_Negocios.Concesion
        SET IdTipoActividadConcesion=@IdTipoActividadConcesion,
        IdEmpresa=@IdEmpresa,
        IdParque=@IdParque,
        Fecha_Inicio=@Fecha_Inicio,
        Fecha_Fin=@Fecha_Fin
        WHERE IdConcesion=@IdConcesion

    END TRY
    BEGIN CATCH
        -- Lanzamos return
            RAISERROR('Algo salio mal en la modificación de la Concesión',16,1);
            Return;
    END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--              MODIFICACIÓN DE LAS EMPRESAS
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Negocios.SP_ModificarEmpresaConcesionaria
	@IdEmpresaConcesionaria INT,
	@Nombre varchar(150),
	@Estado bit
AS
BEGIN
	BEGIN TRY

		--Busca la Empresa Concesionaria en la base de datos
		IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Empresa_Concesionaria WHERE IdEmpresa = @IdEmpresaConcesionaria)
        BEGIN
            PRINT('Empresa Concesionaria inexistente')
            RAISERROR('Empresa Inexistente', 16, 1)
        END

		-- El nuevo nombre debe ser valido
		IF @Nombre IS NULL OR @Nombre='' OR @Nombre LIKE '%[^a-zA-ZñÑ. ]%' OR LEN(@Nombre) > 80
		BEGIN
			PRINT('El Nuevo nombre de la empresa no es valido.');
			RAISERROR('EmpresaConcesionaria Invalida', 16, 1);
		END
		-- La modificacion de Nombre no puede estar repetida.
		IF EXISTS (SELECT 1 FROM Area_Negocios.Empresa_Concesionaria WHERE Nombre = @Nombre AND IdEmpresa <> @IdEmpresaConcesionaria)
        BEGIN
			-- Lanzar el error
			PRINT('La empresa ya se encuentra registrada.');
			RAISERROR('EmpresaConcesionaria Invalida', 16, 1);
		END
		-- El estado no puede ser vacio
		IF @Estado IS NULL
		BEGIN
			PRINT('No puede colocar un estado vacío')
			RAISERROR('Estado Invalido', 16, 1);
		END
			UPDATE Area_Negocios.Empresa_Concesionaria
			SET Nombre = @Nombre, Estado = @Estado
			WHERE IdEmpresa = @IdEmpresaConcesionaria; 

	END TRY
	BEGIN CATCH
			RAISERROR('Algo salio mal en la modificación de la Empresa', 16, 1);
			RETURN;
	END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--              MODIFICACIÓN DEL ESTADO DEL CANON
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Negocios.SP_ModificarEstadoCanon
	@IdEstadoCanon INT,
	@Descripcion varchar(150)
AS
BEGIN
	BEGIN TRY
		--Busca el Estado Canon verificando que existe en la base de datos
		IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Estado_Canon WHERE IdEstadoCanon = @IdEstadoCanon)
        BEGIN
            PRINT('Estado Canon inexistente')
            RAISERROR('Estado Canon Inexistente', 16, 1)
        END

		-- La nueva descripcion debe ser valida
		-- 2. Validar formato de la descripción
        IF @Descripcion IS NULL OR @Descripcion = '' OR LEN(@Descripcion) > 100
        BEGIN
            RAISERROR('La nueva descripción no es válida o excede el límite de caracteres.', 16, 1);
        END

        IF @Descripcion LIKE '%[^a-zA-ZñÑ. ]%'
        BEGIN
			PRINT('La nueva descripción no es valida.');
            RAISERROR('La descripción contiene caracteres no permitidos (solo letras y espacios).', 16, 1);
        END

        -- 3. Validar duplicados EXCLUYENDO el registro actual
        IF EXISTS (SELECT 1 FROM Area_Negocios.Estado_Canon WHERE Descripcion = @Descripcion AND IdEstadoCanon <> @IdEstadoCanon)
        BEGIN
			PRINT('La nueva descripción se encuentra repetida y ya existe.');
            RAISERROR('Ya existe otro Estado de Canon con esa misma descripción.', 16, 1);
        END
		UPDATE Area_Negocios.Estado_Canon
        SET Descripcion = @Descripcion
        WHERE IdEstadoCanon = @IdEstadoCanon;
	END TRY
	BEGIN CATCH
        -- Lanzar Rollback
			RAISERROR('Algo salio mal en la modificación del Estado del Canon', 16, 1);
			RETURN;
	END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--              MODIFICACIÓN DEL PAGO DEL CANON
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Negocios.SP_ModificarPagoCanon
	@IdPagoCanon INT,
	@IdCanon INT,
	@Monto_Abonado DECIMAL(13,3),
    @Fecha_Pago DATE
AS
BEGIN
	BEGIN TRY
		--Busca el Pago Canon verificando que existe en la base de datos
		IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Pago_Canon WHERE IdPagoCanon = @IdPagoCanon)
        BEGIN
            PRINT('Pago de Canon inexistente')
            RAISERROR('PagoCanon Inexistente', 16, 1)
        END
		-- Busca el IdCanon en la tabla de Canon.
        IF NOT EXISTS ( SELECT 1 FROM Area_Negocios.Canon WHERE IdCanon = @IdCanon)
        BEGIN
            PRINT('No Existe el Canon Ingresado')
            RAISERROR('Canon Invalido',16,1)
        END
		-- Valida el Monto ingresado
        IF NOT @Monto_Abonado > 0 OR @Monto_Abonado IS NULL
        BEGIN
            PRINT('El Monto Ingresado no es valido')
            RAISERROR('Monto Invalido',16,1)
        END
        -- Valida la fecha ingresada, comprobando que no sea nula.
		IF @Fecha_Pago IS NULL
		BEGIN
            PRINT('La fecha no puede ser nula')
            RAISERROR('Fecha Invalida', 16, 1)
        END
		--Se completa la operación
	UPDATE Area_Negocios.Pago_Canon SET Monto_Abonado = @Monto_Abonado,
			IdCanon = @IdCanon,
			Fecha_Pago = @Fecha_Pago
			WHERE IdPagoCanon = @IdPagoCanon;
	END TRY
	BEGIN CATCH
        -- Lanzar RETURN
			RAISERROR('Algo salio mal en la modificación del Pago del Canon', 16, 1);
			RETURN;
	END CATCH
	

END
GO

-- //////////////////////////////////////////////////////////////
--              MODIFICACIÓN DE TIPO DE ACTIVIDAD
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Negocios.SP_ModificarTipoActividadConcesion
	@IdTipoActividadConcesion INT,
	@Descripcion varchar(150)
AS
BEGIN
	BEGIN TRY
		--Busca el id verificando que existe en la base de datos
		IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Tipo_Actividad_Concesion WHERE IdTipoActividadConcesion = @IdTipoActividadConcesion)
        BEGIN
            PRINT('Tipo de Actividad inexistente')
            RAISERROR('TipoActividadConcesion Inexistente', 16, 1)
        END

		-- La nueva descripcion debe ser valida
		IF @Descripcion IS  NULL OR @Descripcion = '' OR @Descripcion LIKE '%[^a-zA-ZñÑ. ]%' OR LEN(@Descripcion) > 100
		BEGIN
			PRINT('La nueva descripción no es válida.');
			RAISERROR('Descripcion Invalida', 16, 1);
		END

		--La nueva Descripcion no puede ser una repetida
		IF EXISTS (SELECT 1 FROM Area_Negocios.Tipo_Actividad_Concesion WHERE Descripcion = @Descripcion AND IdTipoActividadConcesion <> @IdTipoActividadConcesion)
		BEGIN
			-- Lanzar el error
			PRINT('La nueva descripción ya se encuentra registrada.');
			RAISERROR('Descripcion Invalida', 16, 1);
		END
		UPDATE Area_Negocios.Tipo_Actividad_Concesion
			SET Descripcion = @Descripcion
			WHERE IdTipoActividadConcesion = @IdTipoActividadConcesion;
	END TRY
	BEGIN CATCH
        -- Lanzar return
			RAISERROR('Algo salio mal en la modificación del Tipo De Actividad de la concesion', 16, 1);
			Return;
	END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--              Apartado 3: Sps de Eliminación
-- //////////////////////////////////////////////////////////////

-- //////////////////////////////////////////////////////////////
--              ELIMINACIÓN DE CANON
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Negocios.SP_EliminarCanon
    @IdCanon INT
AS
BEGIN
    BEGIN TRY

        -- Validamos que la id canon ingresado exista en la Base de Datos
        DECLARE @IdCanonExiste INT;
        SELECT @IdCanonExiste = IdCanon FROM Area_Negocios.Canon WHERE IdCanon = @IdCanon;
        IF @IdCanonExiste IS NULL
        BEGIN
            PRINT('No existe un Canon con ese Identificador')
            RAISERROR('Canon Inexistente',16,1)
        END
        IF EXISTS (SELECT 1 FROM Area_Negocios.Pago_Canon WHERE IdCanon = @IdCanon)
        BEGIN
            PRINT('El canon ingresado tiene pagos asociados')
            RAISERROR('No se puede eliminar el Canon porque posee registros de pagos asociados.', 16, 1);
        END
         DELETE FROM Area_Negocios.Canon WHERE IdCanon = @IdCanon;
    END TRY
    BEGIN CATCH	
            RAISERROR('Algo salio mal en la eliminación del Canon',16,1);
            RETURN;
    END CATCH
   
END
GO
-- //////////////////////////////////////////////////////////////
--              ELIMINACIÓN DE CONCESION
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Negocios.SP_EliminarConcesion
    @IdConcesion INTEGER
AS
BEGIN
	BEGIN TRY

        -- Se verifica que la concesión exista
        IF NOT EXISTS ( SELECT 1 FROM Area_Negocios.Concesion WHERE IdConcesion = @IdConcesion)
        BEGIN
            PRINT('No Existe la concesión ingresada')
            RAISERROR('Concesión Invalida',16,1)
        END
        --Viendo que no hayan canones para esa concesión
        IF EXISTS (SELECT 1 FROM Area_Negocios.Canon WHERE IdConcesion = @IdConcesion)
        BEGIN
            PRINT('La concesión ingresada tiene canones asociados')
            RAISERROR('No se puede eliminar la Concesión porque tiene históricos de cánones vinculados.', 16, 1);
        END

        DELETE FROM Area_Negocios.Concesion WHERE IdConcesion=@IdConcesion
    END TRY
    BEGIN CATCH
        -- Lanzamos return
            RAISERROR('Algo salio mal en la eliminación de la Concesión',16,1);
            Return;
    END CATCH
END
GO

-- //////////////////////////////////////////////////////////////
--              ELIMINACIÓN DE EMPRESA
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Negocios.SP_EliminarEmpresaConcesionaria
    @IdEmpresa INT
AS
BEGIN
    BEGIN TRY
        -- Validamos que la id ingresado exista en la Base de Datos
        --Validamos que la empresa si este actualmente activa
        DECLARE @IdEmpresaExiste INT;
        SELECT @IdEmpresaExiste = IdEmpresa FROM Area_Negocios.Empresa_Concesionaria WHERE IdEmpresa = @IdEmpresa AND Estado = 1;
        IF @IdEmpresaExiste IS NULL
        BEGIN
            PRINT('No existe una Empresa Concesionaria activa con ese Id')
            RAISERROR('Empresa Inexistente',16,1)
        END
        
        UPDATE Area_Negocios.Empresa_Concesionaria SET Estado = 0 WHERE IdEmpresa = @IdEmpresa
    END TRY
    BEGIN CATCH
            RAISERROR('Algo salio mal en la eliminacion de la empresa concesionaria',16,1);
            RETURN;
    END CATCH
    --DELETE FROM Area_Negocios.Empresa_Concesionaria WHERE IdEmpresa = @IdEmpresa;
    
END
GO

-- //////////////////////////////////////////////////////////////
--              ELIMINACIÓN DE ESTADO DE CANON
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Negocios.SP_EliminarEstadoCanon
    @IdEstadoCanon INT
AS
BEGIN
    BEGIN TRY
        -- Validamos que la id ingresado exista en la Base de Datos
        DECLARE @IdEstadoCanonExiste INT;
        SELECT @IdEstadoCanonExiste = IdEstadoCanon FROM Area_Negocios.Estado_Canon WHERE IdEstadoCanon = @IdEstadoCanon;
        IF @IdEstadoCanonExiste IS NULL
        BEGIN
            PRINT('No existe un Estado de Canon con ese Id')
            RAISERROR('EstadoCanon Inexistente',16,1)
        END
        --No puede tener Canones asociados
        IF EXISTS (SELECT 1 FROM Area_Negocios.Canon WHERE IdEstado = @IdEstadoCanon)
        BEGIN
            PRINT('No existe un Estado de Canon con ese Id')
            RAISERROR('No se puede eliminar el Estado de Canon porque está siendo utilizado por registros de la tabla Canon.', 16, 1);
        END

        DELETE FROM Area_Negocios.Estado_Canon WHERE IdEstadoCanon = @IdEstadoCanon;
    END TRY
    BEGIN CATCH
            RAISERROR('Algo salio mal en la eliminacion del Estado de Canon',16,1);
            RETURN;
    END CATCH
    
END
GO

-- //////////////////////////////////////////////////////////////
--              ELIMINACIÓN DE PAGO DE CANON
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Negocios.SP_EliminarPagoCanon
    @IdPagoCanon INT
AS
BEGIN
    BEGIN TRY

        -- Validamos que la id ingresado exista en la Base de Datos
        DECLARE @IdPagoCanonExiste INT;
        SELECT @IdPagoCanonExiste = IdPagoCanon FROM Area_Negocios.Pago_Canon WHERE IdPagoCanon = @IdPagoCanon;
        IF @IdPagoCanonExiste IS NULL
        BEGIN
            PRINT('No existe un Pago de Canon con ese Id')
            RAISERROR('PagoCanon Inexistente',16,1)
        END
         DELETE FROM Area_Negocios.Pago_Canon WHERE IdPagoCanon = @IdPagoCanon;
    END TRY
    BEGIN CATCH
            RAISERROR('Algo salio mal en la eliminación del Pago de Canon',16,1);
            RETURN;
    END CATCH
   
END
GO
-- //////////////////////////////////////////////////////////////
--              ELIMINACIÓN DE TIPO DE ACTIVIDAD 
-- //////////////////////////////////////////////////////////////


CREATE OR ALTER PROCEDURE Area_Negocios.SP_EliminarTipoActividadConcesion
    @IdTipoActividadConcesion INT
AS
BEGIN
    BEGIN TRY
        -- Validamos que la id ingresado exista en la Base de Datos
        DECLARE @IdTipoActividadConcesionExiste INT;
        SELECT @IdTipoActividadConcesionExiste = IdTipoActividadConcesion FROM Area_Negocios.Tipo_Actividad_Concesion WHERE IdTipoActividadConcesion = @IdTipoActividadConcesion;
        IF @IdTipoActividadConcesionExiste IS NULL
        BEGIN
            PRINT('No existe un Tipo de Actividad con ese Id')
            RAISERROR('TipoActividadConcesion Inexistente',16,1)
        END
        --Reviso que la la actividad no se asocie a concesiones
        IF EXISTS (SELECT 1 FROM Area_Negocios.Concesion WHERE IdTipoActividadConcesion = @IdTipoActividadConcesion)
        BEGIN
            PRINT('No se puede eliminar poque existen concesiones asignadas a esta actividad.')
            RAISERROR('No se puede eliminar el Tipo de Actividad debido a que existen concesiones vigentes que dependen de él.', 16, 1);
        END
        DELETE FROM Area_Negocios.Tipo_Actividad_Concesion WHERE IdTipoActividadConcesion = @IdTipoActividadConcesion;
    END TRY
    BEGIN CATCH
            RAISERROR('Algo salio mal en la eliminación del Tipo de Actividad Concesion',16,1);
            RETURN;
    END CATCH
    
END
GO
PRINT '-- #FIN DE CREACIÓN DE SP DE AREA DE NEGOCIOS--'
GO