
;********************************************************************
; Input routines, for commands and CPU generated data.
;********************************************************************

;--------------------------------------------------------------------
; Read a palette (16 bit TC entries) over the host port.
;--------------------------------------------------------------------

ReadPalette:

	move	x:COLOURLOOKUP,a
	tst	a
	jeq	_nopalette
	move	#>palette,r0
	do	#256,_lp
	dspread	x0
	move	x0,x:(r0)+
_lp
	nop
_nopalette
	nop
	rts

