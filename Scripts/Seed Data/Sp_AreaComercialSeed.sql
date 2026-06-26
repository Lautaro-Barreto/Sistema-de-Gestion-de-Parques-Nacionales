/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de crear el Stored Procedure utilizado para generar seed data del área de comercial.
*/

USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Comercial.Sp_AreaComercialSeed
    @PuntosDeVenta BIT = 1,
    @FormasDePago BIT = 1,
    @TiposVisitantes BIT = 1,
    @HistorialVentas BIT = 1
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- ==============================================================================
        --   CREACIÓN DE PUNTOS DE VENTA, FORMAS DE PAGO Y TIPOS DE VISITANTES
        -- ==============================================================================

        IF @PuntosDeVenta = 1 AND NOT EXISTS (SELECT 1 FROM Area_Comercial.Punto_De_Venta where Descripcion IN ('Boletería Principal', 'Web'))
        BEGIN
            EXEC Area_Comercial.SP_CrearPuntoDeVenta 'Boletería Principal';
            EXEC Area_Comercial.SP_CrearPuntoDeVenta 'Web';
        END

        IF @FormasDePago = 1 AND NOT EXISTS (SELECT 1 FROM Area_Comercial.Forma_De_Pago where Descripcion IN ('Efectivo', 'Tarjeta de Credito', 'Tarjeta de Debito', 'Transferencia'))
        BEGIN
            EXEC Area_Comercial.SP_CrearFormaDePago 'Efectivo';
            EXEC Area_Comercial.SP_CrearFormaDePago 'Tarjeta de Credito';
            EXEC Area_Comercial.SP_CrearFormaDePago 'Tarjeta de Debito';
            EXEC Area_Comercial.SP_CrearFormaDePago 'Transferencia';
        END

        IF @TiposVisitantes = 1 AND NOT EXISTS (SELECT 1 FROM Area_Comercial.Tipo_Visitante where Descripcion IN ('Residente', 'No residente'))
        BEGIN
            EXEC Area_Comercial.Sp_CrearTipoVisitante 'Residente';
            EXEC Area_Comercial.Sp_CrearTipoVisitante 'No residente';
        END

        -- ==============================================================================
        --                          REGISTRO DE VENTAS SIMULADAS
        -- ==============================================================================  
        
        -- Registrar historial de ventas simulado: 5 ventas para cada parque con distinta cantidad de entradas
        IF @HistorialVentas = 1
        BEGIN
            DECLARE @MinId INT = (select MIN(IdParque) FROM Area_Infraestructura.Parque);
            DECLARE @MaxId INT = (SELECT MAX(IdParque) FROM Area_Infraestructura.Parque);
            WHILE @MinId <= @MaxId
            BEGIN
                DECLARE @V_ParqueNombre VARCHAR(80) = (SELECT Nombre FROM Area_Infraestructura.Parque WHERE IdParque = @MinId);
                DECLARE @V_ActividadNombre VARCHAR(80) = (SELECT TOP 1 Nombre FROM Area_Excursiones.Actividad WHERE IdParque = @MinId ORDER BY NEWID());
                IF @V_ActividadNombre IS NOT NULL AND @V_ParqueNombre IS NOT NULL
                BEGIN
                    DECLARE @ventasSimuladas INT = 0;
                    while @ventasSimuladas < 5
                    BEGIN
                        DECLARE @V_TipoVisitante VARCHAR(30) = CASE WHEN RAND() > 0.5 THEN 'Residente' ELSE 'No residente' END;
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
                                DECLARE @ErrorMessageInterno VARCHAR(255) = ERROR_MESSAGE();
                                RAISERROR('Error al generar venta de prueba para el parque %s y la actividad %s: %s', 16, 1, @V_ParqueNombre, @V_ActividadNombre, @ErrorMessageInterno);
                            END CATCH
                        END
                        SET @ventasSimuladas = @ventasSimuladas + 1;
                    END
                END

                SET @MinId = @MinId + 1;
            END
        END
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage VARCHAR(255) = ERROR_MESSAGE();
        RAISERROR('Error al generar seed data del área comercial: %s', 16, 1, @ErrorMessage);
    END CATCH
END