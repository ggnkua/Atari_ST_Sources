          opt o+,ow-

;**********************************************
;***  SINUS + PARALLAX SPRITES INTRO V1.2   ***
;***   CODED BY LAIR & GRAPHIX BY -SENSE-   ***
;**********************************************

	move.l	4(a7),base1

	pea	x
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp

	MOVE.L BASE1(PC),A5
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
COPY_SET	MOVE.B (A0)+,(A1)+
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

GAME	INCBIN FILE.PRG

x	dc.w $a00a	;mouse off
	move.b #$12,$fffc02
	move.w	sr,status
	move.w #4,-(sp)	;get old resolution
	trap   #14
	addq.l #2,sp
	move.w d0,oldrez

	move.l #$ff8240,a0	;save old palette	
	move.l #oldpal,a1
	movem.l (a0),d0-d7
	movem.l d0-d7,(a1)
	move.b	$ffff820a.w,oldhz
	move.b	#$2,$ffff820a.w

	and.b	#%11111110,$484.w

	move.w	#$2300,sr

	moveq	#1,d0
	jsr	music(pc)
	jsr	prepare(pc)	;prepare screen
	jsr	mulsin(pc)	;sinusdata*160
	jsr	subsprite(pc)	
	bsr	hblon	;switch hbl on
          
waitkey	tst.b syn
	beq.s waitkey
	clr.b syn
	jsr	sprrout(pc)
	jsr	scrsoft(pc)
	jsr	music+8(pc)
	cmp.b	#$39,$fffffc02.w
	bne.s	waitkey

endintro	bsr    hbloff	;switch hbl off
	move.w	status,sr

	or.b	#%00000001,$484.w
goon	move.l #oldpal,a0	;set palette
	move.l #$ff8240,a1
	movem.l (a0),d0-d7
	movem.l d0-d7,(a1)
	move.w oldrez,-(sp)     ;set resolution
	move.l #$78000,-(sp)
	move.l #$78000,-(sp)
	move.w #5,-(sp)
	trap   #14
	add.l  #12,sp

	move.b	oldhz,$ffff820a.w
	moveq	#0,d0
	jsr	music(pc)
	dc.w $a009	;mouse on
	move.b #8,$fffc02
	rts

oldhz	dc.b 0
status	dc.w 0
oldrez	dc.w 0
oldpal	ds.w 16
syn	dc.b 0
;-----------------------------
hblon	move.l $120.w,oldtb	;save all registers
	move.l $70.w,old4
	move.b $fffa07,old07
	move.b $fffa09,old09
	move.b $fffa0b,old0b
	move.b $fffa0d,old0d
	move.b $fffa0f,old0f
	move.b $fffa11,old11
	move.b $fffa13,old13
	move.b $fffa15,old15
	move.b $fffa1b,old1b
	move.b $fffa21,old21

	clr.b	$fffffa09.w

	move.l #contr,a0
	move.b (a0)+,d0
	cmp.b  #21,d0
	bne    noinst
	move.l #newtb,$120.w;install new vectors
	move.l #new4,$70.w
	move.b   #1,$fffa07	;allow timer b interrupt
	move.b   #1,$fffa13
noinst	rts

hbloff	move.w sr,-(sp)
	move.w #$2700,sr
	move.b contr+1,d0
	cmp.b  #4,d0
	bne    noex
	move.b old07,$fffa07;restore all registers
	move.b old09,$fffa09
	move.b old0b,$fffa0b
	move.b old0d,$fffa0d
	move.b old0f,$fffa0f
	move.b old11,$fffa11
	move.b old13,$fffa13
	move.b old15,$fffa15
	move.b old1b,$fffa1b
	move.b old21,$fffa21

          move.l oldtb,$120.w	;restore vectors
	move.l old4,$70.w
noex	move.w (sp)+,sr
	rts

old4	dc.l 0
oldtb	dc.l 0
old07	dc.b 0
old09	dc.b 0
old0b	dc.b 0
old0d	dc.b 0
old0f	dc.b 0
old11	dc.b 0
old13	dc.b 0
old15	dc.b 0
old1b	dc.b 0
old21	dc.b 0

new4	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$2500,sr
	jsr	colorscr(pc)
	move.l	#newtb,$120.w
	move.b #5,$fffffa21.w	;set data register
	move.b #8,$fffffa1b.w	;start timer	
	move.b #1,syn
	clr.w pal
	move.b	scr0+2,d0		;scr1 = workscreen ?
	move.b	scr1+2,scr0+2
	move.b	d0,scr1+2	
	move.b	d0,$ffff8203.w
	movem.l	(sp)+,d0-d7/a0-a6
	rte



newtb	move.l	a6,-(sp)
	lea	palette0(pc),a6
	add.w	pal(pc),a6
	move.w	(a6),$ffff8240.w
	move.l	(sp)+,a6	
	move.b	#3,$fffffa21.w
	addq.w	#2,pal
	cmp.w	#8,pal
	bne.s	contia
	move.l	#newtb4,$120.w
	move.l	logocolor+6,$ffff8246.w
	move.l	$ffff8246.w,$ffff8256.w
	move.l	logocolor+10,$ffff824a.w
	move.l	$ffff824a.w,$ffff825a.w
	move.l	logocolor+12,$ffff824c.w
	move.l	$ffff824c.w,$ffff825c.w
	move.b	#2,$fffffa21.w
contia	bclr	#0,$fffffa0f.w
	rte

newtb4	move.l	a6,-(sp)
	lea	palette0(pc),a6
	add.w	pal(pc),a6
	move.w	(a6),$ffff8240.w
	move.w	logocol-palette0(a6),$ffff8242.w
	move.w	logocol1-palette0(a6),$ffff8244.w
	move.w	$ffff8242.w,$ffff8252.w
	move.w	$ffff8244.w,$ffff8254.w
	move.w	palette-palette0(a6),$ffff8250.w
	move.l	(sp)+,a6
	cmp.w	#66,pal
	bne.s	contras
	move.b	#3,$fffffa21.w
	move.l	#newtb1,$120.w
	move.l	color0+2(pc),$ffff8242.w
	move.l	color0+6(pc),$ffff8246.w
	move.l	color0+10(pc),$ffff824a.w
	move.w	color0+14(pc),$ffff824e.w
contras	addq.w	#2,pal
	bclr	#0,$fffffa0f.w
	rte

newtb1	move.l a6,-(sp)
	lea palette0(pc),a6
	add.w pal(pc),a6
	move.w	(a6),$ffff8240.w
	move.w	palette-palette0(a6),$ffff8250.w
	move.w	$ffff8250.w,$ffff8252.w
	move.w	$ffff8250.w,$ffff8254.w
	move.w	$ffff8250.w,$ffff8256.w
	move.w	$ffff8250.w,$ffff8258.w
	move.w	$ffff8250.w,$ffff825a.w
	move.w	$ffff8250.w,$ffff825c.w
	move.w	$ffff8250.w,$ffff825e.w
	addq.w   #2,pal
	move.l (sp)+,a6
	bclr    #0,$fffffa0f.w	;end of interrupt
	rte

contr	dc.b 21,4,15,6
pal	dc.w 0

palette0	dc.w	0,0,1,1,2,1
	dc.w	2,2,2,3,2
	dc.w	3,3,4,3
	dc.w	4,4,5,4
	dc.w	5,5,6,5
	dc.w	6,6,7,6
	dc.w	7,7,$107,7
	dc.w	$107,$107,$207,$107,$207,$207,$307,$207
	dc.w	$307,$307,$407,$307,$407,$407,$507,$407
	dc.w	$507,$507,$607,$507,$607,$607,$707,$717
	dc.w	$727,$737,$747
	ds.w	22

palette	dc.w	0,0,0,0,$10,$10,$20,$20
	dc.w	$30,$30,$40,$40,$50,$50,$60,$60,$70,$70
	dc.w	$171,$272,$373,$474,$575,$676,$777,$777,$777,$777
	dc.w	$766,$755,$744,$733,$722,$711,$700,$700,$710,$720
	dc.w	$730,$740,$750,$760,$770,$771,$772,$773,$774,$775
	dc.w	$776,$777,$777,$777,$777,$767,$757,$747,$737,$727
	dc.w	$717,$707,$607,$507,$407,$307,$207,$107
	dc.w	7,6,5,4,3,2,1


logocol	dc.w	0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	$202,$202,$424,$424,$646,$646,$757,$757
	dc.w	$210,$210,$420,$420,$641,$641,$765,$765

logocol1	dc.w	0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	$202,$313,$313,$535,$535,$747,$747
	dc.w	$767,$767,$320,$320,$530,$530,$752,$752,$777,$777

colsc0	ds.w	$50
	dc.w	1,2,3,4,5,6,7
	dc.w	$117,$227,$337,$337,$447,$447
	dc.w	$557,$557,$557,$667,$667,$667,$777,$777,$777,$777
	dc.w	$666,$666,$666,$555,$555,$555,$444,$444
	dc.w	$333,$333,$222,$111
	ds.w	$50
	dc.w	$100,$200,$300,$400,$500,$600,$700
	dc.w	$710,$720,$730,$740,$750,$760,$770
	dc.w	$771,$772,$773,$774,$775,$776,$777,$777,$777,$777
	dc.w	$776,$775,$774,$773,$772,$771,$770,$760,$750,$740
	dc.w	$730,$720,$710,$700,$600,$500,$400,$300,$200,$100
	ds.w	$50
	dc.w	$10,$20,$30,$40,$50,$60,$70
	dc.w	$171,$272,$373,$474,$575,$676,$777,$777,$777,$777
	dc.w	$676,$575,$474,$373,$272,$171,$70,$60,$50,$40,$30
	dc.w	$20,$10
	dc.w	-1
;----------------------------
colindex	dc.w	0,2,4,6,8,10,12,14,16,18,20,22,24,26

colorscr	lea	colsc0(pc),a0
	lea	colindex(pc),a2
	lea	$ffff8242.w,a1
	moveq	#11,d7
allright	move.w	(a2),d1
	move.w	(a0,d1.w),d1	
	bpl.s	endcolors
	clr.w	(a2)
	move.w	(a0),d1
endcolors	move.w	d1,(a1)+
	addq.w	#2,(a2)+
	dbra	d7,allright
	rts	
;-----------------------------
prepare	move.w #0,-(sp)	;set low res
	move.l #realscherm-$8000,-(sp)
	move.l #realscherm-$8000,-(sp)
	move.w #5,-(sp)
	trap   #14
	add.l  #12,sp
	
	move.w #0,-(sp)	;set low res
	move.l #realscherm-$10000,-(sp)
	move.l #realscherm-$10000,-(sp)
	move.w #5,-(sp)
	trap   #14
	add.l  #12,sp

	move.w #0,-(sp)
	move.l #realscherm,-(sp)
	move.l #realscherm,-(sp)
	move.w #5,-(sp)
	trap   #14
	add.l  #12,sp

	pea	color0
	move.w	#6,-(sp)
	trap	#14
	addq.l	#6,sp

	lea	backpic,a0
	lea	realscherm+90*160,a1
	lea	realscherm-$8000+90*160,a2
	lea	realscherm-$10000+90*160,a3
	move.w	#109*40,d0
copyscap	move.l	(a0),(a1)+
	move.l	(a0),(a2)+
	move.l	(a0)+,(a3)+
	dbf	d0,copyscap

	lea	logo,a0
	lea	realscherm+4800,a1
	lea	realscherm-$8000+4800,a2
	move.w	#80*36,d7
notlogo	move.w	(a0),(a1)+
	move.w	(a0)+,(a2)+
	dbra	d7,notlogo

	lea	spritepic+8,a0
	lea	realscherm,a1
	lea	realscherm-$8000,a2
	moveq	#4,d7
coded 	movem.l	(a0),d0-d5
	movem.l	d0-d5,(a1)
	movem.l	d0-d5,(a2)
	movem.l	960(a0),d0-d5
	movem.l	d0-d5,120(a1)
	movem.l	d0-d5,120(a2)
	movem.l	24(a0),d0-d5
	movem.l	d0-d5,24(a1)
	movem.l	d0-d5,24(a2)
	movem.l	984(a0),d0-d3
	movem.l	d0-d3,144(a1)
	movem.l	d0-d3,144(a2)
	add.w	#160,a0
	add.w	#160,a1
	add.w	#160,a2
	dbf	d7,coded
	rts
;-----------------------------
mulsin	lea	sindata,a0
contmul	move.w	(a0),d0
	bmi.s	enddata
	addq.w	#3,d0
	mulu	#160,d0
	move.w	d0,(a0)+
	bra.s	contmul
enddata	move.l	sinend-4,sindata-4
	rts
;-----------------------------
realscherm=$78000
hoogte	=15

scherm0	ds.b	160+hoogte*160
scherm1	ds.b	160+hoogte*160
scherm2	ds.b	160+hoogte*160
scherm3	ds.b	160+hoogte*160
bufferkar	ds.b	160+hoogte*160

nr	dc.w	0
karnr     dc.w	0
teken	dc.l	0


karblok	DC.L	CHBLOK+$1E72
	ds.l	5
	DC.L	CHBLOK+$2842
	DC.L	CHBLOK+$2852
	DC.L	CHBLOK+$2862
	DC.L	CHBLOK+$2802
	DC.L	CHBLOK+$1E82
	DC.L	CHBLOK+$2822
	DC.L	CHBLOK+$1E92
	DC.L	CHBLOK+$2812
	DC.L	0
	dc.l	chblok+$1462,chblok+$1472,chblok+$1482,chblok+$1492
	dc.l	chblok+$1e02,chblok+$1e12,chblok+$1e22,chblok+$1e32
	dc.l	chblok+$1e42,chblok+$1e52
	DC.L	CHBLOK+$2832
	ds.l	4
	DC.L	CHBLOK+$1E62
	DC.L	0
	dc.l	chblok+2,chblok+$12,chblok+$22,chblok+$32,chblok+$42
	dc.l	chblok+$52,chblok+$62,chblok+$72,chblok+$82,chblok+$92
	dc.l	chblok+$a02,chblok+$a12,chblok+$a22,chblok+$a32
	dc.l	chblok+$a42,chblok+$a52,chblok+$a62,chblok+$a72
	dc.l	chblok+$a82,chblok+$a92
	dc.l	chblok+$1402,chblok+$1412,chblok+$1422,chblok+$1432
	dc.l	chblok+$1442,chblok+$1452

jumptabel	dc.l	sch1,sch2,sch3,zetdeel
	dc.l	sch1,sch2,sch3,zetdeel1

scrsoft	move.w nr(pc),d0
	addq.w	#4,nr
	move.l jumptabel(pc,d0.w),a1
	jmp (a1)

zetdeel	lea scherm3(pc),a0
	bsr schuif
	lea text(pc),a0
zoekeens	move.w karnr(pc),d0
	clr.w d1
	move.b (a0,d0.w),d1
	bne.s cont
	clr.w karnr
	move.b (a0),d1
cont	addq.w #1,karnr
	sub.w #$21,d1
	bpl.s nospatie
	lea chblok+$2892(pc),a0		;leeg blok voor space            
	bra.s spatie
nospatie	lsl.w #2,d1
	lea karblok(pc),a0
	move.l (a0,d1.w),a0
spatie	move.l a0,teken
copykars	lea bufferkar(pc),a1
	lea scherm3+$98,a2
	moveq #hoogte,d7
copykar	move.w (a0),d0
	clr.w (a1)+
	move.w d0,(a1)+
	move.w d0,(a2)
	add.w	#12,a1
	add.w	#160,a0
	add.w	#160,a2
	dbf d7,copykar
	rts

zetdeel1	lea	scherm3,a0
	bsr.s	schuif
	addq.l	#8,teken
	move.l	teken,a0
	clr.w	nr
	bra.s	copykars

sch1	lea scherm0(pc),a0
	bra.s schuif
sch2	lea scherm1(pc),a0
	bra.s schuif
sch3	lea scherm2(pc),a0
schuif	lea bufferkar(pc),a1
	move.l a0,a3
	moveq #hoogte,d7
rollen	move.l (a1),d0
	lsl.l #4,d0
	move.l d0,(a1)
	swap d0
	or.w d0,$98(a0)
	add.w	#16,a1
	add.w	#160,a0
	dbf d7,rollen
	
	bsr.s	sinmake
	
	lea bufferkar(pc),a1
	moveq #hoogte,d7
schuifzet	move.w	2(a1),152(a3)
	add.w #16,a1
	add.w #160,a3
	dbf d7,schuifzet
	rts

sinmake	move.l	a3,savea3		;sinus scrol zetten	
	move.l	a3,d5
	move.l	scr1,a1
	addq.w	#6,a1
	lea	sindata,a2
	lea	sinindex(pc),a4
	
	moveq	#19,d6
copylines	move.w	(a4),d0
	addq.w	#2,(a4)+
	addq.w	#2,(a4)+
	move.w	-2(a2,d0.w),d3
	move.w	-4(a2,d0.w),d2
	move.w	2(a2,d0.w),d1
	bpl.s	contread	
	move.w	#2,-4(a4)
	move.w	2(a2),d1

contread	move.w	(a2,d0.w),d0
	bpl.s	notend
	move.w	#2,-2(a4)
	move.w	(a2),d0

notend	move.l	d5,a3
	lea	(a1,d0.w),a5
	lea	1(a1,d1.w),a0
	
	sub.w	d0,d2
	bpl.s	boven
	clr.b	-160(a5)
	clr.b	-320(a5)
	clr.b	-480(a5)
	clr.b	-640(a5)
	clr.b	-800(a5)
	clr.b	-960(a5)
	clr.b	-1120(a5)
	clr.b	-1280(a5)
	bra.s	nextp
boven	clr.b	hoogte*160+320(a5)
	clr.b	hoogte*160+160(a5)
	clr.b	hoogte*160+480(a5)
	clr.b	hoogte*160+640(a5)
	clr.b	hoogte*160+800(a5)
	clr.b	hoogte*160+960(a5)
	clr.b	hoogte*160+1120(a5)
	clr.b	hoogte*160+1280(a5)
	clr.b	hoogte*160+1440(a5)
	clr.b	hoogte*160+1600(a5)
	clr.b	hoogte*160+1760(a5)
nextp	sub.w	d1,d3
	bpl.s	boven1
	clr.b	-160(a0)
	clr.b	-320(a0)
	clr.b	-480(a0)
	clr.b	-640(a0)
	clr.b	-800(a0)
	clr.b	-960(a0)
	clr.b	-1120(a0)
	clr.b	-1280(a0)
	bra.s	nextp	
boven1	clr.b	hoogte*160+160(a0)
	clr.b	hoogte*160+320(a0)
	clr.b	hoogte*160+480(a0)
	clr.b	hoogte*160+640(a0)
	clr.b	hoogte*160+800(a0)
	clr.b	hoogte*160+960(a0)
	clr.b	hoogte*160+1120(a0)
	clr.b	hoogte*160+1280(a0)
	clr.b	hoogte*160+1440(a0)
	clr.b	hoogte*160+1600(a0)
	clr.b	hoogte*160+1760(a0)
nextp1	moveq	#hoogte,d7
copy8pix	move.b	(a3),(a5)
	move.b	1(a3),(a0)
	move.w	8(a3),(a3)
	add.w	#160,a5
	add.w	#160,a0
	add.w	#160,a3
	dbf	d7,copy8pix
	addq.w	#8,d5
	addq.w	#8,a1
	dbf	d6,copylines

	move.l	savea3(pc),a3
	rts
savea3	dc.l	0

sinindex	dc.w	0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38
	dc.w	40,42,44,46,48,50,52,54,56,58,60,62,64,66,68,70,72,74
	dc.w	76,78,80

;-----------------voorbereken routine voor sprites-----------------------	

sprhoogte	=	14

subsprite	lea	sprpoin,a0	;copy original block to
	lea	spritebuf,a1	;sprite block0
	move.l	a1,a6
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
shiftspr	moveq	#sprhoogte-1,d6
shift	movem.l	(a6)+,d0-d3
	ror.l	#1,d0
	ror.l	#1,d1
	ror.l	#1,d2
	ror.l	#1,d3
	movem.l	d0-d3,(a1)
	add.w	#16,a1
	dbf	d6,shift
	dbf	d7,shiftspr
	
	lea	spritebuf,a6	;every block will get 
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

	lea	ysprdatas,a0	;multiply ydatas *160
nextydata	move.w	(a0),d0
	bmi.s	endydata
	sub.w	#12,d0
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
endxdata	move.l	xenddata-4,xsprdatas-4
	move.l	yenddata-4,ysprdatas-4
	rts

;-----------------echte sprite rout voor interupt------------------------
movespr	move.w	8(a0),d0
	move.w	-4(a5,d0.w),d3
	move.w	(a5,d0.w),d1
	cmp.w	#-1,d1
	bne.s	xnotend
	move.w	#0,8(a0)
	move.w	xsprdatas(pc),d1
	move.w	xenddata-4(pc),d3
xnotend	move.w	10(a0),d0
	move.w	-4(a6,d0.w),d4
	move.w	(a6,d0.w),d2
	bpl.s	ynotend
	move.w	#0,10(a0)
	move.w	ysprdatas(pc),d2
	move.w	yenddata-4(pc),d4
ynotend	add.l	#$20002,8(a0)
	movem.w	d1-d4,(a0)
	rts

spraant	= 12

sprrout	lea	sprite0(pc),a0
	move.l	scr1(pc),a1	
	lea	ysprdatas(pc),a6
	lea	xsprdatas(pc),a5
	moveq	#spraant-1,d5
clrspr	move.l	a1,a3
	
	bsr.s	movespr		;move sprite on screen
	
	lea	realscherm-$10000,a2;background picture
	move.l	a1,a3
	clr.w	d0
	move.b	4(a0),d0		;screen + x*8 + y*160
	add.w	d0,a3		
	add.w	d0,a2
	add.w	d4,a3
	add.w	d4,a2
	moveq	#sprhoogte-1,d7	;copy old back to screen
copyback	move.l	(a2),(a3)
	move.w	4(a2),4(a3)
	move.l	8(a2),8(a3)
	move.w	12(a2),12(a3)
	add.w	#160,a2
	add.w	#160,a3
	dbf	d7,copyback
	add.w	#12,a0
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
	moveq	#sprhoogte-1,d7
copyspr	move.l	(a4)+,d0
	and.w	d0,8(a1)
	and.w	d0,10(a1)
	and.w 	d0,12(a1)
	movem.l	(a3)+,d1-d4
	or.w	d1,8(a1)
	or.w	d2,10(a1)
	or.w	d3,12(a1)
	swap	d0
	swap	d1
	swap	d2
	swap	d3
	and.w	d0,(a1)
	and.w	d0,2(a1)
	and.w	d0,4(a1)
	or.w	d1,(a1)
	or.w	d2,2(a1)
	or.w	d3,4(a1)
	add.w	#160,a1
	dbf	d7,copyspr
	addq.w	#8,a0
	dbf	d5,setspr
	rts

scr0	dc.l	realscherm
scr1	dc.l	realscherm-$8000

spriteadr	dc.l	spritebuf
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

sprite0	dc.w	0		;xpos
	dc.w	0		;ypos
	dc.w	0		;old xpos
	dc.w	0		;old ypos
	dc.w	0		;xindex 
	dc.w	0		;yindex

sprite1	dc.w	0,0,0,0
	dc.w	4,4
sprite2	dc.w	0,0,0,0
	dc.w	8,8
sprite3	dc.w	0,0,0,0
	dc.w	12,12
sprite4	dc.w	0,0,0,0
	dc.w	16,16
sprite5	dc.w	0,0,0,0
	dc.w	20,20
sprite6	dc.w	0,0,0,0
	dc.w	24,24
sprite7	dc.w	0,0,0,0
	dc.w	28,28
	ds.w	4
	dc.w	32,32
	ds.w	4
	dc.w	36,36
	ds.w	4
	dc.w	40,40
	ds.w	4
	dc.w	44,44
	ds.w	4
	dc.w	48,48
;-----------------move sprite on screen--------------------------------

	dc.w	0,0			;2 x-save words	
xspdatas	incbin	\intro10.htl\xsprdata.sin
xenddata	dc.w	-1
xsprdatas	=xspdatas+2

	dc.w	0,0			;2 y-save words
yspdatas	incbin	\intro10.htl\ysprdata.sin
yenddata	dc.w	-1
ysprdatas	=yspdatas+2

	dc.w	0,0
sindata	incbin	\intro10.htl\sindatas.sin
sinend	dc.w	-1

;text always in UPPERCASE (most characters included !!)
text	dc.b "** THIS MEGA INTRO WAS CODED BY -LAIR- "
	DC.B "GRAPHIX DRAWN BY -SENSE- *** WHEN YOU USE THIS "
	DC.B "INTRO , THEN INCLUDE THE CODER AND GRAPHIX MAN OF "
	DC.B "THIS INTRO !!! ..... 12 PARALAX SPRITES AND A SINUS "
	DC.B "SCROLLER ARE THE MAIN OBJECTS OF THIS INTRO !! "
	DC.B "MEGA GRETTINGS TO:-SENSE- , -LOTUS- , -LETHAL- ,"
	DC.B " -SLEDGE- , -BIRDY- , -ACE- , -MICK- AND -KAM- "
	DC.B "............ C.U. IN LAIR'S NEXT INTRO !!!"
	DC.B "   					"
	dc.b 0	;END OF SCROLLER

color0	incbin	\intro10.htl\color0.col
chblok	incbin	\intro10.htl\chars.pic
music	incbin	\intro10.htl\atomix.mus
spritepic	incbin	\intro10.htl\sprite.pic
logocolor	incbin	\intro10.htl\logo.col
backpic	incbin	\intro10.htl\landscap.pic
logo	incbin	\intro10.htl\logo.pic
sprpoin	=	spritepic
spritebuf	=	backpic
eof