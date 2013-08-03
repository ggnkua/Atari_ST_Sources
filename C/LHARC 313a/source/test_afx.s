
_onoff			EQU 8

				import	buffer_gen
				import	obj

				export	test_afx
				export	afxonoff


test_afx:		movem.l d3-d6/a2-a6,-(SP)
				move.l	a0,a4		; path

				move.l	buffer_gen,a5

				clr.w	-(SP)
				pea		(a4)
				move.w	#$3D,-(SP)	; Fopen
				trap	#1
				addq.w	#8,SP
				tst.l	D0
				bmi		_error

				move.l	D0,D3		; handle

				pea		(a5)
				pea 	2048.w
				move.w	D3,-(SP)
				move.w	#$3F,-(SP)	; Fread
				trap	#1
				lea 	12(SP),SP

				move.l	d0,d4		; len

				move.w	D3,-(SP)
				move.w	#$3E,-(SP)	; Fclose
				trap	#1
				addq.w	#4,SP

				tst.l	d4
				bmi		_error

				cmpi.w	#$601A,(a5)
				bne.b	no_prg

				tst.l	14(a5)		; ph_slen
				beq		is_prg

				tst.l	22(a5)		; ph_prgflags
				bne		is_prg

				tst.b	obj
				beq.b	is_prg
				bra.b	unpacked

no_prg:			movea.l	a5,a1
				move.w	d4,d0
				subq.w	#1,d0
				moveq.l	#'-',d1
				moveq.l	#0,d3

search_header:	cmp.b	(a1)+,d1
				bne.b	cont_search
				cmp.b	3(a1),d1
				bne.b	cont_search

				cmpi.b	#'l',(a1)
				beq.b	test_lzh
				cmpi.b	#'L',(a1)
				beq.b	test_lzh

				cmp.b	#'a',(a1)
				bne.b	cont_search
				cmp.b	#'f',1(a1)
				bne.b	cont_search
				cmp.b	#'x',2(a1)
				seq		d3
				beq.b	test_lzh

cont_search:	dbra	d0,search_header
				bra.b	unpacked

test_lzh:		subq.l	#3,a1

				cmp.b	#2,20(a1)
				beq.b	is_lzh

				move.l	a1,a0
				moveq.l	#0,D0
				moveq.l	#0,D1
				moveq.l	#0,D2

				move.b	(A0)+,D1
				move.b	(A0)+,D2
				subq.w	#1,D1

get_chk:		add.b	(A0)+,D0
				dbra	D1,get_chk

				cmp.b	D0,D2
				seq		D0
				bne.b	unpacked

				tst.w	d3
				bne.b	is_afx

is_lzh: 		moveq	#2,D0
				bra.b	testx

_error:			moveq.l	#-1,D0
				bra.b	testx

unpacked:		moveq	#0,D0
				bra.b	testx

is_afx: 		moveq	#1,D0
				bra.b	testx

is_prg: 		moveq	#3,D0
testx:			movem.l (SP)+,d3-d6/a2-a6
				rts


afxonoff:		movem.l d3-d6/a2-a6,-(SP)
				bsr.b	find_afx
				cmpa.l	#0,A4
				beq.b	onofX
				move.l	_onoff(A4),D1
				move.l	D0,_onoff(A4)
				move.l	D1,D0
onofX:			movem.l (SP)+,d3-d6/a2-a6
				rts

find_afx:		move.l	D0,-(SP)

				clr.l	-(SP)
				move.w	#$20,-(SP)	; Super
				trap	#1
				addq.l	#6,SP
				move.l	D0,-(SP)
				move.w	#$20,-(SP)

				movea.l $84.w,A4
find_afx1:		cmpi.l	#'XBRA',-12(A4)
				bne.b	no_afx
				cmpi.l	#'AFX ',-8(A4)
				beq.b	found_afx

				movea.l -4(A4),A4
				move.l	a4,d0
				bne.b	find_afx1

no_afx: 		trap	#1			; Super
				addq.l	#6,SP
				suba.l	A4,A4
				move.l	(SP)+,D0
				rts

found_afx:		subq.l	#8,a4
				subq.l	#8,a4
				move.l	(A4),D0
				add.w	d0,a4
				cmpi.l	#'PARX',-4(A4)
				bne.b	no_afx
				trap	#1			; Super
				addq.l	#6,SP
				move.l	(SP)+,D0
				rts

				END
