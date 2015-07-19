	ifeq	SPRITES
	move	ptrdef\w,a0
	move	(a0),a0

	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4

	movem	106(a0),d0/d5/d6/d7/a1/a2
	add	#144,d0
	movem.l	d1-d4,0(a5,d0.w)	;E
	addq	#8,d5
	movem.l	d1-d4,128-8(a5,d5.w)	;C
	movem.l	d1-d4,120(a5,d6.w)	;R
	movem.l	d1-d4,104(a5,d7.w)	;O
	movem.l	d1-d4,88(a5,a1.w)	;F
					;espace
	movem	118(a0),d0/d5/d6/d7/a1/a2
	movem.l	d1-d4,64(a5,d0.w)	;M
	movem.l	d1-d4,48(a5,d5.w)	;U
	movem.l	d1-d4,40(a5,d6.w)	;N
	movem.l	d1-d4,24(a5,d7.w)	;G
	movem.l	d1-d4,8(a5,a1.w)	;A
	movem.l	d1-d4,0(a5,a2.w)	;M

	cmp	#mess3,message\w
	blo	nosprite

	move	coords\w,a1

; quelques d‚finitions de registres fixes
;  pour gagner des cycles en accŠs m‚moire

	LEA	$FFFEFFFE,A2
	LEA	$FFFCFFFC,A3
	LEA	$F8000800,A0
	LEA	$FFC0FFC0,A5
	LEA	$001F001F,A4

; E
	move.l	usp,a6
	add	(a1)+,a6		;coordonn‚e Y

	move.l	A5,d0			;D0=FFC0FFC0
	move.l	A5,d1
	not.l	d1			;D1=003F003F
	move.l	#$3F001F,d2
	move.l	#$FFC0FF80,d3
	moveq	#$7F,d5

	and.b	d0,$91(a6)
	or.b	d1,$93(a6)
	or.l	d1,$94(a6)
	and	d1,$98(a6)
	or	d0,$9A(a6)
	or.l	d0,$9C(a6)
	and.b	d0,$133(a6)
	or.l	d2,$130(a6)
	or.l	d1,$134(a6)
	and	d1,$13A(a6)
	or.l	d3,$138(a6)
	or.l	d0,$13C(a6)
	and.b	d0,$1D3(a6)
	or.l	d2,$1D0(a6)
	or.l	d1,$1D4(a6)
	and	d1,$1DA(a6)
	or.l	d3,$1D8(a6)
	or.l	d0,$1DC(a6)
	and.l	d0,$310(a6)
	or.l	#$1F0020,$310(a6)
	or.l	d1,$314(a6)
	and	d5,$31A(a6)

	BCLR	#22,D3			;D3=FF80FF80
	MOVE.L	D3,D4
	NEG	D4			;D4=FF800080

	or.l	D4,$318(a6)
	or.l	d3,$31C(a6)
	and.b	d0,$3B1(a6)
	or.b	d1,$3B3(a6)
	or.l	d1,$3B4(a6)
	and	d5,$3B8(a6)

	SWAP	D4			;D4=0080FF80

	or.l	d4,$3B8(a6)
	or.l	d3,$3BC(a6)
	and.b	d0,$451(a6)
	or.b	d1,$453(a6)
	or.l	d1,$454(a6)
	and	d5,$458(a6)
	or.l	d4,$458(a6)
	or.l	d3,$45C(a6)
	and.b	d0,$4F1(a6)

	SWAP	D2			;D2=001F003F

	or.l	d2,$4F0(a6)
	and.b	d0,$4F5(a6)

	move.l	#$21003F,d4

	or.l	d4,$4F4(a6)
	or.l	d3,$4F8(a6)
	or.l	d3,$4FC(a6)
	and.b	d0,$591(a6)
	or.l	d2,$590(a6)
	and.b	d0,$595(a6)
	or.l	d4,$594(a6)
	and.b	d0,$631(a6)

	BCLR	#21,D4		;D4=0001003F

	or.l	D4,$630(a6)
	or.l	d1,$634(a6)
	and.b	d0,$6D1(a6)
	or.l	D4,$6D0(a6)
	or.l	d1,$6D4(a6)
	and.l	d0,$770(a6)

	MOVE.L	A4,D3
	ADDQ	#2,D3		;D3=1F0021

	or.l	d3,$770(a6)
	or.l	d1,$774(a6)
	and.l	d0,$810(a6)
	or.l	d3,$810(a6)
	or.l	d1,$814(a6)
	and.b	d0,$8B1(a6)
	or.l	#$1E003F,$8B0(a6)
	or.l	d1,$8B4(a6)
	and	d1,$8B8(a6)
	or.l	#$40FFC0,$8B8(a6)
	or.l	d0,$8BC(a6)
	and.b	d0,$951(a6)
	or.l	d2,$950(a6)
	or.l	d1,$954(a6)
	or.l	d0,$958(a6)
	or.l	d0,$95C(a6)
	and.b	d0,$9F1(a6)
	or.l	d2,$9F0(a6)
	or.l	d1,$9F4(a6)
	or.l	d0,$9F8(a6)
	or.l	d0,$9FC(a6)
; C
	move.l	usp,a6
	add	(a1)+,a6		;coordonn‚e Y

	and	#3,$88(a6)

	MOVE.L	A3,D0			;D0=FFFCFFFC
	MOVE.L	A2,D1
	NOT.L	D1			;D1=00010001
	move.l	A2,d2
	move	A3,d2			;D2=FFFEFFFC
	move.l	#$FC000400,d3
	MOVE.L	D3,D4
	NEG	D4			;D4=FC00FC00
	move.l	d3,d5
	swap	d5			;D5=0400FC00

	or	d0,$8A(a6)
	or.l	d0,$8C(a6)

	MOVE.L	A2,D0			;D0=FFFEFFFE

	and.b	d0,$121(a6)
	or.b	d1,$123(a6)
	or.l	d1,$124(a6)
	and	d1,$12A(a6)
	or.l	d2,$128(a6)
	or.l	d0,$12C(a6)
	and.b	d0,$1C1(a6)
	or.b	d1,$1C3(a6)
	or.l	d1,$1C4(a6)
	and	d1,$1CA(a6)
	or.l	d2,$1C8(a6)
	or.l	d0,$1CC(a6)
	and.b	d0,$301(a6)
	or.b	d1,$303(a6)
	or.l	d1,$304(a6)

	move	#$3FF,d2
	and	d2,$30A(a6)
	or.l	d3,$308(a6)
	or.l	d4,$30C(a6)
	and.b	d0,$3A1(a6)
	or.b	d1,$3A3(a6)
	or.l	d1,$3A4(a6)
	and	d2,$3A8(a6)
	or.l	d5,$3A8(a6)
	or.l	d4,$3AC(a6)
	and.b	d0,$441(a6)
	or.b	d1,$443(a6)
	or.l	d1,$444(a6)
	and	d2,$448(a6)
	or.l	d5,$448(a6)
	or.l	d4,$44C(a6)
	and.b	d0,$4E1(a6)
	or.b	d1,$4E3(a6)
	or.l	d1,$4E4(a6)
	or.l	d4,$4E8(a6)
	and	d2,$4EC(a6)
	or.l	d5,$4EC(a6)
	and.b	d0,$581(a6)
	or.b	d1,$583(a6)
	or.l	d1,$584(a6)
	or.l	d4,$588(a6)
	and	d2,$58C(a6)
	or.l	d5,$58C(a6)
	and.b	d0,$621(a6)
	or.b	d1,$623(a6)
	or.l	d1,$624(a6)
	and	d2,$628(a6)
	or.l	d5,$628(a6)
	or.l	d4,$62C(a6)
	and.b	d0,$6C1(a6)
	or.b	d1,$6C3(a6)
	or.l	d1,$6C4(a6)
	and	d2,$6C8(a6)
	or.l	d5,$6C8(a6)
	or.l	d4,$6CC(a6)
	and.b	d0,$761(a6)
	or.b	d1,$763(a6)
	or.l	d1,$764(a6)
	and	d2,$76A(a6)
	or.l	d3,$768(a6)
	or.l	d4,$76C(a6)
	and.b	d0,$801(a6)
	or.b	d1,$803(a6)
	or.l	d1,$804(a6)
	and	d2,$80A(a6)
	or.l	d3,$808(a6)
	or.l	d4,$80C(a6)
	and.b	d0,$8A1(a6)
	or.b	d1,$8A3(a6)
	or.l	d1,$8A4(a6)
	or.l	d0,$8A8(a6)
	or.l	d0,$8AC(a6)
	and.b	d0,$941(a6)
	or.b	d1,$943(a6)
	or.l	d1,$944(a6)
	or.l	d0,$948(a6)
	or.l	d0,$94C(a6)
	and.b	d0,$9E1(a6)
	or.b	d1,$9E3(a6)
	or.l	d1,$9E4(a6)
	or.l	d0,$9E8(a6)
	or.l	d0,$9EC(a6)
; R
	move.l	usp,a6
	add	(a1)+,a6		;coordonn‚e Y

	MOVE.L	A0,D0
	NEG	D0			;D0=F800F800
	move.l	d0,d1
	not.l	d1			;D1=07FF07FF
	move.l	A0,d2
	swap	d2			;D2=0800F800
	move.l	#$F000F000,d3
	move.l	#$3FF07FF,d4
	move.l	#$FFF8FFF8,d5
	move.l	d5,d6
	not.l	d6			;D6=00070007
	MOVE.L	A0,D7			;D7=F8000800

	and	d0,$78(a6)
	or	d1,$7A(a6)
	or.l	d1,$7C(a6)
	and	#$FFF,$80(a6)
	or	d3,$82(a6)
	or.l	d3,$84(a6)
	and	d0,$118(a6)
	or.l	d4,$118(a6)
	or.l	d1,$11C(a6)
	or.l	d0,$120(a6)
	or.l	d0,$124(a6)
	and	d0,$1B8(a6)
	or.l	d4,$1B8(a6)
	or.l	d1,$1BC(a6)
	or.l	d0,$1C0(a6)
	or.l	d0,$1C4(a6)
	and.b	d5,$25B(a6)
	or.b	d6,$259(a6)
	or.l	d6,$25C(a6)
	and	d1,$262(a6)
	or.l	d7,$260(a6)
	or.l	d0,$264(a6)
	and.l	d0,$2F8(a6)
	or.l	#$3FF0400,$2F8(a6)
	or.l	d1,$2FC(a6)
	and	d1,$302(a6)
	or.l	d7,$300(a6)
	or.l	d0,$304(a6)
	and	d0,$398(a6)
	or	d1,$39A(a6)
	or.l	d1,$39C(a6)
	and	d1,$3A0(a6)
	or.l	d2,$3A0(a6)
	or.l	d0,$3A4(a6)
	and	d0,$438(a6)
	or	d1,$43A(a6)
	or.l	d1,$43C(a6)
	and	d1,$440(a6)
	or.l	d2,$440(a6)
	or.l	d0,$444(a6)
	and	d0,$4D8(a6)
	or.l	d4,$4D8(a6)
	and	d0,$4DC(a6)
	or.l	#$40107FF,$4DC(a6)

	move.l	#$80008000,d4

	or.l	d4,$4E0(a6)
	or.l	d4,$4E4(a6)
	and	d0,$578(a6)
	or.l	#$FF07FF,$578(a6)
	and	d0,$57C(a6)
	or.l	#$70007FF,$57C(a6)
	or.l	d3,$580(a6)
	and	#$FFF,$584(a6)
	or.l	#$7000F000,$584(a6)
	MOVE.b	D4,$619(a6)		;=CLR.B
	move.b	d1,$61B(a6)
	or.l	#$FF00FF,$61C(a6)
	and	d1,$620(a6)
	or.l	d2,$620(a6)
	or.l	d0,$624(a6)
	and.b	#$E0,$6B9(a6)

	move.l	A4,d3

	or.b	d3,$6BB(a6)
	or.l	d3,$6BC(a6)
	and	d1,$6C0(a6)
	or.l	d2,$6C0(a6)
	or.l	d0,$6C4(a6)
	and.l	d5,$758(a6)

	move.l	#$30004,d3

	or.l	d3,$758(a6)
	or.l	d6,$75C(a6)
	and	d1,$762(a6)
	or.l	d7,$760(a6)
	or.l	d0,$764(a6)
	and.l	d5,$7F8(a6)
	or.l	d3,$7F8(a6)
	or.l	d6,$7FC(a6)
	and	d1,$802(a6)
	or.l	d7,$800(a6)
	or.l	d0,$804(a6)
	and.b	d5,$899(a6)

	addq	#7-4,d3			;D3=00030007

	or.l	d3,$898(a6)
	or.l	d6,$89C(a6)
	or.l	d0,$8A0(a6)
	or.l	d0,$8A4(a6)
	and.b	d5,$939(a6)
	or.l	d3,$938(a6)
	or.l	d6,$93C(a6)
	or.l	d0,$940(a6)
	or.l	d0,$944(a6)
	and.b	d5,$9D9(a6)
	or.l	d3,$9D8(a6)
	or.l	d6,$9DC(a6)
	or.l	d0,$9E0(a6)
	or.l	d0,$9E4(a6)
; O
	move.l	usp,a6
	add	(a1)+,a6		;coordonn‚e Y

	move.l	A5,d0
	move.l	#$1F003F,d1
	move.l	A5,d2
	not.l	d2			;D2=3F003F
	move.l	A4,d3
	move.l	#$603F603F,d4
	move.l	#$8FC09040,d5
	MOVE.L	D4,D6
	NOT.L	D6			;D6=9FC09FC0
	move.l	#$FF80FF80,d7

	and.b	#$E0,$69(a6)
	or.b	d3,$6B(a6)
	or.l	d3,$6C(a6)
	and	#$7F,$70(a6)
	or	d7,$72(a6)
	or.l	d7,$74(a6)

	BSET	#22,D7			;D7=FFC0FF80

	and.b	d0,$109(a6)
	or.l	d1,$108(a6)
	or.l	d2,$10C(a6)
	and	d1,$112(a6)
	or.l	d7,$110(a6)
	or.l	d0,$114(a6)
	and.b	d0,$1A9(a6)
	or.l	d1,$1A8(a6)
	or.l	d2,$1AC(a6)
	and	d1,$1B2(a6)
	or.l	d7,$1B0(a6)
	or.l	d0,$1B4(a6)
	and.l	d0,$2E8(a6)

	ADDQ	#1,D3			;D3=1F0020
	move.l	#$80409FC0,d7

	or.l	d3,$2E8(a6)
	or.l	d2,$2EC(a6)
	and.l	d4,$2F0(a6)
	or.l	d5,$2F0(a6)
	or.l	d6,$2F4(a6)
	and.b	d0,$389(a6)
	or.b	d1,$38B(a6)
	or.l	d2,$38C(a6)
	and	d4,$390(a6)
	or.l	d7,$390(a6)
	or.l	d6,$394(a6)
	and.b	d0,$429(a6)
	or.b	d1,$42B(a6)
	or.l	d2,$42C(a6)
	and	d4,$430(a6)
	or.l	d7,$430(a6)
	or.l	d6,$434(a6)
	and.b	d0,$4C9(a6)
	or.l	d1,$4C8(a6)
	and.b	d0,$4CD(a6)
	or.l	#$20003F,$4CC(a6)
	and	d4,$4D0(a6)
	or.l	#$8FC09FC0,$4D0(a6)
	and	d4,$4D4(a6)
	or.l	#$90409FC0,$4D4(a6)
	and.b	d0,$569(a6)
	or.l	d1,$568(a6)
	and.b	d0,$56D(a6)
	or.l	#$20003F,$56C(a6)
	and	d4,$570(a6)
	or.l	#$8FC09FC0,$570(a6)
	and	d4,$574(a6)
	or.l	#$90409FC0,$574(a6)
	and.b	d0,$609(a6)
	or.b	d1,$60B(a6)
	or.l	d2,$60C(a6)
	and	d4,$610(a6)
	or.l	d7,$610(a6)
	or.l	d6,$614(a6)
	and.b	d0,$6A9(a6)
	or.b	d1,$6AB(a6)
	or.l	d2,$6AC(a6)
	and	d4,$6B0(a6)
	or.l	d7,$6B0(a6)
	or.l	d6,$6B4(a6)
	and.l	d0,$748(a6)
	or.l	d3,$748(a6)
	or.l	d2,$74C(a6)
	and.l	d4,$750(a6)
	or.l	d5,$750(a6)
	or.l	d6,$754(a6)
	and.l	d0,$7E8(a6)
	or.l	d3,$7E8(a6)
	or.l	d2,$7EC(a6)
	and.l	d4,$7F0(a6)
	or.l	d5,$7F0(a6)
	or.l	d6,$7F4(a6)
	and.b	d0,$889(a6)
	or.l	d1,$888(a6)
	or.l	d2,$88C(a6)
	or.l	d0,$890(a6)
	or.l	d0,$894(a6)
	and.b	d0,$929(a6)
	or.l	d1,$928(a6)
	or.l	d2,$92C(a6)
	or.l	d0,$930(a6)
	or.l	d0,$934(a6)
	and.b	d0,$9C9(a6)
	or.l	d1,$9C8(a6)
	or.l	d2,$9CC(a6)
	or.l	d0,$9D0(a6)
	or.l	d0,$9D4(a6)
; F
	move.l	usp,a6
	add	(a1)+,a6		;coordonn‚e Y

	MOVE.L	A2,D0			;D0=FFFEFFFE
	move.l	A2,d1
	not.l	d1			;D1=00010001
	MOVE.L	A2,D2
	MOVE	A3,D2			;D2=FFFEFFFC
	move.l	A3,D3			;D3=FFFCFFFC
	move.l	#$FFFC0004,d4

	and.b	d0,$59(a6)
	or.b	d1,$5B(a6)
	or.l	d1,$5C(a6)
	and	d1,$60(a6)
	or	d0,$62(a6)
	or.l	d0,$64(a6)
	and.b	d0,$F9(a6)
	or.b	d1,$FB(a6)
	or.l	d1,$FC(a6)
	and	d1,$102(a6)
	or.l	d2,$100(a6)
	or.l	d0,$104(a6)
	and.b	d0,$199(a6)
	or.b	d1,$19B(a6)
	or.l	d1,$19C(a6)
	and	d1,$1A2(a6)
	or.l	d2,$1A0(a6)
	or.l	d0,$1A4(a6)
	and.b	d0,$2D9(a6)
	or.b	d1,$2DB(a6)
	or.l	d1,$2DC(a6)

	moveq	#3,d2

	and	d2,$2E2(a6)
	or.l	D4,$2E0(a6)

	SWAP	D4			;D4=4FFFC

	or.l	d3,$2E4(a6)
	and.b	d0,$379(a6)
	or.b	d1,$37B(a6)
	or.l	d1,$37C(a6)
	and	d2,$380(a6)
	or.l	d4,$380(a6)
	or.l	d3,$384(a6)
	and.b	d0,$419(a6)
	or.b	d1,$41B(a6)
	or.l	d1,$41C(a6)
	and	d2,$420(a6)
	or.l	d4,$420(a6)
	or.l	d3,$424(a6)
	and.b	d0,$4B9(a6)
	or.b	d1,$4BB(a6)
	or.l	d1,$4BC(a6)
	or.l	d3,$4C0(a6)
	and	d2,$4C4(a6)
	or.l	d4,$4C4(a6)
	and.b	d0,$559(a6)
	or.b	d1,$55B(a6)
	or.l	d1,$55C(a6)
	or.l	d3,$560(a6)
	and	d2,$564(a6)
	or.l	#$FFCFFFC,$564(a6)
	and.b	d0,$5F9(a6)
	or.b	d1,$5FB(a6)
	or.l	d1,$5FC(a6)

	move	#$7FF,d2
	MOVE.L	A0,D3
	SWAP	D3			;D3=0800F800
	MOVE.L	A0,D4
	NEG	D4			;D4=F800F800

	and	d2,$600(a6)
	or.l	d3,$600(a6)
	or.l	d4,$604(a6)
	and.b	d0,$699(a6)
	or.b	d1,$69B(a6)
	or.l	d1,$69C(a6)
	and	d2,$6A0(a6)
	or.l	d3,$6A0(a6)
	or.l	d4,$6A4(a6)
	and.b	d0,$739(a6)
	or.b	d1,$73B(a6)
	or.l	d1,$73C(a6)
	and	d2,$742(a6)

	MOVE.L	A0,D3			;D3=F8000800

	or.l	d3,$740(a6)
	or.l	d4,$744(a6)
	and.b	d0,$7D9(a6)
	or.b	d1,$7DB(a6)
	or.l	d1,$7DC(a6)
	and	d2,$7E2(a6)
	or.l	d3,$7E0(a6)
	or.l	d4,$7E4(a6)
	and.b	d0,$879(a6)
	or.b	d1,$87B(a6)
	or.l	d1,$87C(a6)
	or.l	d4,$880(a6)
	or.l	d4,$884(a6)
	and.b	d0,$919(a6)
	or.b	d1,$91B(a6)
	or.l	d1,$91C(a6)
	or.l	d4,$920(a6)
	or.l	d4,$924(a6)
	and.b	d0,$9B9(a6)
	or.b	d1,$9BB(a6)
	or.l	d1,$9BC(a6)
	or.l	d4,$9C0(a6)
	or.l	d4,$9C4(a6)
; espace
;	addq	#2,a1
; M
;transfŠre espace et M … la fois !!!!
	move.l	(a1)+,d0
	move.l	usp,a6
	add	d0,a6
;	add	(a1)+,a6		;coordonn‚e Y

	move.l	#$7C007C0,d0
	MOVE.L	A5,D1
	NOT.L	D1			;D1=003F003F
	MOVE.L	D0,D2
	NOT.L	D2			;D2=F83FF83F
	move.l	#$1E003F,d3
	move.l	#$3C007C0,d4
	MOVE.L	A4,D5
	ADDQ	#1,D5		;D5=1F0020
	move.l	#$3C00440,d7

	and.b	d0,$41(a6)
	or.b	d1,$43(a6)
	or.l	d1,$44(a6)
	and	d2,$48(a6)
	or	d0,$4A(a6)
	or.l	d0,$4C(a6)
	and.b	d0,$E1(a6)
	or.l	d3,$E0(a6)
	or.l	d1,$E4(a6)
	and	d2,$E8(a6)
	or.l	d4,$E8(a6)
	or.l	d0,$EC(a6)
	and.b	d0,$181(a6)
	or.l	d3,$180(a6)
	or.l	d1,$184(a6)
	and	#$703F,$188(a6)
	or.l	#$3C08FC0,$188(a6)
	or.l	#$8FC08FC0,$18C(a6)

	move.l	A5,d3

	and.l	d3,$220(a6)
	or.l	d5,$220(a6)
	or.l	d1,$224(a6)
	and.l	#$203F203F,$228(a6)
	or.l	#$7C0D840,$228(a6)
	or.l	#$DFC0DFC0,$22C(a6)
	and.l	d3,$2C0(a6)
	or.l	d5,$2C0(a6)
	or.l	d1,$2C4(a6)
	and	d1,$2CA(a6)

	MOVE.L	A5,D5
	NEG	D5			;D5=FFC00040

	or.l	D5,$2C8(a6)
	or.l	d3,$2CC(a6)
	and.b	d0,$361(a6)
	or.b	d1,$363(a6)
	or.l	d1,$364(a6)
	and	d1,$368(a6)

	SWAP	D5			;D5=0040FFC0

	or.l	d5,$368(a6)
	or.l	d3,$36C(a6)
	and.b	d0,$401(a6)
	or.b	d1,$403(a6)
	or.l	d1,$404(a6)
	and	d1,$408(a6)
	or.l	d5,$408(a6)
	or.l	d3,$40C(a6)
	and.b	d0,$4A1(a6)
	or.l	#$1F003F,$4A0(a6)
	and.b	d0,$4A5(a6)
	or.l	#$20003F,$4A4(a6)
	or.l	d3,$4A8(a6)
	and	d1,$4AC(a6)
	or.l	d5,$4AC(a6)

	move.l	#$FFC1FFC1,d1
	move.l	#$1E003E,d3

	and.b	d1,$541(a6)
	or.l	d3,$540(a6)
	and.b	d1,$545(a6)
	or.l	#$22003E,$544(a6)

	move	#$83F,d5

	and	d5,$548(a6)
	or.l	#$F3C0F7C0,$548(a6)
	and	d5,$54C(a6)
	or.l	#$440F7C0,$54C(a6)
	and.b	d1,$5E1(a6)

	move.l	#$2003E,d5

	or.l	d5,$5E0(a6)

	MOVE.L	D1,D6
	NOT.L	D6			;D6=003E003E

	or.l	d6,$5E4(a6)
	and	#$983F,$5E8(a6)
	or.l	#$4067C0,$5E8(a6)
	or.l	#$67C067C0,$5EC(a6)
	and.b	d1,$681(a6)
	or.l	d5,$680(a6)
	or.l	d6,$684(a6)
	and	d2,$688(a6)
	or.l	#$4007C0,$688(a6)
	or.l	d0,$68C(a6)
	and.l	d1,$720(a6)

	move.l	#$1E0022,d5

	or.l	d5,$720(a6)
	or.l	d6,$724(a6)
	and.l	d2,$728(a6)
	or.l	d7,$728(a6)
	or.l	d0,$72C(a6)
	and.l	d1,$7C0(a6)
	or.l	d5,$7C0(a6)
	or.l	d6,$7C4(a6)
	and.l	d2,$7C8(a6)
	or.l	d7,$7C8(a6)
	or.l	d0,$7CC(a6)
	and.b	d1,$861(a6)
	or.l	d3,$860(a6)
	or.l	d6,$864(a6)
	and	d2,$868(a6)
	or.l	d4,$868(a6)
	or.l	d0,$86C(a6)
	and.b	d1,$901(a6)
	or.l	d3,$900(a6)
	or.l	d6,$904(a6)
	and	d2,$908(a6)
	or.l	d4,$908(a6)
	or.l	d0,$90C(a6)
	and.b	d1,$9A1(a6)
	or.l	d3,$9A0(a6)
	or.l	d6,$9A4(a6)
	and	d2,$9A8(a6)
	or.l	d4,$9A8(a6)
	or.l	d0,$9AC(a6)
; U
	move.l	usp,a6
	add	(a1)+,a6		;coordonn‚e Y
	move.l	#$FCFEFC7E,d3
	MOVE.L	D3,D0
	TAS	D0			;D0=FCFEFCFE
	and.b	d0,$31(a6)
	MOVE.L	A2,D1
	NOT.L	D1			;D1=00010001
	or.b	d1,$33(a6)
	or.l	d1,$34(a6)
	MOVE.L	D0,D2
	NOT.L	D2			;D2=03010301
	and.l	d2,$38(a6)
	or.l	#$FEFC00,$38(a6)
	or.l	d0,$3C(a6)
	and.b	d0,$D3(a6)
	or.b	d1,$D1(a6)
	or.l	d1,$D4(a6)
	and	d2,$DA(a6)
	or.l	d3,$D8(a6)
	or.l	d0,$DC(a6)
	and.b	d0,$173(a6)
	or.b	d1,$171(a6)
	or.l	d1,$174(a6)
	and	d2,$17A(a6)
	or.l	d3,$178(a6)
	or.l	d0,$17C(a6)
	and.b	d0,$213(a6)
	or.b	d1,$211(a6)
	or.l	d1,$214(a6)
	and	d2,$21A(a6)
	move	#$402,d3
	or.l	d3,$218(a6)
	or.l	d0,$21C(a6)
	and.b	d0,$2B3(a6)
	or.b	d1,$2B1(a6)
	or.l	d1,$2B4(a6)
	and	d2,$2BA(a6)
	or.l	d3,$2B8(a6)
	or.l	d0,$2BC(a6)
	and.b	d0,$353(a6)
	or.b	d1,$351(a6)
	or.l	d1,$354(a6)
	and.l	d2,$358(a6)
	move.l	#$482FC7E,d3
	or.l	d3,$358(a6)
	or.l	d0,$35C(a6)
	and.b	d0,$3F3(a6)
	or.b	d1,$3F1(a6)
	or.l	d1,$3F4(a6)
	and.l	d2,$3F8(a6)
	or.l	d3,$3F8(a6)
	or.l	d0,$3FC(a6)
	and.b	d0,$491(a6)
	or.b	d1,$493(a6)
	or.l	d1,$494(a6)
	and	d2,$498(a6)
	move.l	d3,d4
	tas	d4			;D4=482FCFE
	move.l	#$FC7EFCFE,d3
	or.l	d3,$498(a6)
	and	d2,$49C(a6)
	or.l	d4,$49C(a6)
	and.b	d0,$531(a6)
	or.b	d1,$533(a6)
	or.l	d1,$534(a6)
	and	d2,$538(a6)
	or.l	d3,$538(a6)
	and	d2,$53C(a6)
	or.l	d4,$53C(a6)
	and.b	d0,$5D1(a6)
	or.b	d1,$5D3(a6)
	or.l	d1,$5D4(a6)
	and	d2,$5D8(a6)

	move.l	#$402FCFE,d3
	or.l	d3,$5D8(a6)
	or.l	d0,$5DC(a6)
	and.b	d0,$671(a6)
	or.b	d1,$673(a6)
	or.l	d1,$674(a6)
	and	d2,$678(a6)
	or.l	d3,$678(a6)
	or.l	d0,$67C(a6)
	and.b	d0,$711(a6)
	or.b	d1,$713(a6)
	or.l	d1,$714(a6)
	and.l	d2,$718(a6)
	move.l	#$FC7E0482,d3
	or.l	d3,$718(a6)
	or.l	d0,$71C(a6)
	and.b	d0,$7B1(a6)
	or.b	d1,$7B3(a6)
	or.l	d1,$7B4(a6)
	and.l	d2,$7B8(a6)
	or.l	d3,$7B8(a6)
	or.l	d0,$7BC(a6)
	and.b	d0,$851(a6)
	or.b	d1,$853(a6)
	or.l	d1,$854(a6)
	MOVE.L	A2,D2			;A2=FFFEFFFE
	or.l	d2,$858(a6)
	or.l	d2,$85C(a6)
	and.b	d0,$8F1(a6)
	or.b	d1,$8F3(a6)
	or.l	d1,$8F4(a6)
	or.l	d2,$8F8(a6)
	or.l	d2,$8FC(a6)
	and.b	d0,$991(a6)
	or.b	d1,$993(a6)
	or.l	d1,$994(a6)
	or.l	d2,$998(a6)
	or.l	d2,$99C(a6)
; N
	move.l	usp,a6
	add	(a1)+,a6		;coordonn‚e Y
	move	#$F81F,d0
	and	d0,$28(a6)
	move.l	#$7E007E0,d1
	or	d1,$2A(a6)
	or.l	d1,$2C(a6)
	MOVE.L	A0,D3
	NEG	D3			;D3=F800F800
	MOVE.L	D3,D2
	NOT.L	D2			;D2=07FF07FF
	and	d2,$30(a6)
	or	d3,$32(a6)
	or.l	d3,$34(a6)
	and	d0,$C8(a6)
	move.l	#$3E007E0,d4
	or.l	d4,$C8(a6)
	or.l	d1,$CC(a6)
	and	d2,$D0(a6)
	move.l	#$7800F800,d5
	or.l	d5,$D0(a6)
	or.l	d3,$D4(a6)
	and	#$F807,$168(a6)
	or.l	#$3F807F8,$168(a6)
	or.l	#$7F807F8,$16C(a6)
	and	d2,$170(a6)
	or.l	d5,$170(a6)
	or.l	d3,$174(a6)
	and.l	#$F803F803,$208(a6)
	or.l	#$3FC0404,$208(a6)
	or.l	#$7FC07FC,$20C(a6)
	and.l	d2,$210(a6)
	move	#$8800,d5
	or.l	d5,$210(a6)
	or.l	d3,$214(a6)
	and.l	d3,$2A8(a6)
	or.l	#$3FF0403,$2A8(a6)
	or.l	d2,$2AC(a6)
	and.l	d2,$2B0(a6)
	or.l	d5,$2B0(a6)
	or.l	d3,$2B4(a6)
	and	d3,$348(a6)
	or	d2,$34A(a6)
	or.l	d2,$34C(a6)
	and	d2,$350(a6)
	MOVE.L	A0,D5
	SWAP	D5			;D5=0800F800
	or.l	d5,$350(a6)
	or.l	d3,$354(a6)
	and	d3,$3E8(a6)
	or	d2,$3EA(a6)
	or.l	d2,$3EC(a6)
	and	d2,$3F0(a6)
	or.l	d5,$3F0(a6)
	or.l	d3,$3F4(a6)
	and	d3,$488(a6)
	move.l	#$3FF07FF,d6
	or.l	d6,$488(a6)
	and	d3,$48C(a6)
	move.l	#$40007FF,d7
	or.l	d7,$48C(a6)
	or.l	d3,$490(a6)
	and	d2,$494(a6)
	or.l	d5,$494(a6)
	and	d3,$528(a6)
	or.l	d6,$528(a6)
	and	d3,$52C(a6)
	or.l	d7,$52C(a6)
	or.l	d3,$530(a6)
	and	d2,$534(a6)
	or.l	d5,$534(a6)
	and	d3,$5C8(a6)
	or	d2,$5CA(a6)
	or.l	d2,$5CC(a6)
	and	d2,$5D0(a6)
	or.l	d5,$5D0(a6)
	or.l	d3,$5D4(a6)
	and	d3,$668(a6)
	or	d2,$66A(a6)
	or.l	d2,$66C(a6)
	and	d2,$670(a6)
	or.l	d5,$670(a6)
	or.l	d3,$674(a6)
	and.l	d3,$708(a6)
	or.l	#$3FF0438,$708(a6)
	or.l	d2,$70C(a6)
	and	d2,$712(a6)
	MOVE.L	A0,D5			;D5=F8000800
	or.l	d5,$710(a6)
	or.l	d3,$714(a6)
	and.l	#$F818F818,$7A8(a6)
	or.l	#$3E70424,$7A8(a6)
	or.l	#$7E707E7,$7AC(a6)
	and	d2,$7B2(a6)
	or.l	d5,$7B0(a6)
	or.l	d3,$7B4(a6)
	and	#$F81C,$848(a6)
	or.l	#$3E307E3,$848(a6)
	or.l	#$7E307E3,$84C(a6)
	or.l	d3,$850(a6)
	or.l	d3,$854(a6)
	and	#$F81E,$8E8(a6)
	or.l	#$3E107E1,$8E8(a6)
	or.l	#$7E107E1,$8EC(a6)
	or.l	d3,$8F0(a6)
	or.l	d3,$8F4(a6)
	and	d0,$988(a6)
	or.l	d4,$988(a6)
	or.l	d1,$98C(a6)
	or.l	d3,$990(a6)
	or.l	d3,$994(a6)
; G
	move.l	usp,a6
	add	(a1)+,a6		;coordonn‚e Y
	and.b	#$E0,$19(a6)
	move.l	A4,d0
	or.b	d0,$1B(a6)
	or.l	d0,$1C(a6)
	and	#$7F,$20(a6)
	move.l	#$FF80FF80,d0
	or	d0,$22(a6)
	or.l	d0,$24(a6)
	move.l	A5,d0
	and.b	d0,$B9(a6)
	move.l	#$1F003F,d1
	or.l	d1,$B8(a6)
	MOVE.L	A5,D2
	NOT.L	D2		;D2=3F003F
	or.l	d2,$BC(a6)
	or.l	d0,$C0(a6)
	or.l	d0,$C4(a6)
	and.b	d0,$159(a6)
	or.l	d1,$158(a6)
	or.l	d2,$15C(a6)
	or.l	d0,$160(a6)
	or.l	d0,$164(a6)
	and.l	d0,$298(a6)
	MOVE.L	A4,D3
	ADDQ	#1,D3		;D3=1F0020
	or.l	d3,$298(a6)
	or.l	d2,$29C(a6)
	move.l	#$80008000,d4
	or.l	d4,$2A0(a6)
	or.l	d4,$2A4(a6)
	and.b	d0,$339(a6)
	or.b	d1,$33B(a6)
	or.l	d2,$33C(a6)
	or.l	d4,$340(a6)
	or.l	d4,$344(a6)
	and.b	d0,$3D9(a6)
	or.b	d1,$3DB(a6)
	or.l	d2,$3DC(a6)
	or.l	d4,$3E0(a6)
	or.l	d4,$3E4(a6)
	and.b	d0,$479(a6)
	or.l	d1,$478(a6)
	and.b	d0,$47D(a6)
	move.l	#$20003F,d5
	or.l	d5,$47C(a6)
	or.l	d4,$480(a6)
	or.l	d4,$484(a6)
	and.b	d0,$519(a6)
	or.l	d1,$518(a6)
	and.b	d0,$51D(a6)
	or.l	d5,$51C(a6)
	or.l	d4,$520(a6)
	or.l	d4,$524(a6)
	and.b	d0,$5B9(a6)
	or.b	d1,$5BB(a6)
	or.l	d2,$5BC(a6)
	move.l	#$403F403F,d4
	and	d4,$5C0(a6)
	or.l	#$9FC0BFC0,$5C0(a6)
	MOVE.L	D4,D5
	NOT.L	D5			;D5=BFC0BFC0
	or.l	d5,$5C4(a6)
	and.b	d0,$659(a6)
	or.b	d1,$65B(a6)
	or.l	d2,$65C(a6)
	and	d4,$660(a6)
	or.l	#$8040BFC0,$660(a6)
	or.l	d5,$664(a6)
	and.l	d0,$6F8(a6)
	or.l	d3,$6F8(a6)
	or.l	d2,$6FC(a6)
	and.l	d4,$700(a6)
	move.l	#$9FC0A040,d6
	or.l	d6,$700(a6)
	or.l	d5,$704(a6)
	and.l	d0,$798(a6)
	or.l	d3,$798(a6)
	or.l	d2,$79C(a6)
	and.l	d4,$7A0(a6)
	or.l	d6,$7A0(a6)
	or.l	d5,$7A4(a6)
	and.b	d0,$839(a6)
	or.l	d1,$838(a6)
	or.l	d2,$83C(a6)
	or.l	d0,$840(a6)
	or.l	d0,$844(a6)
	and.b	d0,$8D9(a6)
	or.l	d1,$8D8(a6)
	or.l	d2,$8DC(a6)
	or.l	d0,$8E0(a6)
	or.l	d0,$8E4(a6)
	and.b	d0,$979(a6)
	or.l	d1,$978(a6)
	or.l	d2,$97C(a6)
	or.l	d0,$980(a6)
	or.l	d0,$984(a6)
; A
	move.l	usp,a6
	add	(a1)+,a6		;coordonn‚e Y
	and	#3,$10(a6)
	MOVE.L	A3,D0			;D0=FFFCFFFC
	or	d0,$12(a6)
	or.l	d0,$14(a6)
	MOVE	A2,D0			;D0=FFFCFFFE
	and.b	d0,$A9(a6)
	MOVE.L	A2,D1
	NOT.L	D1			;D1=00010001
	or.b	d1,$AB(a6)
	or.l	d1,$AC(a6)
	and	d1,$B0(a6)
	or.l	d0,$B0(a6)
	MOVE.L	A2,D2			;D2=FFFEFFFE
	or.l	d2,$B4(a6)
	and.b	d0,$149(a6)
	or.b	d1,$14B(a6)
	or.l	d1,$14C(a6)
	and	d1,$150(a6)
	or.l	d0,$150(a6)
	or.l	d2,$154(a6)
	and.b	d0,$289(a6)
	or.b	d1,$28B(a6)
	or.l	d1,$28C(a6)
	move.l	#$7810781,d3
	and.l	d3,$290(a6)
	or.l	#$F83E0842,$290(a6)
	MOVE.L	D3,D4
	NOT.L	D4			;D4=F87EF87E
	or.l	d4,$294(a6)
	and.b	d0,$329(a6)
	or.b	d1,$32B(a6)
	or.l	d1,$32C(a6)
	and	d3,$330(a6)
	move.l	#$802F87E,d5
	or.l	d5,$330(a6)
	or.l	d4,$334(a6)
	and.b	d0,$3C9(a6)
	or.b	d1,$3CB(a6)
	or.l	d1,$3CC(a6)
	and	d3,$3D0(a6)
	or.l	d5,$3D0(a6)
	or.l	d4,$3D4(a6)
	and.b	d0,$469(a6)
	or.b	d1,$46B(a6)
	or.l	d1,$46C(a6)
	and	d3,$470(a6)
	or.l	#$F83EF87E,$470(a6)
	and	d3,$474(a6)
	move.l	#$0842F87E,d6
	or.l	D6,$474(a6)
	SWAP	D6			;D6=F87E0842
	and.b	d0,$509(a6)
	or.b	d1,$50B(a6)
	or.l	d1,$50C(a6)
	or.l	d2,$510(a6)
	and	d1,$514(a6)
	move.l	#$2FFFE,d5
	or.l	d5,$514(a6)
	and.b	d0,$5A9(a6)
	or.b	d1,$5AB(a6)
	or.l	d1,$5AC(a6)
	and	d1,$5B0(a6)
	or.l	d5,$5B0(a6)
	or.l	d2,$5B4(a6)
	and.b	d0,$649(a6)
	or.b	d1,$64B(a6)
	or.l	d1,$64C(a6)
	and	d1,$650(a6)
	or.l	#$FC2FFFE,$650(a6)
	or.l	d2,$654(a6)
	and.b	d0,$6E9(a6)
	or.b	d1,$6EB(a6)
	or.l	d1,$6EC(a6)
	and	d3,$6F2(a6)
	or.l	d6,$6F0(a6)
	or.l	d4,$6F4(a6)
	and.b	d0,$789(a6)
	or.b	d1,$78B(a6)
	or.l	d1,$78C(a6)
	and	d3,$792(a6)
	or.l	d6,$790(a6)
	or.l	d4,$794(a6)
	and.b	d0,$829(a6)
	or.b	d1,$82B(a6)
	or.l	d1,$82C(a6)
	or.l	d4,$830(a6)
	or.l	d4,$834(a6)
	and.b	d0,$8C9(a6)
	or.b	d1,$8CB(a6)
	or.l	d1,$8CC(a6)
	or.l	d4,$8D0(a6)
	or.l	d4,$8D4(a6)
	and.b	d0,$969(a6)
	or.b	d1,$96B(a6)
	or.l	d1,$96C(a6)
	or.l	d4,$970(a6)
	or.l	d4,$974(a6)

; M
	move.l	usp,a6
	add	(a1),a6			;coordonn‚e Y
	move.l	#$7800F800,d7
	move	#$F81F,d0
	and	d0,(a6)
	move.l	#$7E007E0,d1
	or	d1,2(a6)
	or.l	d1,4(a6)
	MOVE.L	A0,D3
	NEG	D3			;D3=F800F800
	MOVE.L	D3,D2
	NOT.L	D2			;D2=07FF07FF
	and	d2,8(a6)
	or	d3,$A(a6)
	or.l	d3,$C(a6)
	and	d0,$A0(a6)
	or.l	#$3C007E0,$A0(a6)
	or.l	d1,$A4(a6)
	and	d2,$A8(a6)
	or.l	d7,$A8(a6)
	or.l	d3,$AC(a6)
	and	#$F80E,$140(a6)
	or.l	#$3C007F1,$140(a6)
	or.l	#$7F107F1,$144(a6)
	and	d2,$148(a6)
	or.l	d7,$148(a6)
	or.l	d3,$14C(a6)
	and.l	#$F804F804,$1E0(a6)
	or.l	#$3E0041B,$1E0(a6)
	or.l	#$7FB07FB,$1E4(a6)
	and	d2,$1EA(a6)
	MOVE.L	A0,D1			;D1=F8000800
	or.l	d1,$1E8(a6)
	or.l	d3,$1EC(a6)
	and.l	d3,$280(a6)
	or.l	#$3FF0400,$280(a6)
	or.l	d2,$284(a6)
	and	d2,$28A(a6)
	or.l	d1,$288(a6)
	or.l	d3,$28C(a6)
	and	d7,$320(a6)
	or	d2,$322(a6)
	or.l	d2,$324(a6)
	and	d2,$328(a6)
	swap	d1			;D1=0800F800
	or.l	d1,$328(a6)
	or.l	d3,$32C(a6)
	and	d7,$3C0(a6)
	or	d2,$3C2(a6)
	or.l	d2,$3C4(a6)
	and	d2,$3C8(a6)
	or.l	d1,$3C8(a6)
	or.l	d3,$3CC(a6)
	and	d7,$460(a6)
	or.l	#$3FF07FF,$460(a6)
	and	d7,$464(a6)
	or.l	#$40007FF,$464(a6)
	or.l	d3,$468(a6)
	and	d2,$46C(a6)
	or.l	d1,$46C(a6)
	move	#$F821,d0
	and	d0,$500(a6)
	or.l	#$3DE07DE,$500(a6)
	and	d0,$504(a6)
	or.l	#$44007DE,$504(a6)
	and	d2,$508(a6)
	or.l	d7,$508(a6)
	and	d2,$50C(a6)
	or.l	#$8800F800,$50C(a6)
	and	#$F833,$5A0(a6)
	or.l	#$4007CC,$5A0(a6)
	or.l	#$7CC07CC,$5A4(a6)
	and	d2,$5A8(a6)
	or.l	d1,$5A8(a6)
	or.l	d3,$5AC(a6)
	move.l	#$F83FF83F,d0
	and	d0,$640(a6)
	or.l	#$4007C0,$640(a6)
	MOVE.L	D0,D4
	NOT.L	D4			;D4=07C007C0
	or.l	d4,$644(a6)
	and	d2,$648(a6)
	or.l	d1,$648(a6)
	or.l	d3,$64C(a6)
	and.l	d0,$6E0(a6)
	move.l	#$3C00440,d1
	or.l	d1,$6E0(a6)
	or.l	d4,$6E4(a6)
	and.l	d2,$6E8(a6)
	move.l	#$78008800,d5
	or.l	d5,$6E8(a6)
	or.l	d3,$6EC(a6)
	and.l	d0,$780(a6)
	or.l	d1,$780(a6)
	or.l	d4,$784(a6)
	and.l	d2,$788(a6)
	or.l	d5,$788(a6)
	or.l	d3,$78C(a6)
	and	d0,$820(a6)
	move	#$7C0,d1
	or.l	d1,$820(a6)
	or.l	d4,$824(a6)
	and	d2,$828(a6)
	or.l	d7,$828(a6)
	or.l	d3,$82C(a6)
	and	d0,$8C0(a6)
	or.l	d1,$8C0(a6)
	or.l	d4,$8C4(a6)
	and	d2,$8C8(a6)
	or.l	d7,$8C8(a6)
	or.l	d3,$8CC(a6)
	and	d0,$960(a6)
	or.l	d1,$960(a6)
	or.l	d4,$964(a6)
	and	d2,$968(a6)
	or.l	d7,$968(a6)
	or.l	d3,$96C(a6)
	move.l	usp,a5
nosprite
	endc
