* ROUTINE TO PLAY D.S.T. MODULES !
* USES 2 TIMERS;
* 1 for the TEMPO
* 1 for PLAYING
*
* (c) 1989-90 Benoit Pasquereau
* English Translation/Small Optimisation by STORMLORD of NOW 5
*
* DATE: 22 FEBRUARY 90
*
* Tabs set at 10
*
* 'speed' can be between 13 - 36


speed	=	36


call	macro
	move	#\1,-(sp)
	trap	#\2
	lea	\3(sp),sp
	endm


	dc.w	%0100101111111010,-258
	lea	$80(a5),a4
	move.l	$c(a5),d0
	add.l	$14(a5),d0	; malloc
	add.l	$1c(a5),d0
	add.l	#$100,d0
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	clr	-(sp)
	call	$4a,1,12


	clr.l	-(sp)
	call	$20,1,6
	move.l	d0,oldstk


	move	#$2700,sr
	move.b	#$12,$fffffc02.w
	bsr.s	set_up_data	; get module info.
	bsr	init_song		; set up song data
	bsr	init_prog		; get the interrupts going
	bsr	clean_AY		; clear sound chip
	move	#$2300,sr

	clr.b	acia_data


scan	cmpi.b	#$39,acia_data	; space key ?
	bne.s	scan


	move	#$2700,sr
	bsr	old_desk
	move.b	#8,$fffffc02.w
	move	#$2300,sr

	move.l	oldstk(pc),-(sp)
	call	$20,1,6

	clr	-(sp)
	call	11,13,4
	clr	-(sp)
	trap	#1



* get sound patterns/samples/etc.. from module
set_up_data
	lea	module+8(pc),a0	| a0:SAMPLES
	move.l	a0,a1		|
	add.l	-8(a0),a1		| a1:PATTERNS
	move.l	a1,a2		|
	add.l	-4(a0),a2		| a2:SONG

	move.l	a0,a3
	move.l	a0,d1
	move	(a3)+,d0		| d0=NUMBER OF SAMPLES
	subq	#1,d0
next_sam	add.l	d1,(a3)
	lea	16(a3),a3
	dbf	d0,next_sam

	move.l	a1,a3
	move.l	a1,d1
	move	(a3)+,d0		| d0=NUMBER OF PATTERNS
	subq	#1,d0
next_pat	add.l	d1,(a3)+
	dbf	d0,next_pat
	rts



***************************************************
*   ROUTINE TO PLAY THE SAMPLES ON 4 VOICES  	*
*           WITH VARIABLE PITCH 		*
***************************************************

**************************************
* PLAY ROUTINES...ON INTERRUPTS !!!! *
**************************************

* tempo roots!!
ttempo	subq.b	#1,ctempo
	ble.s	tempo_bit
	rte

tempo_bit	movem.l	a0-a2/d0,-(sp)
	tst	nbentreeaj
	bgt.s	met3sound
	tst 	nbrpat
	bgt.s 	nonrecomm
	addq.l 	#4,psong
	move.l 	psong(pc),a0
	move	2(a0),nbrpat
	bne.s	nonrecomm
	move.l 	pdsong(pc),psong
nonrecomm	move.l	psong(pc),a0
	clr.l	d0
	move	(a0),d0
	add	d0,d0
	add	d0,d0
	move.l	ppats(pc),a1
	move.l	(a1,d0.w),a0

	move	(a0),nbentreeaj
	move.b	3(a0),tempo
	addq.l	#4,a0
	move.l	a0,pentree
	subq	#1,nbrpat
met3sound	move.l	pentree(pc),a0
	move.l	pinstrs(pc),a1
sadtabj2t	move.l	#0,a2
sound1	clr.l	d0
	move.b	(a0),d0
	beq.s	noloop1
	lsl	#4,d0
	move.l	(a1,d0.w),a3
	move.l	a3,d3
	add.l	4(a1,d0.w),d3
	move.l	d3,compfini1+2
	move	#$de13,iadda3
	move.b	#(nobcld1-avance1),compfini1+7
	tst.b	1(a0)
	beq.s	noloop1
	move.l	8(a1,d0.w),bcld1+2
	sub.l	12(a1,d0.w),d3
	move.l	d3,compfini1+2
	move.b	#(bcld1-avance1),compfini1+7
noloop1	move	2(a0),d0
	beq.s	fsound1
	add	d0,d0
	add	d0,d0
	move	2(a2,d0.w),avance1+4
	move	#$4e71,avance1
	move.b	(a2,d0.w),d0
	beq.s	fsound1
	move.b	d0,avance1
	move.b	#$43+8,avance1+1
fsound1
sound2	clr.l	d0
	move.b	4(a0),d0
	beq.s	noloop2
	lsl	#4,d0
	move.l	(a1,d0.w),a4
	move.l	a4,d4
	add.l	4(a1,d0.w),d4
	move.l	d4,compfini2+2
	move	#$de14,iadda4
	move.b	#(nobcld2-avance2),compfini2+7
	tst.b	5(a0)
	beq.s	noloop2
	move.l	8(a1,d0.w),bcld2+2
	sub.l	12(a1,d0.w),d4
	move.l	d4,compfini2+2
	clr.l	d4
	move.b	#(bcld2-avance2),compfini2+7
noloop2	move	6(a0),d0
	beq.s	fsound2
	add	d0,d0
	add	d0,d0
	move	2(a2,d0.w),avance2+4
	move	#$4e71,avance2
	move.b	(a2,d0.w),d0
	beq.s	fsound2
	move.b	d0,avance2
	move.b	#$44+8,avance2+1
fsound2
sound3	clr.l	d0
	move.b	8(a0),d0
	beq.s	noloop3
	lsl	#4,d0
	move.l	(a1,d0.w),a5
	move.l	a5,d5
	add.l	4(a1,d0.w),d5
	move.l	d5,compfini3+2
	move	#$de15,iadda5
	move.b	#(nobcld3-avance3),compfini3+7
	tst.b	9(a0)
	beq.s	noloop3
	move.l	8(a1,d0.w),bcld3+2
	sub.l	12(a1,d0.w),d5
	move.l	d5,compfini3+2
	move.b	#(bcld3-avance3),compfini3+7
noloop3	move	10(a0),d0
	beq.s	fsound3
	add	d0,d0
	add	d0,d0
	move	2(a2,d0.w),avance3+4
	move	#$4e71,avance3
	move.b	(a2,d0.w),d0
	beq.s	fsound3
	move.b	d0,avance3
	move.b	#$45+8,avance3+1
fsound3
sound4	clr.l	d0
	move.b	12(a0),d0
	beq.s	noloop4
	lsl	#4,d0
	move.l	(a1,d0.w),a6
	move.l	a6,d6
	add.l	4(a1,d0.w),d6
	move.l	d6,compfini4+2
	move	#$de16,iadda6
	move.b	#(nobcld4-avance4),compfini4+7
	tst.b	13(a0)
	beq.s	noloop4
	move.l	8(a1,d0.w),bcld4+2
	sub.l	12(a1,d0.w),d6
	move.l	d6,compfini4+2
	move.b	#(bcld4-avance4),compfini4+7
noloop4	move	14(a0),d0
	beq.s	fsound4
	add	d0,d0
	add	d0,d0
	move	2(a2,d0.w),avance4+4
	move	#$4e71,avance4
	move.b	(a2,d0.w),d0
	beq.s	fsound4
	move.b	d0,avance4
	move.b	#$46+8,avance4+1
fsound4
FINTPO	move.b	tempo(pc),ctempo
	add.l	#16,pentree
	subq	#1,nbentreeaj
	movem.l	(sp)+,a0-a2/d0
	rte



*********************
* PLAY ROUTINE !!!! *
*********************

nobcld1	move.b	#(nocar1-avance1),compfini1+7
	lea	silence(pc),a3
	move.l	a3,compfini1+2
	move	#$4e71,iadda3
	bra.s	nocar1

bcld1	suba.l	#0,a3
	bra.s	nocar1

nobcld2	move.b	#(nocar2-avance2),compfini2+7
	lea	silence(pc),a4
	move.l	a4,compfini2+2
	move	#$4e71,iadda4
	bra.s	nocar2
bcld2	suba.l	#0,a4
	bra.s	nocar2


**************************
* play back the 4 voices *
**************************

replay4v
compfini1	cmp.l	#0,a3
	bge.s	nocar1
avance1	nop
	add	#0,d3
	bcc.s	nocar1
	addq.l	#1,a3
nocar1
compfini2	cmp.l	#0,a4
	bge.s	nocar2
avance2	nop
	add	#0,d4
	bcc.s	nocar2
	addq.l	#1,a4
nocar2
compfini3	cmp.l	#0,a5
	bge.s	nocar3
avance3	nop
	add	#0,d5
	bcc.s	nocar3
	addq.l	#1,a5
nocar3
compfini4	cmp.l	#0,a6
	bge.s	nocar4
avance4	nop
	add	#0,d6
	bcc.s	nocar4
	addq.l	#1,a6
nocar4
play4v	clr.l	d7
iadda6	nop
iadda5	nop
iadda4	nop
iadda3	nop
	lsl	#4,d7
	move.l	snd_out+0(pc,d7.w),$ffff8800.w
	move.l	snd_out+4(pc,d7.w),$ffff8800.w
	move.l	snd_out+8(pc,d7.w),$ffff8800.w
	rte


bcld3	sub.l	#0,a5
	bra.s	nocar3
nobcld3	move.b	#(nocar3-avance3),compfini3+7
	lea	silence(pc),a5
	move.l	a5,compfini3+2
	move	#$4e71,iadda5
	bra.s	nocar3

bcld4	sub.l	#0,a6
	bra.s	nocar4

nobcld4	move.b	#(nocar4-avance4),compfini4+7
	lea	silence(pc),a6
	move.l	a6,compfini4+2
	move	#$4e71,iadda6
	bra.s	nocar4


***************************************************
*					*
*	d3	Pointer/size end sample 1	*
*	d4	Pointer/size end sample 2	*
*	d5	Pointer/size end sample 3	*
*	d6	Pointer/size end sample 4	*
*					*
*	a3	Pointer/size sample 1	*
*	a4	Pointer/size sample 2	*
*	a5	Pointer/size sample 3	*
*	a6	Pointer/size sample 4	*
*					*
***************************************************

snd_out	incbin	a:\digital.snd\dst1.tac


*********************************
* GET/SET UP DATA FROM THE SONG *
*********************************

init_song	move.b	#1,ctempo
	lea	-14(a0),a0	| LOAD SIZE
	move.l	a0,pinstrs	| BLOCK INSTRUMENTS
	addq.l	#2,a1		| LOAD SIZE
	move.l	a1,ppats		| BLOCK PATTERNS
	addq.l	#2,a2		| LOAD SIZE
	move.l	a2,pdsong		| BLOCK SONG
	subq.l	#4,a2		|
	move.l	a2,psong		|
	clr	nbentreeaj		
	clr	nbrpat

	lea	silence(pc),a3
	move.l	a3,a4
	move.l	a3,a5
	move.l	a3,a6
	clr.l	d3
	move.l	d3,d4
	move.l	d3,d5
	move.l	d3,d6

	moveq	#(nocar1-avance1),d0
	move.b	d0,compfini1+7
	move.b	d0,compfini2+7
	move.b	d0,compfini3+7
	move.b	d0,compfini4+7
	move.l	a3,compfini1+2
	move.l	a3,compfini2+2
	move.l	a3,compfini3+2
	move.l	a3,compfini4+2
	rts


* clear sound chip
clean_AY	move.l	a0,-(sp)
	lea	$ffff8800.w,a0
	clr.b	(a0)
	clr.b	2(a0)
	move.b	#1,(a0)
	clr.b	2(a0)
	move.b	#2,(a0)
	clr.b	2(a0)
	move.b	#3,(a0)
	clr.b	2(a0)
	move.b	#4,(a0)
	clr.b	2(a0)
	move.b	#5,(a0)
	clr.b	2(a0)
	move.b	#7,(a0)
	move.b	#$ff,2(a0)
	move.l	(sp)+,a0
	rts


* initialise interrupts, save vectors & install new vectors ..
init_prog	lea	$fffffa01.w,a0
	lea	old_mfp_reg(pc),a1
	moveq	#16,d0
binit_prog1
	move.b	(a0),(a1)+
	addq.l	#2,a0
	dbf	d0,binit_prog1

	lea	$100.w,a0
	lea	old_mfp_vec(pc),a1
	moveq	#15,d0
binit_prog2
	move.l	(a0)+,(a1)+
	dbf	d0,binit_prog2
	move.l	$70.w,oldvbl

	move.l	#vbl,$70.w
	move.l	#replay4v,$134.w
	move.l	#ttempo,$110.w
	move.l	#newacia,$118.w
	bclr	#3,$fffffa17.w	| MODE AEI

	lea	mfp_tab+speed*2-2(pc),a0
	move.b	(a0),$fffffa19.w	| TIMER A
	move.b	1(a0),$fffffa1F.w	| PRED 50,DATA 5
	
	lea	tabj2t-4(pc),a0
	sub.l	#(speed-25)*4,a0
	move.l	a0,sadtabj2t+2

	andi.b	#$f0,$fffffa1d.w	| TIMER D
	ori.b	#$7,$fffffa1d.w	| A 50 HZ
	move.b	#$f5,$fffffa25.w	|
	move.b	#%00100000,$fffffa07.w	| IERA
	move.b	#%00100000,$fffffa13.w	| IMRA
	move.b	#%01010000,$fffffa09.w	| IERB
	move.b	#%01010000,$fffffa15.w	| IMRB
	rts


* disable old VBL
vbl	rte


* the new keyboard handler !!!
newacia	btst	#0,$fffffc00.w
	beq.s	ok_acia
	move.b	$fffffc02.w,acia_data
	btst	#5,$fffffc00.w
	bne.s	newacia
ok_acia	bclr	#6,$fffffa11.w
	rte



* return old vectors, turn off musixx, etc...
old_desk	lea	$fffffa01.w,a0
	lea	old_mfp_reg(pc),a1
	moveq	#16,d0
bold_desk1
	move.b	(a1)+,(a0)
	addq.l	#2,a0
	dbf	d0,bold_desk1
	move.b	#$c0,(a0)

	lea	$100.w,a0
	lea	old_mfp_vec(pc),a1
	moveq	#15,d0
bold_desk2
	move.l	(a1)+,(a0)+
	dbf	d0,bold_desk2
	move.l	oldvbl(pc),$70.w
	rts



****************
* DATA SECTION *
****************

silence	dc.w	0
mfp_tab	dc.w	$0510,$01f2,$0339,$0256,$01cb,$050c
	dc.w	$01b5,$01ab,$01a1,$0326,$0509,$0322
	dc.w	$0508,$0179,$0172,$022b,$0166,$0506
	dc.w	$015b,$0222,$0151,$0313,$0312,$0311
	dc.w	$0504,$030f,$0139,$0136,$0133,$0503
	dc.w	$0212,$0211,$030a,$0126,$0309,$0122
	dc.w	$0502,$020c,$011d,$011b,$0601,$0306
	dc.w	$0209,$0115,$0305,$0113,$0112,$0111

* Note standard :24
	dc.w	$0000,$2000,$0000,$21e7,$0000,$23eb,$0000,$260d
	dc.w	$0000,$2851,$0000,$2ab7,$0000,$2d41,$0000,$2ff2
	dc.w	$0000,$32cb,$0000,$35d1,$0000,$3904,$0000,$3c68

tabj2t	dc.w	$0000,$4000,$0000,$43ce,$0000,$47d6,$0000,$4c1b
	dc.w	$0000,$50a2,$0000,$556e,$0000,$5a82,$0000,$5fe4
	dc.w	$0000,$6597,$0000,$6ba2,$0000,$7208,$0000,$78d0
	dc.w	$0000,$8000,$0000,$879c,$0000,$8fac,$0000,$9837
	dc.w	$0000,$a145,$0000,$aadc,$0000,$b504,$0000,$bfc8
	dc.w	$0000,$cb2f,$0000,$d744,$0000,$e411,$0000,$f1a1
	dc.w	$5243,$0000,$5243,$0f38,$5243,$1f59,$5243,$306f
	dc.w	$5243,$428a,$5243,$55b8,$5243,$6a09,$5243,$7f91
	dc.w	$5243,$965f,$5243,$ae89,$5243,$c823,$5243,$e343
	dc.w	$5243,$ffff,$5443,$1e71,$5443,$3eb3,$5443,$60df
	dc.w	$5443,$8514,$5443,$ab70,$5443,$d413,$5443,$ff22
	dc.w	$5643,$2cbf,$5643,$5d13,$5643,$9047,$5643,$c686

	dc.w	$5643,$ffff,$5843,$3ce3,$5843,$7d66,$5843,$c1bf
	dc.w	$5a43,$0a28,$5a43,$56e0,$5a43,$a827,$5a43,$fe44
	dc.w	$5c43,$597f,$5c43,$ba27,$5e43,$208f,$5e43,$8d0d



***************
* BSS SECTION *
***************

oldvbl	ds.l	1
oldstk	ds.l	1
acia_data	ds.b	1
old_mfp_reg
	ds.b	17
old_mfp_vec
	ds.l	16

* variables for interrupts
tempo	ds.b	1
ctempo	ds.b	1
nbrpat	ds.w	1
pinstrs	ds.l	1
pdsong	ds.l	1
psong	ds.l	1
ppats	ds.l	1
pentree	ds.l	1
nbentreeaj
	ds.w	1


********
* DATA *
********

module	incbin	b:\module.mod\grill30.mod
