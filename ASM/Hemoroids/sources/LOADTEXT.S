;effet de texte.
;g mis un texte ala fin: tu modifies en fonction...

;il y a 3 fond differents... tu changes comme tu veux
;(mais utilise les 3!)


screen1	equ	$f8000
screen2	equ	$f0000

	CLR.W	-(SP)
	MOVE.L	#-1,-(SP)
	MOVE.L	#-1,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	2(SP),SP

	PEA	DEMO
	MOVE.W	#38,-(SP)
	TRAP	#14
	LEA	6(SP),SP

	CLR.W	-(SP)
	TRAP	#1


DEMO	MOVEM.L	$FFFF8240.W,D0-D7
	MOVEM.L	D0-D7,SAVE_COLORS

	lea	fond1+2+16,a0
	rept	8
	move.w	#$777,(a0)+
	endr
	MOVEM.L	fond1+2,D0-D7
	MOVEM.L	D0-D7,$FFFF8240.W

	lea	screen1,a1
	lea	screen2,a2
	lea	fond1+34,a0
	move.w	#32000/4-1,d0
fuck1	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	dbra	d0,fuck1


	JSR	CODAGE
	
MAIN

	BSR	LIT_TEXTE
	bsr	wait_lit
	CMPI.B	#$39,$FFFFFC02.W
	BEQ	OUT
	
	BRA	MAIN

OUT	MOVE.W	#7,-(SP)
	TRAP	#1
	LEA	2(SP),SP

	MOVEM.L	SAVE_COLORS,D0-D7
	MOVEM.L	D0-D7,$FFFF8240.W
	RTS

SAVE_COLORS	DS.L	8

SYNC	MOVEM.L	D0-D1/A0-A1,-(SP)
	MOVE.W	#37,-(SP)
	TRAP	#14
	LEA	2(SP),SP
	MOVEM.L	(SP)+,D0-D1/A0-A1
	move.l	log,a0
	move.l	phys,log
	move.l	a0,phys
	move.w	#-1,-(sp)
	move.l	a0,-(sp)
	move.l	a0,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	CMPI.B	#$39,$FFFFFC02.W
	BEQ	_OUT
	RTS
_OUT	LEA	8(SP),SP
	BRA	OUT

WAIT_LIT
	MOVE.W	#50*10,D3
_TIME	BSR	SYNC
	DBRA	D3,_TIME
	RTS


LIT_TEXTE
	MOVE.L	PTEXTE,A0
ligne_texte
	move.l	pt_log,A1
	move.l	pt_phys,A2
	move.l	#$70001,d3
CALCUL_FNTS
	LEA	FONTS+32+4*100,A3
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	bmi	other
	lsl.w	#2,d0
	lea	fonts+32,a4
	move.w	(a4,d0.w),d2
	add.w	2(a4,d0.w),a3
bcl
li	set	0
	REPT	12
	move.b	(a3)+,li(A1)
	move.b	(a3)+,li+160(A2)
li	set	li+160
	endr
	add.w	d3,a1
	add.w	d3,a2
	swap	d3
	dbra	d2,bcl
	BRA	CALCUL_FNTS

other	MOVEQ	#0,D0
	cmpi.B	#-2,-1(A0)
	Bne.S	NOT_END_TEXTE
	LEA	TEXTE,A0
NOT_END_TEXTE
	MOVE.L	A0,PTEXTE
CLR_R	sub.l	pt_phys,a2
	CMP.L	#120,A2
	BGE	END_LIT_TEXTE
	add.l	pt_phys,a2
	MOVEQ	#0,D0
L_C	SET	0
	REPT	12
	MOVE.b	D0,L_C(A1)
	MOVE.b	D0,L_C(A2)
L_C	SET	L_C+160
	ENDR
	ADD.W	D3,A1
	ADD.W	D3,A2
	SWAP	D3
	BRA	CLR_R
END_LIT_TEXTE
	add.l	#160*13,pt_log
	add.l	#160*13,pt_phys
	cmp.l	#screen1+6+40+160*13*12,pt_phys
	bne	ligne_texte
	move.l	#screen2+6+40,pt_log
	move.l	#screen1+6+40,pt_phys
	RTS

CODAGE	LEA	TEXTE(PC),A0
	LEA	CODE(PC),A1
	MOVEQ	#0,D0
CODAG	MOVE.B	(A0),D0
	SUBI.B	#$20,D0
	MOVE.B	(A1,D0.W),(A0)+
	CMPI.B	#0,(A0)
	BNE.S	CODAG
	MOVE.B	#-1,(A0)
	RTS

CODE	DC.B	71        espace
	DC.B	67        !
	DC.B	71        "
	DC.B	71        #
	DC.B	-1        $ fin ligne
	DC.B	-2        % fin texte
	DC.B	70        &
	DC.B	71        '
	DC.B	68        (
	DC.B	69        )
	DC.B	71        * non
	DC.B	71        + non
	DC.B	63        ,
	DC.B	71        -
	DC.B	61        .
	DC.B	71        / non
	DC.B 	40,52,53,54,55,56,57,58,59,60	0123456789
	DC.B	62        :
	DC.B	71        ;
	DC.B	64        < H
	DC.B	71        = M
	DC.B	65        > D
	DC.B	66        ?
	DC.B	71        @ non
	DC.B	26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44
	dc.b	45,46,47,48,49,50,51	A-Z
	DC.B	71        [
	DC.B	71        \
	DC.B	71        ]
	DC.B	71        ^
	DC.B	71        _
	DC.B	71        `
	DC.B	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21
	dc.b	22,23,24,25	a-z
	dcb.b	10,71	
	EVEN


PTEXTE	DC.L	TEXTE
;ATTENTION:	"               " CETTE LONGUEUR SEULEMENT!
;$ fin ligne      % fin texte
TEXTE	dc.b	"  Welcome!!!$"
	dc.b	"Here is the old$"
	dc.b	"promise demo by$"
	dc.b	"the Hemoroids$"
	dc.b	"members of the$"
	dc.b	"great .....$"
	dc.b	"Reunion Island!%"


	EVEN
COLORS	DS.L	8
PHYS	DC.L	screen1
LOG	DC.L	screen2
PT_phys	DC.L	screen1+40+6
PT_LOG	DC.L	screen2+40+6


FONTS	INCBIN	fontes1.hmd
	EVEN
fond1	incbin	fond1.pi1
;fond2	incbin	b:fx2.pi1
;fond3	incbin	b:fx3.pi1
	END
						                     										                     				 						                     				