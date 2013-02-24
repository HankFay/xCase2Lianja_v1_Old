////////////////////////////////////////////////////////////////
// Event delegate for 'click' event
proc Main_config_cmdRun_click()
	lianja.showmessage("We will now create your database")
endproc



////////////////////////////////////////////////////////////////
// Event delegate for 'dialogbutton' event
proc Main_config_txtxCaseModelDirectory_dialogbutton()
	local lcDir
	if empty(pconfig.cxcasemodeldir)
		lcDir = getdir(,"Select xCase Model Dir")
		if lastkey() # 27
			replace pconfig.cxcasemodeldir with lcDir
		endif
	endif
endproc


////////////////////////////////////////////////////////////////
// Event delegate for 'dialogbutton' event
proc Main_config_txtcxcasemodeldir_dialogbutton()
	lcDir = getdir("","Select xCase Model Dir")
	this.txtcxcasemodeldir.value = lcDir
endproc


////////////////////////////////////////////////////////////////
// Event delegate for 'gotfocus' event
proc Main_config_txtcxcasemodeldir_gotfocus()
	if empty(this.value)
		lcDir = getdir("","Select xCase Model Dir")
		if !empty(lcDir)
			this.value = lcDir
		endif
	endif
endproc


////////////////////////////////////////////////////////////////
// Event delegate for 'beforecreate' event
proc Main_config_beforecreate()
	// insert your code here
endproc


////////////////////////////////////////////////////////////////
// Event delegate for 'datachanged' event
proc Main_config_datachanged()
	// insert your code here
endproc
