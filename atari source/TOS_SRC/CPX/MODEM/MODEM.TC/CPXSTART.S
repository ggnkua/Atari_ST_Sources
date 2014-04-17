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
		.dc.w	0	; Default Port to start with
				; 0, 1, 2, 3
				
				; Port 0
		.dc.w	0	; BAUD Rate
		.dc.w	0	; Parity
		.dc.w	0	; Bits/Char
		.dc.w	0	; Flow Control
		.dc.w	1	; Stop Bits

				; Port 1
		.dc.w	0
		.dc.w	0
		.dc.w	0
		.dc.w	0
		.dc.w	1

				; Port 2
		.dc.w	0
		.dc.w	0
		.dc.w	0
		.dc.w	0
		.dc.w	1

				; Port 3
		.dc.w	0
		.dc.w	0
		.dc.w	0
		.dc.w	0
		.dc.w	1
		
	.end
