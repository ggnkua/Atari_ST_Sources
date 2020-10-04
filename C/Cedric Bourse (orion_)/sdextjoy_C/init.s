	section	text

	public	_main

_start:
	move.l	4(a7),a0	; basepage address
	move.l	24(a0),a1	; bss ptr
	adda.l	28(a0),a1	; bss size
;	adda.l	#2048,a1	; internal stack size
;	move.l	a1,a7		; setup our internal stack
	suba.l	a0,a1		; global size of our program

	move.l	a1,_GlobalProgramSize	; for later Ptermres

	bra.s	_main

;	move.l	a1,-(a7)	; program size
;	move.l	a0,-(a7)	; start ptr
;	clr.w	-(a7)
;	move.w	#$4A,-(a7)	; Mshrink
;	trap	#1
;	lea	12(a7),a7

;****************************************#

	public	_LE_2_BE_W
	public	_LE_2_BE_L

_LE_2_BE_W:
	move.b	1(a0),d0
	lsl.w	#8,d0		; Convert to Big Endian
	move.b	(a0),d0
	rts

_LE_2_BE_L:
	addq.l	#4,a0
	move.b	-(a0),d0
	lsl.w	#8,d0		; Convert to Big Endian
	move.b	-(a0),d0
	swap	d0
	move.b	-(a0),d0
	lsl.w	#8,d0
	move.b	-(a0),d0
	rts

;****************************************#

	section	bss

	public	_GlobalProgramSize

_GlobalProgramSize:
	ds.l	1
