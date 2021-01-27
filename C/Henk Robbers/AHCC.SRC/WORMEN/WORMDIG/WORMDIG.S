*	Created by TT-Digger v5.4
*	Mon Nov 02 23:43:58 1998

*	TTD_5

*				TEXT	7916 bytes, segment starts at __text
*				DATA	652 bytes, segment starts at __data
*				BSS		12312 bytes, segment starts at _BasPag
*				SYMBOLS	2198 bytes
*				FLAG	$0000
*				External names not listed 


				.text

__text:			movea.l	a0,a3
				move.l	a3,d0
				bne.s	L14
				movea.l	4(a7),a3
				moveq	#1,d0
				bra.s	L16

L14:			clr 	d0
L16:			move.l	a3,_BasPag
				move 	d0,_app
				movea.l	12(a3),a0
				adda.l	20(a3),a0
				adda.l	28(a3),a0
				adda 	#256,a0
				move.l	a0,_PgmSize
				move.l	a3,d0
				add.l	a0,d0
				and.b	#252,d0
				movea.l	d0,a7
				sub.l	#3840,d0
				move.l	d0,_StkLim
				tst 	_app
				beq.w	L254
				sub.l	#250,d0
				and.b	#252,d0
				movea.l	d0,a1
				movea.l	a1,a4
				movea.l	44(a3),a2
				move.l	a2,(a1)+
L102:			tst.b	(a2)+
				bne.s	L102
				move.l	a2,(a1)+
				tst.b	(a2)+
				bne.s	L102
				clr.l	-(a1)
				move.l	a0,-(a7)
				move.l	a3,-(a7)
				move 	#0,-(a7)
				move 	#74,-(a7)		; Mshrink
				trap	#1				; Gemdos
				lea 	12(a7),a7
				lea 	128(a3),a0
				move.b	(a0),d1
				cmp.b	#126,d1
				bmi.s	L158
				addq.l	#1,a0
				moveq	#-1,d1
L148:			addq 	#1,d1
				move.b	(a0)+,d0
				bne.s	L148
				lea 	128(a3),a0
L158:			move 	#1,d3
				ext 	d1
				lea 	1(a0,d1),a1
				clr.b	(a1)
				clr.l	-(a7)
				bra.s	L228

L174:			cmpi.b	#33,(a1)
				bpl.s	L196
				clr.b	(a1)
				tst.b	1(a1)
				beq.s	L196
				pea 	1(a1)
				addq 	#1,d3
				bra.s	L228

L196:			cmpi.b	#34,(a1)
				bne.s	L228
				move.b	#0,(a1)
L206:			subq 	#1,a1
				cmpi.b	#34,(a1)
				dbeq	d1,L206
				subq 	#1,d1
				bmi.s	L234
				pea 	1(a1)
				addq 	#1,d3
				clr.b	(a1)
L228:			subq.l	#1,a1
				dbf		d1,L174
L234:			tst.b	1(a1)
				beq.s	L246
				pea 	1(a1)
				addq 	#1,d3
L246:			pea 	T7996
				movea.l	a7,a2
L254:			move 	d3,d0
				movea.l	a2,a0
				movea.l	a4,a1
				jsr 	main
exit:			move 	d0,-(a7)
				move.l	_AtExitV,d0
				beq.s	__exit
				movea.l	d0,a0
				jsr 	(a0)
__exit:			move.l	_FilSysV,d0
				beq.s	L292
				movea.l	d0,a0
				jsr 	(a0)
L292:			jsr 	_FreeAll
				move 	#76,-(a7)		; Pterm
				trap	#1				; Gemdos
rnd:			movem.l	d3-d5,-(a7)
				move 	d0,d5
				move 	d1,d4
				move 	d2,d3
				jsr 	Random
				move 	d5,d1
				ext.l	d1
				add.l	d1,d0
				move 	d4,d2
				ext.l	d2
				sub.l	d2,d0
				move 	d3,d1
				ext.l	d1
				add.l	d1,d0
				fmove.l	d0,fp0
				fdiv.x	T8138,fp0
				movem.l	(a7)+,d3-d5
				rts

main:			movem.l	d3/a2-a6,-(a7)
L360:			lea 	-20(a7),a7
				lea 	12(a7),a2
				lea 	r,a6
				lea 	26(a6),a0
				movea.l	a2,a1
				move.b	(a0)+,(a1)+
				move.b	(a0)+,(a1)+
				move.b	(a0)+,(a1)+
				move.b	(a0)+,(a1)+
				move.b	(a0)+,(a1)+
				move.b	(a0)+,(a1)+
				move.b	(a0)+,(a1)+
				move.b	(a0)+,(a1)+
				jsr 	appl_ini
				lea 	T8150,a0
				jsr 	rsrc_loa
				tst 	d0
				bne.s	L444
				lea 	T8160,a0
				moveq	#1,d0
				jsr 	form_ale
				jsr 	appl_exi
L438:			moveq	#1,d0
				bra.w	L1730

L444:			lea 	j,a5
				suba.l	a1,a1
				lea 	-4(a5),a0
				jsr 	instt_sc
				fmove	scr,fp0
				fmove.x	fp0,-36(a6)
				fmove	U12998,fp1
				fmove.x	fp1,-24(a6)
				move 	scr,4(a2)
				move 	U12998,6(a2)
				movea.l	a2,a0
				moveq	#1,d1
				move 	-4(a5),d0
				jsr 	vs_clip
				lea 	4(a5),a0
				clr 	d1
				clr 	d0
				jsr 	rsrc_gad
				movea.l	4(a5),a0
				move.l	132(a0),8(a5)
				movea.l	4(a5),a0
				move.l	156(a0),12(a5)
				movea.l	4(a5),a0
				move.l	180(a0),16(a5)
				movea.l	4(a5),a0
				move.l	204(a0),20(a5)
				movea.l	4(a5),a0
				move.l	228(a0),24(a5)
				pea 	4(a7)
				pea 	10(a7)
				pea 	16(a7)
				lea 	22(a7),a1
				movea.l	4(a5),a0
				jsr 	form_cen
				lea 	12(a7),a7
L614:			lea 	-354(a5),a4
				lea 	-270(a5),a3
				suba.l	a0,a0
				clr 	d0
				jsr 	graf_mou
				movea.l	4(a5),a0
				andi 	#-2,322(a0)
				movea.l	4(a5),a0
				andi 	#-2,250(a0)
				movea.l	4(a5),a0
				andi 	#-2,298(a0)
				move 	-4(a5),d1
				clr 	d0
				movea.l	4(a5),a0
				jsr 	form_sav
				move.l	a0,(a7)
				pea 	scr_grec
				moveq	#1,d0
				move 	d0,-(a7)
				moveq	#5,d2
				move 	d0,d1
				movea.l	a0,a1
				movea.l	4(a5),a0
				move 	-4(a5),d0
				jsr 	form_mov
				addq 	#6,a7
				move 	d0,d3
				movea.l	(a7),a1
				move 	-4(a5),d1
				movea.l	4(a5),a0
				clr 	d0
				jsr 	form_res
				cmp 	#10,d3
				beq.w	L1712
				suba.l	a0,a0
				move 	#256,d0
				jsr 	graf_mou
				clr 	-(a7)
				clr 	-(a7)
				moveq	#1,d2
				moveq	#1,d1
				move 	-4(a5),d0
				jsr 	deffill
				addq 	#4,a7
				moveq	#3,d1
				move 	-4(a5),d0
				jsr 	vswr_mod
				cmp 	#13,d3
				beq.s	L806
				cmp 	#12,d3
				bne.w	L1154
				move 	24(a6),d0
				bne.w	L1154
L806:			move 	#1,24(a6)
				movea.l	8(a5),a0
				movea.l	(a0),a0
				jsr 	atoi
				move 	d0,6(a6)
				cmp 	#50,d0
				ble.s	L840
				move 	#50,6(a6)
L840:			movea.l	12(a5),a0
				movea.l	(a0),a0
				jsr 	atoi
				move 	d0,8(a6)
				cmp 	#20,d0
				ble.s	L868
				move 	#20,8(a6)
L868:			movea.l	16(a5),a0
				movea.l	(a0),a0
				jsr 	atoi
				move 	d0,4(a6)
				movea.l	20(a5),a0
				movea.l	(a0),a0
				jsr 	atoi
				move 	d0,(a6)
				movea.l	24(a5),a0
				movea.l	(a0),a0
				jsr 	atoi
				move 	d0,2(a6)
				fmove	4(a6),fp0
L918			equ		*-2
				fmul.x	-48(a6),fp0
				fdiv.x	-12(a6),fp0
				fmove.x	fp0,-18(a5)
				move 	-4(a5),d0
				jsr 	v_clrwk
				clr 	(a5)
				bra.s	L1012

L952:			clr 	-2(a5)
				bra.s	L1002

L958:			moveq	#100,d0
				muls	(a5),d0
				move 	-2(a5),d1
				add 	d1,d1
				add 	d1,d0
				lea 	-4354(a5),a0
				clr 	0(a0,d0)
				moveq	#100,d0
				muls	(a5),d0
				move 	-2(a5),d1
				add 	d1,d1
				add 	d1,d0
				lea 	-2354(a5),a1
				clr 	0(a1,d0)
				addq 	#1,-2(a5)
L1002:			cmpi 	#50,-2(a5)
				blt.s	L958
				addq 	#1,(a5)
L1012:			cmpi 	#20,(a5)
				blt.s	L952
				clr 	(a5)
				bra.s	L1144

L1022:			moveq	#3,d2
				moveq	#2,d1
				moveq	#1,d0
				bsr.w	rnd
				fmul.x	-36(a6),fp0
				fintrz	fp0
				fmove	fp0,d0
				moveq	#100,d1
				muls	(a5),d1
				lea 	-4354(a5),a0
				move 	d0,0(a0,d1)
				moveq	#4,d2
				moveq	#3,d1
				moveq	#2,d0
				bsr.w	rnd
				fmul.x	-24(a6),fp0
				fintrz	fp0
				fmove	fp0,d0
				moveq	#100,d1
				muls	(a5),d1
				lea 	-2354(a5),a0
				move 	d0,0(a0,d1)
				moveq	#5,d2
				moveq	#4,d1
				moveq	#3,d0
				bsr.w	rnd
				fmul.x	T8188,fp0
				fmul.x	-48(a6),fp0
				move 	(a5),d1
				move 	d1,d0
				add 	d0,d0
				add 	d1,d0
				lsl 	#2,d0
				fmove.x	fp0,0(a3,d0)
				move 	(a5),d0
				add 	d0,d0
				clr 	0(a4,d0)
				addq 	#1,(a5)
L1144:			move 	(a5),d0
				cmp 	8(a6),d0
				blt.w	L1022
L1154:			moveq	#6,d2
				moveq	#5,d1
				moveq	#4,d0
				bsr.w	rnd
				fmul	8(a6),fp0
				fintrz	fp0
				fmove	fp0,d0
				move 	d0,(a5)
				add 	d0,d0
				move 	(a5),d1
				add 	d1,d1
				lea 	-314(a5),a0
				move 	0(a4,d0),0(a0,d1)
				move 	(a5),d0
				add 	d0,d0
				move 	0(a4,d0),d1
				ext.l	d1
				divs	6(a6),d1
				swap	d1
				addq 	#1,d1
				move 	d1,0(a4,d0)
				moveq	#100,d0
				muls	(a5),d0
				add 	d1,d1
L1224:			add 	d1,d0
				lea 	-4354(a5),a1
				move 	0(a1,d0),d2
				move 	d2,4(a2)
				move 	d2,(a2)
				lea 	-2354(a5),a0
				move 	0(a0,d0),d3
				move 	d3,6(a2)
				move 	d3,2(a2)
				move 	(a2),d2
				bne.s	L1264
				tst 	d3
				beq.s	L1298
L1264:			move 	(a6),-(a7)
				move 	2(a2),d2
				move 	(a2),d1
				move 	-4(a5),d0
				jsr 	v_circle
L1282:			addq 	#2,a7
				movea.l	a2,a0
				moveq	#2,d1
				move 	-4(a5),d0
				jsr 	v_pline
L1298:			moveq	#7,d2
				moveq	#6,d1
				moveq	#5,d0
				bsr.w	rnd
				fmove.x	fp0,-30(a5)
				fcmp.x	T8200,fp0
				fbge.w	L1356
				move 	(a5),d1
				move 	d1,d0
				add 	d0,d0
				add 	d1,d0
				lsl 	#2,d0
				fmove.x	0(a3,d0),fp1
				fadd.x	-18(a5),fp1
				fmove.x	fp1,0(a3,d0)
				bra.s	L1384

L1356:			move 	(a5),d1
				move 	d1,d0
				add 	d0,d0
				add 	d1,d0
				lsl 	#2,d0
				fmove.x	0(a3,d0),fp0
				fsub.x	-18(a5),fp0
				fmove.x	fp0,0(a3,d0)
L1384:			move 	(a5),d1
				move 	d1,d0
				add 	d0,d0
				add 	d1,d0
				lsl 	#2,d0
				fcos.x	0(a3,d0),fp0
				fmul	2(a6),fp0
				fintrz	fp0
				fmove	fp0,d2
				moveq	#100,d3
				muls	d1,d3
				add 	d1,d1
				lea 	-314(a5),a0
				move 	0(a0,d1),d0
				add 	d0,d0
				add 	d0,d3
				lea 	-4354(a5),a1
				add 	0(a1,d3),d2
				ext.l	d2
				divs	scr,d2
				swap	d2
				move 	d2,-274(a5)
				move 	(a5),d1
				move 	d1,d0
				add 	d0,d0
				add 	d1,d0
				lsl 	#2,d0
				fsin.x	0(a3,d0),fp0
				fmul	2(a6),fp0
				fintrz	fp0
				fmove	fp0,d3
				moveq	#100,d2
				muls	d1,d2
				add 	d1,d1
				lea 	-314(a5),a0
				move 	0(a0,d1),d0
				add 	d0,d0
				add 	d0,d2
				lea 	-2354(a5),a1
				add 	0(a1,d2),d3
				ext.l	d3
				divs	U12998,d3
				swap	d3
				move 	d3,-272(a5)
				move 	-274(a5),d0
				bpl.s	L1540
				move 	scr,d1
				add 	d1,-274(a5)
L1540:			move 	-272(a5),d0
				bpl.s	L1556
				move 	U12998,d1
				add 	d1,-272(a5)
L1556:			moveq	#100,d0
				muls	(a5),d0
				move 	(a5),d1
				add 	d1,d1
				move 	0(a4,d1),d2
				add 	d2,d2
				add 	d2,d0
				lea 	-4354(a5),a0
				move 	-274(a5),0(a0,d0)
				moveq	#100,d0
				muls	(a5),d0
				move 	(a5),d1
				add 	d1,d1
				move 	0(a4,d1),d2
				add 	d2,d2
				add 	d2,d0
				lea 	-2354(a5),a1
				move 	-272(a5),0(a1,d0)
				move 	(a6),-(a7)
				move 	-272(a5),d2
				move 	-274(a5),d1
				move 	-4(a5),d0
				jsr 	v_circle
				addq 	#2,a7
				move 	#255,d0
				jsr 	Crawio
				move 	d0,2(a5)
				tst 	d0
				beq.w	L1154
				andi 	#255,2(a5)
				cmpi 	#32,2(a5)
				bne.s	L1680
				moveq	#2,d0
				jsr 	Bconin
				and 	#255,d0
				move 	d0,2(a5)
L1680:			cmpi 	#99,2(a5)
				beq.w	L1154
				suba.l	a0,a0
				move 	#257,d0
				jsr 	graf_mou
				cmpi 	#113,2(a5)
				bne.w	L614
L1712:			move 	-4(a5),d0
				jsr 	v_clsvwk
				jsr 	appl_exi
				clr 	d0
L1730:			lea 	20(a7),a7
				movem.l	(a7)+,d3/a2-a6
				rts

L1740:			link	a6,#-16
				movem.l	d4-d7/a2,-(a7)
				move 	d0,d5
				move 	d1,-8(a6)
				clr 	d2
				move 	#8,d6
				move 	#1,d4
				move 	-8(a6),d0
				cmp 	#-3,d0
				beq.s	L1854
				cmp 	#-2,d0
				beq.s	L1846
				cmp 	#-1,d0
				beq.s	L1842
L1786:			tst 	d2
				blt.s	L1838
				move 	#24,d0
				muls	d2,d0
				lea 	0(a2,d0.l),a0
				move 	8(a0),d7
				move 	d7,d0
				and 	d6,d0
				beq.s	L1820
				move 	d2,d0
L1812:			movem.l	(a7)+,d4-d7/a2
				unlk	a6
				rts

L1820:			move 	d7,d0
				and 	#32,d0
				beq.s	L1834
				move 	#-1,d2
				bra.s	L1786

L1834:			add 	d4,d2
				bra.s	L1786

L1838:			move 	d5,d0
				bra.s	L1812

L1842:			move 	#-1,d4
L1846:			move 	d5,d0
				add 	d4,d0
				move 	d0,d2
				bra.s	L1786

L1854:			move 	#2,d6
				bra.s	L1786

init_fie:		movem.l	d3/a2,-(a7)
				movea.l	a0,a2
				move 	d0,d3
				bne.s	L1888
				movea.l	a2,a0
				move 	#0,d0
				move 	#-2,d1
				jsr 	L1740
				move 	d0,d3
L1888:			move 	d3,d0
				movem.l	(a7)+,d3/a2
				rts

aform_do:		link	a6,#-34
				movem.l	d3-d6/a2-a3,-(a7)
				movea.l	a0,a2
				movea.l	a1,a3
				move 	d1,d5
				jsr 	init_fie
				move 	d0,-16(a6)
				clr 	d3
				move 	#1,d4
				move 	#1,d0
				jsr 	wind_upd
				move 	#3,d0
				jsr 	wind_upd
L1946:			tst 	d4
				beq.w	L2308
				tst 	-16(a6)
				beq.s	L1994
				cmp 	-16(a6),d3
				beq.s	L1994
				move 	-16(a6),d3
				clr 	-16(a6)
				movea.l	a2,a0
				move 	d3,d0
				move 	#0,d1
				lea 	-22(a6),a1
				move 	#1,d2
				jsr 	objc_edi
L1994:			pea 	-34(a6)
				pea 	-32(a6)
				pea 	-30(a6)
				pea 	-28(a6)
				pea 	-26(a6)
				move 	#0,-(a7)
				move 	#0,-(a7)
				move 	#0,-(a7)
				move 	#0,-(a7)
				move 	#0,-(a7)
				move 	#0,-(a7)
				move 	#0,-(a7)
				move 	#0,-(a7)
				move 	#0,-(a7)
				move 	#0,-(a7)
				move 	#0,-(a7)
				move 	#0,-(a7)
				move 	#1,-(a7)
				move 	#3,d0
				move 	#2,d1
				move 	#1,d2
				suba.l	a0,a0
				lea 	-24(a6),a1
				jsr 	evnt_mul
				adda 	#46,a7
				move 	d0,d6
				and 	#1,d0
				beq.s	L2160
				pea 	-32(a6)
				movea.l	a2,a0
				move 	d3,d0
				move 	-16(a6),d1
				move 	-32(a6),d2
				lea 	-16(a6),a1
				jsr 	form_key
				addq 	#4,a7
				move 	d0,d4
				tst 	-32(a6)
				beq.s	L2160
				movea.l	a2,a0
				move 	d3,d0
				move 	-32(a6),d1
				lea 	-22(a6),a1
				move 	#2,d2
				jsr 	objc_edi
L2160:			move 	d6,d0
				and 	#2,d0
				beq.s	L2218
				move 	-26(a6),-(a7)
				movea.l	a2,a0
				move 	#0,d0
				move 	#8,d1
				move 	-24(a6),d2
				jsr 	objc_fin
				addq 	#2,a7
				move 	d0,-16(a6)
				cmp 	#-1,d0
				bne.s	L2266
				move 	#7,d0
				jsr 	Cconout
				clr 	-16(a6)
L2218:			tst 	d4
				beq.s	L2240
				tst 	-16(a6)
				beq.w	L1946
				move 	-16(a6),d0
				cmp 	d3,d0
				beq.w	L1946
L2240:			movea.l	a2,a0
				move 	d3,d0
				move 	#0,d1
				lea 	-22(a6),a1
				move 	#3,d2
				jsr 	objc_edi
				bra.w	L1946

L2266:			tst 	d5
				beq.s	L2286
				move 	-16(a6),d0
				cmp 	d5,d0
				bne.s	L2286
				move 	#0,d0
L2282:			move 	d0,d4
				bra.s	L2218

L2286:			movea.l	a2,a0
				move 	-16(a6),d0
				move 	-34(a6),d1
				lea 	-16(a6),a1
				jsr 	form_but
				bra.s	L2282

L2308:			move 	#2,d0
				jsr 	wind_upd
				move 	#0,d0
				jsr 	wind_upd
				cmpa 	#0,a3
				beq.s	L2336
				move 	d3,(a3)
L2336:			move 	-16(a6),d0
				movem.l	(a7)+,d3-d6/a2-a3
				unlk	a6
				rts

get_cook:		movem.l	d3/a2-a3,-(a7)
				move.l	d0,d3
				movea.l	a0,a3
				suba.l	a0,a0
				jsr 	Super
				move.l	d0,sstack
				movea.l	1440.w,a2
				movea.l	d0,a0
				jsr 	Super
				move.l	a2,d0
				bne.s	L2406
				bra.s	L2410

L2388:			cmp.l	(a2),d3
				bne.s	L2404
				move.l	a3,d0
				beq.s	L2400
				move.l	4(a2),(a3)
L2400:			moveq	#1,d0
				bra.s	L2412

L2404:			addq 	#8,a2
L2406:			move.l	(a2),d0
				bne.s	L2388
L2410:			clr 	d0
L2412:			movem.l	(a7)+,d3/a2-a3
				rts

copy_gfo:		movem.l	d3/a2-a4,-(a7)
				move 	d0,d3
				movea.l	a0,a4
				movea.l	a1,a3
				lea 	20(a7),a2
				moveq	#-1,d0
				add 	(a2),d0
				add 	d0,4(a2)
				moveq	#-1,d0
				add 	2(a2),d0
				add 	d0,6(a2)
				moveq	#-1,d0
				add 	8(a2),d0
				add 	d0,12(a2)
				moveq	#-1,d0
				add 	10(a2),d0
				add 	d0,14(a2)
				move.l	a3,-(a7)
				movea.l	a4,a1
				movea.l	a2,a0
				moveq	#3,d1
				move 	d3,d0
				jsr 	vro_cpyf
				addq 	#4,a7
				movem.l	(a7)+,d3/a2-a4
				rts

instt_sc:		movem.l	d3/a2-a6,-(a7)
				subq 	#2,a7
				movea.l	a0,a4
				movea.l	a1,a5
				lea 	_fhc,a2
				lea 	scr,a3
				pea 	(a7)
				pea 	4(a7)
				movea.l	a2,a1
				lea 	1814(a3),a0
				jsr 	graf_han
				addq 	#8,a7
				move 	d0,(a4)
				clr 	d3
				bra.s	L2554

L2542:			move 	d3,d0
				add 	d0,d0
				move 	#1,0(a3,d0)
				addq 	#1,d3
L2554:			cmp 	#10,d3
				ble.s	L2542
				move 	#2,20(a3)
				pea 	(a3)
				movea.l	a4,a1
				movea.l	a3,a0
				jsr 	v_opnvwk
				addq 	#4,a7
				move 	(a4),146(a3)
				moveq	#1,d1
				move 	(a4),d0
				jsr 	vsf_inte
				clr 	d1
				move 	(a4),d0
				jsr 	vsf_styl
				clr 	d1
				move 	(a4),d0
				jsr 	vsf_colo
				clr 	d1
				move 	(a4),d0
				jsr 	vsf_peri
				lea 	(a7),a1
				lea 	(a7),a0
				moveq	#4,d2
				clr 	d1
				move 	(a4),d0
				jsr 	vst_alig
				lea 	instmfdb,a6
				move 	(a3),-24(a6)
				move 	2(a3),-22(a6)
				addq 	#1,(a3)
				addq 	#1,2(a3)
				move 	(a3),1818(a3)
				move 	2(a3),1816(a3)
				move 	1818(a3),-32(a6)
				move 	1816(a3),-30(a6)
				move 	70(a3),d0
				beq.s	L2694
				moveq	#-1,d1
				bra.s	L2696

L2694:			moveq	#1,d1
L2696:			move 	d1,70(a3)
				move 	(a2),132(a3)
				move 	1814(a3),130(a3)
				move 	26(a3),d3
				lea 	148(a3),a0
				moveq	#1,d1
				move 	(a4),d0
				jsr 	vq_extnd
				lea 	1810(a3),a4
				move 	156(a3),(a4)
				move 	(a4),122(a3)
				move 	(a3),d0
				ext.l	d0
				move 	2(a3),d1
				ext.l	d1
				jsr 	_lmul
				move 	(a4),d1
				ext.l	d1
				jsr 	_lmul
				moveq	#8,d1
				jsr 	_ldiv
				move.l	d0,126(a3)
				suba.l	a0,a0
				move.l	#1229803077,d0
				jsr 	get_cook
				move 	d0,1822(a3)
				suba.l	a0,a0
				move.l	#1599353431,d0
				jsr 	get_cook
				move 	d0,1824(a3)
				suba.l	a0,a0
				move.l	#1298229080,d0
				jsr 	get_cook
				move 	d0,1826(a3)
				suba.l	a0,a0
				move.l	#1298746964,d0
				jsr 	get_cook
				move 	d0,1828(a3)
				cmpi 	#4,(a4)
				bne.s	L2868
				cmpi 	#8,(a2)
				bne.s	L2868
				clr 	124(a3)
				bra.s	L2886

L2868:			cmpi 	#2,(a4)
				bne.s	L2926
				cmpi 	#8,(a2)
				bne.s	L2926
				move 	#1,124(a3)
L2886:			cmpi 	#512,78(a3)
				ble.s	L2898
				moveq	#3,d0
				bra.s	L2900

L2898:			moveq	#2,d0
L2900:			move 	d0,134(a3)
				cmpi 	#512,78(a3)
L2910:			ble.s	L2916
				moveq	#16,d1
				bra.s	L2918

L2916:			clr 	d1
L2918:			move 	d1,142(a3)
				bra.w	L3112

L2926:			cmpi 	#1,(a4)
				bne.s	L2994
				cmpi 	#16,(a2)
				bne.s	L2994
				cmpi 	#-1,70(a3)
				bne.s	L2966
				move 	#3,134(a3)
L2952:			move 	#2,124(a3)
L2958:			clr 	142(a3)
				bra.w	L3112

L2966:			cmpi 	#1024,(a3)
				ble.s	L2986
				move 	#5,124(a3)
				move 	#3,134(a3)
				bra.s	L2958

L2986:			move 	#2,134(a3)
				bra.s	L2952

L2994:			cmpi 	#8,(a4)
				bne.s	L3030
				cmpi 	#16,(a2)
				bne.s	L3030
				move 	(a3),d0
				cmp 	2(a3),d0
				ble.s	L3022
				move 	#6,124(a3)
				bra.s	L3084

L3022:			move 	#3,124(a3)
				bra.s	L3048

L3030:			cmpi 	#4,(a4)
				bne.s	L3056
				cmpi 	#16,(a2)
				bne.s	L3056
				move 	#4,124(a3)
L3048:			move 	#3,134(a3)
				bra.s	L3090

L3056:			cmpi 	#8,(a4)
				ble.s	L3098
				move 	158(a3),d0
				bne.s	L3098
				cmpi 	#16,(a4)
				bne.s	L3078
				moveq	#7,d1
				bra.s	L3080

L3078:			moveq	#8,d1
L3080:			move 	d1,124(a3)
L3084:			move 	#1,134(a3)
L3090:			move 	#16,142(a3)
				bra.s	L3112

L3098:			lea 	T8331,a0
				moveq	#1,d0
				jsr 	form_ale
L3112:			move 	(a3),d0
				ext.l	d0
				move.l	d0,114(a3)
				move 	2(a3),d1
				ext.l	d1
				move.l	d1,118(a3)
				move 	(a3),d0
				ext.l	d0
				divs	1814(a3),d0
				muls	(a4),d0
				move 	d0,138(a3)
				moveq	#-1,d1
				add 	(a4),d1
				add 	d1,d1
				move 	d1,140(a3)
				move 	138(a3),d0
				ext.l	d0
				divs	#2,d0
				move 	d0,136(a3)
				move 	d0,1820(a3)
				move 	138(a3),1808(a3)
				move.l	a5,d0
				beq.s	L3188
				move.l	d0,1802(a3)
				bra.s	L3228

L3188:			move.l	126(a3),d0
				add.l	#512,d0
				jsr 	Malloc
				move.l	a0,1802(a3)
				move.l	a0,d0
				bne.s	L3228
				moveq	#1,d0
				movea.l	-40(a6),a0
				jsr 	form_ale
				suba.l	a0,a0
				bra.s	L3340

L3228:			move.l	1802(a3),d0
				asr.l	#8,d0
				addq.l	#1,d0
				lsl.l	#8,d0
				move.l	d0,1802(a3)
				jsr 	Physbase
				move.l	a0,1798(a3)
				move.l	a0,d0
				move.l	1802(a3),d1
				eor.l	d1,d0
				move.l	d0,1834(a3)
				jsr 	Logbase
				move.l	a0,1830(a3)
				move 	1818(a3),4(a6)
				move 	1816(a3),6(a6)
				move 	1818(a3),d0
				ext.l	d0
				divs	#16,d0
				move 	d0,8(a6)
				move 	(a4),12(a6)
				clr 	1838(a3)
				clr 	1840(a3)
				move 	1818(a3),1842(a3)
				move 	1816(a3),1844(a3)
				lea 	1838(a3),a0
				lea 	1846(a3),a1
				move.l	(a0)+,(a1)+
				move.l	(a0)+,(a1)+
				movea.l	1802(a3),a0
L3340:			addq 	#2,a7
				movem.l	(a7)+,d3/a2-a6
				rts

L3348:			move.l	a2,-(a7)
				lea 	-12(a7),a7
				lea 	U14858,a2
				move 	(a2),d0
				add 	d0,16(a2)
				move 	2(a2),d0
				add 	d0,18(a2)
				lea 	32(a2),a0
				move.l	-(a0),-(a7)
				move.l	-(a0),-(a7)
				lea 	24(a2),a0
				move.l	-(a0),-(a7)
				move.l	-(a0),-(a7)
				lea 	16(a7),a1
				lea 	18(a7),a0
				move 	32(a2),d1
				move 	form_out,d0
				pea 	20(a7)
				jsr 	snapbox
				lea 	20(a7),a7
				lea 	4(a7),a0
				lea 	-8(a2),a1
				move.l	(a0)+,(a1)+
				move.l	(a0)+,(a1)+
				move 	2(a7),d0
				beq.s	L3446
				move 	-8(a2),16(a2)
L3446:			move 	(a7),d0
				beq.s	L3456
				move 	-6(a2),18(a2)
L3456:			lea 	12(a7),a7
				movea.l	(a7)+,a2
				rts

aform_mo:		movem.l	d3-d5/a2-a5,-(a7)
				lea 	-56(a7),a7
				movea.l	a0,a4
				move 	d2,d5
				move 	92(a7),d4
				clr 	d3
				lea 	MFDBnull,a0
				lea 	36(a7),a2
				moveq	#4,d2
L3494:			move.l	(a0)+,(a2)+
				dbf		d2,L3494
				lea 	16(a7),a2
				lea 	MFDBnull,a0
				movea.l	a2,a3
				moveq	#4,d2
L3514:			move.l	(a0)+,(a3)+
				dbf		d2,L3514
				move 	d0,form_hnd
				lea 	U14850,a5
				movea.l	94(a7),a0
				lea 	32(a5),a3
				move.l	(a0)+,(a3)+
				move.l	(a0)+,(a3)+
				move 	d1,40(a5)
				move.l	a1,(a2)
L3550:			pea 	(a2)
				move.l	a4,-(a7)
				clr 	d0
				movea.l	a5,a1
				lea 	8(a7),a0
				jsr 	form_set
				addq 	#8,a7
				movea.l	a5,a0
				lea 	8(a7),a1
				move.l	(a0)+,(a1)+
				move.l	(a0)+,(a1)+
				move 	d4,d1
				movea.l	88(a7),a1
				move 	d5,d0
				movea.l	a4,a0
				jsr 	aform_do
				move 	d0,d3
				cmp 	d0,d4
				bne.w	L3818
				suba.l	a0,a0
				move 	#256,d0
				jsr 	graf_mou
				lea 	16(a7),a0
				move.l	-(a0),-(a7)
				move.l	-(a0),-(a7)
				move.l	-(a0),-(a7)
				move.l	-(a0),-(a7)
				lea 	52(a7),a1
				movea.l	a2,a0
				move 	form_hnd,d0
				jsr 	copy_gfo
				lea 	16(a7),a7
				suba.l	a0,a0
				move 	#257,d0
				jsr 	graf_mou
				pea 	L3348(pc)
				moveq	#1,d1
				lea 	8(a5),a1
				movea.l	a5,a0
				move 	form_hnd,d0
				jsr 	movebox
				addq 	#4,a7
				move 	(a5),d0
				add 	form_out,d0
				move 	d0,16(a4)
				move 	2(a5),d1
				add 	form_out,d1
				move 	d1,18(a4)
				pea 	(a2)
				move.l	a4,-(a7)
				clr 	d0
				lea 	8(a7),a1
				lea 	16(a7),a0
				jsr 	form_set
				addq 	#8,a7
				suba.l	a0,a0
				move 	#256,d0
				jsr 	graf_mou
				lea 	16(a7),a0
				move.l	-(a0),-(a7)
				move.l	-(a0),-(a7)
				move.l	-(a0),-(a7)
				move.l	-(a0),-(a7)
				movea.l	a2,a1
				lea 	52(a7),a0
				move 	form_hnd,d0
				jsr 	copy_gfo
				lea 	16(a7),a7
				suba.l	a0,a0
				move 	#257,d0
				jsr 	graf_mou
				lea 	8(a5),a0
				move.l	-(a0),-(a7)
				move.l	-(a0),-(a7)
				clr 	d0
				movea.l	a4,a0
				jsr 	draw_ob
				addq 	#8,a7
				bra.w	L3550

L3818:			move 	d3,d0
				lea 	56(a7),a7
				movem.l	(a7)+,d3-d5/a2-a5
				rts

form_mov:		move.l	6(a7),-(a7)
				move 	8(a7),-(a7)
				clr.l	-(a7)
				bsr.w	aform_mo
				lea 	10(a7),a7
				rts

draw_ob:		movem.l	d3/a2-a3,-(a7)
				movea.l	a0,a3
				move 	d0,d3
				lea 	16(a7),a2
				move 	6(a2),-(a7)
				move 	4(a2),-(a7)
				move 	2(a2),-(a7)
				move 	(a2),d2
				moveq	#8,d1
				move 	d3,d0
				movea.l	a3,a0
				jsr 	objc_dra
				addq 	#6,a7
				movem.l	(a7)+,d3/a2-a3
				rts

form_set:		movem.l	d3/a2-a5,-(a7)
				subq 	#4,a7
				movea.l	a0,a2
				movea.l	a1,a4
				move 	d0,d3
				movea.l	32(a7),a5
				pea 	(a7)
				lea 	6(a7),a1
				movea.l	32(a7),a0
				jsr 	objc_off
				addq 	#4,a7
				lea 	form_out,a3
				move 	#3,(a3)
				move 	2(a7),d0
				sub 	(a3),d0
				move 	d0,(a4)
				move 	(a7),d1
				sub 	(a3),d1
				move 	d1,2(a4)
				move 	(a3),d0
				add 	d0,d0
				move 	d3,d1
				ext.l	d1
				move.l	d1,d2
				add.l	d2,d2
				add.l	d1,d2
				lsl.l	#3,d2
				movea.l	28(a7),a0
				add 	20(a0,d2.l),d0
				move 	d0,4(a4)
				move 	(a3),d0
				add 	d0,d0
				add 	22(a0,d2.l),d0
				move 	d0,6(a4)
				move 	4(a4),d3
				asr 	#4,d3
				addq 	#1,d3
				lsl 	#4,d3
				move 	d3,4(a5)
				move 	6(a4),6(a5)
				move 	4(a5),d0
				ext.l	d0
				divs	#16,d0
				move 	d0,8(a5)
				lea 	scr,a0
				move 	156(a0),12(a5)
				move 	2(a7),d0
				cmp 	(a3),d0
				bge.s	L4052
				clr 	(a4)
L4052:			move 	(a7),d0
				cmp 	(a3),d0
				bge.s	L4062
				clr 	2(a4)
L4062:			move 	4(a4),d0
				add 	(a4),d0
				cmp 	(a0),d0
				ble.s	L4080
				move 	(a0),d1
				sub 	(a4),d1
				move 	d1,4(a4)
L4080:			move 	6(a4),d0
				add 	2(a4),d0
				cmp 	2(a0),d0
				ble.s	L4106
				move 	2(a0),d1
				sub 	2(a4),d1
				move 	d1,6(a4)
L4106:			clr 	(a2)
				clr 	2(a2)
				move 	4(a4),4(a2)
				move 	6(a4),6(a2)
				addq 	#4,a7
				movem.l	(a7)+,d3/a2-a5
				rts

form_sav:		movem.l	d3-d4/a2-a3,-(a7)
				lea 	-56(a7),a7
				movea.l	a0,a3
				move 	d0,d3
				move 	d1,d4
				lea 	MFDBnull,a1
				lea 	36(a7),a0
				moveq	#4,d2
L4158:			move.l	(a1)+,(a0)+
				dbf		d2,L4158
				lea 	16(a7),a2
				lea 	MFDBnull,a0
				movea.l	a2,a1
				moveq	#4,d0
L4178:			move.l	(a0)+,(a1)+
				dbf		d0,L4178
				pea 	(a2)
				move.l	a3,-(a7)
				move 	d3,d0
				lea 	8(a7),a1
				lea 	16(a7),a0
				bsr.w	form_set
				addq 	#8,a7
				move 	8(a2),d0
				ext.l	d0
				move 	6(a2),d1
				ext.l	d1
				jsr 	_lmul
				move 	U13152,d1
				ext.l	d1
				jsr 	_lmul
				add.l	d0,d0
				jsr 	malloc
				move.l	a0,(a2)
				move.l	a0,d0
				bne.s	L4268
				moveq	#1,d0
				movea.l	sch_aler,a0
				jsr 	form_ale
				suba.l	a0,a0
				bra.s	L4348

L4268:			suba.l	a0,a0
				move 	#256,d0
				jsr 	graf_mou
				move 	d4,form_hnd
				lea 	16(a7),a0
				move.l	-(a0),-(a7)
				move.l	-(a0),-(a7)
				move.l	-(a0),-(a7)
				move.l	-(a0),-(a7)
				movea.l	a2,a1
				lea 	52(a7),a0
				move 	d4,d0
				jsr 	copy_gfo
				lea 	16(a7),a7
				suba.l	a0,a0
				move 	#257,d0
				jsr 	graf_mou
				lea 	8(a7),a0
				move.l	-(a0),-(a7)
				move.l	-(a0),-(a7)
				move 	d3,d0
				movea.l	a3,a0
				bsr.w	draw_ob
				addq 	#8,a7
				movea.l	(a2),a0
L4348:			lea 	56(a7),a7
				movem.l	(a7)+,d3-d4/a2-a3
				rts

form_res:		movem.l	d3-d4/a2-a4,-(a7)
				lea 	-56(a7),a7
				movea.l	a0,a4
				move 	d0,d3
				move 	d1,d4
				movea.l	a1,a3
				lea 	MFDBnull,a1
				lea 	36(a7),a0
				moveq	#4,d2
L4386:			move.l	(a1)+,(a0)+
				dbf		d2,L4386
				lea 	16(a7),a2
				lea 	MFDBnull,a0
				movea.l	a2,a1
				moveq	#4,d0
L4406:			move.l	(a0)+,(a1)+
				dbf		d0,L4406
				move.l	a3,d0
				beq.s	L4500
				move.l	d0,(a2)
				pea 	(a2)
				move.l	a4,-(a7)
				lea 	16(a7),a1
				lea 	8(a7),a0
				move 	d3,d0
				bsr.w	form_set
				addq 	#8,a7
				suba.l	a0,a0
				move 	#256,d0
				jsr 	graf_mou
				lea 	16(a7),a0
				move.l	-(a0),-(a7)
				move.l	-(a0),-(a7)
				move.l	-(a0),-(a7)
				move.l	-(a0),-(a7)
				lea 	52(a7),a1
				movea.l	a2,a0
				move 	d4,d0
				jsr 	copy_gfo
				lea 	16(a7),a7
				suba.l	a0,a0
				move 	#257,d0
				jsr 	graf_mou
				movea.l	a3,a0
				jsr 	free
L4500:			lea 	56(a7),a7
				movem.l	(a7)+,d3-d4/a2-a4
				rts

cont_mov:		move 	move_mod,d1
				bne.s	L4532
				tst 	d0
				bne.s	L4526
				moveq	#1,d2
				bra.s	L4528

L4526:			clr 	d2
L4528:			move 	d2,d0
				rts

L4532:			tst 	d0
				beq.s	L4540
				moveq	#1,d1
				bra.s	L4542

L4540:			clr 	d1
L4542:			move 	d1,d0
				rts

movebox:		movem.l	d3-d6/a2-a5,-(a7)
				subq 	#6,a7
				move 	d0,d3
				movea.l	a0,a2
				movea.l	a1,a3
				move 	d1,d4
				move 	#21845,d1
				jsr 	vsl_udst
				moveq	#7,d1
				move 	d3,d0
				jsr 	vsl_type
				moveq	#1,d1
				move 	d3,d0
				jsr 	vsl_colo
				moveq	#3,d1
				move 	d3,d0
				jsr 	vswr_mod
				tst 	d4
				beq.s	L4622
				lea 	8(a2),a0
				move.l	-(a0),-(a7)
				move.l	-(a0),-(a7)
				move 	d3,d0
				jsr 	gsbox
				addq 	#8,a7
L4622:			move 	move_mod,d0
				bne.s	L4642
L4630:			move 	d3,d0
				jsr 	mousek
				tst 	d0
				bne.s	L4630
L4642:			lea 	2(a7),a4
				lea 	4(a7),a5
				pea 	(a4)
				movea.l	a5,a1
				lea 	4(a7),a0
				move 	d3,d0
				jsr 	vq_mouse
				addq 	#4,a7
				move 	(a5),d4
				move 	(a4),d5
				movea.l	a2,a0
				lea 	8(a3),a1
				move.l	(a0)+,(a1)+
				move.l	(a0)+,(a1)+
				movea.l	a2,a0
				lea 	16(a3),a1
				move.l	(a0)+,(a1)+
				move.l	(a0)+,(a1)+
				lea 	T8420,a0
				move 	#255,d0
				jsr 	graf_mou
L4708:			pea 	(a4)
				movea.l	a5,a1
				lea 	4(a7),a0
				move 	d3,d0
				jsr 	vq_mouse
				addq 	#4,a7
				move 	(a5),d0
				sub 	d4,d0
				move 	d0,(a3)
				move 	(a4),d1
				sub 	d5,d1
				move 	d1,2(a3)
				movea.l	42(a7),a0
				jsr 	(a0)
				move 	(a7),d0
				bsr.w	cont_mov
				move 	d0,d6
				move 	(a2),d1
				cmp 	8(a3),d1
				bne.s	L4772
				move 	2(a2),d2
				cmp 	10(a3),d2
				beq.s	L4822
L4772:			tst 	d6
				beq.s	L4822
				lea 	16(a3),a0
				move.l	-(a0),-(a7)
				move.l	-(a0),-(a7)
				move 	d3,d0
				jsr 	gsbox
				addq 	#8,a7
				lea 	8(a2),a0
				move.l	-(a0),-(a7)
				move.l	-(a0),-(a7)
				move 	d3,d0
				jsr 	gsbox
				addq 	#8,a7
				movea.l	a2,a0
				lea 	8(a3),a1
				move.l	(a0)+,(a1)+
				move.l	(a0)+,(a1)+
L4822:			move 	(a5),d4
				move 	(a4),d5
				tst 	d6
				bne.s	L4708
				lea 	8(a2),a0
				move.l	-(a0),-(a7)
				move.l	-(a0),-(a7)
				move 	d3,d0
				jsr 	gsbox
				addq 	#8,a7
				move 	move_mod,d0
				bne.s	L4874
				cmpi 	#1,(a7)
				bne.s	L4866
				moveq	#1,d1
				bra.s	L4868

L4866:			clr 	d1
L4868:			move 	d1,6(a3)
				bra.s	L4880

L4874:			move 	#1,6(a3)
L4880:			moveq	#1,d1
				move 	d3,d0
				jsr 	vswr_mod
				moveq	#1,d1
				move 	d3,d0
				jsr 	vsl_type
				move 	move_mod,d0
				bne.s	L4920
L4908:			move 	d3,d0
				jsr 	mousek
				tst 	d0
				bne.s	L4908
L4920:			suba.l	a0,a0
				clr 	d0
				jsr 	graf_mou
				addq 	#6,a7
				movem.l	(a7)+,d3-d6/a2-a5
				rts

snapbox:		movem.l	d3/a2-a3,-(a7)
				lea 	28(a7),a2
				lea 	20(a7),a3
				clr 	(a0)
				clr 	(a1)
				move 	(a3),d2
				cmp 	(a2),d2
				bge.s	L4966
				move 	(a2),(a3)
				move 	#1,(a0)
L4966:			move 	(a3),d2
				add 	4(a3),d2
				move 	(a2),d3
				add 	4(a2),d3
				cmp 	d3,d2
				ble.s	L4992
				sub 	4(a3),d3
				move 	d3,(a3)
				move 	#1,(a0)
L4992:			move 	2(a3),d2
				cmp 	2(a2),d2
				bge.s	L5012
				move 	2(a2),2(a3)
				move 	#1,(a1)
L5012:			move 	2(a3),d2
				add 	6(a3),d2
				move 	2(a2),d3
				add 	6(a2),d3
				cmp 	d3,d2
				ble.s	L5044
				sub 	6(a3),d3
				move 	d3,2(a3)
				move 	#1,(a1)
L5044:			tst 	d1
				beq.s	L5084
				move 	(a3),d1
				add 	d0,d1
				move 	d1,d2
				ext.l	d2
				divs	#8,d2
				move 	d2,d1
				lsl 	#3,d2
				move 	d2,d1
				sub 	d0,d2
				cmp 	(a2),d2
				bge.s	L5078
				addq 	#8,d1
				move 	#1,(a0)
L5078:			move 	d1,d2
				sub 	d0,d2
				move 	d2,(a3)
L5084:			movea.l	a3,a0
				movea.l	16(a7),a1
				move.l	(a0)+,(a1)+
				move.l	(a0)+,(a1)+
				movem.l	(a7)+,d3/a2-a3
				rts

gsbox:			move 	d3,-(a7)
				move.l	a2,-(a7)
				move 	d0,d3
				lea 	10(a7),a2
				moveq	#-1,d0
				add 	(a2),d0
				add 	d0,4(a2)
				moveq	#-1,d0
				add 	2(a2),d0
				add 	d0,6(a2)
				move 	6(a2),-(a7)
				move 	4(a2),-(a7)
				move 	2(a2),d2
				move 	(a2),d1
				move 	d3,d0
				jsr 	box
				addq 	#4,a7
				movea.l	(a7)+,a2
				move 	(a7)+,d3
				rts

box:			movem.l	d3-d7,-(a7)
				lea 	-20(a7),a7
				move 	d0,d7
				move 	d1,d3
				move 	d2,d5
				move 	44(a7),d4
				move 	46(a7),d6
				suba.l	a0,a0
				move 	#256,d0
				jsr 	graf_mou
				move 	d3,(a7)
				move 	d4,4(a7)
				move 	d4,8(a7)
				move 	d3,12(a7)
				move 	d3,16(a7)
				move 	d5,2(a7)
				move 	d5,6(a7)
				move 	d6,10(a7)
				move 	d6,14(a7)
				moveq	#1,d0
				add 	d5,d0
				move 	d0,18(a7)
				lea 	(a7),a0
				moveq	#5,d1
				move 	d7,d0
				jsr 	v_pline
				suba.l	a0,a0
				move 	#257,d0
				jsr 	graf_mou
				lea 	20(a7),a7
				movem.l	(a7)+,d3-d7
				rts

deffill:		move 	d4,-(a7)
				move 	d5,-(a7)
				move 	d0,d4
				move 	d1,d5
				move 	d2,d1
				jsr 	vsf_inte
				move 	8(a7),d1
				move 	d4,d0
				jsr 	vsf_styl
				move 	d5,d1
				move 	d4,d0
				jsr 	vsf_colo
				move 	10(a7),d1
				move 	d4,d0
				jsr 	vsf_peri
				move 	(a7)+,d5
				move 	(a7)+,d4
				rts

mousek:			subq 	#6,a7
				pea 	2(a7)
				lea 	8(a7),a1
				lea 	4(a7),a0
				jsr 	vq_mouse
				addq 	#4,a7
				move 	(a7),d0
				addq 	#6,a7
				rts

atoi:			move 	d3,-(a7)
				move 	d4,-(a7)
				clr 	d0
				lea 	_ChrCla1(pc),a1
L5362:			move.b	(a0)+,d0
				beq.s	L5440
				move.b	0(a1,d0),d0
				bmi.s	L5362
				clr 	d0
				clr 	d1
				move.b	#9,d3
				lea 	_DigCnvT(pc),a1
				move.b	-1(a0),d1
				cmp.b	#45,d1
				seq		d2
				beq.s	L5402
				cmp.b	#43,d1
				bne.s	L5406
L5402:			move.b	(a0)+,d1
				beq.s	L5440
L5406:			move.b	0(a1,d1),d1
				cmp.b	d3,d1
				bhi.s	L5440
L5414:			add 	d1,d0
				move.b	(a0)+,d1
				beq.s	L5440
				move.b	0(a1,d1),d1
				cmp.b	d3,d1
				bhi.s	L5440
				add 	d0,d0
				move 	d0,d4
				add 	d0,d0
				add 	d0,d0
				add 	d4,d0
				bra.s	L5414

L5440:			tst.b	d2
				beq.s	L5446
				neg 	d0
L5446:			move 	(a7)+,d4
				move 	(a7)+,d3
				rts

L5452:			movem.l	d3/a2,-(a7)
				move.l	d0,d3
L5458:			move.l	d3,-(a7)
				move 	#72,-(a7)		; Malloc
				trap	#1				; Gemdos
				addq 	#6,a7
				tst.l	d0
				bne.s	L5492
				move.l	_heapErr,d0
				beq.s	L5492
				movea.l	d0,a0
				move.l	d3,d0
				jsr 	(a0)
				tst 	d0
				bne.s	L5458
				moveq	#0,d0
L5492:			movea.l	d0,a0
				movem.l	(a7)+,d3/a2
				rts

malloc:			movem.l	d3/a2-a3,-(a7)
				move.l	d0,d3
				beq.w	L5680
				addq.l	#8,d3
				addq.l	#1,d3
				and.b	#254,d3
				cmp.l	#4088,d3
				bcs.s	L5558
				move.l	d3,d0
				bsr.w	L5452
				move.l	a0,d0
				beq.w	L5690
				move.l	d3,4(a0)
				lea 	_MemBlkL,a1
				move.l	(a1),(a0)
				move.l	a0,(a1)
				lea 	8(a0),a0
				bra.s	L5674

L5558:			lea 	_MemCluL,a3
L5564:			movea.l	(a3),a3
				move.l	a3,d0
				bne.s	L5618
				move.l	#8192,d0
				bsr.w	L5452
				move.l	a0,d0
				beq.s	L5690
				movea.l	d0,a3
				lea 	8(a3),a0
				moveq	#0,d0
				move.l	d0,(a0)
				move.l	#8184,4(a0)
				move.l	a0,4(a3)
				move.l	_MemCluL,(a3)
				move.l	a3,_MemCluL
L5618:			lea 	4(a3),a0
				movea.l	(a0),a1
				bra.s	L5638

L5626:			move.l	4(a1),d0
				sub.l	d3,d0
				bcc.s	L5644
				movea.l	a1,a0
				movea.l	(a1),a1
L5638:			move.l	a1,d0
				bne.s	L5626
				bra.s	L5564

L5644:			moveq	#16,d1
				cmp.l	d1,d0
				bcc.s	L5654
				move.l	(a1),(a0)
				bra.s	L5664

L5654:			move.l	d0,4(a1)
				adda.l	d0,a1
				move.l	d3,4(a1)
L5664:			move.l	#-1796116985,(a1)
				lea 	8(a1),a0
L5674:			movem.l	(a7)+,d3/a2-a3
				rts

L5680:			bmi.s	L5690
				movea.l	#-1048576,a0
				bra.s	L5674

L5690:			suba.l	a0,a0
				move 	#12,errno
				bra.s	L5674

free:			move.l	a2,-(a7)
				move.l	a0,d0
				ble.s	L5774
				subq.l	#8,a0
				cmpi.l	#-1796116985,(a0)
				bne.s	L5728
				bsr.w	_InsFreB
				tst.b	d0
				beq.s	L5768
				bra.s	L5782

L5728:			lea 	_MemBlkL,a1
				move.l	(a1),d0
				beq.s	L5782
L5738:			cmp.l	a0,d0
				beq.s	L5750
				movea.l	d0,a1
				move.l	(a1),d0
				bne.s	L5738
				bra.s	L5782

L5750:			move.l	(a0),(a1)
				move.l	a0,-(a7)
				move 	#73,-(a7)		; Mfree
				trap	#1				; Gemdos
				addq 	#6,a7
				tst.l	d0
				bpl.s	L5768
				bra.s	L5782

L5768:			moveq	#0,d0
L5770:			movea.l	(a7)+,a2
				rts

L5774:			cmpa.l	#-1048576,a0
				beq.s	L5768
L5782:			moveq	#-1,d0
				bra.s	L5770

_FreeAll:		move.l	a3,-(a7)
				movea.l	_MemBlkL,a3
L5794:			move.l	a3,d0
				beq.s	L5812
				move.l	a3,-(a7)
				movea.l	(a3),a3
				move 	#73,-(a7)		; Mfree
				trap	#1				; Gemdos
				addq 	#6,a7
				bra.s	L5794

L5812:			movea.l	_MemCluL,a3
L5818:			move.l	a3,d0
				beq.s	L5836
				move.l	a3,-(a7)
				movea.l	(a3),a3
				move 	#73,-(a7)		; Mfree
				trap	#1				; Gemdos
				addq 	#6,a7
				bra.s	L5818

L5836:			movea.l	(a7)+,a3
				rts

_InsFreB:		movem.l	a2-a4,-(a7)
				move.l	#8176,d2
				lea 	-8(a0),a1
				lea 	_MemCluL,a3
				move.l	(a3),d0
				beq.w	L6040
L5866:			move.l	a1,d1
				sub.l	d0,d1
				cmp.l	d2,d1
				bls.s	L5884
				movea.l	d0,a3
				move.l	(a3),d0
				bne.s	L5866
				bra.w	L6040

L5884:			movea.l	d0,a4
				move.l	4(a4),d0
				beq.s	L5912
				cmpa.l	d0,a0
				bhi.s	L5938
				move.l	a0,d1
				add.l	4(a0),d1
				cmp.l	d0,d1
				bcs.s	L5912
				beq.s	L5920
				bra.w	L6040

L5912:			move.l	d0,(a0)
				move.l	a0,4(a4)
				bra.s	L6032

L5920:			movea.l	d0,a1
				move.l	4(a1),d1
				add.l	d1,4(a0)
				move.l	(a1),(a0)
				move.l	a0,4(a4)
				bra.s	L6000

L5938:			movea.l	d0,a1
				move.l	(a1),d0
				beq.s	L5948
				cmpa.l	d0,a0
				bhi.s	L5938
L5948:			move.l	a1,d1
				add.l	4(a1),d1
				cmp.l	a0,d1
				bcs.s	L5972
				beq.s	L5962
				bra.s	L6040

L5962:			move.l	4(a0),d1
				add.l	d1,4(a1)
				bra.s	L5978

L5972:			move.l	a0,(a1)
				move.l	d0,(a0)
				movea.l	a0,a1
L5978:			move.l	a1,d1
				add.l	4(a1),d1
				cmp.l	d0,d1
				bne.s	L6000
				movea.l	d0,a0
				move.l	4(a0),d1
				add.l	d1,4(a1)
				move.l	(a0),(a1)
L6000:			movea.l	4(a4),a0
				cmpi.l	#8184,4(a0)
				bcs.s	L6032
				bhi.s	L6040
				move.l	(a4),(a3)
				move.l	a4,-(a7)
				move 	#73,-(a7)		; Mfree
				trap	#1				; Gemdos
				addq 	#6,a7
				tst.l	d0
				bne.s	L6040
L6032:			sf		d0
L6034:			movem.l	(a7)+,a2-a4
				rts

L6040:			st		d0
				bra.s	L6034

_ChrCla1:		dc.b	'@@@@@@@@@',192
				dc.b	192,192,192,192,'@@@@@@@@@@@@@@@@@@',128,1
				dc.b	1,1,1,1,1,1,1,1
				dc.b	1,1,1,1,1,1,18,18
				dc.b	18,18,18,18,18,18,18,18
				dc.b	1,1,1,1,1,1,0,'::::::88888888888888888888',1
				dc.b	1,1,1,1,1,'66666644444444444444444444',1
				dc.b	1,1,1,'@',0,0,0,0
				dc.b	0,0,0,0,0,0,0,0
				dc.b	0,0,0,0,0,0,0,0
				dc.b	0,0,0,0,0,0,0,0
				dc.b	0,0,0,0,0,0,0,0
				dc.b	0,0,0,0,0,0,0,0
				dc.b	0,0,0,0,0,0,0,0
				dc.b	0,0,0,0,0,0,0,0
				dc.b	0,0,0,0,0,0,0,0
				dc.b	0,0,0,0,0,0,0,0
				dc.b	0,0,0,0,0,0,0,0
				dc.b	0,0,0,0,0,0,0,0
				dc.b	0,0,0,0,0,0,0,0
				dc.b	0,0,0,0,0,0,0,0
				dc.b	0,0,0,0,0,0,0,0
				dc.b	0,0,0,0,0,0,0,0
				dc.b	0,0,0,0
_DigCnvT:		dc.b	255,255,255,255,255,255,255,255
				dc.b	255,255,255,255,255,255,255,255
				dc.b	255,255,255,255,255,255,255,255
				dc.b	255,255,255,255,255,255,255,255
				dc.b	255,255,255,255,255,255,255,255
				dc.b	255,255,255,255,255,255,255,255
				dc.b	0,1,2,3,4,5,6,7
				dc.b	8,9,255,255,255,255,255,255
				dc.b	255,10,11,12,13,14,15,16
				dc.b	17,18,19,20,21,22,23,24
				dc.b	25,26,27,28,29,30,31,' !"#',255
				dc.b	255,255,255,255,255,10,11,12
				dc.b	13,14,15,16,17,18,19,20
				dc.b	21,22,23,24,25,26,27,28
				dc.b	29,30,31,' !"#',255
				dc.b	255,255,255,255,255,255,255,255
				dc.b	255,255,255,255,255,255,255,255
				dc.b	255,255,255,255,255,255,255,255
				dc.b	255,255,255,255,255,255,255,255
				dc.b	255,255,255,255,255,255,255,255
				dc.b	255,255,255,255,255,255,255,255
				dc.b	255,255,255,255,255,255,255,255
				dc.b	255,255,255,255,255,255,255,255
				dc.b	255,255,255,255,255,255,255,255
				dc.b	255,255,255,255,255,255,255,255
				dc.b	255,255,255,255,255,255,255,255
				dc.b	255,255,255,255,255,255,255,255
				dc.b	255,255,255,255,255,255,255,255
				dc.b	255,255,255,255,255,255,255,255
				dc.b	255,255,255,255,255,255,255,255
				dc.b	255,255,255,255,255,255,255,255
				dc.b	255,255,255,255

_lmul:			move.l	d0,d2
				bpl.s	L6562
				neg.l	d0
L6562:			eor.l	d1,d2
				movea.l	d2,a0
				tst.l	d1
				bpl.s	L6572
				neg.l	d1
L6572:			move.l	d0,d2
				swap	d2
				tst 	d2
				bne.s	L6614
				move.l	d1,d2
				swap	d2
				tst 	d2
				bne.s	L6598
				mulu 	d1,d0
				move.l	a0,d2
				bpl.s	L6596
				neg.l	d0
L6596:			rts

L6598:			mulu 	d0,d2
				swap	d2
				mulu 	d1,d0
				add.l	d2,d0
				move.l	a0,d2
				bpl.s	L6612
				neg.l	d0
L6612:			rts

L6614:			mulu 	d1,d2
				swap	d2
				mulu 	d1,d0
				add.l	d2,d0
				move.l	a0,d2
				bpl.s	L6628
				neg.l	d0
L6628:			rts

_ldiv:			move.l	d0,d2
				bpl.s	L6636
				neg.l	d0
L6636:			eor.l	d1,d2
				movea.l	d2,a1
				tst.l	d1
				bpl.s	L6646
				neg.l	d1
L6646:			move.l	d1,d2
				swap	d2
				tst 	d2
				bne.s	L6706
				move.l	d0,d2
				swap	d2
				tst 	d2
				bne.s	L6678
				divu	d1,d0
				swap	d0
				clr 	d0
				swap	d0
				move.l	a1,d2
				bpl.s	L6676
				neg.l	d0
L6676:			rts

L6678:			clr 	d0
				swap	d0
				swap	d2
				divu	d1,d0
				movea 	d0,a0
				move 	d2,d0
				divu	d1,d0
				swap	d0
				move 	a0,d0
				swap	d0
				move.l	a1,d2
				bpl.s	L6704
				neg.l	d0
L6704:			rts

L6706:			movea.l	d1,a0
				swap	d0
				moveq	#0,d1
				move 	d0,d1
				clr 	d0
				moveq	#15,d2
				add.l	d0,d0
				addx.l	d1,d1
L6722:			sub.l	a0,d1
				bcc.s	L6728
				add.l	a0,d1
L6728:			addx.l	d0,d0
				addx.l	d1,d1
				dbf		d2,L6722
				not 	d0
				move.l	a1,d2
				bpl.s	L6744
				neg.l	d0
L6744:			rts

Bconin:			pea 	(a2)
				move 	d0,-(a7)
				move 	#2,-(a7)		; Bconin
				trap	#13				; Bios
				addq 	#4,a7
				movea.l	(a7)+,a2
				rts

Super:			pea 	(a2)
				pea 	(a0)
				move 	#32,-(a7)		; Super
				trap	#1				; Gemdos
				addq 	#6,a7
				movea.l	(a7)+,a2
				rts

Malloc:			pea 	(a2)
				move.l	d0,-(a7)
				move 	#72,-(a7)		; Malloc
				trap	#1				; Gemdos
				addq 	#6,a7
				movea.l	d0,a0
				movea.l	(a7)+,a2
				rts

Crawio:			pea 	(a2)
				move 	d0,-(a7)
				move 	#6,-(a7)		; Crawio
				trap	#1				; Gemdos
				addq 	#4,a7
				movea.l	(a7)+,a2
				rts

Cconout:		pea 	(a2)
				move 	d0,-(a7)
				move 	#2,-(a7)		; Cconout
				trap	#1				; Gemdos
				addq 	#4,a7
				movea.l	(a7)+,a2
				rts

Random:			pea 	(a2)
				move 	#17,-(a7)		; Random
				trap	#14				; Xbios
				addq 	#2,a7
				movea.l	(a7)+,a2
				rts

Physbase:		pea 	(a2)
				move 	#2,-(a7)		; Physbase
				trap	#14				; Xbios
				addq 	#2,a7
				movea.l	d0,a0
				movea.l	(a7)+,a2
				rts

Logbase:		pea 	(a2)
				move 	#3,-(a7)		; Logbase
				trap	#14				; Xbios
				addq 	#2,a7
				movea.l	d0,a0
				movea.l	(a7)+,a2
				rts

_aes:			lea 	_GemParB,a1
_aesP:			pea 	(a2)
				moveq	#0,d2
				move.l	d2,(a1)+
				move.l	d2,(a1)+
				move 	d2,(a1)
				movep.l	d1,-7(a1)
				move.l	#AES_pb,d1
				move 	#200,d0
				trap	#2				; VDI/AES
				lea 	U15222,a0
				move 	(a0)+,d0
				movea.l	(a7)+,a2
				rts

appl_exi:		move.l	#318767360,d1
				bra.w	_aes

appl_ini:		move.l	#167772416,d1
				bra.w	_aes

evnt_mul:		pea 	(a1)
				lea 	U14958,a1
				move.l	a0,544(a1)
				move 	d0,(a1)+
				move 	d1,(a1)+
				move 	d2,(a1)+
				move.l	8(a7),(a1)+
				move.l	12(a7),(a1)+
				move.l	16(a7),(a1)+
				move.l	20(a7),(a1)+
				move.l	24(a7),(a1)+
				move.l	28(a7),(a1)+
				move 	32(a7),(a1)
				move.l	#420480769,d1
				bsr.w	_aes
				move.l	a2,d1
				movea.l	(a7)+,a1
				move 	(a0)+,(a1)
				lea 	30(a7),a2
				movea.l	(a2)+,a1
				move 	(a0)+,(a1)
				movea.l	(a2)+,a1
				move 	(a0)+,(a1)
				movea.l	(a2)+,a1
				move 	(a0)+,(a1)
				movea.l	(a2)+,a1
				move 	(a0)+,(a1)
				movea.l	(a2)+,a1
				move 	(a0),(a1)
				movea.l	d1,a2
				rts

form_but:		pea 	(a1)
				movem 	d0-d1,U14958
				move.l	a0,U15502
				move.l	#939655681,d1
				bsr.w	_aes
				movea.l	(a7)+,a1
				move 	(a0),(a1)
				rts

form_cen:		pea 	(a1)
				move.l	a0,U15502
				move.l	#905970945,d1
				bsr.w	_aes
				movea.l	(a7)+,a1
				move 	(a0)+,(a1)
				movea.l	4(a7),a1
				move 	(a0)+,(a1)
				movea.l	8(a7),a1
				move 	(a0)+,(a1)
				movea.l	12(a7),a1
				move 	(a0),(a1)
				rts

form_key:		pea 	(a1)
				lea 	U14958,a1
				move 	d0,(a1)+
				move 	d2,(a1)+
				move 	d1,(a1)
				move.l	a0,540(a1)
				move.l	#922944257,d1
				bsr.w	_aes
				movea.l	(a7)+,a1
				move 	(a0)+,(a1)
				movea.l	4(a7),a1
				move 	(a0),(a1)
				rts

graf_han:		pea 	(a1)
				pea 	(a0)
				move.l	#1291846912,d1
				bsr.w	_aes
				movea.l	(a7)+,a1
				move 	(a0)+,(a1)
				movea.l	(a7)+,a1
				move 	(a0)+,(a1)
				movea.l	4(a7),a1
				move 	(a0)+,(a1)
				movea.l	8(a7),a1
				move 	(a0),(a1)
				rts

graf_mou:		move 	d0,U14958
				move.l	a0,U15502
				move.l	#1308688641,d1
				bra.w	_aes

objc_dra:		lea 	U14958,a1
				move.l	a0,544(a1)
				move 	d0,(a1)+
				move 	d1,(a1)+
				move 	d2,(a1)+
				move.l	4(a7),(a1)+
				move 	8(a7),(a1)
				move.l	#705036545,d1
				bra.w	_aes

objc_edi:		pea 	(a1)
				lea 	U14958,a1
				move.l	a0,544(a1)
				move 	d0,(a1)+
				move 	d1,(a1)+
				movea.l	(a7),a0
				move 	(a0),(a1)+
				move 	d2,(a1)
				move.l	#772014593,d1
				bsr.w	_aes
				movea.l	(a7)+,a1
				move 	(a0),(a1)
				rts

objc_fin:		lea 	U14958,a1
				move.l	a0,544(a1)
				move 	d0,(a1)+
				move 	d1,(a1)+
				move 	d2,(a1)+
				move 	4(a7),(a1)
				move.l	#721682689,d1
				bra.w	_aes

objc_off:		pea 	(a1)
				move 	d0,U14958
				move.l	a0,U15502
				move.l	#738263809,d1
				bsr.w	_aes
				movea.l	(a7)+,a1
				move 	(a0)+,(a1)
				movea.l	4(a7),a1
				move 	(a0),(a1)
				rts

rsrc_gad:		pea 	(a0)
				movem 	d0-d1,U14958
				move.l	#1879179520,d1
				bsr.w	_aes
				movea.l	(a7)+,a1
				move.l	342(a0),(a1)
				rts

wind_upd:		move 	d0,U14958
				move.l	#1795227904,d1
				bra.w	_aes

form_ale:		move 	d0,U14958
				move.l	a0,U15502
				move.l	#872481025,d1
				bra.w	_aes

rsrc_loa:		move.l	a0,U15502
				move.l	#1845494017,d1
				bra.w	_aes

_vdi:			lea 	_VDIParB,a0
				move 	d0,12(a0)
				move 	d1,(a0)+
				move 	d2,4(a0)
				swap	d2
				move 	d2,(a0)
				moveq	#115,d0
				move.l	#VDI_pb,d1
				pea 	(a2)
				trap	#2				; VDI/AES
				movea.l	(a7)+,a2
				lea 	U15924,a0
				move 	(a0)+,d0
				rts

v_pline:		move.l	a0,T8536
				move 	d1,d2
				swap	d2
				clr 	d2
				moveq	#6,d1
				bsr.w	_vdi
				move.l	#U16204,T8536
				rts

v_opnvwk:		pea 	(a2)
				pea 	(a1)
				lea 	_VDIParB,a2
				move 	(a1),12(a2)
				lea 	T8548,a1
				move.l	a1,d1
				move.l	a0,4(a1)
				movea.l	12(a7),a0
				move.l	a0,12(a1)
				lea 	90(a0),a0
				move.l	a0,16(a1)
				move.l	#6553600,(a2)
				move 	#11,6(a2)
				moveq	#115,d0
				trap	#2				; VDI/AES
				movea.l	(a7)+,a0
				move 	U15642,(a0)
				movea.l	(a7)+,a2
				rts

v_clsvwk:		moveq	#101,d1
				moveq	#0,d2
				bra.w	_vdi

v_clrwk:		moveq	#3,d1
				moveq	#0,d2
				bra.w	_vdi

v_circle:		lea 	U16204,a0
				move 	d1,(a0)+
				move 	d2,(a0)+
				clr.l	(a0)+
				move 	4(a7),(a0)+
				clr 	(a0)
				moveq	#11,d1
				move.l	#196608,d2
				move 	#4,-574(a0)
				bra.w	_vdi

vs_clip:		lea 	U16204,a1
				move.l	(a0)+,(a1)+
				move.l	(a0),(a1)
				move 	d1,-548(a1)
				move 	#129,d1
				move.l	#131073,d2
				bra.w	_vdi

vswr_mod:		move 	d1,U15660
				moveq	#32,d1
				moveq	#1,d2
				bra.w	_vdi

vst_alig:		pea 	(a1)
				pea 	(a0)
				movem 	d1-d2,U15660
				moveq	#39,d1
				moveq	#2,d2
				bsr.w	_vdi
				movea.l	(a7)+,a1
				move 	d0,(a1)
				movea.l	(a7)+,a1
				move 	(a0),(a1)
				rts

vsl_udst:		move 	d1,U15660
				moveq	#113,d1
				moveq	#1,d2
				bra.w	_vdi

vsl_type:		move 	d1,U15660
				moveq	#15,d1
				moveq	#1,d2
				bra.w	_vdi

vsl_colo:		move 	d1,U15660
				moveq	#17,d1
				moveq	#1,d2
				bra.w	_vdi

vsf_styl:		move 	d1,U15660
				moveq	#24,d1
				moveq	#1,d2
				bra.w	_vdi

vsf_peri:		move 	d1,U15660
				moveq	#104,d1
				moveq	#1,d2
				bra.w	_vdi

vsf_inte:		move 	d1,U15660
				moveq	#23,d1
				moveq	#1,d2
				bra.w	_vdi

vsf_colo:		move 	d1,U15660
				moveq	#25,d1
				moveq	#1,d2
				bra.w	_vdi

vro_cpyf:		move.l	a0,T8536
				lea 	U15644,a0
				move.l	a1,(a0)+
				move.l	4(a7),(a0)
				move 	d1,12(a0)
				moveq	#109,d1
				move.l	#262145,d2
				bsr.w	_vdi
				move.l	#U16204,T8536
				rts

vq_mouse:		pea 	(a1)
				pea 	(a0)
				moveq	#124,d1
				moveq	#0,d2
				bsr.w	_vdi
				movea.l	(a7)+,a1
				move 	d0,(a1)
				movea.l	(a7)+,a1
				move 	568(a0),(a1)
				movea.l	4(a7),a1
				move 	570(a0),(a1)
				rts

vq_extnd:		move.l	a0,T8540
				lea 	90(a0),a0
				move.l	a0,T8544
				move 	d1,U15660
				moveq	#102,d1
				moveq	#1,d2
				bsr.w	_vdi
				move.l	#U15924,T8540
				move.l	#U16494,T8544
				rts

				.data

__data:			dc.b	'>>>> PURE-C <<<<  for ATARI-ST    Version  1.0  (C'
				dc.b	')88-90 Borland International  '
T7996:			dc 		0
errno:			dc 		0
_AtExitV:		dc 		0,0
_FilSysV:		dc 		0,0
				dc.l	_RedirTa
				dc 		0,4096
pi:				dc 		16384,0,51471,55970
				dc 		9270,65248
hm:				dc 		16392,0,40960,0
				dc 		0,0
vm:				dc 		16391,0,51200,0
				dc 		0,0
gr180:			dc 		16390,0,46080,0
				dc 		0,0
r:				dc 		6
s:				dc 		4
hoek:			dc 		10
worm:			dc 		15
worms:			dc 		3
Line:			dc 		34
File:			dc.l	T8098
Date:			dc.l	T8116
Time:			dc.l	T8128
				dc 		0,0,0,639
				dc 		399
T8098:			dc.b	'E:\WORMEN\WORMS.C',0
T8116:			dc.b	'Jun  1 1998',0
T8128:			dc.b	'11:10:36',0,0
T8138:			dc 		16407,0,32768,0
				dc 		0,0
T8150:			dc.b	'WORMS.RSC',0
T8160:			dc.b	'[1][Geen Resource!][ ACH ]',0,0
T8188:			dc 		16384,0,32768,0
				dc 		0,0
T8200:			dc 		16382,0,32768,0
				dc 		0,0
sch_aler:		dc.l	T8272
scr_grec:		dc 		0,0,0,0
scr_vrec:		dc 		0,0,0,0
MFDBnull:		dc 		0,0,0,0
				dc 		0,0,0,0
				dc 		0,0
instmfdb:		dc 		0,0,0,0
				dc 		0,0,0,0
				dc 		0,0
T8272:			dc.b	'[1][Niet genoeg geheugen|voor schermdump area. !]['
				dc.b	' Quit! ]',0
T8331:			dc.b	'[3][| Install screen: | Intractable combination | '
				dc.b	'of physical characteristics ][ Oh! ]',0
form_hnd:		dc 		0
T8420:			dc 		4,4,1,0
				dc 		1,31232,32576,65504
				dc 		65520,65528,16380,4094
				dc 		51199,61439,65535,65535
				dc 		32767,16383,4095,1022
				dc 		252,20480,10752,5440
				dc 		51872,13648,2728,1028
				dc 		594,50178,43521,20481
				dc 		12289,3073,768,192
				dc 		0
move_mod:		dc 		1
_MemBlkL:		dc 		0,0
_MemCluL:		dc 		0,0
AES_pb:			dc.l	_GemParB
				dc.l	U14928
				dc.l	U14958
				dc.l	U15222
				dc.l	U15502
				dc.l	U15566
VDI_pb:			dc.l	_VDIParB
				dc.l	U15660
T8536:			dc.l	U16204
T8540:			dc.l	U15924
T8544:			dc.l	U16494
T8548:			dc.l	_VDIParB
				dc.l	U15660
				dc.l	U15924
				dc.l	U16204
				dc.l	U16494

				.bss

_BasPag:		ds.b	4
_app:			ds.b	2
_StkLim:		ds.b	4
_PgmSize:		ds.b	4
_RedirTa:		ds.b	18
U8600:			ds.b	6
xc:				ds.b	2000
yc:				ds.b	2000
tail:			ds.b	40
wastail:		ds.b	40
nx:				ds.b	2
ny:				ds.b	2
rich:			ds.b	240
chg:			ds.b	12
d:				ds.b	12
vdivars:		ds.b	2
hl:				ds.b	2
i:				ds.b	2
j:				ds.b	2
inkey:			ds.b	2
db:				ds.b	4
wl:				ds.b	4
wa:				ds.b	4
wg:				ds.b	4
wr:				ds.b	4
ws:				ds.b	4
stackcor:		ds.b	4
sstack:			ds.b	4
scr:			ds.b	2
U12998:			ds.b	154
U13152:			ds.b	106
desk:			ds.b	1536
scr1:			ds.b	4
scr2:			ds.b	6
_frd:			ds.b	2
_fp:			ds.b	2
_fhc:			ds.b	2
_fwc:			ds.b	2
_fh:			ds.b	2
_fw:			ds.b	2
_fww:			ds.b	2
_nova:			ds.b	2
_t2w:			ds.b	2
MagX:			ds.b	2
MiNT:			ds.b	2
_f_logba:		ds.b	8
instdrb:		ds.b	16
U14850:			ds.b	8
U14858:			ds.b	34
form_out:		ds.b	2
_heapErr:		ds.b	4
_GemParB:		ds.b	30
U14928:			ds.b	30
U14958:			ds.b	264
U15222:			ds.b	280
U15502:			ds.b	64
U15566:			ds.b	64
_VDIParB:		ds.b	12
U15642:			ds.b	2
U15644:			ds.b	16
U15660:			ds.b	264
U15924:			ds.b	280
U16204:			ds.b	290
U16494:			ds.b	4386
U20880:
				end		
