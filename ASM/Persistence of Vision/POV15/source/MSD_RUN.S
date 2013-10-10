***********************************************************************
*         AUTOLOADER TO LOAD A DEMO WITH FILENAME ON SCREEN           *
*         -------------------------------------------------           *
*                                                                     *
* Written by MAC SYS DATA  APRIL '90                                  *
* Version 1.1                                                         *
***********************************************************************

	move.l	sp,a5
	move.l	4(a5),a5
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	addi.l	#$100,d0
	move.l	d0,d7
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	#0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#$c,sp

	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	add.l	#160*199,d0
	move.l	d0,a6

	lea	filename(pc),a1
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+

	clr.l	-(sp)
	pea	run(pc)
	pea	filename(pc)
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	add.l	#16,sp

	pea	ermess
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	#7,(sp)
	trap	#1
	addq.l	#2,sp
	clr.w	-(sp)
	trap	#1

filename:	dcb.b	0,20
run:
	dc.l	0
ermess:	dc.b	27,'E'
	dc.b	"EEK!",13,10,10,10
	dc.b	"It appears that this disc is faulty ",13,10
	dc.b	"or someone has been changing filenames.",13,10
	dc.b	"In either case, you'd better get ",13,10
	dc.b	"another copy.",13,10,0
	even
	dc.l	"POV!"

