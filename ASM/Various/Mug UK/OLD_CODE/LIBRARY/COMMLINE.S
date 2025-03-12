;
; Command Line Program (.TTP)
;
; Author: Michael Davidson (from ST World)
;

	move.l	a7,a5		; put stack pointer in a5
	move.l	4(a7),a5		; a5 = address of basepage
	move.l	a5,basepage	; save this address
	move.l	#stack,a7		; a7 = internal program stack
	move.l	12(a5),d0		; d0 = length of TEXT segment
	add.l	20(a5),d0		; add length of DATA segment
	add.l	28(a5),d0		; add length of BSS segment
	move.l	d0,-(a7)		; memory required by program
	move.l	a5,-(a7)		; start address of basepage
	clr.w	-(a7)		; dummy
	move.w	#$4a,-(a7)	; GEMDOS 'mshrink'
	trap	#1		; release memory not required
	lea	12(a7),a7		; correct stack
	tst.l	d0		; Errors ???
	bne.s	exit		; exit if there was an error

* Your program should replace the following sections

	move.l	basepage,a0	; get address of basepage
	add.l	#128,a0		; point to start of command line
	tst.b	(a0)		; is it empty ??
	beq	noval		; if yes - print message
	addq.l	#1,a0		; point to start of string
	move.l	a0,-(a7)		; address of string
	move.w	#$09,-(a7)	; GEMDOS 'Cconws'
	trap	#1		; print string
	addq.l	#6,a7		; correct stack
	bra	exit		; and leave

noval	move.l	#novalw,-(a7)	; address of error message
	move.w	#$09,-(a7)	; GEMDOS 'Cconws'
	trap	#1		; print string
	addq.l	#6,a7		; correct stack
	
exit	move.l	#extmag,-(a7)	; address of exit message
	move.w	#$09,-(a7)	; GEMDOS 'Cconws'
	trap	#1		; print string
	addq.l	#6,a7		; correct stack
	
	move.w	#7,-(a7)		; GEMDOS 'Crawcin'
	trap	#1		; wait for key
	addq.l	#2,a7		; correct stack

	clr.w	-(a7)		; GEMDOS 'Pterm0'
	trap	#1		; exit program

novalw	dc.b	"No paramters entered !!",0
extmag	dc.b	13,10,13,10,"Press any key to exit",0
	even

basepage	ds.l	1		; save address of basepage
	ds.w	500		; increase this, if your program
stack	ds.w	1		; needs a larger stack

