* Simple playfield demo. All code by Agrajag of Digitech in October 1992.

; This illustrates a simple version of the playfield effect using
; timer B rasters. The pattern flashes in time with the channels
; of the music. Read the accompanying article for more details.

; Code and music (c) Agrajag October 1992. Credit me if you use it!

	pea	0
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,oldstack

	bsr	make_pattern
	bsr	make_screen

	bsr	music
	
	bsr	setints
	bsr	waitspc

	bsr	retints

	bsr	music+4

	bsr	restore_screen

	move.l	oldstack,-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr	-(sp)
	trap	#1

oldstack	ds.l	1

* Wait for the space bar

waitspc
.loop	cmp.b	#$39,$fffffc02.w
	bne	.loop
	rts

* Make up playfield pattern

make_pattern
	move.l	patd,a0
	move.l	patp,a1
	lea	pldat,a2
.loop	move	(a0)+,d0		get colour number
	cmp	#$ffff,d0
	beq.s	.end
	add	d0,d0
	move	(a1,d0.w),(a2)+		get palette value
	bra.s	.loop
.end	move	d0,(a2)+
	rts

patd	dc.l	pat_dat1
patp	dc.l	palette1

pat_dat1
	dc.w	4,5,6,7,7,6,5,4
	dc.w	4,1,1,1,1,1,1,4			; A
	dc.w	4,1,6,7,7,6,1,4
	dc.w	4,1,6,7,7,6,1,4
	dc.w	4,1,1,1,1,1,1,4
	dc.w	4,1,6,7,7,6,1,4
	dc.w	4,1,6,7,7,6,1,4
	dc.w	4,1,6,7,7,6,1,4
	dc.w	4,5,6,7,7,6,5,4
	dc.w	4,2,2,2,2,2,2,4			; G
	dc.w	4,2,6,7,7,6,5,4
	dc.w	4,2,6,7,7,6,5,4
	dc.w	4,2,6,7,7,2,2,4
	dc.w	4,2,6,7,7,6,2,4
	dc.w	4,2,6,7,7,6,2,4
	dc.w	4,2,2,2,2,2,2,4
	dc.w	4,5,6,7,7,6,5,4
	dc.w	4,3,3,3,3,3,3,4			; R
	dc.w	4,3,6,7,7,6,3,4
	dc.w	4,3,6,7,7,6,3,4
	dc.w	4,3,3,3,3,3,3,4
	dc.w	4,3,6,7,3,6,5,4
	dc.w	4,3,6,7,7,3,5,4
	dc.w	4,3,6,7,7,6,3,4
	dc.w	4,5,6,7,7,6,5,4
	dc.w	4,5,6,7,7,6,5,4
	dc.w	4,5,6,7,7,6,5,4
	dc.w	4,5,6,7,7,6,5,4
	dc.w	4,5,6,7,7,6,5,4
	dc.w	4,5,6,7,7,6,5,4
	dc.w	4,5,6,7,7,6,5,4
	dc.w	4,5,6,7,7,6,5,4
	dc.w	4,5,6,7,7,6,5,4

	dc.w	$ffff

palette1
	dc.w	0,$700,$70,$77,$4,$5,$6,$7

pldat	ds.w	300

* Make up screen.

make_screen
	move.l	$44e,oldscreen		save old screen address

	dc.w	$a00a			mouse pointer off

	move	#4,-(sp)		get old rez
	trap	#14
	addq.l	#2,sp
	move	d0,oldrez

	lea	$ffff8240,a0		save old colours
	lea	oldcols,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)

	move.l	end_code,d0
	addi.l	#256,d0
	clr.b	d0
	move.l	d0,a6	start of screen

	move.l	a6,screen
	clr	-(sp)
	pea	(a6)
	pea	(a6)
	move	#5,-(sp)
	trap	#14		setscreen
	add.l	#12,sp

* Now to make up the 8 pixel vertical pattern (colours 8 to 15)

	move.l	#%0101010101010101,d1	plane1
	move.l	#%0011001100110011,d2	plane2
	move.l	#%0000111100001111,d3	plane3
	move.l	#%1111111111111111,d4	plane4

* Double them up

	swap	d1
	add.w	d2,d1		plane 1 & plane 2
	swap	d3
	add.w	d4,d3		plane 3 & plane 4

* Now write them to the screen.

	move.l	#($7d00/8)-1,d0		a6=screen area
.loop	movem.l	d1/d3,(a6)
	addq.l	#8,a6
	dbf	d0,.loop

	rts

screen		ds.l	1
oldscreen	ds.l	1
oldrez		ds.w	1
oldcols		ds.w	16

restore_screen
	lea	oldcols,a0		restore colours
	lea	$ffff8240,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)

	move	oldrez,-(sp)		restore old screen
	move.l	oldscreen,-(sp)
	move.l	oldscreen,-(sp)
	move	#5,-(sp)
	trap	#14
	add.l	#12,sp

	dc.w	$a009			mouse pointer off

	rts

* Save interrupts.

setints	move	#$2700,sr
	lea	ints,a0
	move.l	$70.w,(a0)+
	move.l	$120.w,(a0)+
	move.b	$fffffa07,(a0)+
	move.b	$fffffa09,(a0)+
	move.b	$fffffa0f,(a0)+
	move.b	$fffffa11,(a0)+
	move.b	$fffffa1b,(a0)+
	andi.b	#$df,$fffa09
	andi.b	#$fe,$fffa07
	move.l	#playf,$120
	move.l	#vbl,$70
	ori.b	#1,$fffffa07
	ori.b	#1,$fffffa13
	move	#$2300,sr
	rts

ints	ds.l	1
	ds.b	6

* Restore interrupts

retints	move	#$2700,sr
	lea	ints,a0
	move.l	(a0)+,$70.w
	move.l	(a0)+,$120.w
	move.b	(a0)+,$fffffa07
	move.b	(a0)+,$fffffa09
	move.b	(a0)+,$fffffa0f
	move.b	(a0)+,$fffffa11
	move.b	(a0)+,$fffffa1b
	move	#$2300,sr
	rts

* Vbl rout

vbl	move	#$2700,sr
	movem.l	d0-d2/a0-a3,-(sp)
	move.l	start_patt,a6
	lea	$fffffa1b.w,a0
	lea	$fffffa21.w,a1
	clr.b	(a0)
	move.l	wavtop,a0
	move.b	(a0)+,d0
	cmp.b	#$ff,d0
	beq.s	.wrst
.next	move.l	a0,wavtop
	move.l	a0,wavptr
	move.b	#10,(a1)
	move.b	#8,$fffffa1b
	bsr	music+8
	move	#$2300,sr
	bsr	getvol
	bsr	make_pattern
	movem.l	(sp)+,d0-d2/a0-a3
	rte
.wrst	lea	wavdat,a0
	bra.s	.next

start_patt	dc.l	pldat

getvol	lea	$ffff8800.w,a1		Hello soundchip!
	moveq	#0,d0			Clear d0 of any strange values
	move.l	d0,d1			      d1	
	move.l	d0,d2			      d2
	move.b	#8,(a1)			Get vol of channel A
	move.b	(a1),d0			(Now in d0)
	move.b	#9,(a1)					   B
	move.b	(a1),d1			(Now in d1)
	move.b	#10,(a1)				   C
	move.b	(a1),d2			(Now in d2)
.env1	btst	#4,d0			Bit 4 (envelope) set?
	beq	.env2			No, try channel B
	move.b	#10,d0			Ah hell, vol 10 assumed then!
.env2	btst	#4,d1			Bit 4 (envelope) set?
	beq	.env3			No, try channel C
	move.b	#10,d1			Ah hell, vol 10 assumed then!
.env3	btst	#4,d2			Bit 4 (envelope) set?
	beq	zap			No, well that's that then.
	move.b	#10,d2			Ah hell, vol 10 assumed then!
zap	bclr	#0,d0
	bclr	#0,d1
	bclr	#0,d2
	move.l	volcol,a0
	movea.l	4(a0),a1
	movea.l	8(a0),a2
	movea.l	12(a0),a3
	movea.l	(a0),a0
	move	(a0,d0.w),2(a3)		col1
	move	(a1,d1.w),4(a3)		col2
	move	(a2,d2.w),6(a3)		col3
	rts

volcol	dc.l	playf1

playf1	dc.l	pf1R,pf1G,pf1B,palette1

pf1R	dc.w	0,$100,$200,$300,$400,$500,$600,$700
pf1G	dc.w	0,$10,$20,$30,$40,$50,$60,$70
pf1B	dc.w	0,$11,$22,$33,$44,$55,$66,$77

* Playfield scanline rout- uses a6 for address of pattern line
;				d4-d7 for colours!!

playf	movem.l	(a6)+,d4-d7
ps	jmp	norm0
norm0	movem.l	d4/d5/d6/d7,$ffff8250.w		0 pixel offset
	bra.s	fini
norm1	movem.l	d4/d5/d6/d7,$ffff8252.w		1 pixel offset
	move	d7,$ffff8250.w
	bra.s	fini
norm2	move.l	d7,$ffff8250.w			2 pixel offset
	movem.l	d4/d5/d6,$ffff8254.w
	bra.s	fini
norm3	move.l	d7,$ffff8252.w			3 pixel offset
	movem.l	d4/d5,$ffff8256.w	
	swap	d6
	move	d6,$ffff8256+8.w
	swap	d6
	move	d6,$ffff8250
	bra.s	fini
norm4	movem.l	d6/d7,$ffff8250.w		4 pixel offset
	movem.l	d4/d5,$ffff8258.w
	bra.s	fini
norm5	movem.l	d6/d7,$ffff8252.w		5 pixel offset
	move.l	d4,$ffff825a.w
	swap	d5
	move	d5,$ffff825e.w
	swap	d5
	move	d5,$ffff8250
	bra.s	fini
norm6	movem.l	d5/d6/d7,$ffff8250.w		6 pixel offset
	move.l	d4,$ffff8250+(2*6).w
	bra.s	fini
norm7	movem.l	d5/d6/d7,$ffff8252.w		7 pixel offset
	swap	d4
	move	d4,$ffff8252+(2*6).w
	swap	d4
	move	d4,$ffff8250
fini	clr.b	$fffffa1b.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	movem.l	d0/a0,-(sp)
	move	(a6),d0
	cmp	#$ffff,d0
	beq.s	.rst
.next	moveq	#0,d0
	move.l	wavptr,a0
	move.b	(a0)+,d0
	cmp.b	#$ff,d0
	beq.s	.wrst
.jmptab	move.l	a0,wavptr
	lsl	#2,d0
	lea	wavetab,a0
	move.l	(a0,d0.w),ps+2
.bye	movem.l	(sp)+,d0/a0
	bclr    #0,$fffffa0f.w		end of interrupt
	rte
.rst	lea	pldat,a6
	bra.s	.next
.wrst	move.l	#wavdat,wavptr
	bra.s	.next

wavptr	dc.l	wavdat
wavtop	dc.l	wavdat
wavdat	incbin	a:\graphics.dat\playf.wav
wend	dc.b	$ff

	even
wavetab	dc.l	norm0,norm1,norm2,norm3,norm4,norm5,norm6,norm7

music	incbin	agrajag1.thk

end_code

