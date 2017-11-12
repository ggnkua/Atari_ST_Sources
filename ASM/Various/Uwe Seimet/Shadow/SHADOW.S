
*	Shadow-RAM / ROMSPEED V1.0a		*
*	Uwe Seimet, ST:Computer 145,3,1991	*
*	Wolfgang Zweygart 28.02.91		*
*	microTalk BBS, 0711-813480		*


GEMDOS	=	1
CCONWS	=	9
PTERMRES=	49
LOGBASE =	3
SUPEXEC =	38
XBIOS	=	14

_p_cookies	=	$05a0

 text

	pea	super(pc)
	move	#SUPEXEC,-(sp)
	trap	#XBIOS
	addq.l	#6,sp

	tst.b	stflg
	bne.b	quitst
	pea	message(pc)
	move.w	#CCONWS,-(sp)
	trap	#GEMDOS
	addq.l	#6,sp

	tst.b	ramflg
	bne.b	quit

	move.l	rompnt,a1
	sub.l	#mem,a1
	add.l	#524288,a1
	move.l	4(sp),a0
	add.l	12(a0),a1
	lea	$100(a1),a1
	clr.w	-(sp)
	pea	(a1)
	move.w	#PTERMRES,-(sp)
	trap	#GEMDOS
	
quitst: pea	ttonly(pc)
	move	#CCONWS,-(sp)
	trap	#GEMDOS
	addq.l	#6,sp
quit:	clr.w	-(sp)
	trap	#GEMDOS

* find Cookies and detect computer type *
super:	move.l	_p_cookies,d0
	seq	stflg
	beq.b	exit
	move.l	d0,a0
loop:	movem.l (a0)+,d0-d1
	tst.l	d0
	beq.b	exit
	cmp.l	#"_MCH",d0
	bne.b	loop
	cmp.l	#$00020000,d1
	sne	stflg
	cmp.w	#$00e0,$07f8
	sne	ramflg
	bne.b	exit

* move phys. ROM to phys RAM *
	move.l	#mem+32768,d1
	and.l	#$FFFF8000,d1
	move.l	d1,rompnt
	move.l	d1,a0
	lea	$00e00000,a1
	move.l	#16383,d0
copy:	move.l	(a1)+,(a0)+	; moving the memory
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d0,copy

* prepare to switch log. RAM to phys. ROM adr. *
	or.w	#5,d1
	move.l	d1,$07f8

* clear ATC in PMMU *
	pflusha

exit:	rts

message: dc.b $0d,$0a,"Shadow-RAM / ROMSPEED V1.0a",$d,$a
	dc.b $d,$a,"from: Uwe Seimet, ST:Computer 145,3,1991",$d,$a
	dc.b "Rel: Wolfgang Zweygart 28.02.91",$d,$a
	dc.b "Seen: microTalk BBS, 0711-813480",$d,$a,0,0
ttonly: dc.b $d,$a,"only TT and 68030",$d,$a,0,0

 bss
mem:	ds.b 557056

rompnt: ds.l 1		; pointer to phys RAM = ROM
ramflg: ds.b 1
stflg:	ds.b 1		; wrong computer ??
 end
