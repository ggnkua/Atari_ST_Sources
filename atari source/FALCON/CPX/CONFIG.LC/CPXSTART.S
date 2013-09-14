; cpxstart.asm
;=============================================================================
; Startup file for COLOR.CPX
;



; Globals
	xdef	    cpxstart
	
; Externs
	xref	    _cpx_init
	
	text

cpxstart:
   	  jmp _cpx_init
	end
