*****************************************************************
*	Gun re-loading bits					*
*	By GAH on 2/11/88					*
*****************************************************************

REL_SPD		equ	12

RE_LOAD
	move.w		REL_CNT,d0
	cmpi.w		#REL_SPD,d0
	bne		done_reload
	
	clr.w		REL_CNT

	movea.l		#SP_TABLE+104,a6
	
	move.w		#3,d7
EL_MAN
	DO_SAM		REL_SAM,RELOAD_LEN,0
	bsr		get_sc2
	move.l		a5,d0
	tst.l		d0
	beq		no_elm1
	bsr		clearsprite
NO_ELM1
	lea		-26(a6),a6
	dbf.w		d7,el_man

	move.l		a0,SC_ADDR		*Save for RON

	move.w		#3,d6
	movea.l		#REL_TAB,a6

PUT_RELS
	
	movea.l		#MAN_GRPH,a1
	movea.l		#CACHE,a2
	movea.w		SP_TABLE+26,a3
	movea.w		SP_TABLE+28,a4
	move.w		(a6)+,d1		*d1 = offs into man grph
	lea		0(a1,d1.w),a1
	movea.l		SC_ADDR,a0
	bsr		plotsprite


	movea.l		#MAN_GRPH,a1
	movea.l		#CACHE,a2
	movea.w		SP_TABLE+26,a3
	movea.w		SP_TABLE+28,a4
	lea		16(a3),a3
	move.w		(a6)+,d1		*d1 = offs into man grph
	lea		0(a1,d1.w),a1
	movea.l		SC_ADDR,a0
	bsr		plotsprite



	movea.l		#MAN_GRPH,a1
	movea.l		#CACHE,a2
	movea.w		SP_TABLE+26,a3
	movea.w		SP_TABLE+28,a4
	lea		16(a4),a4
	move.w		(a6)+,d1		*d1 = offs into man grph
	lea		0(a1,d1.w),a1
	movea.l		SC_ADDR,a0
	bsr		plotsprite


	movea.l		#MAN_GRPH,a1
	movea.l		#CACHE,a2
	movea.w		SP_TABLE+26,a3
	movea.w		SP_TABLE+28,a4
	lea		16(a3),a3
	lea		16(a4),a4
	move.w		(a6)+,d1		*d1 = offs into man grph
	lea		0(a1,d1.w),a1
	movea.l		SC_ADDR,a0
	bsr		plotsprite

	move.w		(a6)+,d0
	move.w		d0,DIS_TIM

	jsr		pc_wait

	move.l		a6,-(sp)
	movea.l		#SP_TABLE+104,a6
	
	move.w		#3,d7
EL_MANB
	bsr		get_sc2
	move.l		a5,d0
	tst.l		d0
	beq		no_elm2
	bsr		clearsprite
NO_ELM2
	lea		-26(a6),a6
	dbf.w		d7,el_manb

	move.l		(sp)+,a6
	dbf.w		d6,put_rels
	bra		done_reload

REL_TAB
	dc.w		2304,2432,2560,2688,6
	dc.w		2304,11008,2560,2688,6
	dc.w		2304,11136,2560,2688,6
	dc.w		2304,11264,2560,2688,6

SC_ADDR
	dc.l		0
REL_CNT
	dc.w		0

DONE_RELOAD
	addq.w		#1,REL_CNT