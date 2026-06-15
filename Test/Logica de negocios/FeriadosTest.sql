
/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de probar la conexión con la API de feriados
*/


-- Primero vamos a probar la importación de feriados desde la API para un año que no tenemos cargado en la DB, para corroborar que el procedimiento SP_ObtenerFeriadosDesdeAPI
-- funciona correctamente y que luego podemos validar los feriados importados correctamente también.
--El año 2026 no lo tenemos cargado en la DB, así que el procedimiento debería consultar a la API e importar los feriados de ese año para luego validar la fecha que le pasamos por parámetro

declare @fecha date;
set @fecha = '2026-01-01';
EXEC Area_Comercial.SP_ObtenerFeriadosDesdeAPI @Fecha = @fecha;
go

declare @fecha date;
set @fecha = '2026-01-01';
select * from Area_Comercial.Feriado_Nacional where YEAR(Fecha) = YEAR(@fecha) --Corroboramos que se hayan importado los feriados del año 2026 correctamente.
go

DECLARE @EsFeriado BIT

-- Primero validamos una fecha que sabemos que es feriado, para corroborar que el procedimiento nos devuelve el resultado esperado.
EXEC Area_Comercial.Sp_ValidarFeriado @Fecha = '2026-01-01', @EsFeriado = @EsFeriado OUTPUT;
IF @EsFeriado = 1
BEGIN
    PRINT 'La fecha es un feriado nacional. Es el primer día del año, así que es un feriado fijo y debería aparecer en la API.'
END
ELSE
BEGIN
    PRINT 'La fecha es un feriado nacional. La llamada a la API no funcionó como se esperaba o la API no tiene registrado este feriado, lo cual sería raro porque es un feriado fijo y de los más importantes del año.'
END

-- Luego validamos una fecha que no es feriado, para corroborar que el procedimiento nos devuelve el resultado esperado también en este caso.
EXEC Area_Comercial.Sp_ValidarFeriado @Fecha = '2026-01-02', @EsFeriado = @EsFeriado OUTPUT;
IF @EsFeriado = 1
BEGIN
    PRINT 'La fecha NO es un feriado nacional. La llamada a la API no funcionó como se esperaba o la API tiene registrado un feriado que no es feriado, lo cual sería raro porque el 2 de enero no es un feriado fijo ni nada por el estilo.'
END
ELSE
BEGIN
    PRINT 'La fecha NO es un feriado nacional. La llamada a la API funcionó como se esperaba.'
END