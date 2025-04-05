ATARI

************************
* CONDITIONAL ASSEMBLY *
************************

;TOPHALF
FASTMODE
KEYBOARD
;MUSICOFF
;NO_TEXT
TESTOSC

****************
* MISC EQUATES *
****************

LAD		equ		160
BLITMODE	equ		192
COLOUR	equ		$FF8240
LINEWID	equ		$FF820F
PHYS_LOW	equ		$FF820D
PHYS_MED	equ		$FF8201
PHYS_TOP	equ		$FF8203

PLAY		equ		$FF8900
DMA_STR	equ		$FF8902
DMA_END	equ		$FF890E
TRACE		equ		$FF8908
MODE		equ		$FF8920
LOOP		equ		3
STAB		equ		1
REPEAT	equ		-1

TRAX_1	equ		0
TRAX_2	equ		1
TRAX_3	equ		2
TRAX_4	equ		3
TRAX_5	equ		4
TRAX_6	equ		5
TRAX_7	equ		6
TRAX_8	equ		7
TRAX_9	equ		8
TRAX_10	equ		9
TRAX_11	equ		10
TRAX_12	equ		11
TRAX_13	equ		12
TRAX_14	equ		13
TRAX_15	equ		14
TRAX_16	equ		15

beat		equ		194

*************************************************************************
*			   ST BLITTER HARDWARE REGISTERS				*
*************************************************************************

BLIT		equ	$FF8A00
halftone	equ	BLIT+00	16*16 pattern mask
src_xinc	equ	BLIT+32	increment of next source word (-128 -> +127)
src_yinc	equ	BLIT+34	increment of next source line (-128 -> +127)
src_addr	equ	BLIT+36	source data address
endmask1	equ	BLIT+40	mask for first word in line (or only word)
endmask2	equ	BLIT+42	mask for middle words in line
endmask3	equ	BLIT+44	mask for last word in line
dst_xinc	equ	BLIT+46	increment of next dest. word (-128 -> +127)
dst_yinc	equ	BLIT+48	increment of next dest. line (-128 -> +127)
dst_addr	equ	BLIT+50	destination screen address
x_size	equ	BLIT+54	x-size	(number of words to go)
y_size	equ	BLIT+56	y_size	(number of lines to go)
HOP		equ	BLIT+58	halftone operation...
;					0...	1
;					1...	halftone
;					2...	source
;					3...	halftone & source
blit_op	equ	BLIT+59	logic operations
;					0...	0		  8...  NOT s AND NOT d
;					1...	s AND d	  9...  NOT s XOR d
;					2...	s AND NOT d	  10..  NOT d
;					3...	s		  11..  s OR NOT d
;					4...	NOT s AND d	  12..  NOT s
;					5...	d		  13..  NOT s OR d
;					6...	s XOR d	  14..  NOT s OR NOT d
;					7...	s OR d	  15..  1
blit_stat	equ	BLIT+60	blitter chip status registers
;					bit 0-3	halftone line number
;					bit 5		smudge
;					bit 6		HOG	1-nasty,0-nice
;					bit 7		BUSY	1-busy,0-idle
skew		equ	BLIT+61	offset bit shift
;					bit 0-3	pixel offset
;					bit 6		NFSR	1-no final src read,0-norm
;					bit 7		FXSR	1-force extra read,0-norm

********************
* MISC USER MACROS *
********************

push	macro						; stack macros
	move.\0	\1,-(sp)
	endm
pop	macro
	move.\0	(sp)+,\1
	endm
pushall		macro
	movem.l	d0-d7/a0-a6,-(sp)
	endm
popall		macro
	movem.l	(sp)+,d0-d7/a0-a6
	endm

supervisor		macro				; 68000 modes
	clr.l		-(sp)
	move.w	#32,-(sp)
	trap		#1
	addq		#6,sp
	move.l	d0,OLD_STK
	endm
user	macro
	move.l	OLD_STK,-(sp)
	move.w	#32,-(sp)
	trap		#1
	addq		#6,sp
	endm

delay	macro						; vbi delay macro
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#\1,d3
	bsr		VBI
	movem.l	(sp)+,d0-d7/a0-a6
	endm

hidemouse		macro				; mouse macros
	dc.w		$A00A
	endm
showmouse		macro
	dc.w		$A009
	endm

setup	macro						; environment control
	supervisor
	bsr		SETUP
	endm
terminate		macro
	bra		EXIT
	endm

unpack		macro				; unpack pc1 screen to LOG
	lea		\1,a0
	bsr		MAKE_SCR
	bsr		SET_COL
	move.l	LOG_SCR,a5
	lea		BUFFER_2,a6
	bsr		COPY_SCR
	move.l	LOG_SCR,a5
	move.l	PHYS_SCR,a6
	bsr		COPY_SCR
	endm

sound	macro						; play sample (DMA)
	IFNE		NARG
	move.w	#\1,d0
	move.w	#\2,SPEED
	move.w	#\3,STAT
	bsr		DMA_SAMPLE
	ELSEIF
	clr.w		PLAY
	ENDC
	endm

initblit		macro				; set up the blitter
	move.b	#2,HOP
	clr.w		src_xinc
	clr.w		src_yinc
	move.w	#8,dst_xinc
	move.w	#160-8,dst_yinc
	move.w	#2,x_size
	clr.b		skew
	moveq		#-1,d0
	move.l	d0,endmask1
	move.w	d0,endmask3
	endm

blitmask		macro
	move.l	a4,src_addr
	move.l	a3,dst_addr
	move.w	d5,y_size
	move.b	d3,blit_stat
	IFNE		NARG
	addq.l	#\1,a3
	ENDC
	endm	
	
blitprint		macro
	move.l	a5,src_addr
	move.l	a6,dst_addr
	move.w	d5,y_size
	move.b	d3,blit_stat
	IFNE		NARG
	addq.l	#\1,a5
	addq.l	#\1,a6
	ENDC
	endm

**************************************************************

HYPERBLIT:
	setup
	initblit

	IFND		KEYBOARD
	move.l	$456,a0
	moveq		#8-1,d0
.i	clr.l		(a0)+
	dbra		d0,.i
	bsr		DISABLE_INTERRUPTS
	ENDC

	
	IFND		MUSICOFF
	unpack	PIC2
	bsr		FILES
	unpack	PIC1
	move.l	$456,a0			; move music routine
	move.l	a0,VBI_PTR			; onto the VBI.
.lp	tst.l		(a0)+				; it will now act as a
	bne.s		.lp				; music module running at
	move.l	#MUSIC,-(a0)		; 50Hz.
	move.l	a0,MUSIC_PTR
	ENDC
	
	IFND		FASTMODE
	bsr		START_RASTERS		; start HBI colour changing
	ENDC

	move.l	#TEXT,TEXT_POS
MAIN:	clr.l		d0
	clr.l		d4
	lea		TRACE,a1
	move.l	LOG_SCR,a2
	move.w	#320-1,d0	
.o	move.l	d0,d2
	move.l	d0,d3
	move.b	1(a1),REG+1
	move.b	3(a1),REG+2
	move.b	5(a1),REG+3
	move.l	REG,a0
	move.b	(a0),d4
	asr.b		d4
	add.b		#80,d4
	and.w		#$FFF0,d2
	lsr.w		d2
	and.w		#$FF,d4
	mulu		#160,d4
	add.l		d4,d2
	lea		(a2,d2.w),a0
	move.w	#%1000000000000000,d2
	and.w		#$0F,d3
	lsr.w		d3,d2
	or.w		d2,(a0)+
	not.w		d2
	and.w		d2,(a0)+
	and.w		d2,(a0)+
	and.w		d2,(a0)
	dbra		d0,.o

	IFND		NO_TEXT

.PRINT_TEXT					; scrolly font by blitter
	move.l	LOG_SCR,a6
	lea		183*LAD(a6),a6
	tst.b		SC_FLG
	bgt.s		.s1
	move.b	#16,SC_FLG
	addq.l	#1,TEXT_POS
.s1	subq.b	#4,SC_FLG		; 4-pixel scrolling (1-16 poss.)
	move.b	SC_FLG,d4
	move.b	d4,skew

	moveq.w	#-1,d5
	lsr.w		d4,d5
	move.w	d5,endmask1		; mask start and end words
	not.w		d5			; (needed for scrolly bit)
	move.w	d5,endmask3

	clr.w		src_xinc
	move.w	#8,dst_xinc
	move.w	#4,src_yinc
	move.w	#160-8,dst_yinc
	move.b	#7,blit_op
	move.b	#BLITMODE,d3
.tp	move.l	TEXT_POS,a0		; current text position
	moveq		#19-1,d7		; number of characters to print
.lp	moveq		#0,d1
	move.b	(a0)+,d1
	tst.b		d1
	bne.s		.ct
.rs	move.l	#TEXT,TEXT_POS
	bra.s		.tp
.ct	sub.w		#32,d1
	tst.w		d1
	ble		.sp
	lea		FONT,a1
	lsl.w		#6,d1
	add.l		d1,a1
	moveq		#19-1,d6		; print from left to right
	sub.w		d7,d6
	lsl.w		#3,d6
	lea		(a6,d6.l),a2

.rt	tst.w		d7
	bne.s		.lt
	clr.w		endmask3
	moveq.w	#-1,d5
	lsr.w		d4,d5
	move.w	d5,endmask1
	bra.s		.pr

.lt	cmpi.w	#18,d7
	bne.s		.md
	clr.w		endmask1
	moveq.w	#-1,d5
	lsr.w		d4,d5
	not.w		d5
	move.w	d5,endmask3
	bra.s		.pr
	
.md	moveq.w	#-1,d5
	lsr.w		d4,d5
	move.w	d5,endmask1		; mask start and end words
	not.w		d5			; (needed for scrolly bit)
	move.w	d5,endmask3

.pr	move.l	a1,src_addr
	move.l	a2,dst_addr
	move.w	#2,x_size
	move.w	#16,y_size
	move.b	d3,blit_stat
	addq.l	#2,a1
	addq.l	#2,a2
	move.l	a1,src_addr
	move.l	a2,dst_addr
	move.w	#2,x_size
	move.w	#16,y_size
	move.b	d3,blit_stat
.sp	dbra		d7,.lp
	ENDC

.SWAP	move.l	LOG_SCR,d7			; swap screens over
	move.l	PHYS_SCR,LOG_SCR		; in one go.
	move.l	d7,PHYS_SCR			;
	move.b	PHYS_SCR,$FF820D		; low-byte (ste only)
	move.b	PHYS_SCR+1,$FF8201	; med-byte
	move.b	PHYS_SCR+2,$FF8203	; hi-byte
	move.w	#37,-(sp)			; 1 vbi
	trap		#14
	addq.l	#2,sp
	bsr		CLS_REDRAW
	IFD		KEYBOARD
	bsr		END_KEY			; test for a keypress
	ENDC						; if so, then end it all.
	bra		MAIN


MUSIC:addq		#1,VBI_COUNT		; sounds held in
	move.w	VBI_COUNT,d0		; 'SCORE'
	cmp.w		BLIPS,d0			; has time for current sample
	bge.s		.newsound			; run out?
	rts						; if so do next one...
.newsound
	clr.w		VBI_COUNT
.rs	lea		SCORE,a0
	move.w	FRAME,d0
	addq		#1,FRAME
	lsl.w		#2,d0
	ext.l		d0
	add.l		d0,a0				; find next sample
	move.w	(a0)+,d0			; is it a repeat?
	cmp.w		#-1,d0			; if not,continue
	bne.s		.ok				; if so,restart.
	clr.w		FRAME
	bra.s		.rs
.ok	move.w	(a0),BLIPS			; get length (vbi's)
	bsr		NEW_TRACK			; give DMA address of new
	rts						; sound so it can restart
							; when current one is ended.

DMA_SAMPLE:					; dedicated sample player (dma only)
	lea		SOUNDS,a0		; this loads all neccessary inputs
	lsl.w		#2,d0			; and (re)triggers the DMA
	move.l	0(a0,d0.w),SSTR
	move.l	4(a0,d0.w),SEND
	move.b	SSTR+3,DMA_STR+5
	move.b	SSTR+2,DMA_STR+3
	move.b	SSTR+1,DMA_STR+1
	move.b	SEND+3,DMA_END+5
	move.b	SEND+2,DMA_END+3
	move.b	SEND+1,DMA_END+1
	move.w	SPEED,d0	
	bset		#7,d0
	clr.w		PLAY
	move.w	d0,MODE
	move.w	STAT,PLAY
	rts

NEW_TRACK:					; loads address of next sample
	clr.w		PLAY			*****
	lea		SOUNDS,a0		; this routine does NOT retrigger
	lsl.w		#2,d0			; the DMA like the one above,
	move.l	0(a0,d0.w),SSTR	; but simply tells the DMA
	move.l	4(a0,d0.w),SEND	; what to play when it's finished
	move.b	SSTR+3,DMA_STR+5	; the one it is currently doing.
	move.b	SSTR+2,DMA_STR+3
	move.b	SSTR+1,DMA_STR+1
	move.b	SEND+3,DMA_END+5
	move.b	SEND+2,DMA_END+3
	move.b	SEND+1,DMA_END+1
	move.w	#1,d0				; speed
	bset		#7,d0
	move.w	d0,MODE
	move.w	#3,PLAY			; LOOP
	rts

	IFND		KEYBOARD
DISABLE_INTERRUPTS:				; switch off all MFP interrupts.
	move.w	#1,-(sp)			; (they cause a lot of hassle
	move.w	#26,-(sp)			; with the rasters!)
	trap		#14
	addq		#4,sp
	move.w	#2,-(sp)
	move.w	#26,-(sp)
	trap		#14
	addq		#4,sp
	move.w	#3,-(sp)
	move.w	#26,-(sp)
	trap		#14
	addq		#4,sp
	move.w	#4,-(sp)
	move.w	#26,-(sp)
	trap		#14
	addq		#4,sp
	move.w	#5,-(sp)
	move.w	#26,-(sp)
	trap		#14
	addq		#4,sp
	move.w	#6,-(sp)
	move.w	#26,-(sp)
	trap		#14
	addq		#4,sp
	move.w	#7,-(sp)
	move.w	#26,-(sp)
	trap		#14
	addq		#4,sp
	rts
	ENDC
		
CLS_BLIT:
	move.l	LOG_SCR,dst_addr	; embarrassingly simple-to-do
	move.w	#2,dst_xinc		; CLS with the blitter that
	move.w	#200*80,x_size	; is even faster than that one
	move.w	#1,y_size		; up above...
	clr.b		blit_op
	move.b	#BLITMODE,blit_stat	; blitternasty , do it!
	rts

CLS_REDRAW:
	moveq		#-1,d0
	move.l	d0,endmask1
	move.w	d0,endmask3
	move.l	#BUFFER_2+LAD*16,src_addr
	move.l	LOG_SCR,a0
	lea		LAD*16(a0),a0
	move.l	a0,dst_addr
	move.w	#2,dst_xinc
	move.w	#2,src_xinc
	move.w	#128*80,x_size
	move.w	#1,y_size
	move.b	#3,blit_op
	clr.b		skew
	move.b	#BLITMODE,blit_stat
	
	move.l	LOG_SCR,a0
	lea		LAD*183(a0),a0
	move.l	a0,dst_addr
	move.w	#16*80,x_size	; is even faster than that one
	move.w	#1,y_size		; up above...
	clr.b		blit_op
	move.b	#BLITMODE,blit_stat	; blitternasty , do it!
	rts

CLS:	pushall
	move.l	LOG_SCR,a0			; fast CLS routine!
	lea		32000-(160*24)(a0),a0	; miss out first 24 lines
	moveq.l	#0,d1				; this is used in preference
	moveq.l	#0,d2				; to the faster blitter job
	moveq.l	#0,d3				; below,because the rasters
	moveq.l	#0,d4				; are unable to interrupt
	moveq.l	#0,d5				; the blitter on blitternasty.
	moveq.l	#0,d6				; so,when using rasters,
	moveq.l	#0,d7				; keep blitter use low. 
	sub.l		a1,a1				; using blitternice means
	sub.l		a2,a2				; the job may not be finished
	sub.l		a3,a3				; before the next screen swap!
	moveq		#100-12-1,d0		; clear TOP bit (-24 lines)	
.cls	movem.l	d1-d7/a1-a3,-(a0)	
	movem.l	d1-d7/a1-a3,-(a0)
	movem.l	d1-d7/a1-a3,-(a0)
	movem.l	d1-d7/a1-a3,-(a0)
	movem.l	d1-d7/a1-a3,-(a0)
	movem.l	d1-d7/a1-a3,-(a0)
	movem.l	d1-d7/a1-a3,-(a0)
	movem.l	d1-d7/a1-a3,-(a0)
	dbra		d0,.cls
	popall
	rts
	
CHR_FADEIN:					; fade in log screen with
	pushall				; weird patterns
	move.l	LOG_SCR,a3
	move.l	PHYS_SCR,a4
	moveq		#9-1,d0
.frlp	lea		MASKIN,a2
	move.w	d0,d1
	lsl.w		#2,d1
	move.l	(a2,d1.w),a6
	bsr.s		CHR_DRAW
	delay		2
	dbra		d0,.frlp
	popall
	rts

CHR_FADEOUT:				; fade out phys screen in same way
	pushall
	move.l	PHYS_SCR,a3
	move.l	a3,a4
	moveq		#9-1,d0
.frlp	lea		MASKOUT,a2
	move.w	d0,d1
	lsl.w		#2,d1
	move.l	(a2,d1.w),a6
	bsr.s		CHR_DRAW
	delay		2
	dbra		d0,.frlp
	popall
	rts

CHR_DRAW:
	move.l	a3,a1			;set current position in log screen
	move.l	a4,a2			;set current position in phys screen
	moveq		#25-1,d3		;set 25-deep loop (y-loop)
.alld	moveq		#8-1,d4		;set 8-deep mask loop (y loop)
.bard	move.l	a6,a0			;get current character address
	move.b	(a0,d4.w),d1	;move mask byte into d1
	moveq		#0,d6			;clear d6
	move.b	d1,d6			;copy mask into d0
	lsl.w		#8,d6			;
	move.b	d1,d6			;merge upper byte with lower
	move.w	d6,d7			;
	swap		d7			;access other half of d7
	move.w	d6,d7			;each byte in d7 now has same value
	moveq		#10-1,d5		;set x-loop (10*32 pixels)

.scld	move.l	(a1)+,d1
	and.l		d7,d1
	move.l	d1,(a2)+

	move.l	(a1)+,d1
	and.l		d7,d1
	move.l	d1,(a2)+

	move.l	(a1)+,d1
	and.l		d7,d1
	move.l	d1,(a2)+

	move.l	(a1)+,d1
	and.l		d7,d1
	move.l	d1,(a2)+

	dbra		d5,.scld
	dbra		d4,.bard		;next character in column
	dbra		d3,.alld		;next row of 40 characters
	rts

START_RASTERS:
	tst.b		HBI_ON_FLAG
	bne.s		.rts
	st		HBI_ON_FLAG
	move.l	$120,HBI_STORE
	move.l	$70,VERJUM+2
	lea		MFP_STORE,a0
	move.b	$FFFA21,(a0)+		MFP timer B data
	move.b	$FFFA09,(a0)+		MFP interrupt enable B
	and.b		#$DF,$FFFA09
	move.b	$FFFA07,(a0)+		MFP interrupt enable A
	or.b		#1,$FFFA07
	move.b	$FFFA13,(a0)+		MFP interrupt mask A
	or.b		#1,$FFFA13
	move.l	#HBI_ROUTINE_2,$120
	move.l	#HBI_START_0,$70
.rts	rts

STOP_RASTERS:
	tst.b		HBI_ON_FLAG
	beq.s		.rts
	st		HBI_ON_FLAG
	move.l	VERJUM+2,$70
	move.l	HBI_STORE,$120
	lea		MFP_STORE,a0
	move.b	(a0)+,$fffA21
	move.b	(a0)+,$fffA09
	move.b	(a0)+,$fffA07
	move.b	(a0)+,$fffA13
.rts	rts

*************************************************************************
*				RASTER INTERRUPT ROUTINES				*
*************************************************************************

HBI_START_0:
	move.w	#$2700,SR
	move.l	#$08120350,COLOUR+0
	move.l	#$04610572,COLOUR+4
	move.w	#$333,COLOUR+8
	move.w	#$555,COLOUR+16
	move.w	#$777,COLOUR+24
	clr.b		$FFFA1B			MFP timer B control
	move.b	#155,$FFFA21		MFP timer B data
	move.b	#8,$FFFA1B			MFP timer B control
	move.l	#HBI_ROUTINE_1,$120
	move.w	#$2300,SR
VERJUM:
	jmp		0

HBI_ROUTINE_1:
	move.w	#$002,$ff8240
	clr.b		$FFFA1B			MFP timer B control
	move.b	#5,$FFFA21			timer B data
	move.b	#8,$FFFA1B
	clr.b		$fffa1f			timer A data
	clr.b		$fffa0f			interupt in service A
	move.l	#HBI_ROUTINE_2,$120
	rte
HBI_ROUTINE_2:
	move.w	#$00A,$ff8240
	clr.b		$FFFA1B			MFP timer B control
	move.b	#5,$FFFA21			timer B data
	move.b	#8,$FFFA1B
	clr.b		$fffa1f			timer A data
	clr.b		$fffa0f			interupt in service A
	move.l	#HBI_ROUTINE_3,$120
	rte
HBI_ROUTINE_3:
	move.w	#$003,$ff8240
	clr.b		$FFFA1B			MFP timer B control
	move.b	#5,$FFFA21			timer B data
	move.b	#8,$FFFA1B
	clr.b		$fffa1f			timer A data
	clr.b		$fffa0f			interupt in service A
	move.l	#HBI_ROUTINE_4,$120
	rte
HBI_ROUTINE_4:
	move.w	#$00B,$ff8240
	clr.b		$FFFA1B			MFP timer B control
	move.b	#5,$FFFA21			timer B data
	move.b	#8,$FFFA1B
	clr.b		$fffa1f			timer A data
	clr.b		$fffa0f			interupt in service A
	move.l	#HBI_ROUTINE_5,$120
	rte
HBI_ROUTINE_5:
	move.l	#$00040130,COLOUR+0
	move.l	#$02400350,COLOUR+4
	move.w	#$123,COLOUR+8
	move.w	#$234,COLOUR+16
	move.w	#$345,COLOUR+24
	clr.b		$FFFA1B			MFP timer B control
	move.b	#5,$FFFA21			timer B data
	move.b	#8,$FFFA1B
	clr.b		$fffa1f			timer A data
	clr.b		$fffa0f			interupt in service A
	move.l	#HBI_ROUTINE_6,$120
	rte
HBI_ROUTINE_6:
	move.w	#$00C,$ff8240
	clr.b		$FFFA1B			MFP timer B control
	move.b	#5,$FFFA21			timer B data
	move.b	#8,$FFFA1B
	clr.b		$fffa1f			timer A data
	clr.b		$fffa0f			interupt in service A
	move.l	#HBI_ROUTINE_7,$120
	rte
HBI_ROUTINE_7:
	move.w	#$005,$ff8240
	clr.b		$FFFA1B			MFP timer B control
	move.b	#5,$FFFA21			timer B data
	move.b	#8,$FFFA1B
	clr.b		$fffa1f			timer A data
	clr.b		$fffa0f			interupt in service A
	move.l	#HBI_ROUTINE_8,$120
	rte
HBI_ROUTINE_8:
	move.w	#$00D,$ff8240
	clr.b		$FFFA1B			MFP timer B control
	move.b	#5,$FFFA21			timer B data
	move.b	#8,$FFFA1B
	clr.b		$fffa1f			timer A data
	clr.b		$fffa0f			interupt in service A
	move.l	#HBI_ROUTINE_9,$120
	rte
HBI_ROUTINE_9:
	move.w	#006,$ff8240
	clr.b		$FFFA1B			MFP timer B control
	move.b	#255,$FFFA21		timer B data
	move.b	#8,$FFFA1B
	clr.b		$fffa1f			timer A data
	clr.b		$fffa0f			interupt in service A
	move.l	#HBI_ROUTINE_9,$120
	rte
	
SETUP:hidemouse
	push.w	#2
	trap		#14
	addq		#2,sp
	move.l	d0,PHYS_SCR
	move.l	d0,PHYS_VAR
	push.w	#3
	trap		#14
	addq		#2,sp
	move.l	d0,LOG_SCR
	move.l	d0,LOG_VAR
	push.w	#4
	trap		#14
	addq		#2,sp
	move.w	d0,OLD_REZ
	push.w	#0
	push.l	#-1
	push.l	#-1
	push.w	#5
	trap		#14
	add.w		#12,sp
	move.l	#BUFFER+256,d0
	clr.b		d0
	move.l	d0,LOG_SCR
	lea		COLOUR,a0
	lea		GEM_PAL,a1
	moveq		#7,d0
.lp	move.l	(a0)+,(a1)+
	dbra		d0,.lp		
	rts

END_KEY:
	push.w	#11
	trap		#1
	addq		#2,sp
	tst.w		d0
	bne.s		.end
	rts
.end	addq		#4,sp

EXIT:	IFND		MUSICOFF
	move.l	MUSIC_PTR,a0
	clr.l		(a0)
	ENDC
	clr.w		PLAY
	IFND		FASTMODE
	bsr		STOP_RASTERS
	ENDC
	bsr.s		R_C
	user
	bsr.s		R_S
	showmouse
	move.w	#0,-(sp)
	trap		#1

R_C	delay		1
	lea		COLOUR,a0
	lea		GEM_PAL,a1
	moveq		#7,d0
.c	move.l	(a1)+,(a0)+
	dbra		d0,.c
.end	rts

R_S	push.w	OLD_REZ
	push.l	PHYS_VAR
	push.l	LOG_VAR
	push.w	#5
	trap		#14
	add.w		#12,sp
	rts

COPY_SCR:
	push.l	d7
	move.w	#32000/64-1,d7
.clop	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	dbra		d7,.clop
	pop.l		d7
	rts

SET_COL:
	delay		1
	lea		COLOUR,a0
	lea		PALETTE,a1
	moveq		#7,d0
.col	move.l	(a1)+,(a0)+
	dbra		d0,.col
	rts

SET_COL2:
	delay		1
	lea		COLOUR,a0
	lea		PALETTE2,a1
	moveq		#7,d0
.col	move.l	(a1)+,(a0)+
	dbra		d0,.col
	rts

VBI:	subq		#1,d3
.vbip	move.w	#37,-(sp)
	trap		#14
	addq		#2,sp
	dbra		d3,.vbip
	rts

makebit  macro
.A	move.b	\1,(a1)+		;copy byte
	addq		#1,d3			;count	it
	cmp.b		#40,d3		;end of plane ?
	beq.s		.C
	btst		#0,d3
	bne.s		.D
	addq		#6,a1
.D	dbra		d1,.A
	bra.s		MAKE_LOOP
.C	moveq		#0,d3
	addq		#1,d4			;increase planes finished
	cmp.b		#4,d4			;end of line	?
	beq.s		.E
	sub.w		#152,a1
	bra.s		.D
.E	moveq		#0,d4
	dbra		d5,.D
	endm

MAKE_SCR:					; unpacks *.pc1 file to LOG_SCR
	addq		#2,a0
	moveq		#15,d0
	lea		PALETTE,a1
.D	move.w	(a0)+,d1
	move.w	d1,(a1)+
	dbra		d0,.D
	move.l	LOG_SCR,a1		;destination
	moveq		#0,d3			;bytes	this plane (0-39)
	moveq		#0,d4			;planes (0-3)
	move.w	#199,d5		;number of lines to do
MAKE_LOOP
	move.b	(a0)+,d1		;get control	byte
	ext.w		d1
	bpl.s		COPY_BLK		;copy literal
	cmp.b		#-128,d1		;no operation (ignore)
	beq.s		MAKE_LOOP
	neg.w		d1			;copy same byte lots of times
COPY_SAME
	move.b	(a0)+,d2
	makebit	d2
	bra.s		END_MAKE		;finished
COPY_BLK
	makebit	(a0)+			;copy block
END_MAKE
	rts	

load	macro
	lea		\1,a4
	lea		\2,a5
	move.l	#48500,a6
	bsr		OPEN
	endm

FILES:
	load		TRAX_1n,TRAX_1d
	IFND		TESTOSC
	load		TRAX_2n,TRAX_2d
	load		TRAX_3n,TRAX_3d
	load		TRAX_4n,TRAX_4d
	load		TRAX_5n,TRAX_5d
	load		TRAX_6n,TRAX_6d
	load		TRAX_7n,TRAX_7d
	load		TRAX_8n,TRAX_8d
;	load		TRAX_9n,TRAX_9d
	load		TRAX_10n,TRAX_10d
;	load		TRAX_11n,TRAX_11d
	load		TRAX_12n,TRAX_12d
	load		TRAX_13n,TRAX_13d
	load		TRAX_14n,TRAX_14d
	load		TRAX_15n,TRAX_15d
	load		TRAX_16n,TRAX_16d
	ENDC
	rts
	
OPEN:	clr.w		-(sp)			; load a file
	move.l	a4,-(sp)		; a4 -> filename
	move.w	#$3d,-(sp)
	trap		#1
	addq.l	#8,sp
	tst.w		d0
	bmi.s		.end
	move.w	d0,-(sp)		; store file handle
.rd	move.l	a5,-(sp)		; read file to data area
	move.l	a6,-(sp)
	move.w	d0,-(sp)
	move.w	#$3f,-(sp)
	trap		#1
	add.w		#12,sp
	move.l	d0,d7			; store length
.cl	move.w	#$3e,-(sp)		; close file
	trap		#1			; handle already on stack
	addq.l	#4,sp
	move.l	d7,d0
	tst.l		d0			; d0=bytes loaded, -ve=err
.end
	rts

PLOT:
; d6 = x pos
; d7 = y pos
	movem.l	d0-d6/a0-a6,-(sp)
	move.l	d6,d0
	move.l	d7,d1
	ext.l		d0
	ext.l		d1
	move.w	d0,d2
	and.w		#$F0,d0
	and.w		#$FF,d1
	lsr.w		d0
	mulu		#160,d1
	move.l	LOG_SCR,a0
	add.l		d0,d1
	add.l		d1,a0
	
	and.w		#$0F,d2
	move.w	#%1000000000000000,d0
	lsr.w		d2,d0

	or.w		d0,(a0)

.end	movem.l	(sp)+,d0-d6/a0-a6
.rts	rts

*******************************************************

	SECTION DATA

************************
* SCROLLY TEXT SEGMENT *
************************

TEXT:		dc.b	"                    "
		dc.b	"THIS IS THE NEW ORDER 'CONFUSION' DEMO WRITTEN BY DML AT I.C.E.......        "
		dc.b	"IT TAKES UP 800K IN SOUND DATA AND IS SPLIT INTO 16 INDIVIDUAL PIECES "
		dc.b	"WHICH TAKE UP ABOUT 48K EACH ( I.E. 12KHZ SAMPLE RATE ).......  "  
		dc.b	"SINCE IT IS PLAYED BACK USING THE DMA, IT TAKES UP BUGGER ALL CPU TIME, LEAVING "
		dc.b	"PLENTY FOR THE BOUNCY TEXT AND TRENDY OSCILLOSCOPE......... "
		dc.b	"                    "
		dc.b	0
		even

*************************
*   MUSIC SCORE TABLE   *
*************************

;	word1...	sample name
;	word2...	number of vbi's before next sound (sort of)

SCORE:dc.w		TRAX_1,beat
	dc.w		TRAX_1,beat
	dc.w		TRAX_1,beat
	dc.w		TRAX_2,beat
	
	dc.w		TRAX_3,beat
	dc.w		TRAX_4,beat
	dc.w		TRAX_3,beat
	dc.w		TRAX_4,beat

	dc.w		TRAX_8,beat
	dc.w		TRAX_8,beat
	dc.w		TRAX_8,beat
	dc.w		TRAX_8,beat

	dc.w		TRAX_5,beat
	dc.w		TRAX_6,beat
	dc.w		TRAX_5,beat
	dc.w		TRAX_6,beat

	dc.w		TRAX_8,beat
	dc.w		TRAX_8,beat
	dc.w		TRAX_12,beat
	dc.w		TRAX_13,beat

	dc.w		TRAX_10,beat
	dc.w		TRAX_10,beat
	dc.w		TRAX_10,beat
	dc.w		TRAX_10,beat/2
	dc.w		TRAX_16,beat/4
	dc.w		TRAX_16,beat/4

	dc.w		TRAX_12,beat
	dc.w		TRAX_13,beat
	dc.w		TRAX_12,beat
	dc.w		TRAX_13,beat

	dc.w		TRAX_12,beat/2
	dc.w		TRAX_16,beat/2
	dc.w		TRAX_12,beat/2
	dc.w		TRAX_16,beat/2
	
	dc.w		TRAX_12,beat
	dc.w		TRAX_13,beat
	dc.w		TRAX_12,beat
	dc.w		TRAX_13,beat

	dc.w		TRAX_8,beat/8
	dc.w		TRAX_8,beat/8
	dc.w		TRAX_8,beat/8
	dc.w		TRAX_8,beat/8
	dc.w		TRAX_8,beat/2
	dc.w		TRAX_8,beat
	
	dc.w		TRAX_7,beat/4
	dc.w		TRAX_7,beat/4
	dc.w		TRAX_7,beat/4
	dc.w		TRAX_7,beat/4
	dc.w		TRAX_7,beat
	
	dc.w		TRAX_15,beat
	dc.w		TRAX_15,beat
	dc.w		TRAX_15,beat
	dc.w		TRAX_15,beat
	
	dc.w		TRAX_14,beat
	dc.w		TRAX_15,beat
	dc.w		TRAX_14,beat
	dc.w		TRAX_15,beat

	dc.w		TRAX_8,beat
	dc.w		TRAX_7,beat
	dc.w		TRAX_8,beat
	dc.w		TRAX_7,beat

	dc.w		TRAX_3,beat/4
	dc.w		TRAX_3,beat/4
	dc.w		TRAX_3,beat/4
	dc.w		TRAX_3,beat/4
	dc.w		TRAX_3,beat

	dc.w		TRAX_12,beat
	dc.w		TRAX_13,beat
	dc.w		TRAX_12,beat
	dc.w		TRAX_13,beat

	dc.w		TRAX_15,beat
	dc.w		TRAX_15,beat
	dc.w		TRAX_14,beat
	dc.w		TRAX_14,beat

	dc.w		REPEAT

************************
* CHARACTER FADE MASKS *
************************

MASKIN		dc.l	MASK0,MASK1,MASK2,MASK3,MASK4,MASK5,MASK6,MASK7,MASK8
MASKOUT		dc.l	MASK8,MASK7,MASK6,MASK5,MASK4,MASK3,MASK2,MASK1,MASK0

MASK0			dc.b	%11111111
			dc.b	%11111111
			dc.b	%11111111
			dc.b	%11111111
			dc.b	%11111111
			dc.b	%11111111
			dc.b	%11111111
			dc.b	%11111111

MASK1			dc.b	%11111110
			dc.b	%11111111
			dc.b	%11111111
			dc.b	%11111111
			dc.b	%11111111
			dc.b	%11111111
			dc.b	%11111111
			dc.b	%01111111

MASK2			dc.b	%11111100
			dc.b	%11111110
			dc.b	%11111111
			dc.b	%11111111
			dc.b	%11111111
			dc.b	%11111111
			dc.b	%01111111
			dc.b	%00111111

MASK3			dc.b	%11111000
			dc.b	%11111100
			dc.b	%11111110
			dc.b	%11111111
			dc.b	%11111111
			dc.b	%01111111
			dc.b	%00111111
			dc.b	%00011111

MASK4			dc.b	%11110000
			dc.b	%11111000
			dc.b	%11111100
			dc.b	%11111110
			dc.b	%01111111
			dc.b	%00111111
			dc.b	%00011111
			dc.b	%00001111

MASK5			dc.b	%11100000
			dc.b	%11110000
			dc.b	%11111000
			dc.b	%01111100
			dc.b	%00111110
			dc.b	%00011111
			dc.b	%00001111
			dc.b	%00000111

MASK6			dc.b	%11000000
			dc.b	%11100000
			dc.b	%01110000
			dc.b	%00111000
			dc.b	%00011100
			dc.b	%00001110
			dc.b	%00000111
			dc.b	%00000011

MASK7			dc.b	%10000000
			dc.b	%01000000
			dc.b	%00100000
			dc.b	%00010000
			dc.b	%00001000
			dc.b	%00000100
			dc.b	%00000010
			dc.b	%00000001

MASK8			dc.b	%00000000
			dc.b	%00000000
			dc.b	%00000000
			dc.b	%00000000
			dc.b	%00000000
			dc.b	%00000000
			dc.b	%00000000
			dc.b	%00000000
		
SOUNDS:	dc.l	TRAX_1d	
		dc.l	TRAX_2d		
		dc.l	TRAX_3d		
		dc.l	TRAX_4d		
		dc.l	TRAX_5d		
		dc.l	TRAX_6d		
		dc.l	TRAX_7d		
		dc.l	TRAX_8d	
		dc.l	TRAX_9d	
		dc.l	TRAX_10d		
		dc.l	TRAX_11d		
		dc.l	TRAX_12d		
		dc.l	TRAX_13d		
		dc.l	TRAX_14d		
		dc.l	TRAX_15d		
		dc.l	TRAX_16d	
		dc.l	END_SND

TRAX_1n:	dc.b	'TRAX_1.SAM',0
		even
TRAX_2n:	dc.b	'TRAX_2.SAM',0
		even
TRAX_3n:	dc.b	'TRAX_3.SAM',0
		even
TRAX_4n:	dc.b	'TRAX_4.SAM',0
		even
TRAX_5n:	dc.b	'TRAX_5.SAM',0
		even
TRAX_6n:	dc.b	'TRAX_6.SAM',0
		even
TRAX_7n:	dc.b	'TRAX_7.SAM',0
		even
TRAX_8n:	dc.b	'TRAX_8.SAM',0
		even
TRAX_9n:	dc.b	'TRAX_9.SAM',0
		even
TRAX_10n:	dc.b	'TRAX_10.SAM',0
		even
TRAX_11n:	dc.b	'TRAX_11.SAM',0
		even
TRAX_12n:	dc.b	'TRAX_12.SAM',0
		even
TRAX_13n:	dc.b	'TRAX_13.SAM',0
		even
TRAX_14n:	dc.b	'TRAX_14.SAM',0
		even
TRAX_15n:	dc.b	'TRAX_15.SAM',0
		even
TRAX_16n:	dc.b	'TRAX_16.SAM',0
		even

PALETTE2:	dc.w		$000,$231,$342,$453,$234,$461,$461,$461
		dc.w		$456,$461,$461,$461,$677,$461,$461,$461

FONT:		incbin	e:\devpac\cdemo\damocles.fnt
PIC1:		incbin	e:\devpac\confuse.pc1
		even
PIC2:		incbin	e:\devpac\confuse.pc1
		even

*******************************************************
	
	SECTION BSS

HBI_STORE:		ds.l		1	store of horizontal blank vector
MFP_STORE:		ds.l		1	store of mfp data

SSTR:			ds.l		1
SEND:			ds.l		1	
SPEED:		ds.w		1
STAT:			ds.w		1
FRAME:		ds.w		1
BLIPS:		ds.w		1
VBI_COUNT:		ds.w		1
VBI_PTR:		ds.l		1	
MUSIC_PTR:		ds.l		1

TFLG:			ds.w		1
YPOS			ds.l		1
BOUNCE		ds.l		1
TEXT_POS		ds.l		1

SC_FLG		ds.b		1
HBI_ON_FLAG:	ds.b		1
			even

			ds.l		100
ustk:			ds.l		1
env_ptr:		ds.l		1

PHYS_SCR		ds.l		1
PHYS_VAR		ds.l		1
LOG_SCR		ds.l		1
LOG_VAR		ds.l		1
GEM_PAL		ds.w		16
NEW_PAL		ds.w		1
OLD_STK		ds.l		1
OLD_REZ		ds.w		1
PALETTE		ds.w		16
REG			ds.l		1
BUFFER		ds.b		32256
BUFFER_2		ds.b		32000

			IFND		TESTOSC
TRAX_1d:		ds.b		48400
TRAX_2d:		ds.b		48400
TRAX_3d:		ds.b		48400
TRAX_4d:		ds.b		48400
TRAX_5d:		ds.b		48400
TRAX_6d:		ds.b		48400
TRAX_7d:		ds.b		48400
TRAX_8d:		ds.b		48400
TRAX_9d:		ds.b		48400
TRAX_10d:		ds.b		48400
TRAX_11d:		ds.b		48400
TRAX_12d:		ds.b		48400
TRAX_13d:		ds.b		48400
TRAX_14d:		ds.b		48400
TRAX_15d:		ds.b		48400
TRAX_16d:		ds.b		48400/4
			ELSEIF
TRAX_1d:		ds.b		48400
TRAX_2d:		ds.b		1
TRAX_3d:		ds.b		1
TRAX_4d:		ds.b		1
TRAX_5d:		ds.b		1
TRAX_6d:		ds.b		1
TRAX_7d:		ds.b		1
TRAX_8d:		ds.b		1
TRAX_9d:		ds.b		1
TRAX_10d:		ds.b		1
TRAX_11d:		ds.b		1
TRAX_12d:		ds.b		1
TRAX_13d:		ds.b		1
TRAX_14d:		ds.b		1
TRAX_15d:		ds.b		1
TRAX_16d:		ds.b		1
			even
			ENDC
END_SND
