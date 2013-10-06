***********************************************
*                                             *
* << Lower overscan rout : >>                 *
* ---------------------------                 *
*                                             *
* << Code : GT Turbo >>                       *
*                                             *
* This routine open the lower border, for     *
* doing this, the timer B is used for doing   *
* it easier.                                  *
*                                             *
* This rout is freeware, you can use it in    *
* all your code, all that you want.           *
*                                             *
*                                             *
*             GT Turbo (Cerebral Vortex)      *
*                                             *
*                                             *
* < Impossible is not Cerebral,               *
*          it's only a question of time ! >   *
*                                             *
* It's a old code, so don't say anything      *
*                        about my code !!!!   *
*                                             *
* Cerebral Vortex is composed by :            *
*                                             *
* RaZ(TheLAB) : grafix                        *
*                                             *
* Azrael : Code and Mathemakil thinkings !    *
*                                             *
* GT Turbo : Code                             *
*                                             *
***********************************************


***********************************************
*                                             * 
***********************************************

	SECTION	TEXT

***********************************************
*                                             * 
***********************************************

	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,Save_stack

	jsr	Init_screens

	jsr	Save_and_init_a_st

	jsr	Init(pc)

******************************************************************************


Main_rout:
	jsr	Wait_vbl(pc)

	cmp.b	#$39,$fffffc02.w	* Wait
	bne.s	Main_rout		* Space

Wait_main_rout:
	cmp.b	#$39+$80,$fffffc02.w	* Release
	bne.s	Wait_main_rout		* space bar

******************************************************************************


	jsr	Restore_st

Kflush:
	btst	#0,$fffffc00.w
	beq.s	Flush_ok
	move.b	$fffffc02.w,d0
	bra.s	Kflush
Flush_ok:

	move.l	Save_stack,-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.w	-(sp)
	trap	#1

************************************************
*                                              *
*               Sub Routines                   *
*                                              *
************************************************

Vbl:	movem.l	d0-d7/a0-a6,-(a7)

	st	Vsync

	move.l	#Over_rout,$120.w
	move.b	#199,$fffffa21.w
	move.b	#8,$fffffa1b.w

	movem.l	(a7)+,d0-d7/a0-a6
	rte

Wait_vbl:	move.l	a0,-(a7)

	lea	Vsync,a0
	sf	(a0)
Wait_label:	
	tst.b	(a0)
	beq.s	Wait_label

	move.l	(a7)+,a0
	rts

*********************************************
*                                           *
*********************************************

Init:	movem.l	d0-d7/a0-a6,-(a7)

	lea	Vbl(pc),a0
	move.l	a0,$70.w

	lea	Pal(pc),a0
	lea	$ffff8240.w,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)

	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
************************************************

Save_and_init_a_st:

	lea	Save_all,a0
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa15.w,(a0)+
	move.b	$fffffa17.w,(a0)+
	move.b	$ffff8201.w,(a0)+
	move.b	$ffff8203.w,(a0)+
	move.b	$ffff820d.w,(a0)+
	move.b	$ffff8260.w,(a0)+
	move.b	$ffff820a.w,(a0)+

	move.l	$070.w,(a0)+	
	move.l	$118.w,(a0)+	
	move.l	$120.w,(a0)+	
	move.l	$134.w,(a0)+	
	move.l	$114.w,(a0)+	
	move.l	$110.w,(a0)+	
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,(a0)

	sf	$ffff8260.w

	moveq	#0,d0
	lea	$fffffa00.w,a0
	movep.w	d0,$07(a0)
	movep.w	d0,$13(a0)

	bclr	#3,$fffffa17.w

	move.l	Turbo_scr1,d0
	move.b	d0,d1
	lsr.w	#8,d0
	move.b	d0,$ffff8203.w
	swap	d0
	move.b	d0,$ffff8201.w
	move.b	d1,$ffff820d.w

	sf	$fffffa21.w
	sf	$fffffa1b.w
	move.l	#Over_rout,$120.w

	bset	#0,$fffffa07.w	* Timer B on
	bset	#0,$fffffa13.w	* Timer B on

	stop	#$2300
	
	rts

***************************************************************
*                                                             *
*             < Here is the lower border rout >               *
*                                                             *
***************************************************************

Over_rout:
	sf	$fffffa21.w	* Stop Timer B
	sf	$fffffa1b.w

	REPT	95	* Wait line end
	nop
	ENDR	
	sf	$ffff820a.w	* Modif Frequency 60 Hz !

	REPT	28	* Wait a little
	nop
	ENDR

	move.b	#$2,$ffff820a.w * 50 Hz !

	rte

***************************************************************
*                                                             *
***************************************************************

Restore_st:
	move.w	#$2700,sr

	lea	Save_all,a0
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa15.w
	move.b	(a0)+,$fffffa17.w
	move.b	(a0)+,$ffff8201.w
	move.b	(a0)+,$ffff8203.w
	move.b	(a0)+,$ffff820d.w
	move.b	(a0)+,$ffff8260.w
	move.b	(a0)+,$ffff820a.w

	move.l	(a0)+,$070.w
	move.l	(a0)+,$118.w
	move.l	(a0)+,$120.w
	move.l	(a0)+,$134.w
	move.l	(a0)+,$114.w
	move.l	(a0)+,$110.w

	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w

	stop	#$2300

* Sorry for the next lines, but sometimes there somes syncs error !!

	move.b	Video,$ffff8260.w
	move.w	#$25,-(a7)
	trap	#14
	addq.w	#2,a7
	move.b	Video,$ffff8260.w

	rts

************************************************
*                                              *
************************************************

Init_screens:	movem.l	d0-d7/a0-a6,-(a7)

	move.l	#Turbo_screen1,d0
	add.w	#$ff,d0
	sf	d0
	move.l	d0,Turbo_scr1

	move.l	Turbo_scr1,a0
	move.l	#((160*240)/8)-1,d7
	move.l	#$0000ffff,d0
	move.l	#$ffffffff,d1
Clr_1:
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	dbra	d7,Clr_1

	move.l	Turbo_scr1,a0
	add.w	#200*160,a0
	move.l	#((160*40)/4)-1,d7
	moveq	#-1,d0	
Over:
	move.l	d0,(a0)+
	dbra	d7,Over

	movem.l	(a7)+,d0-d7/a0-a6
	rts

******************************************************************

	SECTION	DATA

Pal:	dc.w	$000,$111,$222,$333,$444,$555,$666,$777
	dc.w	$000,$111,$222,$333,$444,$555,$666,$777

******************************************************************

	SECTION	BSS

Vsync:	ds.b	1
               	ds.b	1
Save_stack:	ds.l	1

Save_all:
	ds.b	5	* Mfp
	ds.b	3	* Video
Video	ds.b	1
	ds.b	1
	ds.l	1	* Vbl
	ds.l	1	* Kbd
	ds.l	1	* Timer b
	ds.l	1	* Timer a
	ds.l	1	* Timer c
	ds.l	1	* Timer d
	ds.w	16	* Palette

Turbo_scr1:	ds.l	1

Turbo_screen1:	ds.b	(160*250)+256

	END
