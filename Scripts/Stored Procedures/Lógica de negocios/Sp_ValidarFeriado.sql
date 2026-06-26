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