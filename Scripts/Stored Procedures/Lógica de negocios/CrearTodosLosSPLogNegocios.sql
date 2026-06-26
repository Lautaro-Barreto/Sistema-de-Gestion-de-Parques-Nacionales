/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripcion: Crea todos los SP relacionados a la lógica de negocios.
*/
---------------------------------------------------------------
--              OBTENER FERIADOS DESDE API                   --
---------------------------------------------------------------
/*
#Descripción: Este script se encarga de consultar a una API externa para obtener los feriados nacionales
y validar si una fecha dada es un feriado o no. Para esto se utiliza la API de argentinadatos.com, que devuelve
los feriados nacionales de un año determinado.

Documentación de la API: https://argentinadatos.com/docs/operations/get-feriados

Devuelve los feriados del año indicado (o del año actual si no se especifica).
GET /v1/feriados/{año}
Parámetros

Año de consulta
Tipo integer Requerido
Ejemplo 2026
Mínimo 2016
Máximo 2026

Formato de respuesta

[
    {
        "fecha": "string",  
        "tipo": "string",  
        "nombre": "string"
    }
]
*/
USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Comercial.SP_ObtenerFeriadosDesdeAPI 
    @Fecha DATE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION
            PRINT 'Obteniendo feriados nacionales desde la API de argentinadatos.com...'        

            DECLARE @Object INT
            DECLARE @json TABLE(respuesta NVARCHAR(MAX))	--Usamos una tabla variable
            DECLARE @respuesta NVARCHAR(MAX)
            --Concatenamos la URL con el año de la fecha que recibimos por parámetro, para obtener los feriados de ese año.
            DECLARE @url NVARCHAR(200) = 'https://api.argentinadatos.com/v1/feriados/' + CAST(YEAR(@Fecha) AS CHAR(4))

            EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT	--Creamos una instancia del objeto OLE, que nos permite hacer los llamados.
            EXEC sp_OAMethod @Object, 'OPEN', NULL, 'GET', @url, 'FALSE' --Definimos algunas propiedades del objeto para hacer una llamada HTTP Get.
            EXEC sp_OAMethod @Object, 'SEND' 
            EXEC sp_OAMethod @Object, 'RESPONSETEXT', @respuesta OUTPUT --Guardamos la respuesta de la API en una variable.

            PRINT 'Feriados obtenidos desde la API. Parseando respuesta...'

            INSERT @json 
            EXEC sp_OAGetProperty @Object, 'RESPONSETEXT' --Obtenemos el valor de la propiedad 'RESPONSETEXT' del objeto OLE luego de realizar la consulta.

            DECLARE @datos NVARCHAR(MAX) = (SELECT respuesta FROM @json)
            
            -- Insertamos en la tabla de feriados nacionales los feriados obtenidos desde la API para el año de la fecha que recibimos por parámetro.  
            INSERT INTO Area_Comercial.Feriado_Nacional (Fecha, Tipo, Descripcion)
            SELECT Fecha, Tipo, Nombre FROM OPENJSON(@datos)
            WITH
            (
                [Fecha] date '$.fecha',
                [Tipo] nvarchar(40) '$.tipo',
                [Nombre] nvarchar(30) '$.nombre'
            )
            PRINT 'Feriados nacionales insertados en la base de datos correctamente.'
        COMMIT TRANSACTION;      
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
        BEGIN	
            RAISERROR('Algo salió mal al obtener los feriados nacionales desde la API de argentinadatos.com', 16, 1);
            RETURN;
        END
    END CATCH
END
GO


---------------------------------------------------------------
--              VALIDAR FERIADO                              --
---------------------------------------------------------------
/*
#Descripción: Este script se encarga de consultar a una API externa para obtener los feriados nacionales
y validar si una fecha dada es un feriado o no. Para esto se utiliza la API de argentinadatos.com, que devuelve
los feriados nacionales de un año determinado.

Documentación de la API: https://argentinadatos.com/docs/operations/get-feriados

Devuelve los feriados del año indicado (o del año actual si no se especifica).
GET /v1/feriados/{año}
Parámetros

Año de consulta
Tipo integer Requerido
Ejemplo 2026
Mínimo 2016
Máximo 2026

Formato de respuesta

[
    {
        "fecha": "string",  
        "tipo": "string",  
        "nombre": "string"
    }
]
*/

GO

CREATE OR ALTER PROCEDURE Area_Comercial.Sp_ValidarFeriado
    @Fecha DATE,
    @EsFeriado BIT OUTPUT
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        -- Primero revisamos la tabla de feriados nacionales que tenemos cargada en la DB para chequear que estén cargados los feriados del año de la fecha que recibimos por parámetro. Si no hay ningún
        -- feriado cargado para ese año, consultamos a la API y cargamos los feriados obtenidos en la tabla de la DB para futuras consultas.
        IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Feriado_Nacional WHERE YEAR(Fecha) = YEAR(@Fecha))
        BEGIN
            EXEC Area_Comercial.SP_ObtenerFeriadosDesdeAPI @Fecha;
        END
        ELSE
        BEGIN
            -- Si ya tenemos los feriados cargados para ese año, validamos si la fecha que recibimos por parámetro es un feriado o no.
            IF EXISTS (SELECT 1 FROM Area_Comercial.Feriado_Nacional WHERE Fecha = @Fecha)
                SET @EsFeriado = 1
            ELSE
                SET @EsFeriado = 0
        END
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
        BEGIN	
            RAISERROR('Algo salió mal al obtener los feriados nacionales desde la API de argentinadatos.com', 16, 1);
            RETURN;
        END
    END CATCH
END

---------------------------------------------------------------
--              REGISTRAR VENTA DE ENTRADAS                  --
---------------------------------------------------------------

/*
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para
generar un registro en la tabla de ventas que se asocie con un detalle de venta y una contratación. 

	-- Crea cada entrada y calcula el subtotal en base a una nueva tabla que tiene la asignación de precios entre cada parque y tipo de visitante (Area_Comercial.Precio_Parque_Tipo_Visitante)
	-- Crea un detalle y lo asocia con esas entradas
	-- También recibe un tipo de actividad, así que asocia una contratación de actividad con la venta (se tiene que fijar el tema de los cupos de cada una también)
	-- Suma los subtotales de las entradas y de las contrataciones, setea un total en la venta y la registra
	-- Se usa la API https://api.argentinadatos.com/v1/feriados para validar que la fecha de la venta no sea un feriado nacional, y en caso de serlo, aplicar un descuento del 10% sobre el total de la venta.
*/

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

		--La cantidad de entradas debe ser mayor a cero
		IF @CantidadEntradas <= 0
		BEGIN
			RAISERROR('La cantidad de entradas debe ser mayor a cero', 16, 1)
		END

		--El tipo de visitante debe estar cargado en la DB
		SELECT @IdTipoVisitante = IdTipoVisitante FROM Area_Comercial.Tipo_Visitante WHERE Descripcion = @TipoVisitante;
		IF @IdTipoVisitante IS NULL
        BEGIN
            RAISERROR('Tipo de visitante inexistente', 16, 1)
        END

		-- El parque debe tener tarifas cargadas para el tipo de visitante seleccionado
		IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Precio_Parque_Tipo_Visitante WHERE IdParque = @IdParque AND IdTipoVisitante = (SELECT IdTipoVisitante FROM Area_Comercial.Tipo_Visitante WHERE Descripcion = @TipoVisitante))
		BEGIN
			RAISERROR('No hay tarifas cargadas para el tipo de visitante seleccionado en el parque especificado', 16, 1)
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
			DECLARE @ErrorMessage VARCHAR(255) = ERROR_MESSAGE();	
			RAISERROR(@ErrorMessage, 16, 1);
			ROLLBACK TRANSACTION;
			RETURN;
		END
	END CATCH
	RETURN @IdNuevaVenta
END
GO

---------------------------------------------------------------
--              REGISTRAR PAGO DE CANON                     --
---------------------------------------------------------------

/*
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para registrar el pago de un 
canon, actualizar su estado y generar el próximo canon a pagar.   

-- Determinar el estado posterior al pago basado en las fechas
-- Si el pago se realiza antes o en la fecha de vencimiento, el estado será "Saldado en Término"
-- Si el pago se realiza después de la fecha de vencimiento, el estado será "Saldado con Atraso"
-- Validar que el monto abonado sea suficiente para cubrir el canon

*/

CREATE OR ALTER PROCEDURE Area_Negocios.SP_Registrar_Pago_Canon
    @IdCanon INT,
    @IdConcesion INT,
    @Monto_Abonado DECIMAL(13,3),
    @Fecha_Pago DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Obtener la info del canon que se intenta pagar
    DECLARE @IdEstadoActual INT, @Fecha_Vencimiento DATE, @Monto_Mensual DECIMAL(13,3);
    
    SELECT @IdEstadoActual = IdEstado, @Fecha_Vencimiento = Fecha_Vencimiento, @Monto_Mensual = Monto_Mensual
    FROM Area_Negocios.Canon
    WHERE IdCanon = @IdCanon AND IdConcesion = @IdConcesion;

    IF @IdEstadoActual IS NULL
    BEGIN
        RAISERROR('El Canon especificado no existe.', 16, 1);
        RETURN;
    END

    -- Validar que no esté exento o ya cancelado
    DECLARE @IdExento INT = (SELECT IdEstadoCanon FROM Area_Negocios.Estado_Canon WHERE Descripcion = 'Exento');
    DECLARE @IdSaldadoTermino INT = (SELECT IdEstadoCanon FROM Area_Negocios.Estado_Canon WHERE Descripcion = 'Saldado en Término');
    DECLARE @IdSaldadoAtraso INT = (SELECT IdEstadoCanon FROM Area_Negocios.Estado_Canon WHERE Descripcion = 'Saldado con Atraso');

    IF @IdEstadoActual = @IdExento
    BEGIN
        RAISERROR('El canon especificado está exento. No requiere pago.', 16, 1);
        RETURN;
    END

    IF @IdEstadoActual IN (@IdSaldadoTermino, @IdSaldadoAtraso)
    BEGIN
        RAISERROR('El canon especificado ya se encuentra saldado.', 16, 1);
        RETURN;
    END

    IF @Monto_Abonado < @Monto_Mensual
    BEGIN
        RAISERROR('El monto abonado no es suficiente para cubrir el canon.', 16, 1);
        RETURN;
    END

    DECLARE @NuevoEstado INT;
    IF @Fecha_Pago <= @Fecha_Vencimiento
        SET @NuevoEstado = @IdSaldadoTermino;
    ELSE
        SET @NuevoEstado = @IdSaldadoAtraso;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Insertar el recibo en la tabla de Pagos
        INSERT INTO Area_Negocios.Pago_Canon (IdCanon, Monto_Abonado, Fecha_Pago)
        VALUES (@IdCanon, @Monto_Abonado, @Fecha_Pago);

        -- 2. Actualizar el Canon pagado para cerrarlo
        UPDATE Area_Negocios.Canon
        SET IdEstado = @NuevoEstado
        WHERE IdCanon = @IdCanon;

        -- 3. Emitir el nuevo Canon para la próxima cuota (30 días después del vencimiento original)
        DECLARE @IdVigente INT = (SELECT IdEstadoCanon FROM Area_Negocios.Estado_Canon WHERE Descripcion = 'Vigente');
        
        INSERT INTO Area_Negocios.Canon (IdConcesion, IdEstado, Monto_Mensual, Fecha_Vencimiento)
        VALUES (
            @IdConcesion, 
            @IdVigente, 
            @Monto_Mensual,
            DATEADD(DAY, 30, @Fecha_Vencimiento)
        );

        COMMIT TRANSACTION;
        PRINT 'Pago registrado correctamente. Nuevo canon emitido.';

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR (@ErrorMsg, 16, 1);
    END CATCH
END
GO