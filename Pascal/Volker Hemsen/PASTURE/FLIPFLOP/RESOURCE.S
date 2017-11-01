		OPT D+
		GLOBAL RSRC_ADR,RSRC_ANZ
		RSRC_ANZ:
		move.w    #27,d0
		          rts
		RSRC_ADR:
		move.l    (sp)+,a0
		move.w    (sp)+,d0
		asl.w     #2,d0
		move.l    TREES(PC,d0.w),d0
		jmp       (a0)
		TREES:
		dc.l	L2DA
		dc.l	L42A
		dc.l	L472
		dc.l	L4BA
		dc.l	L51A
		;*******************  Objekte  *******************
L2DA:	dc.w	-1,1,13,20,$0,$0
		dc.l	$1100
		dc.w	0,0,44,10
		dc.w	8,2,7,20,$0,$10
		dc.l	$FF1100
		dc.w	2,1,19,5
		dc.w	3,-1,-1,28,$0,$0
		dc.l	L24
		dc.w	1,0,9,1
		dc.w	4,-1,-1,26,$40,$20
		dc.l	L2E
		dc.w	13,0,5,1
		dc.w	5,-1,-1,28,$0,$0
		dc.l	L34
		dc.w	1,2,7,1
		dc.w	6,-1,-1,26,$40,$20
		dc.l	L3C
		dc.w	12,2,6,1
		dc.w	7,-1,-1,28,$0,$0
		dc.l	L43
		dc.w	1,4,7,1
		dc.w	1,-1,-1,26,$40,$20
		dc.l	L4B
		dc.w	11,4,7,1
		dc.w	10,9,9,20,$0,$0
		dc.l	$FF1100
		dc.w	24,1,18,1
		dc.w	8,-1,-1,20,$0,$0
		dc.l	$FF1141
		dc.w	0,0,1,1
		dc.w	11,-1,-1,26,$5,$0
		dc.l	L53
		dc.w	24,4,18,1
		dc.w	12,-1,-1,23,$0,$0
		dc.l	L2CC
		dc.w	2,7,11,3
		dc.w	13,-1,-1,26,$7,$0
		dc.l	L61
		dc.w	33,7,9,2
		dc.w	0,-1,-1,28,$20,$0
		dc.l	L69
		dc.w	14,8,8,2
L42A:	dc.w	-1,1,2,20,$0,$20
		dc.l	$FF1100
		dc.w	0,0,5,2
		dc.w	2,-1,-1,28,$40,$0
		dc.l	L72
		dc.w	0,0,5,1
		dc.w	0,-1,-1,28,$60,$0
		dc.l	L78
		dc.w	0,1,5,1
L472:	dc.w	-1,1,2,20,$0,$20
		dc.l	$FF1100
		dc.w	0,0,6,2
		dc.w	2,-1,-1,28,$40,$0
		dc.l	L7E
		dc.w	0,0,6,1
		dc.w	0,-1,-1,28,$60,$0
		dc.l	L85
		dc.w	0,1,6,1
L4BA:	dc.w	-1,1,3,20,$0,$20
		dc.l	$FF1100
		dc.w	0,0,7,3
		dc.w	2,-1,-1,28,$40,$0
		dc.l	L8C
		dc.w	0,0,7,1
		dc.w	3,-1,-1,28,$40,$0
		dc.l	L94
		dc.w	0,1,7,1
		dc.w	0,-1,-1,28,$60,$0
		dc.l	L9C
		dc.w	0,2,7,1
L51A:	dc.w	-1,1,3,20,$0,$20
		dc.l	$FF1100
		dc.w	0,0,7,3
		dc.w	2,-1,-1,28,$40,$0
		dc.l	LA4
		dc.w	0,0,7,1
		dc.w	3,-1,-1,28,$40,$0
		dc.l	LAC
		dc.w	0,1,7,1
		dc.w	0,-1,-1,28,$60,$0
		dc.l	LB4
		dc.w	0,2,7,1
		;*******************  Strings  *******************
L24:	dc.b	"Laufwerk:",0
L2E:	dc.b	"  A  ",0
L34:	dc.b	"Dichte:",0
L3C:	dc.b	"  DD  ",0
L43:	dc.b	"Format:",0
L4B:	dc.b	"  720  ",0
L53:	dc.b	"formatiere...",0
L61:	dc.b	"Ausgang",0
L69:	dc.b	"VH 07/93",0
L72:	dc.b	"  A  ",0
L78:	dc.b	"  B  ",0
L7E:	dc.b	"  DD  ",0
L85:	dc.b	"  HD  ",0
L8C:	dc.b	"  720  ",0
L94:	dc.b	"  820  ",0
L9C:	dc.b	"  907  ",0
LA4:	dc.b	" 1440  ",0
LAC:	dc.b	" 1560  ",0
LB4:	dc.b	" 1640  ",0
		;*******************  Bitblks  *******************
L2CC:	dc.l	LBC
		dc.w	12,44,0,0,1
		;*******************  Images  *******************
LBC:	dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$7,$FF
		dc.b	$FF,$FF,$FF,$FF,$F8,$0,$0,$0,$0,$E0,$7,$FF,$FF,$FF,$FF
		dc.b	$FF,$F8,$0,$0,$0,$3,$F8,$7,$FF,$FF,$FF,$FF,$FF,$F8,$0
		dc.b	$0,$0,$7,$FC,$7,$FF,$FF,$FF,$FF,$FF,$F8,$0,$0,$0,$7
		dc.b	$FE,$7,$FF,$FF,$FF,$FF,$FF,$F8,$0,$0,$0,$3,$F,$7,$C0
		dc.b	$73,$FF,$FF,$3F,$F8,$0,$0,$0,$0,$7,$7,$C0,$23,$FF,$FE
		dc.b	$3F,$F8,$0,$20,$20,$0,$3,$87,$C6,$33,$83,$C7,$39,$F8
		dc.b	$0,$30,$60,$0,$3,$87,$C0,$73,$33,$3,$30,$F8,$0,$3F,$E0
		dc.b	$0,$3,$87,$C6,$33,$83,$33,$3,$F8,$0,$1F,$E0,$0,$3,$87
		dc.b	$C6,$33,$33,$3F,$7,$F8,$0,$3F,$F0,$0,$3,$87,$C0,$21
		dc.b	$1,$2,$10,$F8,$0,$3F,$F0,$0,$3,$87,$C0,$61,$13,$C6,$10
		dc.b	$F8,$0,$77,$B8,$7C,$7,$87,$FF,$FF,$FF,$FF,$FF,$F8,$0
		dc.b	$73,$38,$FF,$F,$87,$FF,$FF,$FF,$FF,$FF,$F8,$0,$7F,$FF
		dc.b	$FF,$DF,$7,$FF,$FF,$FF,$FF,$FF,$F8,$0,$7F,$FF,$FF,$FF
		dc.b	$7,$FF,$FF,$FF,$FF,$FF,$F8,$0,$3F,$FF,$FF,$FF,$7,$FF
		dc.b	$FF,$FF,$FF,$FF,$F8,$0,$3F,$FF,$FF,$FE,$7,$FF,$F0,$3F
		dc.b	$FF,$FF,$F8,$0,$F,$FF,$FF,$FE,$7,$FF,$E3,$1F,$F3,$FF
		dc.b	$F8,$0,$7,$FF,$FF,$FC,$7,$FF,$C7,$10,$C0,$FF,$F8,$0
		dc.b	$3,$FF,$FF,$FC,$7,$FF,$C7,$B2,$0,$FF,$F8,$0,$3,$FF,$FF
		dc.b	$FC,$7,$FF,$C7,$F0,$33,$FF,$F8,$0,$1,$FF,$FF,$FC,$7
		dc.b	$FF,$C3,$E3,$33,$FF,$F8,$0,$1,$FF,$FF,$FE,$7,$FF,$E0
		dc.b	$20,$30,$FF,$F8,$0,$3,$FF,$FF,$FE,$7,$FF,$F0,$72,$30
		dc.b	$FF,$F8,$0,$3,$FF,$FF,$FE,$7,$FF,$FF,$FF,$FF,$FF,$F8
		dc.b	$0,$3,$FF,$FF,$FE,$7,$FF,$FF,$FF,$FF,$FF,$F8,$0,$F,$FF
		dc.b	$83,$FF,$7,$FF,$FF,$FF,$FF,$FF,$F8,$0,$F,$3F,$83,$FF
		dc.b	$7,$FF,$FF,$FF,$FF,$FF,$F8,$0,$1C,$3F,$3,$EF,$87,$FF
		dc.b	$FF,$FF,$FF,$FF,$F8,$0,$1C,$3F,$3,$E7,$87,$FF,$7,$FF
		dc.b	$8F,$FF,$F8,$0,$38,$1E,$1,$C3,$87,$FC,$33,$FF,$24,$7F
		dc.b	$F8,$0,$38,$1E,$1,$C3,$87,$FC,$3B,$C7,$18,$1F,$F8,$0
		dc.b	$70,$1C,$1,$83,$87,$FE,$7,$11,$C,$7F,$F8,$0,$70,$1C
		dc.b	$1,$83,$87,$FF,$C3,$31,$1C,$7F,$F8,$0,$0,$38,$3,$87
		dc.b	$7,$FC,$E3,$31,$1C,$7F,$F8,$0,$0,$38,$3,$87,$7,$FE,$7
		dc.b	$3,$1E,$1F,$F8,$0,$0,$78,$7,$87,$7,$FF,$FF,$FF,$FF,$FF
		dc.b	$F8,$0,$0,$58,$6,$8D,$7,$FF,$FF,$FF,$FF,$FF,$F8,$0,$0
		dc.b	$0,$0,$0,$7,$FF,$FF,$FF,$FF,$FF,$F8,$0,$0,$0,$0,$0,$7
		dc.b	$FF,$FF,$FF,$FF,$FF,$F8,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
		dc.b	$0,$0,$0
		END


