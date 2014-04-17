; cpxstart.asm
;=============================================================================
; Startup file for COLOR.CPX
;



; Globals
	xdef	    cpxstart
	xdef	    _saved
	
; Externs
	xref	    _cpx_init
	
	text

cpxstart:
   	  jmp _cpx_init

	data


_saved: dc.w  100	; Display delay (ms )
	dc.w  10000	; Drag Delay
	dc.w  250	; Response Delay
	dc.w  0		; Scroll delay
	dc.w  16	; Menu Height ( scrolling )
	end
