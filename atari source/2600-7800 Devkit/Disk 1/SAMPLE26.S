	.title		"2600 Sample Routines"
*******************************************************
*
*	Two 2600 routines that every 2600 programmer
*	should have.
*
*	horzset -- This is a stock horizontal positioning routine for
*		   player0, player1, missle0, missle1, and the ball
*
*	char6n  -- This is the famous 6 character score kernel which
*		   is called to display 6 independant 8-pixel graphics
*		   on a horizontal band.  To be used with set6c which
*		   initializes the TIA.
*
*
*   This program exercizes the two routines contained herein.  The six
*   character score kernel appears near the bottom of the screen
*   displaying the frame counter.  Player0 & player1 are bouncing around
*   the upper part of the screen.  The kernel displaying the 2 bouncing
*   players is a 1 line kernel.  It has single vertical line positioning
*   and single vertical line graphics resolution.  This is not usually
*   possible in a typical game since many other things need updating
*   by the kernel (i.e. playfield, color changes, missles, etc.).  So, many
*   games use a 2 line kernel which would allow for 2 line vertical
*   positioning and 2 vertical line graphics resolution of the players.
*   In any case, writing kernels is an art not easily aquired.  Patience
*   and imagination are needed in abundance.  Good luck!
*
*
*   For questions or advice, call Dave Staugas  [415] 745-2267 
*
*
DEV	equ	0	;defined if development system (else, comment out)
*
	.include	"stella.s"
*
*  Ram Zero page definitions
*
	.org	$80
frmcnt:
	.ds.w	1	;frame counter (every game should have one)
	.ds.b	1	;really big frame counter!!
*
*  the following five bytes of RAM must appear in this order..
*
hposp0:
	.ds.b	1	;player 0 horizontal position
hposp1:
	.ds.b	1	;player 1 horizontal position
hposm0:
	.ds.b	1	;missle 0 horizontal position
hposm1:
	.ds.b	1	;missle 1 horizontal position
hposbl:
	.ds.b	1	;ball horizontal position
*
*   A few vertical positions here
*
yposp0:
	.ds.b	1	;player 0 vert position
yposp1:
	.ds.b	1	;player 1 vert position
grafptr0:
	.ds.w	1	;graphics pointer for player 0
grafptr1:
	.ds.w	1	;graphics pointer for player 1
*
hzvel0:
	.ds.b	1	;signed player0 horizontal velocity
hzvel1:
	.ds.b	1	;signed player1 horizontal velocity
vtvel0:
	.ds.b	1	;signed player0 vertical velocity
vtvel1:
	.ds.b	1	;signed player1 vertical velocity
*
*  some temporary locations..
*
temp0:
	.ds.b	1	;location for temporary storage
temp1:
	.ds.b	1
*
*  6 character score kernel
*
score6:
	.ds.w	1	;ptr to leftmost graphic of 6 character kernel
score5:
	.ds.w	1	;ptr to 5th from right of 6 character kernel
score4:
	.ds.w	1	;ptr to 4th from right of 6 character kernel
score3:
	.ds.w	1	;ptr to 3rd from right of 6 character kernel
score2:
	.ds.w	1	;ptr to 2nd from right of 6 character kernel
score1:
	.ds.w	1	;ptr to rightmost graphic of 6 character kernel
*
*
*    Rom code begins here..
*
*
	.org	$F800
*
start:
	.if	^^defined DEV
	lda	#$fd		;In the development system,
	sta	COLUPF		;  these two instructions must be executed 1st
*
	cli			;--this one lets the debugger break-in
	.else
	sei
	.endif
*
	cld
	ldx	#$ff
	txs			;initialize stack ptr to $ff
	inx			;x=0
	txa			;a=0
*
*  clear ram and zero out all TIA registers..
*
clearam:
	sta	VSYNC,x
	inx
	bne	clearam
*
*
*   Initialize ram here
*
*     give players a starting position..
*
	lda	#20
	sta	hposp0		;players' starting horz position
	lda	#75
	sta	hposp1
*
	lda	#50
	sta	yposp0		;players' starting vert position
	lda	#100
	sta	yposp1
*
	lda	#1
	sta	hzvel0		;player0's starting signed velocity
	sta	vtvel0
*
	lda	#$ff
	sta	hzvel1		;player1's starting signed velocity
	sta	vtvel1
*
;*************************************************************************
;
; Top of Syncs
;
;   Beginning of frame...
;
;
bframe:
	lda	#2
	sta	WSYNC
	sta	VSYNC		;turn on V-sync
*
	sta	WSYNC		;wait 3 scanlines
	sta	WSYNC
	sta	WSYNC
*
	LDX	#0
	STX	VSYNC		;turn off V-sync
*
	lda	#$2d
	sta	TIM64T		;load up underscan timer
*
*  Perform any underscan processing here..
*
*  advance frame counter..
*
	inc	frmcnt		;increment frame count
	bne	.10		; br if no roll-over
	inc	frmcnt+1	;   increment hi byte if roll-over
	bne	.10
	inc	frmcnt+2
.10:
	lda	#NUM0 >> 8
	sta	score1+1	;set-up high byte of score kernel pointers
	sta	score2+1
	sta	score3+1
	sta	score4+1
	sta	score5+1
	sta	score6+1
	sta	grafptr0+1
	sta	grafptr1+1
*
	ldx	#2
	lda	#0
ldloop:
	sta	temp0
	lda	frmcnt,x
	lsr
	lsr
	lsr
	lsr
	tay
	lda	DIG,y
	ldy	temp0
	sta	score6,y
	lda	frmcnt,x
	and	#$f
	tay
	lda	DIG,y
	ldy	temp0
	sta	score5,y
	tya
	clc
	adc	#score1-score3
	dex
	bpl	ldloop
*
*  Animate the 2 players
*
*      (no animate for now)
*
	lda	#NUM0&255
	sta	grafptr0
*
	lda	#NUM1&255
	sta	grafptr1
*
*  Move the 2 players
*
	lda	INPT4
	and	INPT5		;either fire button hit?
	bmi	automove	;automatically move players if not depressed
*
*  move players from their joysticks if either firebutton depressed
*
	lda	frmcnt		;move only every 4th frame
	and	#3
	bne	skipmove	;br if no move this time
*
	ldy	#0
	lda	SWCHA		;else, move player 1 from joystick
nextjoy:
	rol
	bcs	.10
	ldx	hposp0,y
	inx
	stx	hposp0,y
.10:
	rol
	bcs	.20
	ldx	hposp0,y
	dex
	stx	hposp0,y
.20:
	rol
	bcs	.30
	ldx	yposp0,y
	dex
	stx	yposp0,y
.30:
	rol
	bcs	.40
	ldx	yposp0,y
	inx
	stx	yposp0,y
.40:
	iny
	cpy	#2
	bne	nextjoy
*
skipmove:
	jmp	movedone
automove:
	ldx	#1
movloop:
	lda	hzvel0,x
	tay
	clc
	adc	hposp0,x
	sta	hposp0,x
	cmp	#5		;horz minimum
	bcc	movlp1
	cmp	#150		;horz maximum
	bcc	movlp2
movlp1:
	tya
	eor	#$ff
	clc
	adc	#1
	sta	hzvel0,x	;reverse direction
movlp2:
*
*  now do vertical
*
	lda	vtvel0,x
	tay
	clc
	adc	yposp0,x
	sta	yposp0,x
	cmp	#10		;vert minimum
	bcc	movlp3
	cmp	#160		;vert maximum
	bcc	movlp4
movlp3:
	tya
	eor	#$ff
	clc
	adc	#1
	sta	vtvel0,x	;reverse direction
movlp4:
	dex
	bpl	movloop
*
movedone:
*
*  set colors for 2 bouncing players
*
	lda	#$46
	sta	COLUP0
	lda	#$A6
	sta	COLUP1
*
*
	ldx	#4		;horizontally position all 5 objects
	jsr	horzset		;this routine does it
*
ustime:
	lda	INTIM		;wait for underscan timer to expire
	bne	ustime
*
*  Visible screen begins here..
*
	lda	#$e4		;load up screen timer (optional)
	sta	TIM64T
*
	lda	#0
	sta	WSYNC		;*************************
	sta	VBLANK		;3 turn on beam
*
*   put a display kernel here...
*
	ldx	#170		;5
kernloop:
	ldy	#0		;7/24/30/31
	txa			;33
	sec			;35
	sbc	yposp1		;38
	clc			;40
	adc	#7		;42
	bmi	nogrp1		;44
	cmp	#7		;46
	bcs	nogrp1		;48
	tay			;50
	lda	(grafptr1),y	;55
	tay			;57
nogrp1:
	txa			;59
	sec			;61
	sbc	yposp0		;64
	clc			;66
	sta	WSYNC		;************************
	sty	GRP1		;3
	ldy	#0		;5
	adc	#7		;7
	bpl	yeagrp0		;9/10
nogrp0:
	lda	#0		;11/17
	jmp	dogrp0		;14/20
yeagrp0:
	cmp	#7		;12
	bcs	nogrp0		;14/15
	tay			;16
	lda	(grafptr0),y	;21
dogrp0:
	sta	GRP0		;17/23/24
	dex			;19/25/26
	bne	kernloop	;22/28/29
*
*
*   Now do Score kernel on bottom of screen
*
	jsr	set6c		;set-up 6 character kernel
*
	lda	#$e
	sta	WSYNC		
	sta	COLUP0		;put in bright color for 6 character kernel
	sta	COLUP1
*
	lda	#6		;graphics is 7 lines hi
	jsr	char6n		;do 6 character kernel
*
	sta	WSYNC
	lda	#0
	sta	NUSIZ0		;clear out all that weird 6 char
	sta	NUSIZ1		;  kernel stuff
	sta	VDELP0
	sta	VDELP1
*
*
*   wait for display to expire (if it hasn't already done so)
*
sstime:
	lda	INTIM
	bne	sstime		;wait for display time to finish
* 
	lda	#2
	sta	WSYNC
	sta	VBLANK		;turn off beam
*
*   load up overscan timer...
*
	lda	#$24
	sta	TIM64T
*
*
ostime:
	lda	INTIM		;wait for overscan to expire
	bne	ostime
*
*  Now go back to Top of Syncs
*
	jmp	bframe
*
***************************************************
*
*
*   Horizontal Position Routine
*
*   Entry:  x = # of objects to position horizontally (-1)
*
*	It is assumed that the objects' horizontal positions
*	are stored in RAM in the same order as the
*	TIA reset registers for those objects, starting with
*	a RAM location labeled "hposp0"
*
horzset:
	lda	hposp0,x	;get horz position of current object
	clc
        adc	#$2f
        tay 
        and	#$f
        sta	temp0
        tya
        lsr 
        lsr 
        lsr 
        lsr 
        tay 
        clc 
        adc	temp0
        cmp	#$f
        bcc	horiz21
        sbc	#$f
        iny 
horiz21:
        eor	#7
        asl
        asl
        asl
        asl
        sta	HMP0,x
        sta	WSYNC
horiz31:
        dey
        bpl	horiz31
        sta	RESP0,x
        dex
        bpl	horzset
endhorz:
        sta	WSYNC
        sta	HMOVE
        rts
*
*******************************************
*
*   Set-up for 6-character score kernel...
*
*     call this when its time to position players for the
*      6-character score kernel..
*
set6c:
	sta	WSYNC
	lda	#3
	ldy	#0
	sty	REFP1
	sta	NUSIZ0
	sta	NUSIZ1
	sta	VDELP0
	sta	VDELP1
	sty	GRP0
	sty	GRP1
	sty	GRP0
	sty	GRP1
	sty	HMP1
	nop
	sta	RESP0
	sta	RESP1
	lda	#$F0
	sta	HMP0
	sty	REFP0
	sta	WSYNC
	sta	HMOVE
	rts
*
************************************************
*
*   This is the famous (or infamous) 6-character score kernel
*   Be sure that the set6c routine above has been called to
*   position the players and initialize all hardware needed.
*
*   6 indirect pointers (score1 thru score6 must be initialized)
*     to the 6 graphics objects to be displayed
*
*   Entry: accum = # of scanlines high (-1) to be displayed
* 
char6n:
	sta	temp0
charlp:
	ldy	temp0
	lda	(score6),y
	sta	GRP0
	sta	WSYNC
	lda	(score5),y
	sta	GRP1
	lda	(score4),y
	sta	GRP0
	lda	(score3),y
	sta	temp1
	lda	(score2),y
	tax
	lda	(score1),y
	tay
	lda	temp1
	sta	GRP1
	stx	GRP0
	sty	GRP1
	sty	GRP0
	dec	temp0
	bpl	charlp
chardone:
	lda	#0
	sta	GRP0
	sta	GRP1
	sta	GRP0
	sta	GRP1
	rts
*
*
*
*
*   Force the following table to start on next available page..
*
	.org	(* & $ff00) + $100
NUM0:
	.dc.b	$3C,$66,$66,$66,$66,$66,$3C
NUM1:
	.dc.b	$7E,$18,$18,$18,$18,$78,$38
NUM2:
	.dc.b	$7E,$60,$60,$3C,$06,$46,$7C
NUM3:
	.dc.b	$3C,$46,$06,$0C,$06,$46,$3C
NUM4:
	.dc.b	$0C,$0C,$7E,$4C,$2C,$1C,$0C
NUM5:
	.dc.b	$7C,$46,$06,$7C,$60,$60,$7E
NUM6:
	.dc.b	$3C,$66,$66,$7C,$60,$62,$3C
NUM7:
	.dc.b	$18,$18,$08,$04,$02,$62,$7E
NUM8:
	.dc.b	$3C,$66,$66,$3C,$66,$66,$3C
NUM9:
	.dc.b	$3C,$46,$06,$3E,$66,$66,$3C
NUMA:
	.dc.b	$63,$63,$7F,$63,$63,$36,$1C
NUMB:
	.dc.b	$7E,$33,$33,$3E,$33,$33,$7E
NUMC:
	.dc.b	$3E,$63,$60,$60,$60,$63,$3E
NUMD:
	.dc.b	$7E,$33,$33,$33,$33,$33,$7E
NUME:
	.dc.b	$7F,$30,$30,$3E,$30,$30,$7F
NUMF:
	.dc.b	$78,$30,$30,$3E,$30,$30,$7F
*
*
DIG:
	.dc.b	NUM0&$0FF
	.dc.b	NUM1&$0FF
	.dc.b	NUM2&$0FF
	.dc.b	NUM3&$0FF
	.dc.b	NUM4&$0FF
	.dc.b	NUM5&$0FF
	.dc.b	NUM6&$0FF
	.dc.b	NUM7&$0FF
	.dc.b	NUM8&$0FF
	.dc.b	NUM9&$0FF
	.dc.b	NUMA&$0FF
	.dc.b	NUMB&$0FF
	.dc.b	NUMC&$0FF
	.dc.b	NUMD&$0FF
	.dc.b	NUME&$0FF
	.dc.b	NUMF&$0FF
*
*
	.org	$fffa
	.dc.w	start
	.dc.w	start
	.dc.w	start
