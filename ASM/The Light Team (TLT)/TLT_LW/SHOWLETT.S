; TLT-Letterwriter v0.25 -  Coded by Zaphod/TLT in 1991......

	opt 	d+
	
	dc.w	$a000
	dc.w	$a00a
		
	move.w	#1,-(sp)
	pea	-1
	pea	-1
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	lea	6(sp),sp
	move.l	d0,super
	
	moveq	#1,d0
	jsr	music
	move.l	$70,oldvbl
	lea	exitvbl,a0
	move.l	$70,2(a0)
	move.l	#newvbl,$70

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
	
	lea	pbuf2,a1
	move.w	#$1b65,(a1)+
	move.w	#$0000,(a1)+
	bsr	print
	lea	temp,a0
	
loopy:
	lea	pbuf2,a1
	bsr	sync
	clr.l	d0
	move.b	(a0)+,d0
	tst.w	d0
	beq	exit
	cmp.b	#$1a,d0
	beq	speed
	move.b	d0,(a1)+
	cmp.b	#$1b,d0
	bne	notesc
	move.b	(a0)+,(a1)+
	
notesc:
	move.b	#0,(a1)+
	bsr	print
	bra	loopy
	
speed:
	clr.l	d0
	move.b	(a0)+,d0
	move.w	d0,syncno
	bra	loopy
	
exit:
	move.w	#7,-(sp)
	trap	#1
	lea	2(sp),sp
	
	move.l	oldvbl,$70
	lea	$ffff8800.w,a0
	move.b	#$8,(a0)
	clr.b	2(a0)
	move.b	#$9,(a0)
	clr.b	2(a0)
	move.b	#$a,(a0)
	clr.b	2(a0)
	
	move.l	super,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	lea	6(sp),sp
	
	lea	pbuf2,a1
	move.l	#$1b711b66,(a1)+
	move.w	#$0000,(a1)+
	bsr	print
	
	dc.w	$a009
	
	clr.w	-(sp)
	trap	#1

print:
	movem.l	d0-d7/a0-a6,-(sp)
	pea	pbuf2
	move.w	#9,-(sp)
	trap	#1
	lea	6(sp),sp
	movem.l	(sp)+,d0-d7/a0-a6
	lea	pbuf2,a1
	rts
	
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
	
newvbl:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	music+4
	movem.l	(sp)+,d0-d7/a0-a6
exitvbl:
	jmp	$0
	
pbuf2:		ds.b	80
	even
filename:	dc.b 'LETTER.TXT',0
	even
handle:		dc.w	0
bytez:		dc.l	0
oldvbl:		dc.l	0
super:		dc.l	0
syncno:		dc.w	4
music:		incbin	sanxmix.mus
	even
	
	section bss
	
temp:		ds.b 	50000
	end
