; cpxstart.asm
;=============================================================================
; Startup file for CPXs
;
; 'Save_vars' is the area to store your default variables.
; Add more dc.w's as necessary
;


	.globl	    cpxstart
	.globl	    save_vars
	.globl	    cpx_init
	
	.text

cpxstart:
   	  jmp cpx_init

	.data

save_vars:
		.dc.w	0
		.dc.w	0
		.dc.w	0		
	.end
