; Listing 3: Entfernt den unteren und oberen Rand
; fÅr K-SEKA ab 1.5  Programm von Gunter (6719)
; auch falls wir uns wiederholen: nur in Farbe lauffÑhig

 
x:
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	move.l	d0,savereg
	move.l	#$70000,a7

	move.l	#moff,-(sp)
	clr.w	-(sp)
	move.w	#25,-(sp)
	trap	#14
	addq.l	#8,sp
	line_a $a		;mouse off

	move.w	#4,-(sp)        
	trap	#14
	addq.l	#2,sp
	move.w	d0,oldrez
	move.l	$44e.w,oldscr
	move.l	#$70000,screen	;neuer Bildschirm

	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,oldpal
	move.b	#$02,$ffff820a.w

	bsr	prepare
	bsr	hblon

	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

	bsr	hbloff

	movem.l	oldpal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.w	oldrez,-(sp)
	move.l	oldscr,-(sp)
	move.l	oldscr,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	move.l	#mon,-(sp)
	clr.w	-(sp)
	move.w	#25,-(sp)
	trap	#14
	addq.l	#8,sp
	line_a	$9		;mouse on
	move.l	savereg,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

;	illegal
	clr.l	-(sp)
	trap	#1

oldrez:  dc.w 0
oldscr:  dc.l 0
savereg: dc.l 0
screen:  dc.l 0
oldpal:  blk.w 16,0
mon:  dc.b $08
moff: dc.b $12

;-----------------------------
hblon:
	move.l	$120.w,oldtb	;Vektoren retten
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
	move.l	old4,$70.w
	move.w	(sp)+,sr
	rts

old4:  dc.l 0
oldtb: dc.l 0
old07: dc.b 0
old09: dc.b 0
old0f: dc.b 0
old11: dc.b 0
old1b: dc.b 0
even

new4:
	clr.b	$fffffa1b.w
	move.b	#199,$fffffa21.w
	move.b	#8,$fffffa1b.w
new4b:
	jmp	$000000

newtb:
	clr.b	$fffffa1b.w	;timer stop
	movem.l	d0-d1/a0-a1,-(sp)
	move.w	#$fa21,a1
	move.b	#47,(a1)
	move.b	#8,$fffffa1b.w

	move.b	(a1),d0
wait:				;auf Ende der letzten Zeile warten
	cmp.b	(a1),d0
	beq	wait
				;jetzt sind wir rechts im Rand
	clr.b	$ffff820a.w	;60 Hz

	moveq	#3,d0
nopi2:				;ein wenig warten
	nop
	dbf	d0,nopi2
				;jetzt sind wir im linken Rand
	move.b	#2,$ffff820a.w	;50 Hz
	move.w	#$777,$ff8240	;Markierung

	movem.l	(sp)+,d0-d1/a0-a1
	move.l	#newtb2,$120.w
	bclr	#0,$fffffa0f.w	;end of interrupt
	rte

newtb2:
	clr.b	$fffffa1b.w	;timer stop
	movem.l	d0-d1/a0-a1,-(sp)
	move.w	#$fa21,a1
	move.b	#200,(a1)	;dummy wert
	move.b	#8,$fffffa1b.w
	move.l	#newtb,$120.w
	move.l	old4(pc),$70.w	;level 4 wird nicht mehr benîtigt

	move.b	(a1),d0
wait2:				;auf Ende der Zeile warten
	cmp.b	(a1),d0
	beq	wait2

	moveq	#35,d0
scandelay:
	blk.w	125,$4e71
	dbf	d0,scandelay

	moveq	#29,d0
wait3:
	nop
	dbf	d0,wait3
				;oberer Rand: 1. Versuch
	clr.b	$ffff820a.w	;60 Hz
	moveq	#3,d0
nopi3:				;ein wenig warten
	nop
	dbf	d0,nopi3
				;jetzt sind wir im linken Rand
	move.b	#2,$ffff820a.w	;50 Hz
	move.w	#$700,$ff8240	;Markierung

	moveq	#14,d0
scandelay2:
	blk.w	125,$4e71
	dbf	d0,scandelay2

	moveq	#23,d0
wait4:
	nop
	dbf	d0,wait4
				;Oberer Rand: 2. Versuch
	clr.b	$ffff820a.w	;60 Hz
	moveq	#3,d0
nopi4:				;ein wenig warten
	nop
	dbf	d0,nopi4
				;jetzt sind wir im linken Rand
	move.b	#2,$ffff820a.w	;50 Hz
	move.w	#$070,$ff8240	;Markierung

	clr.b	$fffffa1b.w	;timer stop
	move.b	#199+13,$fffffa21.w
	move.b	#8,$fffffa1b.w

	movem.l	(sp)+,d0-d1/a0-a1
	bclr	#0,$fffffa0f.w	;end of interrupt
	rte

;-----------------------------
prepare:
	move.w	#0,-(sp)	;set low res
	move.l	screen(pc),-(sp)
	move.l	screen(pc),-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	movem.l	graphic(pc),d6-d7
	move.l	screen(pc),a0
	move.w	#300-1,d1	;300 zeilen ausfuellen

alles:
	moveq	#20-1,d0	;20*16 pixel = eine zeile
zeile1:
	move.l	d6,(a0)+
	move.l	d7,(a0)+
	dbf	d0,zeile1
	dbf	d1,alles

	movem.l pal1(pc),d0-d3
	movem.l	d0-d3,$ffff8240.w
	rts

graphic:
dc.w	$55AA,$33CC,$0FF0,$0000

pal1:
dc.w	$000,$111,$222,$333,$444,$555,$666,$777
