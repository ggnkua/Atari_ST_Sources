; @(#)slbload/interfac.s
; Julian F. Reschke, 1998-07-05
;
; Startup-Modul und Assembly-Layer fÅr SLB-Treiber 
	
	.globl	function_table
	.globl	ShowBanner
	.globl	act_pd_p
	.globl	slbexec
	.globl	startoftext;
	
	.text

; MetaDOS calls our init function with the following parameter:
;
; long startoftext (BASPAG **act_pd_p);
;
; act_pd_p is the pointer to the GEMDOS internal variable which
; holds the pointer to the currently executing process.
;
; The init function returns a pointer to the SLB function table,
; which contains pointers to the Slopen() and Slbclose() functions,
; which are GEMDOS 0x16 and 0x17.
	
startoftext:
	move.l	4(sp), act_pd_p
	bsr		ShowBanner
	move.l	#function_table,d0
	rts
	

; Shared Lib execution function. A pointer to this function is
; returned upon Slbopen() to the caller. It provides the hook
; to call the functions in the shared library.
;
; long slbexec (BASPAG *shared_lib, long function_number, ...)
;
; shared_lib points to the basepage of the shared library.
;
; function_number is the library function number. If it exceeds
; the maximum value or the function pointer is NULL, slbexec
; returns EINVFN.
;
; Otherwise the function is called and the D0 return value is
; forwarded to the caller.

slbexec:
	move.l	4(sp), a0		; Basepage of shared lib
	move.l	8(a0), a0		; Start of text segment
	
	move.l	8(sp), d0		; Function number
	cmp.l	4*17(a0), d0	; Max. function number
	bcc.s	.einvfn
	
	add.l	d0, d0			; *= sizeof (long)
	add.l	d0, d0
	move.l	4*18(a0,d0), d0	; Function pointer
	beq.s	.einvfn

	move.l	act_pd_p, a0	
	move.l	0(a0), 4(sp)	; act_pd onto stack, replacing sl pointer

	move.l	d0, a0
	jmp		(a0)

.einvfn:
	move.l	#-32, d0
	rts


	.bss
	
act_pd_p:		ds.l	1
