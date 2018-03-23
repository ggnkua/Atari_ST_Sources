;celle-ci aussi entierement finie!
;change juste les vsync et les interrupts.



Ht	=	199-1	; screen height -1
Wd	=	208	; screen width -1
LSize	=	26	; bytes per line
nbr_buf	equ	50
buffer	equ	$1f0000-Lsize*200*nbr_buf-256

	clr.w	-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	PEA	DEMO(PC)
	MOVE.W	#38,-(SP)
	TRAP	#14
	LEA	6(SP),SP
	CLR.W	-(SP)
	TRAP	#1


DEMO
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,save_colors

	movem.l	colors,d0-d7
	movem.l	d0-d7,$ffff8240.w

	move.l	log,a0
	move.l	phys,a1
	move.w	#32000/4-1,d0
effecr	move.l	#0,(a0)+
	move.l	#0,(a1)+
	dbra	d0,effecr

	bsr	set_screen

	bsr	clear_buf

	bsr	prepare_line_routs

LOOPI	move.w	#37,-(sp)
	trap	#14
	lea	2(sp),sp

	move.l	pal2,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w

;	move.w	#$707,$ffff8240.w
	bsr	Gere_les_angles

	move.l	pt_buffer2,a0
	tst.l	(a0)
	bpl.s	not_ende
	lea	liste_buf2,a0
not_ende
	move.l	(a0)+,screen
	move.l	a0,pt_buffer2

	bsr	efface_buffer
	move.l	routine,a0
	jsr	(a0)

;	move.w	#$700,$ffff8240.w
	bsr	affiche_ecrans2
;	move.w	#$002,$ffff8240.w


	move.l	log,a1
	move.l	phys,a0
	exg.l	a0,a1
	move.l	a1,log
	move.l	a0,phys
	BSR	SET_SCREEN

	cmpi.b	#$39,$fffffc02.w
	bne	loopi

	movem.l	save_colors,d0-d7
	movem.l	d0-d7,$ffff8240.w

	RTS

SET_SCREEN
	move.l	a0,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
	RTS


clear_buf
	lea	buffer,a0
	move.w	#nbr_buf-1,d1
nbuf	move.w	#(Lsize*200)/4-1,d0
clr	move.l	#0,(a0)+
	dbra	d0,clr
	dbra	d1,nbuf
	rts

efface_buffer
	move.l	screen,a0
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5

e	set	0
	rept	100
	movem.l	d0-d7/a1-a5,e(a0)
e	set	e+52
	endr
	rts


Gere_les_angles
	MOVE.W	X_ANGLE1,D0
	ADDQ	#2,d0
	CMP.W	#720,D0
	blt.s	LOOP0
	sub.w	#720,d0
LOOP0	MOVE.W	D0,X_ANGLE1

	MOVE.W	Y_ANGLE1,D0
	ADDQ	#2,d0
	CMP.W	#720,D0
	blt.s	LOOP1
	sub.w	#720,d0
LOOP1	MOVE.W	D0,Y_ANGLE1

	MOVE.W	Z_ANGLE1,D0
	ADDQ	#2,d0
	CMP.W	#720,D0
	blt.s	LOOP2
	sub.w	#720,d0
LOOP2	MOVE.W	D0,Z_ANGLE1

	rts


routine	dc.l	normale

decompt1	dc.w	25
Normale
;	move.w	#$700,$ffff8240.w
	subq	#1,decompt1
	bne	pas_encore1
	move.l	#transf,routine
	move.w	#50*5,decompt1
	lea	object,a0
	move.l	pt_transf,a1
	move.l	4(a1),a2
	move.l	(a1),a1
	move.w	#nbr_pts*3-1,d3
yo1	move.w	(a0)+,d0
	move.w	(a2)+,d1
	cmp.w	d1,d0
	blt	plus_gd
	bgt	plus_pt
	move.w	#0,(a1)+
	dbra	d3,yo1
	bra	pas_encore1
plus_gd	move.w	#1,(a1)+
	dbra	d3,yo1
	bra	pas_encore1
plus_pt	move.w	#-1,(a1)+
	dbra	d3,yo1

pas_encore1
	move.w	x_angle1,x_angle
	move.w	y_angle1,y_angle
	move.w	z_angle1,z_angle
	bsr	Object_Draw

	rts

objfin	dc.l	0
transf
;	move.w	#$070,$ffff8240.w
	lea	object,a1
	move.l	pt_transf,a2
	move.l	(a2),a0
	move.l	4(a2),a2
	move.l	a2,objfin
	moveq	#0,d2
	move.w	#nbr_pts*3-1,d4
next_c	move.w	(a1),d0
	move.w	(a0)+,d1
	add.w	d1,d0
	cmp.w	(a2)+,d0
	bne.s	not_equal
	neg.w	d1
	add.w	d1,d0
	addq.w	#1,d2
not_equal
	move.w	d0,(a1)+
	dbra	d4,next_c

	cmp.w	#nbr_pts*3,d2
	bne.s	pas_encore2
	move.l	#normale,routine
	move.l	pt_transf,a0
	move.l	4(a0),a0
	lea	object,a1
	move.w	nbrs,d3
loop_n2	movem.w	(a0)+,d0-d2
	movem.w	d0-d2,(a1)
	lea	3*2(a1),a1
	dbra	d3,loop_n2
	move.l	pt_transf,a1
	add.l	#8,a1
	tst.l	(a1)
	bpl.s	okay3
	lea	tab_transf,a1
okay3	move.l	a1,pt_transf
pas_encore2
	move.w	x_angle1,x_angle
	move.w	y_angle1,y_angle
	move.w	z_angle1,z_angle
	bsr	object_draw
	rts



TRIGO	MOVEM.L	D0-D7/A4-A6,-(SP)
	LEA	COS_TAB,A4
	LEA	SIN_TAB,A5
	LEA	X_ANGLE,A6
	MOVE.W	(A6)+,D2
	MOVE.W	(A6)+,D1
	MOVE.W	(A6)+,D0
	MOVE.W	0(A5,D2.W),D5
	MOVE.W	0(A4,D2.W),D4
	MOVE.W	0(A5,D1.W),D3
	MOVE.W	0(A4,D1.W),D2
	MOVE.W	0(A5,D0.W),D1
	MOVE.W	0(A4,D0.W),D0
	LEA	VAR_3D,A6
	MOVEQ	#9,D7

SP_C	MOVE.W	D3,D6
	NEG.W	D6
	MOVE.W	D6,(A6)+

SP_F	MOVE.W	D2,D6
	MULS	D5,D6
	ASR.L	D7,D6
	MOVE.W	D6,(A6)+

SP_I	MOVE.W	D2,D6
	MULS	D4,D6
	ASR.L	D7,D6
	MOVE.W	D6,(A6)+

SP_A	MOVE.W	D0,D6
	MULS	D2,D6
	ASR.L	D7,D6
	MOVE.W	D6,(A6)+

SP_D	MOVE.W	D1,D6
	MULS	D4,D6
	ASR.L	D7,D6
	MOVE.W	D6,A4

	MOVE.W	D0,D6
	MULS	D3,D6
	ASR.L	D7,D6
	MULS	D5,D6
	ASR.L	D7,D6
	SUB.W	A4,D6
	MOVE.W	D6,(A6)+

SP_G	MOVE.W	D1,D6
	MULS	D5,D6
	ASR.L	D7,D6
	MOVE.W	D6,A4

	MOVE.W	D0,D6
	MULS	D3,D6
	ASR.L	D7,D6
	MULS	D4,D6
	ASR.L	D7,D6
	ADD.W	A4,D6
	MOVE.W	D6,(A6)+

SP_B	MOVE.W	D1,D6
	MULS	D2,D6
	ASR.L	D7,D6
	MOVE.W	D6,(A6)+

SP_E	MOVE.W	D0,D6
	MULS	D4,D6
	ASR.L	D7,D6
	MOVE.W	D6,A4

	MOVE.W	D1,D6
	MULS	D3,D6
	ASR.L	D7,D6
	MULS	D5,D6
	ASR.L	D7,D6
	ADD.W	A4,D6
	MOVE.W	D6,(A6)+

SP_H	MOVE.W	D0,D6
	MULS	D5,D6
	ASR.L	D7,D6
	MOVE.W	D6,A4

	MOVE.W	D1,D6
	MULS	D3,D6
	ASR.L	D7,D6
	MULS	D4,D6
	ASR.L	D7,D6
	SUB.W	A4,D6
	MOVE.W	D6,(A6)+
	MOVEM.L	(SP)+,D0-D7/A4-A6
	RTS

SP_TO_PL

	LEA	VAR_3D,A6
	MOVE.W	D0,D3
	MOVE.W	D1,D4
	MOVE.W	D2,D5
	MULS	(A6)+,D3
	MULS	(A6)+,D4
	MULS	(A6)+,D5
	ADD.L	D4,D5
	ADD.L	D3,D5
;	ADD.L	A3,D5
	MOVE.L	D5,A5
	DIVS	Z_PT_FUITE,D5
	MOVE.W	#512,D7
	SUB.W	D5,D7
	MOVE.W	D0,D3
	MOVE.W	D1,D4
	MOVE.W	D2,D5
	MULS	(A6)+,D3
	MULS	(A6)+,D4
	MULS	(A6)+,D5
	ADD.L	D4,D5
	ADD.L	D3,D5
;	ADD.L	A1,D5
	MOVE.L	D5,A4
	DIVS	D7,D5
	MULS	(A6)+,D0
	MULS	(A6)+,D1
	MULS	(A6)+,D2
	ADD.L	D0,D1
	ADD.L	D1,D2
;	ADD.L	A2,D2
	MOVE.L	D2,D6
	DIVS	D7,D2
	ADD.W	#104,D5
	ADD.W	#100,D2
	RTS


OBJECT_DRAW
	MOVEM.L	D0-D7/A0/A2-A6,-(SP)
	BSR	TRIGO
	LEA	OBJECT,A0
	lea	trace,a1
	MOVE.W	nbrs,D4
PTS
	MOVE.w	(A0)+,d0
	MOVE.w	(A0)+,d1
	MOVE.W	(A0)+,d2
	movem.l	a0/a1/d4,-(sp)
	BSR	SP_TO_PL
	movem.l	(sp)+,a0/a1/d4
	move.w	d5,(a1)+
	move.w	d2,(a1)+
	DBRA	D4,PTS

	
	lea	trace,a0
	move.w	nbrls,d4
next_l
	movem.w	(a0)+,d0-d3
	movem.l	a0/d4,-(sp)
	bsr	fastline
	movem.l	(sp)+,a0/d4
	dbra	d4,next_l

	MOVEM.L	(SP)+,D0-D7/A0/A2-A6
	RTS


; Line routine by Axel/HMD
; Converted from ST to Amiga
; Draws only one plane lines !
;


pt_buffer	dc.l	liste_buf
	dc.l	buffer+200*26
	dc.l	buffer+200*26*2
	dc.l	buffer+200*26*3
liste_buf
	dc.l	buffer
	dc.l	buffer+200*26
	dc.l	buffer+200*26*2
	dc.l	buffer+200*26*3
	dc.l	-1

bitplane
	dc.l	bit_list
bit_list
	dc.w	0,2,2,4,4,6,6,0,-1



affiche_ecrans

	move.l	log,a1
	move.l	bitplane,a2
	tst.w	(a2)
	bpl.s	not_fin
	lea	bit_list,a2
not_fin
	move.w	(a2)+,d0
	move.l	a2,bitplane
	add.w	d0,a1

	lsl.w	#4,d0
	lea	colors,a4
	add.w	d0,a4
	move.l	a4,pal2
	
	move.l	pt_buffer2,a2
	tst.l	(a2)
	bpl.s	sodomisation
	lea	liste_buf2,a2
sodomisation
	move.l	(a2),a0

lg	set	0
	rept	200
	movem.w	(a0)+,d0-d7/a2-a6
	move.w	d0,lg(a1)
	move.w	d1,8+lg(a1)
	move.w	d2,16+lg(a1)
	move.w	d3,24+lg(a1)
	move.w	d4,32+lg(a1)
	move.w	d5,40+lg(a1)
	move.w	d6,48+lg(a1)
	move.w	d7,56+lg(a1)
	move.w	a2,64+lg(a1)
	move.w	a3,72+lg(a1)
	move.w	a4,80+lg(a1)
	move.w	a5,88+lg(a1)
	move.w	a6,96+lg(a1)
lg	set	lg+160
	endr

	rts



affiche_ecrans2

	move.l	log,a1
	move.l	bitplane,a2
	tst.w	(a2)
	bpl.s	not_fin2
	lea	bit_list,a2
not_fin2
	move.w	(a2)+,d0
	move.l	a2,bitplane
	add.w	d0,a1

	lsl.w	#4,d0
	lea	colors,a4
	add.w	d0,a4
	move.l	a4,pal2

	move.l	pt_buffer2,a2
	moveq	#0,d0
_boucle
	cmp.l	#-1,(a2)
	bne.s	not_ende3
	lea	liste_buf2,a2
not_ende3
	move.l	(a2)+,a0
	add.w	d0,a0
	add.w	#26*4,d0
	movem.l	d0/a2,-(sp)

lg	set	0
	movem.w	(a0)+,d0-d7/a2-a6
	move.w	d0,lg(a1)
	move.w	d1,8+lg(a1)
	move.w	d2,16+lg(a1)
	move.w	d3,24+lg(a1)
	move.w	d4,32+lg(a1)
	move.w	d5,40+lg(a1)
	move.w	d6,48+lg(a1)
	move.w	d7,56+lg(a1)
	move.w	a2,64+lg(a1)
	move.w	a3,72+lg(a1)
	move.w	a4,80+lg(a1)
	move.w	a5,88+lg(a1)
	move.w	a6,96+lg(a1)
lg	set	lg+160
	movem.w	(a0)+,d0-d7/a2-a6
	move.w	d0,lg(a1)
	move.w	d1,8+lg(a1)
	move.w	d2,16+lg(a1)
	move.w	d3,24+lg(a1)
	move.w	d4,32+lg(a1)
	move.w	d5,40+lg(a1)
	move.w	d6,48+lg(a1)
	move.w	d7,56+lg(a1)
	move.w	a2,64+lg(a1)
	move.w	a3,72+lg(a1)
	move.w	a4,80+lg(a1)
	move.w	a5,88+lg(a1)
	move.w	a6,96+lg(a1)
lg	set	lg+160
	movem.w	(a0)+,d0-d7/a2-a6
	move.w	d0,lg(a1)
	move.w	d1,8+lg(a1)
	move.w	d2,16+lg(a1)
	move.w	d3,24+lg(a1)
	move.w	d4,32+lg(a1)
	move.w	d5,40+lg(a1)
	move.w	d6,48+lg(a1)
	move.w	d7,56+lg(a1)
	move.w	a2,64+lg(a1)
	move.w	a3,72+lg(a1)
	move.w	a4,80+lg(a1)
	move.w	a5,88+lg(a1)
	move.w	a6,96+lg(a1)
lg	set	lg+160
	movem.w	(a0)+,d0-d7/a2-a6
	move.w	d0,lg(a1)
	move.w	d1,8+lg(a1)
	move.w	d2,16+lg(a1)
	move.w	d3,24+lg(a1)
	move.w	d4,32+lg(a1)
	move.w	d5,40+lg(a1)
	move.w	d6,48+lg(a1)
	move.w	d7,56+lg(a1)
	move.w	a2,64+lg(a1)
	move.w	a3,72+lg(a1)
	move.w	a4,80+lg(a1)
	move.w	a5,88+lg(a1)
	move.w	a6,96+lg(a1)
	lea	160*4(a1),a1
	movem.l	(sp)+,d0/a2

	subq	#1,decompt
	bne	_boucle
	move.w	#50,decompt
	rts


decompt	dc.w	50


pt_buffer2	dc.l	liste_buf2
	dc.l	buffer+26*200*61
	dc.l	buffer+26*200*62
	dc.l	buffer+26*200*63
liste_buf2
bf	set	0
	rept	nbr_buf
	dc.l	buffer+bf
bf	set	bf+26*200
	endr
	dc.l	-1




remet_object
	lea	objet2,a0
	lea	object,a1
	move.w	#nbr_pts-1,d0
rem	move.w	(a0)+,(a1)+
	dbra	d0,rem
	rts


prepare_line_routs
	lea	Offset,a0
	lea	(Wd+1)*4(a0),a1
	moveq	#0,d0
lp
	moveq	#$f,d1
	and.w	d0,d1
	move.w	#$8000,d2
	lsr.w	d1,d2
	move.w	d2,(a0)+
	moveq	#-1,d2
	lsr.w	d1,d2
	move.w	d2,(a1)+	
	moveq	#$f0,d1
	and.w	d0,d1
	asr.w	#3,d1
	move.w	d1,(a0)+
	move.w	d1,(a1)+
	addq.w	#1,d0
	cmp.w	#Wd+1,d0
	blo.s	lp

; Conversion table for Y coordinates

	lea	MulY,a0
	move.w	#Ht,d0
	moveq	#0,d1
calc
	move.w	d1,(a0)+
	add.w	#LSize,d1
	dbra	d0,calc
	rts


X1	Equr	d0
Y1	Equr	d1
X2	Equr	d2
Y2	Equr	d3

ret	rts
FastLine
	move.l	Screen(pc),a0	; screen address
	lea	MulY,a2
	lea	Offset,a3
	lea	(Wd+1)*4(a3),a1
	cmp.w	Y1,Y2
	bge.s	.skip4
	exg	Y1,Y2
	exg	X1,X2
; Y1<Y2		
.skip4
	cmp.w	#Ht,Y1
	bgt.s	ret
	bls.s	.skip5
 
; Y1<0 => clipping

	muls	Y2,X1
	move.w	X2,d4
	muls	Y1,d4
	sub.l	d4,X1
	move.w	Y2,d4
	bmi.s	ret
	sub.w	Y1,d4
	divs	d4,X1
	sub.w	Y1,Y1

.skip5
	cmp.w	#Ht,Y2
	ble.s	.skip6

; Y2>Ht => clipping

	move.w	Y2,d4
	muls	X1,d4
	move.w	X2,d5
	muls	Y1,d5
	sub.l	d5,d4
	sub.w	X1,X2
	muls	#Ht,X2
	add.l	d4,X2
	sub.w	Y1,Y2
	divs	Y2,X2
	move.w	#Ht,Y2

.skip6
	cmp.w	X1,X2
	ble.s	.skip1
	exg	X1,X2
	exg	Y1,Y2
; X2<X1
.skip1
	cmp.w	#Wd,X2
	bgt.s	ret
	bls.s	.skip2
 
; X2<0 => clipping

	muls	X1,Y2
	move.w	Y1,d4
	muls	X2,d4
	sub.l	d4,Y2
	move.w	X1,d4
	bmi.s	ret
	sub.w	X2,d4
	divs	d4,Y2
	sub.w	X2,X2

.skip2
	cmp.w	#Wd,X1
	ble.s	.skip3

; X1>Wd => clipping

	move.w	X1,d4
	muls	Y2,d4
	move.w	Y1,d5
	muls	X2,d5
	sub.l	d5,d4
	sub.w	Y2,Y1
	muls	#Wd,Y1
	add.l	d4,Y1
	sub.w	X2,X1
	divs	X1,Y1
	move.w	#Wd,X1

.skip3
	sub.w	Y1,Y2		; Dy
	beq	HLine

	sub.w	X1,X2		; Dx
	beq	VLine

	neg.w	d2
	add.w	d0,d0
	add.w	d0,d0
	move.l	(a3,d0.w),d0
	add.w	d1,d1
	add.w	(a2,d1.w),d0
	add.w	d0,a0
	swap	d0
	moveq	#LSize,d1
 
	tst.w	d3
	bpl.s	.skip9
	neg.w	d3
	neg.w	d1
 
.skip9
	cmp.w	d3,d2
	bgt	DxGtDy
	beq	DxEqDy
	
DxLtDy
	swap	d2		; Dx/Dy*65536
	clr.w	d2
	divu	d3,d2
	
	lsl.w	#4,d3
	neg.w	d3
	add.w	#16*Ht,d3
	moveq	#0,d4
	or.w	d0,(a0)
	jmp	.line(pc,d3.w)
.line
	rept	Ht
	add.w	d2,d4
	dc.w	$6408		;bcc.s	.skip
	add.w	d0,d0
	dc.w	$6404		;bcc.s	.skip
	subq.w	#2,a0
	moveq	#1,d0
;.skip	
	add.w	d1,a0
	or.w	d0,(a0)
	endr
	rts
	
DxGtDy
	swap	d3		; Dy/Dx*65536
	clr.w	d3
	divu	d2,d3

	add.w	d2,d2
	move.w	d2,d4
	add.w	d4,d4
	add.w	d4,d2
	add.w	d4,d4
	add.w	d4,d4
	add.w	d4,d2
	neg.w	d2
	add.w	#22*Wd,d2
	moveq	#0,d4
	move.w	(a0),d5
	or.w	d0,d5
	jmp	.line(pc,d2.w)
.line
	rept	Wd
	add.w	d3,d4
	dc.w	$6406		;bcc.s	.skip
	move.w	d5,(a0)
	add.w	d1,a0
	move.w	(a0),d5
;.skip
	add.w	d0,d0
	dc.w	$6406		;bcc.s	.skip2
	move.w	d5,(a0)
	moveq	#1,d0
	move.w	-(a0),d5
;.skip2
	or.w	d0,d5
	endr
	move.w	d5,(a0)
	rts
	
DxEqDy
	add.w	d2,d2
	add.w	d2,d2
	move.w	d2,d3
	add.w	d3,d3
	add.w	d3,d2
	neg.w	d2
	add.w	#12*Ht,d2
	or.w	d0,(a0)
	jmp	.line(pc,d2.w)
.line
	rept	Ht
	add.w	d0,d0
	dc.w	$6404		;bcc.s	.skip
	subq.w	#2,a0
	moveq	#1,d0
;.skip	
	add.w	d1,a0
	or.w	d0,(a0)
	endr
	rts
	
VLine		
	add.w	d0,d0
	add.w	d0,d0
	move.l	(a3,d0.w),d0
	
	tst.w	d3
	bpl.s	.skip
	add.w	d3,d1
	neg.w	d3
.skip
	add.w	d1,d1
	add.w	(a2,d1.w),d0
	add.w	d0,a0
	swap	d0
 
 	neg.w	d3
	add.w	d3,d3
	add.w	d3,d3
	add.w	#4*Ht,d3
	or.w	d0,(a0)
	jmp	.line(pc,d3.w)
.line
k	set	Ht*LSize
	rept	Ht
	or.w	d0,k(a0)
k	set	k-LSize
	endr
	rts

HLine
	add.w	d0,d0
	add.w	d0,d0
	move.l	(a1,d0.w),d0
	add.w	d2,d2
	add.w	d2,d2
	move.l	(a1,d2.w),d2
	add.w	d1,d1
	move.w	(a2,d1.w),d1
	add.w	d0,d1
	add.w	d1,a0

	sub.w	d0,d2
	bmi.s	.cont
	swap	d0
	swap	d2
	not.w	d0
	and.w	d2,d0
	or.w	d0,(a0)
	rts
.cont
	swap	d0
	not.w	d0
	or.w	d0,(a0)
	moveq	#-1,d0
	jmp	.line+2(pc,d2.w)
	rept	LSize/2-2
	move.w	d0,-(a0)
	endr
.line	swap	d2
	or.w	d2,-(a0)
	rts



Offset	ds.l	(Wd+1)*2
MulY	ds.w	Ht+1



COS_TAB	INCBIN	B:COSIN.DAT
SIN_TAB	EQU	COS_TAB+720

save_colors	ds.l	8
pal1	dc.l	colors
pal2	dc.l	colors+32

;	dc.w	$012,$023,$134,$145,$256,$267,$367,$467
;	dc.w	$567,$667,$677,$777,$
colors
	dc.w	$001,$145,$012,$256,$023,$267,$145,$367
	dc.w	$134,$367,$145,$467,$256,$567,$367,$667

	dc.w	$001,$134,$145,$367,$012,$145,$256,$467
	dc.w	$023,$256,$267,$567,$134,$267,$367,$667

	dc.w	$001,$023,$134,$256,$145,$267,$367,$567
	dc.w	$012,$134,$145,$267,$256,$367,$467,$667

	dc.w	$001,$012,$023,$134,$134,$145,$256,$267
	dc.w	$145,$256,$267,$367,$367,$467,$567,$667


OLD_SCREEN	DS.L	1
log	dc.l	$1f0000
phys	dc.l	$1f8000
logique	dc.l	0
screen	ds.l	0
ECR_FLAG	DS.W	1
ROT_FLAG	DS.W	1
OLD_RES		DS.W	1

nbr_lines	equ	12
NBR_PTS	EQU	nbr_lines*2

pt_transf	dc.l	tab_transf
tab_transf
	dc.l	ajout1,objet1
	dc.l	ajout1,objet2
	dc.l	ajout1,objet3	
	dc.l	ajout1,objet4
	dc.l	ajout1,objet5
	dc.l	ajout1,objet6
	dc.l	ajout1,objet7
	dc.l	ajout1,objet8
	dc.l	-1,-1

OBJECT
	ds.w	nbr_pts*3

	dc.w	50,50,50
	dc.w	50,50,-50

	dc.w	50,50,-50
	dc.w	50,-50,-50

	dc.w	50,50,-50	
	dc.w	-50,50,-50

	dc.w	50,-50,-50
	dc.w	-50,-50,-50

	dc.w	-50,50,-50
	dc.w	-50,-50,-50

	dc.w	-50,50,-50
	dc.w	-50,50,50

	dc.w	-50,-50,-50
	dc.w	-50,-50,50

	dc.w	50,-50,50
	dc.w	50,-50,-50
;
	dc.w	50,50,50
	dc.w	-50,50,50

	dc.w	-50,50,50
	dc.w	-50,-50,50

	dc.w	50,-50,50
	dc.w	-50,-50,50

	dc.w	50,50,50
	dc.w	50,-50,50


;coordonnees des extremites de chaque ligne
objet1
	dc.w	-55,45,0
	dc.w	-55,-45,0

	dc.w	-55,0,0
	dc.w	-20,0,0

	dc.w	-20,45,0
	dc.w	-20,-45,0

	dc.w	-20,-45,0
	dc.w	0,0,0

	dc.w	0,0,0
	dc.w	20,-45,0

	dc.w	20,45,0
	dc.w	20,-45,0

	dc.w	20,-45,0
	dc.w	40,-45,0

	dc.w	40,-45,0
	dc.w	50,-35,0

	dc.w	50,-35,0
	dc.w	55,0,0

	dc.w	55,0,0
	dc.w	50,35,0

	dc.w	50,35,0
	dc.w	40,45,0

	dc.w	40,45,0
	dc.w	20,45,0


ajout1	ds.w	nbr_pts*3

objet2
	dc.w	50,50,50
	dc.w	50,50,-50

	dc.w	50,50,-50
	dc.w	50,-50,-50

	dc.w	50,50,-50
	dc.w	-50,50,-50

	dc.w	50,-50,-50
	dc.w	-50,-50,-50

	dc.w	-50,50,-50
	dc.w	-50,-50,-50

	dc.w	-50,50,-50
	dc.w	-50,50,50

	dc.w	-50,-50,-50
	dc.w	-50,-50,50

	dc.w	50,-50,50
	dc.w	50,-50,-50
;
	dc.w	50,50,50
	dc.w	-50,50,50

	dc.w	-50,50,50
	dc.w	-50,-50,50

	dc.w	50,-50,50
	dc.w	-50,-50,50

	dc.w	50,50,50
	dc.w	50,-50,50


objet3	dc.w	0,55,0
	dc.w	-55,0,55

	dc.w	0,55,0
	dc.w	55,0,55

	dc.w	0,55,0
	dc.w	-55,0,-55

	dc.w	-55,0,55
	dc.w	-55,0,-55

	dc.w	55,0,55
	dc.w	55,0,-55

	dc.w	0,-55,0
	dc.w	-55,0,55

	dc.w	0,-55,0
	dc.w	55,0,55

	dc.w	0,55,0
	dc.w	55,0,-55

	dc.w	-55,0,55
	dc.w	55,0,55

	dc.w	-55,0,-55
	dc.w	55,0,-55


	dc.w	0,-55,0
	dc.w	-55,0,-55

	dc.w	0,-55,0
	dc.w	55,0,-55

objet4	dc.w	50,40,50
	dc.w	50,40,-50

	dc.w	-50,40,-50
	dc.w	50,-40,50

	dc.w	50,40,-50
	dc.w	-50,40,-50

	dc.w	50,-40,-50
	dc.w	-50,-40,-50

	dc.w	-50,40,50
	dc.w	50,-40,-50

	dc.w	-50,40,-50
	dc.w	-50,40,50

	dc.w	-50,-40,-50
	dc.w	-50,-40,50

	dc.w	50,-40,50
	dc.w	50,-40,-50

	dc.w	50,40,50
	dc.w	-50,40,50

	dc.w	50,40,50
	dc.w	-50,-40,-50

	dc.w	50,-40,50
	dc.w	-50,-40,50

	dc.w	50,40,-50
	dc.w	-50,-40,50


objet5	dc.w	-45,45,45
	dc.w	-45,-45,45

	dc.w	-45,45,-45
	dc.w	-45,-45,-45

	dc.w	-45,45,45
	dc.w	-45,45,-45

	dc.w	-45,-45,45
	dc.w	-45,-45,-45


	dc.w	0,45,45
	dc.w	0,-45,45

	dc.w	0,45,-45
	dc.w	0,-45,-45

	dc.w	0,45,45
	dc.w	0,45,-45

	dc.w	0,-45,45
	dc.w	0,-45,-45

	dc.w	45,45,45
	dc.w	45,-45,45

	dc.w	45,45,-45
	dc.w	45,-45,-45

	dc.w	45,45,45
	dc.w	45,45,-45

	dc.w	45,-45,45
	dc.w	45,-45,-45


objet6	dc.w	-55,55,0
	dc.w	55,55,0

	dc.w	-55,-55,0
	dc.w	55,-55,0

	dc.w	-55,0,55
	dc.w	55,0,55

	dc.w	-55,0,-55
	dc.w	55,0,-55

	dc.w	0,55,55
	dc.w	0,55,-55

	dc.w	0,-55,55
	dc.w	0,-55,-55

	dc.w	-55,0,55
	dc.w	-55,0,-55

	dc.w	55,0,55
	dc.w	55,0,-55

	dc.w	-55,55,0
	dc.w	-55,-55,0

	dc.w	55,55,0
	dc.w	55,-55,0

	dc.w	0,55,55
	dc.w	0,-55,55

	dc.w	0,55,-55
	dc.w	0,-55,-55

objet7	dc.w	0,65,0
	dc.w	0,0,30

	dc.w	0,65,0
	dc.w	0,0,-30

	dc.w	0,-65,0
	dc.w	0,0,-30

	dc.w	0,-65,0
	dc.w	0,0,30

	dc.w	65,40,0
	dc.w	0,0,30

	dc.w	65,40,0
	dc.w	0,0,-30

	dc.w	65,-40,0
	dc.w	0,0,30

	dc.w	65,-40,0
	dc.w	0,0,-30

	dc.w	-65,40,0
	dc.w	0,0,30

	dc.w	-65,40,0
	dc.w	0,0,-30

	dc.w	-65,-40,0
	dc.w	0,0,30

	dc.w	-65,-40,0
	dc.w	0,0,-30


objet8	ds.w	nbr_pts*3


trace	ds.l	nbr_pts

nbrs	dc.w	nbr_pts-1
nbrls	dc.w	nbr_lines-1

PT_EF	DC.L	BUF_PT1
	DC.L	BUF_PT2

BUF_PT1	REPT	NBR_PTS
	DC.L	$78000
	ENDR
BUF_PT2	REPT	NBR_PTS
	DC.L	$78000
	ENDR


X_ANGLE	DC.W	0
Y_ANGLE	DC.W	0
Z_ANGLE	DC.W	0
X_ANGLE1	DC.W	0
Y_ANGLE1	DC.W	0
Z_ANGLE1	DC.W	0
X_ANGLE2	DC.W	0
Y_ANGLE2	DC.W	0
Z_ANGLE2	DC.W	0
X_ANGLE3	DC.W	0
Y_ANGLE3	DC.W	0
Z_ANGLE3	DC.W	0
X_ANGLE4	DC.W	0
Y_ANGLE4	DC.W	0
Z_ANGLE4	DC.W	0
Z_PT_FUITE	DC.W	256
VAR_3D	DS.W	9

FIN_PRG
	END
