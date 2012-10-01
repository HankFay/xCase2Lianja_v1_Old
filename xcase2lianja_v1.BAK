*/ created 20120821 HJF
*/ Copyright Professional Systems Plus, Inc, All Right Reserved Worldwide
*/ Licensed under the Apache 2 Open Source License
if !validatexCaseDir()
	return .F.
endif

try
	do pspMetaTables
catch to loError
	if vartype(loError.userval) = "O"
		loError = loError.Userval
	endif
endtry

if vartype(loError) = "O"
	=messagebox("Failed: " + loError.message
	return .F.
else
	return .T.
endif

procedure validatexCaseDir
local lcDir
if !file("xcase2lianja.json")
	writejsontemplate()
	lcDir = getdir(,"Select xCase Model Directory)
	if empty(lcDir)
		myMessageBox("Please fill out xCase2Lianja.json information in the App directory and try again.",.t.)
		return .F.
	else
		updatexCaseModelDir(lcDir)
	endif
else
		
endif

loX2L = X2Lobject()
endproc

procedure writejsontemplate
local loObj
loObj = Object()
loObj.xCaseModelDirectory = "Fill In Directory Here"
lcJson = json_encode(loObj)
=strtofile(lcJson,addbs(Lianja.appdir) + "xCase2Lianja.json")
endproc

procedure X2Lobject
local lcApp
lcApp = Lianja.application
if type("Lianja." + lcApp) = "U"
	Lianja.addproperty(lcApp,Object())
	lcAppObj = eval("Lianja." + lcApp)
	lcAppObj = Object()
else
	lcAppObj = eval("Lianja." + lcApp)
endif
if type("Lianja." + lcApp + "oX2L") = "U"
	lcAppObj.oX2L = json_decode("xcase2lianja.json")
endif
endproc

procedure pspMetaTables
local lcPspMetaDb

lcPspMetaDb = "pspMeta_" + Lianja.Application
if !dbused(lcPspMetaDb)
	if !myOpenData(lcPspMetaDB)
		if !createPspMetaTables(lcPspMetaDB)
			return .F.
		endif
	endif
endif
endproc

procedure createPSPMetaTables		
lParameters tcPspMetaDB

if !myCreateDatabase(tcPspMetaDB)
	return .F.
endif

if !myOpenData(tcPspMetaDB)
	return .F.
endif

set database to (tcPSPMetaDB)
llOK = createPspMeta4Tables() and ;
createPspMeta4Views() and ;
createPspMeta4Fields() and ;
createPspMeta4VFields() and ;
createPspMeta4Indexes() and ;
createPspMeta4Relations() and ;
createPspMeta4FldTriggers() and ;
createPspMeta4VFldTriggers() and ;
createPspMeta4EntityTriggers() and ;
createPspMeta4ViewTriggers()

return llOK
endproc

procedure openxCaseTable
lParameters tcEntity, tcAlias
usein(tcAlias)
opentable(tcEntity,tcAlias)

procedure createPspMeta4Tables()
openxCaseTable("ddent","myddent")

endproc

procedure createPspMeta4Views()

endproc

procedure createPspMeta4Fields()

endproc

procedure createPspMeta4VFields()

endproc

procedure createPspMeta4Indexes()

endproc

procedure createPspMeta4Relations()

endproc

procedure createPspMeta4FldTriggers()

endproc

procedure createPspMeta4VFldTriggers()

endproc

procedure createPspMeta4EntityTriggers()

endproc

procedure createPspMeta4ViewTriggers()

endproc									







