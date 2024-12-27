; TEX L.C.D. DEMO 2
; 50/60 Hz TOGGLE ADDED BY MSD 6/11/88
;
; COMPRESSED VERSION CREATED ON 7/5/89 USING
; COMPACTION FORMULA BY LORD BLITTER OF
; AMIGA FAME.
; ST VERSION WRITTEN BY JON SEYMOUR.
;
; DECOMPACTOR WRITTEN BY MAC SYS DATA OF
; P.O.V IN FEB '89

	dc.w	$a00a
	clr.w	-(a7)
	move.l	#-1,-(a7)
	move.l	#-1,-(a7)
	move.w	#5,-(a7)
	trap	#14
	add.l	#12,a7
	clr.l	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,stksv
	clr.w	$ff8240
	move.w	#$777,$ff825e
	pea	mess
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,sp
	move.b	#$fc,hz	;set for 60hz
key	move.w	#7,-(a7)
	trap	#1
	addq.l	#2,sp
	swap	d0
	cmp.b	#$62,d0
	beq.s	set60
	add.b	#2,hz
set60	lea	end,a0
	lea	$60000,a1
	bsr.s	depak
	move.l	stksv,-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	bsr	 DECODE
;and here is the adjustment for hz. - $fc= 60hz,  $fe=50hz
	move.b	hz,$498f5
	JMP     $049800.L
stksv:	dc.l	0
hz	dc.b	0
	dc.b	0
depak:	move.w	$ff8240,-(sp)
	move.l	-(a0),d1
	move.l	-(a0),d5
	move.l 	a1,a2
	adda.l 	d1,a2
	move.l 	-(a0),d0
	eor.l 	d0,d5
l1:	move.w	d0,$ff8240
	lsr.l 	#1,d0
	bne.s 	l2
	bsr 	l16
l2:	bcs.s 	l9
	moveq 	#8,d1
	moveq 	#1,d3
	lsr.l 	#1,d0
	bne.s 	l3
	bsr 	l16
l3:	bcs.s 	l11
	moveq 	#3,d1
	clr.w 	d4
l4:	bsr 	l17
	move.w 	d2,d3
	add.w 	d4,d3
l5:	moveq 	#7,d1
l6:	lsr.l 	#1,d0
	bne.s 	l7
	bsr 	l16
l7:	roxl.l 	#1,d2
	dbf 	d1,l6
	move.b 	d2,-(a2)
	dbf 	d3,l5
	bra.s 	l13
l8:	moveq 	#8,d1
	moveq 	#8,d4
	bra.s 	l4
l9:	moveq 	#2,d1
	bsr 	l17
	cmpi.b 	#2,d2
	blt.s 	l10
	cmpi.b 	#3,d2
	beq.s 	l8
	moveq 	#8,d1
	bsr.s 	l17
	move.w 	d2,d3
	move.w 	#12,d1
	bra.s 	l11
l10:	move.w 	#9,d1
	add.w 	d2,d1
	addq.w 	#2,d2
	move.w 	d2,d3
l11:	bsr.s 	l17
l12:	subq.w 	#1,a2
	move.b 	0(a2,d2.w),(a2)
	dbf 	d3,l12
l13:	cmpa.l 	a2,a1
	blt 	l1
	tst.l 	d5
	bne.s 	l14
fin	move.w	(sp)+,$ff8240
	rts
l14:	nop
l15:	moveq 	#1,d0
	rts
l16:	move.l 	-(a0),d0
	eor.l 	d0,d5
	move.w	d0,$ff8240
	move.b 	#$10,ccr
	roxr.l 	#1,d0
	rts
l17:	subq.w 	#1,d1
	clr.w	 d2
l18:	lsr.l 	#1,d0
	bne.s	 l19
	move.l 	-(a0),d0
	eor.l 	d0,d5
	move.w	d0,$ff8240
	move.b 	#$10,ccr
	roxr.l 	#1,d0
l19:	roxl.l 	#1,d2
	dbf 	d1,l18
	rts
DECODE:	move.l	a7,stksv
	MOVE.L  #$00060000,A7
	MOVE.L  #$00060000,A0
	MOVE.L  #$00040000,A1
MSD:	MOVE.B  (A0)+,D0
	EOR.B   #$008D,D0
EXPAND:	MOVE.B  D0,D7
	MOVE.B  (A0)+,D0
	EOR.B   #$008D,D0
	CMP.B   D0,D7
	BEQ     PARTII
	MOVE.B  D7,(A1)+
	BRA     EXPAND
PARTII:	MOVE.B  (A0)+,D0
	EOR.B   #$008D,D0
	CMP.B   #$0002,D0
	BCS     MOVE
FIX:	MOVE.B  D7,(A1)+
	SUBQ.B  #1,D0
	BNE     FIX
	BRA     MSD
MOVE:	move.l	stksv,a7
	MOVE.L  #$00066000,A0
LOOP:	CLR.L   (A0)+
	CMP.L   #$00070000,A0
	BNE	LOOP
	RTS
mess:	dc.b	27,'E'
	dc.b	"        P.O.V. DECOMPACTER V1.3",13,10,10,10,10,10
	dc.b	"              TEX - DEMO 2",13,10,10,10,10,10,10
	dc.b	"      SINGLE PARTED AND PACKED BY",13,10,10
	DC.B	"         MAC SYS DATA OF P.O.V.",13,10,10,10,10,10,10
	dc.b	"    PRESS 'HELP' TO RUN DEMO IN 60hz",13,10,10
	DC.B	"      PRESS ANY OTHER KEY FOR 50hz",13,10,0
	incbin	"TEX2.IMG"
end
