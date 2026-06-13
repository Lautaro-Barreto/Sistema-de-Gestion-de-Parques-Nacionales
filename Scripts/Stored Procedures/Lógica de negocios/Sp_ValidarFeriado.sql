/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
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

CREATE OR ALTER PROCEDURE Area_Comercial.Sp_ValidarFeriado
    @Fecha DATE,
    @EsFeriado BIT OUTPUT
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        EXEC sp_configure 'show advanced options', 1;	--Este es para poder editar los permisos avanzados.
        RECONFIGURE;
        EXEC sp_configure 'Ole Automation Procedures', 1;	--Aqui habilitamos esta opcion avanzada
        RECONFIGURE;

        DECLARE @Object INT
        DECLARE @json TABLE(respuesta NVARCHAR(MAX))	--Usamos una tabla variable
        DECLARE @respuesta NVARCHAR(MAX)
        --Concatenamos la URL con el año de la fecha que recibimos por parámetro, para obtener los feriados de ese año.
        DECLARE @url NVARCHAR(200) = 'https://api.argentinadatos.com/v1/feriados/' + CAST(YEAR(@Fecha) AS NVARCHAR(4))

        EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT	--Creamos una instancia del objeto OLE, que nos permite hacer los llamados.
        EXEC sp_OAMethod @Object, 'OPEN', NULL, 'GET', @url, 'FALSE' --Definimos algunas propiedades del objeto para hacer una llamada HTTP Get.
        EXEC sp_OAMethod @Object, 'SEND' 
        EXEC sp_OAMethod @Object, 'RESPONSETEXT', @respuesta OUTPUT --Guardamos la respuesta de la API en una variable.

        INSERT @json 
	    EXEC sp_OAGetProperty @Object, 'RESPONSETEXT' --Obtenemos el valor de la propiedad 'RESPONSETEXT' del objeto OLE luego de realizar la consulta.

        DECLARE @datos NVARCHAR(MAX) = (SELECT respuesta FROM @json)

        IF EXISTS (
            SELECT * FROM OPENJSON(@datos)
            WITH
            (
                [Fecha] date '$.fecha',
                [Descripcion] nvarchar(40) '$.tipo',
                [Nombre] nvarchar(30) '$.nombre'
            )    
             WHERE Fecha = @Fecha
            )
            SET @EsFeriado = 1
        ELSE
            SET @EsFeriado = 0

    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
        BEGIN	
            RAISERROR('Algo salió mal al obtener los feriados nacionales desde la API de argentinadatos.com', 16, 1);
            RETURN;
        END
    END CATCH
END