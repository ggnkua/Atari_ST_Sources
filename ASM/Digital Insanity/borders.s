; BORDERS.S
;
; The following code will effectively bust any borders present on
; your color monitor.
;
; Original source by TEX, but it was slightly mutilated by the eager
; fingers of Digital Insanity (of course)
;
; Have fun with it!

screen		equ	$a0000		; address of new screen
line		equ	(1*8)-1		; scanline where border is gone

x:		pea 	0		; supervisor on
		move	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,old_stack

		move.b	#0,$fffa1d	; disable timer C and D

		move	#0,$ff8240	; black screen

		move	#2,-(sp)	; get physbase
		trap	#14
		addq.l	#2,sp
		move.l	d0,oldscr

		move.l	#screen,d0	; set screen address
		lsr.l	#8,d0
		move.b	d0,$ff8203
		lsr 	#8,d0
		move.b	d0,$ff8201

		move.l	#screen+(line+2)*160,newscr	; fill screen
		lea	screen,a0
		moveq	#-1,d1
		move	#11499,d0
clsloop:	move.l	d1,(a0)+
		dbra	d0,clsloop

; put some graphics on the screen to show the effect

		move.l	newscr,a6	; pattern on screen
		moveq	#0,d4
kgloop:		lea	box,a0		
		move	#15,d7
gzloop:		move.l	a6,a1
		add.l	#230,a6		; 230 bytes per scanline
		movem.l (a0)+,d0-d1
		move	#27,d6
gsloop:		movem.l d0-d1,(a1)
		addq.l	#8,a1
		dbra	d6,gsloop
		addq	#1,d4
		cmp	#35,d4
		beq	gr_end
		dbra	d7,gzloop
		bra	kgloop
gr_end:
		move	#37,-(sp)		; vsync
		trap	#14
		addq.l	#2,sp

		move.b	#2,$ff820a	; 50 Hz
		move.b	#0,$ff8260	; lo-res

		movem.l palette,d0-d7
		movem.l d0-d7,$ff8240

		move	#37,-(sp)		; vsync
		trap	#14
		addq.l	#2,sp

; install timer B

		move.l	#noborder,$120
		move.b	#0,$fffa1b
		move.b	#line,$fffa21
		move.b	#8,$fffa1b
		move.b	#200,$fffa21
		bset	#0,$fffa07
		bset	#0,$fffa13

		bra 	wait

; well, this is the routine that does the job!

noborder:	movem.l d0-d7/a0-a6,-(sp)
		move	#$2700,sr

		lea	$ff8209,a0	; video address counter low
		lea	$ff8260,a1	; resolution
		lea	$fffa21,a2	; timer B data

		moveq	#0,d0
		moveq	#0,d1
		moveq	#16,d2
		moveq	#2,d3
		moveq	#0,d4

tbsyncloop:	cmp.b	#199,(a2)
		bne 	tbsyncloop

waitloop:	move.b	(a0),d0
		beq.s	waitloop

		sub	d0,d2
		lsl.w	d2,d1

begin:		dcb.w	92,$4e71

		lea	$ff820a,a0	; sync modus
		move	#34,d0		; number of scanlines to be opened

; repeat this for a number of scanlines

lines:		nop

; switch to mono -> obliterate linker border (MMU: OUCH!!)

		move.b	d3,(a1)		; to monochrome
		move.b	d4,(a1)		; to lo-res

		dcb.w	89,$4e71

; 50/60 Hz for right border (NURSE!!!)
		
		move.b	d4,(a0)
		move.b	d3,(a0)

		dcb.w	13,$4e71

; another 70Hz shock to make it work on all STs

		move.b	d3,(a1)
		nop
		move.b	d4,(a1)
 
		dcb.w	9,$4e71

		dbra	d0,lines	; end of loop, we've had 512 cycles

		movem.l	(sp)+,d0-d7/a0-a6
		bclr	#0,$fffa0f
		rte

; end of border-obliterating timer B interrupt!!!

wait:		move	#7,-(sp)
		trap	#1
		addq.l	#2,sp

		move.b	#0,$fffa1b
		bclr	#0,$fffa07
		bclr	#0,$fffa13

		move.b	#$51,$fffa1d

		move	#$777,$ff8240
		move	#0,$ff8240+6

		move.b	#1,$ff8260	; midres
		move.b	#2,$ff820a	; 50Hz

		move.l	oldscr,d0
		lsr.l	#8,d0
		move.b	d0,$ff8203
		lsr	#8,d0
		move.b	d0,$ff8201

		move.l	old_stack(pc),-(sp)
		move	#$20,-(sp)
		trap	#1
		addq.l	#6,sp

		clr.w	-(sp)
		trap	#1
	
		even

old_stack:	dc.l	0

palette:	dc.w	$0000,$0076,$0210,$0650,$0320,$0760,$0540,$0430	
		dc.w	$0527,$0111,$0222,$0333,$0444,$0555,$0666,$0333

box:		dc.w	$0001,$0000,$FFFF,$FFFF,$7FFD,$7FFC,$8003,$FFFF
		dc.w	$4005,$7FFC,$8003,$FFFF,$5FF5,$7FFC,$8003,$FFFF
		dc.w	$5015,$701C,$8FE3,$FFFF,$57D5,$701C,$8FE3,$FFFF
		dc.w	$5455,$739C,$8FE3,$FFFF,$5555,$739C,$8FE3,$FFFF
		dc.w	$5455,$739C,$8FE3,$FFFF,$57D5,$701C,$8FE3,$FFFF
		dc.w	$5015,$701C,$8FE3,$FFFF,$5FF5,$7FFC,$8003,$FFFF
		dc.w	$4005,$7FFC,$8003,$FFFF,$7FFD,$7FFC,$8003,$FFFF
		dc.w	$0001,$0000,$FFFF,$FFFF,$FFFF,$0000,$FFFF,$FFFF

		even

oldscr:		dc.l	0
newscr:		dc.l	0