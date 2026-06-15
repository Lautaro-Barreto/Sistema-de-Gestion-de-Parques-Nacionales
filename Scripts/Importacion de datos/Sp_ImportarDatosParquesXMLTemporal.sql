/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para
importar datos de parques nacionales desde archivos XML a una tabla temporal.
*/

USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_ImportarDatosParquesXMLTemporal
    @RutaArchivo VARCHAR(500)
AS
BEGIN
    BEGIN TRY

        SET NOCOUNT ON;
/*         IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'U' AND name = 'Staging_Raw_CSV')
        BEGIN
            RAISERROR('El archivo no existe o no es accesible.', 16, 1);
            RETURN;
        END */
        IF OBJECT_ID('tempdb..##Staging_Parques') IS NULL
        BEGIN
            PRINT 'La tabla temporal de staging no existe. Estas llamando a este procedimiento sin haber ejecutado primero el procedimiento principal de importación?';
            RETURN;
        END

        DECLARE @sql NVARCHAR(MAX);
        SET @sql = N'
        DECLARE @XmlData XML;

        -- 1. Cargamos el archivo físico a una variable XML en memoria
        SELECT @XmlData = CAST(BulkColumn AS XML)
        FROM OPENROWSET(BULK ''' + @RutaArchivo + ''', SINGLE_BLOB) AS Archivo;

        -- 2. Declaramos el "Namespace" oficial de Excel (OpenXML) para poder leer sus nodos
        WITH XMLNAMESPACES (''http://schemas.openxmlformats.org/spreadsheetml/2006/main'' AS ns)

        -- 3. Extraemos e insertamos los datos navegando por el árbol XML
        INSERT INTO Area_Infraestructura.##Staging_Parques (Provincia, Parque, Region, Superficie)
        SELECT 
            -- Leemos el texto dentro de <is><t>
            Pref.value(''(ns:c[substring(@r, 1, 1)="A"]/ns:is/ns:t)[1]'', ''VARCHAR(80)'') AS Provincia,
            Pref.value(''(ns:c[substring(@r, 1, 1)="B"]/ns:is/ns:t)[1]'', ''VARCHAR(80)'') AS Area_Protegida,
            Pref.value(''(ns:c[substring(@r, 1, 1)="D"]/ns:is/ns:t)[1]'', ''VARCHAR(80)'') AS Region,
            -- Como es numérico, Excel lo guarda como <v>
            Pref.value(''(ns:c[substring(@r, 1, 1)="E"]/ns:v)[1]'', ''DECIMAL(14,4)'') AS Superficie

        FROM @XmlData.nodes(''//ns:sheetData/ns:row'') AS T(Pref) -- Iteramos por cada fila (<row>) del Excel
        WHERE 
            Pref.value(''(@r)[1]'', ''INT'') >= 3 -- Empezamos en la fila 3 (saltando el súper-título y los encabezados)
            AND (
            Pref.value(''(ns:c[substring(@r, 1, 1)="B"]/ns:is/ns:t)[1]'', ''VARCHAR(80)'') LIKE ''%Parque%'' 
            OR 
            Pref.value(''(ns:c[substring(@r, 1, 1)="B"]/ns:is/ns:t)[1]'', ''VARCHAR(80)'') LIKE ''%Reserva%''
            OR 
            Pref.value(''(ns:c[substring(@r, 1, 1)="B"]/ns:is/ns:t)[1]'', ''VARCHAR(80)'') LIKE ''%Monumento%''
            )
        ORDER BY Pref.value(''(ns:c[substring(@r, 1, 1)="B"]/ns:is/ns:t)[1]'', ''VARCHAR(80)'');';
        
        EXEC sp_executesql @sql;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO