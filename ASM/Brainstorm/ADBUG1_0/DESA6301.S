* disassembler for keyboard chip's ROM!!

	output	.ro

IKBD_ACCESS	=	1
REAL_TIME	=	1

start:	dc.w	$a00a
	move.l	$ffff8240.w,sav_col
	move.l	#$777,$ffff8240.w
	lea	rez(pc),a0
	move.b	d0,(a0)
	lea	text(pc),a5
	bsr	print
	move	#3,-(a7)
	trap	#14
	addq	#2,a7
	lea	scrnptr(pc),a0
	move.l	d0,(a0)
	move	#34,-(a7)
	trap	#14
	addq	#2,a7
	move.l	d0,a0
	move.l	a0,savea
	lea	intrpt(pc),a1
	lea	save(pc),a3
	move.l	12(a0),(a3)
	move.l	a1,12(a0)
	move	#$a0d,cr
	lea	anfang(pc),a4
	move.b	#22,(a4)

	IFEQ	REAL_TIME
init:	lea	flag(pc),a4
	lea	daten(pc),a5
	lea	buffer(pc),a6
	move	#($10000/6),d6
	moveq	#0,d7
.fill	move	d7,adresse
.loop	sf	(a4)
	pea	send(pc)
	pea	$190002
	trap	#14
	addq	#8,a7
.wait	move.b	(a4),d0
	beq.s	.wait
	cmp.b	#$20,d0
	bne.s	.loop
	move.l	(a5),(a6,d7.l)
	move	4(a5),4(a6,d7.l)
	addq.l	#6,d7
	dbf	d6,.fill
	move	#$f000,adresse
	ENDC

loop:
	IFNE	REAL_TIME
	lea	flag(pc),a4
.loop	sf	(a4)
	pea	send(pc)
	pea	$190002
	trap	#14
	addq	#8,a7
.wait	move.b	(a4),d0
	beq.s	.wait
	cmp.b	#$20,d0
	bne.s	.loop
	ENDC	

	lea	string(pc),a0
	moveq	#32,d0
blanks:	move	#'  ',(a0,d0)
	subq.b	#2,d0
	bpl.s	blanks
	moveq	#':',d0
	move.b	d0,5(a0)
	move.b	d0,16(a0)
	moveq	#0,d6
	moveq	#0,d0
	lea	adresse(pc),a1
	move	(a1),d0
	move.b	(a1)+,d7
	bsr	convert
	move.b	(a1),d7
	bsr	convert

	IFNE	REAL_TIME
	lea	daten(pc),a6
	ELSEIF
	lea	buffer(pc),a6
	add.l	d0,a6
	ENDC
	moveq	#0,d0
	move.b	(a6),d0
	move.b	d0,d7
	moveq	#7,d6
	bsr	convert
	move	d0,d1
	move	d0,d2
	lsr	#2,d1
	lea	len(pc),a1
	move.b	(a1,d1),d1
	and.b	#3,d2
	add.b	d2,d2
	lsr.b	d2,d1
	and.b	#3,d1
	lea	anzahl(pc),a4
	move.b	d1,(a4)
	cmpi.b	#$1f,d0
	bls.s	no_bra
	cmpi.b	#$30,d0
	bls.s	is_bra
	cmpi.b	#$8d,d0
	bne.s	no_bra
is_bra:	st	branch_flag
	move.b	1(a6),d1
	ext	d1
	move	adresse(pc),d2
	add	d1,d2
	addq	#2,d2
	move.b	d2,d7
	moveq	#28,d6
	bsr	convert
	lsr	#8,d2
	move.b	d2,d7
	moveq	#26,d6
	bsr	convert
	bra	not_aim
no_bra:	cmpi.b	#$cd,d0
	beq	no_out
	move.b	d0,d1
	and.b	#$f0,d1
	cmpi.b	#$80,d1
	beq.s	file
	cmpi.b	#$c0,d1
	bne.s	no_imm
	move.b	d0,d1
	moveq	#7,d2
	and.b	d2,d1
	sub.b	d2,d1
	beq	no_out
file:	move	#'#$',24(a0)
	bra	not_aim
no_imm:	cmpi.b	#$90,d1
	beq.s	zero
	cmpi.b	#$d0,d1
	bne.s	no_zero
zero:	move.l	#' $00',24(a0)
	lea	zerflag(pc),a5
	st	(a5)
	bra	not_aim
no_zero:	cmpi.b	#$a0,d1
	beq.s	index
	cmpi.b	#$e0,d1
	beq.s	index
	cmpi.b	#$60,d1
	bne.s	no_indx
index:	move	#',X',28(a0)
no_indx:	move.b	d0,d1
	or.b	#$1f,d1
	cmpi.b	#$7f,d1
	bne.s	not_aim
	move.b	d0,d1
	and.b	#$f,d1
	cmpi.b	#1,d1
	beq.s	aim
	cmpi.b	#2,d1
	beq.s	aim
	cmpi.b	#5,d1
	beq.s	aim
	cmpi.b	#$b,d1
	bne.s	not_aim
aim:	move	#'#$',24(a0)
	moveq	#26,d6
	move.b	1(a6),d7
	bsr	convert
	moveq	#10,d6
	move.b	1(a6),d7
	bsr	convert
	moveq	#13,d6
	move.b	2(a6),d7
	bsr	convert
	cmpi.b	#$71,d0
	beq.s	aim1
	cmpi.b	#$72,d0
	beq.s	aim1
	cmpi.b	#$75,d0
	beq.s	aim1
	cmpi.b	#$7b,d0
	bne.s	no_aim1
aim1:	move.l	#',$00',28(a0)
	moveq	#32,d6
	bra.s	add
no_aim1:	moveq	#',',d6
	move	#',$',28(a0)
	move	#'+X',32(a0)
	moveq	#30,d6
	bra.s	add
not_aim:	move.b	anzahl(pc),d5
	subq.b	#1,d5
	beq.s	no_out
	moveq	#10,d6
	move.b	1(a6),d7
	bsr	convert
	move.b	#'$',25(a0)
	tst.b	branch_flag
	bne.s	no_out
	lea	zerflag(pc),a1
	tst.b	(a1)
	bmi.s	itszero
	moveq	#26,d6
	bra.s	ok
itszero:	moveq	#28,d6
	sf	(a1)
ok:	move.b	1(a6),d7
	bsr	convert
	subq.b	#1,d5
	beq.s	no_out
	moveq	#13,d6
	move.b	2(a6),d7
	bsr	convert
	moveq	#28,d6
add:	move.b	2(a6),d7
	bsr	convert
no_out:	sf	branch_flag
	lea	codes(pc),a1
	add	d0,d0
	add	d0,d0
	move.l	(a1,d0),18(a0)
	lea	string(pc),a5
	bsr	print
	lea	adresse(pc),a0
	move.b	anzahl(pc),d0
	ext	d0
	add	d0,(a0)
	lea	anfang(pc),a0
	tst.b	(a0)
	beq.s	weiter
	subq.b	#1,(a0)
	bne	loop
	lea	cr(pc),a4
	clr	(a4)
	bra	loop
weiter:	bsr	get_key
	cmpi.b	#$1b,d0
	beq.s	neuadr
	swap	d0
	cmpi.b	#$50,d0
	bne.s	weiter
allrght:	bsr	scroll
	lea	zeile(pc),a5
	bsr	print
	bra	loop
neuadr:	lea	adr_txt(pc),a5
	bsr	print
	moveq	#0,d7
	lea	inp_txt(pc),a3
	move.l	#'0000',(a3)
	bra.s	eingabe
back:	tst.b	d7
	beq.s	eingabe
	move.b	#'0',-(a3)
	subq.l	#1,d7
	lea	back_sp(pc),a5
	bsr	print
eingabe:	bsr	get_key
	swap	d0
	cmpi.b	#$61,d0
	bne.s	no_undo
	lea	adr_weg(pc),a5
	bsr	print
	bra.s	weiter
no_undo:	swap	d0
	tst.b	d7
	bne.s	no_end
	cmpi.b	#27,d0
	beq	ende
no_end:	cmpi.b	#8,d0
	beq.s	back
	cmpi.b	#13,d0
	bne.s	.not_ret
	bra.s	edit
.not_ret	cmpi.b	#4,d7
	beq.s	eingabe
get_keyen:	cmpi.b	#'0',d0
	bcs.s	eingabe
	cmpi.b	#'9',d0
	bls.s	eing_ok
	and.b	#$df,d0
	cmpi.b	#'A',d0
	bcs.s	eingabe
	cmpi.b	#'F',d0
	bhi.s	eingabe
eing_ok:	addq	#1,d7
	move.b	d0,(a3)+
	move	d0,-(a7)
	pea	$30005
	trap	#13
	addq	#6,a7
	bra.s	eingabe

edit:	lea	adr_weg(pc),a5
	bsr.s	print
	subq	#4,d7
	neg	d7
	lsl	#3,d7
	move.l	inp_txt,d0
	ror.l	d7,d0
	moveq	#0,d1
	moveq	#3,d2
new_adr:	rol.l	#8,d0
	sub.b	#'0',d0
	cmpi.b	#9,d0
	bls.s	.digit
	subq.b	#7,d0
.digit	lsl	#4,d1
	add.b	d0,d1
	dbf	d2,new_adr
	move	d1,undo
	move	d1,adresse
	bsr.s	scroll
	bsr	clear
	bra	allrght

ende:	move.l	savea(pc),a0
	move.l	save(pc),12(a0)
	lea	quit(pc),a5
	bsr.s	print

fin:	move.l	sav_col,$ffff8240.w
	dc.w	$a009
	rts

get_key:	move	#7,-(a7)
	trap	#1
	addq	#2,a7
	rts


print:	move.l	a5,-(a7)
	move	#9,-(a7)
	trap	#1
	addq	#6,a7
	rts

convert:	moveq	#1,d4
.loop	rol.b	#4,d7
	move.b	d7,d3
	and.b	#$f,d3
	add.b	#'0',d3
	cmpi.b	#'9',d3
	bls.s	.digit
	addq.b	#7,d3
.digit	move.b	d3,(a0,d6)
	addq.b	#1,d6
	dbf	d4,.loop
	rts

scroll:	move.l	scrnptr(pc),a0
	lea	$500(a0),a0
	move	#175,d0
	moveq	#88,d3
	move.b	rez(pc),d1
	and	#1,d1
	bne.s	.loop1
	add	#176,d0
	moveq	#44,d3
.loop0	move	d1,d2
.loop1	movem.l	$500(a0),d4-d7/a2-a6
	movem.l	d4-d7/a2-a6,(a0)
	lea	36(a0),a0
	dbf	d2,.loop1
	add	d3,a0
	dbf	d0,.loop0
	rts

clear:	moveq	#0,d4
	moveq	#7,d0
	tst	d1
	bne.s	.loop0
	addq	#8,d0
.loop0	move	d1,d2
.loop1	rept	9
	move.l	d4,(a0)+
	endr
	dbf	d2,.loop1
	add	d3,a0
	dbf	d0,.loop0
	rts

intrpt:	moveq	#6,d0
	lea	flag(pc),a1
repeat:	move.b	(a0)+,(a1)+
	dbf	d0,repeat
	rts

	data
text:	dc.b	$1b,'Y  ',$1b,'J',$1b,'v',$1b,'f',$1b,'p'
	dc.b	'  HITACHI HD6301V1 Micro Processing Unit Disasembler             06 April 1990  '
	dc.b	$1b,'j',$1b,'w',$1b,'Y8 '
	dc.b	'  [ESC] New Address                                         [ESC] - [ESC] Quit  '
	dc.b	$1b,'q'
	dc.b	$1b,'Y$N0000..001F : Internal Registers'
	dc.b	$1b,'Y%N0080..00FF : Internal Ram'
	dc.b	$1b,'Y&NF000..FFFF : Internal Rom'
	dc.b	$1b,'k',0
zeile:	dc.b	$1b,'Y7 ',0
adr_txt:	dc.b	$1b,'p',$1b,'Y86'
	dc.b	'($0000-$FFFF) $____ [UNDO]=Abort'
	dc.b	$1b,'Y8E',$1b,'e',0
back_sp:	dc.b	$1b,'D_',$1b,'D',0
adr_weg:	dc.b	$1b,'f',$1b,'Y86'
	dc.b	'                                '
quit:	dc.b	$1b,'q'

	even
	dc.b	0
send:	dc.b	$21
adresse:	dc.w	$f000
codes:	dc.b	'??? NOP ??? ??? LSRDASLDTAP TPA '
	dc.b	'INX DEX CLV SEV CLC SEC CLI SEI '
	dc.b	'SBA CBA ??? ??? ??? ??? TAB TBA '
	dc.b	'XGDXDAA SLP ABA ??? ??? ??? ??? '
	dc.b	'BRA BRN BHI BLS BCC BCS BNE BEQ '
	dc.b	'BVC BVS BPL BMI BGE BLT BGT BLE '
	dc.b	'TSX INS PULAPULBDES TXS PSHAPSHB'
	dc.b	'PULXRTS ABX RTI PSHXMUL WAI SWI '
	dc.b	'NEGA??? ??? COMALSRA??? RORAASRA'
	dc.b	'ASLAROLADECA??? INCATSTA??? CLRA'
	dc.b	'NEGB??? ??? COMBLSRB??? RORBASRB'
	dc.b	'ASLBROLBDECB??? INCBTSTB??? CLRB'
	dc.b	'NEG AIM OIM COM LSR EIM ROR ASR '
	dc.b	'ASL ROL DEC TIM INC TST JMP CLR '
	dc.b	'NEG AIM OIM COM LSR EIM ROR ASR '
	dc.b	'ASL ROL DEC TIM INC TST JMP CLR '
	dc.b	'SUBACMPASBCASUBDANDABITALDAA??? '
	dc.b	'EORAADCAORAAADDACPX BSR LDS ??? '
	dc.b	'SUBACMPASBCASUBDANDABITALDAASTAA'
	dc.b	'EORAADCAORAAADDACPX JSR LDS STS '
	dc.b	'SUBACMPASBCASUBDANDABITALDAASTAA'
	dc.b	'EORAADCAORAAADDACPX JSR LDS STS '
	dc.b	'SUBACMPASBCASUBDANDABITALDAASTAA'
	dc.b	'EORAADCAORAAADDACPX JSR LDS STS '
	dc.b	'SUBBCMPBSBCBADDDANDBBITBLDAB??? '
	dc.b	'EORBADCBORABADDBLDD ??? LDX ??? '
	dc.b	'SUBBCMPBSBCBADDDANDBBITBLDABSTAB'
	dc.b	'EORBADCBORABADDBLDD STD LDX STX '
	dc.b	'SUBBCMPBSBCBADDDANDBBITBLDABSTAB'
	dc.b	'EORBADCBORABADDBLDD STD LDX STX '
	dc.b	'SUBBCMPBSBCBADDDANDBBITBLDABSTAB'
	dc.b	'EORBADCBORABADDBLDD STD LDX STX '

len:	dc.b	%01010101,%01010101,%01010101,%01010101
	dc.b	%01010101,%01010101,%01010101,%01010101
	dc.b	%10101010,%10101010,%10101010,%10101010
	dc.b	%01010101,%01010101,%01010101,%01010101
	dc.b	%01010101,%01010101,%01010101,%01010101
	dc.b	%01010101,%01010101,%01010101,%01010101
	dc.b	%10111110,%10101110,%11101010,%10101010
	dc.b	%11111111,%11111111,%11111111,%11111111
	dc.b	%11101010,%01101010,%10101010,%01111011
	dc.b	%10101010,%10101010,%10101010,%10101010
	dc.b	%10101010,%10101010,%10101010,%10101010
	dc.b	%11111111,%11111111,%11111111,%11111111
	dc.b	%11101010,%01101010,%10101010,%01110111
	dc.b	%10101010,%10101010,%10101010,%10101010
	dc.b	%10101010,%10101010,%10101010,%10101010
	dc.b	%11111111,%11111111,%11111111,%11111111
	even
undo:	ds.w	1
sav_col	ds.l	1
scrnptr:	ds.l	1
save:	ds.l	1
savea:	ds.l	1
string:	ds.b	34

	even
cr:	ds.b	3
flag:	ds.b	1
daten:	ds.b	6

anzahl:	ds.b	1
anfang:	ds.b	1
zerflag:	ds.b	1
branch_flag:	ds.b	1

	even
inp_txt:	ds.l	1
rez:	ds.b	1

	IFEQ	REAL_TIME
	IFNE	IKBD_ACCESS
	bss
buffer	ds.b	$10010
	ELSEIF
buffer	incbin	f:\buffer\ikbd_mem
	bss
	ENDC
	ENDC
	
	
