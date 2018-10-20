;*****************************************
;** MyLib v0.9 ** by Orion_ [2003-2012] **
;*****************************************

; Define BOOTMODE equ 0/1 if needed (not xbios init)


;***********************
; Useful Equates -
;-----------------

VPTR_HIGH	equ	$FFFF8205
VPTR_MID	equ	$FFFF8207
VPTR_LOW	equ	$FFFF8209
VADRS_HIGH	equ	$FFFF8201
VADRS_MID	equ	$FFFF8203
VADRS_LOW	equ	$FFFF820D
V_PIXEL_OFFSET	equ	$FFFF8265
V_WORD_SKIP	equ	$FFFF820F
V_MODE		equ	$FFFF8260

VECT_HBL	equ	$68
VECT_VBL	equ	$70

VECT_BLITTER	equ	$10C
VECT_TIMERD	equ	$110
VECT_TIMERC	equ	$114
VECT_TIMERB	equ	$120
VECT_TIMERA	equ	$134

MFP_BASE	equ	$FFFFFA00

KEYB1		equ	$FFFFFC00
KEYB		equ	$FFFFFC02

DBUGADRS	equ	$FFFFC123

GEMDOS		equ	1
XBIOS		equ	14
BIOS		equ	13

PALETTE		equ	$FFFF8240
BLUE		equ	$00F
GREEN		equ	$0F0
RED		equ	$F00
PINK		equ	$F0F
YELLOW		equ	$FF0
CIAN		equ	$0FF
WHITE		equ	$FFF
BLACK		equ	$000

B_HALF_RAM	equ	$FFFF8A00
B_SRC_XINC	equ	$FFFF8A20
B_SRC_YINC	equ	$FFFF8A22
B_SRC_ADRS	equ	$FFFF8A24
B_ENDMASK1	equ	$FFFF8A28
B_ENDMASK2	equ	$FFFF8A2A
B_ENDMASK3	equ	$FFFF8A2C
B_DST_XINC	equ	$FFFF8A2E
B_DST_YINC	equ	$FFFF8A30
B_DST_ADRS	equ	$FFFF8A32
B_XCOUNT	equ	$FFFF8A36
B_YCOUNT	equ	$FFFF8A38
B_HALF_OP	equ	$FFFF8A3A
B_OP		equ	$FFFF8A3B
B_CTRL		equ	$FFFF8A3C
B_SKEW		equ	$FFFF8A3D

B_H_DIRECT	equ	0
B_HALFTONE	equ	1
B_H_SRC		equ	2
B_H_SRCANDHALF	equ	3

B_ZERO		equ	0
B_SRC_AND_DST	equ	1
B_SRC_AND_NDST	equ	2
B_SRC		equ	3
B_NSRC_AND_DST	equ	4
B_DST		equ	5
B_SRC_XOR_DST	equ	6
B_SRC_OR_DST	equ	7
B_NSRC_AND_NDST	equ	8
B_NSRC_XOR_DST	equ	9
B_NDST		equ	10
B_SRC_OR_NDST	equ	11
B_NSRC		equ	12
B_NSRC_OR_DST	equ	13
B_NSRC_OR_NDST	equ	14
B_ONE		equ	15

B_EXTRA_SRC	equ	%10000000
B_NOFINAL_SRC	equ	%01000000

B_START		equ	%10000000
B_HOG		equ	%01000000
B_SMUDGE	equ	%00100000

;***********************



;**********************
; Useful Macros -
;----------------

DBUG		macro
	ifeq	BOOTMODE
		move.b	#0,DBUGADRS.w	; stop emulation, debug !
	endc
		endm

DBUG_TAB	macro
	ifeq	BOOTMODE
		cmp.b	#$F,KEYB.w
		bne.s	*+10
		move.b	#0,DBUGADRS.w	; stop emulation, debug !
	endc
		endm

VBLCOLOR_TAB	macro
	ifeq	BOOTMODE
		cmp.b	#$F,KEYB.w
		bne.s	*+8
		move.w	#\1,PALETTE.w
	endc
		endm

VBLCOLOR	macro
	ifeq	BOOTMODE
		move.w	#\1,PALETTE.w
	endc
		endm

PUTPIX_TEST	macro
		movea.l	a1,a2		; Test PutPix: d0=X, d1=Y, a1=screen
		move.w	#$8000,d2	; Param = Plane * 2
		move.w	d0,d3
		andi.w	#15,d3
		lsr.w	d3,d2
		move.w	d1,d3
		lsl.w	#5,d1
		lsl.w	#7,d3
		add.w	d1,d3
		adda.w	d3,a2
		lsr.w	#1,d0
		andi.w	#-8,d0
		adda.w	d0,a2
		or.w	d2,\1(a2)
		endm

IF_NO_SPACEKEY_GOTO	macro
	ifeq	BOOTMODE
			cmp.b	#$39,KEYB.w
			bne	\1
	endc
	if	BOOTMODE
			bra	\1
	endc
			endm

;**********************



	section	text

;********************************

initialise:
	ifeq	BOOTMODE

	move.w	#4,-(a7)		; Get Resolution
	trap	#XBIOS
	addq.l	#2,a7
	move.w	d0,old_resolution

	move.w	#2,-(a7)		; Save Screens Address
	trap	#XBIOS
	addq.l	#2,a7
	move.l	d0,old_screenp		; Physic
	move.w	#3,-(a7)
	trap	#XBIOS
	addq.l	#2,a7
	move.l	d0,old_screenl		; Logic

	moveq	#-1,d0
	move.w	#0,-(a7)		; Low Resolution
	move.l	d0,-(a7)
	move.l	d0,-(a7)
	move.w	#5,-(a7)
	trap	#XBIOS
	add.l	#12,a7

	clr.l	-(a7)			; Supervisor Mode
	move.w	#$20,-(a7)
	trap	#GEMDOS
	addq.l	#6,a7
	move.l	d0,old_stack

	bsr	flush

	lea	Save_reg+32,a0		; Hardware Register Save

	movem.l	PALETTE.w,d0-d7	; Save Palette
	movem.l	d0-d7,-32(a0)

	move.l	VECT_HBL.w,(a0)+		; Timers / VBL Save
	move.l	VECT_VBL.w,(a0)+
	move.l	VECT_TIMERC.w,(a0)+
	move.l	VECT_TIMERB.w,(a0)+
	move.l	VECT_TIMERA.w,(a0)+

	lea	MFP_BASE.w,a1		; Save Mfp
	move.b	$07(a1),(a0)+
	move.b	$09(a1),(a0)+
	move.b	$13(a1),(a0)+
	move.b	$15(a1),(a0)+
	move.b	$17(a1),(a0)+
	move.b	$19(a1),(a0)+
	move.b	$1b(a1),(a0)+

	moveq	#0,d0			; Clear Interupts (disable VBL disturb)
	movep.w	d0,$07(a1)
	movep.w	d0,$13(a1)
	movep.w	d0,$19(a1)

	bclr	#3,$17(a1)		; Attention: Automatic End-interrupt mode (default a 1, donc software !)

	endc

;********************************
; Double Buffering Init

dbufinit:
	move.l	#screen1,d0
	clr.b	d0		; Put on 256 byte boundary	
	move.l	d0,next
	add.l	#32000,d0	; Next screen area
	move.l	d0,last

	bra	whatsnext

;********************************


;********************************

exit:
	ifeq	BOOTMODE

	lea	Save_reg,a0		; Hardware Register Save

	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,PALETTE.w	; Restore Palette

	bsr	flush

	move.l	(a0)+,VECT_HBL.w		; Timers / VBL Restore
	move.l	(a0)+,VECT_VBL.w
	move.l	(a0)+,VECT_TIMERC.w
	move.l	(a0)+,VECT_TIMERB.w
	move.l	(a0)+,VECT_TIMERA.w

	lea	MFP_BASE.w,a1		; Restore Mfp
	move.b	(a0)+,$07(a1)
	move.b	(a0)+,$09(a1)
	move.b	(a0)+,$13(a1)
	move.b	(a0)+,$15(a1)
	move.b	(a0)+,$17(a1)
	move.b	(a0)+,$19(a1)
	move.b	(a0)+,$1b(a1)

	move.l	old_stack,-(a7)		; User Mode
	move.w	#$20,-(a7)
	trap	#GEMDOS
	addq.l	#6,a7

	move.w	old_resolution,-(a7)	; Restore resolution and screen
	move.l	old_screenp,-(a7)
	move.l	old_screenl,-(a7)
	move.w	#5,-(a7)
	trap	#XBIOS
	lea	12(a7),a7

	clr.l	-(a7)			; Exit
	trap	#1

	endc

	if	BOOTMODE
	rts
	endc

;********************************


;********************************
; Flush Keyboard

	ifeq	BOOTMODE
flush:
	btst.b	#0,KEYB1.w		; Flush Keyboard
	beq.s	.flok
	move.b	KEYB.w,d0
	bra.s	flush
.flok:	rts

	endc

;********************************


;********************************
; Flip the next screen

flip:
	move.l	last,d1		; Exchange Screens
	move.l	next,d0
	move.l	d0,last
	move.l	d1,next
	clr.b	VADRS_LOW.w
	lsr.l	#8,d0		
	move.b	d0,VADRS_MID.w
	lsr.w	#8,d0
	move.b	d0,VADRS_HIGH.w
	rts

;********************************

SetScreenSTe:	; d0 = address
	move.w	d0,d1		; Active on Next VBL
	lsr.w	#8,d1
	swap	d0
	move.b	d0,VADRS_HIGH.w
	move.b	d1,VADRS_MID.w
	swap	d0
	move.b	d0,VADRS_LOW.w	; LAST !
	rts

SetScreenSTeNOW:	; d0 = address
	move.w	d0,d1		; Active NOW !
	lsr.w	#8,d1
	swap	d0
	move.b	d0,VPTR_HIGH.w
	move.b	d1,VPTR_MID.w
	swap	d0
	move.b	d0,VPTR_LOW.w	; LAST !
	rts

;********************************

	section data

	even

	ifeq	BOOTMODE

old_stack:	dc.l	0
old_screenp:	dc.l	0
old_screenl:	dc.l	0

	endc

last:		dc.l	0
next:		dc.l	0

	ifeq	BOOTMODE
old_resolution:	dc.w	0
	endc

;********************************

	section bss

	even

	ifeq	BOOTMODE
Save_reg:	ds.l	15
	endc

	even
		ds.b	256
screen1:	ds.b	32000
screen2:	ds.b	32000
		ds.b	256

;********************************

	section	text

whatsnext:
