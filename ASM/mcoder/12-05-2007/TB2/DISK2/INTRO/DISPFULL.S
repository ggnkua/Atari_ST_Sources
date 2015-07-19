	move	sr,d0
	and	#$2000,d0
	bne.s	super
	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq	#6,sp
super:
	moveq	#64/2-1,d0
	lea	$80000,a0
clr:	;clr	(a0)+
	dbra	d0,clr

	lea	$80000+2+64-8,a5
;	lea	230*100(a5),a5
;	lea	230*71(a5),a5
;	lea	230*107(a5),a5
;
; 100+71+107=278
;
	lea	$f8000,a6
	bsr	display

	move	#37,-(sp)
	trap	#14
	addq	#2,sp
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,sav8240
	move.b	$ffff8260.w,sav8260
	clr.b	$ffff8260.w
	movem.l	palette,d0-d7
	movem.l	d0-d7,$ffff8240.w

	move	#7,-(sp)
	trap	#1
	addq	#2,sp

	move	#37,-(sp)
	trap	#14
	addq	#2,sp
	move.b	sav8260,$ffff8260.w
	movem.l	sav8240,d0-d7
	movem.l	d0-d7,$ffff8240.w

	lea	$80000+66,a0
	lea	$90000,a1

	move	#278-1,d7
tkline:
	ADDQ	#8,A0
	move	#[224-16]/4-1,d0
tkplane:
	move.l	(a0)+,(a1)+
	dbra	d0,tkplane

	ADDQ	#8,A0
	addq	#6,a0

	dbra	d7,tkline

erreur:
	illegal

display:
	move	#200-1,d7
line:
	move	#160/4-1,d0
	move.l	a5,a0
copy:
	move.l	(a0)+,(a6)+
	dbra	d0,copy
	lea	230(a5),a5
	dbra	d7,line
	rts
palette:
	DC.W	0,$760,$640,$530
	DC.W	$322,$423,$534,$646
	DC.W	$526,$405,$304,$223
	DC.W	$334,$445,$556,$777
sav8240:blk.b	32
sav8260:dc.b	0

	end

	move.l	phy,a0
	lea	2+160-32(a0),a0
	lea	dessin,a1
	move.w	#16000-1,d0
loop5:
	move.l	(a1)+,(a0)+
	dbf	d0,loop5

