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
	.globl	    gdos_tst

        .EXPORT errno
        .EXPORT _AtExitVec, _FilSysVec

	.text

cpxstart:
   	  jmp cpx_init
	  rts
	  
gdos_tst: move.w #-2, d0
	  trap #2
	  rts

	.data
	.even

save_vars:
		.dc.w	1	; temp?
		
mystuff:	.dc.b	"Font Scaling Module CPX by CJG ",0
		.dc.b	"Copyright (c) 1991 Atari Corporation ",0
		

__data:
	.even
* Global error variable

errno:
        .DC.W   0


* Vector for atexit

_AtExitVec:
        .DC.L   0


* Vector for file system deinitialization

_FilSysVec:
        .DC.L   0

	.end
