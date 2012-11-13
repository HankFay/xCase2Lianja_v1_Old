define class myobj as custom
	
	procedure this_access
		lparameters tcMembername
		messagebox(tcMemberName)
		return tcMemberName
	endproc
	
	procedure init
		messagebox("init")
	endproc
	
enddefine