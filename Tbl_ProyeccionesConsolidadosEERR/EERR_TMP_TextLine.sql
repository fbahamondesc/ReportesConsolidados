IF OBJECT_ID ( 'EERR_TMP_TextLine', 'U' ) IS NOT NULL 
    DROP TABLE  EERR_TMP_TextLine;
GO

CREATE TABLE EERR_TMP_TextLine (txtline VARCHAR(MAX));