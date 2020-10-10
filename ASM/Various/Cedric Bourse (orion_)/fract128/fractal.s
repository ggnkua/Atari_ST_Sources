	; Fractal128 - by Orion_ [02/06/2018]
	; My first 128bytes Atari intro !

	; This is a "Sierpinski like" Fractal generator using the simple Wolfram's algorithm

	; This could be optimized, but it's already 128bytes so ...

; Resolution			; Low/Med/High
NPIX		equ	320	; 320/640/640
LINES		equ	200	; 200/200/400
NEXT_CHUNK	equ	8	; 8/4/2

	section	text

	move.w	#129,d7		; Initial Magic Value
Again:
	; Make Rule Tab
	move.l	d7,d0
	lea	RULE(pc),a0
	moveq	#8-1,d2
.rule:	move.b	d0,d1
	lsr.b	#1,d0
	andi.b	#1,d1
	move.b	d1,(a0)+
	dbra	d2,.rule

	move.w	#$02,-(a7)	; PhysBase(); (shorter than Super() + $44E.w)
	trap	#14
	addq.l	#2,a7
	move.l	d0,a0		; Screen Ptr

	lea	RULE(pc),a2
	lea	line(pc),a5
	lea	Nline(pc),a6

	; Initial dot
	moveq	#1,d0		; needed to clear whole D0 (for next ror)
	move.b	d0,((NPIX/2)-1)(a5)

	; Process
	move.w	#LINES-1,d3	; N lines

.line:	move.l	a5,a3		; Cur line
	lea	1(a6),a4	; New line

	move.w	#NPIX-3,d1	; Generate Next Line (chunky)
.pix:	move.b	(a3)+,d0	; get 3bits
	ror.w	#1,d0
	move.b	(a3)+,d0
	ror.w	#1,d0
	move.b	(a3)+,d0
	rol.w	#2,d0
	move.b	(a2,d0.w),d2	; get rule for these 3 bits
	move.b	d2,(a4)+	; result pixel in New line
	subq.l	#2,a3		; rol back to get next 3 bits
	dbra	d1,.pix

	move.l	a6,a4		; Chunky to Planar 1bit :)
	moveq	#(NPIX/16)-1,d2
.l16:	moveq	#16-1,d1
.p16:	lsl.w	#1,d4		; shift pixels bit
	or.b	(a4)+,d4	; OR new pixel
	dbra	d1,.p16
	move.w	d4,(a0)		; 16 pixels on screen
	addq.l	#NEXT_CHUNK,a0	; next pixel chunk
	dbra	d2,.l16

	move.l	a5,d4		; swap line pointers
	move.l	a6,a5
	move.l	d4,a6

	dbra	d3,.line

	subq.b	#1,d7		; Next Magic Value
	bra.s	Again

	section	bss

RULE:	ds.b	8
line:	ds.b	NPIX
Nline:	ds.b	NPIX
