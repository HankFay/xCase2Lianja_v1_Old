////////////////////////////////////////////////////////////////
// Event delegate for 'click' event
proc page1_section1_field1_click()
	// insert your code here
	=messagebox("click fired")
	local lcDir
	lcDir = getdir()
	this.value = lcDir
endproc


////////////////////////////////////////////////////////////////
// Event delegate for 'load' event
proc page1_section1_load()
	// insert your code here
	this.addproperty("cDirValue","")
	this.field1.datasource = this.cDirValue
endproc


////////////////////////////////////////////////////////////////
// Event delegate for 'dialogbutton' event
proc page1_section1_field1_dialogbutton()
	// insert your code here
	local lcDir
	lcDir = getdir()
	this.value = lcDir
endproc
