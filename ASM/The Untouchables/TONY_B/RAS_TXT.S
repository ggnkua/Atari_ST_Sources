;-----------------------------------------------------------------------------
; Show text as raster bar passes over!
; Programmed by Tony -B-
; Hit ESCape to exit!
;-----------------------------------------------------------------------------


	movea.l	4(sp),a5
	pea	$200.w
	pea	(a5)
	pea	$4a0000
	trap	#1
	lea	$c(sp),sp


	clr	-(sp)
	pea	-1.w
	pea	-1.w
	move	#5,-(sp)
	trap	#14
	add.l	#12,sp

	pea	0.w
	move	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	
	clr	$ffff8240.w
	clr	$ffff825e.w
	
	pea	inf(pc)
	move	#9,-(sp)
	trap	#1
	addq.l	#6,sp


*---------set ints
	move.b	$fffffa07.w,mfp7+3
	move.b	$fffffa09.w,mfp9+3
	move.b	$fffffa13.w,mfp13+3
	move.l	$70.w,oldvbl+2
	move.l	$120.w,oldhbl+2
	clr.b	$fffffa07.w
	clr.b	$fffffa09.w
	move.l	#vbi,$70.w
	move.l	#timer_b,$120.w
	bset	#0,$fffffa07.w
	bset	#0,$fffffa13.w

	
wait	stop	#$2300
	cmp.b	#57,$fffffc02.w	;space
	bne.s	wait2
	
	st	direc
	sf	endflag
	
wait2	cmp.b	#1,$fffffc02.w	;ESC
	bne.s	wait
	


*---------ret ints.
mfp7	move.b	#0,$fffffa07.w
mfp9	move.b	#0,$fffffa09.w
mfp13	move.b	#0,$fffffa13.w
oldhbl	move.l	#0,$120.w
oldvbl	move.l	#0,$70.w
	
	move	#$777,$ffff8240.w
	
	clr	-(sp)
	trap	#1


*---------
vbi	clr.b	$fffffa1b.w

	tst.b	direc		;going up?
	beq.s	down

	tst.b	endflag		;top of screen yet?
	bne.s	no_change
	
	subq.b	#1,scanline+3	;go up a scanline
	cmp.b	#1,scanline+3
	bne.s	no_change
	
	st	endflag
	
down	tst.b	endflag		;bottom of screen yet?
	bne.s	no_change
	
	addq.b	#1,scanline+3	;go down a scanline
	cmp.b	#198,scanline+3
	bne.s	no_change
	
	st	endflag
	
no_change:

scanline	move.b	#0,$fffffa21.w

	move	#$471,$ffff825e.w
	
	move.b	#8,$fffffa1b.w
	rte

*---------
timer_b	clr.b	$fffffa1b.w
	move	d0,-(sp)
	
	move.b	#200,$fffffa21.w
	move.b	#8,$fffffa1b.w

	move.b	$fffffa21.w,d0	;wait for new scanline
sync_in	cmp.b	$fffffa21.w,d0
	beq.s	sync_in
	
	dcb.w	6,$4e71		;prevent flicker
	move	#$547,$ffff8240.w	;set border color
	
	move.b	$fffffa21.w,d0	;wait for new scanline
.sync_in	cmp.b	$fffffa21.w,d0
	beq.s	.sync_in

	clr	$ffff825e.w
	clr	$ffff8240.w
	
	move	(sp)+,d0
	bclr	#0,$fffffa0f.w
	rte


*---------
	data
direc	dc.b	0
endflag	dc.b	0
	even

inf	dc.b	13,10
	dc.b	"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",10,13
	rept	22
	dc.b	"|                                      |",10,13
	endr
	dc.b	"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	dc.b	27,89,32+3,32+11
	dc.b	"Raster 'n' Text !!"
	dc.b	27,89,32+4,32+11
	dc.b	"------------------"
	dc.b	27,89,32+9,32+10
	dc.b	"Coded by Stormlord !"
	dc.b	27,89,32+12,32+13
	dc.b	"(aka Tony -B-)"
	dc.b	27,89,32+18,32+9
	dc.b	"So why not hit space!?"
	dc.b	27,89,32+22,32+18
	dc.b	"_oOo_"
	dc.b	0
