
* With this source PLUS PICPAC1.S, PICPAC2.S and PICPAC3.S (from the
* assembler department) can an object file be created.
* Processor registers preserved except D0-D2 and A0-A2.
*				M†rten Lindstr”m.

picpac	set	3	to include all three picpac parts

 XDEF _vdi_tru,_tru_vdi,_ste_tru,_tru_ste,_vdi_ste,_ste_vdi,_imgpac,_lbmpac
 XDEF _imgcalc,_imgunp,_lbmcalc,_lbmunp,_degcalc,_degunp,_neocalc,_neounp
 XDEF _gifcalc,_gifunp,_tifcalc,_tifunp,_plnfill,_getchnk,_putfm,_getfm,_settru

	include	picpac1.s

_vdi_tru	lea	VDI_TRU(PC),A2
palconv	move.w	4(SP),D0
	move.l	6(SP),A0
	move.l	10(SP),A1
	jmp	(A2)
_tru_vdi	lea	TRU_VDI(PC),A2
	bra.s	palconv
_ste_tru	lea	STE_TRU(PC),A2
	bra.s	palconv
_tru_ste	lea	TRU_STE(PC),A2
	bra.s	palconv
_vdi_ste	lea	VDI_STE(PC),A2
	bra.s	palconv
_ste_vdi	lea	STE_VDI(PC),A2
	bra.s	palconv

_settru	move.l	4(SP),D0
	move.l	8(SP),A0
	bra	SETTRU
_plnfill	lea	PLNFILL(PC),A2
	move.w	4(SP),D0
	move.l	6(SP),A0	A4
	bra.s	safe_run
_getchnk	lea	GETCHNK(PC),A2
	move.l	4(SP),D0
	move.l	8(SP),D2	A3
	bsr.s	safe_run
	move.l	12(SP),A1
	move.l	A0,(A1)
	rts
_putfm	lea	PUTFM(PC),A2
	move.w	4(SP),D0
	move.l	6(SP),D2	A3
	move.l	10(SP),A0	A4
	bra.s	safe_run
_getfm	lea	GETFM(PC),A2
	move.l	4(SP),D2	A3
	move.l	8(SP),A0	A4
	bra.s	safe_run

_lbmcalc	lea	LBMCALC(PC),A2
	bra.s	piccalc
_degcalc	lea	DEGCALC(PC),A2
	bra.s	piccalc
_neocalc	lea	NEOCALC(PC),A2
	bra.s	piccalc
_lbmunp	lea	LBMUNP(PC),A2
	bra.s	picunp
_degunp	lea	DEGUNP(PC),A2
	bra.s	picunp
_neounp	lea	NEOUNP(PC),A2
	bra.s	picunp

safe_run	movem.l	D3-D4/A3-A4,-(SP)
	move.l	D0,D3
	move.l	D1,D4
	move.l	D2,A3
	move.l	A0,A4
	jsr	(A2)
	movem.l	(SP)+,D3-D4/A3-A4
	rts

_imgcalc	lea	IMGCALC(PC),A2
piccalc	moveq	#0,D0	D3
	tst.w	4(SP)
	beq.s	.no_vrt
	moveq	#-1,D0	D3
.no_vrt	move.w	6(SP),D0	D3
	move.l	8(SP),D2	A3
	move.l	12(SP),A0	A4
	link	A1,#-36
	move.l	A0,D1	A4
	bne.s	.xmfdb
	lea	(SP),A0	A4
.xmfdb	move.l	D2,D1	A3->D4, Make D4 non-zero
	bsr.s	safe_run
	unlk	A1
	rts

_imgunp	lea	IMGUNP(PC),A2
picunp	moveq	#0,D0	D3
	tst.w	4(SP)
	beq.s	.no_vrt
	moveq	#-1,D0	D3
.no_vrt	move.w	6(SP),D0	D3
	move.l	8(SP),D2	A3
	move.l	12(SP),A0	A4
	move.l	16(SP),(A0)	(A4)
	ble.s	bnderror
	move.l	20(SP),D1	D4
	ble.s	bnderror
	bsr.s	safe_run
	move.l	24(SP),A0
	move.b	D1,(A0)
	rts
bnderror	moveq	#-1,D0
	rts

	ifge	picpac-3
_gifcalc	lea	GIFCALC(PC),A2
	bra.s	piccalc
_tifcalc	lea	TIFCALC(PC),A2
	bra.s	piccalc
_gifunp	lea	GIFUNP(PC),A2
	bra.s	picunp
_tifunp	lea	TIFUNP(PC),A2
	bra.s	picunp
	include	picpac3.s
	elseif
_gifcalc	equ	bnderror
_tifcalc	equ	bnderror
_gifunp	equ	bnderror
_tifunp	equ	bnderror
	endc

	ifge	picpac-2
_imgpac	lea	IMGPAC(PC),A2
picpac_	move.w	4(SP),D0
	move.l	6(SP),A1	A4
	move.l	10(SP),A0	A3
	move.l	14(SP),D1
	movem.l	A3-A4,-(SP)
	move.l	A0,A3
	move.l	A1,A4
	jsr	(A2)
	movem.l	(SP)+,A3-A4
	rts
_lbmpac	lea	LBMPAC(PC),A2
	bra.s	picpac_
	include	picpac2.s
	elseif
_imgpac	equ	bnderror
_lbmpac	equ	bnderror
	endc

