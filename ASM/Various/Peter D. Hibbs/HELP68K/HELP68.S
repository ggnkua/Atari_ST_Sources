	Include	help68.s2

*******************************
*      Table des bits         *
*******************************
m1	equ	%0000000000000001
m2	equ	%0000000000000010
m3	equ	%0000000000000100
m4	equ	%0000000000001000
m5	equ	%0000000000010000
m6	equ	%0000000000100000
m7	equ	%0000000001000000
m8	equ	%0000000010000000
m9	equ	%0000000100000000
m10	equ	%0000001000000000
m11	equ	%0000010000000000
m12	equ	%0000100000000000
mtout	equ	%0000111111111111
msource	equ	%0000000111111111
mdest	equ	%0000000111111101
lb	equ	%0010000000000000
lw	equ	%0100000000000000
ll	equ	%1000000000000000
lbwl	equ	%1110000000000000

bna	equ	%0000000000000000
bxi	equ	%0000000000000001
bx0	equ	%0000000000000010
bx1	equ	%0000000000000011
bxp	equ	%0000000000000100
bni	equ	%0000000000001000
bn0	equ	%0000000000010000
bn1	equ	%0000000000011000
bnp	equ	%0000000000100000
bzi	equ	%0000000001000000
bz0	equ	%0000000010000000
bz1	equ	%0000000011000000
bzp	equ	%0000000100000000
bvi	equ	%0000001000000000
bv0	equ	%0000010000000000
bv1	equ	%0000011000000000
bvp	equ	%0000100000000000
bci	equ	%0001000000000000
bc0	equ	%0010000000000000
bc1	equ	%0011000000000000
bcp	equ	%0100000000000000
bp	equ	%0100100100100100

**********************************
*         Le programme           *
**********************************

debut	movea.l	#newstack,a7
programm	bsr	initappl
	move.w	d0,id_appl
	cmp.w	#-1,d0
	beq	erreur1
	move.l	#nom_rsc,addrin
	move.l	#$6e000101,d0
	bsr	aes
	tst.w	d0
	beq	erreur2
	move.w	id_appl,intin
	move.l	#nom_acc,addrin
	move.l	#$23010101,d0
	bsr	aes
	move.w	d0,num_acc
	move.w	#-1,id_fen
	clr.w	intin+2
	bsr	rsc_tree
	move.l	a0,ecran
	move.l	20(a0),lbase
	move.w	#5,xbase
	move.w	#50,ybase
	clr.w	intin
	move.w	#%1011,intin+2
	move.l	xbase,intin+4
	move.l	lbase,intin+8
	move.l	#$6c060500,d0
	bsr	aes
	move.l	intout+2,xfen
	move.l	intout+6,lfen
	clr.w	choix
	clr.w	info
boucle	bsr	evn_mult
	bsr	beg_ebdt
	btst	#4,event+1
	beq	nomessag
	bsr	message
nomessag	btst	#1,event+1
	beq	nobutton
	bsr	button
nobutton	btst	#0,event+1
	beq	nokey
	bsr	keyboard
nokey	bsr	end_ebdt
	bra	boucle
erreur2	move.l	#$13000100,d0
	bsr	aes
erreur1	clr.w	-(a7)
	trap	#1

message	lea	mes_tab(pc),a0
	lea	jmp_mes(pc),a1
	moveq	#(jmp_mes-mes_tab)-1,d0
	move.w	tampon,d1
messag1	move.l	(a1)+,a2
	cmp.w	(a0)+,d1
	dbeq	d0,messag1
	move.w	tampon+6,d0
	move.w	id_fen,d1
	jmp	(a2)
messag2	rts

mes_tab	dc.w	21,22,28,29,20,40,41,0
jmp_mes	dc.l	topped,closed,moved,newtop,redraw
	dc.l	acopen,acclose,messag2

redraw	cmp.w	d0,d1
	bne	messag2
	bsr	m_hide
	move.l	ecran,a0
	move.l	xbase,16(a0)
	move.w	#11,intin+2
redraw1	bsr	w_get
	tst	intout+6
	bne	redraw2
	tst	intout+8
	beq	redraw9
redraw2	move.l	intout+2,d0
	move.l	tampon+8,d1
	bsr	minmax
	swap	d0
	swap	d1
	bsr	minmax
	swap	d1
	move.l	d1,intin+4
	move.l	intout+2,d0
	add.l	intout+6,d0
	move.l	tampon+8,d1
	add.l	tampon+12,d1
	bsr	minmax
	swap	d0
	swap	d1
	bsr	minmax
	sub.w	intin+4,d0
	ble	redraw3
	move.w	d0,intin+8
	swap	d0
	sub.w	intin+6,d0
	ble	redraw3
	move.w	d0,intin+10
	clr.w	intin
	bsr	obj_draw
redraw3	move.w	#12,intin+2
	bra	redraw1
redraw9	bsr	m_last
	rts
minmax	cmp.w	d0,d1
	bcc	minmax1
	move.w	d1,d2
	move.w	d0,d1
	move.w	d2,d0
minmax1	rts
moved	cmp.w	d0,d1
	bne	messag2
	move.l	tampon+8,xfen
	move.l	xfen,intin+4
	move.l	lfen,intin+8
	move.w	#5,intin+2
	bsr	w_set
	move.w	#4,intin+2
	bsr	w_get
	move.l	intout+2,xbase
	move.l	ecran,a0
	move.l	xbase,16(a0)
	rts
acopen	move.w	tampon+8,d0
	cmp.w	num_acc,d0
	bne	messag2
	cmp.w	#-1,d1
	bne	activew
	bsr	opnvwk
	bsr	window
	rts
topped:
newtop	cmp.w	d0,d1
	bne	messag2
activew	move.w	#10,intin+2
	move.w	d0,intin+4
	bsr	w_set
	rts
acclose	cmp.w	num_acc,d0
	bne	messag2
	cmp.w	#-1,d1
	beq	messag2
	bra	closew
closed	cmp.w	d0,d1
	bne	messag2
closew	move.w	id_fen,intin
	move.l	#$66010100,d0
	bsr	aes
	move.l	#$67010100,d0
	bsr	aes
	bsr	clsvwk
	move.w	#-1,id_fen
	rts

window	move.w	#%1011,intin
	move.l	xfen,intin+2
	move.l	lfen,intin+6
	move.l	#$64050100,d0
	bsr	aes
	move.w	d0,id_fen
	move.w	d0,intin
	move.w	#2,intin+2
	move.l	#nom_acc,intin+4
	bsr	w_set
	move.l	xfen,intin+2
	move.l	lfen,intin+6
	move.l	#$65050100,d0
	bsr	aes
	rts

keyboard	move.l	ecran,a1
	move.w	choix,d0
	cmp.b	#$48,key
	beq	flhaut
	cmp.b	#$4b,key
	beq	flgauche
	cmp.b	#$4d,key
	beq	fldroite
	cmp.b	#$50,key
	beq	flbas
	rts
flbas	addq	#4,d0
	cmp.w	#instr2,d0
	bls	fleche
	sub.w	#instr2,d0
	cmp.w	#instr1+3,d0
	bne	fldroite
	subq	#4,d0
fldroite	addq	#1,d0
	cmp.w	#instr2,d0
	bls	fleche
	move.w	#instr1,d0
	bra	fleche
flhaut	subq	#4,d0
	cmp.w	#instr1,d0
	bge	fleche
	add.w	#instr2,d0
	cmp.w	#instr2-3,d0
	bne	flgauche
	addq	#4,d0
flgauche	subq	#1,d0
	cmp.w	#instr1,d0
	bge	fleche
	move.w	#instr2,d0
fleche	mulu	#24,d0
	bra	button3

button	move.l	ecran,a1
	move.w	#instr1*24,d0
button1   move.l	16(a1,d0.w),d1
	add.l	xbase,d1
	cmp.l	xmouse,d1
	bhi	button2
	cmp.w	ymouse,d1
	bhi	button2
	add.l	20(a1,d0.w),d1
	cmp.l	xmouse,d1
	bcs	button2
	cmp.w	ymouse,d1
	bcc	button3
button2	cmp.w	#instr2*24,d0
	beq	button9
	add.w	#24,d0
	bra	button1
button3	ext.l	d0
	move.w	d0,d6
	divu	#24,d6
	cmp.w	choix,d6
	beq	button99
	move.w	d6,intin
	bset	#0,11(a1,d0.w)
	bsr	obj_redr
	move.w	choix,d0
	beq	button4
	move.w	d0,intin
	mulu	#24,d0
	bclr	#0,11(a1,d0.w)
	bsr	obj_redr
button4	move.w	d6,choix
	subq	#instr1,d6
	move.w	d6,d1
	mulu	#long,d1
	lea	instruc(pc),a2
	add.l	d1,a2
	moveq	#2,d5
	move.l	a1,a4
	move.l	a1,a5
	add.l	#mnemo*24,a4
	add.l	#operande*24,a5
	move.w	fmasque,d0
	eor.w	#1,d0
	move.w	d0,fmasq2
	eor.w	d0,fmasque
button5	move.w	d5,d4
	mulu	#24,d4
	move.l	12(a4,d4.w),a0
	move.l	(a0),a0
	moveq	#6,d6
	clr.w	d0
	lea	fmnem(pc),a3
	btst	d5,fmasq2+1
	beq	button30
	bchg	#0,11(a4,d4.w)
	bchg	#0,11(a5,d4.w)
	tst.w	d5
	beq	button8
	tst.b	0(a2,d5.w)
	beq	button31
	bra	button8
button30	tst.w	d5
	beq	button8
	tst.b	0(a2,d5.w)
	bne	button8
	tst.b	0(a3,d5.w)
	beq	button10
button31	sf	0(a3,d5.w)
	lea	blanc(pc),a3
	bra	button6
button8	st	0(a3,d5.w)
	move.w	choix,d1
	mulu	#24,d1
	move.l	12(a1,d1.w),a3
	move.l	(a3),a3
button6	move.b	(a3)+,d0
	cmp.b	#'A',d0
	bcc	button7
	moveq	#' ',d0
	subq	#1,a3
button7	move.b	d0,(a0)+
	dbf	d6,button6
	move.w	d5,d0
	add.w	#mnemo,d0
	move	d0,intin
	bsr	obj_redr
button10	clr.w	d0
	lea	foper(pc),a3
	move.b	0(a2,d5.w),d0
	btst	d5,fmasq2+1
	bne	button32
	cmp.b	0(a3,d5.w),d0
	beq	button11
button32	move.b	d0,0(a3,d5.w)
	ext.w	d0
	add.w	#syntaxe0,d0
	move.w	#5,intin
	move.w	d0,intin+2
	bsr	rsc_gadr
	move.l	12(a5,d4.w),a3
	move.l	a0,(a3)
	move.w	d5,d0
	add.w	#operande,d0
	move.w	d0,intin
	bsr	obj_redr
button11	dbf	d5,button5
	clr.w	d0
	move.l	#an,d5
	cmp.b	#add,3(a2)
	bne	button50
	move.l	#anet,d5
	bset	#1,d0
button50	move.l	source*24+36(a1),a0
	move.l	d5,(a0)
	move.w	fnames,d5
	move.w	d0,fnames
	eor.w	d5,d0
	move.w	d0,fname
	move.w	6(a2),d3
	bsr	affsrc
	clr.w	d0
	move.l	#dn,d5
	cmp.b	#bitoper,3(a2)
	bne	button51
	move.l	#dnet,d5
	bset	#0,d0
button51	move.l	destinat*24+12(a1),a0
	move.l	d5,(a0)
	move.l	#an,d5
	cmp.b	#addq,3(a2)
	bne	button52
	move.l	#anet,d5
	bset	#1,d0
button52	move.l	destinat*24+36(a1),a0
	move.l	d5,(a0)
	move.w	fnamed,d5
	move.w	d0,fnamed
	eor.w	d5,d0
	move.w	d0,fname
	move.w	8(a2),d3
	bsr	affdest
	move.w	4(a2),d3
	move.w	#indicat*24,d2
	moveq	#4,d4
	move.w	findic,d5
	move.w	d3,findic
	eor.w	d3,d5
	beq	button15
	lea	indictab(pc),a3
button12	move.w	d5,d0
	and.w	#7,d0
	beq	button14
	move.b	15(a1,d2.w),d1
	and.b	#$80,d1
	move.w	d3,d6
	and.w	#7,d6
	move.b	0(a3,d6.w),12(a1,d2.w)
	btst	#2,d0
	beq	button13
	bchg	#0,11(a1,d2.w)
button13	move.w	d2,d0
	ext.l	d0
	divu	#24,d0
	move.w	d0,intin
	bsr	obj_redr
button14	add.w	#24,d2
	lsr	#3,d3
	lsr	#3,d5
	dbf	d4,button12
button15	move.b	3(a2),d3
	ext.w	d3
	cmp.w	finfo,d3
	beq	button16
	move.w	d3,finfo
	tst.w	d3
	bne	button17
	move.w	#operat,intin
	bsr	obj_redr
button16	rts
button17	move.w	d3,intin+2
	bsr	rsc_tree
	move.l	operat*24+16(a1),d0
	add.l	xbase,d0
	move.l	d0,16(a0)
	bsr	tree_drw
button99	rts
button9	lea	fmnem(pc),a3
	moveq	#2,d5         
	move.l	ecran,a1
button40	tst.b	0(a3,d5.w)
	beq	button41
	move.w	d5,d0
	add.w	#masque,d0
	move.w	d0,intin
	clr.w	intin+2
	move.l	xmouse,intin+4
	move.l	a1,addrin
	move.l	#$2b040101,d0
	bsr	aes
	cmp.w	#-1,d0
	bne	button42
button41	dbf	d5,button40
	rts
button42	move.w	fmasque,d1
	bchg	d5,d1
	tst.w	d1
	beq	button99
	eor.w	d1,fmasque
	move.w	#(mnemo+2)*24,d3
	move.w	#(operande+2)*24,d4
	moveq	#2,d6
button43	btst	d6,d1
	beq	button44
	bchg	#0,11(a1,d3.w)
	bchg	#0,11(a1,d4.w)
	move.w	#mnemo,intin
	add.w	d6,intin
	bsr	obj_redr
	move.w	#operande,intin
	add.w	d6,intin
	bsr	obj_redr
button44	sub.w	#24,d3
	sub.w	#24,d4
	dbf	d6,button43
	asl.w	#2,d5
	lea	instruc(pc),a2
	move.w	choix,d1
	subq	#instr1,d1
	mulu	#long,d1
	add.l	d1,a2
	move.w	6(a2,d5.w),d3
	bsr	affsrc
	move.w	8(a2,d5.w),d3
	bsr	affdest
	rts

affsrc	movem.l	d0-d5,-(a7)
	move.w	#source*24,d2
	move.w	fsource,d4
	move.w	d3,fsource
	bsr	affich
	move.w	#longueur*24,d2
	moveq	#2,d4
	lsr.w	#1,d3
	beq	affsrc1
	bsr	affich1
affsrc1	movem.l	(a7)+,d0-d5
	rts
affdest	movem.l	d0-d5,-(a7)
	move.w	#destinat*24,d2
	move.w	fdest,d4
	move.w	d3,fdest
	bsr	affich
	movem.l	(a7)+,d0-d5
	rts
affich	eor.w	d4,d3
	moveq	#11,d4
	move.w	fname,d1
affich1	lsr.w	#1,d3
	bcc	affich2
	bchg	#0,11(a1,d2.w)
	bra	affich3
affich2	btst	#0,d1
	beq	affich4
affich3	move.w	d2,d5
	ext.l	d5
	divu	#24,d5
	move.w	d5,intin
	bsr	obj_redr
affich4	add.w	#24,d2
	lsr.w	#1,d1
	dbf	d4,affich1
	rts


*****************************
*     Fonctions  A.E.S      *
*****************************

initappl	move.l	#$0a000100,d0
	bra	aes
evn_mult  move.w	#%010011,intin
	move.w	#1,intin+2
	move.w	#1,intin+4
	move.w	#1,intin+6
	clr.l	intin+8
	clr.l	intin+12
	clr.l	intin+16
	clr.l	intin+20
	clr.l	intin+24
	clr.l	intin+28
	move.l	#tampon,addrin
	move.l	#$19100701,d0
	bsr	aes
	move.w	d0,event
	move.w	intout+2,xmouse
	move.w	intout+4,ymouse
	move.w	intout+10,key
	rts
obj_redr	move.l	xbase,intin+4
	move.l	lbase,intin+8
obj_draw	move.w	#20,intin+2
	move.l	ecran,addrin
	move.l	#$2a060101,d0
	bra	aes
tree_drw	move.l	16(a0),intin+4
	move.l	20(a0),intin+8
tree_dr2	move.w	#20,intin+2
	move.l	a0,addrin
	move.l	#$2a060101,d0
	bra	aes
m_hide	move.w	#256,intin
	bra	g_mouse
m_last	move.w	#257,intin
g_mouse	move.l	#$4e010100,d0
	bra	aes
beg_ebdt	move.w	#1,intin
	move.l	#$6b010100,d0
	bra	aes
end_ebdt	clr.w	intin
	move.l	#$6b010100,d0
	bra	aes
w_set	move.w	id_fen,intin
	move.l	#$69060100,d0
	bra	aes
w_get	move.w	id_fen,intin
	move.l	#$68020500,d0
	bra	aes
rsc_tree	clr.w	intin
rsc_gadr	move.l	#$70020100,d0
	bsr	aes
	move.l	addrout,a0
	rts

aes	movem.l	d1-d3/a0,-(a7)
	moveq	#3,d1
	moveq	#6,d2
	lea	ctrlaes(pc),a0
aes1	move.b	d0,d3
	ext.w	d3
	move.w	d3,0(a0,d2.w)
	lsr.l	#8,d0
	subq	#2,d2
	dbra	d1,aes1
	move.l	#aespb,d1
	move.w	#$c8,d0
	trap	#2
	movem.l	(a7)+,d1-d3/a0
	move.w	intout,d0
	rts

*****************************
*     Fonctions  V.D.I      *
*****************************

opnvwk	movem.l	d1,-(a7)
	move.l	#$4d000500,d0
	bsr	aes
	move.w	d0,ctrlvdi1+12
	move.l	#vdipb1,d1
	move.w	#$73,d0
	trap	#2
	move.w	ctrlvdi1+12,id_stat
	movem.l	(a7)+,d1
          rts
clsvwk	move.l	d1,-(a7)
	move.w	id_stat,ctrlvdi2+6
	move.l	#vdipb2,d1
	move.w	#$73,d0
	trap	#2
	movem.l	(a7)+,d1
	rts

*****************************
*           Data            *
*****************************

nom_acc	dc.b	'  Help 68000  ',0
nom_rsc	dc.b	'help68.rsc',0
blanc	dc.b	'       ',0
anet	dc.b	'An*',0
an	dc.b	'An',0
dnet	dc.b	'Dn*',0
dn	dc.w	'Dn',0
indictab	dc.b	' ?01 '
	even
long	equ	18
instruc:
_abcd	dc.b	1,2,0,0
	dc.w	bxp+bni+bzp+bvi+bcp
	dc.w	m1+lb,m1,m5+lb,m5,0,0
_add	dc.b	3,4,0,add
	dc.w	bp
	dc.w	mtout+lbwl,m1,m1+lbwl,mdest-m1,0,0
_adda	dc.b	5,0,0,0
	dc.w	bna
	dc.w	mtout+lw+ll,m2,0,0,0,0
_addi	dc.b	6,0,0,0
	dc.w	bp
	dc.w	m12+lbwl,mdest,0,0,0,0
_addq	dc.b	6,0,0,addq
	dc.w	bp
	dc.w	m12+lbwl,mdest+m2,0,0,0,0
_addx	dc.b	1,2,0,0
	dc.w	bp
	dc.w	m1+lbwl,m1,m5+lbwl,m5,0,0
_and	dc.b	3,4,0,0
	dc.w	bnp+bzp+bv0+bc0
	dc.w	lbwl+mtout-m2,m1,lbwl+m1,mdest-m1,0,0
_andi	dc.b	6,0,0,0
	dc.w	bnp+bzp+bv0+bc0
	dc.w	lbwl+m12,mdest,0,0,0,0
_andic	dc.b	7,0,0,0
	dc.w	bp
	dc.w	lb+m12,0,0,0,0,0
_andis	dc.b 	8,0,0,privileg
	dc.w	bp
	dc.w	lw+m12,0,0,0,0,0
_asl	dc.b	1,9,10,asl
	dc.w	bp
	dc.w	lbwl+m1,m1,lbwl+m12,m1,lb,mdest-m1
_asr	dc.b	1,9,10,asr
	dc.w	bp
	dc.w	lbwl+m1,m1,lbwl+m12,m1,lb,mdest-m1
_bcc	dc.b	11,0,0,0
	dc.w	bna
	dc.w	0,0,0,0,0,0
_bchg	dc.b	4,6,0,bitoper
	dc.w	bzp
	dc.w	lb+ll+m1,mdest,lb+ll+m12,mdest,0,0
_bclr	dc.b	4,6,0,bitoper
	dc.w	bzp
	dc.w	lb+ll+m1,mdest,lb+ll+m12,mdest,0,0
_bra	dc.b	11,0,0,0
	dc.w	bna
	dc.w	0,0,0,0,0,0
_bset	dc.b	4,6,0,bitoper
	dc.w	bzp
	dc.w	lb+ll+m1,mdest,lb+ll+m12,mdest,0,0
_bsr	dc.b	11,0,0,0
	dc.w	bna,0,0,0,0,0,0
_btst	dc.b	4,6,0,bitoper
	dc.w	bzp
	dc.w	lb+ll+m1,mdest,lb+ll+m12,mdest,0,0
_chk	dc.b	3,0,0,chk
	dc.w	bnp+bzi+bvi+bci
	dc.w	lw+mtout-m2,m1,0,0,0,0
_clr	dc.b	10,0,0,0
	dc.w	bn0+bz1+bv0+bc0
	dc.w	lbwl,mdest,0,0,0,0
_cmp	dc.b	3,0,0,add
	dc.w	bnp+bzp+bvp+bcp
	dc.w	lbwl+mtout,m1,0,0,0,0
_cmpa	dc.b	5,0,0,0
	dc.w	bnp+bzp+bvp+bcp
	dc.w	lw+ll+mtout,m2,0,0,0,0
_cmpi	dc.b	6,0,0,0
	dc.w	bnp+bzp+bvp+bcp
	dc.w	lbwl+m12,mdest,0,0,0,0
_cmpm	dc.b	12,0,0,0
	dc.w	bnp+bzp+bvp+bcp
	dc.w	lbwl+m4,m4,0,0,0,0
_dbcc	dc.b	13,0,0,dbcc
	dc.w	bna
	dc.w	lw+m1,0,0,0,0,0
_divs	dc.b	3,0,0,divise
	dc.w	bnp+bzp+bvp+bc0
	dc.w	lw+mtout-m2,m1,0,0,0,0
_divu	dc.b	3,0,0,divise
	dc.w	bnp+bzp+bvp+bc0
	dc.w	lw+mtout-m2,m1,0,0,0,0
_eor	dc.b	4,0,0,0
	dc.w	bnp+bzp+bv0+bc0
	dc.w	lbwl+m1,mdest,0,0,0,0
_eori	dc.b	6,0,0,0
	dc.w	bnp+bzp+bv0+bc0
	dc.w	lbwl+m12,mdest,0,0,0,0
_eoric	dc.b	7,0,0,0
	dc.w	bp
	dc.w	lb+m12,0,0,0,0,0
_eoris	dc.b	8,0,0,privileg
	dc.w	bp
	dc.w	lw+m12,0,0,0,0,0
_exg	dc.b	14,0,0,0
	dc.w	bna
	dc.w	ll+m1+m2,m1+m2,0,0,0,0
_ext	dc.b	15,0,0,0
	dc.w	bnp+bzp+bv0+bc0
	dc.w	lw+ll,m1,0,0,0,0
_illegal	dc.b	0,0,0,illegal
	dc.w	bna,0,0,0,0,0,0
_jmp	dc.b	10,0,0,0
	dc.w	bna
	dc.w	0,m3+m6+m7+m8+m9+m10+m11,0,0,0,0
_jsr	dc.b	10,0,0,0
	dc.w	bna
	dc.w	0,m3+m6+m7+m8+m9+m10+m11,0,0,0,0
_lea	dc.b	5,0,0,0
	dc.w	bna
	dc.w	ll+m3+m6+m7+m8+m9+m10+m11,m2,0,0,0,0
_link	dc.b	16,0,0,0
	dc.w	bna
	dc.w	m2,m12,0,0,0,0
_lsl	dc.b	1,9,10,asl
	dc.w	bxp+bnp+bzp+bv0+bcp
	dc.w	lbwl+m1,m1,lbwl+m12,m1,lb,mdest-m1
_lsr	dc.b	1,9,10,lsr
	dc.w	bxp+bnp+bzp+bv0+bcp
	dc.w	lbwl+m1,m1,lbwl+m12,m1,lb,mdest-m1
_move	dc.b	17,0,0,add
	dc.w	bnp+bzp+bv0+bc0
	dc.w	lbwl+mtout,mdest,0,0,0,0
_movec	dc.b	18,0,0,0
	dc.w	bp
	dc.w	lb+mtout-m2,0,0,0,0,0
_movea	dc.b	5,0,0,0
	dc.w	bna
	dc.w	lw+ll+mtout,m2,0,0,0,0
_moveu	dc.b	19,20,0,privileg
	dc.w	bna
	dc.w	ll,m2,ll+m2,0,0,0
_movefs	dc.b	21,0,0,0
	dc.w	bna
	dc.w	lw,mdest,0,0,0,0
_movets	dc.b	22,0,0,privileg
	dc.w	bp
	dc.w	lw+mtout-m2,0,0,0,0,0
_movem	dc.b	23,24,0,0
	dc.w	bna
	dc.w	lw+ll+m1+m2,m3+m5+m6+m7+m8+m9
	dc.w	lw+ll+m3+m4+m6+m7+m8+m9+m10+m11,m1+m2,0,0
_movep	dc.b	25,26,0,0
	dc.w	bna
	dc.w	lw+ll+m1,m6,lw+ll+m6,m1,0,0
_moveq	dc.b	27,0,0,moveq
	dc.w	bnp+bzp+bv0+bc0
	dc.w	ll+m12,m1,0,0,0,0
_muls	dc.b	3,0,0,0
	dc.w	bnp+bzp+bv0+bc0
	dc.w	lw+mtout-m2,m1,0,0,0,0
_mulu	dc.b	3,0,0,0
	dc.w	bnp+bzp+bv0+bc0
	dc.w	lw+mtout-m2,m1,0,0,0,0
_nbcd	dc.b	10,0,0,0
	dc.w	bxp+bni+bzp+bvi+bcp
	dc.w	lb,mdest,0,0,0,0
_neg	dc.b	10,0,0,0
	dc.w	bp
	dc.w	lbwl,mdest,0,0,0,0
_negx	dc.b	10,0,0,0
	dc.w	bxp+bni+bzp+bvi+bcp
	dc.w	lbwl,mdest,0,0,0,0
_nop	dc.b	0,0,0,0
	dc.w	bna,0,0,0,0,0,0
_not	dc.b	10,0,0,0
	dc.w	bnp+bzp+bv0+bc0
	dc.w	lbwl,mdest,0,0,0,0
_or	dc.b	3,4,0,0
	dc.w	bnp+bzp+bv0+bc0
	dc.w	lbwl+mtout-m2,m1,lbwl+m1,mdest-m1,0,0
_ori	dc.b	6,0,0,0
	dc.w	bnp+bzp+bv0+bc0
	dc.w	lbwl+m12,mdest,0,0,0,0
_oric	dc.b	7,0,0,0
	dc.w	bp
	dc.w	lb+m12,0,0,0,0,0
_oris	dc.b	8,0,0,privileg
	dc.w	bp
	dc.w	lw+m12,0,0,0,0,0
_pea	dc.b	10,0,0,0
	dc.w	bna
	dc.w	ll+m3+m6+m7+m8+m9+m10+m11,0,0,0,0,0
_reset	dc.b	0,0,0,privileg
	dc.w	bna
	dc.w	0,0,0,0,0,0
_rol	dc.b	1,9,10,rol
	dc.w	bnp+bzp+bv0+bcp
	dc.w	lbwl+m1,m1,lbwl+m12,m1,lb,mdest-m1
_ror	dc.b	1,9,10,ror
	dc.w	bnp+bzp+bv0+bcp
	dc.w	lbwl+m1,m1,lbwl+m12,m1,lb,mdest-m1
_roxl	dc.b	1,9,10,roxl
	dc.w	bxp+bnp+bzp+bv0+bcp
	dc.w	lbwl+m1,m1,lbwl+m12,m1,lb,mdest-m1
_roxr	dc.b	1,9,10,roxr
	dc.w	bxp+bnp+bzp+bv0+bcp
	dc.w	lbwl+m1,m1,lbwl+m12,m1,lb,mdest-m1
_rte	dc.b	0,0,0,privileg
	dc.w	bp,0,0,0,0,0,0
_rtr	dc.b	0,0,0,0
	dc.w	bp,0,0,0,0,0,0
_rts	dc.b	0,0,0,0
	dc.w	bna,0,0,0,0,0,0
_sbcd	dc.b	1,2,0,0
	dc.w	bxp+bni+bzp+bvi+bcp
	dc.w	lb+m1,m1,lb+m5,m5,0,0
_scc	dc.b	10,0,0,scc
	dc.w	bna,lb,mdest,0,0,0,0
_stop	dc.b	28,0,0,privileg
	dc.w	bp,m12,0,0,0,0,0
_sub	dc.b	3,4,0,add
	dc.w	bp,lbwl+mtout,m1,lbwl+m1,mdest-m1,0,0
_suba	dc.b	5,0,0,0
	dc.w	bna,lw+ll+mtout,m2,0,0,0,0
_subi	dc.b	6,0,0,0
	dc.w	bp,lbwl+m12,mdest,0,0,0,0
_subq	dc.b	6,0,0,addq
	dc.w	bp,lbwl+m12,mdest+m2,0,0,0,0
_subx	dc.b	1,2,0,0
	dc.w	bp,lbwl+m1,m1,lbwl+m5,m5,0,0
_swap	dc.b	15,0,0,0
	dc.w	bnp+bzp+bv0+bc0
	dc.w	lw,m1,0,0,0,0
_tas	dc.b	10,0,0,0
	dc.w	bnp+bzp+bv0+bc0
	dc.w	lb,mdest,0,0,0,0
_trap	dc.b	29,0,0,trap
	dc.w	bna,m12,0,0,0,0,0
_trapv	dc.b	0,0,0,0
	dc.w	bna,0,0,0,0,0,0
_tst	dc.b	10,0,0,0
	dc.w	bnp+bzp+bv0+bc0
	dc.w	lbwl+mdest,0,0,0,0,0
_unlk	dc.b	30,0,0,0
	dc.w	bna,0,m2,0,0,0,0

*****************************

debpile	ds.w	$100
newstack	equ	*

vdipb1	dc.l	ctrlvdi1,invdi1,0,outvdi1,ptsout1
ctrlvdi1	dc.w	100,0,6,11,45,0,1
invdi1	dc.w	1,1,1,1,1,1,1,1,1,1,2
outvdi1	ds.w	45
ptsout1	ds.w	12

vdipb2	dc.l	ctrlvdi2,0,0,0,0
ctrlvdi2	dc.w	101,0,0,0,0,0,1

aespb	dc.l	ctrlaes,global,intin,intout,addrin,addrout
ctrlaes	ds.w	4
global	ds.w	16
intin	ds.w	16
intout	ds.w	8
addrin	ds.l	4
addrout	ds.l	4

id_appl	dc.w	1
id_fen	dc.w	-1
id_stat	dc.w	1
num_acc	dc.w	1
tampon	ds.w	8
xmouse	dc.w	0
ymouse	dc.w	0
key	dc.w	0
event	dc.w	0
xfen	dc.w	0
yfen	dc.w	30
lfen	dc.w	640
hfen	dc.w	360
xbase	dc.w	0
ybase	dc.w	40
lbase	dc.w	640
hbase	dc.w	350
ecran	dc.l	0
choix	dc.w	0
info	dc.w	0
fmnem	dc.b	0,0,0
foper	dc.b	0,0,0
fsource	dc.w	0
fdest	dc.w	0
findic	dc.w	0
fmasque	dc.w	0
fmasq2	dc.w	0
finfo	dc.w	0
fnames	dc.w	0
fnamed	dc.w	0
fname	dc.w	0

	end