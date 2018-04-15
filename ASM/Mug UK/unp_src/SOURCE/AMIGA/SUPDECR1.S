;-----------------------------------------------------------------------;
;                                                                       ;
;          SUPPLEX V1.0 decruncher source ripped by NATIVE/EFFECT       ;
;                                                                       ;
;-----------------------------------------------------------------------;
org	$c20000
load	$c20000
begin:	lea	Z50158(pc),a3
	move.l	a3,d0
	move.l	$0008(a3),d1
	lea	Z50158+$0c(pc),a0
	add.l	d1,a0
	move.l	$0004(a3),a1
	move.l	-(a0),a2
	add.l	a1,a2
	move.l	-(a0),d0
Z5003e:	moveq	#$03,d1
	bsr	Z50148
	tst.b	d2
	beq	Z500a6
	cmp.w	#$0007,d2
	bne	Z50074
	lsr.l	#1,d0
	bne	Z50056
	bsr	Z5012e
Z50056:	bcc	Z5006c
	moveq	#$0a,d1
	bsr	Z50148
	tst.w	d2
	bne	Z50074
	moveq	#$12,d1
	bsr	Z50148
	bra	Z50074
Z5006c:	moveq	#$04,d1
	bsr	Z50148
	addq.w	#7,d2
Z50074:	subq.w	#1,d2
Z50076:	moveq	#$07,d1
Z50078:	lsr.l	#1,d0
	beq	Z50092
	roxl.l	#1,d3
	dbf	d1,Z50078
	move.b	d3,-(a2)
	move.b	d3,$dff102.l	;Decrunch Colors !
	dbf	d2,Z50076
	bra	Z500a6
Z50092:	move.l	-(a0),d0
	move.w	#$0010,CCR
	roxr.l	#1,d0
	roxl.l	#1,d3
	dbf	d1,Z50078
	move.b	d3,-(a2)
	dbf	d2,Z50076
Z500a6:	cmp.l	a2,a1
	bge	Z50128
	moveq	#$02,d1
	bsr	Z50148
	moveq	#$02,d3
	moveq	#$08,d1
	tst.w	d2
	beq	Z50118
	moveq	#$04,d3
	cmp.w	#$0002,d2
	beq	Z50102
	moveq	#$03,d3
	cmp.w	#$0001,d2
	beq	Z500f4
	moveq	#$02,d1
	bsr	Z50148
	cmp.w	#$0003,d2
	beq	Z500ec
	cmp.w	#$0002,d2
	beq	Z500e2
	addq.w	#5,d2
	move.w	d2,d3
	bra	Z50102
Z500e2:	moveq	#$02,d1
	bsr	Z50148
	addq.w	#7,d2
	move.w	d2,d3
	bra	Z50102
Z500ec:	moveq	#$08,d1
	bsr	Z50148
	move.w	d2,d3
	bra	Z50102
Z500f4:	moveq	#$08,d1
	lsr.l	#1,d0
	bne	Z500fc
	bsr	Z5012e
Z500fc:	bcs	Z50118
	moveq	#$0e,d1
	bra	Z50118
Z50102:	moveq	#$10,d1
	lsr.l	#1,d0
	bne	Z5010a
	bsr	Z5012e
Z5010a:	bcc	Z50118
	moveq	#$08,d1
	lsr.l	#1,d0
	bne	Z50114
	bsr	Z5012e
Z50114:	bcs	Z50118
	moveq	#$0c,d1
Z50118:	bsr	Z50148
	subq.w	#1,d3
Z5011c:	move.b	$ff(a2,d2.l),-(a2)
	dbf	d3,Z5011c
	bra	Z5003e
Z50128:	;rts
	jmp	$30000.L	;Jump-In Adress
Z5012e:	move.l	-(a0),d0
	move.w	#$0010,CCR
	roxr.l	#1,d0
	rts
Z50138:	move.l	-(a0),d0
	move.w	#$0010,CCR
	roxr.l	#1,d0
	roxl.l	#1,d2
	dbf	d1,Z5014c
	rts
Z50148:	subq.w	#1,d1
	clr.l	d2
Z5014c:	lsr.l	#1,d0
	beq	Z50138
	roxl.l	#1,d2
	dbf	d1,Z5014c
	rts

Z50158:	dc.l	$00040624,$00030000,$00000088
;				|         |
;				|         |
;                        Decruch To ?   Length Crunched DATA File

Z50164:;Start Crunched DATA File
       ;	       ----
