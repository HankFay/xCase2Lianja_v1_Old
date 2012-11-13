/*created 20120821 HJF
Copyright Professional Systems Plus, Inc, All Rights Reserved Worldwide
Licensed under the Apache 2 Open Source License

Bootstrap Version: Creates metatables from xCase model, <modelname>_xc
*/

lParameters tcxCaseDir, tcModelName

set macros on

lcDBName = alltrim(lower(tcModelName)) + "_xc"

if !databaseexists(lcDBName)
	llOK = createdb(lcDBName)
endif
open database (lcDBName)

llOK = openxctables(tcxCaseDir,"ddent,ddfld,ddidx")

select ddent

scan
	if tableexists(lcDBName,alltrim(ddent.name))
		llOK = updatetable()
	else
		llOK = createtable()
	endif
endscan

return

procedure createdb
	lParameters tcDBName
	
	create database (tcDBName)
endproc

procedure createtable
	*** runs from ddent and related tables
	dimension laFields[1,4]
	lcTable = alltrim(ddent.name)
	lnTableID = ddent.identifier
	
	select name, type, len,  dec ;
		from ddfld ;
		into array laFields ;
		where i_entity = lnTableID ;
		order by number
		
	create table &lcTable from array laFields

endproc
	
procedure updatetable
	lianja.showmessage("Hey, updating comes later!")
endproc

procedure openxctables
	lParameters tcModelDir, tcxCaseCursors
	local lnConn, laTables[1,1]
	
	lnConn = AdvantageConnection(tcModelDir)
	if lnConn < 1
		return .F.
	endif
	
	
	for lnTable - 1 to alines(laTables, tcxCaseCursors)
		lcTableLine =laTable[lnTable,1]
		lcTable = getwordnum(1,",")
		lcAlias = lcTable
		llOK = sqlexec(lnConn,"select * from " + lcTable,lcAlias)
		for lnParse = 2 to 10
			lcIndexDef = getwordnum(lcTableLine,lnParse,",")
			if empty(lcIndexDef)
				exit
			endif
			lcTagName = getwordnum(lcIndexDef,1,";")
			lcIndexExpr = getwordnum(lcIndexDef,2,";")
			select (lcAlias)
			index on &lcIndexExpr tag &lcTagname
		endfor
	endfor
endproc
			
		
	