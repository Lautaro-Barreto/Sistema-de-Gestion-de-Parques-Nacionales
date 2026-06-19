/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 18/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de testear la modificación de un descuento,
verificando que no se pueda modificar un descuento un descuento que no existe o con
datos inválidos.
*/

-- Se crea un parque y un descuento de prueba para realizar los tests. El ID de ambos será 1
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

-- Test 2: El descuento no está cargado en la DB
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

-- Test 3: Descripción inválida (vacío)
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

-- Test 4: Descripción inválida (con caracteres que no son letras)
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

-- Test 5: Descripción inválida (supera el tamaño declarado)
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