*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;                  Routine de d‚compactage PowerPacker 2
;
;Entr‚e	A0 = d‚but du block compact‚
;	A1 = d‚but de d‚compactage
;	D0 = taille du block compact‚
;
;Sortie	( Z , D0 ) = ( 1 , taille d‚compact‚e )
;		= ( 0 , taille block) si !PP20
;
;Il faut un espace libre de 64 octets sur la pile pour la sauvegarde
;des registres...
;
;                      Modifications cosm‚tiques par Nullos, DNT-Crew 1994
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
power_decrunch
	movem.l	d0-a6,-(sp)
	move.l	a0,a5
	adda.l	d0,a0
	cmpi.l	#'PP20',(a5)+
	bne.w	.abort
	move.l	a1,a3
	moveq	#3,d6
	moveq	#7,d7
	moveq	#1,d5
	movea.l	a3,a2
	move.l	-(a0),d1
	tst.b	d1
	beq.s	.pp_0
	bsr.s	.pp_4
	subq.b	#1,d1
	lsr.l	d1,d5
.pp_0	lsr.l	#8,d1
	move.l	d1,(sp)
	adda.l	d1,a3
.pp_1	bsr.s	.pp_4
	bcs.s	.pp_11
	moveq	#0,d2
.pp_2	moveq	#1,d0
	bsr.s	.pp_7
	add.w	d1,d2
	cmp.w	d6,d1
	beq.s	.pp_2
.pp_3	moveq	#7,d0
	bsr.s	.pp_7
	move.b	d1,-(a3)
	dbf 	d2,.pp_3
	cmpa.l	a3,a2
	bcc.s	.pp_17

.pp_11	moveq	#1,d0
	bsr.s	.pp_7
	moveq	#0,d0
	move.b	(a5,d1.w),d0
	move.w	d1,d2
	cmp.w	d6,d2
	bne.s	.pp_14
	bsr.s	.pp_4
	bcs.s	.pp_12
	moveq	#7,d0
.pp_12	bsr.s	.pp_6
	move.w	d1,d3
.pp_13	moveq	#2,d0
	bsr.s	.pp_7
	add.w	d1,d2
	cmp.w	d7,d1
	beq.s	.pp_13
	bra.s	.pp_15

.pp_4	lsr.l	#1,d5
	beq.s	.pp_5
	rts  	

.pp_5	move.l	-(a0),d5
	roxr.l	#1,d5
	rts  	

.pp_6	subq.w	#1,d0
.pp_7	moveq	#0,d1
.pp_8	lsr.l	#1,d5
	beq.s	.pp_10
	addx.l	d1,d1
	dbf 	d0,.pp_8
	rts  	
.pp_10	move.l	-(a0),d5
	roxr.l	#1,d5
	addx.l	d1,d1
	dbf 	d0,.pp_8
	rts  	

.pp_14	bsr.s	.pp_6
	move.w	d1,d3
.pp_15	addq.w	#1,d2
.pp_16	move.b	(a3,d3.w),-(a3)
	dbf 	d2,.pp_16
	cmpa.l	a3,a2
	bcs.s	.pp_1
.pp_17	moveq	#0,d0
.abort	movem.l	(sp)+,d0-a6
	rts
