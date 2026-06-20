/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 19/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripci�n: Este script se encarga de testear los Stored Procedures de creaci�n, eliminaci�n y
modificaci�n de las tablas del esquema Area_Comercial.
*/

USE SGParquesNacionales
GO

-- ===========================================================================================
--                                 Pruebas de creaci�n
-- ===========================================================================================

-- 1. DESCUENTO_PARQUE
-- Se crea un parque de prueba para realizar los tests. El ID de este parque ser� 1
BEGIN TRY
    EXEC Area_Infraestructura.Sp_CrearRegion
        @Nombre = 'RegionTest'

    EXEC Area_Infraestructura.Sp_CrearProvincia
        @Nombre = 'ProvinciaTest',
        @Region = 'RegionTest'

    EXEC Area_Infraestructura.Sp_CrearTipoParque
        @Descripcion = 'TipoParqueTest'

    EXEC Area_Infraestructura.Sp_CrearParque
        @Nombre = 'ParquePrueba',
        @TipoParqueDesc = 'TipoParqueTest',
        @Provincia = 1,
        @Superficie = 50000.00
    
    SELECT par.IdParque, par.Nombre, par.Superficie, pro.Nombre AS Provincia FROM Area_Infraestructura.Parque par
    JOIN Area_Infraestructura.Provincia pro ON pro.IdProvincia = par.IdProvincia
    WHERE par.Nombre = 'Este es un parque de prueba' AND pro.Nombre = 'ProvinciaTest' AND par.Superficie = 50000.00;
END TRY
BEGIN CATCH
    PRINT 'Error al crear el parque: ' + ERROR_MESSAGE();
END CATCH
GO

-- Test 1: Caso exitoso
BEGIN TRY
    EXEC Area_Comercial.Sp_CrearDescuentoParque
        @IdParque = 1,
        @Descripcion = 'DescuentoTest',
        @Porcentaje = 0.30

    SELECT * FROM Area_Comercial.Descuento_Parque
    WHERE Descripcion = 'DescuentoTest'
END TRY
BEGIN CATCH
    PRINT 'Error al crear el descuento: ' + ERROR_MESSAGE()
END CATCH
GO

-- Test 2: Parque inexistente
BEGIN TRY
    EXEC Area_Comercial.Sp_CrearDescuentoParque
        @IdParque = 3,
        @Descripcion = 'DescuentoTest',
        @Porcentaje = 0.30
END TRY
BEGIN CATCH
    PRINT 'Error al crear el descuento: ' + ERROR_MESSAGE()
END CATCH
GO

-- Test 3: Descripci�n inv�lida (vac�a)
BEGIN TRY
    EXEC Area_Comercial.Sp_CrearDescuentoParque
        @IdParque = 1,
        @Descripcion = '',
        @Porcentaje = 0.30
END TRY
BEGIN CATCH
    PRINT 'Error al crear el descuento: ' + ERROR_MESSAGE()
END CATCH
GO

-- Test 4: Descripci�n inv�lida (con caracteres que no son letras)
BEGIN TRY
    EXEC Area_Comercial.Sp_CrearDescuentoParque
        @IdParque = 1,
        @Descripcion = 'D3scuent0Tes7',
        @Porcentaje = 0.30
END TRY
BEGIN CATCH
    PRINT 'Error al crear el descuento: ' + ERROR_MESSAGE()
END CATCH
GO

-- Test 5: Descripci�n inv�lida (supera el tama�o declarado)
BEGIN TRY
    EXEC Area_Comercial.Sp_CrearDescuentoParque
        @IdParque = 1,
        @Descripcion = 'DescuentoTestDescuentoTestDescuentoTestDescuentoTestDescuentoTestDescuentoTestDescuentoTest',
        @Porcentaje = 0.30
END TRY
BEGIN CATCH
    PRINT 'Error al crear el descuento: ' + ERROR_MESSAGE()
END CATCH
GO

-- Test 6: Porcentaje menor o igual a cero
BEGIN TRY
    EXEC Area_Comercial.Sp_CrearDescuentoParque
        @IdParque = 1,
        @Descripcion = 'DescuentoTest',
        @Porcentaje = -0.30
END TRY
BEGIN CATCH
    PRINT 'Error al crear el descuento: ' + ERROR_MESSAGE()
END CATCH
GO


-- 2. FORMA_DE_PAGO
-- Test 1: Creaci�n exitosa
BEGIN TRY
	EXEC Area_Comercial.SP_CrearFormaDePago @Descripcion = 'FormaDePagoTest'

	SELECT * FROM Area_Comercial.Tipo_Visitante
	WHERE Descripcion = 'FormaDePagoTest'
END TRY
BEGIN CATCH
	PRINT 'Error al crear la forma de pago: ' + ERROR_MESSAGE();
END CATCH
GO

-- Test 2: Descripci�n inv�lida (vac�a)
BEGIN TRY
	EXEC Area_Comercial.SP_CrearFormaDePago @Descripcion = ''
END TRY
BEGIN CATCH
	PRINT 'Error al crear la forma de pago: ' + ERROR_MESSAGE();
END CATCH
GO

-- Test 3: Descripci�n inv�lida (con caracteres que no sean letras)
BEGIN TRY
	EXEC Area_Comercial.SP_CrearFormaDePago @Descripcion = '$#F0rm4D3Pag0#"'
END TRY
BEGIN CATCH
	PRINT 'Error al crear la forma de pago: ' + ERROR_MESSAGE();
END CATCH
GO

-- Test 4: Descripci�n inv�lida (supera el tama�o declarado)
BEGIN TRY
	EXEC Area_Comercial.SP_CrearFormaDePago @Descripcion = 'FormaDePagoTestFormaDePagoTestFormaDePagoTestFormaDePagoTestFormaDePagoTestFormaDePagoTestFormaDePagoTest'
END TRY
BEGIN CATCH
	PRINT 'Error al crear la forma de pago: ' + ERROR_MESSAGE();
END CATCH
GO

-- Test 5: La descripci�n ya existe
BEGIN TRY
	EXEC Area_Comercial.SP_CrearFormaDePago @Descripcion = 'FormaDePagoTest'
END TRY
BEGIN CATCH
	PRINT 'Error al crear la forma de pago: ' + ERROR_MESSAGE();
END CATCH
GO


-- 3. PUNTO_DE_VENTA
-- Test 1: Creaci�n exitosa
BEGIN TRY
	EXEC Area_Comercial.SP_CrearPuntoDeVenta @Descripcion = 'PuntoDeVentaTest'

	SELECT * FROM Area_Comercial.Punto_De_Venta
	WHERE Descripcion = 'PuntoDeVentaTest'
END TRY
BEGIN CATCH
	PRINT 'Error al crear el punto de venta: ' + ERROR_MESSAGE();
END CATCH
GO

-- Test 2: Descripci�n inv�lida (vac�a)
BEGIN TRY
	EXEC Area_Comercial.SP_CrearPuntoDeVenta @Descripcion = ''
END TRY
BEGIN CATCH
	PRINT 'Error al crear el punto de venta: ' + ERROR_MESSAGE();
END CATCH
GO

-- Test 3: Descripci�n inv�lida (con caracteres que no sean letras)
BEGIN TRY
	EXEC Area_Comercial.SP_CrearPuntoDeVenta @Descripcion = '+PuntoD3V3ntaT3st.'
END TRY
BEGIN CATCH
	PRINT 'Error al crear el punto de venta: ' + ERROR_MESSAGE();
END CATCH
GO

-- Test 4: Descripci�n inv�lida (supera el tama�o declarado)
BEGIN TRY
	EXEC Area_Comercial.SP_CrearPuntoDeVenta @Descripcion = 'PuntoDeVentaTestPuntoDeVentaTestPuntoDeVentaTestPuntoDeVentaTestPuntoDeVentaTestPuntoDeVentaTestPuntoDeVentaTest'
END TRY
BEGIN CATCH
	PRINT 'Error al crear el punto de venta: ' + ERROR_MESSAGE();
END CATCH
GO

-- Test 5: La descripci�n ya existe
BEGIN TRY
	EXEC Area_Comercial.SP_CrearPuntoDeVenta @Descripcion = 'PuntoDeVentaTest'
END TRY
BEGIN CATCH
	PRINT 'Error al crear el punto de venta: ' + ERROR_MESSAGE();
END CATCH
GO


-- 4. TIPO_VISITANTE
-- Test 1: Creaci�n exitosa
BEGIN TRY
	EXEC Area_Comercial.SP_CrearTipoVisitante @Descripcion = 'TipoVisitanteTest'

	SELECT * FROM Area_Comercial.Tipo_Visitante
	WHERE Descripcion = 'TipoVisitanteTest'
END TRY
BEGIN CATCH
	PRINT 'Error al crear el tipo de visitante: ' + ERROR_MESSAGE();
END CATCH
GO

-- Test 2: Descripci�n inv�lida (vac�a)
BEGIN TRY
	EXEC Area_Comercial.SP_CrearTipoVisitante @Descripcion = ''
END TRY
BEGIN CATCH
	PRINT 'Error al crear el tipo de visitante: ' + ERROR_MESSAGE();
END CATCH
GO

-- Test 3: Descripci�n inv�lida (con caracteres que no sean letras)
BEGIN TRY
	EXEC Area_Comercial.SP_CrearTipoVisitante @Descripcion = 'TipoVisitanteTest&|'
END TRY
BEGIN CATCH
	PRINT 'Error al crear el tipo de visitante: ' + ERROR_MESSAGE();
END CATCH
GO

-- Test 4: Descripci�n inv�lida (supera el tama�o declarado)
BEGIN TRY
	EXEC Area_Comercial.SP_CrearTipoVisitante @Descripcion = 'TipoVisitanteTestTipoVisitanteTestTipoVisitanteTestTipoVisitanteTestTipoVisitanteTestTipoVisitanteTest'
END TRY
BEGIN CATCH
	PRINT 'Error al crear el tipo de visitante: ' + ERROR_MESSAGE();
END CATCH
GO

-- Test 5: La descripci�n ya existe
BEGIN TRY
	EXEC Area_Comercial.SP_CrearTipoVisitante @Descripcion = 'TipoVisitanteTest'
END TRY
BEGIN CATCH
	PRINT 'Error al crear el tipo de visitante: ' + ERROR_MESSAGE();
END CATCH
GO


-- ===========================================================================================
--                               Pruebas de modificaci�n
-- ===========================================================================================

-- 1. DESCUENTO_PARQUE
-- Se crea un parque y un descuento de prueba para realizar los tests. El ID de ambos ser� 1
-- Parque
BEGIN TRY
    EXEC Area_Infraestructura.Sp_CrearRegion
        @Nombre = 'RegionTest'

    EXEC Area_Infraestructura.Sp_CrearProvincia
        @Nombre = 'ProvinciaTest',
        @Region = 'RegionTest'

    EXEC Area_Infraestructura.Sp_CrearTipoParque
        @Descripcion = 'TipoParqueTest'

    EXEC Area_Infraestructura.Sp_CrearParque
        @Nombre = 'ParquePrueba',
        @TipoParqueDesc = 'TipoParqueTest',
        @Provincia = 1,
        @Superficie = 50000.00
    
    SELECT par.IdParque, par.Nombre, par.Superficie, pro.Nombre AS Provincia FROM Area_Infraestructura.Parque par
    JOIN Area_Infraestructura.Provincia pro ON pro.IdProvincia = par.IdProvincia
    WHERE par.Nombre = 'Este es un parque de prueba' AND pro.Nombre = 'ProvinciaTest' AND par.Superficie = 50000.00;
END TRY
BEGIN CATCH
    PRINT 'Error al crear el parque: ' + ERROR_MESSAGE();
END CATCH
GO

-- Descuento
BEGIN TRY
    EXEC Area_Comercial.Sp_CrearDescuentoParque
        @IdParque = 1,
        @Descripcion = 'DescuentoTest',
        @Porcentaje = 0.30

    SELECT * FROM Area_Comercial.Descuento_Parque
    WHERE Descripcion = 'DescuentoTest'
END TRY
BEGIN CATCH
    PRINT 'Error al crear el descuento: ' + ERROR_MESSAGE()
END CATCH
GO

-- Test 1: Caso exitoso
BEGIN TRY
    EXEC Area_Comercial.Sp_ModificarDescuentoParque
        @IdDescuento = 1,
        @Descripcion = 'DescuentoModificado',
        @Porcentaje = 0.25

    SELECT * FROM Area_Comercial.Descuento_Parque
    WHERE IdDescuento = 1
END TRY
BEGIN CATCH
    PRINT 'Error al modificar el descuento: ' + ERROR_MESSAGE()
END CATCH
GO

-- Test 2: El descuento no est� cargado en la DB
BEGIN TRY
    EXEC Area_Comercial.Sp_ModificarDescuentoParque
        @IdDescuento = 3,
        @Descripcion = 'DescuentoModificado',
        @Porcentaje = 0.25
END TRY
BEGIN CATCH
    PRINT 'Error al modificar el descuento: ' + ERROR_MESSAGE()
END CATCH
GO

-- Test 3: Descripci�n inv�lida (vac�o)
BEGIN TRY
    EXEC Area_Comercial.Sp_ModificarDescuentoParque
        @IdDescuento = 1,
        @Descripcion = '',
        @Porcentaje = 0.25
END TRY
BEGIN CATCH
    PRINT 'Error al modificar el descuento: ' + ERROR_MESSAGE()
END CATCH
GO

-- Test 4: Descripci�n inv�lida (con caracteres que no son letras)
BEGIN TRY
    EXEC Area_Comercial.Sp_ModificarDescuentoParque
        @IdDescuento = 1,
        @Descripcion = '123DescuentoModificado%&#$&',
        @Porcentaje = 0.25
END TRY
BEGIN CATCH
    PRINT 'Error al modificar el descuento: ' + ERROR_MESSAGE()
END CATCH
GO

-- Test 5: Descripci�n inv�lida (supera el tama�o declarado)
BEGIN TRY
    EXEC Area_Comercial.Sp_ModificarDescuentoParque
        @IdDescuento = 1,
        @Descripcion = 'DescuentoModificadoDescuentoModificadoDescuentoModificadoDescuentoModificadoDescuentoModificado',
        @Porcentaje = 0.25
END TRY
BEGIN CATCH
    PRINT 'Error al modificar el descuento: ' + ERROR_MESSAGE()
END CATCH
GO

-- Test 6: Porcentaje menor o igual a cero
BEGIN TRY
    EXEC Area_Comercial.Sp_ModificarDescuentoParque
        @IdDescuento = 1,
        @Descripcion = 'DescuentoModificado',
        @Porcentaje = 0
END TRY
BEGIN CATCH
    PRINT 'Error al modificar el descuento: ' + ERROR_MESSAGE()
END CATCH
GO


-- 2. FORMA_DE_PAGO
--Se crea una forma de pago de prueba para realizar los tests. El ID de este caso ser� 1
BEGIN TRY
	EXEC Area_Comercial.SP_CrearFormaDePago @Descripcion = 'FormaDePagoTest'
END TRY
BEGIN CATCH
	PRINT 'Error al crear la forma de pago: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 1: Caso exitoso
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarFormaDePago
		@IdFormaDePago = 1,
		@Descripcion = 'FormaDePagoModificada'
END TRY
BEGIN CATCH
	PRINT 'Error al modificar la forma de pago: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 2: Descripci�n inv�lida (vac�a)
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarFormaDePago
		@IdFormaDePago = 1,
		@Descripcion = ''
END TRY
BEGIN CATCH
	PRINT 'Error al modificar la forma de pago: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 3: Descripci�n inv�lida (con caracteres que no son letras)
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarFormaDePago
		@IdFormaDePago = 1,
		@Descripcion = 'FormaDePagoModificada505'
END TRY
BEGIN CATCH
	PRINT 'Error al modificar la forma de pago: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 4: Descripci�n inv�lida (supera el tama�o declarado)
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarFormaDePago
		@IdFormaDePago = 1,
		@Descripcion = 'FormaDePagoModificadaFormaDePagoModificadaFormaDePagoModificadaFormaDePagoModificadaFormaDePagoModificadaFormaDePagoModificada'
END TRY
BEGIN CATCH
	PRINT 'Error al modificar la forma de pago: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 5: La forma de pago no est� cargada en la DB
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarFormaDePago
		@IdFormaDePago = 3,
		@Descripcion = 'FormaDePagoModificada'
END TRY
BEGIN CATCH
	PRINT 'Error al modificar la forma de pago: ' + ERROR_MESSAGE();
END CATCH
GO


-- 3. PUNTO_DE_VENTA
--Se crea un punto de venta de prueba para realizar los tests. El ID de este caso ser� 1
BEGIN TRY
	EXEC Area_Comercial.SP_CrearPuntoDeVenta @Descripcion = 'PuntoDeVentaTest'
END TRY
BEGIN CATCH
	PRINT 'Error al crear el punto de venta: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 1: Caso exitoso
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarPuntoDeVenta
		@IdPuntoDeVenta = 1,
		@Descripcion = 'PuntoDeVentaModificado'
END TRY
BEGIN CATCH
	PRINT 'Error al modificar el punto de venta: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 2: Descripci�n inv�lida (vac�a)
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarPuntoDeVenta
		@IdPuntoDeVenta = 1,
		@Descripcion = ''
END TRY
BEGIN CATCH
	PRINT 'Error al modificar el punto de venta: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 3: Descripci�n inv�lida (con caracteres que no son letras)
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarPuntoDeVenta
		@IdPuntoDeVenta = 1,
		@Descripcion = '|||PuntoDeVentaModificado'
END TRY
BEGIN CATCH
	PRINT 'Error al modificar el punto de venta: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 4: Descripci�n inv�lida (supera el tama�o declarado)
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarPuntoDeVenta
		@IdPuntoDeVenta = 1,
		@Descripcion = 'PuntoDeVentaModificadoPuntoDeVentaModificadoPuntoDeVentaModificadoPuntoDeVentaModificadoPuntoDeVentaModificadoPuntoDeVentaModificado'
END TRY
BEGIN CATCH
	PRINT 'Error al modificar el punto de venta: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 5: El punto de venta no est� cargado en la DB
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarPuntoDeVenta 3, 'PuntoDeVentaModificado'
		@IdPuntoDeVenta = 3,
		@Descripcion = 'PuntoDeVentaModificado'
END TRY
BEGIN CATCH
	PRINT 'Error al modificar el punto de venta: ' + ERROR_MESSAGE();
END CATCH
GO


-- 4. TIPO_VISITANTE
--Se crea un tipo de visitante de prueba para realizar los tests. El ID de este caso ser� 1
BEGIN TRY
	EXEC Area_Comercial.SP_CrearTipoVisitante @Descripcion = 'TipoVisitanteTest'
END TRY
BEGIN CATCH
	PRINT 'Error al crear el tipo de visitante: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 1: Caso exitoso
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarTipoVisitante
		@IdTipoVisitante = 1,
		@Descripcion = 'TipoVisitanteModificado'

	SELECT * FROM Area_Comercial.Forma_De_Pago
	WHERE IdFormaDePago = 1
END TRY
BEGIN CATCH
	PRINT 'Error al modificar el tipo de visitante: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 2: Descripci�n inv�lida (vac�a)
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarTipoVisitante
		@IdTipoVisitante = 1,
		@Descripcion = ''
END TRY
BEGIN CATCH
	PRINT 'Error al modificar el tipo de visitante: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 3: Descripci�n inv�lida (con caracteres que no son letras)
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarTipoVisitante
		@IdTipoVisitante = 1,
		@Descripcion = '123TipoVisitanteModificado&#'
END TRY
BEGIN CATCH
	PRINT 'Error al modificar el tipo de visitante: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 4: Descripci�n inv�lida (supera el tama�o declarado)
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarTipoVisitante
		@IdTipoVisitante = 1,
		@Descripcion = 'TipoVisitanteModificadoTipoVisitanteModificadoTipoVisitanteModificadoTipoVisitanteModificadoTipoVisitanteModificado'
END TRY
BEGIN CATCH
	PRINT 'Error al modificar el tipo de visitante: ' + ERROR_MESSAGE();
END CATCH
GO

--Test 5: El tipo de visitante no est� cargado en la DB
BEGIN TRY
	EXEC Area_Comercial.SP_ModificarTipoVisitante
		@IdTipoVisitante = 3,
		@Descripcion = 'TipoVisitanteModificado'
END TRY
BEGIN CATCH
	PRINT 'Error al modificar el tipo de visitante: ' + ERROR_MESSAGE();
END CATCH
GO


-- ===========================================================================================
--                                Pruebas de eliminaci�n
-- ===========================================================================================

-- 1. DESCUENTO_PARQUE
-- Se crea un parque y un descuento de prueba para realizar los tests. El ID de ambos ser� 1
-- Parque
BEGIN TRY
    EXEC Area_Infraestructura.Sp_CrearRegion
        @Nombre = 'RegionTest'

    EXEC Area_Infraestructura.Sp_CrearProvincia
        @Nombre = 'ProvinciaTest',
        @Region = 'RegionTest'

    EXEC Area_Infraestructura.Sp_CrearTipoParque
        @Descripcion = 'TipoParqueTest'

    EXEC Area_Infraestructura.Sp_CrearParque
        @Nombre = 'ParquePrueba',
        @TipoParqueDesc = 'TipoParqueTest',
        @Provincia = 1,
        @Superficie = 50000.00
    
    SELECT par.IdParque, par.Nombre, par.Superficie, pro.Nombre AS Provincia FROM Area_Infraestructura.Parque par
    JOIN Area_Infraestructura.Provincia pro ON pro.IdProvincia = par.IdProvincia
    WHERE par.Nombre = 'Este es un parque de prueba' AND pro.Nombre = 'ProvinciaTest' AND par.Superficie = 50000.00;
END TRY
BEGIN CATCH
    PRINT 'Error al crear el parque: ' + ERROR_MESSAGE();
END CATCH
GO

-- Descuento
BEGIN TRY
    EXEC Area_Comercial.Sp_CrearDescuentoParque
        @IdParque = 1,
        @Descripcion = 'DescuentoTest',
        @Porcentaje = 0.30

    SELECT * FROM Area_Comercial.Descuento_Parque
    WHERE Descripcion = 'DescuentoTest'
END TRY
BEGIN CATCH
    PRINT 'Error al crear el descuento: ' + ERROR_MESSAGE()
END CATCH
GO

-- Test 1: Caso exitoso
BEGIN TRY
    EXEC Area_Comercial.Sp_EliminarDescuentoParque @IdDescuento = 1
END TRY
BEGIN CATCH
    PRINT 'Error al eliminar el descuento: ' + ERROR_MESSAGE()
END CATCH
GO

-- Test 2: El descuento no est� cargado en la DB
BEGIN TRY
    EXEC Area_Comercial.Sp_EliminarDescuentoParque @IdDescuento = 3
END TRY
BEGIN CATCH
    PRINT 'Error al eliminar el descuento: ' + ERROR_MESSAGE()
END CATCH
GO


-- 2. FORMA_DE_PAGO
-- Se crea una forma de pago de prueba para realizar los tests. El ID de este caso ser� 1
BEGIN TRY
	EXEC Area_Comercial.SP_CrearFormaDePago @Descripcion = 'FormaDePagoTest'
END TRY
BEGIN CATCH
	PRINT 'Error al crear la forma de pago: ' + ERROR_MESSAGE();
END CATCH
GO

-- Test 1: Caso exitoso
BEGIN TRY
	EXEC Area_Comercial.SP_EliminarFormaDePago @IdFormaDePago = 1
END TRY
BEGIN CATCH
	PRINT 'Error al eliminar la forma de pago: ' + ERROR_MESSAGE();
END CATCH
GO

-- Test 2: La forma de pago no est� cargado en la DB
BEGIN TRY
	EXEC Area_Comercial.SP_EliminarFormaDePago @IdFormaDePago = 3
END TRY
BEGIN CATCH
	PRINT 'Error al eliminar la forma de pago: ' + ERROR_MESSAGE();
END CATCH
GO


-- 3. PUNTO_DE_VENTA
-- Se crea un punto de venta de prueba para realizar los tests. El ID de este caso ser� 1
BEGIN TRY
	EXEC Area_Comercial.SP_CrearPuntoDeVenta @Descripcion = 'PuntoDeVentaTest'
END TRY
BEGIN CATCH
	PRINT 'Error al crear el punto de venta: ' + ERROR_MESSAGE();
END CATCH
GO

-- Test 1: Caso exitoso
BEGIN TRY
	EXEC Area_Comercial.SP_EliminarPuntoDeVenta @IdPuntoDeVenta = 1
END TRY
BEGIN CATCH
	PRINT 'Error al eliminar el punto de venta: ' + ERROR_MESSAGE();
END CATCH
GO

-- Test 2: El punto de venta no est� cargado en la DB
BEGIN TRY
	EXEC Area_Comercial.SP_EliminarPuntoDeVenta @IdPuntoDeVenta = 3
END TRY
BEGIN CATCH
	PRINT 'Error al eliminar el punto de venta: ' + ERROR_MESSAGE();
END CATCH
GO


-- 4. TIPO_VISITANTE
-- Se crea un tipo de visitante de prueba para realizar los tests. El ID de este caso ser� 1
BEGIN TRY
	EXEC Area_Comercial.SP_CrearTipoVisitante @Descripcion = 'TipoVisitanteTest'
END TRY
BEGIN CATCH
	PRINT 'Error al crear el tipo de visitante: ' + ERROR_MESSAGE();
END CATCH
GO

-- Test 1: Caso exitoso
BEGIN TRY
	EXEC Area_Comercial.SP_EliminarTipoVisitante @IdTipoVisitante = 1
END TRY
BEGIN CATCH
	PRINT 'Error al eliminar el tipo de visitante: ' + ERROR_MESSAGE();
END CATCH
GO

-- Test 2: El tipo de visitante no est� cargado en la DB
BEGIN TRY
	EXEC Area_Comercial.SP_EliminarTipoVisitante @IdTipoVisitante = 3
END TRY
BEGIN CATCH
	PRINT 'Error al eliminar el tipo de visitante: ' + ERROR_MESSAGE();
END CATCH
GO