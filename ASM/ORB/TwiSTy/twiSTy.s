*****************************************************************************
* TwiSTy
*
* a small 256 byte twister (including file header)
* for atari st(e)...
*
* basically a rewrite of my vc20 twister...
*
* ultra^orb 20210608
*
*****************************************************************************
release		equ	1
sin			equ	end+1024
screen		equ	end+2048
efxLines	equ	200
scrPos		equ	16
off1		equ	108	;108
off2		equ	105	;105
*****************************************************************************

start
	pea		prg(pc)
	move.w	#$26,-(a7)
	trap	#$e
prg:
	move	#$2700,sr
	
	clr		-(sp)
	move.l	$44e.w,a5
	move.l	a5,-(sp)
	move.l	a5,-(sp)
	move.w	#5,-(sp)
	trap	#14

	; create a ste color palette 
	lea		$ffff8240.w,a0
	move	#$100,(a0)+
	moveq	#$e,d0
	moveq	#$021,d1
setCols:
	move	d1,d2
	move	d1,d7
	and		#$111,d2
	and		#$eee,d7
	lsl		#3,d2
	lsr		#1,d7
	or		d2,d7

	add		#$100,d1
	move	d7,(a0)+
	dbf		d0,setCols

	move	#$381>>1,d5
	lea		sin+256(pc),a3
	moveq   #1,d4

	moveq   #127,d6
createSin:
	add     d5,d4
	move.l  d4,d3
	asr		#8,d3
	add		#$80,d3
	move.b  d3,-(a3)
	neg.b    d3
	move.b  d3,-128(a3)
	subq    #7,d5
	dbf     d6,createSin

	moveq	#0,d4
	lea		sin(pc),a1
mainloop:

	move	#efxLines-1,d7
	move.l	$44e.w,a0
;	lea		screen+16(pc),a0
drawLoop:
	
	;create a "motion" via bitplanes by scrolling them
	lea		32(a0),a2
	moveq	#8-1,d5
copyPlanes:
	move.l	2(a2),(a2)+
	move.w	2(a2),(a2)+
	clr		(a2)+
	dbf		d5,copyPlanes

	move.b	d6,d3
	add.b	(a1,d4),d3

	bsr.s	plot
	add.b	#85,d3
	bsr.s	plot
	add.b	#170-85,d3
	bsr.s	plot

	subq.b	#1,d6
	addq.b	#1,d4
	lea		160(a0),a0
	dbf		d7,drawLoop

	add.b	#((efxLines*1)+1)&$ff,d6
	sub.b	#((efxLines*1)-1)&$ff,d4

	bra.s   mainloop
plot:
;d0 x
;a0 screen line
	move.b	d3,d2
	sub.b	#(off1)&$ff,d2
	cmp.b	#(256-off2-off1)&$ff,d2
	bcs.s	nodraw

	move.b	(a1,d3),d0
	and		#$ff,d0
	move	d0,d1
	moveq	#$1,d2
	not		d1
	and		#$f,d1
	lsl		d1,d2
	lsr		#4,d0
	lsl		#3,d0
	or		d2,6(a0,d0)		
nodraw:
	rts
end:
*****************************************************************************
		printt  "size:"
		if      release=1
		printv  *-start
		printv  *-start+32
		else
		printv  *-start-20
		printv  *-start-26
		endc
*****************************************************************************

		end