/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado testear la creacion de actividades
*/

USE SGParquesNacionales
GO

BEGIN TRAN; -- 1. Iniciamos la transacción de prueba

-- ==========================================
-- A. PREPARAR (Arrange)
-- ==========================================
-- Insertar datos falsos temporales (Mocks) necesarios para la prueba.
-- Declarar variables para capturar resultados.
    
-- ==========================================
-- B. EJECUTAR (Act)
-- ==========================================
-- Llamar al Stored Procedure usando un bloque TRY...CATCH

-- ==========================================
-- C. VALIDAR (Assert)
-- ==========================================
-- Hacer un SELECT para comprobar si los datos cambiaron como esperábamos.
-- Imprimir mensajes de 'ÉXITO' o 'FALLO' en la consola.

ROLLBACK TRAN; -- 4. Deshacemos TODO para no dejar basura en la BD.
PRINT 'Prueba finalizada. Base de datos restaurada.';