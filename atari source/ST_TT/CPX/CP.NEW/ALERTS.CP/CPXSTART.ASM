; cpxstart.asm
;=============================================================================
; Startup file for CPXs
; Date: February 27, 1990
;
; format for mad mac:   mac cpxstart.asm
;
; The storage space for your variables is currently set to 10 words
; If you need more, well, change it.
; If your not using mad mac, then you can always type in
;   .dc.w 0 as many times as you need it...:-)
;


	.globl	    cpxstart
	.globl	    save_vars
	.globl	    cpx_init

	BLOCKS =    10
	
	.text

cpxstart:
   	  jmp cpx_init

	.data

save_vars:
		.rept	BLOCKS
		.dc.w	0
		.endr
		
	.end
