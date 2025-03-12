; Listing 4: Verbesserte Version der Farbbalken (Listing 1)
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

	move.w	$ffff8240.w,oldback
	move.b	#$02,$ffff820a.w

	bsr	hblon

	move.l	#text,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	cmp.b	#"j",d0
	beq	resident

	bsr	hbloff

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

resident:
	line_a	$9		;mouse on
	move.l	#stack,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	move.l	#gpb,a0
	sub.l	#x,a0
	add.w	#$100,a0
	clr.w	-(sp)
	move.l	a0,-(sp)
	move.w	#$31,-(sp)	;keep
	trap	#1
blk.w $100,0
stack:
;----------------------------------
savereg: dc.l 0
oldback: dc.w 0
scandelay: dc.w 0
plus: dc.w 1
text: dc.b 27,"EProgramm resident halten ? (j)",0
even
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
	move.b	#128-1,$fffffa21.w 
	move.b	#8,$fffffa1b.w

	move.w	d0,-(sp)	;Feinverschiebung hoch-runter
	move.w	plus,d0
	add.w	d0,scandelay
	bne	weiter1
	move.w	#1,plus
weiter1:
	cmp.w	#7,scandelay
	bne	weiter2
	move.w	#-1,plus
weiter2:
	move.w	(sp)+,d0
new4b:
	jmp	$000000

newtb:
	clr.b	$fffffa1b.w	;timer stop
	movem.l	d0-d3/a0-a1,-(sp)
	move.w	#$fa21,a1
	move.b	#200,(a1)
	move.b	#8,$fffffa1b.w

	move.b	(a1),d0
wait:				;auf Ende der Zeile warten
	cmp.b	(a1),d0
	beq	wait
	move.w	scandelay,d3	;anzahl der zeilen
				;um die nach unten verschoben wird
	move.w	#$2700,sr
	moveq	#30,d2
	move.w	#$8209,a0	;Videoadresszaehler
waitloop:			;auf Beginn der nÑchsten Zeile warten
	move.b	(a0),d0
	beq	waitloop
	sub.w	d0,d2
	lsl.l	d2,d0		;hier wird synchronisiert

	moveq	#19,d0		;Hiermit kann die Streifen horizontal
				;verschieben
waitloop2:			;Ende der Zeile abwarten
	nop
	dbf	d0,waitloop2

scandelayloop:			;Warteschleife fÅr 1-8 Zeilen
	blk.w	125,$4e71	;$4e71 = nop
	dbra	d3,scandelayloop

	move.w	#$8240,a0	; $ff8240 = Hintergrundfarbe
	moveq	#100,d0		; Schleifenzaehler

loop:			; das ist die 512 Takzyklenschleife aus Listing 1
	move.w	#$777,(a0)
	move.w	#$766,(a0)
	move.w	#$755,(a0)
	move.w	#$744,(a0)
	move.w	#$733,(a0)
	move.w	#$722,(a0)
	move.w	#$700,(a0)
	move.w	#$710,(a0)
	move.w	#$720,(a0)
	move.w	#$730,(a0)
	move.w	#$740,(a0)
	move.w	#$750,(a0)
	move.w	#$760,(a0)
	move.w	#$770,(a0)
	move.w	#$761,(a0)
	move.w	#$752,(a0)
	move.w	#$743,(a0)
	move.w	#$734,(a0)
	move.w	#$725,(a0)
	move.w	#$716,(a0)
	move.w	#$727,(a0)
	move.w	#$737,(a0)
	move.w	#$747,(a0)
	move.w	#$757,(a0)
	move.w	#$767,(a0)
	move.w	#$577,(a0)
	move.w	#$566,(a0)
	move.w	#$555,(a0)
	move.w	#$544,(a0)
	move.w	#$533,(a0)
	move.w	#$522,(a0)
	move.w	#$500,(a0)
	move.w	#$510,(a0)
	move.w	#$520,(a0)
	move.w	#$530,(a0)
	move.w	#$540,(a0)
	move.w	#$550,(a0)
	move.w	#$560,(a0)
	move.w	#$570,(a0)
	move.w	#$561,(a0)
	move.w	#$552,(a0)
	nop
	nop			;zum Ausgleich fÅr die 512 Taktzyklen
	dbf	d0,loop		; und von vorne
	move.w	oldback(pc),(a0)
	movem.l	(sp)+,d0-d3/a0-a1
	bclr	#0,$fffffa0f.w	;end of interrupt
	rte
gpb:
