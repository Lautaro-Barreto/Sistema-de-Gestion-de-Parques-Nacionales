/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 18/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de testear la creación de un descuento,
verificando que no se pueda crear un descuento con datos inválidos.
*/

USE SGParquesNacionales
GO

-- Se crea un parque de prueba para realizar los tests. El ID de este parque será 1
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

-- Test 3: Descripción inválida (vacía)
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

-- Test 4: Descripción inválida (con caracteres que no son letras)
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

-- Test 5: Descripción inválida (supera el tamaño declarado)
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