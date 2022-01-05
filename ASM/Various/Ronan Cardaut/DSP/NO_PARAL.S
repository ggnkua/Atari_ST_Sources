DW	macro
	dc.b	0,\1,\2,\3
	endm
	TEXT
NO_PARALLEL
;**********************************************************
;*** SANS PARALLEL MOVE                             *******
;**********************************************************
	DW	$ff,0,0
	DW	%00001111,0,0
	dc.b	'JS      '		;JScc	xxx
	dc.l	CCa12
	DW	$ff,0,0
	DW	%00001110,0,0
	dc.b	'J       '		;Jcc	xxx
	dc.l	CCa12
	DW	$ff,%11110000,0
	DW	%00001101,%00000000,0
	dc.b	'JSR     '		;JSR	xxx
	dc.l	a12
	DW	$ff,$f0,0
	DW	%00001100,0,0
	dc.b	'JMP     '		;JMP	xxx
	dc.l	a12
	DW	$ff,%11000000,%11110000
	DW	%00001011,%11000000,%10100000
	dc.b	'JS      '		;JScc	ea
	dc.l	CCea
	DW	$ff,%11000000,$ff
	DW	%00001011,%11000000,%10000000
	dc.b	'JSR     '		;JSR	ea
	dc.l	Pea
	DW	%11111111,%11000000,%11110000
	DW	%00001010,%11000000,%10100000
	dc.b	'J       '		;JCC	ea
	dc.l	CCea
	DW	$ff,%11000000,$ff
	DW	%00001010,%11000000,%10000000
	dc.b	'JMP     '		;JMP	ea
	dc.l	ea
	DW	$ff,%11000000,%10100000
	DW	%00001011,%10000000,%10100000
	dc.b	'JSSET   '		;JSSET	#n,XY:pp,xxxx
	dc.l	bppxx
	DW	$ff,%11000000,%10100000
	DW	%00001011,%10000000,%10000000
	dc.b	'JSCLR   '		
	dc.l	bppxx	
	DW	$ff,%11000000,%10100000
	DW	%00001010,%10000000,%10100000
	dc.b	'JSET    '
	dc.l	bppxx
	DW	$ff,%11000000,%10100000
	DW	%00001010,%10000000,%10000000
	dc.b	'JCLR    '
	dc.l	bppxx

	DW	$ff,%11000000,%10100000
	DW	%00001011,%01000000,%10100000
	dc.b	'JSSET   '		;JSSET	#n,XY:ea,xxxx
	dc.l	beaxx
	DW	$ff,%11000000,%10100000
	DW	%00001011,%01000000,%10000000
	dc.b	'JSCLR   '
	dc.l	beaxx
	DW	$ff,%11000000,%10100000
	DW	%00001010,%01000000,%10100000
	dc.b	'JSET    '
	dc.l	beaxx
	DW	$ff,%11000000,%10100000
	DW	%00001010,%01000000,%10000000
	dc.b	'JCLR    '
	dc.l	beaxx

	DW	$ff,%11000000,%10100000
	DW	%00001011,%00000000,%10100000
	dc.b	'JSSET   '		;JSSET	#n,XY:aa,xxxx
	dc.l	baaxx
	DW	$ff,%11000000,%10100000
	DW	%00001011,%00000000,%10000000
	dc.b	'JSCLR   '
	dc.l	baaxx
	DW	$ff,%11000000,%10100000
	DW	%00001010,%00000000,%10100000
	dc.b	'JSET    '
	dc.l	baaxx
	DW	$ff,%11000000,%10100000
	DW	%00001010,%00000000,%10000000
	dc.b	'JCLR    '
	dc.l	baaxx


	DW	$ff,%11000000,%11100000
	DW	%00001011,%11000000,%00100000
	dc.b	'JSSET   '		;JSSET	#n,S,xxxx
	dc.l	bSxx
	DW	$ff,%11000000,%11100000
	DW	%00001011,%11000000,%00000000
	dc.b	'JSCLR   '
	dc.l	bSxx
	DW	$ff,%11000000,%11100000
	DW	%00001010,%11000000,%00100000
	dc.b	'JSET    '
	dc.l	bSxx
	DW	$ff,%11000000,%11100000
	DW	%00001010,%11000000,%00000000
	dc.b	'JCLR    '
	dc.l	bSxx




	DW	$ff,%11000000,%10100000
	DW	%00001011,%10000000,%00100000
	dc.b	'BTST    '		;BTST	#n,XY:pp
	dc.l	bpp
	DW	$ff,%11000000,%10100000
	DW	%00001011,%10000000,%00000000
	dc.b	'BCHG    '
	dc.l	bpp
	DW	$ff,%11000000,%10100000
	DW	%00001010,%10000000,%00100000
	dc.b	'BSET    '
	dc.l	bpp
	DW	$ff,%11000000,%10100000
	DW	%00001010,%10000000,%00000000
	dc.b	'BCLR    '
	dc.l	bpp
	DW	$ff,%11000000,%10100000
	DW	%00001011,%01000000,%00100000
	dc.b	'BTST    '		;BTST	#n,XY:ea
	dc.l	bea
	DW	$ff,%11000000,%10100000
	DW	%00001011,%01000000,%00000000
	dc.b	'BCHG    '
	dc.l	bea
	DW	$ff,%11000000,%10100000
	DW	%00001010,%10000000,%00100000
	dc.b	'BSET    '
	dc.l	bea
	DW	$ff,%11000000,%10100000
	DW	%00001010,%01000000,%00000000
	dc.b	'BCLR    '
	dc.l	bea
	DW	$ff,%11000000,%10100000
	DW	%00001011,%00000000,%00100000
	dc.b	'BTST    '		;BTST	#n,XY:aa
	dc.l	baa
	DW	$ff,%11000000,%10100000
	DW	%00001011,%00000000,%00000000
	dc.b	'BCHG    '
	dc.l	baa
	DW	$ff,%11000000,%10100000
	DW	%00001010,%00000000,%00100000
	dc.b	'BSET    '
	dc.l	baa
	DW	$ff,%11000000,%10100000
	DW	%00001010,%00000000,%00000000
	dc.b	'BCLR    '
	dc.l	baa
	DW	$ff,%11000000,%11100000
	DW	%00001011,%11000000,%01100000
	dc.b	'BTST    '		;BTST	#n,D
	dc.l	nD
	DW	$ff,%11000000,%11100000
	DW	%00001011,%11000000,%01000000
	dc.b	'BCHG    '
	dc.l	nD
	DW	$ff,%11000000,%11100000
	DW	%00001010,%11000000,%01100000
	dc.b	'BSET    '
	dc.l	nD
	DW	$ff,%11000000,%11100000
	DW	%00001010,%11000000,%01000000
	dc.b	'BCLR    '
	dc.l	nD
	DW	$fe,%01000000,%10000000
	DW	%00001000,%01000000,%10000000
	dc.b	'MOVEP   '			;MOVEP	XY:ea,XY:pp
	dc.l	SWMRsp
	DW	$fe,%01000000,%11000000
	DW	%00001000,%01000000,%01000000
	dc.b	'MOVEP   '			;MOVEP	XY:pp,P:ea
	dc.l	SWMRp
	DW	$fe,%01000000,%11000000
	DW	%00001000,%01000000,%00000000
	dc.b	'MOVEP   '			;MOVEP	S,XY:pp
	dc.l	SWDp
	DW	$ff,%01000000,%11000000
	DW	%00000111,%01000000,%10000000
	dc.b	'MOVEM   '			;MOVEM	S,P:ea
	dc.l	WMRd
	DW	$ff,%01000000,%11000000
	DW	%00000111,%00000000,%00000000
	dc.b	'MOVEM   '			;MOVEM	S,P:aa
	dc.l	Waad
	DW	$ff,0,%11110000
	DW	%00000110,0,%10100000
	dc.b	'REP     '			;REP	#xxx
	dc.l	iih	
	DW	$ff,%11000000,$ff
	DW	%00000110,%11000000,%00100000
	dc.b	'REP     '			;REP	S
	dc.l	D_6
	DW	$ff,%11000000,%10111111
	DW	%00000110,%01000000,%00100000
	dc.b	'REP     '			;REP	XY:ea
	dc.l	sea
	DW	$ff,%11000000,%10111111
	DW	%00000110,%00000000,%00100000
	dc.b	'REP     '			;REP	XY:aa
	dc.l	saa
	DW	$ff,0,%11110000
	DW	%00000110,0,%10000000
	dc.b	'DO      '
	dc.l	iih_exp				;DO	#xxx,expr
	DW	$ff,%11000000,$ff
	DW	%00000110,%11000000,0
	dc.b	'DO      '			;DO	S,expr
	dc.l	S_exp
	DW	$ff,%11000000,%10111111
	DW	%00000110,%01000000,0
	dc.b	'DO      '			;DO	XY:ea,expr
	dc.l	ea_exp
	DW	$ff,%11000000,%10111111
	DW	%00000110,%00000000,0
	dc.b	'DO      '			;DO	XY:aa,expr
	dc.l	aa_exp
	DW	$ff,0,%11100000
	DW	%00000101,0,%10100000
	dc.b	'MOVEC   '			;MOVEC	#xx,D
	dc.l	iidd			
	DW	$ff,%01000000,%10100000
	DW	%00000101,%01000000,%00100000
	dc.b	'MOVEC   '			;MOVEC	XY:ea,D
	dc.l	WMRsd			
	DW	$ff,%01000000,%10100000
	DW	%00000101,%00000000,%00100000
	dc.b	'MOVEC   '			;MOVEC	XY:aa,D
	dc.l	Waasd			
	DW	$ff,%01000000,%11100000
	DW	%00000100,%01000000,%10100000
	dc.b	'MOVEC   '			;MOVEC	S1,D2
	dc.l	Wed			
	DW	$ff,%11100000,%11110000
	DW	%00000100,%01000000,%00010000
	dc.b	'LUA     '			;LUA	ea,D
	dc.l	MRd
	DW	$ff,%00001000,%10000000
	DW	%00000011,0,0	
	dc.b	'T       '			;Tcc	S1,D1	S2,D2
	dc.l	CtJDT
	DW	$ff,%00001111,%10000111
	DW	%00000010,%0,%0
	dc.b	'T       '
	dc.l	CJD				;TCC	S1,D1
	DW	$ff,%11111000,%11110111
	DW	%00000001,%11011000,%00010101
	dc.b	'NORM    '			;NORM	Rn,D1
	dc.l	R3d
	DW	$ff,$ff,%11000111
	DW	1,%10000000,%01000000
	dc.b	'DIV     '			;DIV	S,D
	dc.l	JD
	DW	$ff,0,%11111100
	DW	0,0,%11111000
	dc.b	'ORI     '			;ORI	#xx,D
	dc.l	iiEE
	DW	$ff,0,%11111100
	DW	0,0,%10111000
	dc.b	'ANDI    '
	dc.l	iiEE
	DW	$ff,$ff,$ff
	DW	0,0,%10001100
	dc.b	'ENDDO   '
	dc.l	NULL
	DW	$ff,$ff,$ff
	DW	0,0,%10000111
	dc.b	'STOP    '
	dc.l	NULL
	DW	$ff,$ff,$ff
	DW	0,0,%10000110
	dc.b	'WAIT    '
	dc.l	NULL
	DW	$ff,$ff,$ff
	DW	0,0,%10000100
	dc.b	'RESET   '
	dc.l	NULL
	DW	$ff,$ff,$ff
	DW	0,0,%00001100
	dc.b	'RTS     '
	dc.l	NULL
	DW	$ff,$ff,$ff
	DW	0,0,%00000110
	dc.b	'SWI     '
	dc.l	NULL
	DW	$ff,$ff,$ff
	DW	0,0,%0000000
	dc.b	'NOP     '
	dc.l	NULL
END_NP
	
	
	
	
	
	