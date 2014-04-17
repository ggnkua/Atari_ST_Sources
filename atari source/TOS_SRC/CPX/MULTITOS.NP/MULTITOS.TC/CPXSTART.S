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
		.dc.w	0	; Dot Matrix - 0, Daisy  - 1
		.dc.w	0	; B/W        - 0, Color  - 1
		.dc.w	0	; 1280       - 0, Epson  - 1
		.dc.w	0	; Draft      - 0, Final  - 1
		.dc.w	0	; Feed       - 0, Single - 1
		.dc.w	0	; Parallel   - 0, Serial - 1
	.end
