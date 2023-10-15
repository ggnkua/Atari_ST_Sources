; Listing 1: Weg mit dem rechten Rand
; fÅr K-SEKA ab 1.5 in Farbe; Programm von Gunter (6719)

screen = $70000
 
x:
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	move.l	d0,savereg
	lea	screen,a7

	move.l	#moff,-(sp)
	clr.w	-(sp)
	move.w	#25,-(sp)
	trap	#14
	addq.l	#8,sp
	line_a $a		;mouse off

	move.l	$44e.w,oldscreen
	move.b	$ffff8260,d0
	and.w	#3,d0
	move.w	d0,oldres

	move.w	#0,-(sp)
	move.l	#screen,-(sp)
	move.l	#screen,-(sp)
	move.w	#5,-(sp)
	trap	14
	lea	12(sp),sp

	bsr	prepare		;bildschirm aufbauen

	move.b	$ffff820a.w,oldsync
	move.b	#$02,$ffff820a.w

	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,oldpal
	movem.l	pal(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w

	bsr	hblon

	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

	bsr	hbloff

	movem.l	oldpal(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.b	oldsync(pc),$ffff820a.w
	move.w	oldres(pc),-(sp)
	move.l	oldscreen(pc),-(sp)
	move.l	oldscreen(pc),-(sp)
	move.w	#5,-(sp)
	trap	14
	lea	12(sp),sp

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
	clr.w	-(sp)
	trap	#1

;------------------------------------
savereg:	dc.l 0
oldscreen:	dc.l 0
oldres:		dc.w 0
oldpal:		blk.l 8,0
oldsync:	dc.b 0
even
mon:		dc.b $08
moff:		dc.b $12
;------------------------------------
prepare:
	lea	screen,a0
	moveq	#-1,d1
	move.w	#10199,d0	;screenlÑnge, wenn Rand Åber 200 Zeilen
clsloop:			;offen wÑre
	move.l	d1,(a0)+
	dbf	d0,clsloop

	move.l	#33*160+screen,a6
	moveq	#0,d4
kgloop:
	lea	kasten(pc),a0
	move.w	#15,d7
gzloop:
	move.l	a6,a1
	add.w	#204,a6		;bytes pro Zeile

	movem.l	(a0)+,d0-d1
	moveq	#25-1,d6	;Anzahl KÑstchen
gsloop:
	movem.l	d0-d1,(a1)
	addq.l	#8,a1
	dbf	d6,gsloop
	addq.w	#1,d4
	cmp.w	#150,d4		;150 Zeilen mit Muster fÅllen
	beq.s	kgende
	dbf	d7,gzloop
	bra.s	kgloop
kgende:
	rts

pal:
	dc.w $0000,$0076,$0210,$0650,$0320,$0760,$0540,$0430
	dc.w $0527,$0111,$0222,$0333,$0444,$0555,$0666,$0777
kasten:
	dc.w $0001,$0000,$FFFF,$FFFF,$7FFD,$7FFC,$8003,$FFFF
	dc.w $4005,$7FFC,$8003,$FFFF,$5FF5,$7FFC,$8003,$FFFF
	dc.w $5015,$701C,$8FE3,$FFFF,$57D5,$701C,$8FE3,$FFFF
	dc.w $5455,$739C,$8FE3,$FFFF,$5555,$739C,$8FE3,$FFFF
	dc.w $5455,$739C,$8FE3,$FFFF,$57D5,$701C,$8FE3,$FFFF
	dc.w $5015,$701C,$8FE3,$FFFF,$5FF5,$7FFC,$8003,$FFFF
	dc.w $4005,$7FFC,$8003,$FFFF,$7FFD,$7FFC,$8003,$FFFF
	dc.w $0001,$0000,$FFFF,$FFFF,$FFFF,$0000,$FFFF,$FFFF
;------------------------------------
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
	move.b	#32-1,$fffffa21.w 
	move.b	#8,$fffffa1b.w
new4b:
	jmp	$000000

newtb:
	clr.b	$fffffa1b.w	;timer stop
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$fa21,a2
	move.b	#200,(a2)
	move.b	#8,$fffffa1b.w
	move.w	#$2700,sr

	move.w	#$8209,a0
	move.w	#$8800,a6
;	move.w	#$8240,a3	;frei, um Kontrollfarben zu setzen

	moveq	#0,d0
	moveq	#0,d1
	moveq	#16,d2
	moveq	#2,d3
	moveq	#0,d4

	move.b	(a2),d7
wait:				;auf Ende der Zeile warten
	cmp.b	(a2),d7
	beq	wait

waitloop:
	move.b	(a0),d0
	beq.s	waitloop
	sub	d0,d2
	lsl.w	d2,d1

anfang:
	blk.w	30,$4e71	;$4e71 = nop
	moveq	#14,d0
delayloop1:
	nop
	dbf	d0,delayloop1

	lea	$ff820a,a0
	move.w	#149,d0
zeilenloop2:
	nop
	nop
	nop
	nop
	nop
	moveq	#20,d1
delayloop2:
	nop
	dbf	d1,delayloop2
	nop
	nop
	nop

	move.b	d4,(a0)		;50/60 Hz fuer rechten rand
	move.b	d3,(a0)

	blk.w	27,$4e71
	dbf	d0,zeilenloop2

	movem.l	(sp)+,d0-d7/a0-a6
	bclr	#0,$fffffa0f.w
	rte
