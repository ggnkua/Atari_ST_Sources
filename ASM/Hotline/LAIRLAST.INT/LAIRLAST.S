;**************************************************************
;** HELLO PAL, THIS IS A NEW INTRO FROM HOTLINE , CODED BY : **
;**      THE OLD HOTLINE MEMBER ------ LAIR --------         **
;**         INSERT TXT ON THE BOTTOM OF THE SOURCE           **
;**   --------  INSERT FILENAME AT LINE 100 ----------       **       
;** CHANGE TUNE AT LABEL TUNE , DON'T INSERT FILES OF 200K   **  
;** OR SOMETHING LIKE THAT IN THIS INTRO , OTHERWISE IT WILL **
;**     CRASH !! COS' I DON'T KNOW THE EXACT FREE MEM !!     **
;**        I TRIED A FILE OF 110K AND IT WORKED 100%         **
;**      THIS INTRO IS FINISHED AT 16-11-1990  15:40 PM      **
;**     PLEASE MENTION THE GRAPHIX ARTIST OF THIS INTRO !!   **
;**                 -------- SENSE --------                  **
;**************************************************************

realscherm	= $70000

tune=0		

	opt o+,ow-

	MOVE.L $4(A7),BASE1

	lea	$1500,a7
	pea	startintro
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp

	MOVE.L BASE1(PC),A5
	pea	(a5)
	pea	(a5)
	LEA GAME(PC),A3
	MOVE.L $2(A3),A0
	ADD.L $6(A3),A0
	MOVE.L A0,BASE2
	ADD.L A3,A0
	LEA $1C(A0),A0
	MOVE.L $8(A5),D0
	LEA GAME+$1C(PC),A1
	TST.L (A0)
	BEQ.S QUIT
	ADD.L (A0)+,A1
NEXT1	ADD.L D0,(A1)
NEXT2	CLR.L D1
	MOVE.B (A0)+,D1
	TST.W D1
	BEQ.S QUIT
	CMP.B #$1,D1
	BNE.S NEXT3
	LEA $FE(A1),A1
	BRA.S NEXT2

NEXT3	ADD.L D1,A1
	BRA.S NEXT1

QUIT	MOVE.L $2(A3),$C(A5)
	MOVE.L $6(A3),$14(A5)
	MOVE.L $A(A3),$1C(A5)
	MOVE.L $8(A5),D0
	MOVE.L $C(A5),D1
	ADD.L D0,D1
	MOVE.L D1,$10(A5)
	MOVE.L $14(A5),D0
	ADD.L D0,D1
	MOVE.L D1,$18(A5)

	LEA COPY(PC),A0
	LEA $7FF00,A1
	MOVE.L A1,A5
	MOVEQ #$2F,D0
COPY_SET
	MOVE.B (A0)+,(A1)+
	DBF D0,COPY_SET

	LEA GAME+$1C(PC),A0
	MOVE.L BASE1(PC),A1
	LEA $100(A1),A1
	MOVE.L A1,A3
	MOVE.L BASE2(PC),A4
	ADD.L A1,A4
	MOVE.L #EOF,A2
	JMP (A5)

COPY	MOVE.L (A0)+,(A1)+
	CMP.L A2,A0
	BLT.S COPY

CLEAR	CLR.L (A4)+
	CMP.L A2,A4
	BLT.S CLEAR
	JMP (A3)

BASE1	DC.L $0
BASE2	DC.L $0
GAME	CLR.W    -(SP)	;MILKMAN WAS HERE
	TRAP	#1
	;INCBIN FILE.PRG
EOF

startintro
	move.b #$4,$484.w
	dc.w $a00a	;mouse off
	move.b #$12,$FFFFFc02.W

	move.w #4,-(sp)	;get old resolution
	trap   #14
	addq.l #2,sp
	move.w d0,oldrez

	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,oldscr

	LEA $fFFf8240.W,a0	;save old palette	
	LEA oldpal(PC),a1
	movem.l (a0),d0-d7
	movem.l d0-d7,(a1)
	
	lea	$ffff8240.w,a0
	clr.l	(a0)+
	clr.l	(a0)+	
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+

	bsr    prepare	;prepare screen

	LEA	endintro,A3
	lea	realscherm,a2
ddd	CLR.L	(A3)+
	cmp.l	a3,a2
	bge.s	ddd


lairun	lea	sea+30*160,a0
	lea	realscherm-32*160,a1
	move.w	#(32*40)-40,d0
okas	move.l	(a0)+,(a1)+
	dbra	d0,okas

	lea	logo,a0
	move.l	scr0(pc),a1
	move.l	scr1(pc),a2
	move.w	#89*40,d0
copylogo	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	dbra	d0,copylogo

	bsr	subsprite

	move.w	#$2300,sr
	
	bsr    hblon	;switch hbl on

	moveq	#tune,d0
	jsr	musix
	jsr	musix+18

waitkey	tst.b syn
	beq.s waitkey
	clr.b syn
	bsr	sprrout	
	bsr	textfx
	jsr	musix+26
nosound1
	cmp.b	#$39,$fffffc02.w
	bne.s waitkey
	jsr	musix+22
	bsr    hbloff	;switch hbl off
	move.l	#$ff,d0
	jsr	musix

goon	lEA	oldpal(PC),a0	;set palette
	lEA	$FFff8240.W,a1
	movem.l (a0),d0-d7
	movem.l d0-d7,(a1)
	move.w oldrez(PC),-(sp)     ;set resolution
	move.l oldscr,-(sp)
	move.l oldscr,-(sp)
	move.w #5,-(sp)
	trap   #14
	add.l  #12,sp

	dc.w $a009	;mouse on
	move.b #8,$ffFFfc02.W
	rts
oldrez	dc.w	0
oldpal	ds.w	16
syn	dc.b	0
oldscr	dc.l	0
;----------------------------------------------------------------------
hblon	move.w	sr,status
	move.l	$120.w,oldtb	;save all registers
	move.l	$70.w,old4
	move.b	$fFFffa07.W,old07
	move.b	$fFFffa09.W,old09
	move.b	$fFFffa0b.W,old0b
	move.b	$fFFffa0d.W,old0d
	move.b	$fFFffa0f.W,old0f
	move.b	$fFFffa11.W,old11
	move.b	$fFFffa13.W,old13
	move.b	$fFFffa15.W,old15
	MOVE.B	$FFFFFA17.W,OLD17
	move.b	$fFFffa1b.W,old1b
	move.b	$fFFffa21.W,old21
	move.l	#contr,a0
	clr.b	$fFFffa09.W
	and.b	#$fe,$ffFFfa07.W
	move.b	(a0)+,d0
	cmp.b	#21,d0
	bne.s	noinst
	move.l	#newtb,$120.w	;install new vectors
	move.l	#new4,$70.w
	or.b	#1,$fFFffa07.W	;allow timer b interrupt
	or.b	#1,$fFFffa13.W
noinst	rts

hbloff	move.b	contr+1(PC),d0
	cmp.b	#4,d0
	bne.s	noex
	move.b	old07(PC),$fffffa07.W	;restore all registers
	move.b	old09(PC),$fffffa09.W
	move.b	old0b(PC),$fffffa0b.W
	move.b	old0d(PC),$fffffa0d.W
	move.b	old0f(PC),$fffffa0f.W
	move.b	old11(PC),$fffffa11.W
	move.b	old13(PC),$ffFFfa13.W
	move.b	old15(PC),$fffffa15.W
	MOVE.B	OLD17(PC),$FFFffA17.W
	move.b	old1b(PC),$fffffa1b.W
	move.b	old21(PC),$fffffa21.W
	move.l	oldtb(PC),$120.w	;restore vectors
	move.l	old4(PC),$70.w
	move.w	status(PC),sr
noex	rts

old4	dc.l	0
oldtb	dc.l	0
old07	dc.b	0
old09	dc.b	0
old0b	dc.b	0
old0d	dc.b	0
old0f	dc.b	0
old11	dc.b	0
old13	dc.b	0
old15	dc.b	0
OLD17	DC.B	0
old1b	dc.b	0
old21	dc.b	0
status	dc.w	0

new4	movem.l d0-d7/a0-a6,-(sp)
	move.w	#$2500,sr
	move.b	#2,$fffffa21.w
	move.b	#8,$fffffa1b.w
	BCLR	#3,$FFFFFA17.W
	move.l	#newtb,$120.w
	move.b	scr0+2(pc),d0		;scr1 = workscreen ?
	move.b	scr1+2(pc),scr0+2
	move.b	d0,scr1+2	
	move.b	d0,$ffff8203.w	;verwissel scherm adres
	move.l	logocol+2,$ffff8242.w
	move.l	logocol+6,$ffff8246.w
	move.l	logocol+10,$ffff824a.w
	move.l	logocol+14,$ffff824e.w
	move.l	logocol+18,$ffff8252.w
	move.l	logocol+22,$ffff8256.w
	move.l	logocol+26,$ffff825a.w
	move.w	logocol+30,$ffff825e.w
	clr.w pal
	movem.l (sp)+,d0-d7/a0-a6
new4b	rte


newtb	pea	(a6)
	lea palette(pc),a6
	add.w pal(pc),a6
	move.w	(a6),$ffff825a.w
	move.w	palette1-palette(a6),$ffff825c.w
	move.l (sp)+,a6
	cmp.w	#44*2,pal
	beq.s	newtb1
	addq.w	#2,pal
	rte

newtb1	movem.l	d0/a6,-(sp)
	move.l	newcolor(pc),$ffff8242.w
	move.l	newcolor+4(pc),$ffff8246.w
	move.l	newcolor+8(pc),$ffff824a.w
	move.l	bubcol+14(pc),$ffff824e.w
	move.l	bubcol+18(pc),$ffff8252.w
	move.l	bubcol+22(pc),$ffff8256.w
	move.l	bubcol+26(pc),$ffff825a.w
	move.w	bubcol+30(pc),$ffff825e.w
	movem.l	(sp)+,d0/a6
	move.b	rasterpo(pc),$fffffa21.w
	move.l	#newtb2,$120.w
	rte	

newtb2	movem.l	d0/a6,-(sp)
	moveq	#110,d0
	sub.b	rasterpo(pc),d0
	move.b	d0,$fffffa21.w
	move.b	#1,syn
	move.l	#newtb3,$120.w
	movem.l	(sp)+,d0/a6
	rte

newtb3	move.l	oldcolor(pc),$ffff8242.w
	move.l	oldcolor+4(pc),$ffff8246.w
	move.l	oldcolor+8(pc),$ffff824a.w
	rte

oldcolor	ds.l	6
newcolor	ds.l	16

contr	dc.b 21,4,15,6
pal	dc.w 0


palette	dc.w 0
	dc.w 1,1,2,2,3,3,4,4,5,5,6,6,7,7,7,6,6,5,5,4,4,3,3,2,2,1,1,0,0,$100,$100,$200,$200,$300,$300,$400,$400,$500,$500,$600,$600; BALK BLAUW EN BALK ROOD

palette1	dc.w 1,1,2,2,3,3,4,4,5,5,6,6,7,7,7,6,6,5,5,4,4,3,3,2,2,1,1,0,0,$100,$100,$200,$200,$300,$300,$400,$400,$500,$500,$600,$600,$700,$700; MENGING

;----------------------------------------------------------------------
prepare	clr.w -(sp)
	move.l #realscherm,-(sp)
	move.l #realscherm,-(sp)
	move.w #5,-(sp)
	trap   #14
	add.l  #12,sp
	
	clr.w -(sp)
	move.l #realscherm+$8000,-(sp)
	move.l #realscherm+$8000,-(sp)
	move.w #5,-(sp)
	trap   #14
	add.l  #12,sp

	bra	ok

	lea	fuck,a0
	lea	endfuck(pc),a1
	clr.w	d0
shitt:	add.b	(a0)+,d0
	cmp.l	a0,a1
	bne.s	shitt
	cmp.b	#5,d0	;Ron mag dit tellen (en blij!!!)
	beq.s	ok
me:	bra	me
ok:	rts

scr0	dc.l	realscherm
scr1	dc.l	realscherm+$8000
;----------------------------------------------------------------------
bubtabel
	DC.L	$70+BUBBLE+BUBHOOG*320			;'!'
	DS.L	5
	DC.L	$50+BUBBLE+BUBHOOG*640			; '
	DC.L	$90+BUBBLE+BUBHOOG*320,BUBBLE+BUBHOOG*480	;'()'
	DS.L	2
	DC.L	$40+BUBBLE+BUBHOOG*640			;','
	DC.L	$80+BUBBLE+BUBHOOG*320			;'-'
	DC.L	$60+BUBBLE+BUBHOOG*320			;'.'
	dc.l	$10+bubble+bubhoog*640			;'/'
	dc.l	bubble+bubhooG*640,$10+bubble+bubhooG*480	;'0-9'
	dc.l	$20+bubble+BUBHOOG*480,$30+bubble+bubhoog*480
	dc.l	$40+bubble+BUBHOOG*480,$50+bubble+bubhoog*480
	dc.l	$60+bubble+BUBHOOG*480,$70+bubble+bubhoog*480
	dc.l	$80+bubble+BUBHOOG*480,$90+bubble+bubhoog*480
	DC.L	$20+BUBBLE+BUBHOOG*640,$30+BUBBLE+BUBHOOG*640	;':;'
	DS.L	5
	dc.l	bubble,bubble+$10,bubble+$20,bubble+$30,bubble+$40;'A-Z'
	dc.l	bubble+$50,bubble+$60,bubble+$70,bubble+$80
	dc.l	bubble+$90
	dc.l	bubble+bubhooG*160,$10+bubble+bubhooG*160
	dc.l	$20+bubble+BUBHOOG*160,$30+bubble+bubhoog*160
	dc.l	$40+bubble+BUBHOOG*160,$50+bubble+bubhoog*160
	dc.l	$60+bubble+BUBHOOG*160,$70+bubble+bubhoog*160
	dc.l	$80+bubble+BUBHOOG*160,$90+bubble+bubhoog*160
	dc.l	bubble+BUBHOOG*320,$10+bubble+bubhoog*320
	dc.l	$20+bubble+BUBHOOG*320,$30+bubble+bubhoog*320
	dc.l	$40+bubble+BUBHOOG*320,$50+bubble+bubhoog*320

colortabl	dc.l	pal0,pal1,pal2,pal13,pal3,pal4,pal5,pal6,pal7,pal8,pal9,PAL10,PAL11,PAL12

aantline	=4
nextline	dc.b	aantline	;4 rijen letters
wacht	=120	;200 x 1/50s wachten
delay1	dc.b	wacht
txtpoin	dc.l	ltext
bubhoog	=26
scrpoin	dc.l	realscherm-150*160
seapoin	dc.l	0

textfx	tst.b	nextline
	beq	specfx
	subq.b	#1,nextline
nogeens	move.l	txtpoin(pc),a0
	tst.b	(a0)
	bpl.s	start
	cmp.b	#-1,(a0)
	bne.s	colortab
	move.l	#ltext,txtpoin
	bra.s	nogeens
colortab	
	addq.l	#1,txtpoin
	clr.w	d0
	move.b	(a0)+,d0
	sub.w	#$80,d0		
	lsl.w	#2,d0
	lea	colortabl(pc),a1
	move.l	(a1,d0.w),a1
	lea	newcolor(pc),a2
	lea	oldcolor(pc),a3		
	moveq	#5,d0
plenty	move.w	(a2),(a3)+
	move.w	(a1)+,(a2)+
	dbra	d0,plenty

start	add.L	#10,txtpoin
	move.l	scrpoin(pc),a2
	lea	bubtabel(pc),a1	;tabel met karakter adressen
	moveq	#10-1,d7		;aantal letters per regel		
copyli	move.l	a2,a3
	CLR.W	D0
	move.b	(a0)+,d0
	sub.b	#$21,d0
	bpl.s	nospatie	
	lea	$60+BUBBLE+BUBHOOG*640,a5
	bra.s	copylet
nospatie
	lsl.w	#2,d0
	MOVE.L	(a1,d0.w),a5
copylet	moveq	#bubhoog-1,d6
bubheel	movem.l	(a5),d1-d4
	movem.l	d1-d4,(a3)
	add.W	#160,a5
	add.W	#160,a3
	dbra	d6,bubheel
	add.W	#$10,a2
	dbra	d7,copyli
	add.l	#160+bubhoog*160,scrpoin
	move.b	#1,rasterpo
	rts

scans	=109
scanb	dc.b	scans-1

specfx	tst.b	scanb
	beq.s	specfxa
	subq.b	#1,scanb
	move.l	seapoin,d0
	lea	sea,a0
	lea	realscherm-150*160,a1
	add.l	d0,a0
	add.l	d0,a1
	moveq	#39,d7
scanline	movem.w	(a1),d1-d4
	move.w	d4,d0	
	or.w	d1,d0
	or.w	d2,d0
	or.w	d3,d0
	not.w	d0
	move.w	d0,d5
	and.w	(a0),d0
	or.w	d1,d0
	move.w	d0,(a1)
	move.w	d5,d0
	and.w	2(a0),d0
	or.w	d2,d0
	move.w	d0,2(a1)
	move.w	d5,d0
	and.w	4(a0),d0
	or.w	d3,d0
	move.w	d0,4(a1)
	move.w	d5,d0
	and.w	6(a0),d0
	or.w	d4,d0
	move.w	d0,6(a1)	
	addq.w	#8,a0
	addq.w	#8,a1
	dbra	d7,scanline
	add.l	#160,seapoin
	rts

mode1	dc.b	1

specfxa	tst.b	mode1
	beq.s	goodscrol
	subq.b	#1,mode1
	move.b	#36,rasterpo
	subq.b	#1,logcount
	rts

log1	dc.l	logo
log2	dc.l	mcalogo
logcount	dc.b	3
	EVEN

goodscrol
	move.w	linepo(pc),d6
	cmp.b	#108,d6
	bne	notendfx
	tst.b	delay1
	bne.s	delay
	move.b	#scans,scanb
	move.b	#wacht,delay1
	move.b	#aantline,nextline
	move.w	#1,linepo	
	move.b	#1,mode1
	lea	linesave(pc),a0
	lea	linenrs(pc),a1
	move.l	#realscherm-150*160,scrpoin
	clr.l	seapoin
	moveq	#34,d0
copylin	move.w 	(a0)+,(a1)+	
	dbra	d0,copylin
	rts
delay	subq.b	#1,delay1
	tst.b	logcount
	bne.s	nietwisel
	move.l	log1(pc),d0
	move.l	log2(pc),log1
	move.l	d0,log2
	move.l	log1(pc),whichlogo
	move.b	#3,logcount
	bra.s	newlogo
nietwisel	
	move.l	scr1(pc),a1
	add.l	#199*160,a1
	move.l	scr0(pc),a0
	add.l	#199*160,a0
	moveq	#40-1,d0
shit 	move.l	(a0)+,(a1)+
	dbra	d0,shit
	rts

newlogo	move.l	log1(pc),a0
	add.w	#(14*160)-8,a0
	move.l	scr1(pc),a1
	add.w	#(14*160)-8,a1
	move.l	scr0(pc),a2
	add.w	#(14*160)-8,a2
	moveq	#56-1,d7
hoas:	movem.l	$20(a0),d0-d5/a3-a4
	movem.l	d0-d5/a3-a4,$20(a1)
	movem.l	d0-d5/a3-a4,$20(a2)
	movem.l	$40(a0),d0-d5/a3-a4
	movem.l	d0-d5/a3-a4,$40(a1)
	movem.l	d0-d5/a3-a4,$40(a2)
	movem.l	$60(a0),d0-d5/a3-a4
	movem.l	d0-d5/a3-a4,$60(a1)
	movem.l	d0-d5/a3-a4,$60(a2)
	movem.l	$80(A0),d0-d5/a3-a4
	movem.l	d0-d5/a3-a4,$80(a1)
	movem.l	d0-d5/a3-a4,$80(a2)
	add.w	#160,a0
	add.w	#160,a1
	add.w	#160,a2
	dbra	d7,hoas

	tst.b	whichspr
	beq.s	htlspr	
	clr.b	whichspr
	lea	sprite0(pc),a0	;mca
	move.w	#9,12(a0)
	move.w	#8,12+14(a0)
	move.w	#7,12+28(a0)
	move.w	#10,12+42(a0)
	move.w	#9,12+56(a0)
	move.w	#8,12+70(a0)
	move.w	#7,12+84(a0)
okdo	rts
htlspr	move.b	#1,whichspr
	lea	sprite0(pc),a0	;htl
	move.w	#6,12(a0)
	move.w	#5,12+14(a0)
	move.w	#4,12+28(a0)
	move.w	#3,12+42(a0)
	move.w	#2,12+56(a0)
	move.w	#1,12+70(a0)
	clr.w	12+84(a0)
	rts

whichspr	dc.b	0,0

notendfx
	lea	realscherm-152*160,a0
	lea	linenrs(pc),a4
	move.l	scr1(pc),a2
	add.w	#91*160,a2
	cmp.b	#108-35,d6
	bge.s	changenr
	moveq	#35-1,d5
	addq.b	#1,rasterpo
	bra.s	nofurther
changenr	
	moveq	#107,d7		;108=bubhoog+1*aantline
	sub.w	d6,d7
	move.w	d7,d5
nofurther
	mulu	#160,d6
	add.w	d6,a2
	move.l	a0,a3
	add.w	d6,a3
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+	
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+	
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+	
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+	
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+	
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+	
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+	
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+	
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
copyline1	
	move.l	a0,a3
	move.w	(a4),d0
	add.w	#45,d0
	cmp.w	#154,d0
	blt.s	doesn1
	sub.w	#106,d0
	bra.s	setss
doesn1	cmp.w	#110,d0
	blt.s	doesn
	sub.w	#56,d0
setss	lea	sea,a3	
doesn	addq.w	#1,(a4)+
	mulu	#160,d0
	add.w	d0,a3
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+	
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+	
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+	
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+	
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	dbf	d5,copyline1
	addq.w	#1,linepo
	rts

linepo	dc.w	1
rasterpo	dc.b	36

pal0	dc.w	$646,$202,$313,$424,$535
pal1	dc.w	$635,$201,$302,$413,$524
pal2	dc.w	$644,$200,$311,$422,$533
pal3	dc.w	$66,$22,$33,$44,$55
pal4	dc.w	$65,$21,$32,$43,$54
pal5	dc.w	$626,$202,$313,$414,$525
pal6	dc.w	$600,$200,$300,$400,$500
pal7	dc.w	$56,$12,$23,$34,$45
pal8	dc.w	$60,$20,$30,$40,$50
pal9	dc.w	$666,$222,$333,$444,$555
PAL10	DC.W	$67,$23,$34,$45,$56
PAL11	DC.W	$660,$220,$330,$440,$550
PAL12	DC.W	$456,$012,$123,$234,$345
pal13	dc.w	$665,$221,$332,$443,$554
linenrs	dc.w	47,44,41,39,37
	dc.w	36,35,34,33,32,31,30,29,28
	dc.w	27,26,25,24,23,22,21,20,19,18
	dc.w	17,16,15,14,13,12	
	dc.w	11,9,7,4,1

linesave	dc.w	47,44,41,39,37
	dc.w	36,35,34,33,32,31,30,29,28
	dc.w	27,26,25,24,23,22,21,20,19,18
	dc.w	17,16,15,14,13,12	
	dc.w	11,9,7,4,1

;-----------------voorbereken routine voor sprites-----------------------	
;------- deze routine 1 keer aanroepen voor de interupt begint ----------
sprhoogte	=	16		;hoogte sprite
aantgrx		=	11		;sprite grafix aantal

subsprite	lea	sprpoin,a4	;copy original block to
	lea	spritebuf,a1	;sprite block0
	moveq	#aantgrx-1,d5	;aantal verschillende sprites
nextgrx	move.l	a1,a6
	move.l	a1,a2
	move.l	a4,a0
	moveq	#sprhoogte-1,d7
origspr	movem.w	(a0),d0-d3
	move.w	d0,(a1)+
	clr.w	(a1)+
	move.w	d1,(a1)+
	clr.w	(a1)+
	move.w	d2,(a1)+
	clr.w	(a1)+
	move.w	d3,(a1)+
	clr.w	(a1)+
	add.l	#160,a0
	dbf	d7,origspr
	
	moveq	#15-1,d7		;shift sprites in blocks 1-15
shiftspr
	moveq	#sprhoogte-1,d6
shift	movem.l	(a6)+,d0-d3
	ror.l	#1,d0
	ror.l	#1,d1
	ror.l	#1,d2
	ror.l	#1,d3
	movem.l	d0-d3,(a1)
	add.l	#16,a1
	dbf	d6,shift
	dbf	d7,shiftspr

	move.l	a2,a6		;every block will get
	moveq	#16-1,d7		;a mask block
maskspr	moveq	#sprhoogte-1,d6
mask	movem.l	(a6)+,d0-d3
	or.l	d3,d0
	or.l	d2,d0
	or.l	d1,d0
	not.l	d0
	move.l	d0,(a1)+
	dbf	d6,mask
	dbf	d7,maskspr
	addq.l	#8,a4
	dbf	d5,nextgrx

	lea	ysprdatas,a0	;multiply ydatas *160
nextydata	
	move.w	(a0),d0
	bmi.s	endydata
	mulu	#160,d0
	move.w	d0,(a0)+
	bra.s	nextydata

endydata	lea	xsprdatas,a0	;xdata/16
nextxdata	clr.l	d0
	move.w	(a0),d0		;1e byte = result*8
	bmi.s	endxdata		;2e byte = rest 
	divu	#16,d0
	move.w	d0,d1
	lsl.w	#3,d1
	move.b	d1,(a0)+
	swap	d0
	lsl.w	#3,d0
	move.b	d0,(a0)+
	bra.s	nextxdata
endxdata
	move.l	xenddata-4,xsprdatas-4
	move.l	yenddata-4,ysprdatas-4
	rts

;----- dit routinetje kijkt waar de indexen zijn met de posities ----
movespr	move.w	8(a0),d0		;x index lezen
	move.w	-4(a5,d0.w),d3	;lees oude x-pos
	move.w	(a5,d0.w),d1
	tst.w	2(a5,d0.w)	;lees nieuwe x-pos
	cmp.w	#-1,d1
	bne.s	xnotend		;einde data tabel
	clr.w	8(a0)
	move.w	xsprdatas(pc),d1	;start met nieuwe x-pos	
	move.w	xenddata-4(pc),d3
xnotend	move.w	10(a0),d0		;y index lezen
	move.w	-4(a6,d0.w),d4	;etc ..
	move.w	(a6,d0.w),d2
	tst.w	2(a6,d0.w)
	bne.s	ynotend
	clr.w	10(a0)
	move.w	ysprdatas(pc),d2
	move.w	yenddata-4(pc),d4
ynotend	add.l	#$20002,8(a0)	;indexen met 2 verhogen
	movem.w	d1-d4,(a0)	;schrijf posities weg
	rts

;-----------------echte sprite rout voor interupt------------------------
;---------- deze routine moet in de interupt worden gezet ---------------
whichlogo	dc.l	logo
spraant	= 7

sprrout	lea	sprite0(pc),a0	;eerste sprite
	move.l	scr1(pc),a1	
	lea	ysprdatas(pc),a6	;start y-data tabel
	lea	xsprdatas(pc),a5	;start x-data tabel
	moveq	#spraant-1,d5
clrspr	move.l	a1,a3
	
	bsr.s	movespr		;move sprite on screen
	
	move.l	whichlogo(pc),a2	;background picture
	move.l	a1,a3
	clr.w	d0
	move.b	4(a0),d0		;screen + x*8 + y*160
	add.w	d0,a3		
	add.w	d0,a2
	add.w	d4,a3
	add.w	d4,a2
	moveq	#sprhoogte-1,d7	;copy old back to screen
copyback	move.l	(a2),(a3)
	move.l	4(a2),4(a3)
	move.l	8(a2),8(a3)
	move.l	12(a2),12(a3)
	add.w	#160,a2
	add.w	#160,a3
	dbf	d7,copyback
	add.w	#14,a0
	dbf	d5,clrspr
	
	lea	sprite0(pc),a0
 	moveq	#spraant-1,d5
setspr	move.l	scr1(pc),a1
	clr.w	d0		;copy spriteblock to screen
	move.b	(a0)+,d0
	add.w	d0,a1
	move.b	(a0)+,d0
	add.w	(a0)+,a1
	movem.l	spriteadr(pc,d0.w),a3-a4
	move.w	8(a0),d7
	mulu	#5120,d7
	add.l	d7,a3
	add.l	d7,a4
	moveq	#sprhoogte-1,d7
copyspr	move.l	(a4)+,d0		;read mask
	and.w	d0,8(a1)		;make parallax
	and.w	d0,10(a1)
	and.w 	d0,12(a1)
	and.w	d0,14(a1)
	movem.l	(a3)+,d1-d4
	or.w	d1,8(a1)
	or.w	d2,10(a1)
	or.w	d3,12(a1)
	or.w	d4,14(a1)
	swap	d0
	swap	d1
	swap	d2
	swap	d3
	swap	d4
	and.w	d0,(a1)
	and.w	d0,2(a1)
	and.w	d0,4(a1)
	and.w	d0,6(a1)
	or.w	d1,(a1)
	or.w	d2,2(a1)
	or.w	d3,4(a1)
	or.w	d4,6(a1)
	add.w	#160,a1
	dbf	d7,copyspr
	add.w	#10,a0
	dbf	d5,setspr
	rts

spriteadr	dc.l	spritebuf		;adressen sprite graphix
	dc.l	spritebuf+sprhoogte*256
	dc.l	spritebuf+sprhoogte*16
	dc.l	spritebuf+sprhoogte*260
	dc.l	spritebuf+sprhoogte*32
	dc.l	spritebuf+sprhoogte*264
	dc.l	spritebuf+sprhoogte*48
	dc.l	spritebuf+sprhoogte*268
	dc.l	spritebuf+sprhoogte*64
	dc.l	spritebuf+sprhoogte*272
	dc.l	spritebuf+sprhoogte*80
	dc.l	spritebuf+sprhoogte*276
	dc.l	spritebuf+sprhoogte*96
	dc.l	spritebuf+sprhoogte*280
	dc.l	spritebuf+sprhoogte*112
	dc.l	spritebuf+sprhoogte*284
	dc.l	spritebuf+sprhoogte*128
	dc.l	spritebuf+sprhoogte*288
	dc.l	spritebuf+sprhoogte*144
	dc.l	spritebuf+sprhoogte*292
	dc.l	spritebuf+sprhoogte*160
	dc.l	spritebuf+sprhoogte*296	
	dc.l	spritebuf+sprhoogte*176
	dc.l	spritebuf+sprhoogte*300
	dc.l	spritebuf+sprhoogte*192
	dc.l	spritebuf+sprhoogte*304
	dc.l	spritebuf+sprhoogte*208	
	dc.l	spritebuf+sprhoogte*308
	dc.l	spritebuf+sprhoogte*224
	dc.l	spritebuf+sprhoogte*312
	dc.l	spritebuf+sprhoogte*240
	dc.l	spritebuf+sprhoogte*316

sprite0	dc.w	0	;xpos
	dc.w	0	;ypos
	dc.w	0	;old xpos
	dc.w	0	;old ypos
	dc.w	0	;xindex 
	dc.w	0	;yindex
	dc.w	9
	ds.w	4
	dc.w	8,8
	dc.w	8
	ds.w	4	
	dc.w	16,16
	dc.w	7
	ds.w	4
	dc.w	24,24
	dc.w	10
	ds.w	4
	dc.w	32,32
	dc.w	9
	ds.w	4
	dc.w	40,40
	dc.w	8
	ds.w	4
	dc.w	48,48
	dc.w	7 
;-----------------move sprite on screen--------------------------------
	dc.w	0,0			;2 x-save words	
xsprdatas	incbin	\LAIRLAST.INT\xdata.sin
xenddata	dc.w	-1

	dc.w	0,0			;2 y-save words
ysprdatas	incbin	\LAIRLAST.INT\ydata.sin
yenddata	dc.w	-1
;----------------------------------------------------------------------	
bubble	incbin	\LAIRLAST.INT\bub.pi1
bubcol	incbin	\LAIRLAST.INT\bub.col
;----------------------------------------------------------------------	
LTEXT	dc.b	$80		;color tabel 0 = $80+1
				;CHOOSE $80-$8D
	dc.b	"HOTLINE   "	;4 LINES VAN 10 LETTERS
	dc.b	" PRESENTS:"
	dc.b	"          "
	dc.b	"   GAME   "        ;HIER NAAM VAN HET SPEL******* 
	
fuck	DC.B   $81,'THIS IN'
	DC.B   'TRO IS C' 
	DC.B   'ODED    ' 
	DC.B   ' BY:    ' 
	DC.B   '- LAIR -' 
	DC.B   ' ',$82,'GRAFIX' 
	DC.B   ' AND PAL' 
	DC.B   'ETTES   ' 
	DC.B   '  BY:   ' 
	DC.B   ' - SENSE' 
	DC.B   ' -',$8C,'MUSIC' 
	DC.B   ' AND  DI' 
	DC.B   'GI-DRUM ' 
	DC.B   '   BY:  ' 
	DC.B   '    LOTUS  '
endfuck
	DC.B	$86
	DC.B	"THE GREETZ"
	DC.B	" ARE SEND "
	DC.B	"    TO:   "
	DC.B	"          "

	dc.b	$84
	DC.B	" ALL OTHER"
	DC.B	"HOTLINE-  "
	DC.B	"  MEMBERS,"
	DC.B	"THE EMPIRE"

	dc.b	$85
	DC.B	"REPLICANTS"
	DC.B	"AUTOMATION"
	DC.B	"   TLB,   "
	DC.B	"   TCB,   "

	dc.b	$86
	DC.B	" DELIGHT, "
	DC.B	"INNER-    "
	DC.B	"   CIRCLE,"
	DC.B	"FINGERBOBS"

	dc.b	$87
	DC.B	"ZAE OF    "
	DC.B	"     NEXT,"
	DC.B	"DYNAMIC-  "
	DC.B	"      DUO,"

	dc.b	$88
	DC.B	"THE GERMAN"
	DC.B	" ALLIANCE,"
	DC.B	"   TEX,   "
	DC.B	"  OMEGA,  "

	dc.b	$89
	DC.B	"   SYNC,  "
	DC.B	"AENIG-    "
	DC.B	"   MATICA,"
	DC.B	"   FOF,   "
	
	dc.b	$8A
	DC.B	"   HIT    "
	DC.B	"  SPACE   "
	DC.B	"2 CONTINUE"
	DC.B	"----------"
	
	dc.b	-1
;----------------------------------------------------------------------	
musix	incbin	\groovy.mus
;----------------------------------------------------------------------	
logo	incbin	\LAIRLAST.INT\logo.pic
mcalogo	incbin	\LAIRLAST.INT\logo_mca.pic
logocol	incbin	\LAIRLAST.INT\logo.col
;----------------------------------------------------------------------	
sea	incbin	\LAIRLAST.INT\sea.pic
;----------------------------------------------------------------------	
spritepic	incbin	\LAIRLAST.INT\sprite.pic
sprpoin	=	spritepic
spritebuf	=	spritepic+$a00
;----------------------------------------------------------------------	
endintro