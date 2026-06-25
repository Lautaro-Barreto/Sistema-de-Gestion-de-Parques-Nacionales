/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de crear el Stored Procedure utilizado para generar seed data del área de infraestructura.
*/

USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_AreaInfraSeed
    @Regiones INT = 1,
    @Provincias INT = 1,
    @TiposParque INT = 1,
    @TiposVisitante INT = 1,
    @Parques INT = 1,
    @Guardaparques INT = 1
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- ==============================================================================
        --  CREACION DE REGIONES, PROVINCIAS, TIPOS DE PARQUE Y TIPOS DE VISITANTE
        -- ==============================================================================

        IF @Regiones = 1 AND NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Region)
        BEGIN
            EXEC Area_Infraestructura.SP_CrearRegion 'Región Centro Este';
            EXEC Area_Infraestructura.SP_CrearRegion 'Región Centro';
            EXEC Area_Infraestructura.SP_CrearRegion 'Región Noreste';
            EXEC Area_Infraestructura.SP_CrearRegion 'Región Noroeste';
            EXEC Area_Infraestructura.SP_CrearRegion 'Región Patagonia Austral';
            EXEC Area_Infraestructura.SP_CrearRegion 'Región Patagonia Norte';
        END

        IF @Provincias = 1 AND NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Provincia)
        BEGIN
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Cordoba', @NombreRegion = 'Región Centro';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'La Rioja', @NombreRegion = 'Región Centro';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'San Juan', @NombreRegion = 'Región Centro';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'San Luis', @NombreRegion = 'Región Centro';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Mendoza', @NombreRegion = 'Región Centro';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Buenos Aires', @NombreRegion = 'Región Centro Este';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Entre Rios', @NombreRegion = 'Región Centro Este';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Santa Fe', @NombreRegion = 'Región Centro Este';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Chaco', @NombreRegion = 'Región Noreste';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Corrientes', @NombreRegion = 'Región Noreste';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Formosa', @NombreRegion = 'Región Noreste';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Misiones', @NombreRegion = 'Región Noreste';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Jujuy', @NombreRegion = 'Región Noroeste';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Santiago Del Estero', @NombreRegion = 'Región Noroeste';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Salta', @NombreRegion = 'Región Noroeste';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Tucuman', @NombreRegion = 'Región Noroeste';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Santa Cruz', @NombreRegion = 'Región Patagonia Austral';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Tierra Del Fuego', @NombreRegion = 'Región Patagonia Austral';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Chubut', @NombreRegion = 'Región Patagonia Norte';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'La Pampa', @NombreRegion = 'Región Patagonia Norte';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Neuquen', @NombreRegion = 'Región Patagonia Norte';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Rio Negro', @NombreRegion = 'Región Patagonia Norte';
            EXEC Area_Infraestructura.SP_CrearProvincia @Nombre = 'Catamarca', @NombreRegion = 'Región Noroeste';
        END

        -- Inserción de Tipos de Parque y Tipos de Visitante
        IF @TiposParque = 1 AND NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Tipo_Parque where Descripcion  in ('Parque Nacional', 'Reserva Natural', 'Monumento Natural')))
        BEGIN
            EXEC Area_Infraestructura.SP_CrearTipoParque 'Parque Nacional';
            EXEC Area_Infraestructura.SP_CrearTipoParque 'Reserva Natural';
            EXEC Area_Infraestructura.SP_CrearTipoParque 'Monumento Natural';
        END

        IF @TiposVisitante = 1 AND NOT EXISTS (SELECT 1 FROM Area_Comercial.Tipo_Visitante where Descripcion in ('Residente', 'No residente')))
        BEGIN
            EXEC Area_Comercial.SP_CrearTipoVisitante 'Residente';
            EXEC Area_Comercial.SP_CrearTipoVisitante 'No residente';
        END

        -- ==============================================================================
        --      CREACIÓN DE PARQUES, CON PRECIOS Y DESCUENTOS PARA CADA UNO
        -- ==============================================================================

        -- Inserción de 10 Parques (Seed Data)
        IF @Parques = 1 AND NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Parque WHERE Nombre IN ('Parque Nacional De Los Payasos', 'Monumento Natural El Nahual', 'Parque Nacional Los Chicos del Chaco', 'Reserva Natural Hnatiuk', 'Monumento Natural Los Héroes de Malvinas', 'Reserva Natural Península del Libertador', 'Monumento Natural Los Héroes de Malvinas', 'Parque Nacional Agustina', 'Parque Nacional Semilla', 'Reserva Natural Bossero'))
        BEGIN
            EXEC Area_Infraestructura.SP_CrearParque @Nombre = 'Parque Nacional De Los Payasos', @Provincia = 'Buenos Aires', @TipoParqueDesc = 'Parque Nacional', @Superficie = 263000.00;
            EXEC Area_Infraestructura.SP_CrearParque @Nombre = 'Monumento Natural El Nahual', @Provincia = 'Rio Negro', @TipoParqueDesc = 'Monumento Natural', @Superficie = 150000.00;
            EXEC Area_Infraestructura.SP_CrearParque @Nombre = 'Parque Nacional Los Chicos del Chaco', @Provincia = 'Chaco', @TipoParqueDesc = 'Parque Nacional', @Superficie = 180000.00;
            EXEC Area_Infraestructura.SP_CrearParque @Nombre = 'Reserva Natural Hnatiuk', @Provincia = 'Santa Cruz', @TipoParqueDesc = 'Reserva Natural', @Superficie = 200000.00;
            EXEC Area_Infraestructura.SP_CrearParque @Nombre = 'Monumento Natural Los Héroes de Malvinas', @Provincia = 'Tierra del Fuego', @TipoParqueDesc = 'Monumento Natural', @Superficie = 150000.00;
            EXEC Area_Infraestructura.SP_CrearParque @Nombre = 'Reserva Natural Península del Libertador', @Provincia = 'Santa Cruz', @TipoParqueDesc = 'Reserva Natural', @Superficie = 150000.00;
            EXEC Area_Infraestructura.SP_CrearParque @Nombre = 'Monumento Natural Los Héroes de Malvinas', @Provincia = 'Misiones', @TipoParqueDesc = 'Monumento Natural', @Superficie = 150000.00;
            EXEC Area_Infraestructura.SP_CrearParque @Nombre = 'Parque Nacional Agustina', @Provincia = 'Chubut', @TipoParqueDesc = 'Parque Nacional', @Superficie = 10000.00;
            EXEC Area_Infraestructura.SP_CrearParque @Nombre = 'Parque Nacional Semilla', @Provincia = 'Mendoza', @TipoParqueDesc = 'Parque Nacional', @Superficie = 130000.00;
            EXEC Area_Infraestructura.SP_CrearParque @Nombre = 'Reserva Natural Bossero', @Provincia = 'Buenos Aires', @TipoParqueDesc = 'Reserva Natural', @Superficie = 12000.00;

            -- Precios y Descuentos para cada Parque
            -- Precios aleatorios entre $2000 y $5000 para Residentes, y $10000 y $25000 para No Residentes
            INSERT INTO Area_Comercial.Precio_Parque_Tipo_Visitante (IdParque, IdTipoVisitante, Precio)
            SELECT p.IdParque, tv.IdTipoVisitante,
                CASE WHEN tv.Descripcion = 'Residente' 
                    THEN 2000 + (ABS(CHECKSUM(NEWID())) % 3000)
                    ELSE 10000 + (ABS(CHECKSUM(NEWID())) % 15000) END
            FROM Area_Infraestructura.Parque p
            CROSS JOIN Area_Comercial.Tipo_Visitante tv
            WHERE NOT EXISTS (
                SELECT 1 FROM Area_Comercial.Precio_Parque_Tipo_Visitante px 
                WHERE px.IdParque = p.IdParque AND px.IdTipoVisitante = tv.IdTipoVisitante
            );

            -- Descuento del 10% por feriado para TODOS los parques
            INSERT INTO Area_Comercial.Descuento_Parque (IdParque, Descripcion, Porcentaje)
            SELECT IdParque, 'Descuento por Feriado Nacional', 0.10
            FROM Area_Infraestructura.Parque p
            WHERE NOT EXISTS (SELECT 1 FROM Area_Comercial.Descuento_Parque d WHERE d.IdParque = p.IdParque);
        END



        -- ==============================================================================
        --      CREACIÓN Y ASIGNACIÓN DE GUARDAPARQUES A LOS PARQUES
        -- ==============================================================================

        IF @Guardaparques = 1 AND NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Guardaparque)
        BEGIN
            -- Creación de 20 Guardaparques
            DECLARE @TotalGuardaparques INT = (SELECT COUNT(*) FROM Area_Infraestructura.Guardaparque WHERE Nombre LIKE 'GpNom%');
            
            DECLARE @nombresYapellidos TABLE (id INT IDENTITY(1,1), nombre VARCHAR(30), apellido VARCHAR(30));
            DECLARE @limInf INT = 1;
            DECLARE @limSup INT = 20;

            insert into @nombresYapellidos values ('Agustina', 'Losada'), ('Lautaro', 'Barreto'), ('Guillermo', 'Hnatiuk'), ('Facundo', 'Bossero'), ('Jair', 'Perez'), ('Julio', 'Bossero'), ('Elias', 'Joseph'), ('Federico', 'Martinez'), ('Tiago', 'Pujia'), ('Cecilia', 'Gonzalez'),
                                        ('Tyler', 'Joseph'), ('Gerard', 'Way'), ('William', 'Afton'), ('Daniel', 'Velazquez'), ('Agustin', 'Claure'), ('Jeremias', 'Gutierrez'), ('Federico', 'Pezzola'), ('Franco', 'Conde'), ('Francisco', 'Comerci'), ('Sofia', 'Salvia');

            -- Asignación de guardaparques a parques de manera aleatoria
            IF @TotalGuardaparques < 20
            BEGIN
                DECLARE @GpNo INT = 1;
                WHILE @GpNo <= 20
                BEGIN
                    DECLARE @RandParqueGp INT = (SELECT TOP 1 IdParque FROM Area_Infraestructura.Parque ORDER BY NEWID());
                    DECLARE @DniGp CHAR(8) = CAST(CAST(RAND() * 89999999 + 10000000 AS INT) AS CHAR(8));
                    DECLARE @NomGp VARCHAR(30) = (SELECT nya.nombre FROM @nombresYapellidos nya WHERE nya.id = CAST(RAND()*(@limSup - @limInf)+@limInf AS INT));
                    DECLARE @ApeGp VARCHAR(30) = (SELECT nya.apellido FROM @nombresYapellidos nya WHERE nya.id = CAST(RAND()*(@limSup - @limInf)+@limInf AS INT));
                    DECLARE @Ingreso DATE = DATEADD(DAY, -CAST(RAND() * 3000 AS INT), GETDATE());
                    INSERT INTO Area_Infraestructura.Guardaparque (IdParque, Dni, Nombre, Apellido, Fecha_Ingreso, Activo)
                    VALUES (@RandParqueGp, @DniGp, @NomGp, @ApeGp, @Ingreso, 1);
                    SET @GpNo = @GpNo + 1;
                END
            END;
            -- Eliminamos los guardaparques repetidos
            -- Acá los parámetros por los que partimos son los que se van a contar como repetidos
            WITH cte(idGuardaparques, nombre, apellido, ocurrencias) AS (
                SELECT idGuardaparque, nombre, apellido, 
                ROW_NUMBER() OVER(PARTITION BY nombre, apellido ORDER BY idGuardaparque) as duplicados
                from Area_Infraestructura.Guardaparque
            )
            delete from cte where ocurrencias > 1;
        END

        COMMIT TRANSACTION
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage VARCHAR(255) = ERROR_MESSAGE();
        RAISERROR('Error al generar seed data del área de infraestructura: %s', 16, 1, @ErrorMessage);
        ROLLBACK TRANSACTION;
    END CATCH
END