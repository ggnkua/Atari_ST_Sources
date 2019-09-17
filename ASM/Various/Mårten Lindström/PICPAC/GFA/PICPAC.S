
* With this source PLUS PICPAC1.S, PICPAC2.S and PICPAC3.S (from the
* assembler department) can an INLINE file be created.

picpac	set	3	to include all three picpac parts

* NOTE:	When creating an inline file, you should be aware that Devpac
*	unfortunately creates a program file header even for a file that
*	begins with an ORG directive (which automatically makes the header
*	useless anyway). My other assembler - Easy Rider - doesn't do that.
*	This means that you have to remove the first 18 bytes of the
*	"program" that you intend to use as an inline file. (The ending
*	zero longword is similarly useless - a "relocation table" - and
*	can also be removed.)
*			M†rten Lindstr”m
	ORG	0
	OUTPUT	PICPAC.INL
	jmp	_vdi_tru(PC)
	jmp	_tru_vdi(PC)
	jmp	_ste_tru(PC)
	jmp	_tru_ste(PC)
	jmp	_vdi_ste(PC)
	jmp	_ste_vdi(PC)
	jmp	_imgpac(PC)
	jmp	_lbmpac(PC)
	jmp	_imgcalc(PC)
	jmp	_imgunp(PC)
	jmp	_lbmcalc(PC)
	jmp	_lbmunp(PC)
	jmp	_degcalc(PC)
	jmp	_degunp(PC)
	jmp	_neocalc(PC)
	jmp	_neounp(PC)
	jmp	_gifcalc(PC)
	jmp	_gifunp(PC)
	jmp	_tifcalc(PC)
	jmp	_tifunp(PC)
	jmp	_plnfill(PC)
	jmp	_getchnk(PC)
	jmp	_putfm(PC)
	jmp	_getfm(PC)
	jmp	_settru(PC)

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
