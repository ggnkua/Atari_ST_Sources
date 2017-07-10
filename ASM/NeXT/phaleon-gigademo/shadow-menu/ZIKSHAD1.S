	include notes.s
	include	playrout.s

data_lap_musix
WC:	dc.w	table_offset_adr_son-wc
	dc.w	partition_pattern-wc
	dc.w	(dz-debut)/12
	dc.w	((fz-debut)/12)-1
	dc.w	(dz-debut)/12+8
	dc.w	32
	dc.w	7
	DC.W	MESURE-WC
	dc.w	0
	dc.b	'(c) LARY' 
	
table_offset_adr_son
	dc.w	son0-TABLE_OFFSET_ADR_SON
	dc.w	son1-TABLE_OFFSET_ADR_SON
	dc.w	son2-TABLE_OFFSET_ADR_SON
	dc.w	son3-TABLE_OFFSET_ADR_SON
	dc.w	son4-TABLE_OFFSET_ADR_SON
	dc.w	son5-TABLE_OFFSET_ADR_SON
	dc.w	son8-TABLE_OFFSET_ADR_SON
	even
son0	dc.b	$ff,0	
son1	dc.b	$f0,11,$f2,02,$f0,0,$ff,0	,charle
SON2	DC.B	$F0,$0E,$F2,13,01	;GROSSE CAISSE 2
	DC.B	$FE,$99,$FE,$98
	DC.B	$FE,$96,$FE,$92,$FE,$8A
	DC.B	$Fe,0,$fd,14,1,$FF,0
SON3	DC.B	$F0,$0E,$F2,$00,$01	;CAISSE CLAIRE 2
	DC.B	$FE,$9E,$FE,$A0
	DC.B	$F2,$02,01
	DC.B	$F0,$0D,$FE,$9E
	DC.B	$F0,$0C,$FE,$A0
	DC.B	$Fe,0,$fd,14,1,$FF
SON4	DC.B	1,$F0,14,$F3,2
	DC.B	$F0,13,$F3,2
	DC.B	$F0,12,$F4,2
	DC.B	$F0,11,$F4,2
	DC.B	$F0,10,$F3,2,$F3,2,$F4,2,$F4,2,$FF
son5	DC.B	1,$F0,14,$F5,12,$F0,13,$F5,0
	DC.B	0,0,0,0,$F0,12,0,0,0,0
	DC.B	$F3,1,$F3,2,$F3,1,$F4,1,$F4,2,$F4,1,$F6,12
son6	dc.b 	$fd,14,1,3,1,$f6,2
son7	dc.b	$f0,13,$f2,0,$f0,12,0,$f0,11,0,$f0,10,0,$f0,6,0,$f0,0,1,$ff
son8 dc.b $f0,11,$f3,4,$f6,2
son9 dc.b $f1,0,1,$f4,2,$f6,2,$ff
sona dc.b 01,$e0,01,3,$ff,0

hh = 1
bdm = 2
sdm = 3
acc = 4
mel = 5
down = 6

	EVEN

partition_pattern
debut
DZ
	DC.W	$100,0,$300,0,$500,0
	DC.W	$100,0,$400,0,$500,0
	DC.W	$107,0,$700,0,$600,0
	DC.W	$107,0,$1100,0,$600,0
	DC.W	$100,0,$300,0,$500,0
	DC.W	$100,0,$400,0,$500,0
	DC.W	$107,0,$700,0,$600,0
	DC.W	$807,0,$1100,0,$600,0
	DC.W	$200,0,$900,0,$500,0
	DC.W	$200,0,$A00,0,$500,0
	DC.W	$207,0,$B00,0,$600,0
	DC.W	$207,0,$C00,0,$600,0
	DC.W	$200,0,$900,0,$500,0
	DC.W	$200,0,$A00,0,$500,0
	DC.W	$207,0,$B00,0,$600,0
	DC.W	$207,0,$B00,0,$600,0
	DC.W	$20A,0,$D00,0,$1000,0
	DC.W	$20A,0,$D00,0,$1000,0
	DC.W	$208,0,$D00,0,$10FE,0	
	DC.W	$208,0,$D00,0,$10FE,0
	DC.W	$207,0,$E00,0,$10FD,0	
	DC.W	$207,0,$F00,0,$10FD,0
FZ
	EVEN

MESURE
P0	DC.W	0,0,0,0
	DC.W	0,0,0,0
	DC.W	0,0,0,0
	DC.W	0,0,0,0
P1	DC.W	fa1+bdm,0,0,0
	DC.W	fa1+bdm,0,0,0
	DC.W	fa1+bdm,0,0,0
	DC.W	fa1+bdm,0,0,0
P2	DC.W	fa1+bdm,0,0,0
	DC.W	fa1+sdm,0,0,0
	DC.W	fa1+bdm,0,0,0
	DC.W	fa1+sdm,0,0,fa1+bdm
P3	DC.W	fa4+mel,0,0,0
	DC.W	do4+mel,0,0,0
	DC.W	sib3+mel,0,0,0
	DC.W	do4+mel,0,0,0
P4	DC.W	fa4+mel,0,0,0
	DC.W	do4+mel,0,0,0
	DC.W	sib3+mel,0,0,0
	DC.W	lab3+mel,0,0,0
P5	DC.W	fa3+acc,0,lab3+acc,0
	DC.W	fa3+acc,0,do4+acc,0
	DC.W	fa3+acc,0,lab3+acc,0
	DC.W	fa3+acc,0,do4+acc,0
P6	DC.W	do3+acc,0,sol3+acc,0
	DC.W	mib3+acc,0,do4+acc,0
	DC.W	do3+acc,0,sol3+acc,0
	DC.W	mib3+acc,0,do4+acc,0
P7	DC.W	do3+mel,0,0,0
	DC.W	0,0,0,0
	DC.W	0,0,0,0
	DC.W	0,0,0,0
P8	DC.W	fa1+bdm,0,0,0
	DC.W	fa1+bdm,0,0,0
	DC.W	fa1+bdm,0,0,0
	DC.W	fa1+bdm,fa1+sdm,0,fa1+sdm
P9	DC.W	fa4+mel,0,do4+mel,0
	DC.W	sib3+mel,0,do4+mel,sib3+mel
	DC.W	0,0,lab3+mel,0
	DC.W	0,0,0,0
PA	DC.W	fa4+mel,0,do4+mel,0
	DC.W	sib3+mel,0,do4+mel,sib3+mel
	DC.W	0,0,lab3+mel,0
	DC.W	sol3+mel,0,fa3+mel,0
PB	DC.W	sol3+mel,0,lab3+mel,0
	DC.W	sol3+mel,0,lab3+mel,sol3+mel
	DC.W	0,0,do3+mel,0
	DC.W	reb3+mel,0,do3+mel,0	
PC	DC.W	sol3+mel,0,lab3+mel,0
	DC.W	sol3+mel,0,lab3+mel,sol3+mel
	DC.W	0,0,do3+mel,0
	DC.W	mib4+mel,0,do4+mel,0
PD	DC.W	sol3+mel,0,lab3+mel,0
	DC.W	sol3+mel,0,lab3+mel,sol3+mel
	DC.W	0,0,fa3+mel,0
	DC.W	mib3+mel,0,fa3+mel,0
PE	DC.W	sol3+mel,0,lab3+mel,0
	DC.W	sol3+mel,0,lab3+mel,sol3+mel
	DC.W	0,0,fa3+mel,0
	DC.W	mi3+mel,0,fa3+mel,0
PF	DC.W	sol3+mel,0,lab3+mel,0
	DC.W	sol3+mel,0,lab3+mel,sol3+mel
	DC.W	0,0,do3+mel,0
	DC.W	mib4+mel,0,do4+mel,0
P10	DC.W	mib3+acc,0,sib3+acc,0
	DC.W	mib3+acc,0,mib4+acc,0
	DC.W	mib3+acc,0,sib3+acc,0
	DC.W	mib3+acc,0,mib4+acc,0
P11	DC.W	0,0,0,0
	DC.W	0,0,0,0
	DC.W	do3+down,0,0,0
	DC.W	0,0,0,0
lapend
	end
