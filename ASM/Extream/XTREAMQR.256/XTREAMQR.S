* 256b moving QR-code, Emphii / eXtream, 11.11.2022 - 13.11.2022

* Includes the https://www.extreamdemoscene.org QR-code, which
* is moved in x-direction (clear4free -method)

* 320x200 HC RGB only
* As an effect, double line is used


		comment	HEAD=%111

RELEASE	= 1
DEBUG = 0
TEST = 0

	IFNE	RELEASE
		opt	d-
	ENDC

		opt	o+,ow-
		opt	p=68030


		section TEXT

* mandatory (8b)
extream		clr.l	-(sp)		; (+2) super()
		move.w	#$20,-(sp)	; (+4)
		trap	#1		; (+2)

* reso+screen (40b)
	IFEQ	DEBUG
		move.w	#%000100100,-(sp) ; (+4) hicolor 320 rgb
		move.w	#$58,-(sp)	; (+4)
		trap	#14		; (+2)
	ENDC

		move.l	#screenSpace,d0	; (+6!) initialize the screen
		clr.b	d0		; (+2)
		add.w	#256,d0		; (+4)
		move.l	d0,a5		; (+2)
	IFEQ	DEBUG
		move.b	d0,d1		; (+2) set the screen
		lsr.w	#8,d0		; (+2)
		move.l	d0,$ffff8200.w	; (+4)
		move.b	d1,$ffff820d.w	; (+4)
	ENDC
		lea	30*640+58*2(a5),a5 ; (+4) center the "screen"

* vbl (16b) 
	IFEQ	DEBUG
		move.w	SR,d0		; (+2)
		move.w	#$2700,SR	; (+4)
		move.l	#vbl,$70.w	; (+8!) My VBL
 		move.w	d0,SR		; (+2)
	ENDC

******* initials (16b)
		movem.l	(a5),d0-d7	; (+4) reset data registers
		moveq	#80,d2		; (+2) limit

	IFEQ	DEBUG
		move.w	#1,$ffff82c2.w	; (+6) double line
		move.l	d0,$ffff9800.w	; (+4) border color to zero
	ENDC

*******

* vbl (8b)
main		
	IFEQ	DEBUG
		cmp.w	#2,d1		; (+4) 2 vbl is mandatory for
		blt.s	main		; (+2) trying to read it
		moveq	#0,d1		; (+2)
	ENDC

**** 

* mandatories (6b)
		move.l	a5,a0		; (+2) screen
		lea	qr(pc),a4	; (+4) qrdata

* count curve and add to screen (12b)
		addq.w	#2,d3		; (+2) always add 2
		cmp.w	d2,d4		; (+2) do we reach the limit?
		blt.s	.j0		; (+2) not yet
		subq.w	#4,d3		; (+2) subtract 4, because add 2
.j0		add.w	d3,d4		; (+2) add -2/2 to curvepointer

		add.w	d4,a0		; (+2) add curvepointer to "screen"

* draw qrcode (38b)
		moveq	#25-1,d7	; (+2) 25 lines needs to be drawn
.yloop		move.l	(a4)+,d0	; (+2) next line for code
		moveq	#31-1,d6	; (+2) we handle 3+25+3 bits
.bloop		moveq	#-1,d5		; (+2) in first place, dot is always on
		asl.l	#1,d0		; (+2) shift MSB out
		bcs.s	.j1		; (+2) it's 1? go to draw
		moveq	#0,d5		; (+2) it was 0, so zero it gets
.j1		move.l	d5,640(a0)	; (+4) draw
		move.l	d5,644(a0)	; (+4) draw
		move.l	d5,(a0)+	; (+2) draw
		move.l	d5,(a0)+	; (+2) draw
		dbra	d6,.bloop	; (+4)
		lea	(2*640-31*8.w,a0),a0 ; (+4) next line
		dbra	d7,.yloop	; (+4)

****
		bra.s	main		; (+2) everything's done, start over

vbl		addq.w	#1,d1		; (+2)
		rte			; (+2)

		section	DATA

**			 **********++++++++++**********++
qr		dc.l	%00011111110100100001011111110000
		dc.l	%00010000010011100101010000010000
		dc.l	%00010111010100111100010111010000
		dc.l	%00010111010101111110010111010000
		dc.l	%00010111010101001111010111010000
		dc.l	%00010000010011011101010000010000
		dc.l	%00011111110101010101011111110000
		dc.l	%00000000000000110010000000000000
		dc.l	%00011110010110000100100111010000
		dc.l	%00010101001110100001101000100000
		dc.l	%00010011010011100000001000000000
		dc.l	%00011011000000111000110011000000
		dc.l	%00001000110010111111111101110000
		dc.l	%00000010001110010111011100010000
		dc.l	%00001010110000011101100101100000
		dc.l	%00010010000110000110101100010000
		dc.l	%00000111011011101011111111110000
		dc.l	%00000000000101110011000101010000
		dc.l	%00011111110010000101010101110000
		dc.l	%00010000010000000011000100100000
		dc.l	%00010111010001000101111110000000
		dc.l	%00010111010101101000010111000000
		dc.l	%00010111010110111010110101100000
		dc.l	%00010000010111101100110101000000
		dc.l	%00011111110110001100001111110000
*			 **********++++++++++**********++

		section	BSS

	IFEQ	TEST
screenSpace	ds.l	(320*200*2+256)/4
	ELSE
screenSpace	ds.l	0
	ENDC
