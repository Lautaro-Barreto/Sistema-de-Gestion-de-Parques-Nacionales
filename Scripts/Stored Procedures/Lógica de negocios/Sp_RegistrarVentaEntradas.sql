/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para
generar un registro en la tabla de ventas que se asocie con un detalle de venta y una contratación. 

	-- Crea cada entrada y calcula el subtotal en base a una nueva tabla que tiene la asignación de precios entre cada parque y tipo de visitante (Area_Comercial.Precio_Parque_Tipo_Visitante)
	-- Crea un detalle y lo asocia con esas entradas
	-- También recibe un tipo de actividad, así que asocia una contratación de actividad con la venta (se tiene que fijar el tema de los cupos de cada una también)
	-- Suma los subtotales de las entradas y de las contrataciones, setea un total en la venta y la registra
	-- Se usa la API https://api.argentinadatos.com/v1/feriados para validar que la fecha de la venta no sea un feriado nacional, y en caso de serlo, aplicar un descuento del 10% sobre el total de la venta.
*/

USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Comercial.Sp_RegistrarVentaEntradas
	@Parque VARCHAR(80),
    @CantidadEntradas INT,
    @TipoVisitante VARCHAR(30),
    @Actividad VARCHAR(80),
	@Fecha DATE,
	@IdPuntoDeVenta INT,
	@FormaDePago VARCHAR(30)
AS
BEGIN
    BEGIN TRY
	BEGIN TRANSACTION;
        SET NOCOUNT ON;

		DECLARE @IdParque INT;
		DECLARE @IdActividadIngresada INT;
		DECLARE @IdFormaDePago INT;
		DECLARE @SubTotal DECIMAL(14,4) = 0.0;
		DECLARE @Total DECIMAL(14,4) = 0.0;
		DECLARE @IdTipoVisitante INT;

		-- ================================================================================================================
		--											VALIDACIONES
		-- ================================================================================================================

		--El parque debe estar cargado en la DB
		SELECT @IdParque = IdParque FROM Area_Infraestructura.Parque WHERE Nombre = @Parque;
		IF @IdParque IS NULL
        BEGIN
            RAISERROR('Parque inexistente', 16, 1)
        END

		--El tipo de visitante debe estar cargado en la DB
		SELECT @IdTipoVisitante = IdTipoVisitante FROM Area_Comercial.Tipo_Visitante WHERE Descripcion = @TipoVisitante;
		IF @IdTipoVisitante IS NULL
        BEGIN
            RAISERROR('Tipo de visitante inexistente', 16, 1)
        END

		--El punto de venta debe estar cargado en la DB
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Punto_De_Venta WHERE IdPuntoDeVenta = @IdPuntoDeVenta)
        BEGIN
            RAISERROR('Punto de venta inexistente', 16, 1)
        END

		--La forma de pago debe estar cargada en la DB
		SELECT @IdFormaDePago = IdFormaDePago FROM Area_Comercial.Forma_De_Pago WHERE Descripcion = @FormaDePago;
		IF @IdFormaDePago IS NULL
        BEGIN
            RAISERROR('Forma de pago inexistente', 16, 1)
        END

		--El campo fecha debe tener un valor
		IF @Fecha IS NULL
		BEGIN
            RAISERROR('La fecha no puede ser nula', 16, 1)
        END

		--La actividad (si se ingresó, porque puede ser null) debe estar cargada en la DB
		IF @Actividad IS NOT NULL
		BEGIN
			SELECT @IdActividadIngresada = IdActividad FROM Area_Excursiones.Actividad WHERE Nombre = @Actividad
			IF @IdActividadIngresada IS NULL
			BEGIN
				RAISERROR('Actividad inexistente', 16, 1)
			END
			
			-- La actividad debe estar vinculada al parque seleccionado
			IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Actividad WHERE IdActividad = @IdActividadIngresada AND IdParque = @IdParque)
			BEGIN
				RAISERROR('La actividad seleccionada no está disponible para el parque seleccionado', 16, 1)
			END

			--La actividad debe tener cupos disponibles para la fecha de la venta
			DECLARE @CuposDisponibles INT
			DECLARE @CupoMaximoActividad INT
			DECLARE @CantidadContratacionesActividad INT

			SET @CupoMaximoActividad = (SELECT Cupo_maximo FROM Area_Excursiones.Actividad WHERE IdActividad = @IdActividadIngresada)

			SELECT @CantidadContratacionesActividad = COUNT(*) FROM Area_Excursiones.Contratacion_Actividad CA
			INNER JOIN Area_Excursiones.Actividad A ON CA.IdActividad = A.IdActividad
			WHERE CA.IdActividad = @IdActividadIngresada AND CA.Fecha_Contratacion = @Fecha

			SET @CuposDisponibles = @CupoMaximoActividad - @CantidadContratacionesActividad

			IF @CuposDisponibles <= 0
			BEGIN
				RAISERROR('No hay cupos disponibles para la actividad seleccionada en la fecha indicada', 16, 1)
			END
		END

		--La cantidad de entradas debe ser mayor a cero
		IF @CantidadEntradas <= 0
		BEGIN
			RAISERROR('La cantidad de entradas debe ser mayor a cero', 16, 1)
		END

		-- ================================================================================================================
		--							CÁLCULO DE PRECIOS, DESCUENTOS, SUBTOTALES Y TOTALES
		-- ================================================================================================================

		DECLARE @PrecioEntrada DECIMAL(14,4)
		DECLARE @PorcentajeDescuento DECIMAL(5,2)
		SELECT @PrecioEntrada = Precio FROM Area_Comercial.Precio_Parque_Tipo_Visitante WHERE IdParque = @IdParque AND IdTipoVisitante = @IdTipoVisitante;	
		SET @Subtotal = @CantidadEntradas * @PrecioEntrada;

		--Validamos si la fecha es un feriado nacional, y en caso de serlo, verificamos
		--si existe un descuento aplicable sobre el total de la venta para ese parque
		DECLARE @EsFeriado BIT
		EXEC Area_Comercial.Sp_ValidarFeriado @Fecha = @Fecha, @EsFeriado = @EsFeriado OUTPUT
		IF @EsFeriado = 1
		BEGIN
			SELECT @PorcentajeDescuento = Porcentaje FROM Area_Comercial.Descuento_Parque WHERE IdParque = @IdParque AND (Descripcion LIKE '%feriado%' OR Descripcion LIKE '%Feriado%')
			SET @Subtotal = @Subtotal - (@Subtotal * @PorcentajeDescuento)
			PRINT('La fecha corresponde con un feriado, se aplicó un descuento del ' + CAST(@PorcentajeDescuento AS VARCHAR(10)) + '%')
		END

		SET @Total = @Subtotal;

		--Obtencion del precio de la actividad
		IF @Actividad IS NOT NULL
			BEGIN
			DECLARE @PrecioActividad DECIMAL(14,4)
			SELECT @PrecioActividad = Costo FROM Area_Excursiones.Actividad WHERE Nombre = @Actividad
			IF @PrecioActividad IS NULL
			BEGIN
				RAISERROR('Error al obtener el precio de la actividad', 16, 1)
			END
			SET @Total = @Total + (@PrecioActividad * @CantidadEntradas);
		END
		
		-- ================================================================================================================
		--				REGISTRO DE LA VENTA, DETALLE DE VENTA, ENTRADAS Y CONTRATACIÓN DE ACTIVIDAD
		-- ================================================================================================================

		--Registramos la venta
		INSERT INTO Area_Comercial.Venta(IdPuntoDeVenta, IdParque, IdFormaDePago, Fecha, Total) VALUES
		(@IdPuntoDeVenta, @IdParque, @IdFormaDePago, @Fecha, @Total);
		DECLARE @IdNuevaVenta INT
		SET @IdNuevaVenta = SCOPE_IDENTITY()

		--Creamos el detalle de venta de entradas y las entradas asociadas a ese detalle
		DECLARE @CantidadEntradasContador INT;
		SET @CantidadEntradasContador = @CantidadEntradas;

		while @CantidadEntradasContador > 0
		BEGIN
			DECLARE @IdEntrada INT
			INSERT INTO Area_Comercial.Entrada(IdParque, IdTipoVisitante, Precio, Fecha_Acceso) VALUES
			(@IdParque, @IdTipoVisitante, @PrecioEntrada, @Fecha);
			SET @IdEntrada = SCOPE_IDENTITY()

			EXEC Area_Comercial.SP_CrearDetalleVentaEntrada @IdVenta = @IdNuevaVenta, @IdEntrada = @IdEntrada, @Cantidad = 1, @Subtotal = @PrecioEntrada

			SET @CantidadEntradasContador = @CantidadEntradasContador - 1
		END

		--Si la actividad fue ingresada, creamos la contratación y la asociamos con la venta
		IF @Actividad IS NOT NULL
		BEGIN
			SET @CantidadEntradasContador = @CantidadEntradas;
			WHILE @CantidadEntradasContador > 0
			BEGIN
				EXEC Area_Excursiones.Sp_CrearContratacion_Actividad @IdVenta = @IdNuevaVenta, @IdActividad = @IdActividadIngresada,  @Monto = @PrecioActividad, @FechaContratacion = @Fecha  
				SET @CantidadEntradasContador = @CantidadEntradasContador - 1
			END
		END
	COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF ERROR_SEVERITY() > 10
		BEGIN	
			PRINT 'Error al registrar la venta de entradas: ' + ERROR_MESSAGE();
			RAISERROR('', 16, 1);
			ROLLBACK TRANSACTION;
			RETURN;
		END
	END CATCH
	RETURN @IdNuevaVenta
END
GO