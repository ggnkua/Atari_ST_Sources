; cpxstart.asm
;=============================================================================
; Startup file for CPXs
;
; 'Save_vars' is the area to store your default variables.
; Add more dc.w's as necessary
;
; Assemble with Mad Mac
;
; For Mark Williams - Use  'cpx_init_'
; For Alcyon        - Use  '_cpx_init'
;
;  
;


	.globl	    cpxstart
	.globl	    save_vars
	.globl	    _cpx_init
	
	.text

cpxstart:
   	  jmp _cpx_init

	.data

save_vars:
		.dc.w	0
		.dc.w	0
		.dc.w	0		
	.end
