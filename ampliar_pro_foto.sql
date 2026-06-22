-- =======================================================
-- Script para ampliar la columna pro_foto en tbl_producto
-- EJECUTAR en SQL Server Management Studio (SSMS)
-- Base de datos: Monolito4am
-- =======================================================

USE Monolito4am;
GO

-- Ampliar pro_foto de VARCHAR(250) a VARCHAR(500)
-- Esto permite hasta ~10 imágenes con nombres GUID completos
ALTER TABLE dbo.tbl_producto
    ALTER COLUMN pro_foto VARCHAR(500) NULL;
GO

PRINT 'Columna pro_foto ampliada a VARCHAR(500) correctamente.';
GO
