*********************************************************
*			AutoAVS program			*
*			---------------			*
*							*
* Demo: WALKER 1					*
*							*
* Auto running AVS sequence so no user intervention	*
*							*
*********************************************************
	opt	o+,w+


	SECTION	TEXT

start
	bra.s	.code
	dc.b	'<AUTOAVS Version 1.0 (C) 1991'
	dc.b	' Boris & MAC SYS DATA >'
	even
.code
	move.l	sp,a5
	lea	stack(pc),sp
	move.l	4(a5),a5
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$100,d0
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	d0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#12,sp

	dc.w	$a00a
	pea	pal1
	move.w	#6,-(sp)
	trap	#14
	addq.l	#6,sp

	clr.w	-(sp)
	move.l	#-1,-(sp)
	move.l	(sp),-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	pea	message
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	dc.w	$a00a

	move.w	#30000,d7
.loop	move.w	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	tst.l	d0
	bmi.s	.yes
	dbf	d7,.loop
	bra.s	.no
.yes	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
.no	pea	cls
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	pea	null		;run advert program
	pea	null
	pea	advert
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	add.l	#16,sp

	pea	pal2		;reset pal
	move.w	#6,-(sp)
	trap	#14
	addq.l	#6,sp

	move.w	#1,-(sp)	;medium rez
	move.l	#-1,-(sp)
	move.l	(sp),-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	pea	revector(pc)	;install trap 1 and 2 fix
	move.w	#38,-(sp)
	trap	#14
	addq.w	#6,sp

	clr.l	-(sp)		;run PACK program
	pea	com_tail(pc)
	pea	filename
	clr.w	-(sp)
	move.w	#75,-(sp)
	trap	#1
	add.w	#16,sp
.exit	clr.w	-(sp)
	trap	#1


***************
* Subroutines *
***************

revector
	move.w	sr,-(sp)
	or.w	#$700,sr
	move.l	$84.w,old_trap1
	move.l	$88.w,old_trap2
	move.l	#new_trap1,$84.w
	move.l	#new_trap2,$88.w
	move.w	(sp)+,sr
	rts


new_trap1			;checks for key input
	move.l	a0,-(sp)
	move.l	usp,a0
	cmp.w	#11,(a0)
	beq.s	.check
	cmp.w	#7,(a0)
	beq.s	.return
	move.l	(sp)+,a0
	move.l	old_trap1,-(sp)
	rts
.check	moveq	#-1,d0
	move.l	(sp)+,a0
	rte
.return	move.w	key,d0
	cmp.w	#13,key
	beq.s	.restore
	move.w	#13,key
	move.l	(sp)+,a0
	rte
.restore
	move.l	old_trap1,$84.w
	move.l	(sp)+,a0
	rte

new_trap2			;checks for F_SEL to frig AVS filename
	cmp.w	#$c8,d0
	bne.s	.exit
	movem.l	a0-a1,-(sp)
	move.l	d1,a0
	move.l	(a0),a1
	cmp.w	#90,(a1)
	beq.s	.fsel
	movem.l	(sp)+,a0-a1
.exit	move.l	old_trap2,-(sp)
	rts
.fsel	move.l	12(a0),a1
	move.l	#$10001,(a1)
	move.l	16(a0),a1
	move.l	4(a1),a1
	lea	avs_name(pc),a0
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	movem.l	(sp)+,a0-a1
	move.l	old_trap2,$88.w
	rte


reset	move.l	$4.w,-(sp)
	rts


get_type
	move.w	$200.w,(a6)
	rts

********************
* Initialised data *
********************

	SECTION	DATA

key	dc.w	'l'		;key sequence for first request - LOAD

avs_name
	dc.b	'WALKER_1.AVS',0	;sequence filename
	even

com_tail
	dc.l	0

filename
	dc.b	'WALKER.___',0		;PACK filename
	even


**********************
* Uninitialised data *
**********************

	SECTION	BSS

old_trap1	ds.l	1
old_trap2	ds.l	1

exec_type	ds.w	1

	SECTION DATA
pal1	dc.w	$000,$200,$300,$400,$500,$600,$700,$135
	dc.w	$246,$457,$047,$057,$067,$660,$770,$777

pal2	dc.w	$000,$700,$070,$777,0,0,0,0,0,0,0,0,0,0,0,0

cls	dc.b	27,'E'
	dc.b	0

	even
message	dc.b	27,'E'
	dc.b	27,'b',14
	dc.b	27,'Y',32+3,32+14,"WALKER DEMO 1"
	dc.b	27,'b',6
	dc.b	27,'Y',32+6,32+11,"Linked with intro"
	dc.b	27,'b',5
	dc.b	27,'Y',32+7,32+2,"Fixed for any drive (even hard discs)"
	dc.b	27,'b',4
	dc.b	27,'Y',32+8,32+10,"Fixed for clean exit"
	dc.b	27,'b',3
	dc.b	27,'Y',32+9,32+9,"and finally packed by"
	dc.b	27,'b',12
	dc.b	27,'Y',32+11,32+14,"MAC SYS DATA"
	dc.b	27,'b',11
	dc.b	27,'Y',32+13,32+19,"of"
	dc.b	27,'b',10
	dc.b	27,'Y',32+15,32+10,"Persistence of Vision"
	dc.b	27,'b',14
	dc.b	27,'Y',32+18,32+3,"Auto running AVS patch routine by"
	dc.b	27,'b',12
	dc.b	27,'Y',32+20,32+9,"MAC SYS DATA and BORIS"
	dc.b	27,'b',15
	dc.b	0
	even

advert	dc.b	"WDT.MSD",0
	even

null	ds.l	0

	ds.b	1000
stack	ds.l	1
