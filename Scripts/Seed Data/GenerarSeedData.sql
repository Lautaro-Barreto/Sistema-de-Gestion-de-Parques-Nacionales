/*
Este script inserta la seed data requerida de manera segura (con chequeos de existencia):

Tablas auxiliares inicializadas.
10 Parques adicionales.
30 Actividades asignadas a parques aleatorios.
20 Guías con especialidades asignados a actividades de sus respectivos parques.
20 Guardaparques con fechas de ingreso aleatorias.
10 Concesiones asociadas a empresas concesionarias.
Configuración de precios aleatorios en Precio_Parque_Tipo_Visitante para todos los parques.
Historial de 50 ventas simuladas registradas a través de Sp_RegistrarVentaEntradas.
*/

USE SGParquesNacionales
GO

--EXEC Area_Infraestructura.Sp_GenerarSeedDataAll

BEGIN TRY
    set nocount on;
    BEGIN TRANSACTION;

    -- ==============================================================================
    --  CREACION DE REGIONES, PROVINCIAS, TIPOS DE PARQUE Y TIPOS DE VISITANTE
    -- ==============================================================================

    IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Region)
    BEGIN
        EXEC Area_Infraestructura.SP_CrearRegion 'Región Centro Este';
        EXEC Area_Infraestructura.SP_CrearRegion 'Región Centro';
        EXEC Area_Infraestructura.SP_CrearRegion 'Región Noreste';
        EXEC Area_Infraestructura.SP_CrearRegion 'Región Noroeste';
        EXEC Area_Infraestructura.SP_CrearRegion 'Región Patagonia Austral';
        EXEC Area_Infraestructura.SP_CrearRegion 'Región Patagonia Norte';
    END

    IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Provincia)
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
    END

    -- Inserción de Tipos de Parque y Tipos de Visitante
    IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Tipo_Parque)
        EXEC Area_Infraestructura.SP_CrearTipoParque 'Parque Nacional';
        EXEC Area_Infraestructura.SP_CrearTipoParque 'Reserva Natural';
        EXEC Area_Infraestructura.SP_CrearTipoParque 'Monumento Natural';

    IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Tipo_Visitante)
        EXEC Area_Comercial.SP_CrearTipoVisitante 'Residente';
        EXEC Area_Comercial.SP_CrearTipoVisitante 'No residente';

    -- ==============================================================================
    --      CREACIÓN DE PARQUES, CON PRECIOS Y DESCUENTOS PARA CADA UNO
    -- ==============================================================================

    -- Inserción de 10 Parques (Seed Data)
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

    -- ==============================================================================
    --     CREACIÓN DE ACTIVIDADES, GUÍAS, GUARDAPARQUES Y ASIGNACIÓN DE ESPECIALIDADES
    -- ==============================================================================
    
    -- Creación de 30 Actividades distribuidas en los Parques
    -- cada actividad debe tener una habilitacion 
    IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Tipo_Actividad)
    BEGIN
        EXEC Area_Excursiones.Sp_CrearTipoActividad 'Senderismo';
        EXEC Area_Excursiones.Sp_CrearTipoActividad 'Trekking';
        EXEC Area_Excursiones.Sp_CrearTipoActividad 'Navegacion';
        EXEC Area_Excursiones.Sp_CrearTipoActividad 'Cabalgata';
        EXEC Area_Excursiones.Sp_CrearTipoActividad 'Avistaje de Aves';
        EXEC Area_Excursiones.Sp_CrearTipoActividad 'Observacion de Flora/Fauna';
    END

    IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Habilitacion)
    BEGIN
        INSERT INTO Area_Excursiones.Habilitacion (Descripcion) VALUES 
        ('Primeros Auxilios y RCP'), 
        ('Rescate Acuático y Buceo'), 
        ('Alta Montaña y Escalada'), 
        ('Supervivencia en Entornos Extremos'), 
        ('Observación de Flora y Fauna Local');
    END

    IF (SELECT COUNT(*) FROM Area_Excursiones.Actividad) < 30
    BEGIN
        DECLARE @cantActividades INT = 0;
        WHILE @cantActividades < 30
        BEGIN
            DECLARE @IdTipoActividad INT, @IdParque INT;
            DECLARE @NombreTipoActividad VARCHAR(30) ;
            DECLARE @NombreActividad VARCHAR(30) = 'Tour Guiado';
            DECLARE @Costo decimal(10, 2) = 5000 + (ABS(CHECKSUM(NEWID())) % 10000);
            DECLARE @Duracion INT = 2 + (ABS(CHECKSUM(NEWID())) % 6);
            DECLARE @Cupo_maximo INT = 20 + (ABS(CHECKSUM(NEWID())) % 30);

            SET @IdTipoActividad = (SELECT TOP 1 IdTipoActividad FROM Area_Excursiones.Tipo_Actividad ORDER BY NEWID());
            SET @NombreTipoActividad = (SELECT TOP 1 Descripcion FROM Area_Excursiones.Tipo_Actividad WHERE IdTipoActividad = @IdTipoActividad);
            SET @NombreActividad = @NombreActividad + ' ' + @NombreTipoActividad;
            
            SET @IdParque = (SELECT TOP 1 IdParque FROM Area_Infraestructura.Parque ORDER BY NEWID());

            EXEC Area_Excursiones.Sp_CrearActividad
                @tipoActividad = @IdTipoActividad,
                @idParque = @IdParque,
                @Nombre = @NombreActividad,
                @Costo = @Costo,
                @Duracion = @Duracion,
                @Cupo_maximo = @Cupo_maximo

            -- Asignar requisitos (1 o 2 habilitaciones por actividad)
            INSERT INTO Area_Excursiones.Habilitaciones_por_Actividad (IdActividad, IdHabilitacion)
            SELECT A.IdActividad, H.IdHabilitaciones
            FROM Area_Excursiones.Actividad A
            CROSS APPLY (
                -- Selecciona 1 o 2 habilitaciones aleatorias para cada actividad
                SELECT TOP (1 + ABS(CHECKSUM(NEWID())) % 2) IdHabilitaciones 
                FROM Area_Excursiones.Habilitacion ORDER BY NEWID()
            ) H
            WHERE NOT EXISTS (
                SELECT 1 FROM Area_Excursiones.Habilitaciones_por_Actividad HA 
                WHERE HA.IdActividad = A.IdActividad AND HA.IdHabilitacion = H.IdHabilitaciones
            );

            SET @cantActividades = @cantActividades + 1;
        END
    END

    -- Creación de 20 Guardaparques
    DECLARE @TotalGuardaparques INT = (SELECT COUNT(*) FROM Area_Infraestructura.Guardaparque WHERE Nombre LIKE 'GpNom%');
    
    DECLARE @nombresYapellidos TABLE (id INT IDENTITY(1,1), nombre VARCHAR(30), apellido VARCHAR(30));
    DECLARE @limInf INT = 1;
    DECLARE @limSup INT = 20;

    insert into @nombresYapellidos values ('Agustina', 'Losada'), ('Lautaro', 'Barreto'), ('Guillermo', 'Hnatiuk'), ('Facundo', 'Bossero'), ('Jair', 'Perez'), ('Julio', 'Bossero'), ('Elias', 'Joseph'), ('Federico', 'Martinez'), ('Tiago', 'Pujia'), ('Cecilia', 'Gonzalez'),
                                ('Tyler', 'Joseph'), ('Gerard', 'Way'), ('William', 'Afton'), ('Daniel', 'Velazquez'), ('Agustin', 'Claure'), ('Jeremias', 'Gutierrez'), ('Federico', 'Pezzola'), ('Franco', 'Conde'), ('Francisco', 'Comerci'), ('Sofia', 'Salvia');

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

    -- Creación de 20 Guías con especialidades asignados a actividades de sus respectivos parques
    -- cada guia debe cumplir con todas las habilitaciones de las actividades que se realizan en su parque asignado, por lo que se asigna la habilitacion 
    -- al guia y luego se relaciona el guia con las actividades de su parque que correspondan a esa habilitacion

    EXEC Area_Excursiones.Sp_CrearEspecialidad 'Especialidad en Senderismo';
    EXEC Area_Excursiones.Sp_CrearEspecialidad 'Especialidad en Trekking';
    EXEC Area_Excursiones.Sp_CrearEspecialidad 'Especialidad en Rafting';
    EXEC Area_Excursiones.Sp_CrearEspecialidad 'Especialidad en Cabalgatas';
    EXEC Area_Excursiones.Sp_CrearEspecialidad 'Especialidad en Avistaje de Aves';

    DECLARE @NomYApeGuias TABLE (id INT IDENTITY(1,1), nombre VARCHAR(30), apellido VARCHAR(30));
    INSERT INTO @NomYApeGuias VALUES
    ('Thom', 'Yorke'), ('Jonny', 'Greenwood'), 
    ('Colin', 'Greenwood'), ('Ed', 'O''Brien'),
    ('Phil', 'Selway'), ('Robert', 'Smith'),
    ('Simon', 'Gallup'), ('Jason', 'Cooper'), 
    ('Roger', 'O''Donnell'), ('Reeves', 'Gabrels'),
    ('Michael', 'Dempsey'), ('Andy', 'Anderson'),
    ('Perry', 'Bamonte'), ('Nicholas', 'Matthews'),
    ('Johnny', 'Braddock'), ('Adam', 'Virostko'),
    ('Dan', 'Juarez'), ('Bradley', 'Iverson'),
    ('Ray', 'Toro'), ('Mikey', 'Way');

    DECLARE @TotalGuias INT = (SELECT COUNT(*) FROM Area_Excursiones.Guia WHERE Nombre LIKE 'GuiaNom%');
    DECLARE @RandParqueGuia INT;
    DECLARE @RandEspId INT;
    DECLARE @DniGuia CHAR(8);
    DECLARE @NomGuia VARCHAR(30);
    DECLARE @ApeGuia VARCHAR(30);
    DECLARE @TituloGuia VARCHAR(30);


    IF @TotalGuias < 20
    BEGIN
        DECLARE @GuiaNo INT = 1;
        WHILE @GuiaNo <= 20
        BEGIN
            SET @RandParqueGuia = (SELECT TOP 1 IdParque FROM Area_Infraestructura.Parque ORDER BY NEWID());
            SET @RandEspId = (SELECT TOP 1 IdEspecialidad FROM Area_Excursiones.Especialidad ORDER BY NEWID());
            SET @DniGuia = CAST(CAST(RAND() * 89999999 + 10000000 AS INT) AS CHAR(8));
            SET @NomGuia = (SELECT nombre FROM @NomYApeGuias WHERE id = CAST(RAND()*(@limSup - @limInf)+@limInf AS INT));
            SET @ApeGuia = (SELECT apellido FROM @NomYApeGuias WHERE id = CAST(RAND()*(@limSup - @limInf)+@limInf AS INT));
            SET @TituloGuia = 'Licenciado en turismo';
            INSERT INTO Area_Excursiones.Guia (DNI, IdParque, IdEspecialidad, Nombre, Apellido, Titulo)
            VALUES (@DniGuia, @RandParqueGuia, @RandEspId, @NomGuia, @ApeGuia, @TituloGuia);
            DECLARE @NewGuiaId INT = SCOPE_IDENTITY();
            SET @GuiaNo = @GuiaNo + 1;
        END
    END;
    -- Eliminamos los guias repetidos
    -- Acá los parámetros por los que partimos son los que se van a contar como repetidos
    WITH cte(idGuia, nombre, apellido, ocurrencias) AS (
        SELECT idGuia, nombre, apellido, 
        ROW_NUMBER() OVER(PARTITION BY nombre, apellido ORDER BY idGuia) as duplicados
        from Area_Excursiones.Guia
    )
    delete from cte where ocurrencias > 1;

    -- Asignar Habilitaciones a los Guías
    INSERT INTO Area_Excursiones.Habilitacion_Guia (IdGuia, IdHabilitacion, Fecha_Inicio_Validez, Fecha_Fin_Validez)
    SELECT 
        G.IdGuia, 
        H.IdHabilitaciones, 
        DATEADD(DAY, -30, GETDATE()), -- Inicio hace 30 días
        DATEADD(DAY, 365, GETDATE())  -- Vence en 1 año
    FROM Area_Excursiones.Guia G
    CROSS APPLY (
        -- Truco: Si el ID del guía es par, le damos TODAS las habilitaciones (Guía Maestro).
        -- Si es impar, le damos solo 2 aleatorias. Esto garantiza que haya asignaciones exitosas.
        SELECT TOP (CASE WHEN G.IdGuia % 2 = 0 THEN 5 ELSE 2 END) IdHabilitaciones
        FROM Area_Excursiones.Habilitacion ORDER BY NEWID()
    ) H
    WHERE NOT EXISTS (
        SELECT 1 FROM Area_Excursiones.Habilitacion_Guia HG 
        WHERE HG.IdGuia = G.IdGuia AND HG.IdHabilitacion = H.IdHabilitaciones
    );

    -- ==============================================================================
    -- ASIGNACIÓN DE GUÍAS A ACTIVIDADES (respetando las habilitaciones requeridas)
    -- ==============================================================================
    
    IF OBJECT_ID('tempdb..#ParejasValidas') IS NOT NULL DROP TABLE #ParejasValidas;
    CREATE TABLE #ParejasValidas (Id INT IDENTITY(1,1), IdGuia INT, IdActividad INT);

    -- Filtramos usando exactamente la misma lógica de doble negación del SP
    INSERT INTO #ParejasValidas (IdGuia, IdActividad)
    SELECT G.IdGuia, A.IdActividad
    FROM Area_Excursiones.Guia G
    CROSS JOIN Area_Excursiones.Actividad A
    WHERE NOT EXISTS (
        SELECT 1 FROM Area_Excursiones.Habilitaciones_por_Actividad HA
        WHERE HA.IdActividad = A.IdActividad
        AND NOT EXISTS (
            SELECT 1 FROM Area_Excursiones.Habilitacion_Guia HG 
            WHERE HG.IdGuia = G.IdGuia AND HG.IdHabilitacion = HA.IdHabilitacion 
            AND HG.Fecha_Fin_Validez >= GETDATE()
        )
    )
    AND NOT EXISTS (
        -- Evitamos insertar si la pareja ya existe en Guias_por_Actividad
        SELECT 1 FROM Area_Excursiones.Guias_por_Actividad GA 
        WHERE GA.IdGuia = G.IdGuia AND GA.IdActividad = A.IdActividad
    );

    -- Ejecutamos el SP iterando la tabla temporal
    DECLARE @MaxId INT = (SELECT ISNULL(MAX(Id), 0) FROM #ParejasValidas);
    DECLARE @Iterador INT = 1;
    DECLARE @IdGuiaActual INT, @IdActividadActual INT;

    WHILE @Iterador <= @MaxId
    BEGIN
        SELECT @IdGuiaActual = IdGuia, @IdActividadActual = IdActividad 
        FROM #ParejasValidas WHERE Id = @Iterador;

        EXEC Area_Excursiones.Sp_CrearGuiasPorActividad 
            @IdGuia = @IdGuiaActual, 
            @IdActividad = @IdActividadActual;

        SET @Iterador = @Iterador + 1;
    END

    -- ==============================================================================
    --   CREACIÓN DE PUNTOS DE VENTA, FORMAS DE PAGO, CONCESIONES Y REGISTRO DE VENTAS SIMULADAS
    -- ==============================================================================

    IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Punto_De_Venta)
    BEGIN
        EXEC Area_Comercial.SP_CrearPuntoDeVenta 'Boletería Principal';
        EXEC Area_Comercial.SP_CrearPuntoDeVenta 'Web';
    END

    IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Forma_De_Pago)
    BEGIN
        EXEC Area_Comercial.SP_CrearFormaDePago 'Efectivo';
        EXEC Area_Comercial.SP_CrearFormaDePago 'Tarjeta de Credito';
        EXEC Area_Comercial.SP_CrearFormaDePago 'Tarjeta de Debito';
        EXEC Area_Comercial.SP_CrearFormaDePago 'Transferencia';
    END
   
    -- Crear al menos 10 Concesiones
    IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Empresa_Concesionaria)
    BEGIN
        EXEC Area_Negocios.Sp_CrearEmpresaConcesionaria 'Agus Inc.';
        EXEC Area_Negocios.Sp_CrearEmpresaConcesionaria 'Umbrella Corp';
        EXEC Area_Negocios.Sp_CrearEmpresaConcesionaria 'YPF';
        EXEC Area_Negocios.Sp_CrearEmpresaConcesionaria 'Freddy Fazbear''s Pizza';
        EXEC Area_Negocios.Sp_CrearEmpresaConcesionaria 'Claure & Co.';
    END
    DECLARE @TotalConcesiones INT = (SELECT COUNT(*) FROM Area_Negocios.Concesion);
    IF @TotalConcesiones < 10
    BEGIN
        DECLARE @ConNo INT = 1;
        WHILE @ConNo <= 10
        BEGIN
            DECLARE @RandParqueCon INT = (SELECT TOP 1 IdParque FROM Area_Infraestructura.Parque ORDER BY NEWID());
            DECLARE @RandEmpId INT = (SELECT TOP 1 IdEmpresa FROM Area_Negocios.Empresa_Concesionaria ORDER BY NEWID());
            DECLARE @RandTipoConId INT = (SELECT TOP 1 IdTipoActividadConcesion FROM Area_Negocios.Tipo_Actividad_Concesion ORDER BY NEWID());
            DECLARE @FInicio DATE = DATEADD(DAY, -CAST(RAND() * 365 AS INT), GETDATE());
            DECLARE @FFin DATE = DATEADD(YEAR, 5, @FInicio);
            EXEC Area_Negocios.SP_CrearConcesion @RandTipoConId, @RandEmpId, @RandParqueCon, @FInicio, @FFin
            SET @ConNo = @ConNo + 1;
        END
    END

    -- Registrar historial de ventas simulado
    DECLARE @VentaNo INT = 1;
    WHILE @VentaNo <= 50
    BEGIN
        DECLARE @V_ParqueNombre VARCHAR(80);
        DECLARE @V_ParqueId INT;
        
        SELECT TOP 1 @V_ParqueNombre = Nombre, @V_ParqueId = IdParque FROM Area_Infraestructura.Parque ORDER BY NEWID();
        DECLARE @V_ActividadNombre VARCHAR(80) = (SELECT TOP 1 Nombre FROM Area_Excursiones.Actividad WHERE IdParque = @V_ParqueId);
        
        IF @V_ActividadNombre IS NULL
        BEGIN
            SELECT TOP 1 @V_ActividadNombre = A.Nombre, @V_ParqueId = A.IdParque, @V_ParqueNombre = P.Nombre 
            FROM Area_Excursiones.Actividad A
            INNER JOIN Area_Infraestructura.Parque P ON A.IdParque = P.IdParque
            ORDER BY NEWID();
        END
        DECLARE @V_TipoVisitante VARCHAR(30) = CASE WHEN RAND() > 0.5 THEN 'Residente' ELSE 'No Residente' END;
        DECLARE @V_PuntoDeVenta INT = (SELECT TOP 1 IdPuntoDeVenta FROM Area_Comercial.Punto_De_Venta ORDER BY NEWID());
        DECLARE @V_FormaPago VARCHAR(30) = (SELECT TOP 1 Descripcion FROM Area_Comercial.Forma_De_Pago ORDER BY NEWID());
        DECLARE @V_Fecha DATE = DATEADD(DAY, -CAST(RAND() * 180 AS INT), GETDATE());
        DECLARE @V_CantEntradas INT = CAST(RAND() * 5 + 1 AS INT);
        IF @V_ParqueNombre IS NOT NULL AND @V_ActividadNombre IS NOT NULL AND @V_PuntoDeVenta IS NOT NULL AND @V_FormaPago IS NOT NULL
        BEGIN
            BEGIN TRY
                EXEC Area_Comercial.Sp_RegistrarVentaEntradas
                    @Parque = @V_ParqueNombre,
                    @CantidadEntradas = @V_CantEntradas,
                    @TipoVisitante = @V_TipoVisitante,
                    @Actividad = @V_ActividadNombre,
                    @Fecha = @V_Fecha,
                    @IdPuntoDeVenta = @V_PuntoDeVenta,
                    @FormaDePago = @V_FormaPago;
            END TRY
            BEGIN CATCH
                PRINT 'Error al generar venta de prueba ' + CAST(@VentaNo AS VARCHAR(5)) + ': ' + ERROR_MESSAGE();
            END CATCH
        END
        SET @VentaNo = @VentaNo + 1;
    END

    COMMIT TRANSACTION;
    PRINT 'Seed Data generada exitosamente.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT ERROR_MESSAGE();
END CATCH
GO

-- ==============================================================================
--                                VER RESULTADOS
-- ==============================================================================

-- parques, provincias y regiones
SELECT p.IdParque, p.Nombre, tp.Descripcion as [Tipo de parque], pr.Nombre as [Provincia], r.Nombre as [Region] FROM Area_Infraestructura.Parque p
join area_Infraestructura.Tipo_Parque tp on tp.IdTipoParque = p.IdTipoParque
join area_infraestructura.Provincia pr on pr.IdProvincia = p.IdProvincia
join area_Infraestructura.Region r on r.IdRegion = pr.IdRegion
order by r.Nombre;

-- precios por parque y tipo de visitante
select p.Nombre, tv.Descripcion as [tipo visitante], pptv.Precio from Area_Comercial.Precio_Parque_Tipo_Visitante pptv
join Area_Infraestructura.Parque p on p.IdParque = pptv.IdParque
join Area_Comercial.Tipo_Visitante tv on tv.IdTipoVisitante = pptv.IdTipoVisitante
order by p.Nombre, tv.Descripcion;

-- Descuentos por parque
select p.Nombre, d.Descripcion, d.Porcentaje from Area_Comercial.Descuento_Parque d
join Area_Infraestructura.Parque p on p.IdParque = d.IdParque

-- Actividades con su parque
select a.Nombre as [Actividad], tp.Descripcion as [Tipo Actividad], p.Nombre as [Parque] from Area_Excursiones.Actividad a
join Area_Excursiones.Tipo_Actividad tp on tp.IdTipoActividad = a.IdTipoActividad
join Area_Infraestructura.Parque p on p.IdParque = a.IdParque

-- Guardaparques con su parque
select g.IdGuardaparque, g.Dni, g.Nombre, g.Apellido, p.Nombre as [Parque], g.Fecha_Ingreso, g.Fecha_Egreso from Area_Infraestructura.Guardaparque g
join Area_Infraestructura.Parque p on p.IdParque = g.IdParque

-- Guias con su parque y especialidad
select g.IdGuia, g.DNI, g.Nombre, g.Apellido, p.Nombre as [Parque], e.Descripcion as [Especialidad] from Area_Excursiones.Guia g
join Area_Infraestructura.Parque p on p.IdParque = g.IdParque
join Area_Excursiones.Especialidad e on e.IdEspecialidad = g.IdEspecialidad

-- Actividades con sus guias asignados, su parque y tipo de actividad
select a.Nombre as [Actividad], p.Nombre as [Parque], g.Nombre + ' ' + g.Apellido as [Guia], ta.Descripcion as [Tipo Actividad] from Area_Excursiones.Actividad a
join Area_Infraestructura.Parque p on p.IdParque = a.IdParque
join Area_Excursiones.Guias_por_Actividad ga on ga.IdActividad = a.IdActividad
join Area_Excursiones.Guia g on g.IdGuia = ga.IdGuia
join area_excursiones.Tipo_Actividad ta on ta.IdTipoActividad = a.IdTipoActividad
order by p.Nombre, a.Nombre;

-- Habilitaciones por actividad
select a.Nombre, h.Descripcion
from Area_Excursiones.Habilitaciones_por_Actividad ha
join Area_Excursiones.Habilitacion h on ha.IdHabilitacion = h.IdHabilitaciones
join Area_Excursiones.Actividad a on ha.IdActividad = a.IdActividad

-- Habilitaciones por guia
select g.Nombre + ' ' + g.Apellido as [Guia], h.Descripcion as [Habilitacion], hg.Fecha_Inicio_Validez, hg.Fecha_Fin_Validez
from Area_Excursiones.Habilitacion_Guia hg
join Area_Excursiones.Guia g on g.IdGuia = hg.IdGuia
join Area_Excursiones.Habilitacion h on h.IdHabilitaciones = hg.IdHabilitacion;

-- Concesiones con su parque, empresa concesionaria y tipo de actividad concesionada
select c.IdConcesion, p.Nombre as [Parque], ec.Nombre as [Empresa Concesionaria], tac.Descripcion as [Tipo de Actividad de Concesion], c.Fecha_Inicio, c.Fecha_Fin
from Area_Negocios.Concesion c
join Area_Infraestructura.Parque p on p.IdParque = c.IdParque
join Area_Negocios.Empresa_Concesionaria ec on ec.IdEmpresa = c.IdEmpresa
join Area_Negocios.Tipo_Actividad_Concesion tac on tac.IdTipoActividadConcesion = c.IdTipoActividadConcesion