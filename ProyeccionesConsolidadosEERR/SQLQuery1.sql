-- ARGUMENTOS
DECLARE @path VARCHAR(255) = 'C:\Consolidacion\Files\ISA Presup. 2018 (Ind.).csv';
--VARIABLES
DECLARE @sql varchar(max);
-- CURSORES
DECLARE @curRecorreFilas CURSOR;
--
DECLARE @Fila VARCHAR(MAX);
-- TABLAS TEMPORALES
CREATE TABLE #EERR_TMP_TextLine (txtline VARCHAR(MAX));
--

-- Insertamos las lineas del archivo CSV en una tabla temporal
SET @sql = 'BULK INSERT #EERR_TMP_TextLine FROM ''' + @path + ''';';
EXEC (@sql)
-- Eliminamos las lineas vacias
DELETE FROM #EERR_TMP_TextLine WHERE LEN(REPLACE(REPLACE(REPLACE(REPLACE(txtline,';',''),'0',''),'-',''),'.','')) = 0;
-- Obtenemos columnas
SET @curRecorreFilas  = CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR 
	SELECT txtline FROM #EERR_TMP_TextLine;
OPEN 


select * from #EERR_TMP_TextLine
DROP TABLE #EERR_TMP_TextLine
