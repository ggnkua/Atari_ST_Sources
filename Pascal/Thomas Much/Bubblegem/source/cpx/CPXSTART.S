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
	.globl		  bg_fontchg
	.globl		  bg_nowinstyle
	.globl		  bg_sendkey
	.globl      bg_demonactive
	.globl      bg_toponly
	.globl      bg_opentime
	.globl      bg_closetime
	.globl	    cpx_init
	
	.text

cpxstart:
   	  jmp cpx_init

	.data
save_vars:
bg_fontchg:      .dc.w 0
bg_nowinstyle:   .dc.w 1
bg_sendkey:      .dc.w 1
bg_demonactive:  .dc.w 1
bg_toponly:      .dc.w 0
bg_opentime:     .dc.w 300
bg_closetime:    .dc.w 200

	.end
