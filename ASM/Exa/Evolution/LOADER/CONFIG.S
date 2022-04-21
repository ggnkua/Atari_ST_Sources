	SECTION TEXT
startup
	move.l	8(a7),a3		base page
	move.l	$c(a3),d0		text len
	add.l	$14(a3),d0		data len
	add.l	$1c(a3),d0		BSS len
	add.l	#$100,d0		basepage
	move.l	d0,-(sp)
	move.l	a3,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1			shrink memory
	lea	12(sp),sp
	rts

	
SAVE_ALL
	
	move.w	sr,SAVE_SR
	
	move	#$2700,sr
	
	lea	SAVE_INT,a0		! Store MFP
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa0b.w,(a0)+
	move.b	$fffffa0d.w,(a0)+
	move.b	$fffffa0f.w,(a0)+
	move.b	$fffffa11.w,(a0)+
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa15.w,(a0)+
	move.b	$fffffa17.w,(a0)+
	move.b	$fffffa19.w,(a0)+
	move.b	$fffffa1b.w,(a0)+
	move.b	$fffffa1d.w,(a0)+
	
	lea	SAVE_EXECP,a0		! Store Inter
	move.l	$68.w,(a0)+
	move.l	$70.w,(a0)+
	move.l	$114.w,(a0)+
	move.l	$118.w,(a0)+
	move.l	$120.w,(a0)+
	move.l	$134.w,(a0)+
	

	lea	SAVE_DIVERS,a0		! Store divers
	move.b	$ffff8201.w,(a0)+
	move.b	$ffff8203.w,(a0)+
	move.l	$44e,(a0)+
	move.l	USP,a1
	move.l	a1,(a0)+

	lea	$ffff8240.w,a0
	lea	OLD_PAL,a1		! Store pal
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)

	lea	$ffff9800.w,a0
	lea	FALC_PAL,a1
	move.w	#255,d7
.C	move.l	(a0)+,(a1)+
	dbra	d7,.C
	
	lea	SAVE_STE,a0
	move.b	$ffff8901.w,(a0)+
	move.b	$ffff8921.w,(a0)+
	move.b	$ffff820f.w,(a0)+
	move.b	$ffff8265.w,(a0)+
	clr.b	$ffff8901.w
	move.w	#$2300,sr
	rts

RESTORE_ALL
	move	#$2700,sr
	clr.b	$fffffa07.w
	clr.b	$fffffa09.w
	clr.b	$fffffa13.w
	clr.b	$fffffa15.w
	
	lea	SAVE_DIVERS,a0		! Restore divers
	move.b	(a0)+,$ffff8201.w
	move.b	(a0)+,$ffff8203.w
	move.l	(a0)+,$44e
	move.l	(a0)+,a1
	move.l	a1,usp


	lea	SAVE_INT,a0		! Restore Mfp
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa0b.w
	move.b	(a0)+,$fffffa0d.w
	move.b	(a0)+,$fffffa0f.w
	move.b	(a0)+,$fffffa11.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa15.w
	move.b	(a0)+,$fffffa17.w
	move.b	(a0)+,$fffffa19.w
	move.b	(a0)+,$fffffa1b.w
	move.b	(a0)+,$fffffa1d.w
	
	;move.b	#$b4,$fffffa23.w
	
	lea	SAVE_EXECP,A0		! Restore inter
	move.l	(a0)+,$68.w
	move.l	(a0)+,$70.w
	move.l	(a0)+,$114.w
	move.l	(a0)+,$118.w
	move.l	(a0)+,$120.w
	move.l	(a0)+,$134.w
	
	lea	$ffff8240.w,a1		! Restore pal
	lea	OLD_PAL,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)

	lea	FALC_PAL,a0
	lea	$ffff9800.w,a1
	move.w	#255,d7
.C	move.l	(a0)+,(a1)+
	dbra	d7,.C

	
	lea	SAVE_STE,a0
	move.b	(a0)+,$ffff8901.w
	move.b	(a0)+,$ffff8921.w
	move.b	(a0)+,$ffff820f.w
	move.b	(a0)+,$ffff8265.w

PAS_STE_SA
WAC	move.b	$fffffc00.w,d1			;RESET 6301
	btst	#1,d1				;COMMANDE $8001
	beq.s	WAC
	move.b	#$80,$fffffc02.w
WAC2	move.b	$fffffc00.w,d1
	btst	#1,d1
	beq.s	WAC2
	move.b	#$01,$fffffc02.w

	
Y_EN_A	btst.b	#0,$fffffc00.w		! Keyboard flush ...
	beq.s	Y_EN_A_PLUS	
	move.b	$fffffc02.w,d0
	bra.s	Y_EN_A
Y_EN_A_PLUS
	move.w	SAVE_SR,sr
	rts
	
	
	SECTION BSS
	
SAVE_INT		ds.l	20
SAVE_EXECP		ds.l	20
SAVE_DIVERS		ds.l	20
FALC_PAL		ds.l	256
OLD_PAL			ds.l	20
SAVE_STE		ds.l	20
SAVE_SR			ds.w	1


	SECTION TEXT