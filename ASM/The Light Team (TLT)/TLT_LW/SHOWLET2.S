; TLT-Letterwriter v0.25 -  Coded by Zaphod/TLT in 1991......

	opt 	d+
	
	dc.w	$a000
	dc.w	$a00a
		
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

	clr.w	-(sp)
	pea	filename
	move.w	#$3d,-(sp)
	trap	#1
	lea	8(sp),sp
	move.w	d0,handle
	
	pea	temp
	move.l	#10000,-(sp)
	move.w	handle,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	lea	12(sp),sp
	
	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	lea	4(sp),sp
	
	clr.w	xpos
	clr.w	ypos
	lea	temp,a6
	
loopy:
	bsr	sync
	clr.l	d0
	move.b	(a6)+,d7
	tst.w	d7
	beq	exit
	
	cmp.b	#$0,d7
	beq	exit
	cmp.b	#$1,d7
	bne	notup
	cmp.w	#0,ypos
	ble	notup
	sub.w	#1,ypos
	
notup:
	cmp.b	#$2,d7
	bne	notdown
	cmp.w	#24,ypos
	bge	notdown
	add.w	#1,ypos
	
notdown:
	cmp.b	#$3,d7
	bne	notleft
	cmp.w	#0,xpos
	ble	notleft
	sub.w	#1,xpos
	
notleft:
	cmp.b	#$4,d7
	bne	notright
	cmp.w	#39,xpos
	bge	notright
	add.w	#1,xpos
	
notright:
	cmp.b	#$a,d7
	bne	notlf
	cmp.w	#24,ypos
	ble	noscroll
*	bsr	scroll
noscroll:
	clr.w	xpos
	addq.w	#1,ypos
notlf:
	cmp.b	#$11,d7
	bne	notinv
	move.w	#1,inverse
notinv:
	cmp.b	#$12,d7
	bne	notnotinv
	clr.w	inverse
notnotinv:
	cmp.b	#$8,d7
	bne	nodel
	cmp.w	#$0,xpos
	ble	nodel
	sub.w	#1,xpos
nodel:
	move.w	xpos,d0
	move.w	ypos,d1
	move.w	d7,d2
	bsr	print
	bra	loopy
	
exit:
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
	
	dc.w	$a009
	
	clr.w	-(sp)
	trap	#1

sync:
	move.w	syncno,d7
sync2:
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#37,-(sp)
	trap	#14
	lea	2(sp),sp
	movem.l	(sp)+,d0-d7/a0-a6
	dbra	d7,sync2
	rts

print:
	and.l	#$ffff,d0
 	and.l	#$ffff,d1
	and.l	#$ff,d2
	moveq	#0,d3
	cmp.b	#$20,d2
	blt	noprint
	cmp.b	#$7f,d2
	bgt	noprint
	
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
	tst.w	inverse
	beq	notinv2
	not.b	(a1)
notinv2:
	lea	160(a1),a1
	dbra	d7,copy
	addq.w	#1,xpos
noprint:
	rts
	
filename:	dc.b 'LETT40.TXT',0
	even
handle:		dc.w	0
bytez:		dc.l	0
super:		dc.l	0
syncno:		dc.w	4
screen:		dc.l	0
xpos:		dc.w	0
ypos:		dc.w	0
inverse:	dc.w	0
font:		incbin	letter5.fnt
	even
music:		incbin	sanxmix.mus
	even
	
	section bss
	
palsave:	ds.w	16
temp:		ds.b 	50000
	end
