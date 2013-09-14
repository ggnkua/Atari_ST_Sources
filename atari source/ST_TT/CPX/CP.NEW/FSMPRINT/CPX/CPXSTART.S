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
	.even
save_vars:
		.dc.w	0
		.dc.w	0
		.dc.w	0
		
mystuff:	.dc.b	"FSMPRINT CPX by CJG ",0
		.dc.b	"Copyright (c) 1991 Atari Corporation ",0
	.end
