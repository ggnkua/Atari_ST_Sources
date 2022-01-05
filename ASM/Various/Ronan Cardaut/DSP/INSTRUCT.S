	TEXT
NULL	rts
iiEE	move	#'	',(a6)+
	bfextu	d0{16:8},d1
	bsr	IMM_8
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{30:2},d1
	move.b	#'E',d7
	bsr	TRIPLE	; 0 + 2 bits...
	rts
Pea	move	#'	',(a6)+
	bfextu	d0{18:6},d1
	bsr	EA
	rts
	
CCa12					;Jcc xxx
	bfextu	d0{16:4},d1
	bsr	CCCC	
	move	#'	',(a6)+
	bfextu	d0{20:12},d1
	bsr	ABSa12
	rts
a12	move	#'	',(a6)+
	bfextu	d0{20:12},d1
	bsr	ABSa12
	rts
CCea	bfextu	d0{28:4},d1
	bsr	CCCC	
	move	#'	',(a6)+
	bfextu	d0{18:6},d1
	bsr	EA
	rts
ea	move	#'	',(a6)+
	bfextu	d0{18:6},d1
	bsr	EA
	rts
bppxx	move	#'	',(a6)+
	bfextu	d0{27:5},d1
	bsr	IMM_5
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{25:1},d1	
	bsr	MEMORY_S
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{18:6},d1
	bsr	ABSp6
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	move	#'P:',MEM_BANK
	bsr	ABS_16
	rts
beaxx	move	#'	',(a6)+
	bfextu	d0{27:5},d1
	bsr	IMM_5
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{25:1},d1	
	bsr	MEMORY_S
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{18:6},d1
	bsr	EA
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	move	#'P:',MEM_BANK
	bsr	ABS_16
	rts
baaxx	move	#'	',(a6)+
	bfextu	d0{27:5},d1
	bsr	IMM_5
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{25:1},d1	
	bsr	MEMORY_S
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{18:6},d1
	bsr	ABSa6
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	move	#'P:',MEM_BANK
	bsr	ABS_16
	rts
bSxx	move	#'	',(a6)+
	bfextu	d0{27:5},d1
	bsr	IMM_5
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{18:6},d1	
	bsr	SIX
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	move	#'P:',MEM_BANK
	bsr	ABS_16
	rts
bpp	move	#'	',(a6)+
	bfextu	d0{27:5},d1
	bsr	IMM_5
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{25:1},d1	
	bsr	MEMORY_S
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{18:6},d1
	bsr	ABSp6
	rts
bea	move	#'	',(a6)+
	bfextu	d0{27:5},d1
	bsr	IMM_5
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{25:1},d1	
	bsr	MEMORY_S
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{18:6},d1
	bsr	EA
	rts
baa	move	#'	',(a6)+
	bfextu	d0{27:5},d1
	bsr	IMM_5
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{25:1},d1	
	bsr	MEMORY_S
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{18:6},d1
	bsr	ABSa6
	rts
nD	move	#'	',(a6)+
	bfextu	d0{27:5},d1
	bsr	IMM_5
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{18:6},d1
	bsr	SIX
	rts
SWMRsp	move	#'	',(a6)+
	bfextu	d0{16:1},d1
	bne.s	.WRITEP
.READP	bfextu	d0{15:1},d1
	bsr	MEMORY_S	
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{26:6},d1
	bsr	ABSp6
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{25:1},d1	
	bsr	MEMORY_S	
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{18:6},d1
	bsr	EA
	rts
.WRITEP	bfextu	d0{25:1},d1	;write peripheral
	bsr	MEMORY_S	
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{18:6},d1
	bsr	EA
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{15:1},d1
	bsr	MEMORY_S	
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{26:6},d1
	bsr	ABSp6
	rts			
SWMRp	move	#'	',(a6)+
	bfextu	d0{16:1},d1
	bne.s	.WRITEP
.READP	move	#'P:',MEM_BANK
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{26:6},d1
	bsr	ABSp6
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{15:1},d1	
	bsr	MEMORY_S	
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{18:6},d1
	bsr	EA
	rts
.WRITEP	bfextu	d0{15:1},d1	;write peripheral
	bsr	MEMORY_S	
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{18:6},d1
	bsr	EA
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	move	#'P:',MEM_BANK
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{26:6},d1
	bsr	ABSp6
	rts			
SWDp	move	#'	',(a6)+
	btst	#15,d0
	bne.s	.WRITEP
.READP	bfextu	d0{15:1},d1	
	bsr	MEMORY_S
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{26:6},d1
	bsr	ABSp6
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{18:6},d1
	bsr	SIX
	rts	
.WRITEP	bfextu	d0{18:6},d1
	bsr	SIX
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{15:1},d1	
	bsr	MEMORY_S
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{26:6},d1
	bsr	ABSp6
	rts
WMRd	move	#'	',(a6)+
	btst	#15,d0
	bne.s	.WRITEP
.READP	bfextu	d0{26:6},d1
	bsr	SIX
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	move	#'P:',MEM_BANK
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{18:6},d1
	bsr	EA
	rts	
.WRITEP	move	#'P:',MEM_BANK
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{18:6},d1
	bsr	EA
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{26:6},d1
	bsr	SIX
	rts
Waad	move	#'	',(a6)+
	btst	#15,d0
	bne.s	.WRITEP
.READP	bfextu	d0{26:6},d1
	bsr	SIX
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	move	#'P:',MEM_BANK
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{18:6},d1
	bsr	ABSa6
	rts	
.WRITEP	move	#'P:',MEM_BANK
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{18:6},d1
	bsr	ABSa6
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{26:6},d1
	bsr	SIX
	rts
iih	
	move	#'	',(a6)+
	move	d0,d1
	move	d1,d2
	and	#$ff00,d1
	lsr	#8,d1
	and	#$f,d2
	lsl	#8,d2
	add	d2,d1
	bsr	IMM_12
	rts
D_6	move	#'	',(a6)+
	bfextu	d0{18:6},d1
	bsr	SIX
	rts
sea	move	#'	',(a6)+
	bfextu	d0{25:1},d1
	bsr	MEMORY_S
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{18:6},d1
	bsr	EA
	rts
saa	move	#'	',(a6)+
	bfextu	d0{25:1},d1
	bsr	MEMORY_S
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{18:6},d1
	bsr	ABSa6
	rts

iih_exp	move	#'	',(a6)+
	move.w	#'P:',MEM_BANK
	bfextu	d0{28:4},d1
	lsl.l	#8,d1
	bfextu	d0{16:8},d2
	add	d2,d1
	bsr	IMM_12
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bsr	ABS_16
	rts
S_exp	move	#'	',(a6)+
	bfextu	d0{18:6},d1
	bsr	SIX
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	move	#'P:',MEM_BANK
	bsr	ABS_16
	rts
ea_exp	bsr	sea
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	move	#'P:',MEM_BANK
	bsr	ABS_16
	rts
aa_exp	bsr	saa
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	move	#'P:',MEM_BANK
	bsr	ABS_16	
	rts
iidd	move	#'	',(a6)+
	bfextu	d0{16:8},d1
	bsr	IMM_8
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{26:6},d1
	bsr	SIX
	rts
WMRsd	
	move	#'	',(a6)+
	btst	#15,d0
	bne.s	.WRITEP
.READP	bfextu	d0{26:6},d1
	bsr	SIX
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{25:1},d1
	bsr	MEMORY_S
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{18:6},d1
	bsr	EA
	rts	
.WRITEP	bfextu	d0{25:1},d1
	bsr	MEMORY_S
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{18:6},d1
	bsr	EA
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{26:6},d1
	bsr	SIX
	rts
Waasd	move	#'	',(a6)+
	btst	#15,d0
	bne.s	.WRITEP
.READP	bfextu	d0{26:6},d1
	bsr	SIX
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{25:1},d1
	bsr	MEMORY_S
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{18:6},d1
	bsr	ABSa6
	rts	
.WRITEP	bfextu	d0{25:1},d1
	bsr	MEMORY_S
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{18:6},d1
	bsr	ABSa6
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{26:6},d1
	bsr	SIX
	rts
Wed	move	#'	',(a6)+
	btst	#15,d0
	bne.s	.WRITEP
.READP	bfextu	d0{26:6},d1
	bsr	SIX
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{18:6},d1
	bsr	SIX
	rts	
.WRITEP	bfextu	d0{18:6},d1
	bsr	SIX
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{26:6},d1
	bsr	SIX
	rts
MRd	
	move	#'P:',MEM_BANK
	move	#'	',(a6)+
	bfextu	d0{18:6},d1
	bsr	EA
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{26:6},d1
	bsr	SIX
	rts
CtJDT	bfextu	d0{16:4},d1
	bsr	CCCC
	move	#'	',(a6)+
	bfextu	d0{25:4},d1
	bsr	JJJD
	move	#'	R',(a6)+
	bfextu	d0{21:3},d1
	add.b	#'0',d1
	move.b	d1,(a6)+
	move	#',R',(a6)+
	bfextu	d0{29:3},d1
	add.b	#'0',d1
	move.b	d1,(a6)+
	rts
CJD	bfextu	d0{16:4},d1
	bsr	CCCC
	move	#'	',(a6)+
	bfextu	d0{25:4},d1
	bsr	JJJD
	rts
R3d	move	#'	R',(a6)+
	bfextu	d0{21:3},d1
	add.b	#'0',d1
	move.b	d1,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{28:1},d1
	move.b	#'d',d7
	bsr	SINGLE
	rts
JD	move	#'	',(a6)+
	bfextu	d0{25:4},d1
	bsr	JJJd
	rts
D	move	#'	',(a6)+
	bfextu	d0{28:1},d1
	move.b	#'d',d7
	bsr	SINGLE
	rts
D_inv_D	move	#'	',(a6)+
	bfextu	d0{29:1},d1
	move.b	#'d',d7
	bsr	SINGLE
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{29:1},d1
	bchg	#0,d1	
	move.b	#'d',d7
	bsr	SINGLE
	rts	
	
	
;****************************************************************	
;********** ON ATTAQUE LA MULTIPLICATION           *************
;****************************************************************	
MUL	bsr	DEC_MUL
	rts
DEC_MUL	btst	#1,d0
	beq	.Y
	cpy	'AC',a6
	bra.s	.OK0
.Y	cpy	'PY',a6
.OK0	btst	#0,d0
	beq.s	.OK1
	move.b	ATTRIBUTE,(a6)+
	move.b	#'R',(a6)+
.OK1	move	#'	',(a6)+
	btst	#2,d0
	beq	.OK2
	move.b	ATTRIBUTE,(a6)+
	move.b	#'-',(a6)+
.OK2	bfextu	d0{25:3},d1
	lea	(.QQQ.l,d1.w*8),a2
	col_cpy	a2,a6
	btst	#3,d0
	beq	.AA
	move.b	ATTRIBUTE,(a6)+
	move.b	#'B',(a6)+
	bra.s	.OK3
.AA	move.b	ATTRIBUTE,(a6)+
	move.b	#'A',(a6)+
.OK3	rts
.QQQ	dc.b	'X0,X0,',0,0,'Y0,Y0,',0,0
	dc.b	'X1,X0,',0,0,'Y1,Y0,',0,0
	dc.b	'X0,Y1,',0,0,'Y0,X0,',0,0
	dc.b	'X1,Y0,',0,0,'Y1,X1,',0,0

;****************************************************************	
DEC_PAR	lea	LIST_PAR,a2
.NEXT	move.l	d0,d1
	and.l	(a2)+,d1
	cmp.l	(a2)+,d1
	beq.s	.FOUND
	addq	#4,a2
	bra.s	.NEXT
.FOUND	jmp	([a2])
;****************************************************************	
P_XY	move	#'	',(a6)+
	bsr	.XFIELD
	move	#'	',(a6)+
	bsr	.YFIELD
	rts
.XFIELD	btst	#15,d0
	bne.s	.XWRITE
	bfextu	d0{12:2},d1
	move.b	#'e',d7
	bsr	DOUBLE
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	move	#'X:',MEM_BANK
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{19:5},d1
	bfextu	d0{19:2},d2
	tst	d2
	bne.s	.OK
	or.b	#%100000,d1
.OK	bsr	EA		
	rts
.XWRITE	move	#'X:',MEM_BANK
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{19:5},d1
	bfextu	d0{19:2},d2
	tst	d2
	bne.s	.OK1
	or.b	#%100000,d1
.OK1	bsr	EA		
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{12:2},d1
	move.b	#'e',d7
	bsr	DOUBLE
	rts
.YFIELD	btst	#15,d0
	bne.s	.YWRITE
	bfextu	d0{14:2},d1
	move.b	#'f',d7
	bsr	DOUBLE
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	move	#'Y:',MEM_BANK
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{10:2},d1
	tst	d1
	bne.s	.OK3
	or.b	#%100,d1
.OK3	lsl	#3,d1
	bfextu	d0{17:2},d2
	bfextu	d0{21:1},d3
	bchg	#0,d3
	lsl	#2,d3
	or	d3,d2
	or	d2,d1
	bsr	EA
	rts
.YWRITE	move	#'Y:',MEM_BANK
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{10:2},d1
	tst	d1
	bne.s	.OK5
	or.b	#%100,d1
.OK5	lsl	#3,d1
	bfextu	d0{17:2},d2
	bfextu	d0{21:1},d3
	bchg	#0,d3
	lsl	#2,d3
	or	d3,d2
	or	d2,d1
	bsr	EA
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{14:2},d1
	move.b	#'f',d7
	bsr	DOUBLE
	rts
;****************************************************************	
P_X	move	#'	',(a6)+
	btst	#15,d0
	bne.s	.WRITER
	bfextu	d0{13:3},d1
	bfextu	d0{10:2},d2	
	asl	#3,d2
	or	d2,d1
	bsr	FIVE
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	move	#'X:',MEM_BANK
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{18:6},d1
	bsr	EA
	rts
.WRITER	move	#'X:',MEM_BANK
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{18:6},d1
	bsr	EA
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{13:3},d1
	bfextu	d0{10:2},d2	
	asl	#3,d2
	or	d2,d1
	bsr	FIVE
	rts
;****************************************************************	
P_Xaa	move	#'	',(a6)+
	btst	#15,d0
	bne.s	.WRITER
	bfextu	d0{13:3},d1
	bfextu	d0{10:2},d2	
	asl	#3,d2
	or	d2,d1
	bsr	FIVE
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	move	#'X:',MEM_BANK
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{18:6},d1
	bsr	ABSa6
	rts
.WRITER	move	#'X:',MEM_BANK
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{18:6},d1
	bsr	ABSa6
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{13:3},d1
	bfextu	d0{10:2},d2	
	asl	#3,d2
	or	d2,d1
	bsr	FIVE
	rts
;****************************************************************	
P_Y	move	#'	',(a6)+
	btst	#15,d0
	bne.s	.WRITER
	bfextu	d0{13:3},d1
	bfextu	d0{10:2},d2	
	asl	#3,d2
	or	d2,d1
	bsr	FIVE
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	move	#'Y:',MEM_BANK
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{18:6},d1
	bsr	EA
	rts
.WRITER	move	#'Y:',MEM_BANK
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{18:6},d1
	bsr	EA
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{13:3},d1
	bfextu	d0{10:2},d2	
	asl	#3,d2
	or	d2,d1
	bsr	FIVE
	rts
;****************************************************************	
P_Yaa	move	#'	',(a6)+
	btst	#15,d0
	bne.s	.WRITER
	bfextu	d0{13:3},d1
	bfextu	d0{10:2},d2	
	asl	#3,d2
	or	d2,d1
	bsr	FIVE
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	move	#'Y:',MEM_BANK
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{18:6},d1
	bsr	ABSa6
	rts
.WRITER	move	#'Y:',MEM_BANK
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{18:6},d1
	bsr	ABSa6
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{13:3},d1
	bfextu	d0{10:2},d2	
	asl	#3,d2
	or	d2,d1
	bsr	FIVE
	rts


;****************************************************************	
P_L	move	#'	',(a6)+
	btst	#15,d0
	bne.s	.WRITER
	bfextu	d0{14:2},d1
	bfextu	d0{12:1},d2	
	asl	#2,d2
	or	d2,d1
	move.b	#'L',d7
	bsr	TRIPLE
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	move	#'L:',MEM_BANK
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{18:6},d1
	bsr	EA
	rts
.WRITER	move	#'L:',MEM_BANK
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{18:6},d1
	bsr	EA
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{14:2},d1
	bfextu	d0{12:1},d2	
	asl	#2,d2
	or	d2,d1
	move.b	#'L',d7
	bsr	TRIPLE
	rts
;****************************************************************	
P_Laa	move	#'	',(a6)+
	btst	#15,d0
	bne.s	.WRITER
	bfextu	d0{14:2},d1
	bfextu	d0{12:1},d2	
	asl	#2,d2
	or	d2,d1
	move.b	#'L',d7
	bsr	TRIPLE
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	move	#'L:',MEM_BANK
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{18:6},d1
	bsr	ABSa6
	rts
.WRITER	move	#'L:',MEM_BANK
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{18:6},d1
	bsr	ABSa6
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{14:2},d1
	bfextu	d0{12:1},d2	
	asl	#2,d2
	or	d2,d1
	move.b	#'L',d7
	bsr	TRIPLE
	rts
;****************************************************************	
P_I	move	#'	',(a6)+
	bfextu	d0{16:8},d1
	bsr	IMM_8
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{11:5},d1
	bsr	FIVE
	rts
;****************************************************************	
P_R	move	#'	',(a6)+
	bfextu	d0{14:5},d1
	bsr	FIVE
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{19:5},d1
	bsr	FIVE
	rts
;****************************************************************	
P_U	move	#'	',(a6)+
	move	#'  ',MEM_BANK
	bfextu	d0{18:6},d1
	bsr	EA
	rts
;****************************************************************	
P_NOP	rts
;****************************************************************	
P_RYI	move	#'	',(a6)+
	bfextu	d0{12:1},d1
	move.b	#'d',d7
	bsr	SINGLE
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{13:1},d1
	move.b	#'e',d7
	bsr	SINGLE
	move	#'	',(a6)+
	btst	#15,d0
	bne.s	.WRITE
.READ	bfextu	d0{14:2},d1
	move.b	#'f',d7
	bsr	DOUBLE
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	move	#'Y:',MEM_BANK
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{18:6},d1
	bsr	EA
	rts
.WRITE	move	#'Y:',MEM_BANK
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{18:6},d1
	bsr	EA
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{14:2},d1
	move.b	#'f',d7
	bsr	DOUBLE
	rts
;****************************************************************	
P_RYII	move	#'	',(a6)+
	bfextu	d0{15:1},d1	;d
	bfextu	d0{18:6},d2	;EA
	move.b	#'Y',d7
	bsr	SINGLE_II	;contient EA et d
	rts
;****************************************************************	
P_XRI	move	#'	',(a6)+
	btst	#15,d0
	bne.s	.WRITE
.READ	bfextu	d0{14:2},d1
	move.b	#'f',d7
	bsr	DOUBLE
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	move	#'X:',MEM_BANK
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{18:6},d1
	bsr	EA
	bra.s	.SUITE
.WRITE	move	#'X:',MEM_BANK
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK,(a6)+
	move.b	ATTRIBUTE,(a6)+
	move.b	MEM_BANK+1,(a6)+
	bfextu	d0{18:6},d1
	bsr	EA
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{14:2},d1
	move.b	#'f',d7
	bsr	DOUBLE
.SUITE	move	#'	',(a6)+
	bfextu	d0{12:1},d1
	move.b	#'d',d7
	bsr	SINGLE
	move.b	ATTRIBUTE,(a6)+
	move.b	#',',(a6)+
	bfextu	d0{13:1},d1
	move.b	#'f',d7
	bsr	SINGLE
	rts
;****************************************************************	
P_XRII	move	#'	',(a6)+
	bfextu	d0{15:1},d1	;d
	bfextu	d0{18:6},d2	;EA
	move.b	#'X',d7
	bsr	SINGLE_II	;contient EA et d
	rts
;****************************************************************	
ELSE_PAR
	bsr	DEC_AUTRE
	bsr	DEC_PAR
	rts
DEC_AUTRE	;g‚n‚ration des instructions avec parrallele move
	bfextu	d0{25:3},d1
	move	d1,d2
	lsl	#3,d2
	bfextu	d0{29:3},d1
	or	d1,d2
	move.l	(.INS0.l,d2.w*4),(a6)+
	EFF_SP
	tst	d2
	beq	.OK1
	move	#'	',(a6)+
	bfextu	d0{25:3},d1
	cmp.b	#%10,d1
	beq.s	.SPECIAL
	cmp.b	#%11,d1
	beq.s	.SPECIAL
.SUITE	asl	d1
	bfextu	d0{28:1},d2
	or	d2,d1
	move	(.SOURCE.l,d1.w*2),(a6)+
	EFF_SP
	btst	#3,d0
	bne.S	.OK
	move	#',A',(a6)+
	rts
.OK	move	#',B',(a6)+
.OK1	rts
.SPECIAL
	btst	#1,d0
	beq.s	.SUITE
	move	#0,d1
	bra.s	.SUITE		
.SOURCE	dc	'B ','A '
	dc	'B ','A '
	dc	'X ','X '	;sp‚cial
	dc	'Y ','Y '	;idem
	dc	'X0','X0'
	dc	'Y0','Y0'
	dc	'X1','X1'
	dc	'Y1','Y1'
.INS0	dc.l	'MOVE','TFR ','ADDR','TST ','*   ','CMP ','SUBR','CMPM'
.INS1	DC.l	'ADD ','RND ','ADDL','CLR ','SUB ','*   ','SUBL','NOT '	
.INS2	DC.L	'ADD ','ADDC','ASR ','LSR ','SUB ','SBC ','ABS ','ROR '	
.INS3	DC.L	'ADD ','ADDC','ASL ','LSL ','SUB ','SBC ','NEG ','ROL '	
.INS4	DC.L	'ADD ','TFR ','OR  ','EOR ','SUB ','CMP ','AND ','CMPM'	
.INS5	DC.L	'ADD ','TFR ','OR  ','EOR ','SUB ','CMP ','AND ','CMPM'	
.INS6	DC.L	'ADD ','TFR ','OR  ','EOR ','SUB ','CMP ','AND ','CMPM'	
.INS7	DC.L	'ADD ','TFR ','OR  ','EOR ','SUB ','CMP ','AND ','CMPM'	
;****************************************************************	
