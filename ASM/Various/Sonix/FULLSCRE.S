;-------------------------------------------------------------------------;
;      Sonix's FULLSCREEN routines! first version 05/07/1993 21:59 pm     ;
;      cpu time left 0%  final FULLSCREEN version 23/07/1993 03:47 am     ;
;-------------------------------------------------------------------------;
; Tested on: STf 1040 (TOS 1.00)         STe 1040 (TOS 1.6)               ;
;            ST  512  (TOS 1.00)         STf 512  (TOS 1.00)              ;
;            ST  512  (TOS 1.02)                                          ;
;as you can see from the tested on list, this rout should work on all ST's;
;This routine is NOT fully documented, so if you don't understand it all, ;
;it's your loss. Sorry about this, but you should know how this is working;
;Plase sent to me (Sonix = poor coder) some money, if you use this routine;
;Something 30 Fim ~ 6 dollars or 5 pounds would be a nice gift from you to;
;me! You'll have much better mind after that, at least i will have!       ;
;                                                                         ;
;        My address:         Toni Pietil„                                 ;
;                         Vaahtorinne 4 e 78                              ;
;                            01600  Vantaa                                ;
;                               Finland             (Send lots'a money!)  ;
;-------------------------------------------------------------------------;

*	opt	o+

	clr.l	-(SP)
	move.w	#$20,-(SP)
	trap	#1
	addq.l	#6,SP

	movem.l	black_pal,D0-D7
	movem.l	D0-D7,$ffff8240.w

	move.l	d0,SAVE_SPP	;<- save old timers & vectors
	move.l	$120,SAVE_VECT
	move.b	$fffa07,SAVE_IERA
	move.b	$fffa09,SAVE_IERB
	move.b	$fffa0f,SAVE_INS
	move.b	$fffa13,SAVE_IMRA
	move.b	$fffa21,SAVE_TBDR
	move.b	$fffa1b,SAVE_TBCR
	move.l	$70,SAVE_VBL	;<- save old VBL!
	move.b	#1,$00FF8201

*	clr.w	-(a7)
*	pea	$70000
*	pea	$70000
*	move.w	#5,-(a7)
*	trap	#14
*	lea	12(a7),a7
*
*	move.l	$44e.l,a0		;<- clear screen!
*	move	#15999,d0		;<- about 2x32000 area!
*cls	clr.l	(a0)+
*	dbf	d0,cls

	move.b	$FFFFA07,D1	;<- set interupts!
	bset	#0,D1
	move.b	$FFFFA09,D0
	bclr	#5,D0
	bclr	#6,D0
	move.b	D1,$FFFFA07
	move.b	D0,$FFFFA09
	move.l	#hbl,$120		;<- set new HBL on!
	ori.b	#1,$FFFFA07	;<- stop MFP!
	ori.b	#1,$FFFFA13
	move.l	#vbl,$70		;<- set new VBL on!

	movem.l	pic_pal,D0-D7
	movem.l	D0-D7,$ffff8240.w

scanloop	cmp.b	#$39,$FFFFFC02 
	beq.s	quit
	cmp.b	#$38,$FFFFFC02 
	beq.s	time
	jmp	scanloop

time	move.w	#$003,$ffff8240.w
	jmp	scanloop

quit	move.w	#$777,$ffff8240.w
	move.w	#$000,$ffff8246.w
	move.w	#$000,$ffff825e.w

	move.l	SAVE_VECT,$120
	move.b	SAVE_IERA,$fffa07
	move.b	SAVE_IERB,$fffa09
	move.b	SAVE_IMRA,$fffa13
	move.b	SAVE_TBDR,$fffa21
	move.b	SAVE_TBCR,$fffa1b
	move.b	SAVE_INS,$fffa0f
	move.l	SAVE_VBL,$70
	move.l	SAVE_SPP,-(sp)
*     	move.l	#old_color,$45a.w

	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	movem.l	(sp)+,d0-a6
	clr.l	-(sp)
	trap	#1

vbl:	move.w	#$000,$ffff8240.w
	move	sr,-(a7)
	move	#$2700,sr
	move.l	#$592,d0
.wait1	dbf	d0,.wait1
	move.b	#0,$ffff820a.w	;<-this is the top remover!
	moveq	#4,d0
.wait2	dbf	d0,.wait2
	move.b	#2,$ffff820a.w
	move	(a7)+,sr

	move.l	#hbl,$120
	move.b	#0,$FFFFA1B
	move.b	#1,$FFFFA21
	move.b	#8,$FFFFA1B
	rte

hbl	lea	$FFFF820A,A0
	lea	$FFFF8260,A1
	stop	#$2100
	move	#$2700,SR
	moveq	#0,D0
syncronise	move.b	$FFFF8209.w,D0
	beq.s	syncronise
	not.w	D0
	lsr.w	D0,D0

	dcb.w	55,$4e71		;<- sync to right screen point!

	move	#225,d5		;<- number of normal scanlines!
overscan	nop
	move.w	A1,(A1)
	nop
	move.b	D0,(A1)

	dcb.w	89,$4e71		;<- number of nop's

	move.b	D0,(A0)
	move.w	A0,(A0)

	dcb.w	13,$4e71

	move.w	A1,(A1)
	nop
	move.b	D0,(A1)

	dcb.w	8,$4e71

	dbf	d5,overscan

	move.w	a1,(a1)
	nop
	move.b	d7,(a1)

	dcb.w	89,$4e71

	move.b	d7,(a0)
	move.w	a0,(a0)

	dcb.w	13,$4e71

	move.w	a1,(a1)
	nop
	move.b	d7,(a1)

	nop
	move.b	#0,(a0)		;<- bottom 60hz!

	dcb.w	6,$4e71

	move.b	#2,(a0)		;<- bottom 50hz!
	move.w	a1,(a1)
	move.b	d7,(a1)

	dcb.w	89,$4e71

	move.b	d7,(a0)
	move.w	a0,(a0)

	dcb.w	13,$4e71

	move.w	a1,(a1)
	nop
	move.b	d7,(a1)

	dcb.w	9,$4e71

	move	#41,d5		;<- bottom bord. scanlines!
overscan2	nop
	move.w	A1,(A1)
	nop
	move.b	D0,(A1)

	dcb.w	89,$4e71

	move.b	D0,(A0)
	move.w	A0,(A0)

	dcb.w	13,$4e71

	move.w	A1,(A1)
	nop
	move.b	D0,(A1)

	dcb.w	8,$4e71

	dbf	d5,overscan2

	move	#$2300,sr
	move.l	#exit_hbl,$120.w
	subq.b	#1,$FFFFA0F
	rte

exit_hbl	subq.b	#1,$FFFFA0F   
	rte

SAVE_SPP	ds.l 1
SAVE_VECT	ds.l 1
SAVE_IERA	ds.b 1
SAVE_IMRA	ds.b 1
SAVE_TBDR	ds.b 1
SAVE_TBCR	ds.b 1
SAVE_IERB	ds.b 1
SAVE_VBL	ds.l 1
SAVE_INS	ds.b 1

black_pal	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
pic_pal	dc.w	$0,$122,$233,$3C3,$33C,$CCC,$DDC,$EEE
	dc.w	$31,$F00,$F10,$F00,$F00,$F00,$F00,$F00
	ds.b	256
         										           	