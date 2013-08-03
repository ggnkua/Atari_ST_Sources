	SECTION	text

showProgramInfo

	displayDialog	#ABOUTBOX,#16395,#.return

; set window title

	rsrc_gaddr	#5,#ABOUTTITLE
	move.l	addrout,intin+4
	move.l	dialogTableAddress,a0
	wind_set	dialogHandle(a0),#2

	rts

; the object that caused the return is in d0
.return

	rts