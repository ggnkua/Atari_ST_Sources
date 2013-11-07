	opt	x-
	output	a:\auto\loader.prg
	bra	proggy
	include	d:\stlibs\readfile.s
	include	e:\cruncher\dechomp.s
name	dc.b	'bike.crn',0
pic	dc.b	'loadscrn.neo',0
proggy	lea	pic,a0
	lea	end,a1
	move.l	#32128,d0
	bsr	read_file
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	move.l	d0,2(sp)

	lea	end+4,a0	Palette
	lea	$ffff8240.w,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)

	move.w	#2,-(sp)
	trap	#14
	addq.w	#2,sp
	lea	end+128,a0	Picture
	move.l	d0,a1
	move.w	#3999,d0
.0	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,.0

	trap	#1
	addq.w	#6,sp
;Load game code
	lea	name,a0
	lea	$10000,a1
	move.l	#1000000,d0
	bsr	read_file
	lea	$10000,a0
	lea	$10000,a1
	bsr	unpack
	jmp	$10000.l

end	dc.b	0
