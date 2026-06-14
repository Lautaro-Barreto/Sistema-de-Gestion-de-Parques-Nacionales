/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de testear la creación de un parque nacional, 
verificando que no se pueda crear un parque con datos inválidos.   
*/

USE SGParquesNacionales
GO

-- Test 1: Creación exitosa de un parque nacional en una provincia existente, con nombre y tipo de parque (existente) válidos y superficie positiva
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

-- Test 2: Intentar crear un parque con un nombre inválido
BEGIN TRY
    EXEC Area_Infraestructura.Sp_CrearParque
        @Provincia = 'ProvinciaTest',
        @TipoParqueDesc = 'TipoParqueTest',
        @Nombre = 'Parque$###||',
        @Superficie = 50000.00
END TRY
BEGIN CATCH
    PRINT 'Error al crear el parque: ' + ERROR_MESSAGE();
END CATCH
GO

-- Test 3: Intentar crear un parque con un nombre que ya existe en la base de datos
BEGIN TRY
    EXEC Area_Infraestructura.Sp_CrearParque
        @Provincia = 'ProvinciaTest',
        @TipoParqueDesc = 'TipoParqueTest',
        @Nombre = 'ParqueTest',
        @Superficie = 50000.00
END TRY
BEGIN CATCH
    PRINT 'Error al crear el parque: ' + ERROR_MESSAGE();
END CATCH
GO

-- Test 4: Intentar crear un parque con una provincia que no existe en la base de datos
BEGIN TRY
    EXEC Area_Infraestructura.Sp_CrearParque
        @Provincia = 'ProvinciaQueNoExiste',
        @TipoParqueDesc = 'TipoParqueTest',
        @Nombre = 'ParqueTest',
        @Superficie = 50000.00
END TRY
BEGIN CATCH
    PRINT 'Error al crear el parque: ' + ERROR_MESSAGE();
END CATCH
GO

-- Test 5: Intentar crear un parque con una provincia inválida
BEGIN TRY
    EXEC Area_Infraestructura.Sp_CrearParque
        @Provincia = '1231234123413###$$asda',
        @TipoParqueDesc = 'TipoParqueTest',
        @Nombre = 'ParquePrueba',
        @Superficie = 50000.00
END TRY
BEGIN CATCH
    PRINT 'Error al crear el parque: ' + ERROR_MESSAGE();
END CATCH
GO

-- Test 6: Intentar crear un parque con un tipo de parque inválido (contiene caracteres especiales)
BEGIN TRY
    EXEC Area_Infraestructura.Sp_CrearParque
        @Provincia = 'ProvinciaTest',
        @TipoParqueDesc = 'TipoParqueTest@',
        @Nombre = 'ParquePrueba',
        @Superficie = 50000.00
END TRY
BEGIN CATCH
    PRINT 'Error al crear el parque: ' + ERROR_MESSAGE();
END CATCH
GO

-- Test 7: Intentar crear un parque con una superficie negativa
BEGIN TRY
    EXEC Area_Infraestructura.Sp_CrearParque
        @Provincia = 'ProvinciaTest',
        @TipoParqueDesc = 'TipoParqueTest',
        @Nombre = 'ParquePrueba',
        @Superficie = -50000.00
END TRY
BEGIN CATCH
    PRINT 'Error al crear el parque: ' + ERROR_MESSAGE();
END CATCH
GO

EXEC Area_Infraestructura.Sp_EliminarParque
    @Nombre = 'ParquePrueba'

EXEC Area_Infraestructura.Sp_EliminarRegion
    @Nombre = 'RegionTest'
    
EXEC Area_Infraestructura.Sp_EliminarProvincia
    @Nombre = 'ProvinciaTest'

EXEC Area_Infraestructura.Sp_EliminarTipoParque
    @Descripcion = 'TipoParqueTest'