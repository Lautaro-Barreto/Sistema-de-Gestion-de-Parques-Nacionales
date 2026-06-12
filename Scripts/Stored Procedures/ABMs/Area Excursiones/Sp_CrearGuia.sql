/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para crear un guía.
*/


USE SGParquesNacionales
go

CREATE PROCEDURE Area_Excursiones.Sp_CrearGuia
    @DNI CHAR(8),
    @idParque INT,
    @idEspecialidad INT,
    @Nombre VARCHAR(30),
    @Apellido VARCHAR(30),
    @Titulo VARCHAR(30)

AS
BEGIN
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
        --El dni no debe exsitir en la db 
        IF @DNI IS NULL OR LEN(@DNI) == 0
        BEGIN
            RAISERROR('Debe ingresar un DNI valido', 16, 1)
        END

        IF EXISTS(SELECT 1 FROM Area_Excursiones.Guia WHERE DNI = @DNI)
        BEGIN 
            RAISERROR('El DNI ya existe en la base de datos.', 16, 1)
            
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

    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
        BEGIN
            RAISERROR('Error al crear el guía', 16, 1)
            RETURN;
        END
    END CATCH

    INSERT INTO Area_Excursiones.Guia (DNI, IdParque, IdEspecialidad, Nombre, Apellido, Titulo)
    VALUES (@DNI, @idParque, @idEspecialidad, @Nombre, @Apellido, @Titulo)
    DECLARE @Id_NuevoGuia INT
    SET @Id_NuevoGuia = SCOPE_IDENTITY()
    RETURN @Id_NuevoGuia
END
GO
