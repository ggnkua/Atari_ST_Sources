vsync:	macro
	move.l	$466.w,d0
.\@l1:
	cmp.l	$466.w,d0
	beq.s	.\@l1
	endm

put:	macro

	MOVE.B	(A0)+,0(A1)
	MOVE.B	(A0)+,1(A1)
	MOVE.B	(A0)+,8(A1)
	MOVE.B	(A0)+,9(A1)
	MOVE.B	(A0)+,$10(A1)
	MOVE.B	(A0)+,$11(A1)
	MOVE.B	(A0)+,$18(A1)
	MOVE.B	(A0)+,$19(A1)
	MOVE.B	(A0)+,$20(A1)
	MOVE.B	(A0)+,$21(A1)
	MOVE.B	(A0)+,$28(A1)
	MOVE.B	(A0)+,$29(A1)
	MOVE.B	(A0)+,$30(A1)
	MOVE.B	(A0)+,$31(A1)
	MOVE.B	(A0)+,$38(A1)
	MOVE.B	(A0)+,$39(A1)
	MOVE.B	(A0)+,$40(A1)
	MOVE.B	(A0)+,$41(A1)
	MOVE.B	(A0)+,$48(A1)
	MOVE.B	(A0)+,$49(A1)
	MOVE.B	(A0)+,$50(A1)
	MOVE.B	(A0)+,$51(A1)
	MOVE.B	(A0)+,$58(A1)
	MOVE.B	(A0)+,$59(A1)
	MOVE.B	(A0)+,$60(A1)
	MOVE.B	(A0)+,$61(A1)
	MOVE.B	(A0)+,$68(A1)
	MOVE.B	(A0)+,$69(A1)
	MOVE.B	(A0)+,$70(A1)
	MOVE.B	(A0)+,$71(A1)
	MOVE.B	(A0)+,$78(A1)
	MOVE.B	(A0)+,$79(A1)
	MOVE.B	(A0)+,$80(A1)
	MOVE.B	(A0)+,$81(A1)
	MOVE.B	(A0)+,$88(A1)
	MOVE.B	(A0)+,$89(A1)
	MOVE.B	(A0)+,$90(A1)
	MOVE.B	(A0)+,$91(A1)
	MOVE.B	(A0)+,$98(A1)
	MOVE.B	(A0)+,$99(A1)
	MOVE.B	(A0)+,160(A1)
	MOVE.B	(A0)+,161(A1)
	MOVE.B	(A0)+,168(A1)
	MOVE.B	(A0)+,169(A1)
	MOVE.B	(A0)+,176(A1)
	MOVE.B	(A0)+,177(A1)
	MOVE.B	(A0)+,184(A1)
	MOVE.B	(A0)+,185(A1)
	MOVE.B	(A0)+,192(A1)
	MOVE.B	(A0)+,193(A1)
	MOVE.B	(A0)+,200(A1)
	MOVE.B	(A0)+,201(A1)
	lea	52(a0),A0
	lea	160(a1),a1
	endm


	opt	o+,w-

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,u_pile

	move.l	$44e.w,oldec	
	move.b	$ffff8260.w,oldrez
	move.l	#ecran,d0
	andi.l	#$ffff00,d0
	move.l	d0,ec1
	move.l	d0,ec2

	
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,oldpal

	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp

	move.b	ec1+1,$ffff8201.w
	move.b	ec1+2,$ffff8203.w
	

	lea	font1,a0
	lea	font2,a1
	bsr	decal

	lea	font2,a0
	lea	font3,a1
	bsr	decal

	lea	font3,a0
	lea	font4,a1
	bsr	decal

	
	move.b	#2,$484.w
	
	move.b	#$12,$fffffc02.w
	jsr	INITMFP

	
main:	cmp.b	#$39,$fffffc02.w
	bne.s	main
	
finprg:
error_clavier:
	btst	#5,$fffffc00.w
	beq.s	.noerror

	tst.b	$fffffc02.w
	bra.s	error_clavier
.noerror:

	btst	#0,$fffffc00.w
	beq.s	.vidbuff

	tst.b	$fffffc02.w
	bra.s	error_clavier
.vidbuff:
	
	jsr	FIN_MFP
	move.b	#8,$fffffc02.w
	move.w	#$2300,sr
	
	
	movem.l	oldpal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move	#$25,-(a7)
	trap	#14
	addq	#2,a7
	clr.b	$ffff820a.w
	
	move	#-1,-(a7)
	move.l	oldec,-(a7)
	move.l	oldec,-(a7)
	move	#5,-(a7)
	trap	#14
	lea	12(a7),a7
	
	move	#$25,-(a7)
	trap	#14
	addq	#2,a7

*	move.b	#2,$ffff820a.w

	move.b	oldrez,$ffff8260.w
	
	move.l	u_pile,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.w	-(sp)
	move.w	#11,-(sp)
	trap	#13
	addq.l	#4,sp
	clr.w	-(sp)
	trap	#1


	

*************************************************
*~~~	  Routine   VBL	~~~*
*************************************************

vbl:	
	

	move.l	pttabsc,a0
	movem.l	(a0)+,d0-d4
	movem.l	d0-d4,$330.w
	cmp.l	#ftable_scroll,a0
	blt.s	.oklk
	lea	table_scroll,a0
.oklk:
	move.l	a0,pttabsc
	
	addq.l	#1,$466.w
	rte

	move.l	ptbuf4,a0
	cmp.l	#buf_scr4+52,a0
	blt.s	.ok41
	lea	buf_scr4,a0
.ok41:
	move.l	a0,ptbuf4

	move.l	ptbuf3,a0
	cmp.l	#buf_scr3+52,a0
	blt.s	.ok31
	lea	buf_scr3,a0
.ok31:
	move.l	a0,ptbuf3

	move.l	ptbuf2,a0
	cmp.l	#buf_scr2+52,a0
	blt.s	.ok21
	lea	buf_scr2,a0
.ok21:
	move.l	a0,ptbuf2

	move.l	ptbuf1,a0
	cmp.l	#buf_scr1+52,a0
	blt.s	.ok11
	lea	buf_scr1,a0
.ok11:
	move.l	a0,ptbuf1

	cmp.l	#font1,$338.w
	bne.s	.ok1
	move.l	pttex,a0
	addq.l	#1,a0
	cmp.l	#ftexte,a0
	blt.s	.ok2
	lea	texte,a0
.ok2:
	move.l	a0,pttex
.ok1:
	move.w	#$0,$ffff8240.w

hbl:	rte

*************************************************
*~~~      Diverses Initialisations Hard	~~~*
*************************************************
INITMFP:	move	sr,-(a7)
	move	#$2700,sr
	
	lea	$fffffa01.w,a0
	lea	oldmf,a1
	move.w	#16,d0
savemfp:	move.b	(a0),(a1)+
	addq.l	#2,a0
	dbf	d0,savemfp
	
	movem.l	$100.w,d0-d7
	movem.l	d0-d7,oldvec
	movem.l	$120.w,d0-d7
	movem.l	d0-d7,oldvec+$20
	movem.l	$58.w,d0-d7
	movem.l	d0-d7,oldvec+$40
	
	bclr	#3,$fffffa17.w	; mode aei
	
	
	move.l	#hbl,$68.w
	move.l	#vbl,$70.w
	
	move.b	#%00000000,$fffffa07.w	| iera
	move.b	#%00000000,$fffffa13.w	| imra
	move.b	#%00000000,$fffffa09.w	| ierb
	move.b	#%00000000,$fffffa15.w	| imrb
	
	rte

FIN_MFP:	move	sr,-(a7)
	move	#$2700,sr

	lea	oldmf,a0
	lea	$fffffa01.w,a1
	move.w	#16,d0
restmfp:	move.b	(a0)+,(a1)
	addq.l	#2,a1
	dbf	d0,restmfp
	move.b	#$c0,(a1)
	
	movem.l	oldvec,d0-d7
	movem.l	d0-d7,$100.w
	movem.l	oldvec+$20,d0-d7
	movem.l	d0-d7,$120.w
	movem.l	oldvec+$40,d0-d7
	movem.l	d0-d7,$58.w
	rte

scroll:
	move.l	$330.w,a1
	addq.l	#1,a1
	move.l	a1,$330.w

	move.l	$334.w,a0
	addq.l	#1,a0
	lea	25*2+1(a1),a1
st	set	0
	rept	8
	move.b	st(a0),d0
	move.b	d0,26*st*2(a1)
	move.b	d0,26*st*2-52(a1)
st	set	st+2
	endr

	move.l	pttex,a0

	moveq	#0,d0
	move.b	(a0),d0
	sub.w	#32,d0
	lsl.w	#4,d0
	move.l	$338.w,a1
	adda.w	d0,a1
	move.l	a1,$334.w


	move.l	$330.w,a0
	lea	25*2+1(a0),a0
st	set	0
	rept	8
	move.b	st(a1),d0
	or.b	d0,st*26*2(a0)
	or.b	d0,st*26*2-26*2(a0)
st	set	st+2
	endr


	move.l	$330.w,a0
	move.l	ec1,a1
	lea	204+4+16*6+8+230*4(a1),a1

	put
	put
	put
	put
	put
	put
	put
	put
	rts



decal:
	move.w	#(8*58)-1,d1
.loop1:
	move.w	(a0)+,d0
	lsr.w	#2,d0
	move.w	d0,(a1)+
	dbf	d1,.loop1
	rts



	section	data

table_scroll:
ptbuf4:	dc.l	buf_scr4	* 330
old4:	dc.l	font4	* 334
	dc.l	font4	* 338
	dc.l	old4	* 33c
	dc.l	ptbuf4	* 340
ptbuf3:	dc.l	buf_scr3
old3:	dc.l	font3
	dc.l	font3
	dc.l	old3
	dc.l	ptbuf3
ptbuf2:	dc.l	buf_scr2
old2:	dc.l	font2
	dc.l	font2
	dc.l	old2
	dc.l	ptbuf2
ptbuf1:	dc.l	buf_scr1
old1:	dc.l	font1
	dc.l	font1
	dc.l	old1
	dc.l	ptbuf1
ftable_scroll:

pttabsc:	dc.l	table_scroll

font1:	incbin	"fnt.bin"
	even

pttex:	dc.l	texte

texte:	dc.b	" TRY TO REMEMBER WHEN LIFE WAS SO TENDER.........       "
ftexte:	
	even

	
	

	section	bss

	
	ds.b	256
ecran	ds.b	64000+230*25
	
oldbomb	ds.l	8

noir:	ds.w	16

oldmf	ds.b	17
oldvec	ds.l	24
oldpal	ds.w	16
oldec	ds.l	1
oldrez	ds.w	1
ec1	ds.l	1
ec2	ds.l	1

	ds.l	256
u_pile	ds.l	1

font2:	ds.b	16*58
font3:	ds.b	16*58
font4:	ds.b	16*58

buf_scr1:	ds.b	416*2
buf_scr2:	ds.b	416*2
buf_scr3:	ds.b	416*2
buf_scr4:	ds.b	416*2

	end
