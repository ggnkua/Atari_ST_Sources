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

	.text

cpxstart:
   	  jmp cpx_init

	.data

save_vars:
		.dc.w	0			; Left Attenuation
		.dc.w	0			; Right Attenuation
		.dc.w   0			; Left Gain
		.dc.w	0			; Right Gain
	.end
