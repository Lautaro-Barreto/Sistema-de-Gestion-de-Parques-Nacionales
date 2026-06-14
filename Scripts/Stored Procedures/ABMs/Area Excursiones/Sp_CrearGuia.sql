/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para crear un guía.
*/


USE SGParquesNacionales
go

CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_CrearGuia
    @DNI CHAR(8),
    @idParque INT,
    @idEspecialidad INT,
    @Nombre VARCHAR(30),
    @Apellido VARCHAR(30),
    @Titulo VARCHAR(30)

AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        --El parque debe estar en la db
        IF NOT EXISTS(SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @idParque)
        BEGIN
            RAISERROR('El Parque no existe.', 16, 1)
        END

        --La especialidad debe estar en la db
        IF NOT EXISTS(SELECT 1 FROM Area_Excursiones.Especialidad WHERE IdEspecialidad = @idEspecialidad)
        BEGIN
            RAISERROR('La especialidad no existe.', 16, 1)
            
        END
        --validar que el dni sea válido
        IF (@DNI LIKE '%[^0-9]%' OR LEN(@DNI) NOT BETWEEN 7 AND 8)
        BEGIN
            RAISERROR('DNI inválido: debe contener solo números y tener entre 7 y 8 dígitos.', 16, 1);
        END

        --El dni no debe existir en la db 
        DECLARE @IdGuiaRepetido INT
        SELECT @IdGuiaRepetido = IdGuia FROM Area_Excursiones.Guia WHERE DNI = @Dni
        IF @IdGuiaRepetido IS NOT NULL
        BEGIN
            RAISERROR('El DNI proporcionado ya está registrado para otro guía.', 16, 1)
            RETURN @IdGuiaRepetido 
        END

        IF( @Nombre IS NULL OR LEN(@Nombre) = 0)
        BEGIN
            RAISERROR('El nombre debe tener entre 1 y 30 caracteres.', 16, 1)
            
        END

        IF( @Apellido IS NULL OR LEN(@Apellido) = 0)
        BEGIN
            RAISERROR('El apellido debe tener entre 1 y 30 caracteres.', 16, 1)
            
        END

        IF( @Titulo IS NULL OR LEN(@Titulo) = 0)
        BEGIN
            RAISERROR('El título debe tener entre 1 y 30 caracteres.', 16, 1)
            
        END

        INSERT INTO Area_Excursiones.Guia (DNI, IdParque, IdEspecialidad, Nombre, Apellido, Titulo)
        VALUES (@DNI, @idParque, @idEspecialidad, @Nombre, @Apellido, @Titulo)
        DECLARE @Id_NuevoGuia INT
        SET @Id_NuevoGuia = SCOPE_IDENTITY()
        RETURN @Id_NuevoGuia

    END TRY

    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END
GO
