	SECTION	text

resError

	bra	quitRoutine
;-------------------------------------------------------------
resourceError
	form_alert	#1,#resourceErrorString
	bra	quitRoutine
;-------------------------------------------------------------
cantLoadError

	cmpi.w	#1,d1
	beq	.mem

	rts
.mem
	rsrc_gaddr	#5,#CANTLOADMEM
	form_alert	#1,addrout
	rts
;-------------------------------------------------------------
noMoreWindows

	rts
;-------------------------------------------------------------
	SECTION	data

resourceErrorString	dc.b	'[1][Resouce File not found!][OK]',0