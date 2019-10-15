hdv_bpb		= $472	* getbpb-Vektor
hdv_rw		= $476	* RWABS-Vektor
hdv_mediach	= $47e	* Mediach-Vektor
drvbits		= $4c2

secs		= 1024	* = 512 KB
groesse		= (secs+18)*512
ramdrv		= 15	*  P:

start:
	move.l	sp,a5
	move.l	4(a5),a5
	move.l	12(a5),d0
	add.l	20(a5),d0
	add.l	28(a5),d0
	add.l	#$400,d0

	move.l	d0,d1
	add.l	a5,d1
	and.l	#-2,d1
	move.l	d1,sp
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	lea		12(sp),sp

	moveq	#0,d0
	bsr		super
	move.l	d0,save_ssp
	bsr		init
	bmi		raushier
	move.l	save_ssp,d0
	bsr		super
	move.w	#0,-(sp)
	move.l	#ende-start+groesse,-(sp)
	move.w	#49,-(sp)
	trap	#1

raushier:
	move.l	o_rw,hdv_rw
	move.l	o_bpb,hdv_bpb
	move.l	o_media,hdv_mediach

	move.l	drvbits,d0
	move.w	#ramdrv,d1
	beq		exitus
	bclr	d1,d0
	move.l	d0,drvbits
exitus:
	move.l	save_ssp,d0
	bsr		super
	pea		fehler
	move	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	clr.w	-(sp)
	trap	#1


super:
	move.l	d0,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts


init:
	move.l	hdv_bpb,o_bpb
	move.l	#mybpb,hdv_bpb

	move.l	hdv_rw,o_rw
	move.l	#myrwabs,hdv_rw
	move.l	hdv_mediach,o_media
	move.l	#mymedia,hdv_mediach

	move.l	#groesse,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
	tst.l	d0
	beq		error
	move.l	d0,puffer

	move.l	d0,a0
	move.w	#18*4-1,d0
	moveq.l	#0,d1
	moveq.l	#0,d2
	moveq.l	#0,d3
	moveq.l	#0,d4
	moveq.l	#0,d5
	moveq.l	#0,d6
	moveq.l	#0,d7
	move.l	d1,a1
clearit:
	movem.l	d1-d7/a1,(a0)	* clear 32 Byte
	movem.l	d1-d7/a1,32(a0)	* clear 32 Byte
	movem.l	d1-d7/a1,64(a0)	* clear 32 Byte
	movem.l	d1-d7/a1,96(a0)	* clear 32 Byte
	lea		128(a0),a0
	dbf		d0,clearit		* clear 128 Byte

	move.l	drvbits,d0
	btst	#ramdrv,d0
	bne		error
	bset	#ramdrv,d0
	move.l	d0,drvbits

	pea		drivemsg
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	moveq.l	#0,d0
	rts

error:
	moveq	#-1,d0
	rts


* mybpb
	dc.b	"XBRA"
	dc.b	"TOSD"
o_bpb:
	dc.l	0

mybpb:
	move.w	#ramdrv,d0
	cmp.w	4(sp),d0
	beq		newbpb
	move.l	o_bpb,a0
	jmp		(a0)
newbpb:
	move.l	#protobpb,d0
	rts


* myrwabs
	dc.b	"XBRA"
	dc.b	"TOSD"
o_rw:
	dc.l	0

myrwabs:
	move	#ramdrv,d0
	cmp.w	14(sp),d0
	beq		newrw
	move.l	o_rw,a0
	jmp		(a0)
newrw:
	moveq	#0,d0
	move.w	12(sp),d0
	lsl.l	#8,d0
	lsl.l	#1,d0		* offset
	move.l	6(sp),a0
	move.w	10(sp),d1	* seccnt
	subq.w	#1,d1
	move.l	puffer,a1
	add.l	d0,a1
	move.w	4(sp),d0	* rw-flag
	btst	#0,d0
	beq		copysec
	exg		a0,a1
copysec:
	move.l	a0,d0
	btst	#0,d0
	bne		ungerade
	move.l	a1,d0
	btst	#0,d0
	bne		ungerade

	movem.l	d2-d7/a2-a6,-(sp)
gerade:
	movem.l	(a1)+,d2-d7/a2-a6	* 44 Byte
	movem.l	d2-d7/a2-a6,0*44(a0)
	movem.l	(a1)+,d2-d7/a2-a6	* 44 Byte
	movem.l	d2-d7/a2-a6,1*44(a0)
	movem.l	(a1)+,d2-d7/a2-a6	* 44 Byte
	movem.l	d2-d7/a2-a6,2*44(a0)
	movem.l	(a1)+,d2-d7/a2-a6	* 44 Byte
	movem.l	d2-d7/a2-a6,3*44(a0)
	movem.l	(a1)+,d2-d7/a2-a6	* 44 Byte
	movem.l	d2-d7/a2-a6,4*44(a0)
	movem.l	(a1)+,d2-d7/a2-a6	* 44 Byte
	movem.l	d2-d7/a2-a6,5*44(a0)
	movem.l	(a1)+,d2-d7/a2-a6	* 44 Byte
	movem.l	d2-d7/a2-a6,6*44(a0)
	movem.l	(a1)+,d2-d7/a2-a6	* 44 Byte
	movem.l	d2-d7/a2-a6,7*44(a0)
	movem.l	(a1)+,d2-d7/a2-a6	* 44 Byte
	movem.l	d2-d7/a2-a6,8*44(a0)
	movem.l	(a1)+,d2-d7/a2-a6	* 44 Byte
	movem.l	d2-d7/a2-a6,9*44(a0)
	movem.l	(a1)+,d2-d7/a2-a6	* 44 Byte
	movem.l	d2-d7/a2-a6,10*44(a0)
	movem.l	(a1)+,d2-d7/a2		* 28 Byte
	movem.l	d2-d7/a2,11*44(a0)
	lea		512(a0),a0
	dbf		d1,gerade
	movem.l	(sp)+,d2-d7/a2-a6
	moveq	#0,d0
	rts

ungerade:
	moveq	#512/16-1,d0
cplp:
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	dbf		d0,cplp
	dbf		d1,ungerade
	moveq	#0,d0
	rts

* mymedia
	dc.b	"XBRA"
	dc.b	"TOSD"
o_media:
	dc.l	0
mymedia:
	move.w	#ramdrv,d0
	cmp.w	4(sp),d0
	beq		newmedia
	move.l	o_media,a0
	jmp		(a0)
newmedia:
	moveq	#0,d0
	rts


puffer:
	.dc.l	0

protobpb:
	.dc.w	512
	.dc.w	2
	.dc.w	1024
	.dc.w	7
	.dc.w	5
	.dc.w	6
	.dc.w	18
	.dc.w	secs/2
	.dc.w	0
	.dc.l	0

save_ssp:
	.dc.l	0
fehler:
	.dc.b	13,10,7,"Fehler beim Installieren!",13,10,0
drivemsg:
	.dc.b	13,10,7,"RAM-Disk als Laufwerk P: installiert.",13,10,0

.even
.dc.w	0
ende:
