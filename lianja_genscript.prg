*** Copyright ProSysPlus and DataWorks 2009-- {^2009-04-24 10:49:25}
* Created
*** {^2009-04-24 10:49:25}
#IF .F.
	TEXT
********************************
*   HELP BUILDER COMMENT BLOCK *
********************************
*:Help Documentation
*:Name:
SQLScript_Gen
*:Purpose:
Generate a script from the VPMDD that creates a SQL Database
*:Keywords:

*:Parameters:
tcTableList: only tables in this list will be moved.
tcFieldList: only useful when there is one table in the list: those fields that will be created
*:Returns:

*:Remarks:
The name of the database is not used in this
*:Example:

*:EndHelp
	ENDTEXT
#ENDIF

LPARAMETERS toConfig 

*!*	tcOutputFile, tcTableList, tcFieldList, tlSkipProcedures, tcEntTable, tcFldTable, ;
*!*		tcIDXTable, tcNewTableSuffix, tlSystemTables, tlSysIntTables

LOCAL lcFieldTypeMatch, lcFieldSpec, lcPrefix, lcOutputFile, lnField, laFieldTypeMatch[1,1], lcIndexExpr
LOCAL lcFields, lcPrimaryIndex, lcIndexExpr, llDescending, llCandidate, llPrimary, lcSQLTableName, lnNumTypes
LOCAL lnCurType, laFieldTypeLines[1,1], lnPrimaryTags, llNoCPTrans, laFields[1,1], lcTableList, lnTable
LOCAL lcTable, tcFieldList, lcField, lcFieldList, lcFieldName, lcIndexName_SQL, lcSQLIndexExpr, lcTagName
LOCAL lcDD2Table, lcDD1Table, lcDindTable, lnFields, laDefaults[1,1], lcSystemTables, lcNewSQLIndexExpr

SET EXCLUSIVE OFF
SET SAFETY OFF

* lcOutputFile = Param_Val(tcOutputFile,"create.prg")
lcOutputFile = Lianja.Application + "_gendd.prg"

IF !EMPTY(tcTableList)
	lcTableList = ""
	FOR lnTable = 1 TO GETWORDCOUNT(tcTableList,",")
		lcTable = UPPER(DEFAULTEXT(ALLTRIM(GETWORDNUM(tcTableList,lnTable,",")),"DBF"))
		lcTableList = lcTableList + "," + lcTable
	ENDFOR
	lcTableList = lcTableList + ","
ENDIF

lcFieldList = ""
IF !EMPTY(tcFieldList)
	lcFieldList = ""
	FOR lnField = 1 TO GETWORDCOUNT(tcFieldList,",")
		lcField = UPPER(DEFAULTEXT(ALLTRIM(GETWORDNUM(tcFieldList,lnField,",")),"DBF"))
		lcFieldList = lcFieldList + "," + lcField
	ENDFOR
	lcFieldList = lcFieldList + ","
ENDIF

IF tlSystemTables
	lcSystemTables = ""
ELSE
	lcSystemTables = ""
ENDIF

IF tlSysIntTables
	lcSysIntTables = ""
ELSE
	lcSysIntTables = ""
ENDIF

#DEFINE iSQLType 1
#DEFINE iDefault 2

SET TEXTMERGE OFF
TEXT TO lcFieldTypeMatch NOSHOW
C(<<tnFieldLen>>);CHAR(<<tnFieldLen>>);''
T;DATETIME;'1900/1/1'
D;DATE;'1900/1/1'
I;INT;0
N(<<tnFieldLen>>,<<tnFieldDec>>);NUMERIC(<<tnFieldLen>>,<<tnFieldDec>>);0
L;LOGICAL;.F.
W;OJBECT;''
M;MEMO <<IIF(!tlNoCPTrans,"","BINARY")>>;<<IIF(!tlNoCPTrans,"''",0)>>
ENDTEXT

lnNumTypes = ALINES(laFieldTypeLines,lcFieldTypeMatch)
DIMENSION laFieldTypeMatch[lnNumTypes,2]
FOR lnCurType = 1 TO lnNumTypes
	laFieldTypeMatch[lnCurType,1] = LEFT(laFieldTypeLines[lnCurType],1)
	laFieldTypeMatch[lnCurType,2] = laFieldTypeLines[lnCurType]
ENDFOR


SET SAFETY OFF

=STRTOFILE("/* Generated " + TRANSFORM(DATETIME()) + " */",lcOutputFile,0) && new file
SET TEXTMERGE TO (lcOutputFile) ADDITIVE NOSHOW
SET TEXTMERGE ON
SET TEXTMERGE DELIMITERS TO "asfd","sdfg"
\-- Version <<lcDBVersion>>
SET TEXTMERGE DELIMITERS TO "<<",">>"

lcEndOfFields = CHR(13) + CHR(10) + ")"

close data all

SET EXCLUSIVE OFF

USE (tcENTTable) AGAIN IN 0 ALIAS ENT

USE (tcFLDTable) AGAIN IN 0 ALIAS FLD

USE (tcIDXTable) AGAIN IN 0 ALIAS IDX

SELECT FLD
SET ORDER TO FLDEN
SELECT IDX
SET ORDER TO DDIDXEN   
SELECT ENT
SET RELATION TO identifier INTO FLD
SET RELATION TO identifier INTO IDX ADDITIVE

SELECT ENT
lnPrimaryTags = 0
SCAN

	IF !EMPTY(lcTableList) AND NOT "," + ALLTRIM(file_name) + "," $ lcTableList
		LOOP
	ENDIF

	lcTableName = JUSTSTEM(ENT.file_name)

	*** we need the nocptrans information, which VPM does not have
	USE (lcSQLTableName) AGAIN IN 0 ALIAS curTable
	=AFIELDS(laFields,"curTable")
	UseIn("curTable")

	SELECT * FROM FLD ;
		WHERE i_entity = ENT.identifier ;
		ORDER BY number ;
		INTO CURSOR myFLD


	*** add the Create Table line
*	\SET ANSI_NULLS ON
*	\go
*	\SET QUOTED_IDENTIFIER ON
*	\go
*	\SET ANSI_PADDING ON
*	\go
*	\SET ANSI_WARNINGS ON
*	\go
	\-- [<<lcTableName>>]
	\-- CREATE TABLE [<<lcTableName>>]
	\CREATE TABLE  [<<lcTableName>>] ( ;
	lnField = 0
	SELECT myFLD
	DIMENSION laDefaults[RECCOUNT("myFLD"),2]
	laDefaults = ""
	lnFields = 0
	SCAN

		IF !EMPTY(lcFieldList) AND NOT "," + ALLTRIM(field_name) + "," $ lcFieldList
			LOOP
		ENDIF

		lnFields = lnFields + 1 
		lcFieldName = ALLTRIM(myFLD.field_name)

		lnField = lnField + 1
		llNoCPTrans = laFields[lnField,6]

		*** Add a field
		\\<<IIF(lnField > 1," ,","")>>
		lcFieldSpec = fieldtypeConvert(@m.laFieldTypeMatch,myFLD.Fld_type,myFLD.Fld_width,myFLD.Fld_dec,llNoCPTrans)
		lcDefaultValue = alltrim(myFld.e_default)
		if !myFld.null and empty(lcDefaultValue)
			lcDefaultValue = DEFAULTVALUE(@m.laFieldTypeMatch,alltrim(myFld.type),,llNoCPTrans)
		ENDIF
		\   [<<lcFieldName>>] <<lcFieldSpec>> <<iif(myField.null,'','NOT')>> NULL <<iif(!empty(lcDefaultValue),'DEFAULT','')>> <<lcDefaultValue>> ;

		laDefaults[lnFields,1] = lcFieldName
		laDefaults[lnFields,2] = lcDefaultValue
	ENDSCAN
	*** close the create table
	\)
	\-- END CREATE TABLE [<<lcTableName>>]
	\
	\
	*** now create the block of defaults, inside a comments
	\
	\/* DEFAULTS
	FOR lnField = 1 TO lnFields
	\alter table <<lcTableName>> add constraint <<"<" + "<lcNewConstraint>" + ">">> default <<laDefaults[lnField,2]>> for <<laDefaults[lnField,1]>>
	ENDFOR
	\*/
	\
	*** add the indexes: set the table being altered
	\-- PrimaryKey
	\Alter Table [<<m.lcTableName>>] ;

	*** add the primary key
	lcPrimaryIndex = ALLTRIM(ENT.PrimaryTag)
	lnPrimaryTags = lnPrimaryTags + 1
	lcIndexName_SQL = "PRIMARY"+TRANSFORM(lnPrimaryTags)
	*=SEEK(PADR(ENT.file_name,230) + lcPrimaryIndex,"IDX","file_name")
	* lcIndexExpr = ALLTRIM(IDX.Index_KEY)
	llDescending = .F.
	lcSQLIndexExpr = ALLTRIM(ENT.PrimaryFld) && IndexExpr_SQL_Fields(ALLTRIM(ENT.file_name),lcIndexExpr,llDescending,"FLD")

	\ ADD CONSTRAINT [<<lcIndexName_SQL>>] PRIMARY KEY CLUSTERED (<<lcSQLIndexExpr>> ASC)
	\ WITH ( IGNORE_DUP_KEY = OFF)
	\
	\-- END PrimaryKey
	\go
	\
	*** add the other keys
	\-- Indexes
	SELECT * FROM IDX ;
		WHERE file_name = ENT.file_name ;
		AND tag_name # lcPrimaryIndex ;
		ORDER BY tag_name ;
		INTO CURSOR myIDX

	SELECT myIDX
	SCAN
		lcTagName = ALLTRIM(myIDX.tag_name)
		llCandidate = myIDX.tag_cand
		lcIndexExpr = myIDX.Index_Expr
		llDescending = myIDX.desc_order
		lcSQLIndexExpr = IndexExpr_SQL_Fields(ALLTRIM(ENT.file_name),lcIndexExpr,llDescending,"FLD")
		
		FOR lnField = 1 TO GETWORDCOUNT(lcSQLIndexExpr,",")
			lcField = GETWORDNUM(lcSQLIndexExpr,lnField,",")
			lcNewSQLIndexExpr = ""
			IF !SEEK(PADR(ENT.file_name,112) + PADR(UPPER(lcField),128),"FLD","File_Name")
				lcNewSQLIndexExpr = ""
				EXIT
			ENDIF
			IF FLD.fld_type = "M"
				lcNewSQLIndexExpr = ""
				EXIT
			ENDIF
			lcNewSQLIndexExpr = "," + lcNewSQLIndexExpr
		ENDFOR
		lcSQLIndexExpr = SUBSTR(lcNewSQLIndexExpr,2)
		IF EMPTY(lcSQLIndexExpr)
			LOOP
		ENDIF		

		\CREATE <<IIF(llCandidate," UNIQUE ","")>> NONCLUSTERED INDEX [<<ALLTRIM(myIDX.tag_name)>>]
		\\ ON [<<lcTableName>>] <<lcSQLIndexExpr>>
		\WITH ( IGNORE_DUP_KEY = OFF)
		\
		\go
		\
	ENDSCAN
	\-- END Indexes
	\-- END [<<lcTableName>>]

ENDSCAN

IF !tlSkipProcedures
	*** add the procedures

\
\SET ANSI_NULLS ON
\go
\SET QUOTED_IDENTIFIER ON
\go
\CREATE FUNCTION [dbo].[Greatest]
\( @val1 SQL_VARIANT,
\  @val2 SQL_VARIANT )
\RETURNS SQL_VARIANT
\AS
\BEGIN
\RETURN ( CASE WHEN @val1 > @val2 THEN @val1
\  ELSE @val2 END )
\END
\go
\
\SET ANSI_NULLS ON
\go
\SET QUOTED_IDENTIFIER ON
\go
\CREATE FUNCTION [dbo].[Least]
\( @val1 SQL_VARIANT,
\  @val2 SQL_VARIANT )
\RETURNS SQL_VARIANT
\AS
\BEGIN
\RETURN ( CASE WHEN @val1 < @val2 THEN @val1
\  ELSE @val2 END )
\END
\go
ENDIF
SET TEXTMERGE OFF
SET TEXTMERGE TO

PROCEDURE IndexExpr_SQL_Fields
	*** returns the fields part of an index expression; the rest comes from IDX
	*** if the last word is desc or descending, sets individual Fields to DESC in SQL
	LPARAMETERS tcFileName, tcIndexExpr, tlDescending, tcFLDAlias
	LOCAL lcFields, lnField, lcWord, lcField, lnNumFields, lcFieldList, lcDescAsc

	lcFieldList = ""
	lcFields = Field_Only(tcFileName,tcIndexExpr,,tcFLDAlias)
	lcDescAsc = IIF(tlDescending,"DESC","ASC")
	FOR lnField = 1 TO GETWORDCOUNT(lcFields,",")
		lcField = GETWORDNUM(lcFields,lnField,",")
		lcFieldList = lcFieldList + "," + "[" + lcField + "] " + lcDescAsc
	ENDFOR
	lcFieldList = SUBSTR(lcFieldList,2) && initial comma
	lcFieldList = "(" + lcFieldList + ")"

	RETURN lcFieldList

PROCEDURE fieldtypeConvert
	LPARAMETERS taFieldTypeMatch, tcFieldType, tnFieldLen, tnFieldDec, tlNoCPTrans
	EXTERNAL ARRAY taFieldTypeMatch

	LOCAL lnType, lcSQLType, lcMergeFile

	lcSQLType = ""
	lnType = ASCAN(taFieldTypeMatch,tcFieldType,1,-1,1,1+8)
	IF lnType = 0
		ASSERT .F. MESSAGE "Field Type Not Found"
	ELSE
		lcSQLType = GETWORDNUM(taFieldTypeMatch[lnType,2],2,";")
		lcMergeFile = SET("Textmerge",2)
		SET TEXTMERGE TO
		lcSQLType = TEXTMERGE(lcSQLType)
		IF !EMPTY(lcMergeFile)
			SET TEXTMERGE TO (lcMergeFile) ADDITIVE
		ENDIF
	ENDIF

	RETURN lcSQLType
ENDPROC

PROCEDURE DEFAULTVALUE
	LPARAMETERS taFieldTypeMatch,tcVFPFieldType,tnFieldLen,tnFieldDec,tlNoCPTrans
	EXTERNAL ARRAY taFieldTypeMatch

	LOCAL lnDefaultLine, lcDefaultExpr, lcMergeFile
	lnDefaultLine = ASCAN(taFieldTypeMatch,m.tcVFPFieldType,1,-1,1,1+8)

	lcDefaultExpr = ''
	IF lnDefaultLine = 0
		ASSERT .F. MESSAGE "Field Default Not Found"
	ELSE
		lcDefaultExpr = GETWORDNUM(taFieldTypeMatch[lnDefaultLine,2],3,";")
		lcMergeFile = SET("Textmerge",2)
		SET TEXTMERGE TO
		lcDefaultExpr = TEXTMERGE(lcDefaultExpr)
		IF !EMPTY(lcMergeFile)
			SET TEXTMERGE TO (lcMergeFile) ADDITIVE
		ENDIF

		lcDefaultExpr = Str_Rep(lcDefaultExpr,.T.)
	ENDIF
	RETURN lcDefaultExpr
ENDPROC

