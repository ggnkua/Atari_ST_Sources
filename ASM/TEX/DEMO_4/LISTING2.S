;Listing 2: Ein Scroller, der nur aus Hintergrundfarbe besteht
;	    FÅr K-Seka 1.5; natÅrlich nur in Farbe

x:
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	move.l	d0,savereg
	move.l	#$80000,a7

	move.l	#moff,-(sp)
	clr.w	-(sp)
	move.w	#25,-(sp)
	trap	#14
	addq.l	#8,sp
	line_a	$a		;mouse off
	bsr	clearscr

	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,oldpal
	movem.l	clrpal(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.b	$ffff820a.w,oldsync
	move.b	#$02,$ffff820a.w
	move.l	textstart(pc),textpos
	move.l	#45*5+buchstaben,buchst_addr	;space 
	bsr	hblon
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	bsr	hbloff
	move.b	oldsync(pc),$ffff820a.w
	movem.l	oldpal(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w

	move.l	#mon,-(sp)
	clr.w	-(sp)
	move.w	#25,-(sp)
	trap	#14
	addq.l	#8,sp
	line_a	$9		;mouse on
	move.l	savereg(pc),-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

;	illegal
	clr.w	-(sp)
	trap	#1

;------------------------------------
savereg:	dc.l 0
oldpal:		blk.l 8,0
clrpal:		blk.l 8,0
oldsync:	dc.b 0
mon:		dc.b $08
moff:		dc.b $12
even

clearscr:
	move.l	$44e.w,a1
	lea	$7d00(a1),a1
	movem.l	clrpal(pc),d1-d7/a0
	move.w	#1000-1,d0
clsloop:
	movem.l	d1-d7/a0,-(a1)
	dbf	d0,clsloop
	rts

hblon:
	move.l	$120.w,oldtb	;Vektoren retten
	move.l	$118.w,oldkey
	move.l	$118.w,newkey2+2
	move.l	$70.w,old4
	move.l	$70.w,new4b+2
	move.b	$fffffa07.w,old07
	move.b	$fffffa09.w,old09
	move.b	$fffffa0f.w,old0f
	move.b	$fffffa11.w,old11
	move.b	$fffffa1b.w,old1b
	and.b	#$df,$fffa09	;disable Timer C
	and.b	#$fe,$fffa07	;disable Timer B
	move.l	#newtb,$120.w
	move.l	#new4,$70.w
	move.l	#newkey,$118.w
	or.b	#1,$fffffa07.w	;Timer B erlauben
	or.b	#1,$fffffa13.w
	rts

hbloff:
	move.w	sr,-(sp)
	move.w	#$2700,sr
	move.b	old07(pc),$fffffa07.w    ;restore all registers
	move.b	old09(pc),$fffffa09.w
	move.b	old0f(pc),$fffffa0f.w
	move.b	old11(pc),$fffffa11.w
	move.b	old1b(pc),$fffffa1b.w
	move.l	oldtb,$120.w             ;restore vectors
	move.l	oldkey(pc),$118.w
	move.l	old4,$70.w
	move.w	(sp)+,sr
	rts

old4:  dc.l 0
oldtb: dc.l 0
oldkey: dc.l 0
old07: dc.b 0
old09: dc.b 0
old0f: dc.b 0
old11: dc.b 0
old1b: dc.b 0
even

new4:
	movem.l	d0-d7/a0,-(sp)
	move.b	#0,$fffffa1b.w

	move.l	bahnpos(pc),a0
	addq.l	#2,bahnpos
	move.w	(a0)+,d0		;aktuelle Zeile des Scrollers
	tst.w	(a0)
	bpl.s	bahnposok
	move.l	#jumpbahn,bahnpos
bahnposok:
	move.w	d0,d1
	and.w	#$fff8,d1		;Rasterinterrupt in 8er Schritten
	sub.w	#1,d1
	and.w	#7,d0
	move.w	d0,scandelay		;Rest merken
	move.b	d1,$fffffa21.w		;Zeile fÅr Rasterinterrupt
	move.b	#8,$fffffa1b.w		;setzen
	movem.l	(sp)+,d0-d7/a0
new4b:
	jmp	$0

newkey:
	move.w	#$2500,sr		;Keyboard kann von Timer b unter-
newkey2:				;brochen werden
	jmp	$0

newtb:
	movem.l	d0-d7/a0-a6,-(sp)
	move.b	#0,$fffffa1b.w
	move.b	#250,$fffffa21.w
	move.b	#8,$fffffa1b.w

syncloop:
	cmp.b	#249,$fffffa21.w	;bis Zeilenende warten
	bne.s	syncloop

	moveq	#30,d2
	moveq	#0,d0
	move.w	scandelay(pc),d3	;anzahl der zeilen um die nach
	moveq	#0,d4			;unten verschoben wird

	move.w	#$2700,sr

	lea	$ffff8209.w,a0		;lowbyte videoadresse
waitloop:
	move.b	(a0),d0
	beq.l	waitloop

	sub.w	d0,d2
	lsl.l	d2,d0			;sorgt fÅr sync

	moveq	#16,d0
waitloop2:				;wartet bis Zeilenende
	nop
	dbf	d0,waitloop2

scandelayloop:				;um d3+1 Zeilen verzîgern
	exg	d1,d1
	blk.w	123,$4e71		;$4e71 = nop (siehe Artikel)
	dbf	d3,scandelayloop

	move.w	#$8240,a1
	lea	regenbogen(pc),a0	;Farbtabelle
;--------------------------------------
	moveq	#0,d0
	moveq	#7,d1			;5 dbf-ZÑhler laden
	moveq	#7,d2
	moveq	#7,d3
	moveq	#7,d4
	moveq	#7,d5
	move.w	(a0)+,d7		;erste Farbe fÅr Scroller holen

	move.w	nummer(pc),d6		;'Scrollbit' entweder um 0 oder 4
	lsl.l	d6,d6			;Pixel verschieben

;-------------------------------------- 1
scanloop1:
	nop
	nop
	nop
	nop
inloop1:
	blk.w 55,$3280		;= move.w d0,(a1)
				;55 Befehle = 440 cyc +16 (4*nop)
	nop			;Ab hier sieht niemand mehr etwas
	nop			;wir befinden uns in der AustastlÅcke
	nop
	nop
	nop
				;476
	move.w	(a0)+,d7	;neue Farbe holen
	nop
	nop
	nop
				;496
	nop
	dbf	d1,scanloop1
;--------------------------------------  2
	bra.s	inloop2

scanloop2:
	nop
	nop
	nop
	nop
inloop2:
	blk.w 55,$3280		;= move.w d0,(a1)
				;55 Befehle = 440 cyc +16 (4*nop)
	nop			;Ab hier sieht niemand mehr etwas
	nop			;wir befinden uns in der AustastlÅcke
	nop
	nop
	nop
				;476
	move.w	(a0)+,d7	;neue Farbe holen
	nop
	nop
	nop
				;496
	nop
	dbf	d2,scanloop2
;--------------------------------------  3
	bra.s	inloop3

scanloop3:
	nop
	nop
	nop
	nop
inloop3:
	blk.w 55,$3280		;= move.w d0,(a1)
				;55 Befehle = 440 cyc +16 (4*nop)
	nop			;Ab hier sieht niemand mehr etwas
	nop			;wir befinden uns in der AustastlÅcke
	nop
	nop
	nop
				;476
	move.w	(a0)+,d7	;neue Farbe holen
	nop
	nop
	nop
				;496
	nop
	dbf	d3,scanloop3
;--------------------------------------  4
	bra.s	inloop4

scanloop4:
	nop
	nop
	nop
	nop
inloop4:
	blk.w 55,$3280		;= move.w d0,(a1)
				;55 Befehle = 440 cyc +16 (4*nop)
	nop			;Ab hier sieht niemand mehr etwas
	nop			;wir befinden uns in der AustastlÅcke
	nop
	nop
	nop
				;476
	move.w	(a0)+,d7	;neue Farbe holen
	nop
	nop
	nop
				;496
	nop
	dbf	d4,scanloop4
;--------------------------------------  5
	bra.s	inloop5

scanloop5:
	nop
	nop
	nop
	nop
inloop5:
	blk.w 55,$3280		;= move.w d0,(a1)
				;55 Befehle = 440 cyc +16 (4*nop)
	nop			;Ab hier sieht niemand mehr etwas
	nop			;wir befinden uns in der AustastlÅcke
	nop
	nop
	nop
				;476
	move.w	(a0)+,d7	;neue Farbe holen
	nop
	nop
	nop
				;496
	nop
	dbf	d5,scanloop5
;-------------------------------------- ende der Sync-Schleifen
; der folgende Teil ist fÅr das eigentliche Scrolling zustÑndig

	move.w	d0,$ffff8240.w
	move.w	#$2500,sr

	tst.w	vblwaitcount	;soll scroller noch stehen ?
	beq.s	laufen
	subq.w	#1,vblwaitcount
	bra	nummerok
laufen:
	subq.w	#2,nummer
	bpl	nummerok	;= fertig (es wurde nur nummer geÑndert)
	move.w	#2,nummer

;Farbtabelle (oder besser: Programmcode) um 1 nach links scrollen
	lea	inloop1(pc),a6
	movem.l 2(a6),d0-d7/a0-a5	;14 Long
	movem.l d0-d7/a0-a5,(a6)
	movem.l 58(a6),d0-d7/a0-a4	;13 Long
	movem.l d0-d7/a0-a4,56(a6)
	lea	inloop2(pc),a6
	movem.l 2(a6),d0-d7/a0-a5	;14 Long
	movem.l d0-d7/a0-a5,(a6)
	movem.l 58(a6),d0-d7/a0-a4	;13 Long
	movem.l d0-d7/a0-a4,56(a6)
	lea	inloop3(pc),a6
	movem.l 2(a6),d0-d7/a0-a5	;14 Long
	movem.l d0-d7/a0-a5,(a6)
	movem.l 58(a6),d0-d7/a0-a4	;13 Long
	movem.l d0-d7/a0-a4,56(a6)
	lea	inloop4(pc),a6
	movem.l 2(a6),d0-d7/a0-a5	;14 Long
	movem.l d0-d7/a0-a5,(a6)
	movem.l 58(a6),d0-d7/a0-a4	;13 Long
	movem.l d0-d7/a0-a4,56(a6)
	lea	inloop5(pc),a6
	movem.l 2(a6),d0-d7/a0-a5	;14 Long
	movem.l d0-d7/a0-a5,(a6)
	movem.l 58(a6),d0-d7/a0-a4	;13 Long
	movem.l d0-d7/a0-a4,56(a6)

;bitmuster des buchstabens anhaengen
	move.l	buchst_addr(pc),a0
	lea	inloop1+108(pc),a1	;letzte Position
	move.b	bitnummer(pc),d1

	moveq	#4,d2			;5 Pixels hoch
	move.w	#$3280,d0		;= move.w d0,(a1)
	move.w	#$3287,d7		;= move.w d7,(a1)

bitcopyloop:				;eine Pixelspalte anhÑngen
	btst	d1,(a0)+
	beq.s	bitnichtgesetzt
	move.w	d7,(a1)
	bra.s	gesetztok
bitnichtgesetzt:
	move.w	d0,(a1)
gesetztok:
	lea	inloop2-inloop1(a1),a1	;Distanzwert zur nÑchsten Loop
	dbf	d2,bitcopyloop

	subq.b	#1,bitnummer		;neuen Buchstaben holen ?
	bpl.s	bitnummerok		;nein, dann raus

	lea	proportionaltab(pc),a0
	move.l	textpos(pc),a1
	moveq	#0,d0
	move.b	(a1)+,d0
	bpl.s	textok			;Textende ?
	move.l	textstart(pc),a1	;ja, Text von vorne laufen lassen
	move.b	(a1)+,d0
textok:
	cmp.b	#127,d0
	bne.s	nichtwarten
	move.b	(a1)+,d0		;gibt an, wie lange der Scroller
	lsl.w	#4,d0
	move.w	d0,vblwaitcount		;stehen soll
	moveq	#0,d0
	move.b	(a1)+,d0
nichtwarten:
	move.l	a1,textpos
	move.b	(a0,d0.w),bitnummer	;aus Proportionaltab
	subq.b	#1,bitnummer
	lea	buchstaben(pc),a0
	mulu	#5,d0			;5 Bytes pro Buchstabe
	add.w	d0,a0
	move.l	a0,buchst_addr		;Adresse merken

bitnummerok:
nummerok:
	movem.l	(sp)+,d0-d7/a0-a6
	bclr	#0,$fffffa0f.w
	rte

nummer:		dc.w 0
bitnummer:	dc.w 0
buchst_addr:	dc.l 0
textpos:	dc.l 0
scandelay:	dc.w 0
bahnpos:	dc.l 0
vblwaitcount:	dc.w 0

textstart:	dc.l testtext
testtext:
	dc.b 45,45,3,8,4,$12,45,8,$12,$13,45,$d,$14,$11,45,4,8,$d
	dc.b 45,$a,$b,4,8,$d,4,$11,45,$13,4,$12,$13,45,45,45,45,45
	dc.b $12,$13,$e,$f,45,45,45,45,127,10
	dc.b $d,$14,$d,45,0,$b,$b,4,45,38,45,45,45
	dc.b 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
	dc.b 20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35
	dc.b 36,37,38,39,40,41,42,43,44,45,46,47,48,49
	dc.b -1

proportionaltab:
	blk.b 8,5
	dc.b 2,5,5,5,6,5,5,5,5,5,5,6,5,6,6,6,6,6,6,4,5,5,6
	blk.b 5,5
	dc.b 3,2,2,3,3,5,5,4,4,4,6,5,5,3
	even

regenbogen:
	dc.w $700,$710,$720,$730,$740,$750,$760,$770,$670,$570
	dc.w $470,$370,$270,$170,$070,$071,$072,$073,$074,$075
	dc.w $076,$077,$067,$057,$047,$037,$027,$017,$007,$107
	dc.w $207,$307,$407,$507,$607,$707,$706,$705,$704,$713

jumpbahn:		;kann wie Åblich gekÅrzt werden
 dc.w 146,148,151,153,156,158,161,163,166,169
 dc.w 172,175,178,181,184,181,178,175,172,169
 dc.w 166,163,161,158,156,153,151,148,146,144
 dc.w 141,139,137,135,133,131,130,128,126,124
 dc.w 123,121,120,119,117,116,115,114,113,112
 dc.w 111,110,109,108,108,107,107,106,106,105
 dc.w 105,105,105,105,105,105,105,105,105,105
 dc.w 106,106,107,107,108,108,109,110,111,112
 dc.w 113,114,115,116,117,119,120,121,123,124
 dc.w 126,128,130,131,133,135,137,139,141,144
 dc.w 146,148,151,153,156,158,161,163,166,169
 dc.w 172,175,178,181,184,181,178,175,172,169
 dc.w 166,163,161,158,156,153,151,148,146,144
 dc.w 142,140,138,136,134,132,131,129,127,126
 dc.w 124,123,122,120,119,118,117,117,116,115
 dc.w 115,115,115,115,115,115,115,115,116,117
 dc.w 117,118,119,120,122,123,124,126,127,129
 dc.w 130,132,134,136,138,140,141,143,145,147
 dc.w 149,151,153,155,156,158,160,161,163,165
 dc.w 166,167,168,170,171,171,172,173,173,174
 dc.w 174,174,174,174,174,174,174,173,172,172
 dc.w 171,170,169,168,166,165,163,162,160,159
 dc.w 157,155,153,151,150,148,146,144,142,140
 dc.w 138,136,134,133,131,129,128,126,125,123
 dc.w 122,121,120,119,118,117,116,116,115,115
 dc.w 115,115,115,115,115,115,116,117,117,118
 dc.w 119,120,121,123,124,125,127,129,130,132
 dc.w 134,135,137,139,141,143
 dc.w -1		;Endekennung nicht vergessen !

buchstaben:		;enthÑlt Zeichensatz 8*5 Pixel
dc.b $06,$09,$0f,$09,$09,$0e,$09,$0e,$09,$0e,$07,$08,$08,$08,$07,$0e
dc.b $09,$09,$09,$0e,$0f,$08,$0e,$08,$0f,$0f,$08,$0e,$08,$08,$07,$08
dc.b $0b,$09,$07,$09,$09,$0f,$09,$09,$01,$01,$01,$01,$01,$0f,$01,$01
dc.b $01,$0e,$09,$0a,$0c,$0a,$09,$08,$08,$08,$08,$0f,$11,$1b,$15,$11
dc.b $11,$09,$0d,$0f,$0b,$09,$06,$09,$09,$09,$06,$0e,$09,$0e,$08,$08
dc.b $06,$09,$09,$0b,$07,$0e,$09,$0e,$0a,$09,$07,$08,$06,$01,$0e,$1f
dc.b $04,$04,$04,$04,$09,$09,$09,$09,$07,$11,$11,$0a,$0a,$04,$11,$11
dc.b $15,$1b,$11,$11,$0a,$04,$0a,$11,$11,$0a,$04,$04,$04,$1f,$02,$04
dc.b $08,$1f,$0e,$13,$15,$19,$0e,$01,$03,$05,$01,$01,$0e,$01,$02,$04
dc.b $0f,$0e,$01,$06,$01,$0e,$02,$04,$0a,$1f,$02,$0f,$08,$0e,$01,$0e
dc.b $02,$04,$0e,$09,$06,$0f,$01,$02,$04,$08,$06,$09,$06,$09,$06,$06
dc.b $09,$07,$01,$06,$00,$00,$00,$01,$02,$00,$00,$00,$00,$01,$00,$01
dc.b $00,$00,$01,$00,$01,$00,$01,$02,$03,$03,$03,$00,$03,$0e,$01,$06
dc.b $00,$06,$05,$0a,$00,$00,$00,$03,$06,$06,$06,$03,$06,$03,$03,$03
dc.b $06,$00,$00,$00,$00,$00,$04,$04,$1f,$04,$04,$00,$00,$0f,$00,$00
dc.b $01,$03,$06,$0c,$08,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00
even
