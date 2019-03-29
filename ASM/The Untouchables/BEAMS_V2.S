;-----------------------------------------------------------------------------
; Mega cool raster beams v1.1
; The routine i supplied last time wasn't very well documented and wasn't
; that great either, here is a better example with comments!
;
; Colors are simply copied from a palette into the border, using a given
; offset to create movement, no actual graphic movement is necessary, and
; the result is quite fantastic!!! Of course you needn't do beams at all..
; remember the Color Shock in Syntax Terror?? It's really very simple, you
; simply set up a large palette of colors and shift them around in the vbi,
; using pointers as offsets from the start of the palette, and then copy
; say 220 lines of colors from this pointer in the palette using the hbl!
;
; Programmed by Tony B!
; Devpac v2.25, tabs =10
;-----------------------------------------------------------------------------


	movea.l	4(sp),a5
	pea	$200.w
	pea	(a5)
	pea	$4a0000
	trap	#1
	lea	$c(sp),sp

	pea	0.w
	move	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,oldstk
	
	clr	-(sp)		;hit low res & clr screen
	pea	-1.w
	pea	-1.w
	move	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	move.b	#$12,$fffffc02.w	;mouse off
	
	bsr	set_ints		;save/install interrupts

*---------
scan	bsr	sync

	cmp.b	#$39,$fffffc02.w	;'space'
	bne.s	scan
*---------

	bsr	rem_ints		;remove interrupts
	
	move	#$777,$ffff8240.w
	move.b	#8,$fffffc02.w	;mouse on

	move.l	oldstk(pc),-(sp)
	move	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	clr	-(sp)
	trap	#1


*---------wait for vbi
sync	move	d0,-(sp)
	move	$468.w,d0
.sync	cmp	$468.w,d0
	beq.s	.sync
	move	(sp)+,d0
	rts

*---------clear keyboard!
key_handler
	move	#$2500,sr
	move.b	$fffffc02.w,key
	rte


*---------
my_vbl	clr.b	$fffffa1b.w
	move.b	#1,$fffffa21.w	;start timer B
	move.l	#timer_b,$120.w
	move.b	#8,$fffffa1b.w

	addq	#2,offset1	;offset into color palette
	cmp	#400,offset1	;for 1st beam
	blt.s	next1
	clr	offset1
	
next1	subq	#2,offset2	;offset into color palette
	tst	offset2		;for 2nd beam
	bpl.s	next2
	move	#300,offset2

next2	addq	#2,offset3	;offset into color palette
	cmp	#400,offset3	;for 3rd beam
	blt.s	next3
	move	#100,offset3

next3	subq	#2,offset4	;offset into color palette
	cmp	#100,offset4	;for 4th beam
	bpl.s	next4
	move	#400,offset4

next4	addq	#2,offset5	;offset into color palette
	cmp	#400,offset5	;for 5th beam
	blt.s	next5
	clr	offset5
	
next5	subq	#2,offset6	;offset into color palette
	tst	offset6		;for 6th beam
	bpl.s	next6
	move	#300,offset6

next6	addq	#2,offset7	;offset into color palette
	cmp	#400,offset7	;for 7th beam
	blt.s	next7
	move	#100,offset7

next7	subq	#2,offset8	;offset into color palette
	cmp	#100,offset8	;for 8th beam
	bpl.s	next8
	move	#400,offset8

next8	addq	#2,offset9	;offset into color palette
	cmp	#400,offset9	;for 9th beam
	blt.s	next9
	move	#20,offset9

next9	subq	#2,offset10	;offset into color palette
	tst	offset10		;for 10th beam
	bpl.s	next10
	move	#360,offset10

next10
	addq	#1,$468.w
	rte


*---------1st timer B
timer_b	clr.b	$fffffa1b.w	;stop timer B
	move	#$2700,sr

	movem.l	d0/a0-a2,-(sp)
	
	lea	beam(pc),a0	;get addr of colors
	adda	offset1(pc),a0	;new col addr
	lea	$ffff8240.w,a1	;addr of border col
	
	lea	sync_in(pc),a2	;wait till start of next
	moveq	#0,d0		;scanline
wait_up	tst.b	$ffff8209.w
	beq.s	wait_up
	move.b	$ffff8209.w,d0
	adda	d0,a2
	jmp	(a2)		;synchronize!
	
sync_in	dcb.w	171,$4e71
	
	rept	42		;put 42 colors into the border
	move	(a0)+,(a1)	;on 1 scanline
	endr
	
	clr	(a1)		;clear border
	movem.l	(sp)+,d0/a0-a2
	
	clr.b	$fffffa1b.w
	move.l	#timer_b2,$120.w	;next raster beam
	move.b	#20,$fffffa21.w
	move.b	#8,$fffffa1b.w	;start timer B
	rte

*---------second beam!!
timer_b2	clr.b	$fffffa1b.w
	pea	(a0)		;faster than movem.l
	pea	(a1)
	
	lea	beam(pc),a0
	adda	offset2(pc),a0
	lea	$ffff8240.w,a1
	
	rept	42		; put 42 cols: width of screen
	move	(a0)+,(a1)
	endr
	
	clr	(a1)		;make black again
	move.l	(sp)+,a1
	move.l	(sp)+,a0
	move.l	#timer_b3,$120.w	;next raster beam
	move.b	#20,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte

*---------3rd
timer_b3	clr.b	$fffffa1b.w
	pea	(a0)		;faster than movem.l
	pea	(a1)
	
	lea	beam(pc),a0
	adda	offset3(pc),a0
	lea	$ffff8240.w,a1
	
	rept	42		; put 42 cols: width of screen
	move	(a0)+,(a1)
	endr
	
	clr	(a1)
	move.l	(sp)+,a1
	move.l	(sp)+,a0
	move.l	#timer_b4,$120.w	;next raster beam
	move.b	#20,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte

*---------4th beam
timer_b4	clr.b	$fffffa1b.w
	pea	(a0)		;faster than movem.l
	pea	(a1)
	
	lea	beam(pc),a0
	adda	offset4(pc),a0
	lea	$ffff8240.w,a1
	
	rept	42		; put 42 cols: width of screen
	move	(a0)+,(a1)
	endr
	
	clr	(a1)
	move.l	(sp)+,a1
	move.l	(sp)+,a0
	move.l	#timer_b5,$120.w	;next raster beam
	move.b	#20,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte

*---------5th beam
timer_b5	clr.b	$fffffa1b.w
	pea	(a0)		;faster than movem.l
	pea	(a1)
	
	lea	beam(pc),a0
	adda	offset5(pc),a0
	lea	$ffff8240.w,a1
	
	rept	42		; put 42 cols: width of screen
	move	(a0)+,(a1)
	endr
	
	clr	(a1)
	move.l	(sp)+,a1
	move.l	(sp)+,a0
	move.l	#timer_b6,$120.w	;next raster beam
	move.b	#20,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte

*---------6th beam
timer_b6	clr.b	$fffffa1b.w
	pea	(a0)		;faster than movem.l
	pea	(a1)
	
	lea	beam(pc),a0
	adda	offset6(pc),a0
	lea	$ffff8240.w,a1
	
	rept	42		; put 42 cols: width of screen
	move	(a0)+,(a1)
	endr
	
	clr	(a1)
	move.l	(sp)+,a1
	move.l	(sp)+,a0
	move.l	#timer_b7,$120.w	;next raster beam
	move.b	#20,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte

*---------7th beam
timer_b7	clr.b	$fffffa1b.w
	pea	(a0)		;faster than movem.l
	pea	(a1)
	
	lea	beam(pc),a0
	adda	offset7(pc),a0
	lea	$ffff8240.w,a1
	
	rept	42		; put 42 cols: width of screen
	move	(a0)+,(a1)
	endr
	
	clr	(a1)
	move.l	(sp)+,a1
	move.l	(sp)+,a0
	move.l	#timer_b8,$120.w	;next raster beam
	move.b	#20,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte

*---------8th beam
timer_b8	clr.b	$fffffa1b.w
	pea	(a0)		;faster than movem.l
	pea	(a1)
	
	lea	beam(pc),a0
	adda	offset8(pc),a0
	lea	$ffff8240.w,a1
	
	rept	42		; put 42 cols: width of screen
	move	(a0)+,(a1)
	endr
	
	clr	(a1)
	move.l	(sp)+,a1
	move.l	(sp)+,a0
	move.l	#timer_b9,$120.w	;next raster beam
	move.b	#20,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte

*---------9th beam
timer_b9	clr.b	$fffffa1b.w
	pea	(a0)		;faster than movem.l
	pea	(a1)
	
	lea	beam(pc),a0
	adda	offset9(pc),a0
	lea	$ffff8240.w,a1
	
	rept	42		; put 42 cols: width of screen
	move	(a0)+,(a1)
	endr
	
	clr	(a1)
	move.l	(sp)+,a1
	move.l	(sp)+,a0
	move.l	#timer_b10,$120.w	;next raster beam
	move.b	#20,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte

*---------10th beam
timer_b10	clr.b	$fffffa1b.w
	pea	(a0)		;faster than movem.l
	pea	(a1)
	
	lea	beam(pc),a0
	adda	offset10(pc),a0
	lea	$ffff8240.w,a1
	
	rept	42		; put 42 cols: width of screen
	move	(a0)+,(a1)
	endr
	
	clr	(a1)
	move.l	(sp)+,a1
	move.l	(sp)+,a0
	rte


*---------
set_ints	move	#$2700,sr
	clr.b	$fffffa07.w
	clr.b	$fffffa09.w
	move.l	#key_handler,$118.w
	move.l	#timer_b,$120.w
	move.l	#my_vbl,$70.w
	bclr	#3,$fffffa17.w
	bset	#0,$fffffa07.w
	bset	#0,$fffffa13.w
	bset	#6,$fffffa09.w
	bset	#6,$fffffa15.w
	move	#$2300,sr
	rts

*---------
rem_ints	move	#$2700,sr
	move.b	#$1e,$fffffa07.w
	move.b	#$64,$fffffa09.w
	move.b	#$1e,$fffffa13.w
	move.l	#$fc06de,$70.w
	move.l	#$e5f0e044,$120.w
	move.l	#$fc29ce,$118.w
	move	#$2300,sr
	rts

 
*---------
 	data
 
key	dc.b	0

oldstk	ds.l	1

* offsets for each beam, each one is an offset from 'beam', and then
* is either added to or subtracted from to give movement of a bar (beam)!
offset1	dc.w	0
offset2	dc.w	260
offset3	dc.w	100
offset4	dc.w	400
offset5	dc.w	200
offset6	dc.w	0
offset7	dc.w	220
offset8	dc.w	20
offset9	dc.w	20
offset10	dc.w	360

beam	dcb.w	100,0
	dc.w	$101,$111,$221,$321,$421
	dc.w	$431,$431,$431,$432,$432,$432,$433,$433,$433,$434,$434,$434,$435,$435,$435,$436,$436,$436,$437,$437,$437,$436,$436,$436,$435,$435,$435,$434,$434,$434,$433,$433,$433,$432,$432,$432,$431,$431,$431
	dc.w	$421,$321,$221,$111,$101
	dcb.w	100,0
