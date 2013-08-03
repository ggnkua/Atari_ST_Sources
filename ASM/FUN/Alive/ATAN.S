	fmove.x	#0.9567832E100,fp0
	fmove.x	fp0,floatinput
	fatan	fp0
	fmul.l	#((1<<16)*31416)/10000,fp0
	fmove.x	fp0,floatoutput
	fmove.l	fp0,d0

	clr.w	-(sp)
	trap	#1

	BSS

floatinput:
	DS.L	3
floatoutput:
	DS.L	3