	text
begin
	movea.l	a7,a5
	movea.l	4(a5),a5
	move.l	12(a5),d0
	add.l	20(a5),d0
	add.l	12(a5),d0
	addi.l	#$200,d0
	move.l	d0,d1
	add.l	a5,d1
	andi.b	#$fe,d1
	lea	l005a(pc),a0
	move.l	d1,(a0)
	movea.l	d1,a7
	move.l	d0,-(a7)
	move.l	a5,-(a7)
	move.l	#$4a0000,-(a7)
	trap	#1
	lea	12(a7),a7
	pea	run_in_super(pc)
	move.w	#$26,-(a7)		;supexec
	trap	#$e
	addq.l	#6,a7
	pea	null(pc)
	move.l	(a7),-(a7)
	pea	link_file(pc)
	pea	$4b0000
	trap	#1
	lea	16(a7),a7
	clr.w	-(a7)		;pterm0
	trap	#1
run_in_super	bsr	intro
	lea	intro_text(pc),a0
	bsr	fade_text
wait_loop	bsr	key_d0
	cmp.b	#$39,d0		;#'9'
	bne.s	wait_loop
	bsr	exit
	bsr	load_link
	rts

intro	dc.w	$a00a
	clr.b	$484.w
	move.w	#1,-(a7)
	pea	$78000
	move.l	(a7),-(a7)
	move.w	#5,-(a7)		;setscreen
	trap	#$e
	lea	12(a7),a7
	lea	$ffff8240.w,a1
	bsr	fade_out
	movem.l	storage(pc),d0-d7
	movem.l	d0-d7,(a1)
	rts

exit	lea	$ffff8246.w,a1
	bsr	fade_out
	clr.w	-(a7)
	pea	$78000
	move.l	(a7),-(a7)
	move.w	#5,-(a7)		;setscreen
	trap	#$e
	lea	12(a7),a7
	rts

vsync	clr.l	$466.w
v_loop	cmp.l	$466.w,d2
	bge.s	v_loop
	rts

fade_text	lea	$ffff8246.w,a1
	bsr	fade_out
	bsr	print_a0
	lea	$ffff8246.w,a1
	bsr	fade_in
	rts

print_a0	pea	(a0)
	move.w	#9,-(a7)		;cconws
	trap	#1
	addq.l	#6,a7
	rts

key_d0	move.w	#7,-(a7)		;crawcin
	trap	#1
	addq.l	#2,a7
	swap	d0
	rts

fade_in	moveq	#0,d0
	moveq	#7,d1
f_in_loop	moveq	#2,d2
	bsr	vsync
	move.w	d0,(a1)
	addi.w	#$111,d0
	dbf	d1,f_in_loop
	rts

fade_out	move.w	#$777,d0
	moveq	#7,d1
f_out_loop	moveq	#2,d2
	bsr	vsync
	move.w	d0,(a1)
	subi.w	#$111,d0
	dbf	d1,f_out_loop
	rts

load_link	lea	load_text(pc),a0
	bsr	print_a0
	lea	$ffff825e.w,a1
	bsr	fade_in
	clr.w	-(a7)
	pea	link_file(pc)
	move.w	#$3d,-(a7)		;fopen
	trap	#1
	addq.l	#8,a7
	lea	l005b(pc),a2
	move.l	d0,8(a2)
	cmpi.l	#$100000,$42e.w
	blt.s	only_half_meg
	lea	file_list(pc),a0
l000e	tst.b	(a0)+
	bne.s	l000e
	addq.l	#5,a0
	move.l	a0,d0
	andi.l	#$fffffffe,d0
	movea.l	d0,a0
	move.l	(a0),12(a2)
	clr.w	-(a7)
	move.w	10(a2),-(a7)
	move.l	12(a2),-(a7)
	move.w	#$42,-(a7)		;fseek
	trap	#1
	lea	10(a7),a7
	pea	$90000
	pea	$fffff
	move.w	10(a2),-(a7)
	move.w	#$3f,-(a7)		;fread
	trap	#1
	lea	12(a7),a7
	not.w	16(a2)
only_half_meg	lea	new_trap1(pc),a0
	move.l	$84.w,old_trap1
	move.l	$84.w,$94.w
	move.l	a0,$84.w
	lea	new_trap_5(pc),a0
	move.l	a0,$90.w
	rts

new_trap_5	bsr	depack_atm5
	lea	-4(a7),a7
	move.w	4(a7),(a7)
	lea	l0011(pc),a0
	move.l	a0,2(a7)
	lea	6(a7),a0
	rte

l0011	lea	$77ff4,a7
	move.l	(a0),(a7)
	clr.l	4(a7)
	move.l	8(a0),8(a7)
	rts

new_trap1	movem.l	a0-a3/d0,-(a7)
	lea	26(a7),a1
	dc.b	8,'/',0,$d,0,$14
	bne.s	l0013
	move	usp,a1
l0013	cmpi.w	#$3d,(a1)
	bne	ram_fread
	movea.l	2(a1),a0
	movea.l	a0,a1
l0014	tst.b	(a0)+
	bne.s	l0014
l0015	cmpi.b	#$5c,-(a0)
	beq.s	l0016
	cmpi.b	#$3a,(a0)
	beq.s	l0016
	cmpa.l	a0,a1
	ble.s	l0015
l0016	addq.l	#1,a0
	movea.l	a0,a1
	lea	file_list(pc),a2
	lea	null(pc),a3
l0017	move.b	(a0)+,d0
	bne.s	l0018
	tst.b	(a2)
	beq.s	l001b
	bra.s	l001a
l0018	cmp.b	#$61,d0		;#'a'
	blt.s	l0019
	cmp.b	#$7a,d0		;#'z'
	bgt.s	l0019
	andi.b	#$5f,d0
l0019	cmp.b	(a2)+,d0
	beq.s	l0017
l001a	tst.b	(a2)+
	bne.s	l001a
	move.l	a2,d0
	addi.l	#9,d0
	andi.l	#$fffffffe,d0
	movea.l	d0,a2
	movea.l	a1,a0
	cmpa.l	a2,a3
	bgt.s	l0017
	bra.s	l001f
l001b	move.l	a2,d0
	addq.l	#2,d0
	andi.l	#$fffffffe,d0
	movea.l	d0,a0
	lea	l005b(pc),a2
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a2)+,(a7)
l001c	movem.l	(a7)+,a0-a3/d0
	rte

l001d	cmpi.w	#$3e,(a1)
	bne.s	l001f
	move.w	l005c(pc),d0
	cmp.w	2(a1),d0
	bne.s	l001f
	clr.l	(a7)
	bra.s	l001c
ram_fread	cmpi.w	#$3f,(a1)
	bne.s	l001d
	lea	l005b(pc),a2
	move.w	10(a2),d0
	cmp.w	2(a1),d0
	bne.s	l001f
	tst.w	16(a2)
	bne.s	get_from_ram
	clr.w	-(a7)
	move.w	10(a2),-(a7)
	move.l	(a2)+,-(a7)
	move.w	#$42,-(a7)
	trap	#5
	lea	10(a7),a7
	subq.l	#2,22(a7)
	lea	another_trap1(pc),a0
	move.l	a0,$84.w
	move.l	(a2)+,4(a1)
	lea	l0022(pc),a0
	move.l	8(a1),(a0)
l001f	movem.l	(a7)+,a0-a3/d0
	jmp	0.l
old_trap1	equ	*-4
another_trap1	pea	(a0)
	lea	0.l,a0
l0022	equ	*-4
	bsr	depack_atm5
	lea	new_trap1(pc),a0
	move.l	a0,$84.w
	movea.l	(a7)+,a0
	rte

get_from_ram	lea	$90000,a3
	adda.l	(a2),a3
	suba.l	12(a2),a3
	move.l	4(a2),d0
	move.l	d0,(a7)
	movea.l	8(a1),a1
	movea.l	a1,a0
ram_mover	move.b	(a3)+,(a1)+
	subq.l	#1,d0
	bne.s	ram_mover
	move.l	(a7),d0
	bsr	depack_atm5
	move.l	d0,(a7)
	bra	l001c
depack_atm5	movem.l	a0-a6/d0-d7,-(a7)
	cmpi.l	#$41544d35,(a0)+
	bne	l0053
	move.l	(a0),(a7)
	link	a2,#$ffe4
	move.l	(a0)+,d0
	lea	4(a0,d0.l),a5
	move.l	d0,-(a7)
	movea.l	a5,a4
	lea	256(a4),a5
	lea	-12(a4),a4
	move.l	(a0)+,d0
	movea.l	a0,a6
	adda.l	d0,a6
	clr.w	-2(a2)
	subq.w	#1,a6
	lea	storage(pc),a3
	move.w	-2(a2),d0
	lsl.w	#2,d0
	addi.w	#$10c,d0
	bra.s	l0027
l0026	move.b	(a4)+,(a3)+
	subq.w	#1,d0
l0027	bne.s	l0026
	movem.l	a3-a4,-(a7)
	move.b	-(a6),d7
	bra	l0047
l0028	move.w	d3,d5
l0029	add.b	d7,d7
l002a	dbcs	d5,l0029
	beq.s	l002d
	bcc.s	l002b
	sub.w	d3,d5
	neg.w	d5
	bra.s	l0030
l002b	moveq	#3,d6
	bsr.s	l0036
	beq.s	l002c
	bra.s	l002f
l002c	moveq	#7,d6
	bsr.s	l0036
	beq.s	l002e
	addi.w	#$f,d5
	bra.s	l002f
l002d	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	l002a
l002e	moveq	#$d,d6
	bsr.s	l0036
	addi.w	#$10e,d5
l002f	add.w	d3,d5
l0030	lea	l0054(pc),a4
	move.w	d5,d2
	bne.s	l003a
	add.b	d7,d7
	bne.s	l0031
	move.b	-(a6),d7
	addx.b	d7,d7
l0031	bcs.s	l0032
	moveq	#1,d6
	bra.s	l003b
l0032	moveq	#3,d6
	bsr.s	l0036
	tst.b	-28(a2)
	beq.s	l0033
	move.b	-18(a2,d5.w),-(a5)
	bra	l0046
l0033	move.b	(a5),d0
	btst	#3,d5
	bne.s	l0034
	bra.s	l0035
l0034	addi.b	#$f0,d5
l0035	sub.b	d5,d0
	move.b	d0,-(a5)
	bra	l0046
l0036	clr.w	d5
l0037	add.b	d7,d7
	beq.s	l0039
l0038	addx.w	d5,d5
	dbf	d6,l0037
	tst.w	d5
	rts

l0039	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	l0038
l003a	moveq	#2,d6
l003b	bsr.s	l0036
	move.w	d5,d4
	move.b	14(a4,d4.w),d6
	ext.w	d6
	tst.b	-27(a2)
	bne.s	l003c
	addq.w	#4,d6
	bra.s	l0040
l003c	bsr.s	l0036
	move.w	d5,d1
	lsl.w	#4,d1
	moveq	#2,d6
	bsr.s	l0036
	cmp.b	#7,d5
	blt.s	l003e
	moveq	#0,d6
	bsr.s	l0036
	beq.s	l003d
	moveq	#2,d6
	bsr.s	l0036
	add.w	d5,d5
	or.w	d1,d5
	bra.s	l0041
l003d	or.b	-26(a2),d1
	bra.s	l003f
l003e	or.b	-25(a2,d5.w),d1
l003f	move.w	d1,d5
	bra.s	l0041
l0040	bsr.s	l0036
l0041	add.w	d4,d4
	beq.s	l0042
	add.w	-2(a4,d4.w),d5
l0042	lea	1(a5,d5.w),a4
	move.b	-(a4),-(a5)
l0043	move.b	-(a4),-(a5)
	dbf	d2,l0043
	bra.s	l0046
l0044	add.b	d7,d7
	bne.s	l0045
	move.b	-(a6),d7
	addx.b	d7,d7
l0045	bcs.s	l004f
	move.b	-(a6),-(a5)
l0046	cmpa.l	a5,a3
	bne.s	l0044
	cmpa.l	a6,a0
	beq.s	l0050
l0047	moveq	#0,d6
	bsr	l0036
	beq.s	l004a
	move.b	-(a6),d0
	lea	-26(a2),a1
	move.b	d0,(a1)+
	moveq	#1,d1
	moveq	#6,d2
l0048	cmp.b	d0,d1
	bne.s	l0049
	addq.w	#2,d1
l0049	move.b	d1,(a1)+
	addq.w	#2,d1
	dbf	d2,l0048
	st	-27(a2)
	bra.s	l004b
l004a	sf	-27(a2)
l004b	moveq	#0,d6
	bsr	l0036
	beq.s	l004d
	lea	-18(a2),a1
	moveq	#$f,d0
l004c	move.b	-(a6),(a1)+
	dbf	d0,l004c
	st	-28(a2)
	bra.s	l004e
l004d	sf	-28(a2)
l004e	clr.w	d3
	move.b	-(a6),d3
	move.b	-(a6),d0
	lsl.w	#8,d0
	move.b	-(a6),d0
	movea.l	a5,a3
	suba.w	d0,a3
	bra.s	l0044
l004f	bra	l0028
l0050	movem.l	(a7)+,a3-a4
	move.l	(a7)+,d0
	bsr	l0055
	move.w	-2(a2),d0
	lsl.w	#2,d0
	addi.w	#$10c,d0
	bra.s	l0052
l0051	move.b	-(a3),-(a4)
	subq.w	#1,d0
l0052	bne.s	l0051
	unlk	a2
l0053	movem.l	(a7)+,a0-a6/d0-d7
	rts

l0054	dc.b	0,' ',0,'`',1,'`',3,'`'
	dc.b	7,'`',$f,'`',$1f,'`',0,1
	dc.b	3,4,5,6,7,8
l0055	lsr.l	#4,d0
	lea	-12(a6),a6
l0056	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	dbf	d0,l0056
	rts

storage	dcb.w	206
load_text	dc.b	27,'E',27,'Y,/Please Wait'
intro_text	dc.b	27,'E',27,'Y(                               THE REPLICANTS PRESENT',10,13
	dc.b	10,13
	dc.b	'                                  >>> CAESAR <<<',10,13
	dc.b	10,13
	dc.b	'                        PACKED,LINKED & RAMDISKED BY ORION',10,13
	dc.b	10,13
	dc.b	'                           ORIGINAL SUPPLIED BY ELLFIRE',10,13
	dc.b	10,13
	dc.b	'                              BASH SPACE TO CONTINUE',10,13
	dc.b	0
l005a	dc.l	0
l005b	dc.l	0
	dc.l	0
	dc.l	0
l005c	equ	*-2
	dc.l	0
	dc.w	0
file_list	dc.b	'CAESAR.PRG',0,0
	dc.l	0,71550
	dc.b	'CAESWA16.APX',0
	dc.l	71550,22890
	dc.b	'C_VITAE.APX'
	dc.l	94440,3428
	dc.b	'DEMOL.FX',0
	dc.l	97868,6036
	dc.b	'EMAP1.APX'
	dc.l	103904,21306
	dc.b	'EMPIRE2.000'
	dc.l	125210,902
	dc.b	'EMPIRE2.001'
	dc.l	126112,948
	dc.b	'EMPIRE2.002'
	dc.l	127060,1034
	dc.b	'EMPIRE2.003'
	dc.l	128094,1192
	dc.b	'EMPIRE2.004'
	dc.l	129286,896
	dc.b	'EMPIRE2.005'
	dc.l	130182,888
	dc.b	'EMPIRE2.006'
	dc.l	131070,1114
	dc.b	'EMPIRE2.007'
	dc.l	132184,1190
	dc.b	'EMPIRE2.008'
	dc.l	133374,1196
	dc.b	'EMPIRE2.009'
	dc.l	134570,1090
	dc.b	'EMPIRE2.010'
	dc.l	135660,1092
	dc.b	'EMPIRE2.011'
	dc.l	136752,1074
	dc.b	'EMPIRE2.012'
	dc.l	137826,1068
	dc.b	'EMPIRE2.013'
	dc.l	138894,1070
	dc.b	'EMPIRE2.014'
	dc.l	139964,1182
	dc.b	'EMPIRE2.015'
	dc.l	141146,1006
	dc.b	'EMPIRE2.016'
	dc.l	142152,1048
	dc.b	'EMPIRE2.017'
	dc.l	143200,1132
	dc.b	'EMPIRE2.018'
	dc.l	144332,1148
	dc.b	'EMPIRE2.019'
	dc.l	145480,1130
	dc.b	'EMPIRE2.020'
	dc.l	146610,1036
	dc.b	'EMPIRE2.021'
	dc.l	147646,1054
	dc.b	'EMPIRE2.022'
	dc.l	148700,1088
	dc.b	'EMPIRE2.023'
	dc.l	149788,1154
	dc.b	'EMPIRE2.024'
	dc.l	150942,1102
	dc.b	'EMPIRE2.025'
	dc.l	152044,1024
	dc.b	'EMPIRE2.026'
	dc.l	153068,1132
	dc.b	'EMPIRE2.027'
	dc.l	154200,1122
	dc.b	'EMPIRE2.028'
	dc.l	155322,1134
	dc.b	'EMPIRE2.029'
	dc.l	156456,1094
	dc.b	'EMPIRE2.030'
	dc.l	157550,1110
	dc.b	'EMPIRE2.031'
	dc.l	158660,1066
	dc.b	'EMPIRE2.032'
	dc.l	159726,812
	dc.b	'EMPIRE2.033'
	dc.l	160538,1110
	dc.b	'EMPIRE2.034'
	dc.l	161648,1050
	dc.b	'EMPIRE2.035'
	dc.l	162698,1120
	dc.b	'EMPIRE2.036'
	dc.l	163818,1028
	dc.b	'EMPIRE2.037'
	dc.l	164846,1094
	dc.b	'EMPIRE2.038'
	dc.l	165940,1180
	dc.b	'EMPIRE2.039'
	dc.l	167120,1066
	dc.b	'EMPIRE2.040'
	dc.l	168186,1004
	dc.b	'EMPIRE2.041'
	dc.l	169190,1040
	dc.b	'EMPIRE2.042'
	dc.l	170230,984
	dc.b	'EMPIRE2.043'
	dc.l	171214,1022
	dc.b	'EMPIRE2.044'
	dc.l	172236,1128
	dc.b	'EMPIRE2.045'
	dc.l	173364,1060
	dc.b	'EMPIRE2.046'
	dc.l	174424,1062
	dc.b	'EMPIRE2.047'
	dc.l	175486,1044
	dc.b	'EMPIRE2.048'
	dc.l	176530,1042
	dc.b	'EMPIRE2.049'
	dc.l	177572,1042
	dc.b	'FANFARE.FX',0
	dc.l	178614,5722
	dc.b	'FIRE.FX'
	dc.l	184336,5700
	dc.b	'FIXT3.PL4'
	dc.l	190036,8116
	dc.b	'FIXTS.PL4'
	dc.l	198152,13574
	dc.b	'FORUM16.APX'
	dc.l	211726,20066
	dc.b	'HOUSES.PL4',0
	dc.l	231792,17704
	dc.b	'HOUSES2.PL4'
	dc.l	249496,8824
	dc.b	'IMP_LOGO.APX',0
	dc.l	258320,1498
	dc.b	'LOGO.APX',0
	dc.l	259818,3086
	dc.b	'LOSPIC16.APX',0
	dc.l	262904,15926
	dc.b	'MOREMEN.PL4'
	dc.l	278830,4284
	dc.b	'RESPONSE.FX'
	dc.l	283114,700
	dc.b	'SPRITE2.PL4'
	dc.l	283814,2732
	dc.b	'SWORD.FX',0
	dc.l	286546,1732
	dc.b	'TEMPLE.APX',0
	dc.l	288278,5546
	dc.b	'TEXT_CSR.FRE',0
	dc.l	293824,3138
	dc.b	'TEXT_CSR.GER',0
	dc.l	296962,3172
	dc.b	'TITLE16.APX'
	dc.l	300134,16424
	dc.b	'WAR_CRY.FX',0
	dc.l	316558,5234
	dc.b	'WATER.FX',0
	dc.l	321792,2804
	dc.b	'WINPIC16.APX',0
	dc.l	324596,21878
	dc.l	0
null	dc.l	0
link_file	dc.b	'caesar.lnk'
	dc.b	0,$90
zuend	end
