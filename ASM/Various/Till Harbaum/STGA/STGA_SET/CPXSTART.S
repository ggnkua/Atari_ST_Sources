; cpxstart.s
; ==========
; Startup-Datei fr CPX-Module
;
	.globl	cpxstart
	.globl	save_vars
	.globl	cpx_init

cpxstart:
	jmp		cpx_init
	
	.data
save_vars:
	.dc.w	0
	.end