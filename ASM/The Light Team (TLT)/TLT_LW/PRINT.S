; Test print routine

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	lea	6(sp),sp
	move.l	d0,super
	
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,palsave
	clr.w	$ffff8240.w
	move.w	#$777,$ffff8242.w
	
	moveq	#1,d0
	jsr	music
	move.l	#music+4,$4d2
	
	clr.w	-(sp)
	pea	$f8000
	pea	$f8000
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	
	move.w	#2,-(sp)
	trap	#14
	lea	2(sp),sp
	move.l	d0,screen
	
	move.w	#0,d0		; X-pos
	move.w	#2,d1		; Y-pos
	move.b	#'Z',d2
	bsr 	print
	move.w	#1,d0		; X-pos
	move.w	#2,d1		; Y-pos
	move.b	#'B',d2
	bsr 	print
	
	move.w	#7,-(sp)
	trap	#1
	lea	2(sp),sp
	
	clr.l	$4d2
	
	lea	$ffff8800.w,a0
	move.b	#$8,(a0)
	clr.b	2(a0)
	move.b	#$9,(a0)
	clr.b	2(a0)
	move.b	#$a,(a0)
	clr.b	2(a0)
	
	movem.l	palsave,d0-d7
	movem.l	d0-d7,$ffff8240.w
	
	move.l	super,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	lea	6(sp),sp
	
	clr.w	-(sp)
	trap	#1

print:
	and.l	#$ffff,d0
 	and.l	#$ffff,d1
	and.l	#$ff,d2
	moveq	#0,d3
	
	move.w	d0,d3
	lsl.w	#2,d3		; multiply by 4 instead of ^
	and.w	#1,d0
	add.w	d3,d0		; odd offset + block no. = X-offset
	mulu.w	#8*160,d1	; Y-offset

	lea	font,a0
	sub.b	#32,d2
	mulu	#8,d2
	adda.l	d2,a0
	move.l	screen,a1
	add.w	d1,a1
	add.w	d0,a1
	moveq	#8-1,d7
copy:	move.b	(a0)+,(a1)
*	not.b	(a1)
	lea	160(a1),a1
	dbra	d7,copy
	rts
	
screen:		dc.l	0
super:		dc.l	0
font:		incbin	letter5.fnt
	even
music:		incbin	e:\zsource.s\mwond91\offbeat\omega.mus
	even
	
	section bss
	
palsave:	ds.w	16
	end