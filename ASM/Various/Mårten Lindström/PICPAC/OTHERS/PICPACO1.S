
* With this source PLUS PICPAC1.S, PICPAC2.S and PICPAC3.S (from the
* assembler department) can an object file be created.
* Processor registers used indiscriminately.
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

_imgcalc	lea	IMGCALC(PC),A2
piccalc	moveq	#0,D3
	tst.w	4(SP)
	beq.s	.no_vrt
	moveq	#-1,D3
.no_vrt	move.w	6(SP),D3
	move.l	8(SP),A3
	move.l	12(SP),A4
	move.l	A3,D4	Make D4 non-zero
	link	A6,#-36
	move.l	A4,D0
	bne.s	.xmfdb
	lea	(SP),A4
.xmfdb	jsr	(A2)
	unlk	A6
	rts

_imgunp	lea	IMGUNP(PC),A2
picunp	moveq	#0,D3
	tst.w	4(SP)
	beq.s	.no_vrt
	moveq	#-1,D3
.no_vrt	move.w	6(SP),D3
	move.l	8(SP),A3
	move.l	12(SP),A4
	move.l	16(SP),(A4)
	ble.s	bnderror
	move.l	20(SP),D4
	ble.s	bnderror
	jsr	(A2)
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
	move.l	6(SP),A4
	move.l	10(SP),A3
	move.l	14(SP),D1
	jmp	(A2)
_lbmpac	lea	LBMPAC(PC),A2
	bra.s	picpac_
	include	picpac2.s
	elseif
_imgpac	equ	bnderror
_lbmpac	equ	bnderror
	endc

_plnfill	move.w	4(SP),D0
	move.l	6(SP),A4
	bra	PLNFILL
_getchnk	move.l	4(SP),D0
	move.l	8(SP),A3
	bsr	GETCHNK
	move.l	12(SP),A1
	move.l	A0,(A1)
	rts
_putfm	move.w	4(SP),D0
	move.l	6(SP),A3
	move.l	10(SP),A4
	bra	PUTFM
_getfm	move.l	4(SP),A3
	move.l	8(SP),A4
	bra	GETFM
_settru	move.l	4(SP),D0
	move.l	8(SP),A0
	bra	SETTRU
