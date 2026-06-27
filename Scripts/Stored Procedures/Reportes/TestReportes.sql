/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de generar el reporte de visitas por semana, mes y año, por parque
*/
USE SGParquesNacionales
PRINT 'Reporte de visitas'
EXEC Area_Infraestructura.Sp_ReporteVisitas @IdParque = 5

PRINT 'Reporte de Ingresos'
EXEC Area_Comercial.Sp_ReporteIngresos @IdParque = 5

PRINT 'Reporte Deudores'
PRINT 'Insertamos datos para los canon porque no hay'
GO
BEGIN TRANSACTION
    -- 1. Inserción de Empresas de prueba
    SET IDENTITY_INSERT Area_Negocios.Empresa_Concesionaria ON;
    INSERT INTO Area_Negocios.Empresa_Concesionaria (IdEmpresa, Nombre) VALUES 
    (9991, 'EcoTurismo S.A.'), 
    (9992, 'Aventuras del Sur'),
    (9993, 'Restaurante El Lago');
    SET IDENTITY_INSERT Area_Negocios.Empresa_Concesionaria OFF;
    GO

    -- 2. Inserción de Concesiones
    SET IDENTITY_INSERT Area_Negocios.Concesion ON;
    INSERT INTO Area_Negocios.Concesion (IdConcesion, IdEmpresa) VALUES 
    (9991, 9991), 
    (9992, 9992),
    (9993, 9993);
    SET IDENTITY_INSERT Area_Negocios.Concesion OFF;
    GO

    -- 3. Inserción de Cánones (obligaciones)
    SET IDENTITY_INSERT Area_Negocios.Canon ON;
    INSERT INTO Area_Negocios.Canon (IdCanon, IdConcesion, Monto_Mensual, Fecha_Vencimiento) VALUES 
    -- Concesión 9991: Debe Febrero y Marzo (Completos)
    (9991, 9991, 50000.00, '2026-02-10'), 
    (9992, 9991, 50000.00, '2026-03-10'), 
    (9993, 9991, 50000.00, '2026-07-10'), -- No vencido aún
    -- Concesión 9992: Debe un saldo de Abril (Pago parcial)
    (9994, 9992, 45000.00, '2026-04-10'),
    -- Concesión 9993: Todo al día
    (9995, 9993, 80000.00, '2026-05-10');
    SET IDENTITY_INSERT Area_Negocios.Canon OFF;
    GO

    -- 4. Inserción de Pagos realizados
    SET IDENTITY_INSERT Area_Negocios.Pago_Canon ON;
    INSERT INTO Area_Negocios.Pago_Canon (IdPagoCanon, IdCanon, Monto_Abonado) VALUES 
    -- De la concesión 9992, se pagaron 20.000 de los 45.000 (Debe 25.000 del Canon 9994)
    (9991, 9994, 20000.00), 
    -- De la concesión 9993, se pagó completo (Canon 9995)
    (9992, 9995, 80000.00);
    SET IDENTITY_INSERT Area_Negocios.Pago_Canon OFF;
    GO

    EXEC Area_Negocios.Sp_ReporteDeudores

ROLLBACK TRANSACTION

EXEC Area_Infraestructura.Sp_Reporte_VisitasAnuales  @Año = 2026 -- Le agregué el año para evitar que se junte con otros años

EXEC Area_Infraestructura.Sp_ReporteParquesYConcesionesXML
