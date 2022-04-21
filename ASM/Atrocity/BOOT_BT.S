less	=	$1e	;0 = 512 Kb	1e = 482 Kb  Juste sur prog Boot
	move.w	#1,-(a7)
	clr.w	-(a7)
	move.w	#0,-(a7)
	move.w	#1,-(a7)
	clr.w	-(a7)
	clr.l	-(a7)
	pea	boot
	move.w	#8,-(a7)
	trap	#14
	adda.l	#20,a7
	move.w	#$0,-(a7)
	move.l	#filename,-(a7)
	move.w	#$3c,-(a7)
	trap	#1
	adda.l	#8,a7
	tst	d0
	bmi	end
	pea	boot+less
	move.w	d0,handle
	move.l	#$200-less,-(a7)
	move.w	handle,-(a7)
	move.w	#$40,-(a7)
	trap	#1
	adda.l	#12,a7
	move.w	handle,-(a7)
	move.w	#$3e,-(a7)
	trap	#1
	addq.l	#4,a7
end:	clr.w	-(a7)
	trap	#1
	
	section	data
filename:	dc.b		'a:\data\work\boot.bt',0
	section	bss
handle:
	ds.l	1
boot:
	ds.b	512
