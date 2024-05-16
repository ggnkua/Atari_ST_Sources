;Desert Drain V1.46   68000er Disassembler  29.08.1998 00:45:54
;DATEI: LENSFLAR.PRG   20270 Bytes
;TEXT:  16276   $03F94
;DATA:    658   $00292
;BSS:    7258  $001C5A
;SYMBOLE: 219
		          ;Programm ins Fast-Ram laden (128kB)
		          ;malloc() aus dem Fast-Ram
	TEXT
__text:	bra.s   T_62
	dc.l    _RedirTa
	dc.w    $0000            ;
	move.b  D0,D0
	ori.b   #0,D0
	dc.w    $0000            ;
	dc.w    $3E3E            ;>>
	dc.w    $3E3E            ;>>
	movea.l (A0),A0
	subq.w  #2,(A2)
	dc.w    $452D            ;E-
	dc.w    $4320            ;C
	move.w  #$3C3C,D6
	move.l  -(A0),D0
	dc.w    $666F            ;fo
	moveq   #$20,D1
	dc.w    $4154            ;AT
	dc.w    $4152            ;AR
	dc.w    $492D            ;I-
	subq.w  #1,(A4)
	move.l  -(A0),D0
	move.l  -(A0),D0
	addq.w  #3,-(A5)
	moveq   #$73,D1
	dc.w    $696F            ;io
	bgt.s   T_5A
	move.l  $30(A1,D2.l*8),D0
	move.l  -(A0),D0
	movea.l D3,A4
	move.l  $382D.w,-(A4)
	move.w  $42(A0,D2.w),-(A4)
	ble.s   T_BE
	dc.w    $6C61            ;la
	bgt.s   T_B4
	movea.l A1,A0
	bgt.s   T_C8
	bcs.s   T_C8
	dc.w    $6E61            ;na
	moveq   #$69,D2
T_5A:          ble.s   T_CA
	bsr.s   T_CA
	move.l  -(A0),D0
T_60:          dc.w    $0000            ;
T_62:          movea.l A0,A3
	move.l  A3,D0
	bne.s   T_70
	movea.l 4(SP),A3
	moveq   #1,D0
	bra.s   T_72
T_70:          clr.w   D0
T_72:          move.l  A3,_BasPag
	move.w  D0,_app
	movea.l 12(A3),A0
	adda.l  $14(A3),A0
	adda.l  $1C(A3),A0
	adda.w  #$100,A0
	move.l  A0,_PgmSize
	move.l  A3,D0
	add.l   A0,D0
	and.b   #-4,D0
	movea.l D0,SP
	sub.l   #$F00,D0
	move.l  D0,_StkLim
	tst.w   _app
	beq     T_160
T_B4:          sub.l   #$FA,D0
	and.b   #-4,D0
T_BE:          movea.l D0,A1
	movea.l A1,A4
	movea.l $2C(A3),A2
	move.l  A2,(A1)+
T_C8:          tst.b   (A2)+
T_CA:          bne.s   T_C8
	move.l  A2,(A1)+
	tst.b   (A2)+
	bne.s   T_C8
	clr.l   -(A1)
	move.l  A0,-(SP)
	move.l  A3,-(SP)
	move.w  #0,-(SP)
	move.w  #$4A,-(SP)
	trap    #1	;Mshrink
	lea     12(SP),SP
	lea     $80(A3),A0
	move.b  (A0),D1
	cmp.b   #$7E,D1
	bmi.s   T_100
	addq.l  #1,A0
	moveq   #-1,D1
T_F6:          addq.w  #1,D1
	move.b  (A0)+,D0
	bne.s   T_F6
	lea     $80(A3),A0
T_100:         move.w  #1,D3
	ext.w   D1
	lea     1(A0,D1.w),A1
	clr.b   (A1)
	clr.l   -(SP)
	bra.s   T_146
T_110:         cmpi.b  #$21,(A1)
	bpl.s   T_126
	clr.b   (A1)
	tst.b   1(A1)
	beq.s   T_126
	pea     1(A1)
	addq.w  #1,D3
	bra.s   T_146
T_126:         cmpi.b  #$22,(A1)
	bne.s   T_146
	move.b  #0,(A1)
T_130:         subq.w  #1,A1
	cmpi.b  #$22,(A1)
	dbeq    D1,T_130
	subq.w  #1,D1
	bmi.s   T_14C
	pea     1(A1)
	addq.w  #1,D3
	clr.b   (A1)
T_146:         subq.l  #1,A1
	dbra    D1,T_110
T_14C:         tst.b   1(A1)
	beq.s   T_158
	pea     1(A1)
	addq.w  #1,D3
T_158:         pea     T_60
	movea.l SP,A2
T_160:         jsr     _fpuinit
	move.w  D3,D0
	movea.l A2,A0
	movea.l A4,A1
	jsr     main
exit:          move.w  D0,-(SP)
	move.l  _AtExitV,D0
	beq.s   __exit
	movea.l D0,A0
	jsr     (A0)
__exit:        move.l  _FilSysV,D0
	beq.s   T_18C
	movea.l D0,A0
	jsr     (A0)
T_18C:         jsr     _FreeAll
	move.w  #$4C,-(SP)
	trap    #1	;Pterm
frand1d:       move.l  D3,-(SP)
	lea     -$14(SP),SP
	move.l  D0,D3
	lsl.l   #3,D3
	add.l   D0,D3
	lsl.l   #3,D3
	sub.l   D0,D3
	move.l  D3,D0
	moveq   #13,D1
	lsl.l   D1,D0
	eor.l   D3,D0
	move.l  D0,D3
	lea     D_3FA2,A0
	lea     (SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
	move.l  D3,D2
	muls.l  D3,D2
	muls.l  #$3D73,D2
	add.l   #$C0AE5,D2
	muls.l  D2,D0
	add.l   #$5208DD0D,D0
	and.l   #$7FFFFFFF,D0
	lea     10(SP),A0
	bsr     _lxcnv
	lea     10(SP),A0
	lea     D_3FAC,A1
	bsr     _xxdiv
	lea     (SP),A0
	lea     10(SP),A1
	bsr     _xxsub
	movea.l $1C(SP),A0
	lea     (SP),A1
	move.l  (A1)+,(A0)+
	move.l  (A1)+,(A0)+
	move.w  (A1)+,(A0)+
	lea     $14(SP),SP
	move.l  (SP)+,D3
	rts
Noise1D:       move.l  D3,-(SP)
	lea     -$28(SP),SP
	subq.w  #2,SP
	lea     $40(SP),A0
	move.l  -(A0),-(SP)
	move.l  -(A0),-(SP)
	move.w  -(A0),-(SP)
	pea     12(SP)
	bsr     floor
	lea     $10(SP),SP
	lea     (SP),A0
	bsr     _xwcnv
	move.l  D0,D3
	lea     $34(SP),A0
	lea     (SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
	lea     (SP),A0
	move.l  D3,D0
	bsr     _xlsub
	move.l  D3,D0
	pea     10(SP)
	bsr     frand1d
	addq.w  #4,SP
	moveq   #1,D0
	add.l   D3,D0
	pea     $14(SP)
	bsr     frand1d
	addq.w  #4,SP
	lea     $14(SP),A0
	lea     $1E(SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
	lea     $1E(SP),A0
	lea     10(SP),A1
	bsr     _xxsub
	lea     $1E(SP),A0
	lea     (SP),A1
	bsr     _xxmul
	lea     $1E(SP),A0
	lea     10(SP),A1
	bsr     _xxadd
	movea.l $30(SP),A0
	lea     $1E(SP),A1
	move.l  (A1)+,(A0)+
	move.l  (A1)+,(A0)+
	move.w  (A1)+,(A0)+
	lea     $28(SP),SP
	move.l  (SP)+,D3
	rts
draw_fla:      movem.l D3/D4/A2/A3,-(SP)
	lea     -$5A0(SP),SP
	lea     D_3FB6,A0
	lea     $1E(SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
	lea     D_3FC0,A0
	lea     $14(SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
	lea     D_3FCA,A0
	lea     $53C(SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
	lea     D_3FD4,A0
	lea     $546(SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
	lea     D_3FDE,A0
	lea     $550(SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
	lea     $546(SP),A0
	lea     $528(SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
	lea     $528(SP),A0
	lea     $550(SP),A1
	bsr     _xxadd
	lea     $528(SP),A0
	lea     (SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
	lea     $546(SP),A0
	lea     $528(SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
	lea     $528(SP),A0
	lea     $550(SP),A1
	bsr     _xxsub
	lea     $528(SP),A0
	lea     10(SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
	lea     $5B4(SP),A0
	lea     $56E(SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
	lea     D_3FE8,A0
	lea     $5B4(SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
	clr.w   D3
	lea     Width,A2
	lea     $28(SP),A3
	bra     T_7EA
T_386:         move.w  2(A2),D0
	ext.l   D0
	divs.w  #2,D0
	sub.w   D3,D0
	lea     $56E(SP),A0
	bsr     _wxcnv
	clr.w   D4
	bra     T_7E2
T_3A0:         move.w  D4,D0
	move.w  (A2),D1
	ext.l   D1
	divs.w  #2,D1
	sub.w   D1,D0
	lea     $564(SP),A0
	bsr     _wxcnv
	subq.w  #2,SP
	lea     $566(SP),A0
	lea     $52A(SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
	lea     $52A(SP),A0
	lea     $566(SP),A1
	bsr     _xxmul
	lea     $570(SP),A0
	lea     $534(SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
	lea     $534(SP),A0
	lea     $570(SP),A1
	bsr     _xxmul
	lea     $52A(SP),A0
	lea     $534(SP),A1
	bsr     _xxadd
	lea     $534(SP),A0
	move.l  -(A0),-(SP)
	move.l  -(A0),-(SP)
	move.w  -(A0),-(SP)
	pea     $534(SP)
	bsr     sqrt
	lea     $10(SP),SP
	lea     $528(SP),A0
	lea     D_3FF2,A1
	bsr     _xxmul
	subq.w  #2,SP
	lea     $52A(SP),A0
	lea     $534(SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
	eori.b  #-$80,$534(SP)
	lea     $534(SP),A0
	lea     $20(SP),A1
	bsr     _xxmul
	lea     $53E(SP),A0
	move.l  -(A0),-(SP)
	move.l  -(A0),-(SP)
	move.w  -(A0),-(SP)
	pea     $584(SP)
	bsr     exp
	lea     $10(SP),SP
	lea     D_3FFC,A0
	lea     $532(SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
	lea     $532(SP),A0
	lea     $53C(SP),A1
	bsr     _xxsub
	lea     $578(SP),A0
	lea     $532(SP),A1
	bsr     _xxmul
	subq.w  #2,SP
	lea     $52A(SP),A0
	lea     $534(SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
	eori.b  #-$80,$534(SP)
	lea     $534(SP),A0
	lea     $52A(SP),A1
	bsr     _xxmul
	lea     $534(SP),A0
	lea     $16(SP),A1
	bsr     _xxmul
	lea     $53E(SP),A0
	move.l  -(A0),-(SP)
	move.l  -(A0),-(SP)
	move.w  -(A0),-(SP)
	pea     $53E(SP)
	bsr     exp
	lea     $10(SP),SP
	lea     $532(SP),A0
	lea     $53C(SP),A1
	bsr     _xxmul
	lea     $578(SP),A0
	lea     $532(SP),A1
	bsr     _xxadd
	lea     $578(SP),A0
	lea     $532(SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
	lea     $528(SP),A0
	lea     10(SP),A1
	bsr     _xxcmp
	blt.s   T_4FE
	lea     $528(SP),A0
	lea     (SP),A1
	bsr     _xxcmp
	ble.s   T_512
T_4FE:         lea     D_4006,A0
	lea     $55A(SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
	bra     T_5E6
T_512:         subq.w  #2,SP
	lea     $52A(SP),A0
	lea     $55C(SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
	lea     $55C(SP),A0
	lea     $548(SP),A1
	bsr     _xxsub
	lea     $566(SP),A0
	move.l  -(A0),-(SP)
	move.l  -(A0),-(SP)
	move.w  -(A0),-(SP)
	pea     $566(SP)
	bsr     fabs
	lea     $10(SP),SP
	lea     $55A(SP),A0
	lea     $550(SP),A1
	bsr     _xxdiv
	lea     D_4010,A0
	lea     $578(SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
	lea     $55A(SP),A0
	lea     $582(SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
	lea     $582(SP),A0
	lea     $55A(SP),A1
	bsr     _xxmul
	lea     D_401A,A0
	lea     $58C(SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
	lea     D_4024,A0
	lea     $596(SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
	lea     $596(SP),A0
	lea     $55A(SP),A1
	bsr     _xxmul
	lea     $58C(SP),A0
	lea     $596(SP),A1
	bsr     _xxsub
	lea     $582(SP),A0
	lea     $58C(SP),A1
	bsr     _xxmul
	lea     $578(SP),A0
	lea     $582(SP),A1
	bsr     _xxsub
	lea     $578(SP),A0
	lea     $55A(SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
	lea     $55A(SP),A0
	lea     D_402E,A1
	bsr     _xxmul
T_5E6:         lea     $532(SP),A0
	lea     $55A(SP),A1
	bsr     _xxadd
	lea     $578(SP),A0
	move.l  -(A0),-(SP)
	move.l  -(A0),-(SP)
	move.w  -(A0),-(SP)
	lea     $578(SP),A0
	move.l  -(A0),-(SP)
	move.l  -(A0),-(SP)
	move.w  -(A0),-(SP)
	pea     $58C(SP)
	bsr     atan2
	lea     $18(SP),SP
	lea     $578(SP),A0
	lea     D_4038,A1
	bsr     _xxadd
	lea     $578(SP),A0
	lea     $564(SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
	lea     D_404C,A0
	move.l  -(A0),-(SP)
	move.l  -(A0),-(SP)
	move.w  -(A0),-(SP)
	lea     $582(SP),A0
	lea     D_404C,A1
	bsr     _xxmul
	lea     $58C(SP),A0
	move.l  -(A0),-(SP)
	move.l  -(A0),-(SP)
	move.w  -(A0),-(SP)
	pea     $596(SP)
	bsr     Noise1D
	lea     14(SP),SP
	lea     $56E(SP),A0
	lea     $582(SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
	lea     $582(SP),A0
	lea     D_4056,A1
	bsr     _xxdiv
	lea     $582(SP),A0
	lea     D_4060,A1
	bsr     _xxmul
	lea     $582(SP),A0
	lea     D_406A,A1
	bsr     _xxadd
	lea     $58C(SP),A0
	lea     $582(SP),A1
	bsr     _xxadd
	lea     $596(SP),A0
	move.l  -(A0),-(SP)
	move.l  -(A0),-(SP)
	move.w  -(A0),-(SP)
	pea     $58C(SP)
	bsr     fmod
	lea     $18(SP),SP
	lea     $578(SP),A0
	lea     D_4074,A1
	bsr     _xxsub
	lea     $578(SP),A0
	lea     D_407E,A1
	bsr     _xxmul
	lea     $578(SP),A0
	lea     $564(SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
	subq.w  #2,SP
	lea     $584(SP),A0
	move.l  -(A0),-(SP)
	move.l  -(A0),-(SP)
	move.w  -(A0),-(SP)
	pea     $58E(SP)
	bsr     fabs
	lea     $10(SP),SP
	lea     $582(SP),A0
	lea     $564(SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
	lea     D_4092,A0
	move.l  -(A0),-(SP)
	move.l  -(A0),-(SP)
	move.w  -(A0),-(SP)
	lea     $596(SP),A0
	move.l  -(A0),-(SP)
	move.l  -(A0),-(SP)
	move.w  -(A0),-(SP)
	pea     $58C(SP)
	bsr     pow
	lea     $18(SP),SP
	lea     $578(SP),A0
	lea     $564(SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
	lea     D_4092,A0
	lea     $582(SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
	lea     $582(SP),A0
	lea     $578(SP),A1
	bsr     _xxmul
	lea     $528(SP),A0
	lea     $578(SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
	lea     $578(SP),A0
	lea     D_409C,A1
	bsr     _xxmul
	lea     $578(SP),A0
	lea     D_40A6,A1
	bsr     _xxadd
	lea     $582(SP),A0
	lea     $578(SP),A1
	bsr     _xxdiv
	lea     $532(SP),A0
	lea     $582(SP),A1
	bsr     _xxadd
	lea     $532(SP),A0
	lea     D_40B0,A1
	bsr     _xxcmp
	ble.s   T_7B6
	lea     D_40BA,A0
	lea     $532(SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
T_7B6:         lea     D_40C4,A0
	lea     $528(SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
	lea     $528(SP),A0
	lea     $532(SP),A1
	bsr     _xxmul
	lea     $528(SP),A0
	bsr     _xwcnv
	move.l  D0,D0
	move.w  D0,0(A3,D4.w*2)
	addq.w  #1,D4
T_7E2:         cmp.w   (A2),D4
	blt     T_3A0
	addq.w  #1,D3
T_7EA:         cmp.w   2(A2),D3
	blt     T_386
	lea     $5A0(SP),SP
	movem.l (SP)+,D3/D4/A2/A3
	rts
SetColor:      movem.l D3-D5/A2,-(SP)
	lea     -$A(SP),SP
	moveq   #0,D3
	lea     rgbtab,A2
	bra     T_91E
T_810:         lea     D_40D8,A0
	move.l  -(A0),-(SP)
	move.l  -(A0),-(SP)
	move.w  -(A0),-(SP)
	lea     10(SP),A0
	move.l  D3,D0
	bsr     _lxcnv
	lea     10(SP),A0
	lea     D_40D8,A1
	bsr     _xxdiv
	lea     $14(SP),A0
	move.l  -(A0),-(SP)
	move.l  -(A0),-(SP)
	move.w  -(A0),-(SP)
	pea     $14(SP)
	bsr     pow
	lea     $18(SP),SP
	lea     (SP),A0
	lea     D_40E2,A1
	bsr     _xxmul
	lea     (SP),A0
	bsr     _xwcnv
	move.l  D0,D4
	lea     D_40F6,A0
	move.l  -(A0),-(SP)
	move.l  -(A0),-(SP)
	move.w  -(A0),-(SP)
	lea     10(SP),A0
	move.l  D3,D0
	bsr     _lxcnv
	lea     10(SP),A0
	lea     D_40F6,A1
	bsr     _xxdiv
	lea     $14(SP),A0
	move.l  -(A0),-(SP)
	move.l  -(A0),-(SP)
	move.w  -(A0),-(SP)
	pea     $14(SP)
	bsr     pow
	lea     $18(SP),SP
	lea     (SP),A0
	lea     D_4100,A1
	bsr     _xxmul
	lea     (SP),A0
	bsr     _xwcnv
	move.l  D0,D5
	lea     D_4114,A0
	move.l  -(A0),-(SP)
	move.l  -(A0),-(SP)
	move.w  -(A0),-(SP)
	lea     10(SP),A0
	move.l  D3,D0
	bsr     _lxcnv
	lea     10(SP),A0
	lea     D_4114,A1
	bsr     _xxdiv
	lea     $14(SP),A0
	move.l  -(A0),-(SP)
	move.l  -(A0),-(SP)
	move.w  -(A0),-(SP)
	pea     $14(SP)
	bsr     pow
	lea     $18(SP),SP
	lea     (SP),A0
	lea     D_411E,A1
	bsr     _xxmul
	lea     (SP),A0
	bsr     _xwcnv
	move.l  D0,D0
	move.l  D4,D1
	moveq   #$18,D2
	lsl.l   D2,D1
	move.l  D3,D2
	add.l   D2,D2
	add.l   D3,D2
	move.l  D1,4(A2,D2.w*4)
	move.l  D5,D4
	moveq   #$18,D1
	lsl.l   D1,D4
	move.l  D4,8(A2,D2.w*4)
	move.l  D0,D5
	lsl.l   D1,D5
	move.l  D5,12(A2,D2.w*4)
	addq.l  #1,D3
T_91E:         cmp.l   #$100,D3
	blt     T_810
	clr.l   (A2)
	lea     10(SP),SP
	movem.l (SP)+,D3-D5/A2
	rts
main:	lea     -$A(SP),SP
	lea     D_413E,A0
	lea     (SP),A1
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.w  (A0)+,(A1)+
	bsr     SetColor
	subq.w  #2,SP
	lea     12(SP),A0
	move.l  -(A0),-(SP)
	move.l  -(A0),-(SP)
	move.w  -(A0),-(SP)
	bsr     draw_fla
	lea     12(SP),SP
	lea     D_4128,A0
	bsr     printf
T_968:         bsr     kbhit
	tst.w   D0
	beq.s   T_968
	lea     10(SP),SP
	rts
_PrintF:       movem.l D3-D6/A2-A4,-(SP)
	subq.w  #6,SP
	movea.l A0,A2
	movea.l A1,A3
	movea.l $26(SP),A4
	clr.w   D3
	moveq   #$25,D4
T_988:         moveq   #-1,D0
	movea.l A2,A0
T_98C:         addq.w  #1,D0
	move.b  (A2)+,D5
	beq     T_C0E
	cmp.b   D4,D5
	bne.s   T_98C
	tst.w   D0
	beq.s   T_9A2
	add.w   D0,D3
	ext.l   D0
	jsr     (A4)
T_9A2:         clr.w   D5
T_9A4:         move.b  (A2)+,D0
	beq     T_C1E
	clr.w   D1
	move.b  D0,D1
	sub.b   #$20,D1
	cmp.b   #$10,D1
	bhi.s   T_9D4
	move.b  T_9C2(PC,D1.w),D1
	bmi.s   T_9D4
	or.b    D1,D5
	bra.s   T_9A4
T_9C2:         dc.w    $01FF            ; ˇ
	dc.w    $FF02            ;ˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FF04            ;ˇ
	dc.w    $FF08            ;ˇ
	dc.w    $FFFF            ;ˇˇ
	move.b  D0,D0
T_9D4:         moveq   #-1,D6
	cmp.b   #$2A,D0
	bne.s   T_9E0
	move.w  (A3)+,D6
	bra.s   T_A06
T_9E0:         move.b  D0,D1
	sub.b   #$30,D1
	cmp.b   #9,D1
	bhi.s   T_A0C
	lea     -$1(A2),A0
	lea     (SP),A1
	moveq   #10,D0
	bsr     strtoul
	movea.l (SP),A2
	cmp.l   #$7FFF,D0
	bhi     T_C1E
	move.w  D0,D6
T_A06:         move.b  (A2)+,D0
	beq     T_C1E
T_A0C:         moveq   #-1,D2
	cmp.b   #$2E,D0
	bne.s   T_A4A
	move.b  (A2)+,D0
	cmp.b   #$2A,D0
	bne.s   T_A20
	move.w  (A3)+,D2
	bra.s   T_A44
T_A20:         sub.b   #$30,D0
	cmp.b   #9,D0
	bhi.s   T_A4A
	lea     -$1(A2),A0
	lea     (SP),A1
	moveq   #10,D0
	bsr     strtoul
	movea.l (SP),A2
	cmp.l   #$7FFF,D0
	bhi     T_C1E
	move.w  D0,D2
T_A44:         move.b  (A2)+,D0
	beq     T_C1E
T_A4A:         move.b  D0,D1
	and.b   #-$21,D1
	cmp.b   #$4C,D1
	bne.s   T_A62
	bset    #15,D5
T_A5A:         move.b  (A2)+,D0
	beq     T_C1E
	bra.s   T_A68
T_A62:         cmp.b   #$68,D0
	beq.s   T_A5A
T_A68:         cmp.b   D4,D0
	beq     T_B0E
	moveq   #$40,D1
	sub.b   D1,D0
	cmp.b   D1,D0
	bcc     T_C1E
	and.w   #$3F,D0
	add.w   D0,D0
	move.w  T_A86(PC,D0.w),D0
	jmp     T_A86(PC,D0.w)
T_A86:         bclr    D0,(A0)+
	bclr    D0,(A0)+
	bclr    D0,(A0)+
	bclr    D0,(A0)+
	bclr    D0,(A0)+
	dc.w    $013E            ; >
	bclr    D0,(A0)+
	bchg    D0,$198(A6)
	bclr    D0,(A0)+
	bclr    D0,(A0)+
	bclr    D0,(A0)+
	bclr    D0,(A0)+
	bclr    D0,(A0)+
	bclr    D0,(A0)+
	bclr    D0,(A0)+
	bclr    D0,(A0)+
	bclr    D0,(A0)+
	bclr    D0,(A0)+
	bclr    D0,(A0)+
	bclr    D0,(A0)+
	bclr    D0,(A0)+
	bclr    D0,(A0)+
	bclr    D0,(A0)+
	dc.w    $00FA            ; ˙
	bclr    D0,(A0)+
	bclr    D0,(A0)+
	bclr    D0,(A0)+
	bclr    D0,(A0)+
	bclr    D0,(A0)+
	bclr    D0,(A0)+
	bclr    D0,(A0)+
	bclr    D0,(A0)+
	bclr    D0,(A0)+
	bclr    D0,(A0)+
	ori.l   #$DA0142,(A0)
	bchg    D0,(A0)+
	bchg    D0,$98(A2,D0.w)
	dc.w    $00DA            ; ⁄
	bclr    D0,(A0)+
	bclr    D0,(A0)+
	bclr    D0,(A0)+
	bclr    D0,(A0)+
	ori.l   #$11E0102,D0
	bclr    D0,(A0)+
	bclr    D0,(A0)+
	ori.l   #$19800BA,$198(A0)
	bclr    D0,(A0)+
	dc.w    $00FE            ; ˛
	bclr    D0,(A0)+
	bclr    D0,(A0)+
	bclr    D0,(A0)+
	bclr    D0,(A0)+
	bclr    D0,(A0)+
	bclr    D0,(A0)+
	bclr    D0,(A0)+
	movea.l (A3)+,A0
	move.w  D3,(A0)
	bra     T_988
T_B0E:         lea     4(SP),A0
	move.b  D4,(A0)
	bra.s   T_B1E
	move.w  (A3)+,D0
	lea     4(SP),A0
	move.b  D0,(A0)
T_B1E:         move.b  D5,D0
	move.w  D6,D1
	movea.l A4,A1
	bsr     _OutChr
	add.w   D0,D3
	bra     T_988
	movea.l (A3)+,A0
	move.b  D5,D0
	move.w  D6,D1
	movea.l A4,A1
	bsr     _OutStr
	add.w   D0,D3
	bra     T_988
	tst.w   D5
	bpl.s   T_B48
	move.l  (A3)+,D0
	bra.s   T_B4C
T_B48:         moveq   #0,D0
	move.w  (A3)+,D0
T_B4C:         move.w  D2,-(SP)
	move.b  D5,D1
	move.w  D6,D2
	movea.l A4,A0
	bsr     _OutCarD
	addq.w  #2,SP
	add.w   D0,D3
	bra     T_988
	tst.w   D5
	bpl.s   T_B68
	move.l  (A3)+,D0
	bra.s   T_B6C
T_B68:         move.w  (A3)+,D0
	ext.l   D0
T_B6C:         move.w  D2,-(SP)
	move.b  D5,D1
	move.w  D6,D2
	movea.l A4,A0
	bsr     _OutIntD
	addq.w  #2,SP
	add.w   D0,D3
	bra     T_988
	bset    #5,D5
	tst.w   D5
	bpl.s   T_B8C
	move.l  (A3)+,D0
	bra.s   T_B90
T_B8C:         moveq   #0,D0
	move.w  (A3)+,D0
T_B90:         move.w  D2,-(SP)
	move.b  D5,D1
	move.w  D6,D2
	movea.l A4,A0
	bsr     _OutCarH
	addq.w  #2,SP
	add.w   D0,D3
	bra     T_988
	tst.w   D5
	bpl.s   T_BAC
	move.l  (A3)+,D0
	bra.s   T_BB0
T_BAC:         moveq   #0,D0
	move.w  (A3)+,D0
T_BB0:         move.w  D2,-(SP)
	move.b  D5,D1
	move.w  D6,D2
	movea.l A4,A0
	bsr     _OutCarO
	addq.w  #2,SP
	add.w   D0,D3
	bra     T_988
	bset    #5,D5
	lea     (A3),A0
	adda.w  #10,A3
	move.b  D5,D0
	move.w  D6,D1
	movea.l A4,A1
	bsr     _OutFlt
	add.w   D0,D3
	bra     T_988
	lea     (A3),A0
	adda.w  #10,A3
	move.b  D5,D0
	move.w  D6,D1
	movea.l A4,A1
	bsr     _OutFix
	add.w   D0,D3
	bra     T_988
	bset    #5,D5
	lea     (A3),A0
	adda.w  #10,A3
	move.b  D5,D0
	move.w  D6,D1
	movea.l A4,A1
	bsr     _OutFixF
	add.w   D0,D3
	bra     T_988
T_C0E:         add.w   D0,D3
	ext.l   D0
	jsr     (A4)
	move.w  D3,D0
T_C16:         addq.w  #6,SP
	movem.l (SP)+,D3-D6/A2-A4
	rts
T_C1E:         moveq   #-1,D0
	bra.s   T_C16
	movep.w $5761(A2),D6
	moveq   #$6E,D1
	bvs.s   T_C98
	beq.s   T_C66
	movea.l ([$2054,A5]),A0
	dc.w    $4346            ;CF
	divs.l  (A4),D4
	clr.b   -(A0)
	moveq   #$6F,D2
	movea.l -(SP),A0
	bcs.s   T_CB4
	movea.l -(A6),A0
	dc.w    $6C6F            ;lo
	bsr.s   T_CBA
	movea.l $706F7274(A3,D7.w*4),A0
	movea.l -(A6),A0
T_C50:         ble.s   T_CC4
	movea.l $69(A0,D7.w*2),A0
	bgt.s   T_CCC
	bne.s   T_C88
	movep.w 0(A2),D6
_OutFlt:       movem.l D3-D7/A2/A3,-(SP)
	lea     -$62(SP),SP
T_C66:         movea.l A0,A2
	movea.l A1,A3
	move.w  D0,(SP)
	move.w  D1,D3
	move.w  D2,D4
	bpl.s   T_C76
	moveq   #6,D4
	bra.s   T_C7E
T_C76:         moveq   #$12,D0
	cmp.w   D0,D4
	bls.s   T_C7E
	move.w  D0,D4
T_C7E:         move.w  #0,6(SP)
	move.w  (A2),D0
	dc.w    $0880            ; Ä
T_C88:         dc.w    $000F            ;
	cmp.w   #$7FFF,D0
	beq     T_11BA
	movea.l A2,A0
	move.w  D4,D0
	addq.w  #1,D0
T_C98:         lea     $44(SP),A1
	pea     $42(SP)
	bsr     T_1248
	addq.w  #4,SP
	move.w  (SP),D0
	move.w  #0,10(SP)
	tst.w   $42(SP)
	beq.s   T_CC2
T_CB4:         move.b  #$2D,8(SP)
T_CBA:         move.w  #1,10(SP)
	bra.s   T_CE8
T_CC2:         dc.w    $0800            ;
T_CC4:         dc.w    $0002            ;
	beq.s   T_CD6
	dc.w    $1F7C            ; |
	dc.w    $002B            ; +
T_CCC:         dc.w    $0008            ;
	move.w  #1,10(SP)
	bra.s   T_CE8
T_CD6:         btst    #0,D0
	beq.s   T_CE8
	move.b  #$20,8(SP)
	move.w  #1,10(SP)
T_CE8:         move.w  #1,$20(SP)
	move.w  D4,$36(SP)
	move.w  D4,D1
	addq.w  #4,D1
	addq.w  #4,D1
	moveq   #$30,D2
	cmp.b   (A0),D2
	beq.s   T_D02
	tst.b   (A0)
	bne.s   T_D26
T_D02:         move.b  D2,12(SP)
	addq.w  #1,$44(SP)
	tst.w   D4
	bne.s   T_D18
	btst    #1,D0
	bne.s   T_D46
	subq.w  #1,D1
	bra.s   T_D46
T_D18:         lea     $22(SP),A1
	subq.w  #1,D4
T_D1E:         move.b  D2,(A1)+
	dbra    D4,T_D1E
	bra.s   T_D46
T_D26:         move.b  (A0)+,12(SP)
	tst.w   D4
	bne.s   T_D38
	btst    #1,D0
	bne.s   T_D46
	subq.w  #1,D1
	bra.s   T_D46
T_D38:         lea     $22(SP),A1
	subq.w  #1,D4
	blt.s   T_D46
T_D40:         move.b  (A0)+,(A1)+
	dbra    D4,T_D40
T_D46:         moveq   #0,D2
	add.w   10(SP),D1
	sub.w   D1,D3
	bgt.s   T_D5A
	move.w  D2,2(SP)
	move.w  D2,4(SP)
	bra.s   T_D78
T_D5A:         btst    #3,D0
	bne.s   T_D66
	btst    #4,D0
	bne.s   T_D70
T_D66:         move.w  D3,2(SP)
	move.w  D2,4(SP)
	bra.s   T_D78
T_D70:         move.w  D3,4(SP)
	move.w  D2,2(SP)
T_D78:         lea     $38(SP),A1
	move.w  #6,$40(SP)
	btst    #5,D0
	beq.s   T_D8E
	move.b  #$45,(A1)+
	bra.s   T_D92
T_D8E:         move.b  #$65,(A1)+
T_D92:         move.w  $44(SP),D0
	subq.w  #1,D0
	bpl.s   T_DA2
	neg.w   D0
	move.b  #$2D,(A1)+
	bra.s   T_DA6
T_DA2:         move.b  #$2B,(A1)+
T_DA6:         move.l  A1,-(SP)
	moveq   #10,D1
	lea     $4A(SP),A0
	bsr     itoa
	movea.l (SP)+,A1
	lea     $46(SP),A0
	moveq   #-1,D0
T_DBA:         tst.b   (A0)+
	dbeq    D0,T_DBA
	not.w   D0
	moveq   #4,D1
	sub.b   D0,D1
	beq.s   T_DD4
	subq.w  #1,D1
	bmi.s   T_DD4
	moveq   #$30,D2
T_DCE:         move.b  D2,(A1)+
	dbra    D1,T_DCE
T_DD4:         subq.w  #1,D0
	bmi.s   T_DE2
	lea     $46(SP),A0
T_DDC:         move.b  (A0)+,(A1)+
	dbra    D0,T_DDC
T_DE2:         bra     T_110E
_OutFix:       movem.l D3-D7/A2/A3,-(SP)
	lea     -$62(SP),SP
	movea.l A0,A2
	movea.l A1,A3
	move.w  #0,$40(SP)
	move.w  D0,D7
	move.w  D7,(SP)
	move.w  D1,D3
	move.w  D2,D4
	bpl.s   T_E04
	moveq   #6,D4
T_E04:         move.w  (A2),D0
	bclr    #15,D0
	cmp.w   #$7FFF,D0
	beq     T_11BA
	movea.l A2,A0
	moveq   #$13,D0
	lea     $44(SP),A1
	pea     $42(SP)
	bsr     T_1248
	addq.w  #4,SP
T_E24:         move.w  #0,10(SP)
	tst.w   $42(SP)
	beq.s   T_E3E
	move.b  #$2D,8(SP)
	move.w  #1,10(SP)
	bra.s   T_E64
T_E3E:         btst    #2,D7
	beq.s   T_E52
	move.b  #$2B,8(SP)
	move.w  #1,10(SP)
	bra.s   T_E64
T_E52:         btst    #0,D7
	beq.s   T_E64
	move.b  #$20,8(SP)
	move.w  #1,10(SP)
T_E64:         move.w  $44(SP),D5
	bge     T_F3C
	neg.w   D5
	move.b  #$30,12(SP)
	move.w  #1,$20(SP)
	moveq   #2,D6
	tst.w   D4
	bne.s   T_E88
	btst    #1,D7
	bne.s   T_E88
	subq.w  #1,D6
T_E88:         cmp.w   D4,D5
	beq.s   T_E9E
	bcs.s   T_EF2
	move.w  D4,6(SP)
	add.w   D4,D6
	move.w  #0,$36(SP)
	bra     T_FD4
T_E9E:         tst.w   D5
	bne.s   T_EB0
	moveq   #0,D0
	move.w  D0,6(SP)
	move.w  D0,$36(SP)
	bra     T_FD4
T_EB0:         movea.l A2,A0
	moveq   #$13,D0
	lea     $44(SP),A1
	pea     $42(SP)
	bsr     T_1248
	addq.w  #4,SP
	cmpi.b  #$35,(A0)
	bcc.s   T_ED8
	move.w  D5,6(SP)
	add.w   D5,D6
	move.w  #0,$36(SP)
	bra     T_FD4
T_ED8:         subq.w  #1,D5
	move.w  D5,6(SP)
	add.w   D5,D6
	move.b  #$31,$22(SP)
	moveq   #1,D0
	move.w  D0,$36(SP)
	add.w   D0,D6
	bra     T_FD4
T_EF2:         sub.w   D5,D4
	cmp.w   #$13,D4
	bhi     T_100E
	movea.l A2,A0
	move.w  D4,D0
	lea     $44(SP),A1
	pea     $42(SP)
	bsr     T_1248
	addq.w  #4,SP
	move.b  #$30,0(A0,D4.w)
	add.w   D5,D4
	move.w  $44(SP),D5
	neg.w   D5
	sub.w   D5,D4
	move.w  D4,$36(SP)
	add.w   D4,D6
	lea     $22(SP),A1
	subq.w  #1,D4
	blt.s   T_F32
T_F2C:         move.b  (A0)+,(A1)+
	dbra    D4,T_F2C
T_F32:         move.w  D5,6(SP)
	add.w   D5,D6
	bra     T_FD4
T_F3C:         move.w  #0,6(SP)
	move.w  D5,D0
	add.w   D4,D0
	cmp.w   #$13,D0
	bhi     T_100E
	movea.l A2,A0
	lea     $44(SP),A1
	pea     $42(SP)
	bsr     T_1248
	addq.w  #4,SP
	move.w  D5,D0
	add.w   D4,D0
	move.b  #$30,0(A0,D0.w)
	move.w  $44(SP),D5
	move.w  D5,D6
	addq.w  #1,D6
	add.w   D4,D6
	tst.w   D4
	bne.s   T_F7E
	btst    #1,D7
	bne.s   T_F7E
	subq.w  #1,D6
T_F7E:         move.w  D4,$36(SP)
	moveq   #$30,D2
	tst.b   (A0)
	bne.s   T_FA6
	move.b  D2,12(SP)
	move.w  #1,$20(SP)
	addq.w  #1,$44(SP)
	lea     $22(SP),A1
	subq.w  #1,D4
	bmi.s   T_FD4
T_F9E:         move.b  D2,(A1)+
	dbra    D4,T_F9E
	bra.s   T_FD4
T_FA6:         lea     12(SP),A1
	move.w  D5,$20(SP)
	subq.w  #1,D5
	bpl.s   T_FC0
	move.b  #$30,(A1)+
	move.w  #1,$20(SP)
	addq.w  #1,D6
	bra.s   T_FC6
T_FC0:         move.b  (A0)+,(A1)+
	dbra    D5,T_FC0
T_FC6:         lea     $22(SP),A1
	subq.w  #1,D4
	bmi.s   T_FD4
T_FCE:         move.b  (A0)+,(A1)+
	dbra    D4,T_FCE
T_FD4:         moveq   #0,D2
	add.w   10(SP),D6
	sub.w   D6,D3
	bgt.s   T_FEA
	move.w  D2,2(SP)
	move.w  D2,4(SP)
	bra     T_110E
T_FEA:         btst    #3,D7
	bne.s   T_FF6
	btst    #4,D7
	bne.s   T_1002
T_FF6:         move.w  D3,2(SP)
	move.w  D2,4(SP)
	bra     T_110E
T_1002:        move.w  D2,2(SP)
	move.w  D3,4(SP)
	bra     T_110E
T_100E:        move.b  #$3F,12(SP)
	move.w  #1,$20(SP)
	moveq   #0,D4
	move.w  D4,10(SP)
	move.w  D4,6(SP)
	move.w  D4,$36(SP)
	moveq   #1,D6
	bra.s   T_FD4
_OutFixF:      movem.l D3-D7/A2/A3,-(SP)
	lea     -$62(SP),SP
	movea.l A0,A2
	movea.l A1,A3
	move.w  #0,$40(SP)
	move.w  D0,D7
	move.w  D7,(SP)
	move.w  D1,D3
	move.w  D2,D4
	bmi.s   T_1052
	cmp.w   #$12,D4
	bmi.s   T_1054
	moveq   #$12,D4
	bra.s   T_1054
T_1052:        moveq   #6,D4
T_1054:        move.w  (A2),D0
	bclr    #15,D0
	cmp.w   #$7FFF,D0
	beq     T_11BA
	movea.l A2,A0
	lea     $4E(SP),A1
	bsr     _fabs
	lea     $4E(SP),A0
	tst.l   (A0)+
	bne.s   T_107E
	tst.l   (A0)+
	bne.s   T_107E
	tst.w   (A0)
	beq     T_1100
T_107E:        lea     $4E(SP),A0
	lea     $58(SP),A1
	bsr     _log10
	lea     $58(SP),A0
	btst    #7,(A0)
	sne     D0
	ext.w   D0
	move.w  D0,-(SP)
	bsr     _xwcnv
	add.w   (SP)+,D0
	movea.l A2,A0
	lea     $44(SP),A1
	pea     $42(SP)
	cmp.w   #-$4,D0
	bmi.s   T_10E8
	cmp.w   D0,D4
	bmi.s   T_10E8
	add.w   D4,D0
	addq.w  #1,D0
	cmp.w   #$12,D0
	bmi.s   T_10BE
	moveq   #$12,D0
T_10BE:        bsr     T_1248
	addq.w  #4,SP
T_10C4:        tst.b   (A0)+
	bne.s   T_10C4
	subq.l  #1,A0
T_10CA:        cmpi.b  #$30,-(A0)
	beq.s   T_10CA
	addq.l  #1,A0
	suba.l  #cnv_stri,A0
	move.w  A0,D4
	sub.w   $44(SP),D4
	bpl     T_E24
	clr.w   D4
	bra     T_E24
T_10E8:        move.w  D4,D0
	bsr     T_1248
	addq.w  #4,SP
	adda.w  D4,A0
T_10F2:        cmpi.b  #$30,-(A0)
	dbne    D4,T_10F2
	subq.w  #1,D4
	bra     T_C7E
T_1100:        clr.w   D4
	clr.w   $42(SP)
	clr.w   $44(SP)
	bra     T_E24
T_110E:        move.w  (SP),D3
	moveq   #0,D4
	move.w  2(SP),D0
	beq.s   T_1126
	btst    #3,D3
	bne.s   T_1126
	add.w   D0,D4
	movea.l A3,A0
	bsr     OutBlank
T_1126:        move.w  10(SP),D0
	beq.s   T_1134
	add.w   D0,D4
	lea     8(SP),A0
	jsr     (A3)
T_1134:        move.w  4(SP),D0
	beq.s   T_1142
	add.w   D0,D4
	movea.l A3,A0
	bsr     OutZero
T_1142:        move.w  $20(SP),D0
	beq.s   T_1150
	add.w   D0,D4
	lea     12(SP),A0
	jsr     (A3)
T_1150:        tst.w   6(SP)
	bne.s   T_1162
	tst.w   $36(SP)
	bne.s   T_1162
	btst    #1,D3
	beq.s   T_1170
T_1162:        moveq   #1,D0
	add.w   D0,D4
	lea     12(SP),A0
	move.b  #$2E,(A0)
	jsr     (A3)
T_1170:        move.w  6(SP),D0
	beq.s   T_117E
	add.w   D0,D4
	movea.l A3,A0
	bsr     OutZero
T_117E:        move.w  $36(SP),D0
	beq.s   T_118C
	add.w   D0,D4
	lea     $22(SP),A0
	jsr     (A3)
T_118C:        move.w  $40(SP),D0
	beq.s   T_119A
	add.w   D0,D4
	lea     $38(SP),A0
	jsr     (A3)
T_119A:        move.w  2(SP),D0
	beq.s   T_11AE
	btst    #3,D3
	beq.s   T_11AE
	add.w   D0,D4
	movea.l A3,A0
	bsr     OutBlank
T_11AE:        move.w  D4,D0
	lea     $62(SP),SP
	movem.l (SP)+,D3-D7/A2/A3
	rts
T_11BA:        move.w  #8,D0
	lsr.w   #1,D0
	subq.w  #1,D0
	moveq   #2,D1
T_11C4:        tst.w   0(A2,D1.w)
	bne.s   T_1206
	addq.w  #2,D1
	dbra    D0,T_11C4
	move.b  #$2B,12(SP)
	btst    #7,(A2)
	beq.s   T_11E2
	move.b  #$2D,12(SP)
T_11E2:        move.b  #$49,13(SP)
	move.b  #$6E,14(SP)
	move.b  #$66,15(SP)
	moveq   #4,D0
	move.w  D0,$20(SP)
	sub.w   D0,D3
	bpl.s   T_1200
	moveq   #0,D3
T_1200:        move.w  D3,2(SP)
	bra.s   T_1228
T_1206:        move.b  #$4E,12(SP)
	move.b  #$61,13(SP)
	move.b  #$6E,14(SP)
	moveq   #3,D0
	move.w  D0,$20(SP)
	sub.w   D0,D3
	bpl.s   T_1224
	moveq   #0,D3
T_1224:        move.w  D3,2(SP)
T_1228:        bclr    #1,1(SP)
	moveq   #0,D0
	move.w  D0,10(SP)
	move.w  D0,4(SP)
	move.w  D0,6(SP)
	move.w  D0,$36(SP)
	move.w  D0,$40(SP)
	bra     T_110E
T_1248:        moveq   #0,D1
	move.l  4(SP),-(SP)
	move.l  A1,-(SP)
	lea     cnv_stri,A1
	bsr     ftoa
	addq.w  #8,SP
	lea     cnv_stri,A0
	rts
fcvt:          moveq   #1,D1
	bra.s   T_126A
ecvt:          moveq   #0,D1
T_126A:        pea     (A1)
	pea     (A0)
	lea     B_4E6A,A1
	lea     12(SP),A0
	bsr.s   ftoa
	addq.w  #8,SP
	rts
ftoa:          movem.l D3-D7/A6,-(SP)
	lea     (A1),A6
	move.w  D1,D4
	move.w  D0,D6
	ble     T_13AC
	tst.w   (A0)
	smi     D0
	andi.w  #1,D0
	movea.l $20(SP),A1
	move.w  D0,(A1)
	bsr     _normA0
	bmi.s   T_12D0
	beq.s   T_12C2
	bvc.s   T_12B2
	lea     _INFP(PC),A6
	tst.w   D0
	bpl.s   T_12B6
	lea     _INFM(PC),A6
	bra.s   T_12B6
T_12B2:        lea     _NAN(PC),A6
T_12B6:        moveq   #0,D0
	bra     T_13AC
T_12BC:        move.b  #$30,0(A6,D6.w)
T_12C2:        dbra    D6,T_12BC
	movea.l $1C(SP),A0
	clr.w   (A0)
	bra     T_13AA
T_12D0:        lea     -$A(SP),SP
	andi.w  #$7FFF,D0
	move.l  D2,-(SP)
	move.l  D1,-(SP)
	move.w  D0,-(SP)
	move.w  D0,D3
	move.w  D0,D7
	mulu.w  #$4D10,D7
	swap    D7
	subi.w  #$1343,D7
	lea     10(SP),A0
	move.w  D7,D0
	bpl.s   T_1306
	neg.w   D0
	bsr     _pow10
	lea     (SP),A0
	lea     10(SP),A1
	bsr     __xxmul
	bra.s   T_1314
T_1306:        bsr     _pow10
	lea     (SP),A0
	lea     10(SP),A1
	bsr     __xxdiv
T_1314:        cmpi.w  #$3FFE,(A0)
	bhi.s   T_1326
	lea     _xc10(PC),A1
	bsr     __xxmul
	subq.w  #1,D7
	bra.s   T_1314
T_1326:        lea     (SP),A0
	move.w  (A0)+,D3
	move.l  (A0)+,D1
	move.l  (A0)+,D2
	addq.w  #1,D7
	tst.w   D4
	ble.s   T_133A
	add.w   D7,D6
	bgt.s   T_133A
	moveq   #1,D6
T_133A:        cmpi.w  #$14,D6
	ble.s   T_1342
	moveq   #$14,D6
T_1342:        movea.l $30(SP),A0
	move.w  D7,(A0)
	lea     (A6),A1
	subi.w  #$3FFF,D3
	subq.w  #1,D6
	moveq   #0,D0
T_1352:        add.l   D2,D2
	addx.l  D1,D1
	addx.w  D0,D0
	dbra    D3,T_1352
	bra.s   T_137E
T_135E:        moveq   #0,D0
	add.l   D2,D2
	addx.l  D1,D1
	addx.w  D0,D0
	move.l  D2,D5
	move.l  D1,D4
	move.w  D0,D3
	add.l   D2,D2
	addx.l  D1,D1
	addx.w  D0,D0
	add.l   D2,D2
	addx.l  D1,D1
	addx.w  D0,D0
	add.l   D5,D2
	addx.l  D4,D1
	addx.w  D3,D0
T_137E:        add.b   #$30,D0
	move.b  D0,(A1)+
	dbra    D6,T_135E
	clr.b   (A1)
	tst.l   D1
	bpl.s   T_13A6
T_138E:        addq.b  #1,-(A1)
	cmpi.b  #$3A,(A1)
	bne.s   T_13A6
	cmpa.l  A1,A6
	beq.s   T_13A0
	move.b  #$30,(A1)
	bra.s   T_138E
T_13A0:        move.b  #$31,(A1)
	addq.w  #1,(A0)
T_13A6:        lea     $14(SP),SP
T_13AA:        moveq   #1,D0
T_13AC:        lea     (A6),A0
	movem.l (SP)+,D3-D7/A6
	rts
T_13B4:        bsr.s   T_142A
	bsr.s   T_1426
	move.w  D0,D1
atan2:         lea     8(SP),A0
	lea     $12(SP),A1
_atan2:        tst.l   2(A1)
	bne.s   T_140E
	tst.l   6(A1)
	bne.s   T_140E
	pea     (A6)
	movea.l 8(SP),A6
	tst.l   2(A0)
	bne.s   T_13F6
	tst.l   6(A0)
	bne.s   T_13F6
	pea     (A6)
	pea     T_13B4(PC)
	clr.w   (A6)+
	clr.l   (A6)+
	clr.l   (A6)+
	moveq   #1,D0
	bsr     _xmather
	addq.w  #8,SP
	bra.s   T_140A
T_13F6:        lea     _xcph(PC),A1
	move.w  (A1)+,(A6)+
	move.l  (A1)+,(A6)+
	move.l  (A1)+,(A6)+
	tst.w   (A0)
	bge.s   T_140A
	bchg    #7,-$A(A6)
T_140A:        movea.l (SP)+,A6
T_140C:        rts
T_140E:        move.w  (A1),-(SP)
	addq.w  #6,A0
	move.l  (A0),-(SP)
	move.l  -(A0),-(SP)
	move.w  -(A0),-(SP)
	lea     (SP),A0
	bsr     _xxdiv
	movea.l $10(SP),A1
	bsr     _atan
T_1426:        lea     10(SP),SP
T_142A:        tst.w   (SP)+
	bge.s   T_140C
	movea.l 4(SP),A0
	lea     _xcpi(PC),A1
	tst.w   (A0)
	blt     _xxadd
	bgt     _xxsub
	tst.l   2(A0)
	bne     _xxsub
	tst.l   6(A0)
	bne     _xxsub
	bra     _xxadd
atan:          lea     8(SP),A0
	movea.l 4(SP),A1
_atan:         move.w  #$480A,D2
	btst    #7,_fpumode
	bne     _fpu1op
__atan:        bsr     _normA0
	bmi.s   T_148A
	bvc     _ret012
	lea     _xcph(PC),A0
	move.w  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	andi.w  #-$8000,D0
	or.w    D0,-$A(A1)
	rts
T_148A:        movem.l D5-D7/A5/A6,-(SP)
	lea     (A1),A6
	lea     _fpumode,A1
	move.w  (A1),-(SP)
	clr.w   (A1)
	move.w  D0,D5
	andi.w  #$7FFF,D0
	move.l  D2,-(SP)
	move.l  D1,-(SP)
	move.w  D0,-(SP)
	cmpi.w  #$3FFE,D0
	shi     D5
	bls.s   T_14BA
	lea     (SP),A0
	bsr     __xxinv
	move.w  (A0)+,D0
	move.l  (A0)+,D1
	move.l  (A0)+,D2
T_14BA:        moveq   #0,D6
	cmpi.w  #$3FF9,D0
	bcs.s   T_14EC
	beq.s   T_14D2
T_14C4:        subq.w  #1,D0
	add.l   D2,D2
	roxl.l  #1,D1
	roxl.w  #1,D6
	cmpi.w  #$3FF9,D0
	bne.s   T_14C4
T_14D2:        tst.l   D1
	bpl.s   T_14E2
	neg.l   D2
	negx.l  D1
	bvs.s   T_14E8
	addq.w  #1,D6
	ori.w   #-$8000,D0
T_14E2:        bne.s   T_14E8
	tst.l   D2
	beq.s   T_14EC
T_14E8:        bsr     _norm012
T_14EC:        move.w  D6,D7
	add.w   D7,D7
	add.w   D7,D7
	add.w   D7,D6
	add.w   D6,D6
	move.l  D2,-(SP)
	move.l  D1,-(SP)
	move.w  D0,-(SP)
	clr.l   -(SP)
	clr.l   -(SP)
	move.b  D7,(SP)
	move.w  #$3FFF,-(SP)
	lea     (SP),A0
	lea     $14(SP),A1
	bsr     __xxmul
	bsr     __xxinc
	lea     (A0),A1
	lea     10(SP),A0
	bsr     __xxdiv
	lea     $14(SP),A1
	bsr     __square
	lea     T_16FE(PC),A5
	lea     10(A6),A0
	move.l  -(A5),-(A0)
	move.l  -(A5),-(A0)
	move.w  -(A5),-(A0)
	moveq   #3,D7
T_1536:        bsr     __xxmul
	lea     -$A(A5),A5
	exg     A1,A5
	bsr     __xxadd
	exg     A1,A5
	dbra    D7,T_1536
	lea     10(SP),A1
	bsr     __xxmul
	lea     T_1582(PC,D6.w),A1
	bsr     __xxadd
	tst.b   D5
	beq.s   T_156A
	lea     _xcph(PC),A1
	bsr     __xxsub
	bchg    #7,(A6)
T_156A:        tst.w   D5
	bpl.s   T_1572
	bchg    #7,(A6)
T_1572:        lea     $1E(SP),SP
	move.w  (SP)+,_fpumode
	movem.l (SP)+,D5-D7/A5/A6
	rts
T_1582:        ori.b   #0,D0
	ori.b   #0,D0
	dc.w    $0000            ;
	dc.w    $3FF9            ;?˘
	dc.w    $FFEA            ;ˇÍ
	dc.w    $ADDD            ;≠›
	dc.w    $4BB1            ;K±
	move.l  D2,$3FFA(A2)
	dc.w    $FFAA            ;ˇ™
	add.l   D6,$67EF4E37
	dc.w    $3FFB            ;?˚
	eor.w   D7,$17887461(A0,A4.w)
	dc.w    $3FFB            ;?˚
	dc.w    $FEAD            ;˛≠
	adda.w  (A5),A2
	dc.w    $617B            ;a{
	dc.w    $6E33            ;n3
	dc.w    $3FFC            ;?¸
	dc.w    $9EB7            ;û∑
	dc.w    $7746            ;wF
	move.w  (A3),-(A1)
	dc.w    $62C3            ;b√
	dc.w    $3FFC            ;?¸
T_15C0:        cmpa.l  A3,A6
	add.w   (A6)+,D5
	moveq   #-$28,D1
	move.b  $FC(A4,D3.l*8),-(A0)
	add.l   D6,D6
	cmp.l   (A4),D5
	subx.b  D5,D1
	move.b  -(A3),D0
	dc.w    $3FFC            ;?¸
T_15D4:        dc.w    $FADB            ;˙€
	dc.w    $AFC9            ;Ø…
	bcc.s   T_15E0
	roxl.b  #5,D5
	dc.w    $3FFD            ;?˝
	or.w    (SP)+,D6
T_15E0:        dc.w    $AD18            ;≠
	subq.l  #7,A3
	and.b   D0,$FD(A1,D3.l*8)
	sub.b   D5,(A3)
	eor.l   D4,$3F5E.w
	addq.w  #7,$3FFD(A2)
	dc.w    $A985            ;©Ö
	bge.s   T_15C0
	or.w    $4EDB(A2),D7
	dc.w    $3FFD            ;?˝
	eor.l   D3,15(A0,A4.l*2)
	move.l  $74(SP,A0.w*4),(A3)+
	dc.w    $3FFD            ;?˝
	and.l   D2,(A2)
	bvs.s   T_15D4
	st      (A1)+
	move.l  $3FFD(A6),-$2CD9(A5)
	moveq   #$1E,D3
	dc.w    $611F            ;a
	roxl.l  D2,D6
	dc.w    $3FFD            ;?˝
	lsr.w   D0,D5
	dc.w    $A64A            ;¶J
	moveq   #$4F,D3
	moveq   #$68,D6
	dc.w    $3FFD            ;?˝
	asl.w   D6,D3
	move.w  $DDA(A3),D4
	dc.w    $7B45            ;{E
	dc.w    $3FFD            ;?˝
	dc.w    $FA06            ;˙
	ror.w   #4,D2
	dc.w    $A0A0            ;††
	cmp.w   (A4)+,D7
	dc.w    $3FFE            ;?˛
	or.b    D1,-$B5A(A3)
	addx.l  D6,D4
	moveq   #$2A,D7
	dc.w    $3FFE            ;?˛
	or.b    D4,-$1321(A2)
	add.l   (A5),D7
	chk     $FE(A5,D3.l*8),D3
	sbcd    D0,D7
	subq.w  #6,(A6)+
	dc.w    $F7F5            ;˜ı
	sub.l   D7,(A3)+
	dc.w    $3FFE            ;?˛
	sub.l   $72C9(A4),D2
	or.w    $F6(A1,A0.w*8),D2
	dc.w    $3FFE            ;?˛
	sub.b   -$7F1A(SP),D5
	dc.w    $71BD            ;qΩ
	add.b   -(A0),D5
	dc.w    $3FFE            ;?˛
	subx.l  -(A1),-(SP)
	dc.w    $FDC4            ;˝ƒ
	dc.w    $F4B7            ;Ù∑
	dc.w    $A1ED            ;°Ì
	dc.w    $3FFE            ;?˛
	dc.w    $A4BC            ;§º
	dc.w    $7D19            ;}
	move.w  ([$3FFE,SP],D0.l),(A2)+
	dc.w    $A9C7            ;©«
	dc.w    $ABDC            ;´‹
	nbcd    $C9(A0,SP.w*4)
	dc.w    $3FFE            ;?˛
	dc.w    $AEAC            ;Æ¨
	mulu.l  $FFFFC080.w,D3
	dc.w    $3FFE            ;?˛
T_1692:        eor.w   D1,$31C9(A3)
	move.b  D4,-(SP)
	move.w  (A1),(A3)
	dc.w    $3FFE            ;?˛
	cmp.b   D5,D4
	move.w  -$3DCF(A3),D7
	sub.w   $FE(A4,D3.l*8),D7
	cmp.w   T_1692(PC,D5.l*4),D6
	lsl.l   #4,D2
	dc.w    $F281            ;ÚÅ
	dc.w    $3FFE            ;?˛
	dc.w    $C0CE            ;¿Œ
	or.l    D2,$FFFFAC52.w
	dc.w    $6641            ;fA
	dc.w    $3FFE            ;?˛
	dc.w    $C4FF            ;ƒˇ
	dc.w    $AFFA            ;Ø˙
	cmpm.l  (SP)+,(SP)+
	eor.w   D6,(A5)
	dc.w    $3FFE            ;?˛
	abcd    -(SP),-(A4)
	add.l   -(A2),D5
	move.l  -$3DCB(A0),$3FFF(A0)
	or.b    D0,D0
	ori.b   #0,D0
	dc.w    $0000            ;
	dc.w    $BFFD            ;ø˝
	dc.w    $AAAA            ;™™
	dc.w    $AAAA            ;™™
	dc.w    $AAAA            ;™™
	dc.w    $A620            ;¶
	dc.w    $3FFC            ;?¸
	dc.w    $CCCC            ;ÃÃ
	dc.w    $CCCC            ;ÃÃ
	and.w   D1,D4
	and.b   -(A5),D1
	cmpa.l  #-$6DB6DC3A,SP
	cmpa.l  $15BF(A3),A6
	dc.w    $3FFB            ;?˚
	roxl.w  D1,D1
	move.l  -(SP),D2
	dc.w    $64DD            ;d›
	dc.w    $23AB            ;#´
T_16FE:        dc.w    $BFFB            ;ø˚
T_1700:        abcd    D2,D4
	muls.w  $CF(A2,A0.l*8),D7
	cmpa.l  -(A2),A4
T_1708:        moveq   #$6F,D0
	dc.w    $7765            ;we
	moveq   #0,D1
pow:           lea     8(SP),A0
	lea     $12(SP),A1
_pow:          pea     (A6)
	lea     (A1),A6
	clr.l   -(SP)
	bsr     _normA0
	move.l  D2,-(SP)
	move.l  D1,-(SP)
	move.w  D0,-(SP)
	lea     (A6),A0
	bsr     _normA0
	move.l  D2,-(SP)
	move.l  D1,-(SP)
	move.w  D0,-(SP)
	movea.l $20(SP),A6
	bne.s   T_1776
	move.l  #$3FFF8000,(A6)+
	clr.w   (A6)+
	clr.l   (A6)+
	tst.l   12(SP)
	beq.s   T_175C
	bra     T_180C
T_174C:        move.w  #$7FFF,(A6)+
	move.l  #-1,(A6)+
	move.l  #-1,(A6)+
T_175C:        lea     10(SP),A0
	lea     (SP),A1
	pea     -$A(A6)
	pea     T_1708(PC)
	moveq   #1,D0
	bsr     _xmather
	addq.w  #8,SP
	bra     T_180C
T_1776:        tst.w   10(SP)
	bgt.s   T_17E4
	bmi.s   T_1790
	tst.l   12(SP)
	bne.s   T_17E4
	tst.w   (SP)
	bmi.s   T_174C
	clr.w   (A6)+
	clr.l   (A6)+
	clr.l   (A6)+
	bra.s   T_180C
T_1790:        bclr    #7,10(SP)
	move.w  (SP),D0
	andi.w  #$7FFF,D0
	subi.w  #$403E,D0
	neg.w   D0
	bmi.s   T_17E4
	cmpi.w  #$3F,D0
	bhi.s   T_174C
	moveq   #0,D1
	moveq   #0,D2
	cmpi.w  #$1F,D0
	bhi.s   T_17BE
	bset    D0,D2
	move.l  6(SP),D0
	and.l   D2,D0
	bra.s   T_17CA
T_17BE:        subi.w  #$20,D0
	bset    D0,D1
	move.l  2(SP),D0
	and.l   D1,D0
T_17CA:        subq.l  #1,D2
	bcc.s   T_17D0
	subq.l  #1,D1
T_17D0:        and.l   2(SP),D1
	bne     T_174C
	and.l   6(SP),D2
	bne     T_174C
	move.l  D0,$14(SP)
T_17E4:        lea     10(SP),A0
	lea     (A6),A1
	bsr     _log2
	lea     (SP),A1
	lea     _fpumode,A0
	move.w  (A0),-(SP)
	clr.w   (A0)
	lea     (A6),A0
	bsr     _xxmul
	move.w  (SP)+,_fpumode
	lea     (A6),A1
	bsr     _exp2
T_180C:        tst.l   $14(SP)
	beq.s   T_1816
	bchg    #7,(A6)
T_1816:        lea     $18(SP),SP
	movea.l (SP)+,A6
	rts
pow10:         movea.l 4(SP),A0
_pow10:        move.w  D0,-(SP)
	bpl.s   T_1828
	neg.w   D0
T_1828:        cmpi.w  #$1800,D0
	bls.s   T_1832
	move.w  #$1800,D0
T_1832:        move.w  D7,-(SP)
	move.w  D0,D7
	andi.w  #7,D0
	move.w  D0,D1
	add.w   D1,D1
	add.w   D1,D1
	add.w   D0,D1
	add.w   D1,D1
	lea     T_1872(PC,D1.w),A1
	move.w  (A1)+,(A0)+
	move.l  (A1)+,(A0)+
	move.l  (A1)+,(A0)
	subq.w  #6,A0
	lsr.w   #3,D7
	beq.s   T_1868
	lea     T_18B8(PC),A1
T_1858:        lea     10(A1),A1
	lsr.w   #1,D7
	bcc.s   T_1858
	bsr     _xxmul
	tst.w   D7
	bne.s   T_1858
T_1868:        move.w  (SP)+,D7
	tst.w   (SP)+
	bmi     __xxinv
	rts
T_1872:        dc.w    $3FFF            ;?ˇ
	or.b    D0,D0
	ori.b   #0,D0
	dc.w    $0000            ;
	negx.b  D2
	dc.w    $A000            ;init
	ori.b   #0,D0
	dc.w    $0000            ;
	negx.b  D5
T_1888:        and.b   D0,D4
	ori.b   #0,D0
	dc.w    $0000            ;
	dc.w    $4008            ;@
	dc.w    $FA00            ;˙
	ori.b   #0,D0
	dc.w    $0000            ;
	dc.w    $400C            ;@
	sub.w   D0,D6
	ori.b   #0,D0
	dc.w    $0000            ;
	dc.w    $400F            ;@
	and.w   D1,(A0)
	ori.b   #0,D0
	dc.w    $0000            ;
	negx.b  (A2)
	dc.w    $F424            ;Ù$
	ori.b   #0,D0
	dc.w    $0000            ;
T_18B8:        negx.b  (A6)
	sub.l   (A6),D4
	or.b    D0,D0
	ori.b   #0,D0
	negx.b  (A1)+
	cmp.l   #$20000000,D7
	dc.w    $0000            ;
	negx.b  $1B(A4,A0.l*8)
	dc.w    $C9BF            ;…ø
	subi.b  #0,D0
	negx.w  -$623B(A1)
	dc.w    $ADA8            ;≠®
	move.l  $9E(A0,A3.w*4),$40D3(A5)
	and.w   $1F49.w,D1
	dc.w    $FFCF            ;ˇœ
	dc.w    $A6D5            ;¶’
	chk     -$6C46(A0),D0
	dc.w    $47C9            ;G…
	divu.w  -$7320(A1),D0
	dc.w    $4351            ;CQ
	dc.w    $AA7E            ;™~
	bfexts  T_1888(PC,A5.l*8){D23:D25},D1
	not.l   -(A3)
	rol.b   #1,D1
	dc.w    $A0AE            ;†Æ
	dc.w    $A60E            ;¶
	suba.l  D7,A0
	dc.w    $4D48            ;MH
	dc.w    $C976            ;…v
	dc.w    $7586            ;uÜ
	or.w    D0,$17(A5,D0.l*4)
	addq.l  #5,(A2)
	sub.l   A3,D7
	move.w  (A5)+,-$3AC3(A5)
	slt     -(A5)
	dc.w    $7525            ;u%
	and.w   -(A0),D2
	addq.b  #1,D2
	or.b    -(A0),D5
	sub.l   D3,(A3)+
T_1926:        bcs.s   T_19A0
	moveq   #0,D0
	dc.w    $BFFD            ;ø˝
	suba.l  $98(A6,D1.l),A2
	cmpi.w  #$36F7,D3
	dc.w    $BFFD            ;ø˝
	divs.w  -$473F(A6),D2
	dc.w    $4FE7            ;OÁ
	sub.l   D3,D1
	cmpa.l  #-$159CA846,SP
	dc.w    $ABE4            ;´‰
	sub.l   A3,D2
	cmpa.l  #-$38923055,SP
	divs.w  -$390(A5),D0
	cmpa.l  #-$5D13F32C,SP
	dc.w    $A58A            ;•ä
	addq.b  #2,-$4005(SP)
	dc.w    $F999            ;˘ô
T_1960:        dc.w    $089E            ; û
	dc.w    $AB58            ;´X
	dc.w    $F778            ;˜x
	cmpa.l  T_1961(PC,A2.l),SP
	mulu.w  D1,D4
	move.b  (A6)+,(A3)+
	move.w  A1,(A3)
	cmpa.l  __text-$38E6(PC),SP
	move.l  -$486D(A5),(SP)
	move.w  $0.w,-(A6)       ;reset_ssp
	ori.b   #0,D0
	ori.b   #0,D0
	dc.w    $3FFA            ;?˙
	eor.w   D2,(A0)+
	dc.w    $6CF9            ;l˘
	sbcd    -(SP),-(A4)
	dc.w    $6299            ;bô
	dc.w    $3FFB            ;?˚
	eor.w   D4,(A4)+
	dc.w    $1E3E            ; >
	dc.w    $A8BD            ;®Ω
	bgt.s   T_1A08
	dc.w    $3FFC            ;?¸
	or.b    (A6)+,D7
	sub.l   D5,(A5)+
	addq.l  #4,A6
T_19A0:        move.b  $FC(A0,D3.l*8),$BF(A4,A4.w)
	dc.w    $828C            ;Çå
	dc.w    $6DC5            ;m≈
	dc.w    $4B7A            ;Kz
	dc.w    $3FFC            ;?¸
	dc.w    $F7A9            ;˜©
	subx.b  D4,D1
	sbcd    -(A0),-(A6)
	or.w    D6,$3FFD(A5)
	suba.l  T_1960(PC,D5.l*2),A3
	exg     D2,D4
	lsl.l   D1,D0
	dc.w    $3FFD            ;?˝
	eor.w   D2,-(A0)
	dc.w    $FBA9            ;˚©
	eori.l  #$2B193FFD,D5
	add.b   (A3),D2
	dc.w    $CCCF            ;Ãœ
	rol.w   D3,D1
	sub.b   (A1),D1
	dc.w    $3FFD            ;?˝
	eor.w   D0,([-$2E308655],-$40071CA8)
	not.l   $24FF.w
	addq.l  #7,(A5)
	dc.w    $3FF4            ;?Ù
	dc.w    $AEC3            ;Æ√
T_19EC:        dc.w    $FF34            ;ˇ4
	dc.w    $0DFD            ; ˝
	moveq   #$1F,D4
	cmpa.l  $EE(A0,A0.w*8),SP
	ror.b   #8,D5
	adda.w  A1,A6
	add.l   $6100(SP),D4
	move.b  D0,$6C00(A3)
	move.b  -(A6),$81(A3,D4.l*2)
	bmi.s   T_1A14
T_1A08:        bne.s   T_1A10
	tst.l   D2
	beq     _ret012
T_1A10:        bsr     _norm012
T_1A14:        lea     _fpumode,A0
	move.w  (A0),-(SP)
	clr.w   (A0)
	movem.l D3/D4/A5/A6,-(SP)
	lea     (A1),A6
	movea.w D0,A5
	moveq   #0,D3
	andi.w  #$7FFF,D0
	cmpi.w  #$3FFA,D0
	bhi.s   T_1A38
	beq.s   T_1A46
	move.w  A5,D0
	bra.s   T_1A74
T_1A38:        subq.w  #1,D0
	add.l   D2,D2
	roxl.l  #1,D1
	roxl.w  #1,D3
	cmpi.w  #$3FFA,D0
	bne.s   T_1A38
T_1A46:        tst.l   D1
	bpl.s   T_1A56
	neg.l   D2
	negx.l  D1
	bvs.s   T_1A5C
	addq.w  #1,D3
	ori.w   #-$8000,D0
T_1A56:        bne.s   T_1A5C
	tst.l   D2
	beq.s   T_1A60
T_1A5C:        bsr     _norm012
T_1A60:        add.w   D3,D3
	move.w  D3,D4
	add.w   D4,D4
	add.w   D4,D4
	add.w   D4,D3
	move.w  A5,D4
	bpl.s   T_1A74
	neg.w   D3
	eori.w  #-$8000,D0
T_1A74:        move.l  D2,-(SP)
	move.l  D1,-(SP)
	move.w  D0,-(SP)
	lea     (SP),A0
	lea     -$1E(SP),SP
	lea     $14(SP),A1
	bsr     __square
	lea     __expa(PC),A5
	lea     10(SP),A0
	move.l  -(A5),-(A0)
	move.l  -(A5),-(A0)
	move.w  -(A5),-(A0)
	moveq   #2,D4
T_1A98:        bsr     __xxmul
	lea     -$A(A5),A5
	exg     A1,A5
	bsr     __xxadd
	exg     A1,A5
	dbra    D4,T_1A98
	lea     $1E(SP),A1
	bsr     __xxmul
	move.l  #$3FFF8000,10(SP)
	clr.w   14(SP)
	clr.l   $10(SP)
	lea     (A0),A1
	lea     10(SP),A0
	bsr     __xxsub
	exg     A0,A1
	addq.w  #1,(SP)
	bsr     __xxdiv
	lea     T_197A(PC),A1
	adda.w  D3,A1
	move.w  (A0)+,(A6)+
	move.l  (A0)+,(A6)+
	move.l  (A0),(A6)+
	subq.w  #6,A0
	bsr     __xxadd
	lea     -$A(A6),A0
	bsr     __xxmul
	lea     (SP),A1
	bsr     __xxadd
	lea     $28(SP),SP
	movem.l (SP)+,D3/D4/A5/A6
	move.w  (SP)+,_fpumode
	rts
exp10:         lea     8(SP),A0
	movea.l 4(SP),A1
_exp10:        move.w  #$4812,D2
	btst    #7,_fpumode
	bne     _fpu1op
__exp10:       move.w  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	lea     -$A(A1),A0
	lea     _fpumode,A1
	move.w  (A1),-(SP)
	clr.w   (A1)
	lea     _xclg2(PC),A1
	bsr     __xxdiv
	move.w  (SP)+,_fpumode
	lea     (A0),A1
	bra.s   __exp2
exp:           lea     8(SP),A0
	movea.l 4(SP),A1
_exp:          move.w  #$4810,D2
	btst    #7,_fpumode
	bne     _fpu1op
__exp:         move.w  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	lea     -$A(A1),A0
	lea     _fpumode,A1
	move.w  (A1),-(SP)
	clr.w   (A1)
	lea     _xcln2(PC),A1
	bsr     __xxdiv
	move.w  (SP)+,_fpumode
	lea     (A0),A1
	bra.s   __exp2
exp2:          lea     8(SP),A0
	movea.l 4(SP),A1
_exp2:         move.w  #$4811,D2
	btst    #7,_fpumode
	bne     _fpu1op
__exp2:        bsr     _normA0
	bgt     _ret012
	blt.s   T_1BB0
	move.l  #$3FFF8000,(A1)+
	clr.w   (A1)+
	clr.l   (A1)+
	rts
T_1BB0:        movem.l D3-D7,-(SP)
	move.w  D0,D7
	move.w  D0,D5
	moveq   #0,D4
	andi.w  #$7FFF,D5
	subi.w  #$3FFE,D5
	bmi.s   T_1C0A
	beq.s   T_1BEE
	cmpi.w  #15,D5
	blt.s   T_1BD6
	bhi     T_1C58
	tst.w   D7
	bpl     T_1C64
T_1BD6:        bset    D5,D4
	subq.w  #1,D4
	move.l  D4,D3
	move.l  D4,D6
	not.w   D6
	rol.l   D5,D1
	rol.l   D5,D2
	and.w   D1,D4
	and.w   D6,D1
	and.w   D2,D3
	or.w    D3,D1
	and.w   D6,D2
T_1BEE:        move.w  #$3FFE,D0
	tst.l   D1
	bpl.s   T_1C00
	addq.w  #1,D4
	eori.w  #-$8000,D0
	neg.l   D2
	negx.l  D1
T_1C00:        tst.w   D7
	bpl.s   T_1C0A
	neg.w   D4
	eori.w  #-$8000,D0
T_1C0A:        pea     (A0)
	pea     (A1)
	bsr     __expb
	movea.l (SP)+,A0
	lea     _fpumode,A1
	move.w  (A1),-(SP)
	clr.w   (A1)
	bsr     __xxinc
	move.w  (SP)+,_fpumode
	lea     (A0),A1
	movea.l (SP)+,A0
	add.w   D4,(A1)
	bpl.s   T_1C6C
	movem.l -$2(A1),D0-D2
	cmpi.w  #-$41,D0
	bls.s   T_1C5C
	moveq   #0,D3
T_1C3E:        lsr.l   #1,D1
	roxr.l  #1,D2
	roxr.w  #1,D3
	addq.w  #1,D0
	bne.s   T_1C3E
	moveq   #0,D0
	add.w   D3,D3
	addx.l  D0,D2
	addx.l  D0,D1
	move.w  D0,(A1)+
	move.l  D1,(A1)+
	move.l  D2,(A1)+
	bra.s   T_1C6C
T_1C58:        tst.w   D7
	bpl.s   T_1C64
T_1C5C:        clr.w   (A1)+
	clr.l   (A1)+
	clr.l   (A1)+
	bra.s   T_1C6C
T_1C64:        pea     T_1926(PC)
	bsr     _txoverf
T_1C6C:        movem.l (SP)+,D3-D7
	rts
exp1:          lea     8(SP),A0
	movea.l 4(SP),A1
_exp1:         move.w  #$4808,D2
	btst    #7,_fpumode
	bne     _fpu1op
__exp1:        move.w  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	lea     -$A(A1),A0
	lea     _fpumode,A1
	move.w  (A1),-(SP)
	clr.w   (A1)
	lea     _xcln2(PC),A1
	bsr     __xxdiv
	move.w  (SP)+,_fpumode
	lea     (A0),A1
	bra.s   _exp21
exp21:         lea     8(SP),A0
	movea.l 4(SP),A1
__exp21:
_exp21:        bsr     _normA0
	bge     _ret012
	move.w  D0,-(SP)
	andi.w  #$7FFF,D0
	cmpi.w  #$3FFD,D0
	bhi.s   T_1CD2
	move.w  (SP)+,D0
	bra     __expb
T_1CD2:        move.w  (SP)+,D0
	pea     (A1)
	bsr     T_1BB0
	movea.l (SP)+,A0
	lea     _fpumode,A1
	move.w  (A1),-(SP)
	clr.w   (A1)
	bsr     __xxdec
	move.w  (SP)+,_fpumode
	rts
T_1CF2:        dc.w    $6C6F            ;lo
	beq     T_1CF6
	ori.b   #0,D0
	ori.b   #0,D0
	dc.w    $3FFA            ;?˙
	cmpa.l  (A6),A2
	sub.l   D5,$77EC(A4)
	move.w  A2,$FB(A4,D3.l*8)
	eor.b   D1,(SP)+
	cmpa.l  (A6),A3
	dc.w    $4898            ;Hò
	cmpa.l  -(A6),A1
	dc.w    $3FFC            ;?¸
	or.w    -(A2),D2
	and.w   -(A6),D2
	adda.l  SP,A1
	move.b  $FC(A1,D3.l*8),(A6)
	dc.w    $AE00            ;Æ
	adda.l  SP,A0
	add.l   $FD(A4,D3.l*4),D7
	dc.w    $3FFC            ;?¸
T_1D2A:        add.w   T_E99(PC),D3
	dc.w    $A764            ;ßd
	dc.w    $9F7F            ;ü
	dc.w    $3FFC            ;?¸
	dc.w    $FDE0            ;˝‡
	cmpa.l  A0,A2
	move.b  D0,$511D(A1)
	dc.w    $3FFD            ;?˝
	sub.b   -(A0),D1
	move.w  (A0)+,$7039(A6)
	and.b   (A2),D6
	dc.w    $3FFD            ;?˝
	dc.w    $A4D3            ;§”
	and.w   (A6)+,D1
	bvc.s   T_1D2A
	seq     $FD(A2,D3.l*8)
	eor.b   D3,(A1)
	moves.w A6,-$D44(A4)
	dc.w    $3FFD            ;?˝
	mulu.w  (A5)+,D4
	add.w   A0,D2
	dc.w    $F8B8            ;¯∏
	chk     -(A6),D2
	dc.w    $3FFD            ;?˝
	dc.w    $DA3F            ;⁄?
	subq.l  #7,$C4150521
	dc.w    $3FFD            ;?˝
	rol.b   D5,D2
	subx.b  D1,D7
	sub.w   D3,(A0)
	dc.w    $77F2            ;wÚ
	dc.w    $3FFD            ;?˝
	dc.w    $FBD4            ;˚‘
	move.l  D6,$5836(A5)
	moveq   #$71,D3
	dc.w    $3FFE            ;?˛
	dc.w    $8608            ;Ü
	move.l  D6,D4
	cmpa.l  (A5),A0
	move.w  D4,(A1)+
	dc.w    $3FFE            ;?˛
T_1D8E:        divs.w  $88F4AE80,D6
	ble.s   T_1DB4
	dc.w    $3FFE            ;?˛
	suba.l  D0,A2
	move.b  $FBD687A0,D5
	dc.w    $3FFE            ;?˛
	sub.w   D6,(A5)+
	suba.l  (A5),SP
	movep.w $3666(A3),D0
	dc.w    $3FFE            ;?˛
	dc.w    $A4D3            ;§”
	and.w   (A6)+,D1
	bvc.s   T_1D8E
	dc.w    $57F2            ;WÚ
T_1DB4:        dc.w    $3FFE            ;?˛
	dc.w    $AC24            ;¨$
	move.b  $E9(A4,A4.w*4),-(A0)
	sub.b   (A4)+,D7
	dc.w    $3FFE            ;?˛
	eor.w   D1,(A0)
	subi.w  #$3C46,$69(A2,D5.l*8)
	dc.w    $3FFE            ;?˛
	cmp.w   (A0)+,D5
	dc.w    $FEB2            ;˛≤
	moveq   #$3A,D0
	sub.b   $FE(SP,D3.l*8),D7
	exg     D0,D0
	jsr     -$C7D(A5)
	suba.w  (SP)+,A3
	dc.w    $3FFE            ;?˛
	and.b   D7,D4
	move.w  $16(A0,D0.w),(A0)
	beq.s   T_1DD8
	dc.w    $3FFE            ;?˛
	and.l   -$3016(A6),D7
	or.l    D5,D0
	sub.b   D5,$FE(A3,D3.l*8)
	add.b   D2,$47AC.w
	ori.l   #-$6418C002,-(A6)
	add.l   D5,-(A4)
	dc.w    $A47A            ;§z
	dc.w    $A996            ;©ñ
	add.w   (A2)+,D1
	dc.w    $3FFE            ;?˛
	asl.w   ([A4],A6.w*4,$D02A99B)
	dc.w    $3FFE            ;?˛
	lsr.b   D4,D1
	dc.w    $FB69            ;˚i
	movea.w D4,A0
	eor.l   D1,(A1)+
	dc.w    $3FFE            ;?˛
	asr.w   #7,D4
	and.w   D6,(A1)+
	dc.w    $FFAB            ;ˇ´
	dc.w    $62F3            ;bÛ
	dc.w    $3FFE            ;?˛
	dc.w    $F446            ;ÙF
	move.w  (A3)+,([A2],-$6AAEC002)
	dc.w    $FA2F            ;˙/
	subi.w  #$7832,(A6)+
	dc.w    $AA72            ;™r
	dc.w    $3FFF            ;?ˇ
	or.b    D0,D0
	ori.b   #0,D0
	dc.w    $0000            ;
	negx.b  D0
	cmp.l   $3B29(A2),D4
	addq.b  #6,(SP)
	dc.w    $F0BC            ;º
	dc.w    $3FFE            ;?˛
	dc.w    $F638            ;ˆ8
	dc.w    $4EE1            ;N·
	add.b   -(A5),D0
	cas.w   D6,D7,$BB(A5,A1.w*2)
	dc.w    $6281            ;bÅ
	move.b  D1,$3739(A1)
	dc.w    $3FFD            ;?˝
	add.b   D1,(A0)
	add.l   (SP),D1
	dc.w    $C24C            ;¬L
	dc.w    $27DF            ;'ﬂ
T_1E68:        bsr     _normA0
	bge     _ret012
	movem.l D3/D4/A5/A6,-(SP)
	moveq   #0,D3
	cmpi.w  #$3FF9,D0
	bcs.s   T_1EA6
	beq.s   T_1E8C
T_1E7E:        subq.w  #1,D0
	add.l   D2,D2
	roxl.l  #1,D1
	roxl.w  #1,D3
	cmpi.w  #$3FF9,D0
	bne.s   T_1E7E
T_1E8C:        tst.l   D1
	bpl.s   T_1E9C
	neg.l   D2
	negx.l  D1
	bvs.s   T_1EA2
	addq.w  #1,D3
	ori.w   #-$8000,D0
T_1E9C:        bne.s   T_1EA2
	tst.l   D2
	beq.s   T_1EA6
T_1EA2:        bsr     _norm012
T_1EA6:        add.w   D3,D3
	move.w  D3,D4
	add.w   D4,D4
	add.w   D4,D4
	add.w   D4,D3
	move.l  D2,-(SP)
	move.l  D1,-(SP)
	move.w  D0,-(SP)
	lea     (A1),A6
	lea     (SP),A1
	lea     -$A(SP),SP
	move.w  #$4000,(SP)
	addi.w  #$100,D4
	lsl.w   #7,D4
	bcc.s   T_1ED2
	move.w  #$4001,(SP)
	move.w  #-$8000,D4
T_1ED2:        swap    D4
	clr.w   D4
	move.l  D4,2(SP)
	clr.l   6(SP)
	lea     (SP),A0
	bsr     __xxadd
	exg     A0,A1
	bsr     __xxdiv
	bsr     __square
	lea     T_1E68(PC),A5
	lea     10(A6),A0
	move.l  -(A5),-(A0)
	move.l  -(A5),-(A0)
	move.w  -(A5),-(A0)
	moveq   #2,D4
T_1EFE:        bsr     __xxmul
	lea     -$A(A5),A5
	exg     A1,A5
	bsr     __xxadd
	exg     A1,A5
	dbra    D4,T_1EFE
	lea     10(SP),A1
	bsr     __xxmul
	lea     T_1CF6(PC),A1
	adda.w  D3,A1
	bsr     __xxadd
	lea     $14(SP),SP
	movem.l (SP)+,D3/D4/A5/A6
	rts
log2:          lea     8(SP),A0
	movea.l 4(SP),A1
_log2:         move.w  #$4816,D2
	btst    #7,_fpumode
	bne     _fpu1op
__log2:        bsr     _normA0
	bmi.s   T_1F5E
	bgt.s   T_1F62
	bcs.s   T_1F62
	bne     _ret012
	pea     T_1CF2(PC)
	bsr     _txmover
	rts
T_1F5E:        tst.w   D0
	bpl.s   T_1F6C
T_1F62:        pea     T_1CF2(PC)
	bsr     _txinval
	rts
T_1F6C:        lea     _fpumode,A0
	move.w  (A0),-(SP)
	clr.w   (A0)
	tst.l   D1
	bmi.s   T_1F82
T_1F7A:        subq.w  #1,D0
	add.l   D2,D2
	addx.l  D1,D1
	bpl.s   T_1F7A
T_1F82:        bclr    #31,D1
	move.l  D2,-(SP)
	move.l  D1,-(SP)
	move.w  #$3FFF,-(SP)
	lea     (SP),A0
	moveq   #0,D1
	subi.w  #$3FFF,D0
	bmi.s   T_1FA0
	beq.s   T_1FA6
	move.w  #$400E,D1
	bra.s   T_1FA6
T_1FA0:        neg.w   D0
	move.w  #-$3FF2,D1
T_1FA6:        clr.l   -(SP)
	clr.w   -(SP)
	move.w  D0,-(SP)
	move.w  D1,-(SP)
	pea     (A1)
	bsr     T_1E68
	movea.l (SP)+,A0
	lea     (SP),A1
	bsr     __xxadd
	lea     $14(SP),SP
	move.w  (SP)+,_fpumode
	rts
log:           lea     8(SP),A0
	movea.l 4(SP),A1
_log:          move.w  #$4814,D2
	btst    #7,_fpumode
	bne     _fpu1op
__log:         pea     (A1)
	bsr     __log2
	movea.l (SP)+,A0
	lea     _fpumode,A1
	move.w  (A1),-(SP)
	clr.w   (A1)
	lea     _xcln2(PC),A1
	bsr     __xxmul
	move.w  (SP)+,_fpumode
	rts
log10:         lea     8(SP),A0
	movea.l 4(SP),A1
_log10:        move.w  #$4815,D2
	btst    #7,_fpumode
	bne     _fpu1op
__log10:       pea     (A1)
	bsr     __log2
	movea.l (SP)+,A0
	lea     _fpumode,A1
	move.w  (A1),-(SP)
	clr.w   (A1)
	lea     _xclg2(PC),A1
	bsr     __xxmul
	move.w  (SP)+,_fpumode
	rts
log1:          lea     8(SP),A0
	movea.l 4(SP),A1
_log1:         move.w  #$4806,D2
	btst    #7,_fpumode
	bne     _fpu1op
__log1:        pea     (A1)
	bsr.s   _log21
	movea.l (SP)+,A0
	lea     _fpumode,A1
	move.w  (A1),-(SP)
	clr.w   (A1)
	lea     _xcln2(PC),A1
	bsr     __xxmul
	move.w  (SP)+,_fpumode
	rts
log21:         lea     8(SP),A0
	movea.l 4(SP),A1
__log21:
_log21:        bsr     _normA0
	tst.w   D0
	bmi.s   T_20B0
	cmpi.w  #$3FFF,D0
	blt     T_1E68
T_208C:        lea     _fpumode,A0
	move.w  (A0),-(SP)
	clr.w   (A0)
	move.l  D2,-(SP)
	move.l  D1,-(SP)
	move.w  D0,-(SP)
	lea     (SP),A0
	pea     (A1)
	bsr     __xxinc
	movea.l (SP)+,A1
	bsr     _log2
	lea     10(SP),SP
	bra.s   T_20F2
T_20B0:        cmpi.w  #-$4002,D0
	bge.s   T_208C
	lea     _fpumode,A0
	move.w  (A0),-(SP)
	clr.w   (A0)
	move.l  D2,-(SP)
	move.l  D1,-(SP)
	move.w  D0,-(SP)
	lea     (SP),A0
	move.l  D2,-(SP)
	move.l  D1,-(SP)
	move.w  D0,-(SP)
	bchg    #7,(SP)
	pea     (A1)
	bsr     __xxinc
	lea     (A0),A1
	lea     4(SP),A0
	bsr     __xxdiv
	movea.l (SP),A1
	bsr     T_1E68
	movea.l (SP)+,A1
	bchg    #7,(A1)
	lea     $14(SP),SP
T_20F2:        move.w  (SP)+,_fpumode
	rts
fmod:          lea     8(SP),A0
	lea     $12(SP),A1
_fmod:         addq.l  #6,A0
	move.l  (A0),-(SP)
	move.l  -(A0),-(SP)
	move.w  -(A0),-(SP)
	lea     (SP),A0
	bsr     _xxmod
	movea.l 14(SP),A1
	move.w  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	lea     10(SP),SP
	rts
fabs:          lea     8(SP),A0
	movea.l 4(SP),A1
_fabs:         move.w  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	bclr    #7,-$A(A1)
	rts
trunc:         lea     8(SP),A0
	movea.l 4(SP),A1
_trunc:        moveq   #2,D0
	bra.s   T_2184
floor:         lea     8(SP),A0
	movea.l 4(SP),A1
_floor:        moveq   #-1,D0
	bra.s   T_2184
ceil:          lea     8(SP),A0
	movea.l 4(SP),A1
_ceil:         moveq   #1,D0
	bra.s   T_2184
round:         lea     8(SP),A0
	movea.l 4(SP),A1
_round:        btst    #7,D_415D
	beq.s   T_2182
	btst    #6,D_415D
	beq.s   _trunc
	btst    #5,D_415D
	beq.s   _floor
	bra.s   _ceil
T_2182:        moveq   #0,D0
T_2184:        movem.l D3-D7,-(SP)
	move.w  D0,-(SP)
	bsr     _normA0
	bmi.s   T_2198
	bsr     _ret012
	bra     T_2270
T_2198:        move.w  D0,(A1)
	andi.w  #$7FFF,D0
	cmpi.w  #$3FFE,D0
	bhi.s   T_21FA
	clr.w   4(A1)
	clr.l   6(A1)
	cmpi.w  #2,(SP)
	beq.s   T_21F0
	tst.w   (SP)
	beq.s   T_21C4
	bpl.s   T_21BE
	tst.w   (A1)
	bpl.s   T_21F0
	bra.s   T_21DC
T_21BE:        tst.w   (A1)
	bpl.s   T_21E6
	bra.s   T_21F0
T_21C4:        cmpi.w  #$3FFD,D0
	bls.s   T_21F0
	cmpi.l  #-$80000000,D1
	bne.s   T_21D8
	tst.l   D2
	bne.s   T_21D8
	bra.s   T_21F0
T_21D8:        tst.w   (A1)
	bpl.s   T_21E6
T_21DC:        move.l  #-$40008000,(A1)
	bra     T_2270
T_21E6:        move.l  #$3FFF8000,(A1)
	bra     T_2270
T_21F0:        andi.w  #-$8000,(A1)
	clr.w   2(A1)
	bra.s   T_2270
T_21FA:        moveq   #0,D6
	moveq   #0,D7
	subi.w  #$401E,D0
	neg.w   D0
	bmi.s   T_220A
	bset    D0,D6
	bra.s   T_221A
T_220A:        add.w   #$20,D0
	bmi.s   T_2214
	bset    D0,D7
	bra.s   T_221A
T_2214:        move.l  D1,D0
	move.l  D2,D3
	bra.s   T_226A
T_221A:        move.l  D7,D3
	move.l  D6,D0
	neg.l   D3
	negx.l  D0
	and.l   D2,D3
	and.l   D1,D0
	cmpi.w  #2,(SP)
	beq.s   T_226A
	move.l  D2,D5
	move.l  D1,D4
	sub.l   D3,D5
	subx.l  D0,D4
	beq.s   T_226A
	tst.w   (SP)
	beq.s   T_2248
	bpl.s   T_2242
	tst.w   (A1)
	bmi.s   T_225E
	bra.s   T_226A
T_2242:        tst.w   (A1)
	bpl.s   T_225E
	bra.s   T_226A
T_2248:        add.l   D5,D5
	addx.l  D4,D4
	sub.l   D7,D5
	subx.l  D6,D4
	beq.s   T_2256
	bpl.s   T_225E
	bra.s   T_226A
T_2256:        and.l   D6,D1
	bne.s   T_225E
	and.l   D7,D2
	beq.s   T_226A
T_225E:        add.l   D7,D3
	addx.l  D6,D0
	bcc.s   T_226A
	bset    #31,D0
	addq.w  #1,(A1)
T_226A:        movem.l D0/D3,2(A1)
T_2270:        addq.w  #2,SP
	movem.l (SP)+,D3-D7
	rts
T_2278:        dc.w    $7371            ;sq
	moveq   #$74,D1
	dc.w    $0000            ;
T_227E:        beq     _ret012
	bgt.s   T_228A
	tst.w   D0
	bpl     _ret012
T_228A:        pea     T_2278(PC)
	bsr     _txinval
	rts
sqrt:          lea     8(SP),A0
	movea.l 4(SP),A1
_sqrt:         move.w  #$4804,D2
	btst    #7,_fpumode
	bne     _fpu1op
__sqrt:        bsr     _normA0
	bpl.s   T_227E
	tst.w   D0
	bmi.s   T_228A
	tst.l   D1
	bmi.s   T_22BE
	bsr     _norm012
T_22BE:        movem.l D3-D7,-(SP)
	moveq   #0,D3
	moveq   #0,D4
	move.l  D1,D5
	swap    D5
	lsr.w   #1,D0
	bcs.s   T_22D6
	addi.w  #$1FFF,D0
	asr.w   #1,D5
	bra.s   T_22E6
T_22D6:        addi.w  #$2000,D0
	lsr.w   #1,D5
	addi.w  #$4000,D5
	lsr.l   #1,D1
	roxr.l  #1,D2
	roxr.l  #1,D3
T_22E6:        move.l  D1,D7
	divu.w  D5,D7
	bvc.s   T_22EE
	moveq   #-1,D7
T_22EE:        add.w   D7,D5
	lsr.w   #1,D5
	ori.w   #-$8000,D5
	move.l  D1,D7
	divu.w  D5,D7
	bvc.s   T_22FE
	moveq   #-1,D7
T_22FE:        add.w   D7,D5
	lsr.w   #1,D5
	ori.w   #-$8000,D5
	move.l  D1,D7
	divu.w  D5,D7
	bvc.s   T_2310
	moveq   #-1,D5
	bra.s   T_2328
T_2310:        swap    D7
	move.l  D2,D6
	move.w  D7,D6
	swap    D6
	divu.w  D5,D6
	move.w  D6,D7
	swap    D5
	clr.w   D5
	add.l   D7,D5
	lsr.l   #1,D5
	bset    #31,D5
T_2328:        move.w  D5,D7
	mulu.w  D7,D7
	move.l  D5,D6
	swap    D6
	mulu.w  D6,D6
	sub.l   D7,D2
	subx.l  D6,D1
	move.l  D5,D7
	swap    D7
	mulu.w  D5,D7
	move.l  D7,D6
	swap    D7
	clr.w   D7
	clr.w   D6
	swap    D6
	sub.l   D7,D2
	subx.l  D6,D1
	sub.l   D7,D2
	subx.l  D6,D1
	bpl.s   T_235C
T_2350:        add.l   D5,D2
	addx.l  D4,D1
	subq.l  #1,D5
	add.l   D5,D2
	addx.l  D4,D1
	bmi.s   T_2350
T_235C:        bne.s   T_2368
	tst.l   D3
	bne.s   T_2368
	moveq   #0,D6
	bra     T_248C
T_2368:        lsr.w   #1,D1
	roxr.l  #1,D2
	roxr.l  #1,D3
	move.l  D5,D1
	swap    D1
	move.l  D2,D6
	divu.w  D1,D6
	bvc.s   T_2386
	move.l  D5,D6
	clr.w   D6
	sub.l   D6,D2
	swap    D6
	add.l   D6,D2
	moveq   #-1,D6
	bra.s   T_238C
T_2386:        move.l  D6,D2
	clr.w   D2
	swap    D2
T_238C:        move.w  D2,D3
	swap    D3
	clr.w   D2
	swap    D2
	move.w  D5,D7
	mulu.w  D6,D7
	sub.l   D7,D3
	subx.w  D4,D2
	bpl.s   T_23A6
T_239E:        subq.w  #1,D6
	add.l   D5,D3
	addx.w  D4,D2
	bmi.s   T_239E
T_23A6:        move.l  D3,D7
	divu.w  D1,D7
	bvc.s   T_23C0
	move.l  D5,D7
	clr.w   D7
	sub.l   D7,D3
	swap    D7
	add.l   D7,D3
	moveq   #-1,D7
	swap    D3
	move.w  D3,D2
	clr.w   D3
	bra.s   T_23C4
T_23C0:        move.l  D7,D3
	clr.w   D3
T_23C4:        move.w  D5,D1
	mulu.w  D7,D1
	sub.l   D1,D3
	subx.w  D4,D2
	bpl.s   T_23D6
T_23CE:        subq.w  #1,D7
	add.l   D5,D3
	addx.w  D4,D2
	bmi.s   T_23CE
T_23D6:        add.l   D3,D3
	addx.w  D2,D2
	move.w  D6,D1
	mulu.w  D1,D1
	sub.l   D1,D3
	subx.w  D4,D2
	bpl.s   T_2402
T_23E4:        tst.w   D7
	bne.s   T_23F6
	moveq   #0,D1
	move.w  D6,D1
	add.l   D1,D1
	subq.l  #1,D1
	add.l   D1,D3
	addx.w  D4,D2
	subq.w  #1,D6
T_23F6:        subq.w  #1,D7
	add.l   D5,D3
	addx.w  D4,D2
	add.l   D5,D3
	addx.w  D4,D2
	bmi.s   T_23E4
T_2402:        swap    D6
	move.w  D7,D6
	btst    #7,D_415D
	beq.s   T_2438
	cmpi.l  #$1FFFE,D3
	bls.s   T_244A
T_2418:        btst    #6,D_415D
	beq.s   T_248C
	btst    #5,D_415D
	beq.s   T_248C
	bra.s   T_2480
T_242E:        tst.w   D2
	bpl.s   T_2418
	subq.l  #1,D6
	subx.l  D4,D5
	bra.s   T_2418
T_2438:        sub.l   D5,D3
	subx.w  D4,D2
	bmi.s   T_248C
	cmpi.l  #$1FFFE,D3
	bhi.s   T_2480
	add.l   D5,D3
	addx.w  D4,D2
T_244A:        move.l  D6,D1
	swap    D1
	mulu.w  D6,D1
	move.l  D1,D7
	swap    D1
	clr.w   D1
	clr.w   D7
	swap    D7
	add.l   D1,D1
	addx.l  D7,D7
	neg.l   D1
	subx.l  D7,D3
	subx.w  D4,D2
	move.l  D6,D7
	mulu.w  D7,D7
	sub.l   D7,D1
	subx.l  D4,D3
	subx.w  D4,D2
	btst    #7,D_415D
	bne.s   T_242E
	sub.l   D6,D1
	subx.l  D5,D3
	subx.w  D4,D2
	ble.s   T_248C
T_2480:        addq.l  #1,D6
	addx.l  D4,D5
	bne.s   T_248C
	bset    #31,D5
	addq.w  #1,D0
T_248C:        andi.w  #$7FFF,D0
	move.w  D0,(A1)+
	move.l  D5,(A1)+
	move.l  D6,(A1)
	subq.w  #6,A1
	movem.l (SP)+,D3-D7
	rts
T_249E:        dc.w    $7371            ;sq
	dc.w    $7561            ;ua
	moveq   #$65,D1
	dc.w    $0000            ;
square:        lea     8(SP),A0
	movea.l 4(SP),A1
_square:       btst    #7,_fpumode
	beq.s   __square
	move.w  #$4823,D2
	move.w  (A0),(A1)
	move.l  2(A0),2(A1)
	move.l  6(A0),6(A1)
	exg     A0,A1
	bsr     _fpuxxop
	exg     A0,A1
	rts
__square:      movem.l D3-D6,-(SP)
	movem.l -$2(A0),D0-D2
	andi.w  #$7FFF,D0
	cmpi.w  #$7FFF,D0
	beq     T_2594
	tst.l   D1
	bmi.s   T_24FA
	bne.s   T_24F6
	tst.l   D2
	beq     T_2594
T_24F6:        bsr     _norm012
T_24FA:        add.w   D0,D0
	subi.w  #$3FFE,D0
	moveq   #0,D6
	move.w  D2,D5
	mulu.w  D1,D5
	move.w  D1,D4
	mulu.w  D1,D4
	add.l   D5,D5
	addx.l  D6,D4
	swap    D1
	swap    D2
	move.w  D2,D3
	mulu.w  D2,D3
	add.l   D3,D5
	addx.l  D6,D4
	move.w  D4,D5
	clr.w   D4
	swap    D4
	swap    D5
	move.l  D2,D3
	swap    D3
	mulu.w  D1,D3
	add.l   D3,D5
	addx.l  D6,D4
	add.l   D3,D5
	addx.l  D6,D4
	move.l  D1,D3
	swap    D3
	mulu.w  D2,D3
	add.l   D3,D5
	addx.l  D6,D4
	add.l   D3,D5
	addx.l  D6,D4
	move.l  D1,D3
	swap    D3
	mulu.w  D1,D3
	add.l   D3,D4
	add.l   D3,D4
	addx.l  D6,D6
	move.w  D5,D3
	move.w  D4,D5
	move.w  D6,D4
	swap    D4
	swap    D5
	moveq   #0,D6
	mulu.w  D1,D2
	add.l   D2,D5
	addx.l  D6,D4
	add.l   D5,D2
	addx.l  D6,D4
	mulu.w  D1,D1
	add.l   D4,D1
	bmi.s   T_256E
	add.w   D3,D3
	addx.l  D2,D2
	addx.l  D1,D1
	subq.w  #1,D0
T_256E:        add.w   D3,D3
	addx.l  D6,D2
	addx.l  D6,D1
	bne.s   T_257C
	bset    #31,D1
	addq.w  #1,D0
T_257C:        cmpi.w  #$7FFF,D0
	bcs.s   T_2594
	move.w  (A0),(A1)
	exg     A0,A1
	addq.w  #6,A0
	pea     T_249E(PC)
	bsr     _xxflow
	exg     A0,A1
	bra.s   T_259C
T_2594:        move.w  D0,(A1)+
	move.l  D1,(A1)+
	move.l  D2,(A1)
	subq.w  #6,A1
T_259C:        movem.l (SP)+,D3-D6
	rts
_xdadd:        move.w  #$5422,D2
	btst    #7,_fpumode
	bne     _fpuxdop
__xdadd:       pea     __xxadd(PC)
	bra.s   T_2614
_xdsub:        move.w  #$5428,D2
	btst    #7,_fpumode
	bne     _fpuxdop
__xdsub:       pea     __xxsub(PC)
	bra.s   T_2614
_xdmul:        move.w  #$5423,D2
	btst    #7,_fpumode
	bne     _fpuxdop
__xdmul:       pea     __xxmul(PC)
	bra.s   T_2614
_xddiv:        move.w  #$5420,D2
	btst    #7,_fpumode
	bne     _fpuxdop
__xddiv:       pea     __xxdiv(PC)
	bra.s   T_2614
_xdrem:        move.w  #$5425,D2
	btst    #7,_fpumode
	bne     _fpuxdop
__xdrem:       pea     __xxrem(PC)
	bra.s   T_2614
_xdcmp:        pea     _xxcmp(PC)
T_2614:        pea     (A0)
	lea     -$A(SP),SP
	lea     (A1),A0
	lea     (SP),A1
	bsr     dxcnv
	movea.l 10(SP),A0
	pea     T_2630(PC)
	move.l  $12(SP),-(SP)
	rts
T_2630:        lea     $12(SP),SP
	rts
_xsadd:        move.w  #$4422,D2
	btst    #7,_fpumode
	bne     _fpuxsop
__xsadd:       pea     __xxadd(PC)
	lea     _sxcnv(PC),A1
	bra     T_2750
_xssub:        move.w  #$4428,D2
	btst    #7,_fpumode
	bne     _fpuxsop
__xssub:       pea     __xxsub(PC)
	lea     _sxcnv(PC),A1
	bra     T_2750
_xsmul:        move.w  #$4423,D2
	btst    #7,_fpumode
	bne     _fpuxsop
__xsmul:       pea     __xxmul(PC)
	lea     _sxcnv(PC),A1
	bra     T_2750
_xsdiv:        move.w  #$4420,D2
	btst    #7,_fpumode
	bne     _fpuxsop
__xsdiv:       pea     __xxdiv(PC)
	lea     _sxcnv(PC),A1
	bra     T_2750
_xsrem:        move.w  #$4425,D2
	btst    #7,_fpumode
	bne     _fpuxsop
__xsrem:       pea     __xxrem(PC)
	lea     _sxcnv(PC),A1
	bra     T_2750
_xscmp:        pea     _xxcmp(PC)
	lea     _sxcnv(PC),A1
	bra     T_2750
_xwadd:        ext.l   D0
_xladd:        move.w  #$4022,D2
	btst    #7,_fpumode
	bne     _fpuxsop
__xladd:       pea     __xxadd(PC)
	bra.s   T_274C
_xwsub:        ext.l   D0
_xlsub:        move.w  #$4028,D2
	btst    #7,_fpumode
	bne     _fpuxsop
__xlsub:       pea     __xxsub(PC)
	bra.s   T_274C
_xwmul:        ext.l   D0
_xlmul:        move.w  #$4023,D2
	btst    #7,_fpumode
	bne     _fpuxsop
__xlmul:       pea     __xxmul(PC)
	bra.s   T_274C
_xwdiv:        ext.l   D0
_xldiv:        move.w  #$4020,D2
	btst    #7,_fpumode
	bne     _fpuxsop
__xldiv:       pea     __xxdiv(PC)
	bra.s   T_274C
_xwrem:        ext.l   D0
_xlrem:        move.w  #$4025,D2
	btst    #7,_fpumode
	bne     _fpuxsop
__xlrem:       pea     __xxrem(PC)
	bra.s   T_274C
_xwcmp:        ext.l   D0
_xlcmp:        pea     _xxcmp(PC)
T_274C:        lea     _lxcnv(PC),A1
T_2750:        pea     (A0)
	lea     -$A(SP),SP
	lea     (SP),A0
	jsr     (A1)
	lea     (SP),A1
	movea.l 10(SP),A0
	pea     T_276A(PC)
	move.l  $12(SP),-(SP)
	rts
T_276A:        lea     $12(SP),SP
	rts
__xxcmp:
_xxcmp:        movem.l D3-D6,-(SP)
	pea     T_2798(PC)
	bra     _xxentry
T_277C:        move    #2,ccr
	bra.s   T_27CA
	bra.s   T_277C
	bra.s   T_277C
	bra.s   T_277C
	bra.s   T_2798
	bra.s   T_2798
	bra.s   T_2798
	bra.s   T_2798
	bra.s   T_27C4
	nop
	nop
	nop
T_2798:        tst.w   D0
	bpl.s   T_27A4
T_279C:        lsr.l   #1,D1
	roxr.l  #1,D2
	addq.w  #1,D0
	bne.s   T_279C
T_27A4:        tst.l   D0
	bpl.s   T_27AE
	not.l   D1
	not.l   D2
	not.w   D0
T_27AE:        tst.w   D3
	bpl.s   T_27BA
T_27B2:        lsr.l   #1,D4
	roxr.l  #1,D5
	addq.w  #1,D3
	bne.s   T_27B2
T_27BA:        tst.l   D3
	bpl.s   T_27C4
	not.l   D4
	not.l   D5
	not.w   D3
T_27C4:        sub.l   D5,D2
	subx.l  D4,D1
	subx.w  D3,D0
T_27CA:        movem.l (SP)+,D3-D6
	rts
T_27D0:        bsr.s   T_2836
	dc.w    $6400            ;d
_xxdec:        lea     _xc1(PC),A1
_xxsub:        btst    #7,_fpumode
	beq.s   __xxsub
	move.w  #$4828,D2
	bra     _fpuxxop
__xxdec:       lea     _xc1(PC),A1
__xxsub:       movem.l D3-D6,-(SP)
	pea     T_2860(PC)
	bra     _xyentry
_xxinc:        lea     _xc1(PC),A1
_xxadd:        btst    #7,_fpumode
	beq.s   __xxadd
	move.w  #$4822,D2
	bra     _fpuxxop
__xxinc:       lea     _xc1(PC),A1
__xxadd:       movem.l D3-D6,-(SP)
	pea     T_2860(PC)
	bra     _xxentry
T_2820:        eor.l   D3,D0
	bmi     T_29EE
T_2826:        move.l  D3,D0
	move.l  D4,D1
	move.l  D5,D2
T_282C:        tst.w   D0
	bpl     T_2A0E
	lsr.l   #1,D1
	roxr.l  #1,D2
T_2836:        addq.w  #1,D0
	bra.s   T_282C
T_283A:        eor.l   D0,D3
	bpl.s   T_282C
T_283E:        pea     T_27D0(PC)
	bsr     _xxinval
	bra     T_2A18
	bra.s   T_283E
	bra.s   T_283E
	bra.s   T_283E
	bra.s   T_283A
	bra.s   T_282C
	bra.s   T_282C
	bra.s   T_2826
	bra.s   T_2820
	bra.s   T_2826
	bra.s   T_2826
	bra.s   T_282C
T_2860:        move.l  D0,D6
	eor.l   D3,D6
	move.w  D0,D6
	sub.w   D3,D6
	bgt.s   T_287E
	neg.w   D6
	bne.s   T_2878
	cmp.l   D4,D1
	bhi.s   T_287E
	bne.s   T_2878
	cmp.l   D2,D5
	bls.s   T_287E
T_2878:        move.l  D3,D0
	exg     D4,D1
	exg     D5,D2
T_287E:        moveq   #0,D3
	cmpi.w  #9,D6
	bls.s   T_28D0
	cmpi.w  #$41,D6
	bls.s   T_2894
	moveq   #0,D5
	moveq   #0,D4
	moveq   #1,D3
	bra.s   T_28DE
T_2894:	cmpi.w	#$21,D6
	bls.s   T_28A4
	or.l    D5,D3
	move.l  D4,D5
	moveq   #0,D4
	subi.w  #$20,D6
T_28A4:	cmpi.w	#$11,D6
	bls.s   T_28B8
	or.w    D5,D3
	move.w  D4,D5
	clr.w   D4
	swap    D4
	swap    D5
	subi.w  #$10,D6
T_28B8:	cmpi.w  #9,D6
	bls.s   T_28C8
	or.b    D5,D3
	move.b  D4,D5
	ror.l   #8,D5
	lsr.l   #8,D4
	subq.w  #8,D6
T_28C8:	tst.l	D3
	beq.s	T_28D0
	move.w	#$FFF,D3
T_28D0:	subq.w	#1,D6
	bmi.s	T_28DE
T_28D4:	lsr.l	#1,D4
	roxr.l	#1,D5
	roxr.w	#1,D3
	dbra	D6,T_28D4
T_28DE:	tst.l	D6
	bmi.s   T_294E
	add.l   D5,D2
	addx.l  D4,D1
	bcc.s   T_28F0
	roxr.l  #1,D1
	roxr.l  #1,D2
	roxr.w  #1,D3
	addq.w  #1,D0
T_28F0:	btst    #7,D_415D
	bne.s   T_2922
	cmpi.w  #-$8000,D3
	bhi.s   T_290C
	bne     T_29D4
	btst    #0,D2
	beq     T_29D4
T_290C:	addq.l  #1,D2
	bcc     T_29D4
	addq.l  #1,D1
	bcc     T_29D4
	bset    #31,D1
	addq.w  #1,D0
	bra     T_29D4
T_2922:	tst.w   D3
	beq     T_29D4
	btst    #6,D_415D
	beq     T_29D4
	btst    #5,D_415D
	bne.s   T_2946
	tst.l   D0
	bmi.s   T_290C
	bra     T_29D4
T_2946:	tst.l   D0
	bmi     T_29D4
	bra.s   T_290C
T_294E:	sub.l   D5,D2
	subx.l  D4,D1
	bmi.s   T_2968
	beq     T_29EE
	subq.w  #1,D0
	add.l   D2,D2
	addx.l  D1,D1
	add.w   D3,D3
	bcc.s   T_2968
	subq.l  #1,D2
	bcc.s   T_2968
	subq.l  #1,D1
T_2968:        btst    #7,D_415D
	bne.s   T_29A6
	cmpi.w  #-$8000,D3
	bhi.s   T_298C
	bne.s   T_29C8
	btst    #0,D2
	bne.s   T_298C
	tst.l   D2
	bne.s   T_29C8
	cmp.l   #-$80000000,D1
	bne.s   T_29C8
T_298C:        subq.l  #1,D2
	bcc.s   T_29C8
	subq.l  #1,D1
	bmi.s   T_29D4
	beq.s   T_29EE
	moveq   #-1,D2
	moveq   #-1,D1
	subq.w  #1,D0
	btst    #14,D3
	beq.s   T_29D4
	moveq   #-2,D2
	bra.s   T_29D4
T_29A6:        tst.w   D3
	beq.s   T_29C8
	btst    #6,D_415D
	beq.s   T_298C
	btst    #5,D_415D
	bne.s   T_29C4
	tst.l   D0
	bmi.s   T_29C8
	bra.s   T_298C
T_29C4:        tst.l   D0
	bmi.s   T_298C
T_29C8:        tst.l   D1
	bmi.s   T_29D4
T_29CC:        subq.w  #1,D0
	add.l   D2,D2
	addx.l  D1,D1
	bpl.s   T_29CC
T_29D4:        cmpi.w  #$7FFF,D0
	bcs.s   T_2A0E
	pea     T_27D0(PC)
	pea     T_2A18(PC)
	cmpi.w  #-$4000,D0
	bhi     _xxunder
	bra     _xxoverf
T_29EE:        clr.l   (A0)
	clr.l   -(A0)
	clr.w   -(A0)
	btst    #7,D_415D
	beq.s   T_2A18
	btst    #5,D_415D
	bne.s   T_2A18
	bchg    #7,(A0)
	bra.s   T_2A18
T_2A0E:        add.l   D0,D0
	roxr.w  #1,D0
	move.l  D2,(A0)
	move.l  D1,-(A0)
	move.w  D0,-(A0)
T_2A18:        movem.l (SP)+,D3-D6
	rts
T_2A1E:        dc.w    $6D75            ;mu
	dc.w    $6C00            ;l
_xxmul:        move.w  #$4823,D2
	btst    #7,_fpumode
	bne     _fpuxxop
__xxmul:       movem.l D3-D7,-(SP)
	pea     T_2A92(PC)
	bra     _xxentry
T_2A3E:        eor.l   D3,D0
	andi.l  #-$80000000,D0
	clr.l   (A0)
	clr.w   -(A0)
	move.l  D0,-(A0)
	bra     T_2C2E
T_2A50:        pea     T_2A1E(PC)
	bsr     _xxinval
	bra     T_2C2E
T_2A5C:        eor.l   D3,D0
	swap    D0
	or.w    D6,D0
	clr.l   (A0)
	clr.l   -(A0)
	move.w  D0,-(A0)
	bra     T_2C2E
	move.l  D7,D0
	clr.w   D0
	pea     T_2A1E(PC)
	bsr     _xxflow
	bra     T_2C2E
	bra.s   T_2A50
	bra.s   T_2A50
	bra.s   T_2A50
	bra.s   T_2A5C
	bra.s   T_2A50
	bra.s   T_2A5C
	bra.s   T_2A50
	bra.s   T_2A3E
	bra.s   T_2A3E
	bra.s   T_2A5C
	bra.s   T_2A3E
T_2A92:        move.l  D0,D7
	eor.l   D3,D7
	move.w  D0,D7
	add.w   D3,D7
	subi.w  #$3FFE,D7
	move.l  D7,-(SP)
	moveq   #0,D0
	move.w  D2,D6
	mulu.w  D4,D6
	move.w  D1,D3
	mulu.w  D4,D3
	move.w  D1,D7
	mulu.w  D5,D7
	add.l   D7,D6
	addx.l  D0,D3
	swap    D1
	swap    D2
	swap    D4
	swap    D5
	move.w  D2,D7
	mulu.w  D5,D7
	add.l   D7,D6
	addx.l  D0,D3
	move.w  D6,-(SP)
	move.w  D3,D6
	clr.w   D3
	swap    D3
	swap    D6
	move.l  D2,D7
	swap    D7
	mulu.w  D4,D7
	add.l   D7,D6
	addx.l  D0,D3
	move.l  D4,D7
	swap    D7
	mulu.w  D2,D7
	add.l   D7,D6
	addx.l  D0,D3
	move.l  D1,D7
	swap    D7
	mulu.w  D5,D7
	add.l   D7,D6
	addx.l  D0,D3
	move.l  D5,D7
	swap    D7
	mulu.w  D1,D7
	add.l   D7,D6
	addx.l  D0,D3
	move.l  D1,D7
	swap    D7
	mulu.w  D4,D7
	add.l   D7,D3
	move.l  D4,D7
	swap    D7
	mulu.w  D1,D7
	add.l   D7,D3
	addx.l  D0,D0
	move.w  D6,-(SP)
	move.w  D3,D6
	move.w  D0,D3
	swap    D3
	swap    D6
	moveq   #0,D0
	move.w  D2,D7
	mulu.w  D4,D7
	add.l   D7,D6
	addx.l  D0,D3
	move.w  D1,D7
	mulu.w  D5,D7
	add.l   D7,D6
	addx.l  D0,D3
	move.w  D1,D7
	mulu.w  D4,D7
	add.l   D7,D3
	move.l  (SP)+,D4
	move.l  (SP)+,D1
	move.l  D4,D7
	tst.l   D3
	bmi.s   T_2B34
	add.l   D7,D7
T_2B34:        btst    #7,D_415D
	beq     T_2BC2
	tst.l   D7
	beq.s   T_2B4E
	bpl.s   T_2B5A
	cmpi.l  #-$1FFFF,D7
	bls.s   T_2B5A
T_2B4E:        bsr.s   T_2B80
	tst.l   D4
	bne.s   T_2B5A
	tst.l   D7
	beq     T_2C02
T_2B5A:        btst    #6,D_415D
	beq     T_2C02
	btst    #5,D_415D
	bne.s   T_2B78
	tst.l   D1
	bmi.s   T_2BE8
	bra     T_2C02
T_2B78:        tst.l   D1
	bmi     T_2C02
	bra.s   T_2BE8
T_2B80:        move.l  D1,-(SP)
	move.l  D2,D1
	swap    D1
	mulu.w  D5,D1
	move.l  D5,D7
	swap    D7
	mulu.w  D2,D7
	moveq   #0,D0
	add.l   D1,D7
	addx.w  D0,D0
	swap    D0
	swap    D7
	move.w  D7,D0
	clr.w   D7
	swap    D2
	swap    D5
	move.w  D2,D1
	mulu.w  D5,D1
	moveq   #0,D2
	add.l   D1,D7
	addx.l  D0,D4
	addx.l  D2,D6
	addx.l  D2,D3
	moveq   #0,D0
	move.l  (SP)+,D1
	tst.l   D3
	bmi.s   T_2BC0
	add.l   D7,D7
	addx.l  D4,D4
	addx.l  D6,D6
	addx.l  D3,D3
	subq.w  #1,D1
T_2BC0:        rts
T_2BC2:        cmpi.l  #-$80000000,D7
	bhi.s   T_2BE8
	cmpi.l  #$7FFE0001,D7
	bls.s   T_2C02
	bsr.s   T_2B80
	cmpi.l  #-$80000000,D4
	bhi.s   T_2BE8
	bne.s   T_2C02
	tst.l   D7
	bne.s   T_2BE8
	btst    #0,D6
	beq.s   T_2C02
T_2BE8:        tst.l   D3
	bmi.s   T_2BF4
	add.l   D4,D4
	addx.l  D6,D6
	addx.l  D3,D3
	subq.w  #1,D1
T_2BF4:        addq.l  #1,D6
	addx.l  D0,D3
	bne.s   T_2C0E
	bset    #31,D3
	addq.w  #1,D1
	bra.s   T_2C0E
T_2C02:        tst.l   D3
	bmi.s   T_2C0E
	add.l   D4,D4
	addx.l  D6,D6
	addx.l  D3,D3
	subq.w  #1,D1
T_2C0E:        cmpi.w  #$7FFF,D1
	bcs.s   T_2C24
	move.l  D1,D0
	move.l  D3,D1
	move.l  D6,D2
	pea     T_2A1E(PC)
	bsr     _xxflow
	bra.s   T_2C2E
T_2C24:        add.l   D1,D1
	roxr.w  #1,D1
	move.l  D6,(A0)
	move.l  D3,-(A0)
	move.w  D1,-(A0)
T_2C2E:        movem.l (SP)+,D3-D7
	rts
T_2C34:        dc.w    $6469            ;di
	moveq   #0,D3
__xxinv:       lea     (A0),A1
	lea     _xc2(PC),A0
	move.l  -(A0),-(SP)
	move.l  -(A0),-(SP)
	move.w  -(A0),-(SP)
	lea     (SP),A0
	bsr.s   __xxdiv
	lea     (A1),A0
	move.w  (SP)+,(A0)+
	move.l  (SP)+,(A0)+
	move.l  (SP)+,(A0)
	subq.w  #6,A0
	rts
_xxdiv:        move.w  #$4820,D2
	btst    #7,_fpumode
	bne     _fpuxxop
__xxdiv:       movem.l D3-D7/A2/A3,-(SP)
	pea     T_2CC0(PC)
	bra     _xxentry
T_2C70:        pea     T_2C34(PC)
	bsr     _xxinval
	bra     T_2E5A
T_2C7C:        eor.l   D3,D0
	andi.l  #-$80000000,D0
	clr.l   (A0)
	clr.w   -(A0)
	move.l  D0,-(A0)
	bra     T_2E5A
T_2C8E:        pea     T_2C34(PC)
	bsr     _xxdivze
	bra     T_2E5A
T_2C9A:        eor.l   D3,D0
	swap    D0
	or.w    D6,D0
	clr.l   (A0)
	clr.l   -(A0)
	move.w  D0,-(A0)
	bra     T_2E5A
	bra.s   T_2C70
	bra.s   T_2C70
	bra.s   T_2C70
	bra.s   T_2C70
	bra.s   T_2C9A
	bra.s   T_2C9A
	bra.s   T_2C7C
	bra.s   T_2C70
	bra.s   T_2C7C
	bra.s   T_2C7C
	bra.s   T_2C8E
T_2CC0:        suba.l  A3,A3
	move.l  D0,D7
	eor.l   D3,D7
	move.w  D0,D7
	sub.w   D3,D7
	addi.w  #$3FFE,D7
	cmp.l   D1,D4
	bhi.s   T_2CE4
	bne.s   T_2CD8
	cmp.l   D2,D5
	bhi.s   T_2CE4
T_2CD8:        addq.w  #1,D7
	lsr.l   #1,D1
	roxr.l  #1,D2
	bcc.s   T_2CE4
	movea.w #-$8000,A3
T_2CE4:        move.l  D7,-(SP)
	moveq   #2,D6
T_2CE8:        movea.l D6,A2
	move.l  D4,D6
	swap    D6
	move.l  D1,D7
	divu.w  D6,D7
	bvc.s   T_2D02
	move.l  D4,D7
	clr.w   D7
	sub.l   D7,D1
	swap    D7
	add.l   D7,D1
	moveq   #-1,D7
	bra.s   T_2D08
T_2D02:        move.l  D7,D1
	clr.w   D1
	swap    D1
T_2D08:        move.l  D5,D6
	swap    D6
	mulu.w  D7,D6
	moveq   #0,D0
	sub.l   D6,D2
	subx.l  D0,D1
	swap    D1
	swap    D2
	move.w  D1,D0
	move.w  D2,D1
	move.w  A3,D2
	suba.l  A3,A3
	move.w  D4,D3
	mulu.w  D7,D3
	move.w  D5,D6
	mulu.w  D7,D6
	move.w  D7,-(SP)
	moveq   #0,D7
	sub.l   D6,D2
	subx.l  D3,D1
	subx.w  D7,D0
	bpl.s   T_2D3E
T_2D34:        subq.w  #1,(SP)
	add.l   D5,D2
	addx.l  D4,D1
	addx.w  D7,D0
	bcc.s   T_2D34
T_2D3E:        move.l  A2,D6
	dbra    D6,T_2CE8
	move.l  D4,D6
	swap    D6
	move.l  D1,D7
	divu.w  D6,D7
	bvc.s   T_2D5E
	move.l  D4,D7
	clr.w   D7
	sub.l   D7,D1
	swap    D7
	add.l   D7,D1
	moveq   #-1,D7
	swap    D1
	bra.s   T_2D62
T_2D5E:        move.l  D7,D1
	clr.w   D1
T_2D62:        swap    D2
	move.w  D1,D0
	move.w  D2,D1
	clr.w   D2
	move.w  D4,D3
	mulu.w  D7,D3
	moveq   #0,D6
	sub.l   D3,D1
	subx.w  D6,D0
	bpl.s   T_2D7E
T_2D76:        subq.w  #1,D7
	add.l   D4,D1
	addx.w  D6,D0
	bcc.s   T_2D76
T_2D7E:        swap    D7
	move.w  (SP)+,D7
	swap    D7
	btst    #7,D_415D
	bne.s   T_2DA6
	move.l  D4,D6
	lsr.l   #1,D6
	sub.l   D1,D6
	bhi     T_2E36
	swap    D6
	addq.w  #1,D6
	bmi     T_2E2A
T_2DA0:        pea     T_2E02(PC)
	bra.s   T_2DD2
T_2DA6:        cmpi.l  #$FFFF,D1
	bls.s   T_2DA0
T_2DAE:        btst    #6,D_415D
	beq.s   T_2E36
	btst    #5,D_415D
	bne.s   T_2DCA
	tst.l   4(SP)
	bmi.s   T_2E2A
	bra.s   T_2E36
T_2DCA:        tst.l   4(SP)
	bmi.s   T_2E36
	bra.s   T_2E2A
T_2DD2:        move.l  D2,-(SP)
	move.l  D1,-(SP)
	move.l  D5,D3
	swap    D3
	mulu.w  D7,D3
	move.w  D3,D0
	clr.w   D3
	swap    D3
	swap    D0
	clr.w   D0
	move.w  D5,D2
	mulu.w  D7,D2
	moveq   #0,D1
	add.l   D2,D0
	addx.l  D1,D3
	move.l  (SP)+,D1
	move.l  (SP)+,D2
	sub.l   D0,D2
	subx.l  D3,D1
	bcc.s   T_2E00
	subq.w  #1,D7
	add.l   D5,D2
	addx.l  D4,D1
T_2E00:        rts
T_2E02:        btst    #7,D_415D
	bne.s   T_2E20
	lsr.l   #1,D4
	roxr.l  #1,D5
	sub.l   D2,D5
	subx.l  D1,D4
	bmi.s   T_2E2A
	bne.s   T_2E36
	btst    #0,D7
	beq.s   T_2E36
	bra.s   T_2E2A
T_2E20:        tst.l   D1
	bne.s   T_2DAE
	tst.l   D2
	beq.s   T_2E36
	bra.s   T_2DAE
T_2E2A:        move.l  (SP)+,D6
	swap    D6
	addq.l  #1,D7
	bcc.s   T_2E3A
	addq.l  #1,D6
	bra.s   T_2E3A
T_2E36:        move.l  (SP)+,D6
	swap    D6
T_2E3A:        move.l  (SP)+,D0
	cmpi.w  #$7FFE,D0
	bls.s   T_2E50
	move.l  D6,D1
	move.l  D7,D2
	pea     T_2C34(PC)
	bsr     _xxflow
	bra.s   T_2E5A
T_2E50:        add.l   D0,D0
	roxr.w  #1,D0
	move.l  D7,(A0)
	move.l  D6,-(A0)
	move.w  D0,-(A0)
T_2E5A:        movem.l (SP)+,D3-D7/A2/A3
	rts
T_2E60:        dc.w    $6D6F            ;mo
	dc.w    $6400            ;d
_xxmod:        move.w  #$4821,D2
	btst    #7,_fpumode
	bne     _fpuxxop
__xxmod:       movem.l D3-D7,-(SP)
	moveq   #0,D7
	pea     T_2EC6(PC)
	bra     _xxentry
_xxrem:        move.w  #$4825,D2
	btst    #7,_fpumode
	bne     _fpuxxop
__xxrem:       movem.l D3-D7,-(SP)
	moveq   #-1,D7
	pea     T_2EC6(PC)
	bra     _xxentry
T_2EA0:        pea     T_2E60(PC)
	bsr     _xxinval
	bra     T_2F6E
T_2EAC:        bra     T_2F58
	bra.s   T_2EA0
	bra.s   T_2EA0
	bra.s   T_2EA0
	bra.s   T_2EA0
	bra.s   T_2EA0
	bra.s   T_2EA0
	bra.s   T_2EAC
	bra.s   T_2EA0
	bra.s   T_2EAC
	bra.s   T_2EAC
	bra.s   T_2EA0
T_2EC6:        moveq   #-1,D6
	sub.w   D0,D3
	beq.s   T_2F16
	blt.s   T_2EEC
	cmpi.w  #1,D3
	bne.s   T_2F4C
	tst.w   D7
	beq.s   T_2F4C
	sub.l   D2,D5
	subx.l  D1,D4
	bcc.s   T_2F4C
	add.l   D5,D5
	addx.l  D4,D4
	add.l   D5,D2
	addx.l  D4,D1
	bchg    #31,D0
	bra.s   T_2F4C
T_2EEC:        neg.w   D3
	sub.w   D3,D0
	subq.w  #2,D3
	bcs.s   T_2F08
T_2EF4:        add.l   D2,D2
	addx.l  D1,D1
	bcc.s   T_2F04
	sub.l   D5,D2
	subx.l  D4,D1
	bcs.s   T_2F04
	sub.l   D5,D2
	subx.l  D4,D1
T_2F04:        dbra    D3,T_2EF4
T_2F08:        add.l   D2,D2
	addx.l  D1,D1
	bcc.s   T_2F16
T_2F0E:        neg.w   D6
	sub.l   D5,D2
	subx.l  D4,D1
	bcc.s   T_2F0E
T_2F16:        neg.w   D6
	sub.l   D5,D2
	subx.l  D4,D1
	beq.s   T_2F30
	bcc.s   T_2F16
	add.l   D2,D5
	addx.l  D1,D4
	add.l   D5,D2
	addx.l  D4,D1
	bne.s   T_2F34
	tst.w   D6
	bpl.s   T_2F36
	bra.s   T_2F3C
T_2F30:        clr.w   D0
	bra.s   T_2F64
T_2F34:        bcs.s   T_2F3C
T_2F36:        move.l  D5,D2
	move.l  D4,D1
	bra.s   T_2F4C
T_2F3C:        tst.w   D7
	beq.s   T_2F36
	sub.l   D2,D5
	subx.l  D1,D4
	move.l  D5,D2
	move.l  D4,D1
	bchg    #31,D0
T_2F4C:        tst.l   D1
	bmi.s   T_2F58
T_2F50:        subq.w  #1,D0
	add.l   D2,D2
	addx.l  D1,D1
	bpl.s   T_2F50
T_2F58:        tst.w   D0
	bpl.s   T_2F64
T_2F5C:        lsr.l   #1,D1
	roxr.l  #1,D2
	addq.w  #1,D0
	bmi.s   T_2F5C
T_2F64:        add.l   D0,D0
	roxr.w  #1,D0
	move.l  D2,(A0)
	move.l  D1,-(A0)
	move.w  D0,-(A0)
T_2F6E:        movem.l (SP)+,D3-D7
	rts
T_2F74:        move.w  #3,-$E(A2)
	movea.l D1,A2
_fpuxxop:      moveq   #$7F,D0
	move.l  A2,D1
	lea     $FFFFFA50.w,A2   ;FPop
T_2F84:        cmpi.w  #$802,-$10(A2)
	dbeq    D0,T_2F84
	move.w  #$4800,-$6(A2)
T_2F94:        cmpi.w  #-$69F4,-$10(A2)
	dbeq    D0,T_2F94
	move.l  (A0),(A2)
	move.l  2(A0),(A2)
	move.l  6(A0),(A2)
T_2FA8:        cmpi.w  #$802,-$10(A2)
	dbeq    D0,T_2FA8
	move.w  D2,-$6(A2)
T_2FB6:        cmpi.w  #-$69F4,-$10(A2)
	dbeq    D0,T_2FB6
	move.l  (A1),(A2)
	move.l  2(A1),(A2)
	move.l  6(A1),(A2)
T_2FCA:        cmpi.w  #$802,-$10(A2)
	dbeq    D0,T_2FCA
	move.w  #$6800,-$6(A2)
T_2FDA:        cmpi.w  #-$4DF4,-$10(A2)
	dbeq    D0,T_2FDA
	bne.s   T_2F74
	move.l  (A2),(A0)
	move.l  (A2),2(A0)
	move.l  (A2),6(A0)
	movea.l D1,A2
	rts
T_2FF4:        move.w  #3,-$E(A2)
	movea.l D1,A2
_fpuxdop:      moveq   #$7F,D0
	move.l  A2,D1
	lea     $FFFFFA50.w,A2   ;FPop
T_3004:        cmpi.w  #$802,-$10(A2)
	dbeq    D0,T_3004
	move.w  #$4800,-$6(A2)
T_3014:        cmpi.w  #-$69F4,-$10(A2)
	dbeq    D0,T_3014
	move.l  (A0),(A2)
	move.l  2(A0),(A2)
	move.l  6(A0),(A2)
T_3028:        cmpi.w  #$802,-$10(A2)
	dbeq    D0,T_3028
	move.w  D2,-$6(A2)
T_3036:        cmpi.w  #-$69F8,-$10(A2)
	dbeq    D0,T_3036
	move.l  (A1),(A2)
	move.l  4(A1),(A2)
T_3046:        cmpi.w  #$802,-$10(A2)
	dbeq    D0,T_3046
	move.w  #$6800,-$6(A2)
T_3056:        cmpi.w  #-$4DF4,-$10(A2)
	dbeq    D0,T_3056
	bne.s   T_2FF4
	move.l  (A2),(A0)
	move.l  (A2),2(A0)
	move.l  (A2),6(A0)
	movea.l D1,A2
	rts
T_3070:        move.w  #3,-$E(A1)
_fpuxsop:      moveq   #$7F,D1
	lea     $FFFFFA50.w,A1   ;FPop
T_307C:        cmpi.w  #$802,-$10(A1)
	dbeq    D1,T_307C
	move.w  #$4800,-$6(A1)
T_308C:        cmpi.w  #-$69F4,-$10(A1)
	dbeq    D1,T_308C
	move.l  (A0),(A1)
	move.l  2(A0),(A1)
	move.l  6(A0),(A1)
T_30A0:        cmpi.w  #$802,-$10(A1)
	dbeq    D1,T_30A0
	move.w  D2,-$6(A1)
T_30AE:        cmpi.w  #-$6AFC,-$10(A1)
	dbeq    D1,T_30AE
	move.l  D0,(A1)
T_30BA:        cmpi.w  #$802,-$10(A1)
	dbeq    D1,T_30BA
	move.w  #$6800,-$6(A1)
T_30CA:        cmpi.w  #-$4DF4,-$10(A1)
	dbeq    D1,T_30CA
	bne.s   T_3070
	move.l  (A1),(A0)
	move.l  (A1),2(A0)
	move.l  (A1),6(A0)
	rts
T_30E2:        move.w  #3,-$E(A2)
	movea.l D1,A2
_fpu1op:       moveq   #$7F,D0
	move.l  A2,D1
	lea     $FFFFFA50.w,A2   ;FPop
T_30F2:        cmpi.w  #$802,-$10(A2)
	dbeq    D0,T_30F2
	move.w  D2,-$6(A2)
T_3100:        cmpi.w  #-$69F4,-$10(A2)
	dbeq    D0,T_3100
	move.l  (A0),(A2)
	move.l  2(A0),(A2)
	move.l  6(A0),(A2)
T_3114:        cmpi.w  #$802,-$10(A2)
	dbeq    D0,T_3114
	move.w  #$6800,-$6(A2)
T_3124:	cmpi.w  #-$4DF4,-$10(A2)
	dbeq    D0,T_3124
	bne.s   T_30E2
	move.l  (A2),(A1)
	move.l  (A2),2(A1)
	move.l  (A2),6(A1)
	movea.l D1,A2
	rts
_normA0:
	move.l  6(A0),D2
	move.w  (A0),D0
	moveq   #1,D1
	add.w   D0,D1
	add.w   D1,D1
	beq.s   T_3184
	move.l  2(A0),D1
	bpl.s   T_3154
	rts
T_3154:	bne.s   T_3164
	tst.l   D2
	bne.s   T_3164
	andi.w  #-$8000,D0
	move    #4,ccr
	rts
T_3164:	ext.l	D0
	andi.w	 #$7FFF,D0
	bsr	_norm012
	tst.w	D0
	bpl.s	T_317A
T_3172:	lsr.l   #1,D1
	roxr.l  #1,D2
	addq.w  #1,D0
	bne.s   T_3172
T_317A:	add.l   D0,D0
	roxr.w  #1,D0
	move    #8,ccr
	rts
T_3184:        move.l  2(A0),D1
	bne.s   T_319E
	tst.l   D2
	bne.s   T_319E
	tst.w   D0
	bmi.s   T_3198
	move    #2,ccr
	rts
T_3198:        move    #3,ccr
	rts
T_319E:        bset    #30,D1
	move    #0,ccr
	rts
_ret012:       move.w  D0,(A1)+
	move.l  D1,(A1)+
	move.l  D2,(A1)
	subq.w  #6,A1
	rts
T_31B2:        moveq   #0,D1
	move.w  #-$1,(A1)+
	bra.s   T_31C4
T_31BA:        moveq   #0,D1
	bra.s   T_31C0
_retNaN:       moveq   #-1,D1
T_31C0:        move.w  #$7FFF,(A1)+
T_31C4:        move.l  D1,(A1)+
	move.l  D1,(A1)
	subq.w  #6,A1
	rts
_txmover:      bsr.s   T_31B2
	moveq   #3,D0
	bra.s   T_31DC
_txoverf:      bsr.s   T_31BA
	moveq   #3,D0
	bra.s   T_31DC
_txinval:      bsr.s   _retNaN
	moveq   #1,D0
T_31DC:        pea     (A1)
	move.l  8(SP),-(SP)
	bsr     _xmather
	addq.l  #8,SP
	move.l  (SP)+,(SP)
	rts
_xyentry:      move.w  (A1),D3
	bchg    #15,D3
	bra.s   T_31F6
_xxentry:      move.w  (A1),D3
T_31F6:        move.l  6(A1),D5
	move.w  #$7FFF,D6
	ext.l   D3
	and.w   D6,D3
	cmp.w   D6,D3
	beq.s   T_323C
	move.l  2(A1),D4
	bmi.s   T_321E
	bne.s   T_3216
	tst.l   D5
	bne.s   T_3216
	subq.l  #2,(SP)
	bra.s   T_321E
T_3216:        subq.w  #1,D3
	add.l   D5,D5
	addx.l  D4,D4
	bpl.s   T_3216
T_321E:        move.w  (A0)+,D0
	move.l  (A0)+,D1
	move.l  (A0),D2
	ext.l   D0
	and.w   D6,D0
	cmp.w   D6,D0
	beq.s   T_324A
	tst.l   D1
	bpl.s   T_3232
	rts
T_3232:        bne.s   T_3268
	tst.l   D2
	bne.s   T_3268
	subq.l  #6,(SP)
	rts
T_323C:        move.l  2(A1),D4
	bne.s   T_325A
	tst.l   D5
	bne.s   T_325A
	subq.l  #4,(SP)
	bra.s   T_321E
T_324A:        tst.l   D1
	bne.s   T_325C
	tst.l   D2
	bne.s   T_325C
	subi.l  #12,(SP)
	rts
T_325A:        addq.w  #6,A0
T_325C:        subi.l  #$12,(SP)
	rts
_norm012:      tst.l   D1
	bmi.s   T_3270
T_3268:        subq.w  #1,D0
	add.l   D2,D2
	addx.l  D1,D1
	bpl.s   T_3268
T_3270:        rts
_xxinval:      move.w  #$7FFF,D0
	moveq   #-1,D1
	moveq   #-1,D2
	moveq   #1,D3
	bra     T_3374
_xxdivze:      eor.l   D3,D0
	swap    D0
	or.w    D6,D0
	moveq   #0,D1
	moveq   #0,D2
	moveq   #2,D3
	bra     T_3374
_xxflow:       move.w  #$7FFF,D6
	move.w  -$6(A0),D3
	and.w   D6,D3
	beq.s   _xxunder
	cmpi.w  #$7000,D3
	bgt.s   _xxoverf
	cmpi.w  #-$5000,D0
	bhi.s   _xxunder
_xxoverf:      swap    D0
	ori.w   #$7FFF,D0
	btst    #7,D_415D
	beq.s   T_32D8
	btst    #6,D_415D
	beq.s   T_32CE
	move.w  _fpumode,D3
	ror.w   #6,D3
	eor.w   D0,D3
	bmi.s   T_32D8
T_32CE:        subq.w  #1,D0
	moveq   #-1,D1
	moveq   #-1,D2
	bra     T_3368
T_32D8:        moveq   #0,D1
	moveq   #0,D2
	moveq   #3,D3
	bra     T_3374
_xxunder:      cmpi.w  #-$80,D0
	bgt.s   T_3318
	swap    D0
	andi.w  #-$8000,D0
	moveq   #0,D1
	moveq   #0,D2
	moveq   #4,D3
	btst    #7,D_415D
	beq.s   T_3374
	btst    #6,D_415D
	beq.s   T_3374
	move.w  _fpumode,D4
	ror.w   #6,D4
	eor.w   D0,D4
	bpl.s   T_3374
	moveq   #1,D2
	bra.s   T_3368
T_3318:        moveq   #0,D3
	moveq   #0,D4
T_331C:        lsr.l   #1,D1
	roxr.l  #1,D2
	roxr.l  #1,D3
	roxr.l  #1,D4
	addq.w  #1,D0
	bne.s   T_331C
	add.l   D0,D0
	roxr.w  #1,D0
	btst    #7,D_415D
	bne.s   T_333E
	bclr    #31,D3
	beq.s   T_3368
	bra.s   T_335E
T_333E:        btst    #6,D_415D
	beq.s   T_3368
	or.l    D4,D3
	btst    #5,D_415D
	beq.s   T_335A
	tst.w   D0
	bmi.s   T_3368
	bra.s   T_335E
T_335A:        tst.w   D0
	bpl.s   T_3368
T_335E:        tst.l   D3
	beq.s   T_3368
	addq.l  #1,D2
	bcc.s   T_3368
	addq.l  #1,D1
T_3368:        move.l  D2,(A0)
	move.l  D1,-(A0)
	move.w  D0,-(A0)
	move.l  (SP)+,(SP)
	rts
_xxinexa:      moveq   #5,D3
T_3374:        subq.w  #6,A0
	move.l  D2,-(SP)
	move.l  D1,-(SP)
	move.w  D0,-(SP)
	pea     (SP)
	move.l  $12(SP),-(SP)
	move.w  D3,D0
	bsr     _xmather
	addq.w  #8,SP
	move.w  (SP)+,(A0)+
	move.l  (SP)+,(A0)+
	move.l  (SP)+,(A0)
	subq.w  #6,A0
	move.l  (SP)+,(SP)
	rts
_xmather:      move.l  A1,-(SP)
	move.l  A0,-(SP)
	movea.l $10(SP),A0
	addq.w  #6,A0
	move.l  (A0),-(SP)
	move.l  -(A0),-(SP)
	move.w  -(A0),-(SP)
	movea.l 10(SP),A0
	addq.w  #6,A0
	addq.w  #6,A1
	move.l  (A1),-(SP)
	move.l  -(A1),-(SP)
	move.w  -(A1),-(SP)
	move.l  (A0),-(SP)
	move.l  -(A0),-(SP)
	move.w  -(A0),-(SP)
	move.l  $2A(SP),-(SP)
	move.w  D0,-(SP)
	lea     D_415D,A0
	move.w  D0,D1
	neg.w   D1
	addq.w  #5,D1
	bset    D1,(A0)
	btst    D1,-(A0)
	beq.s   T_33F8
	lea     _fpuvect,A1
	lsl.w   #2,D0
	move.l  $FC(A1,D0.w),D0
	beq.s   T_33F8
	movea.l D0,A1
	move.w  (A0),-(SP)
	clr.w   (A0)
	lea     2(SP),A0
	jsr     (A1)
	lea     _fpumode,A0
	move.w  (SP)+,(A0)
	tst.w   D0
	bne.s   T_3414
T_33F8:        move.w  (SP),D0
	cmpi.w  #2,D0
	bls.s   T_340A
	move.w  #$22,errno
	bra.s   T_3422
T_340A:        move.w  #$21,errno
	bra.s   T_3422
T_3414:        movea.l $34(SP),A0
	lea     $1A(SP),A1
	move.w  (A1)+,(A0)+
	move.l  (A1)+,(A0)+
	move.l  (A1)+,(A0)+
T_3422:        lea     $24(SP),SP
	movea.l (SP)+,A0
	movea.l (SP)+,A1
	rts
_dxcnv:
dxcnv:         move.l  (A0),D1
	move.l  4(A0),D2
	move.l  D1,D0
	swap    D0
	ext.l   D0
	rol.l   #8,D2
	rol.l   #8,D1
	move.b  D2,D1
	clr.b   D2
	add.l   D2,D2
	roxl.l  #1,D1
	add.l   D2,D2
	roxl.l  #1,D1
	add.l   D2,D2
	roxl.l  #1,D1
	bclr    #31,D1
	andi.w  #$7FF0,D0
	cmpi.w  #$7FF0,D0
	bne.s   T_346E
	tst.l   D2
	bne.s   T_3466
	tst.l   D1
	bne.s   T_3466
	moveq   #0,D1
	bra.s   T_3468
T_3466:        moveq   #-1,D1
T_3468:        move.l  D1,D2
	st      D0
	bra.s   T_348C
T_346E:        lsr.w   #4,D0
	bne.s   T_3484
	tst.l   D1
	bne.s   T_347A
	tst.l   D2
	beq.s   T_348C
T_347A:        subq.w  #1,D0
	add.l   D2,D2
	addx.l  D1,D1
	bpl.s   T_347A
	addq.w  #1,D0
T_3484:        addi.w  #$3C00,D0
	bset    #31,D1
T_348C:        add.l   D0,D0
	roxr.w  #1,D0
	move.w  D0,(A1)+
	move.l  D1,(A1)+
	move.l  D2,(A1)
	subq.w  #6,A1
	rts
_sxcnv:        move.l  D0,D1
	swap    D0
	move.w  D0,D2
	lsl.l   #8,D1
	bclr    #31,D1
	andi.w  #$7F80,D0
	cmpi.w  #$7F80,D0
	bne.s   T_34B6
	move.w  #$7FFF,D0
	bra.s   T_34CE
T_34B6:        lsr.w   #7,D0
	bne.s   T_34C6
	tst.l   D1
	beq.s   T_34CE
T_34BE:        subq.w  #1,D0
	add.l   D1,D1
	bpl.s   T_34BE
	addq.w  #1,D0
T_34C6:        addi.w  #$3F80,D0
	bset    #31,D1
T_34CE:        add.w   D0,D0
	add.w   D2,D2
	roxr.w  #1,D0
	move.w  D0,(A0)+
	move.l  D1,(A0)+
	clr.l   (A0)
	subq.w  #6,A0
	rts
_xlcnv:
_xwcnv:        bsr     _normA0
	bne.s   T_34E8
	moveq   #0,D0
	rts
T_34E8:        andi.w  #$7FFF,D0
	sub.w   #$401E,D0
	bmi.s   T_34FA
	move.l  #$7FFFFFFF,D0
	bra.s   T_350A
T_34FA:        neg.w   D0
	cmpi.w  #$1F,D0
	bls.s   T_3506
	moveq   #0,D0
	rts
T_3506:        lsr.l   D0,D1
	move.l  D1,D0
T_350A:        tst.w   (A0)
	bpl.s   T_3510
	neg.l   D0
T_3510:        rts
_uxcnv:        moveq   #0,D2
	tst.l   D0
	bne.s   T_3538
	clr.w   D1
	bra.s   T_3576
_wxcnv:        ext.l   D0
_lxcnv:        move.l  D0,D2
	bne.s   T_3526
	clr.w   D1
	bra.s   T_3576
T_3526:        bpl.s   T_3538
	neg.l   D0
	bvc.s   T_3538
	move.w  #-$3FE2,D1
	move.l  #-$80000000,D0
	bra.s   T_3576
T_3538:        move.w  #$401E,D1
	swap    D0
	tst.w   D0
	bne.s   T_3548
	subi.w  #$10,D1
	swap    D0
T_3548:        cmpi.w  #$FF,D0
	bhi.s   T_3552
	subq.w  #8,D1
	rol.l   #8,D0
T_3552:        cmpi.w  #$FFF,D0
	bhi.s   T_355C
	subq.w  #4,D1
	rol.l   #4,D0
T_355C:        cmpi.w  #$3FFF,D0
	bhi.s   T_3566
	subq.w  #2,D1
	rol.l   #2,D0
T_3566:        tst.w   D0
	bmi.s   T_356E
	subq.w  #1,D1
	rol.l   #1,D0
T_356E:        swap    D0
	add.w   D1,D1
	add.l   D2,D2
	roxr.w  #1,D1
T_3576:        move.w  D1,(A0)+
	move.l  D0,(A0)+
	clr.l   (A0)
	subq.w  #6,A0
	rts
T_3580:        lea     T_35AA(PC),A0
	moveq   #8,D0
	movea.l D0,A1
	move.l  (A1),D0
	move.l  A0,(A1)
	clr.w   _fpumode
	lea     (SP),A0
	move.w  #3,$FFFFFA42.w   ;FPctl
	move.w  #-$8000,_fpumode
	move.w  #-$1,_fpuctrl
T_35AA:        lea     (A0),SP
	move.l  D0,(A1)
	rts
_fpuinit:      move.l  A2,-(SP)
	pea     T_3580(PC)
	move.w  #$26,-(SP)
	trap    #14              ;Supexec
	addq.w  #6,SP
	movea.l (SP)+,A2
	rts
_xce:          negx.b  D0
	dc.w    $ADF8            ;≠¯
	addq.w  #2,(A0)+
	dc.w    $A2BB            ;¢ª
	tst.l   (A3)+
_xclg2:        dc.w    $3FFD            ;?˝
	sub.b   -(A0),D5
	sub.l   D4,D5
	dc.w    $FBCF            ;˚œ
	dc.w    $F799            ;˜ô
_xcln2:        dc.w    $3FFE            ;?˛
	dc.w    $B172            ;±r
	dc.w    $17F7            ; ˜
	adda.l  SP,A0
	dc.w    $79AC            ;y¨
_xcpi:         negx.b  D0
	abcd    -(SP),-(A4)
	add.l   -(A2),D5
	dc.w    $2168            ;!h
	dc.w    $C235            ;¬5
_xcph:         dc.w    $3FFF            ;?ˇ
	abcd    -(SP),-(A4)
	add.l   -(A2),D5
	move.l  -$3DCB(A0),$3FFE(A0)
	abcd    -(SP),-(A4)
	add.l   -(A2),D5
	dc.w    $2168            ;!h
	dc.w    $C235            ;¬5
_xc1:          dc.w    $3FFF            ;?ˇ
	or.b    D0,D0
	ori.b   #0,D0
	dc.w    $0000            ;
_xc2:          negx.b  D0
	or.b    D0,D0
	ori.b   #0,D0
	dc.w    $0000            ;
_xc10:         negx.b  D2
	dc.w    $A000            ;init
	ori.b   #0,D0
	dc.w    $0000            ;
_NAN:          move    A1,usp
	dc.w    $4E00            ;N
_INFM:         move.l  A1,$4E46(A6)
	dc.w    $002B            ; +
	dc.w    $494E            ;IN
	not.b   D0
	movea.l D3,A4
	move.l  (A0)+,$6D61(A4)
	moveq   #$68,D2
	movea.l -(A2),A0
	dc.w    $7920            ;y
	dc.w    $6427            ;d'
	dc.w    $4152            ;AR
	addq.b  #2,D0
printf:        move.l  A6,-(SP)
	subq.w  #4,SP
	lea     (SP),A6
	move.l  SP,(A6)
	lea     12(SP),A1
	pea     T_3658(PC)
	bsr     _PrintF
	addq.w  #4,SP
T_3652:        addq.w  #4,SP
	movea.l (SP)+,A6
	rts
T_3658:        swap    D0
	clr.w   D0
	swap    D0
	lea     _StdOutF,A1
	moveq   #1,D1
	bsr     fwrite
	tst.w   D0
	bmi.s   T_3670
	rts
T_3670:        movea.l (A6),SP
	moveq   #-1,D0
	bra.s   T_3652
_OutIntD:      movem.l D3/D4/A2,-(SP)
	lea     -$18(SP),SP
	moveq   #10,D3
	tst.l   D0
	bpl.s   T_3696
	move.b  #$2D,6(SP)
	move.w  #1,8(SP)
	neg.l   D0
	bra     T_373E
T_3696:        btst    #2,D1
	beq.s   T_36AC
	move.b  #$2B,6(SP)
	move.w  #1,8(SP)
	bra     T_373E
T_36AC:        btst    #0,D1
	beq.s   T_36C0
	move.b  #$20,6(SP)
	move.w  #1,8(SP)
	bra.s   T_373E
T_36C0:        move.w  #0,8(SP)
	bra.s   T_373E
_OutCarD:      movem.l D3/D4/A2,-(SP)
	lea     -$18(SP),SP
	moveq   #10,D3
	move.w  #0,8(SP)
	bra.s   T_373E
_OutCarH:      movem.l D3/D4/A2,-(SP)
	lea     -$18(SP),SP
	moveq   #$10,D3
	btst    #1,D1
	bne.s   T_36F2
	move.w  #0,8(SP)
	bra.s   T_373E
T_36F2:        move.b  #$30,6(SP)
	btst    #5,D1
	bne.s   T_370C
	move.b  #$78,7(SP)
	move.w  #2,8(SP)
	bra.s   T_373E
T_370C:        move.b  #$58,7(SP)
	move.w  #2,8(SP)
	bra.s   T_373E
_OutCarO:      movem.l D3/D4/A2,-(SP)
	lea     -$18(SP),SP
	moveq   #8,D3
	btst    #1,D1
	bne.s   T_3732
	move.w  #0,8(SP)
	bra.s   T_373E
T_3732:        move.b  #$30,6(SP)
	move.w  #1,8(SP)
T_373E:        movea.l A0,A2
	move.w  D1,(SP)
	exg     D1,D3
	move.w  D2,D4
	bpl.s   T_374A
	moveq   #0,D4
T_374A:        lea     10(SP),A0
	bsr     ultoa
	lea     10(SP),A0
	moveq   #-1,D0
T_3758:        tst.b   (A0)+
	dbeq    D0,T_3758
	not.w   D0
	move.w  D0,$16(SP)
	btst    #5,D3
	beq.s   T_3788
	lea     10(SP),A0
	move.w  D0,D1
	subq.w  #1,D1
	bmi.s   T_3788
	moveq   #$61,D2
T_3776:        cmp.b   (A0)+,D2
	dbls    D1,T_3776
	bhi.s   T_3788
	andi.b  #-$21,-$1(A0)
	dbra    D1,T_3776
T_3788:        move.w  8(SP),D1
	add.w   D0,D1
	move.w  $28(SP),D2
	bpl.s   T_3796
	moveq   #1,D2
T_3796:        sub.w   D0,D2
	bpl.s   T_379C
	moveq   #0,D2
T_379C:        add.w   D2,D1
	btst    #4,D3
	beq.s   T_37B4
	btst    #3,D3
	bne.s   T_37B4
	move.w  D4,D0
	sub.w   D1,D0
	ble.s   T_37B8
	add.w   D0,D1
	add.w   D0,D2
T_37B4:        sub.w   D1,D4
	bge.s   T_37BA
T_37B8:        moveq   #0,D4
T_37BA:        move.w  D2,4(SP)
	move.w  D4,2(SP)
	bra.s   T_382C
_OutChr:       movem.l D3/D4/A2/A3,-(SP)
	movea.l A0,A2
	movea.l A1,A3
	clr.b   1(A0)
	moveq   #1,D3
	bra.s   T_37E6
_OutStr:       movem.l D3/D4/A2/A3,-(SP)
	movea.l A0,A2
	movea.l A1,A3
	moveq   #-1,D3
T_37DE:        tst.b   (A0)+
	dbeq    D3,T_37DE
	not.w   D3
T_37E6:        tst.w   D2
	bpl.s   T_37EC
	move.w  D3,D2
T_37EC:        cmp.w   D3,D2
	bhi.s   T_37F2
	move.w  D2,D3
T_37F2:        moveq   #0,D4
	tst.w   D1
	bmi.s   T_3800
	cmp.w   D3,D1
	bls.s   T_3800
	move.w  D1,D4
	sub.w   D3,D4
T_3800:        btst    #3,D0
	bne.s   T_3816
	movea.l A3,A0
	move.w  D4,D0
	bsr     OutBlank
	move.w  D3,D0
	movea.l A2,A0
	jsr     (A3)
	bra.s   T_3822
T_3816:        move.w  D3,D0
	movea.l A2,A0
	jsr     (A3)
	move.w  D4,D0
	movea.l A3,A0
	bsr.s   OutBlank
T_3822:        move.w  D3,D0
	add.w   D4,D0
	movem.l (SP)+,D3/D4/A2/A3
	rts
T_382C:        move.w  (SP),D3
	moveq   #0,D4
	move.w  2(SP),D0
	beq.s   T_3842
	btst    #3,D3
	bne.s   T_3842
	add.w   D0,D4
	movea.l A2,A0
	bsr.s   OutBlank
T_3842:        move.w  8(SP),D0
	beq.s   T_3850
	add.w   D0,D4
	lea     6(SP),A0
	jsr     (A2)
T_3850:        move.w  4(SP),D0
	beq.s   T_385C
	add.w   D0,D4
	movea.l A2,A0
	bsr.s   OutZero
T_385C:        move.w  $16(SP),D0
	beq.s   T_386A
	add.w   D0,D4
	lea     10(SP),A0
	jsr     (A2)
T_386A:        move.w  2(SP),D0
	beq.s   T_387C
	btst    #3,D3
	beq.s   T_387C
	add.w   D0,D4
	movea.l A2,A0
	bsr.s   OutBlank
T_387C:        move.w  D4,D0
	lea     $18(SP),SP
	movem.l (SP)+,D3/D4/A2
	rts
OutZero:       movem.l D3/D4/A2/A3,-(SP)
	lea     T_38C4(PC),A2
	bra.s   T_389A
OutBlank:      movem.l D3/D4/A2/A3,-(SP)
	lea     T_38CC(PC),A2
T_389A:        movea.l A0,A3
	move.w  D0,D3
	beq.s   T_38BE
	move.w  D0,D4
	lsr.w   #3,D3
	beq.s   T_38B2
	subq.w  #1,D3
T_38A8:        movea.l A2,A0
	moveq   #8,D0
	jsr     (A3)
	dbra    D3,T_38A8
T_38B2:        movea.l A2,A0
	move.w  D4,D0
	and.w   #7,D0
	beq.s   T_38BE
	jsr     (A3)
T_38BE:        movem.l (SP)+,D3/D4/A2/A3
	rts
T_38C4:        move.w  $30(A0,D3.w),D0
	move.w  $30(A0,D3.w),D0
T_38CC:        move.l  -(A0),D0
	move.l  -(A0),D0
	move.l  -(A0),D0
	move.l  -(A0),D0
fwrite:        movem.l D3/D4/A2-A4/A6,-(SP)
	movea.l A0,A2
	movea.l A1,A3
	movea.l (A3),A4
	move.l  D0,D3
	beq.s   T_3948
	tst.l   D1
	beq.s   T_3944
	btst    #1,$12(A3)
	beq.s   T_394E
	btst    #2,$12(A1)
	bne.s   T_396A
	bset    #6,$12(A3)
	movea.l 12(A3),A6
	moveq   #0,D4
T_3902:        move.l  D3,D2
T_3904:        move.b  (A2)+,(A4)+
	cmpa.l  A6,A4
	bcc.s   T_3916
	subq.l  #1,D2
	bne.s   T_3904
	addq.l  #1,D4
	cmp.l   D1,D4
	bcs.s   T_3902
	bra.s   T_3944
T_3916:        move.l  A4,(A3)
	move.l  D1,-(SP)
	move.l  D2,-(SP)
	movea.l A3,A0
	bsr     _FlshBuf
	move.l  (SP)+,D2
	move.l  (SP)+,D1
	tst.w   D0
	bmi.s   T_3956
	bne.s   T_3960
	movea.l (A3),A4
	bset    #6,$12(A3)
	subq.l  #1,D2
	bne.s   T_3904
	addq.l  #1,D4
	cmp.l   D1,D4
	bne.s   T_3902
	bclr    #6,$12(A3)
T_3944:        move.l  A4,(A3)
	move.l  D1,D0
T_3948:        movem.l (SP)+,D3/D4/A2-A4/A6
	rts
T_394E:        move.w  #13,errno
T_3956:        bset    #5,$12(A3)
	moveq   #-1,D0
	bra.s   T_3948
T_3960:        bset    #5,$12(A3)
	move.l  D4,D1
	bra.s   T_3944
T_396A:        move.l  D0,D3
	moveq   #0,D4
	movea.l D1,A6
T_3970:        move.l  A2,8(A3)
	move.l  A2,4(A3)
	lea     0(A2,D3.l),A2
	move.l  A2,12(A3)
	move.l  A2,(A3)
	bset    #6,$12(A3)
	movea.l A3,A0
	bsr     _FlshBuf
	tst.w   D0
	bmi.s   T_3956
	bne.s   T_3960
	addq.l  #1,D4
	cmp.l   A6,D4
	bne.s   T_3970
	move.l  A6,D1
	bra.s   T_3944
_FlshBuf:      movem.l D3/A3/A4,-(SP)
	movea.l A0,A3
	movea.l 8(A3),A4
	move.w  $10(A3),D3
	move.l  4(A3),D1
	sub.l   A4,D1
	beq.s   T_39C4
	move.w  D3,D0
	neg.l   D1
	moveq   #1,D2
	bsr     lseek
	tst.l   D0
	bmi     T_3A4C
T_39C4:        btst    #7,$12(A3)
	bne.s   T_3A26
	move.l  (A3),D1
	sub.l   A4,D1
	subq.l  #1,D1
	movea.l A4,A1
	movea.l A1,A0
	moveq   #10,D0
T_39D8:        cmp.b   (A1)+,D0
	beq.s   T_39E2
	subq.l  #1,D1
	bpl.s   T_39D8
	bra.s   T_3A0C
T_39E2:        move.b  #13,-$1(A1)
	move.l  D1,-(SP)
	move.l  A1,-(SP)
	move.l  A1,D1
	sub.l   A0,D1
	move.w  D3,D0
	bsr     write
	movea.l (SP)+,A1
	move.l  (SP)+,D1
	tst.l   D0
	bmi.s   T_3A4C
	beq.s   T_3A50
	lea     -$1(A1),A0
	moveq   #10,D0
	move.b  D0,(A0)
	subq.l  #1,D1
	bpl.s   T_39D8
T_3A0C:        movem.l D1/A0/A1,-(SP)
	move.l  A1,D1
	sub.l   A0,D1
	move.w  D3,D0
	bsr     write
	movem.l (SP)+,D1/A0/A1
	tst.l   D0
	bmi.s   T_3A4C
	beq.s   T_3A50
	bra.s   T_3A38
T_3A26:        move.w  D3,D0
	move.l  (A3),D1
	sub.l   A4,D1
	movea.l A4,A0
	bsr     write
	tst.l   D0
	bmi.s   T_3A4C
	beq.s   T_3A50
T_3A38:        move.l  A4,(A3)
	move.l  A4,4(A3)
	bclr    #6,$12(A3)
	clr.w   D0
T_3A46:        movem.l (SP)+,D3/A3/A4
	rts
T_3A4C:        moveq   #-1,D0
	bra.s   T_3A46
T_3A50:        moveq   #1,D0
	bra.s   T_3A46
write:         movem.l D1/A0/A2,-(SP)
	move.w  D0,-(SP)
	move.w  #$40,-(SP)
	trap    #1	;Fwrite
	lea     12(SP),SP
	movea.l (SP)+,A2
	tst.l   D0
	bmi.s   T_3A70
	cmp.l   D1,D0
	bne.s   T_3A7E
	rts
T_3A70:        bsr     _XltErr
	move.w  D0,errno
	moveq   #-1,D0
	rts
T_3A7E:        move.w  #$1C,errno
	rts
lseek:         movem.l D3/D4/A2,-(SP)
	cmp.w   #2,D2
	bhi     T_3B22
	beq.s   T_3AB0
T_3A96:        move.w  D2,-(SP)
	move.w  D0,-(SP)
	move.l  D1,-(SP)
	move.w  #$42,-(SP)
	trap    #1	;Fseek
	lea     10(SP),SP
	tst.l   D0
	bmi.s   T_3B14
T_3AAA:        movem.l (SP)+,D3/D4/A2
	rts
T_3AB0:        tst.l   D1
	ble.s   T_3A96
	move.w  D0,D3
	move.l  D1,D4
	move.w  #2,-(SP)
	move.w  D3,-(SP)
	moveq   #0,D0
	move.l  D0,-(SP)
	move.w  #$42,-(SP)
	trap    #1	;Fseek
	lea     10(SP),SP
	tst.l   D0
	bmi.s   T_3B14
T_3AD0:        pea     lseek(PC)
	move.l  #$400,D0
	cmp.l   D0,D4
	bcs.s   T_3AE2
	move.l  D0,-(SP)
	bra.s   T_3AE4
T_3AE2:        move.l  D4,-(SP)
T_3AE4:        move.w  D3,-(SP)
	move.w  #$40,-(SP)
	trap    #1	;Fwrite
	lea     12(SP),SP
	tst.l   D0
	bmi.s   T_3B14
	sub.l   #$400,D4
	bhi.s   T_3AD0
	move.w  #1,-(SP)
	move.w  D3,-(SP)
	moveq   #0,D0
	move.l  D0,-(SP)
	move.w  #$42,-(SP)
	trap    #1	;Fseek
	lea     10(SP),SP
	tst.l   D0
	bpl.s   T_3AAA
T_3B14:        bsr     _XltErr
T_3B18:        move.w  D0,errno
	moveq   #-1,D0
	bra.s   T_3AAA
T_3B22:        move.w  #$16,D0
	bra.s   T_3B18
_XltErr:       neg.w   D0
	sub.w   #$20,D0
	cmp.w   #$22,D0
	bhi.s   T_3B3A
	move.b  T_3B3E(PC,D0.w),D0
	rts
T_3B3A:        moveq   #5,D0
	rts
T_3B3E:        move.b  D2,D3
	move.b  (A0)+,D2
	movep.w $50C(A1),D6
	btst    D5,D5
	btst    D2,D5
	btst    D2,D5
	move.b  D5,-(A1)
	btst    D2,D2
	btst    D2,D5
	btst    D2,D5
	btst    D2,D5
	btst    D2,D5
	btst    D2,D5
	btst    D2,D5
	btst    D2,D5
	move.b  D5,-(A6)
	move.w	A4,D1
itoa:          move.l  D3,-(SP)
	move.l  A0,-(SP)
	lea     -$12(SP),SP
	move.w  D1,D2
	subq.w  #2,D2
	cmp.w   #$22,D2
	bhi.s   T_3BB6
	tst.w   D0
	bpl.s   T_3B84
	cmp.b   #10,D1
	bne.s   T_3B84
	neg.w   D0
	move.b  #$2D,(A0)+
T_3B84:        lea     $12(SP),A1
	moveq   #-1,D2
	swap    D0
	clr.w   D0
	swap    D0
T_3B90:        divu.w  D1,D0
	move.l  D0,D3
	swap    D3
	move.b  T_3BC0(PC,D3.w),-(A1)
	addq.w  #1,D2
	swap    D0
	clr.w   D0
	swap    D0
	bne.s   T_3B90
T_3BA4:        move.b  (A1)+,(A0)+
	dbra    D2,T_3BA4
T_3BAA:        clr.b   (A0)+
	lea     $12(SP),SP
	movea.l (SP)+,A0
	move.l  (SP)+,D3
	rts
T_3BB6:        move.w  #$21,errno
	bra.s   T_3BAA
T_3BC0:        move.w  $33(A1,D3.w*2),D0
	move.w  $37(A5,D3.w*8),D2
	move.w  $41424344,D4
	dc.w    $4546            ;EF
	dc.w    $4748            ;GH
	dc.w    $494A            ;IJ
	dc.w    $4B4C            ;KL
	dc.w    $4D4E            ;MN
	dc.w    $4F50            ;OP
	subq.w  #8,(A2)
	subq.w  #1,(A4)
	subq.w  #2,(A6)
	subq.w  #3,(A0)+
	subq.w  #4,(A2)+
strtoul:       movem.l D3/A2/A3,-(SP)
	movea.l A0,A2
	cmp.w   #1,D0
	beq     T_3CA4
	cmp.w   #$24,D0
	bhi     T_3CA4
	lea     _ChrCla1(PC),A3
	moveq   #0,D1
	moveq   #0,D2
T_3C02:        move.b  (A2)+,D1
	beq     T_3C88
	tst.b   0(A3,D1.w)
	bmi.s   T_3C02
	subq.w  #1,A2
	move.b  (A2)+,D1
	beq.s   T_3C88
	tst.w   D0
	bne.s   T_3C3A
	moveq   #10,D0
	cmp.b   #$30,D1
	bne.s   T_3C5A
	moveq   #8,D0
	move.b  (A2)+,D1
	beq.s   T_3C88
	move.b  D1,D3
	and.b   #-$21,D3
	cmp.b   #$58,D3
	bne.s   T_3C5A
	moveq   #$10,D0
	move.b  (A2)+,D1
	bne.s   T_3C5A
	bra.s   T_3C88
T_3C3A:        cmp.w   #$10,D0
	bne.s   T_3C5A
	cmp.b   #$30,D1
	bne.s   T_3C5A
	move.b  (A2)+,D1
	beq.s   T_3C88
	move.b  D1,D3
	and.b   #-$21,D3
	cmp.b   #$58,D3
	bne.s   T_3C5A
	move.b  (A2)+,D1
	beq.s   T_3C88
T_3C5A:        lea     _DigCnvT(PC),A3
	move.b  0(A3,D1.w),D1
	cmp.b   D0,D1
	bcc.s   T_3C88
	move.b  D1,D2
T_3C68:        move.b  (A2)+,D1
	move.b  0(A3,D1.w),D1
	cmp.b   D0,D1
	bcc.s   T_3C88
	move.l  D2,D3
	swap    D3
	mulu.w  D0,D3
	swap    D3
	tst.w   D3
	bne.s   T_3C98
	mulu.w  D0,D2
	add.l   D3,D2
	add.l   D1,D2
	bcc.s   T_3C68
	bra.s   T_3C98
T_3C88:        move.l  D2,D0
	move.l  A1,D3
	beq.s   T_3C92
	subq.w  #1,A2
	move.l  A2,(A1)
T_3C92:        movem.l (SP)+,D3/A2/A3
	rts
T_3C98:        move.w  #$22,errno
	moveq   #-1,D0
	bra.s   T_3CAE
T_3CA4:        move.w  #$21,errno
	moveq   #0,D0
T_3CAE:        move.l  A1,D3
	beq.s   T_3C92
	move.l  A0,(A1)
	bra.s   T_3C92
ultoa:         move.l  D3,-(SP)
	move.l  A0,-(SP)
	suba.w  #$22,SP
	move.w  D1,D2
	subq.w  #2,D2
	cmp.w   #$22,D2
	bhi.s   T_3D22
	lea     $22(SP),A1
	moveq   #-1,D2
	move.l  D0,D3
	swap    D3
	tst.w   D3
	bne.s   T_3CEC
T_3CD6:        divu.w  D1,D0
	move.l  D0,D3
	swap    D3
	move.b  T_3D2C(PC,D3.w),-(A1)
	addq.w  #1,D2
	swap    D0
	clr.w   D0
	swap    D0
	bne.s   T_3CD6
	bra.s   T_3D10
T_3CEC:        move.w  D4,-(SP)
T_3CEE:        move.l  D0,D3
	move.w  D0,D4
	clr.w   D3
	swap    D3
	divu.w  D1,D3
	move.w  D3,D0
	move.w  D4,D3
	divu.w  D1,D3
	swap    D0
	move.w  D3,D0
	swap    D3
	move.b  T_3D2C(PC,D3.w),-(A1)
	addq.w  #1,D2
	tst.l   D0
	bne.s   T_3CEE
	move.w  (SP)+,D4
T_3D10:        move.b  (A1)+,(A0)+
	dbra    D2,T_3D10
T_3D16:        clr.b   (A0)+
	adda.w  #$22,SP
	movea.l (SP)+,A0
	move.l  (SP)+,D3
	rts
T_3D22:        move.w  #$21,errno
	bra.s   T_3D16
T_3D2C:        move.w  $33(A1,D3.w*2),D0
	move.w  $37(A5,D3.w*8),D2
	move.w  $61626364,D4
	bcs.s   T_3DA2
	beq.s   T_3DA6
	bvs.s   T_3DAA
	bmi.s   T_3DAE
	blt.s   T_3DB2
	ble.s   T_3DB6
	dc.w    $7172            ;qr
	dc.w    $7374            ;st
	dc.w    $7576            ;uv
	dc.w    $7778            ;wx
	dc.w    $797A            ;yz
_FreeAll:      move.l  A3,-(SP)
	movea.l _MemBlkL,A3
T_3D58:        move.l  A3,D0
	beq.s   T_3D6A
	move.l  A3,-(SP)
	movea.l (A3),A3
	move.w  #$49,-(SP)
	trap    #1	;Mfree
	addq.w  #6,SP
	bra.s   T_3D58
T_3D6A:        movea.l _MemCluL,A3
T_3D70:        move.l  A3,D0
	beq.s   T_3D82
	move.l  A3,-(SP)
	movea.l (A3),A3
	move.w  #$49,-(SP)
	trap    #1	;Mfree
	addq.w  #6,SP
	bra.s   T_3D70
T_3D82:        movea.l (SP)+,A3
	rts
_ChrCla1:      negx.w  D0
	negx.w  D0
	negx.w  D0
	negx.w  D0
	move    sr,D0
	mulu.w  D0,D0
	mulu.w  D0,D0
	negx.w  D0
	negx.w  D0
	negx.w  D0
	negx.w  D0
	negx.w  D0
	negx.w  D0
	negx.w  D0
T_3DA2:        negx.w  D0
	negx.w  D0
T_3DA6:        or.b    D1,D0
	btst    D0,D1
T_3DAA:        btst    D0,D1
	btst    D0,D1
T_3DAE:        btst    D0,D1
	btst    D0,D1
T_3DB2:        btst    D0,D1
	btst    D0,D1
T_3DB6:        move.b  (A2),D1
	move.b  (A2),D1
	move.b  (A2),D1
	move.b  (A2),D1
	move.b  (A2),D1
	btst    D0,D1
	btst    D0,D1
	btst    D0,D1
	dc.w    $003A            ; :
	dc.w    $3A3A            ;::
	dc.w    $3A3A            ;::
	move.w  $3838.w,D5
	move.w  $3838.w,D4
	move.w  $3838.w,D4
	move.w  $3838.w,D4
	move.w  $3838.w,D4
	move.w  D1,D4
	btst    D0,D1
	btst    D0,D1
	btst    D0,$36(A6,D3.w*8)
	move.w  $34(A6,D3.w*8),D3
	move.w  $34(A4,D3.w*4),D2
	move.w  $34(A4,D3.w*4),D2
	move.w  $34(A4,D3.w*4),D2
	move.w  $34(A4,D3.w*4),D2
	move.w  1(A4,D3.w*4),D2
	btst    D0,D1
	bchg    D0,D0
	ori.b   #0,D0
	ori.b   #0,D0
	ori.b   #0,D0
	ori.b   #0,D0
	ori.b   #0,D0
	ori.b   #0,D0
	ori.b   #0,D0
	ori.b   #0,D0
	ori.b   #0,D0
	ori.b   #0,D0
	ori.b   #0,D0
	ori.b   #0,D0
	ori.b   #0,D0
	ori.b   #0,D0
	ori.b   #0,D0
	ori.b   #0,D0
	ori.b   #0,D0
	ori.b   #0,D0
	ori.b   #0,D0
	ori.b   #0,D0
	ori.b   #0,D0
	ori.b   #0,D0
	ori.b   #0,D0
	ori.b   #0,D0
	ori.b   #0,D0
	ori.b   #0,D0
	ori.b   #0,D0
	ori.b   #0,D0
	ori.b   #0,D0
	ori.b   #0,D0
	ori.b   #0,D0
	ori.b   #0,D0
_DigCnvT:      dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $0001            ;
	dc.w    $0203            ;
	dc.w    $0405            ;
	dc.w    $0607            ;
	dc.w    $0809            ;
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FF0A            ;ˇ
	movep.w $D0E(A4),D5
	btst    D7,(A0)
	move.b  (A2),-(A0)
	move.b  (A4),-(A1)
	move.b  (A6),-(A2)
	move.b  (A0)+,-(A3)
	move.b  (A2)+,-(A4)
	move.b  (A4)+,-(A5)
	move.b  (A6)+,-(A6)
	move.b  -(A0),-(SP)
	move.l  -(A2),-(A0)
	dc.w    $23FF            ;#ˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FF0A            ;ˇ
	movep.w $D0E(A4),D5
	btst    D7,(A0)
	move.b  (A2),-(A0)
	move.b  (A4),-(A1)
	move.b  (A6),-(A2)
	move.b  (A0)+,-(A3)
	move.b  (A2)+,-(A4)
	move.b  (A4)+,-(A5)
	move.b  (A6)+,-(A6)
	move.b  -(A0),-(SP)
	move.l  -(A2),-(A0)
	dc.w    $23FF            ;#ˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
	dc.w    $FFFF            ;ˇˇ
kbhit:         move.l  A2,-(SP)
	move.w  #11,-(SP)
	trap    #1	;Cconis
	addq.w  #2,SP
	movea.l (SP)+,A2
	rts
	DATA
__data:
errno:         dc.b    $0,$0
_AtExitV:      dc.b    $0,$0,$0,$0
_FilSysV:      dc.b    $0,$0,$0,$0
Width:         dc.b    $0,$10,$0,$A
D_3FA2:        dc.b    '?ˇÄ',$0,$0,$0,$0,$0,$0,$0
D_3FAC:        dc.b    '@',$1D,'Ä',$0,$0,$0,$0,$0,$0,$0
D_3FB6:        dc.b    '?˘ı¬è\(ı¬è'
D_3FC0:        dc.b    '?˜ƒõ•„S˜ŒŸ'
D_3FCA:        dc.b    '?˛Ä',$0,$0,$0,$0,$0,$0,$0
D_3FD4:        dc.b    '@',$3,'ÿ',$0,$0,$0,$0,$0,$0,$0
D_3FDE:        dc.b    '?ˇÃÃÃÃÃÃÃÕ'
D_3FE8:        dc.b    $0,$0,$0,$0,$0,$0,$0,$0,$0,$0
D_3FF2:        dc.b    '?˛Ä',$0,$0,$0,$0,$0,$0,$0
D_3FFC:        dc.b    '?ˇÄ',$0,$0,$0,$0,$0,$0,$0
D_4006:        dc.b    $0,$0,$0,$0,$0,$0,$0,$0,$0,$0
D_4010:        dc.b    '?ˇÄ',$0,$0,$0,$0,$0,$0,$0
D_401A:        dc.b    '@',$0,'¿',$0,$0,$0,$0,$0,$0,$0
D_4024:        dc.b    '@',$0,'Ä',$0,$0,$0,$0,$0,$0,$0
D_402E:        dc.b    '?˚ÃÃÃÃÃÃÃÕ'
D_4038:        dc.b    '@',$0,'…',$F,'˘rGE8Ô?ˇÄ',$0,$0,$0,$0,$0,$0,$0
D_404C:        dc.b    '@',$2,'†',$0,$0,$0,$0,$0,$0,$0
D_4056:        dc.b    '@',$0,'…',$F,'˘rGE8Ô'
D_4060:        dc.b    '@',$3,'à',$0,$0,$0,$0,$0,$0,$0
D_406A:        dc.b    '?ˇÄ',$0,$0,$0,$0,$0,$0,$0
D_4074:        dc.b    '?˛Ä',$0,$0,$0,$0,$0,$0,$0
D_407E:        dc.b    '@',$0,'Ä',$0,$0,$0,$0,$0,$0,$0,'@',$1,'†',$0,$0,$0,$0,$0
	dc.b    $0,$0
D_4092:        dc.b    '?˚ÃÃÃÃÃÃÃÕ'
D_409C:        dc.b    '?˚ÃÃÃÃÃÃÃÕ'
D_40A6:        dc.b    '?ˇÄ',$0,$0,$0,$0,$0,$0,$0
D_40B0:        dc.b    '?ˇÄ',$0,$0,$0,$0,$0,$0,$0
D_40BA:        dc.b    '?ˇÄ',$0,$0,$0,$0,$0,$0,$0
D_40C4:        dc.b    '@',$3,'¯',$0,$0,$0,$0,$0,$0,$0,'?ˇÄ',$0,$0,$0,$0,$0,$0,$0
D_40D8:        dc.b    '@',$6,'ˇ',$0,$0,$0,$0,$0,$0,$0
D_40E2:        dc.b    '@',$6,'ˇ',$0,$0,$0,$0,$0,$0,$0,'?ˇÄ',$0,$0,$0,$0,$0,$0,$0
D_40F6:        dc.b    '@',$6,'ˇ',$0,$0,$0,$0,$0,$0,$0
D_4100:        dc.b    '@',$6,'ˇ',$0,$0,$0,$0,$0,$0,$0,'?ˇÄ',$0,$0,$0,$0,$0,$0,$0
D_4114:        dc.b    '@',$6,'ˇ',$0,$0,$0,$0,$0,$0,$0
D_411E:        dc.b    '@',$6,'ˇ',$0,$0,$0,$0,$0,$0,$0
D_4128:        dc.b    'Press a key to exit.',$A,$0
D_413E:        dc.b    '?ˇÄ',$0,$0,$0,$0,$0,$0,$0
_fpuvect:      dc.b    $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
_fpumode:      dc.b    $0
D_415D:        dc.b    $0
_fpuctrl:      dc.b    $0,$0
_StdInF:       dc.l    D_4176
	dc.l    D_4176
	dc.l    D_4176
	dc.l    _StdOutF
	dc.b    $0,$0,$1,$0,$0,$0
D_4176:        dc.b    $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	dc.b    $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	dc.b    $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	dc.b    $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
_StdOutF:      dc.b    $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$1,$6,$0
	dc.b    $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,'ˇˇ'
	dc.b    $6,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	dc.b    $0,$2,$7,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	dc.b    $0,$0,$0,$3,$6,$0,$0,$0
_MemBlkL:      dc.b    $0,$0,$0,$0
_MemCluL:      dc.b    $0,$0,$0,$0
	BSS
__bss:
_BasPag:       ds.l    1	 ;=4
_app:          ds.w    1	 ;=2
_StkLim:       ds.l    1	 ;=4
_PgmSize:      ds.l    1	 ;=4
_RedirTa:      ds.l    6	 ;=24
rgbtab:        ds.l    770              ;=3080
cnv_stri:      ds.w    11	;=22
B_4E6A:        ds.l    1021             ;=4084
B_5E5E:        ds.w    17	;=34
