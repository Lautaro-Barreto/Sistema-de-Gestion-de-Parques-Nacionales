-- =============================================
--          Creación de entorno de pruebas
-- =============================================

/*
# Universidad Nacional de la Matanza
# Materia: 3641 - Bases de Datos Aplicada 
# Fecha: 09/06/2026
# Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
# Descripción: En este sript se crea un esquema para testing
*/

USE SGParquesNacionales
GO

IF NOT EXISTS(SELECT * FROM sys.schemas WHERE name = 'Test')
BEGIN
        EXEC ('CREATE SCHEMA Test')
END
GO

-- aca abajo agregar la declaracion de algun SP que haga algo


