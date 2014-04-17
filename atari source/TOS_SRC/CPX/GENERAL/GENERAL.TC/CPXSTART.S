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
		.dc.w	1	; Keyclick  0 or 1
		.dc.w	1	; Bell      0 or 1
		.dc.w	3	; dclick    0, 1, 2, 3, 4
		.dc.w	2	; keyboard repeat rate
		.dc.w	23	; keyboard response rate
		.dc.w	3	; blitter/ttcache on/off
		.dc.w   1	; TT speaker on/off
		.dc.w   2	; STE Toggle  0 -  8mhz No Cache
				;	      1 -  16mhz no cache
				;	      2 -  16mhz with cache
	.end
