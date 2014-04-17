	.globl scroll
	.include hardware
	.include defs

*	vertical/horizontal scroll test
*	Aug 31, 89:  place screen at 128k
*	July 17, 89: use triangle patterns
*	Screen mode must be 640x200 (2 planes).
*	Write a screen pattern for a virtual screen of 1280 lines.
* 	Scroll a line at a time from beginning to end, and start over at
*	the beginning when end is reached.

* 19JUN92 : RWS : changed horiz #'s to fix SPARROW/STe diffs.

vscreen	equ	$20000
vbash	equ	$2
vbasm	equ	0
vbasl	equ	0
scrlin	equ	640*2/8			;length in bytes of a screen line
scrlen	equ	640*2*scrlin		;length of virtual screen
vscrend	equ	vscreen+scrlen		;address of end of virtual screen
hscrend	equ	vscreen+scrlin*2
wrdsiz	equ	4			;# bytes for 16 pixels in 2-plane
hbit	equ	$ff8264
hwidth	equ	$ff820e

	.text
scroll:
	bsr	savdsp		;save screen values
	move	#0,d4
	lea	vscreen,a0
	move.l	#scrlen,d7
	bsr	clrblk

	move	#1,d4		;1 to 640 (width of screen)
	lea	vscreen,a0
vsrt:	bsr	vpattern	;fill in line, increasing left to right
	add	#1,d4
	cmpi	#641,d4
	bne.s	vsrt
	sub	#2,d4
vslf:	bsr	vpattern	;fill in line, decreasing right to left
	sub	#1,d4
	bne.s	vslf

*	set up vertical blank
	move.l	$70,vecsav
	move.l	#vbs,$70

*	let it scroll
	move	#white,palette
	move	#black,palette+6
	move	#$ff,vsflg
	move	#$2200,sr

*	wait for keystroke
wtvs:	bsr	conin
	cmpi.b	#' ',d0
	bne.s	wtvs

	move	#$2400,sr
	
*	horizontal scroll test
*	Screen mode must be medium res - 640x400 (2 planes).
	move	#0,d4		;0 to 399 (height of screen)
	lea	vscreen,a0
	move.l	#scrlen/2,d7
	bsr	clrblk
hsrt:	bsr	hpattern	;fill vertical stripes
	add	#1,d4
	cmpi	#202,d4
	bne.s	hsrt

	move	#-1,hcount

	move.l	#vbl,$70
	move.l	$68,vecsav+4
	move.l	#hbl,$68

	move	#$ff,vsflg		;flag new screen address
	move	#scrlin/2,hwidth	;make virtual screen double width
	
	move	#$2000,sr		;start scrolling

*	wait for keystroke
	clr.b	brkcod
hswt:	bsr	conin
	cmpi.b	#' ',d0			;got space?
	beq.s	.exit
	cmpi.b	#'.',d0
	beq.s	.stop
	cmpi.b	#',',d0
	beq.s	.start
	bra	hswt
.stop:
	move.w	#$2400,sr
	bra	hswt
.start:
	move.w	#$2000,sr
	bra	hswt
.exit:
	bset	#7,d1			;break scan code
hswtbk:	cmp.b	brkcod,d1		;wait for key break (last test)
	bne.s	hswtbk

*	clean up and return
	move	#$2400,sr
	move	#0,hbit
	move	#0,hwidth
	move.l	vecsav,$70
	move.l	vecsav+4,$68
	bsr	resdsp			;restore display
	bset	#autoky,consol		;return directly to menu
	rts

**********************************************
*	vertical/horizontal scroll subroutines

*------------------------
*	clear block of memory
*	a0 = start
*	d7 = length in words
clrblk:	move.l	a0,-(sp)
clrbl0:	clr	(a0)+
	sub.l	#1,d7
	bne.s	clrbl0
	move.l	(sp)+,a0
	rts

*--------------------------------
*	fill in a line 
*	entry:	d4 = number of bits to fill (1-640)	
*		a0 = start of line
*	i.e., if 1, fill leftmost bit, if 80, fill 1-80
*	this is 4 plane mode, so fill 2 words
vpattern:
	move	d4,-(sp)
	move.l	a0,a1
	move	#scrlin,d0
	add	d0,a1		;a1 = next line

*	fill multiples of 16
vp0:	cmpi	#16,d4
	blt	vp_last
	move	#$ffff,d0
	move	d0,(a0)+	;fill 16 bits
	move	d0,(a0)+	;in 2 planes
	subi	#16,d4
	beq.s	vp_last		;no remainder
	cmp.l	a0,a1		
	bne.s	vp0

*	fill remainder (<16 bits)
vp_last:
	tst	d4		;more bits?
	beq.s	vp_x
	clr	d0
*	bit order on screen is 15,14,13,...
*	if d4=1, set bit 15, if=15, set bits 1-15	
vp1:	move	#16,d1		;calculate bit numbers to set
	sub	d4,d1		;15->1, 14->2,...,1->15	
	bset	d1,d0		;set bit
	subq	#1,d4		;from 15 to ...
	bne.s	vp1
	move	d0,(a0)+
	move	d0,(a0)+
vp_x:	move.l	a1,a0		;update new line start
	move	(sp)+,d4
	rts

*--------------------------------
*	fill in a line (virtual screen is two screens wide, fills in
*		two physical lines one after the other)
*	entry:	d4 = line number = number of bits to leave untouched	
*		a0 = start of line
*	exit:	a0 = next line
*	i.e., if 1, fill leftmost bit, if 80, fill 1-80
*	this is 4 plane mode, so fill all 4 words
hpattern:
	move	d4,-(sp)
	move.l	a0,a1
	move.l	a0,a2
	move.l	#scrlin,d0
	add.l	d0,a1		;a1 = end of line +1
	lsr	#1,d0
	add.l	d0,a2		;a2 = midpt this line
	move.l	a0,a3		;copy start of line
	lsl	#2,d0		;add physical line x2
	add	d0,a3		;=next line 

*	edge word has line number mod 16 bits set
	clr.l	d2
	clr.l	d3
	move	d4,d2

*	divide line number by 16: quotient=# of words to shift,
*	remainder=# of bits to shift
	divu	#16,d2
	move	d2,d3		;move # words to d3
	lsl.l	#2,d3		;x4 because its # of words x 2 planes
	add.l	d3,a0		;advance pointer d2 words
	sub.l	d3,a1		;backup point from end of line
	swap	d2		;remainder of line number/16 = bits
	move	#15,d1
	sub	d2,d1		;sub from 15 for bit number to set
	clr	d0		;d0 = left edge
	clr	d3		;d3 = right edge (reflection)

*	do bit shift for edge
hpat0:	bset	d1,d0		;d1 = 0-15
	bset	d2,d3		;d2 = 15-0
	addq	#1,d2
	dbra	d1,hpat0
	move	d0,scrlin(a0)
	move	d0,(a0)+	;left edge
	move	d0,scrlin(a0)
	move	d0,(a0)+
	move	d3,-(a1)	;right edge
	move	d3,scrlin(a1)
	move	d3,-(a1)
	move	d3,scrlin(a1)
	
*	fill remaining words all 1's
	moveq	#$ff,d0
hpat1:	cmpa.l	a0,a2		;meet in middle
	ble.s	hp_x
	move	d0,scrlin(a0)
	move	d0,(a0)+	;1st half
	move	d0,-(a1)	;2nd half
	move	d0,scrlin(a1)
	bra.s	hpat1
	
hp_x:	move.l	a3,a0		;update new line start
	move	(sp)+,d4
	rts


********************************
*	vertical blank handler for horiz scroll
vbl:	clr	hcount
	rte

********************************
*	horizontal blank handler for horiz scroll
hbl:
	move.l	d0,-(sp)
	add	#1,hcount
*	cmp	#235,hcount	;look for end of screen (200 visible +35)
	cmp	#265,hcount	;look for end of screen (200 visible +65 for SPARROW)
	bne	hbsx		;if not at end, do nothing

hbs:	cmp	#0,vsflg
	beq.s	hbs1		;branch if not time for start

*	start of screen
hbs0:	move.b	#vbash,v_bas_h
	move.b	#vbasm,v_bas_m
	move.b	#vbasl,v_bas_l
	move.l	#vscreen,v_bas_c ;new screen address
	move	#0,hbit		;no bit offset
	move	#scrlin/2,hwidth ;no extra fetch, normal length line
	clr	vsflg
	move	#0,vscount
	bra.s	hbsx

*	check for bit or word scroll
hbs1:
	move	vscount,d0
	add	#1,d0
	andi	#$f,d0
	move	d0,vscount
	tst	d0		;if 0, inc word
	beq.s	wscroll		;do word scroll

*	do bit scroll
	move	d0,hbit		;do bit scroll
	move	#scrlin/2-2,hwidth ;compensate for extra fetch
	bra.s	hbsx
	
*	bit count=0, do word scroll (16 pixels)
wscroll:
*	advance base address and check for end of screen
	add.l	#wrdsiz,v_bas_c	;next word

	move	#0,hbit		;no bit offset
	move	#scrlin/2,hwidth ;no extra fetch, normal length line
	move.b	v_bas_c+3,v_bas_l	;scroll a word
	cmp.l	#hscrend,v_bas_c ;compare to end of virtual screen
	bge	hbs0		;if there, restart, else scroll word

hbsx:	move.l	(sp)+,d0
	rte

********************************
*	vertical blank handler for vertical scroll
*	virtual screen is 640*2*2/8. Number of lines is equal to 2 widths
*	of the screen, since the pattern increments one bit across each line
*	(640 pixels across, written twice, 8 pixels per byte, 2 planes)
vbs:
	movem.l	d0-d1,-(sp)
	cmp	#0,vsflg
	beq.s	vbs1		;branch if not time for start/restart

*	start of screen
vbs0:	move.b	#vbash,v_bas_h
	move.b	#vbasm,v_bas_m
	move.b	#vbasl,v_bas_l
	move.l	#vscreen,v_bas_c ;save screen address
	clr	vsflg
	clr	vscount
	bra.s	vbsx

*	check for end of screen
vbs1:
	move.l	v_bas_c,d0
	cmp.l	#vscrend,d0	;compare to end of virtual screen
	bge.s	vbs0		;if there, restart, else scroll

*	scroll mid screen
	add	#1,vscount
	cmp	#2,vscount
	bne.s	vbsx		;not time to scroll

*	advance one line
	clr	vscount
	add.l	#scrlin,d0	;inc one scan line
	move.l	d0,v_bas_c	;save new address
	move.b	v_bas_c+1,v_bas_h
	move.b	v_bas_c+2,v_bas_m
	move.b	v_bas_c+3,v_bas_l
vbsx:	movem.l	(sp)+,d0-d1
	rte

