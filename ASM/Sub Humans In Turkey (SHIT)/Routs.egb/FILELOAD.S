; On entry to routine:	A0=points to filename
;			A1=address to load file to

	jmp	start_code
print	incbin	c:\source\ratstuff\proprint.o

mess1	dc.w	10,40
	dc.b	'EGB of The Sub Humans in Turkey presents',0
	dc.w	25,40
	dc.b	'              TITANIC BLINKY',0
	dc.w	25,41
	dc.b	'              TITANIC BLINKY',0
	dc.w	25,39
	dc.b	'              ______________',0
	dc.w	40,40
	dc.b	'       Hacked, Packed & Filed by EGB        ',0
	dc.w	60,3
	DC.B	'Thanks to Ruthless of Awesome for the Original...',0
	dc.w	70,3
	DC.B	'Even although it was a non working copy, it was still',0
	dc.w	80,3
	DC.B	'easy to do!!  Please read the help page, as this game',0
	dc.w	90,3
	DC.B	'is rather hard to play on the later stages!!! ',0
	dc.w	105,4
	DC.B	' Greetings are sent to the following cool people . . .',0
	dc.w	120,4
	DC.B	'   Zippy of Medway Boy, The BBC, Inner Circle',0
	dc.w	130,4
	DC.B	'   Neil of Cor Blimey, The Pompey Pirates, The Lost Boys',0
	dc.w	140,4
	DC.B	'   Awesome, Hal, Monster, Snurkel, Ketchin, Arn, Bisc',0
	dc.w	150,4
	DC.B	'   Genesis Inc, The Replicants, Elite, Superior ( Yo Axe! )',0
	dc.w	160,4
	DC.B	'   Equinox, The Napalm Soldiers, Vapour, Dack, and anyone',0
	dc.w	170,4
	DC.B	'   else reading this !!',0
	dc.w	186,4
	dc.b	'Press T for Trainer, H for Help, or SPACE for normal game',0
	dc.w	186,5
	dc.b	'Press T for Trainer, H for Help, or SPACE for normal game',0
	even
mess2	dc.w	25,40
	dc.b	'              TITANIC BLINKY',0
	dc.w	25,41
	dc.b	'              TITANIC BLINKY',0
	dc.w	25,39
	dc.b	'              ______________',0
	dc.w	40,40
	dc.b	'              Trainer Options',0
cheat1	dc.w	60,20
	dc.b	'  Infinite Lives (Y/N)',0
	even

message	dc.w	5,40
	dc.b	'              TITANIC BLINKY',0
	dc.w	5,41
	dc.b	'              TITANIC BLINKY',0
	dc.w	5,39
	dc.b	'              ______________',0
	dc.w	20,40
	dc.b	'               Help Screen',0
	dc.w	30,3
	DC.B	'Controls :',0
	dc.w	40,2
	DC.B	'   Use joystick to control Blinky.',0
	dc.w	50,2
	DC.B	'   Joystick Down to pick up objects.',0
	dc.w	60,2
	DC.B	'   Joystick Up to jump.',0
	dc.w	80,2
	DC.B	'   Firing will kill monsters, or open objects. ',0
	dc.w	90,2
	DC.B	'   ',0
	dc.w	100,2
	DC.B	'   Level 1... You must collect enough musical notes',0
	dc.w	110,2
	DC.B	'   to play a tune on the ships horn. When the horn',0
	dc.w	120,2
	DC.B	'   sounds, a door will open on the left hand side of',0	
	dc.w	130,2
	DC.B	'   the ship.',0
	dc.w	140,3
	DC.B	'   Level 2... An easy level... All you need to do is',0
	dc.w	150,3
	DC.B	'   shoot the captains caps, and collect all the objects',0
	dc.w	160,3
	DC.B	'   When you have collected them all a noise will sound.',0
	dc.w	170,3
	DC.B	'   Go back outside on the ship and jump in the water',0
	dc.w	190,3
	DC.B	'                        Press space',0

messag2	dc.w	5,40
	dc.b	'              TITANIC BLINKY',0
	dc.w	5,41
	dc.b	'              TITANIC BLINKY',0
	dc.w	5,39
	dc.b	'              ______________',0
	dc.w	20,40
	dc.b	'               Help Screen',0
	dc.w	40,2
	DC.B	'   Level 3... Collect all the objects required to',0
	dc.w	50,2
	DC.B	'   open the airlock under the ship. The airlock is',0
	dc.w	60,2
	DC.B	'   above the anchor. ',0
	dc.w	80,2
	DC.B	'   Level 4... you will come to a screen with a lot ',0
	dc.w	90,3
	DC.B	'   of levers on the ground and deflectors in the air.',0
	dc.w	100,3
	DC.B	'   What you have to do, is set the deflectors so that',0
	dc.w	110,3
	DC.B	'   when you pull a lever the machine will fire a shot',0
	dc.w	120,3
	DC.B	'   which hits you. When you are hit, you are transported',0
	dc.w	130,3
	DC.B	'   to a new level, where you need to collect more objects',0
	dc.w	140,3
	DC.B	'   Do the 4th, 2nd and then the 3rd levers to complete ',0
	dc.w	150,3
	DC.B	'   the game. Have fun people....',0
	dc.w	190,3
	DC.B	'                   Press space',0
	even
start_code
	dc.w	$a00a

	clr.l	-(a7)
	move.w	#32,-(a7)
	trap	#1
	addq.w	#6,a7
	
	move.b	#8,$fffffc02.w
	move.b	#0,$484.w
	
	clr.w	-(a7)
	pea	-1.w
	move.l	(a7),-(a7)
	move.w	#5,-(a7)
	trap	#14
	lea	12(a7),a7	

	move.l	$44e.w,print+2
	clr.w	$ffff825e.w

mess_display
	clr.w	-(a7)
	pea	-1.w
	move.l	(a7),-(a7)
	move.w	#5,-(a7)
	trap	#14
	lea	12(a7),a7

	lea	mess1(pc),a0
	moveq.l	#17,d6
.loop	move.w	(a0)+,d1
	move.w	(a0)+,d0
	bsr	print
	move.l	a0,d0
	btst	#0,d0
	beq	.next
	addq.l	#1,a0
.next	dbf	d6,.loop
	
.a	cmp.b	#$39,$fffffc02.w
	beq	nocheat
	cmp.b	#$14,$fffffc02.w
	beq     trainer
	cmp.b	#$23,$fffffc02.w
	beq	help
	bra	.a

help
	clr.w	-(a7)
	pea	-1.w
	move.l	(a7),-(a7)
	move.w	#5,-(a7)
	trap	#14
	lea	12(a7),a7

	lea	message(pc),a0
	moveq.l	#18,d6
.loop	move.w	(a0)+,d1
	move.w	(a0)+,d0
	bsr	print
	move.l	a0,d0
	btst	#0,d0
	beq	.next
	addq.l	#1,a0
.next	dbf	d6,.loop

.again	cmp.b	#$39,$fffffc02.w
	bne	.again

	clr.w	-(a7)
	pea	-1.w
	move.l	(a7),-(a7)
	move.w	#5,-(a7)
	trap	#14
	lea	12(a7),a7

m2	lea	messag2(pc),a0
	moveq.l	#15,d6
.loop	move.w	(a0)+,d1
	move.w	(a0)+,d0
	bsr	print
	move.l	a0,d0
	btst	#0,d0
	beq	.next
	addq.l	#1,a0
.next	dbf	d6,.loop

.again	cmp.b	#$39,$fffffc02.w
	bne	.again

	bra	mess_display

trainer	
	clr.w	-(a7)
	pea	-1.w
	move.l	(a7),-(a7)
	move.w	#5,-(a7)
	trap	#14
	lea	12(a7),a7

	lea	mess2(pc),a0
	moveq.l	#3,d6
.loop	move.w	(a0)+,d1
	move.w	(a0)+,d0
	bsr	print
	move.l	a0,d0
	btst	#0,d0
	beq	.next
	addq.l	#1,a0
.next	dbf	d6,.loop

	lea	cheat1(pc),a0
	move.w	(a0)+,d1
	move.w	(a0)+,d0
	bsr	print
	move.w	#1,$20.w
.ww1	cmp.b	#$15,$fffffc02.w
	beq.s	.ok1
	cmp.b	#$31,$fffffc02.w
	bne.s	.ww1
	move.w	#0,$20.w
.ok1	
nocheat
	lea	$80000,a7
	
reloc_code
	lea	code(pc),a0
	lea	$67e00,a1
	move.w	#$290,d0
.copy	move.l	(a0)+,(a1)+
	dbf	d0,.copy
	jmp	$67e00

code
	org	$67e00
loadfile
	lea	$80000,a7
	move.w	#$2700,sr

	lea	depack(pc),a0		;install routines at $100000
	lea	$140.w,a1
	move.w	#$52,d0
.copy	move.l	(a0)+,(a1)+
	dbf	d0,.copy

	lea	start(pc),a0		;install routines at $100000
	lea	$2000,a1
	move.w	#$159,d0
.copy2	move.l	(a0)+,(a1)+
	dbf	d0,.copy2
	move.w	#$200,d0
.clear	clr.l	(a1)+
	dbf	d0,.clear

	lea	file1(pc),a0
	lea	$70000,a1
	bsr	load
	lea	$70000,a0
	bsr	depack
	
	move.l	#$4ef90000,$709ba
	move.w	#$2000,$709be
	move.w	#$4e75,$70dd2
	move.l	#$4ef90006,$70998
	move.w	#$7e84,$7099c
	jmp	$708d6
	move.l	#$4ef90000,$f0ba
	move.w	#$2000,$f0be
	move.w	#$4e75,$12bce
	move.l	#$31fc0001,$5088
	move.w	#$4f02,$508c
	cmp.w	#1,$20
	bne	.next
	move.w	#$4e71,$50d2
.next	jmp	$3000.w

file1	dc.b	'loader  .bin',0
	even
depack
	link	a3,#-120
	movem.l	d0-a6,-(sp)
	move.l	a0,a1
	move.l	a0,a4		; a4 = Anfang entpackte Daten
	move.l	a0,a6		; a6 = Ende entpackte Daten
	bsr.s	.getinfo
	cmpi.l	#'AU5!',d0	; Kennung gefunden?
	bne	.not_packed
	bsr.s	.getinfo		; gepackte LÑnge holen
	moveq	#119,d1		; 120 Bytes vor gepackten Daten
.save:	move.b	-(a1),-(a3)	; in sicheren Bereich sichern
	dbf	d1,.save
	move.l	a1,a2		; Anfang der gepackten Daten
	lea.l	-8(a1,d0.l),a5	; a5 = Ende der gepackten Daten
.move	move.b	(a0)+,(a1)+
	subq.l	#1,d0
	bne.s	.move
	move.l	a2,a0
	bsr.s	.getinfo		; ungepackte LÑnge holen (original)
	move.l	d0,(sp)		; OriginallÑnge: spÑter nach d0
	adda.l	d0,a6		; a6 = Ende entpackte Daten
	move.l	a6,a3		; merken fÅr Picture decrunch
	move.b	-(a5),d7		; erstes Informationsbyte
	bsr.s	.normal_bytes

	movem.l	(sp),d0-a3	; hole nîtige Register
	moveq	#119,d0		; um Åberschriebenen Bereich
.rest	move.b	-(a3),-(a4)	; wieder herzustellen
	dbf	d0,.rest
.not_packed:
	movem.l	(sp)+,d0-a6
	unlk	a3
	rts

.getinfo: moveq	#3,d1		; ein Langwort vom Anfang
.getbytes: lsl.l	#8,d0		; der Daten lesen
	move.b	(a0)+,d0
	dbf	d1,.getbytes
	rts

.normal_bytes:	
	bsr.s	.get_1_bit
	bcc.s	.test_if_end	; Bit %0: keine Daten
	moveq.l	#0,d1		; falls zu copy_direkt
	bsr.s	.get_1_bit
	bcc.s	.copy_direkt	; Bitfolge: %10: 1 Byte direkt kop.
	lea.l	.direkt_tab+20(pc),a1
	moveq.l	#4,d3
.nextgb:	move.l	-(a1),d0		; d0.w Bytes lesen
	bsr.s	.get_d0_bits
	swap.w	d0
	cmp.w	d0,d1		; alle gelesenen Bits gesetzt?
	dbne	d3,.nextgb	; ja: dann weiter Bits lesen
.no_more: add.l	20(a1),d1 	; Anzahl der zu Åbertragenen Bytes
.copy_direkt:	
	move.b	-(a5),-(a6)	; Daten direkt kopieren
	dbf	d1,.copy_direkt	; noch ein Byte
.test_if_end:	
	cmpa.l	a4,a6		; Fertig?
	bgt.s	.strings		; Weiter wenn Ende nicht erreicht
	rts	

;************************** Unterroutinen: wegen Optimierung nicht am Schluû

.get_1_bit:add.b	d7,d7		; hole ein bit
	bne.s	.bitfound 	; quellfeld leer
	move.b	-(a5),d7		; hole Informationsbyte
	addx.b	d7,d7
.bitfound:	rts	

.get_d0_bits:	
	moveq.l	#0,d1		; ergebnisfeld vorbereiten
.hole_bit_loop:	
	add.b	d7,d7		; hole ein bit
	bne.s	.on_d0		; in d7 steht noch Information
	move.b	-(a5),d7		; hole Informationsbyte
	addx.b	d7,d7
.on_d0:	addx.w	d1,d1		; und Åbernimm es
	dbf	d0,.hole_bit_loop	; bis alle Bits geholt wurden
	rts	

;************************************ Ende der Unterroutinen


.strings: lea.l	.length_tab(pc),a1	; a1 = Zeiger auf Tabelle
	moveq.l	#3,d2		; d2 = Zeiger in Tabelle
.get_length_bit:	
	bsr.s	.get_1_bit
	dbcc	d2,.get_length_bit	; nÑchstes Bit holen
.no_length_bit:	
	moveq.l	#0,d4		; d4 = öberschuû-LÑnge
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0	; d2: zw. -1 und 3; d3+1: Bits lesen
	ext.w	d0		; als Wort behandeln
	bmi.s	.no_Åber		; kein öberschuû nîtig
.get_Åber: bsr.s	.get_d0_bits
.no_Åber: move.b	6(a1,d2.w),d4	; Standard-LÑnge zu öberschuû add.
	add.w	d1,d4		; d4 = String-LÑnge-2
	beq.s	.get_offset_2	; LÑnge = 2: Spezielle Offset-Routine


	lea.l	.more_offset(pc),a1 ; a1 = Zeiger auf Tabelle
	moveq.l	#1,d2
.getoffs: bsr.s	.get_1_bit
	dbcc	d2,.getoffs
	moveq.l	#0,d1		; Offset-öberschuû
	move.b	1(a1,d2.w),d0	; request d0 Bits
	ext.w	d0		; als Wort
	bsr.s	.get_d0_bits
	add.w	d2,d2		; ab jetzt: Pointer auf Worte
	add.w	6(a1,d2.w),d1	; Standard-Offset zu öberschuû add.
	bpl.s	.depack_bytes	; keine gleiche Bytes: String kop.
	sub.w	d4,d1		; gleiche Bytes
	bra.s	.depack_bytes


.get_offset_2:	
	moveq.l	#0,d1		; öberschuû-Offset auf 0 setzen
	moveq.l	#5,d0		; standard: 6 Bits holen
	moveq.l	#-1,d2		; Standard-Offset auf -1
	bsr.s	.get_1_bit
	bcc.s	.less_40		; Bit = %0
	moveq.l	#8,d0		; quenty fourty: 9 Bits holen
	moveq.l	#$3f,d2		; Standard-Offset: $3f
.less_40: bsr.s	.get_d0_bits
	add.w	d2,d1		; Standard-Offset + öber-Offset

.depack_bytes:			; d1 = Offset, d4 = Anzahl Bytes
	lea.l	2(a6,d4.w),a1	; Hier stehen die Originaldaten
	adda.w	d1,a1		; Dazu der Offset
	move.b	-(a1),-(a6)	; ein Byte auf jeden Fall kopieren
.dep_b:	move.b	-(a1),-(a6)	; mehr Bytes kopieren
	dbf	d4,.dep_b 	; und noch ein Mal
	bra	.normal_bytes	; Jetzt kommen wieder normale Bytes


.direkt_tab:
	dc.l $7fff000e,$00ff0007,$00070002,$00030001,$00030001	; Anzahl 1-Bits
	dc.l     270-1,	15-1,	 8-1,	 5-1,	 2-1	; Anz. Bytes

.length_tab:
	dc.b 9,1,0,-1,-1		; Bits lesen
	dc.b 8,4,2,1,0		; Standard-LÑnge - 2 (!!!)

.more_offset:
	dc.b	  11,   4,   7,  0	; Bits lesen
	dc.w	$11f,  -1, $1f	; Standard Offset

ende_ice_decrunch_3:
;*************************************************** Ende der Unpackroutine

start	
	movem.l	d0-d2/a0-a2,-(a7)
	move.l	a0,a1
	lea	chars(pc),a0
	lea	filchar(pc),a2
	move.l	d1,d2
	lsr.l	#8,d2
	and.w	#$f,d2
	move.b	(a0,d2.w),(a2)+	
	move.l	d1,d2
	lsr.l	#4,d2
	and.w	#$f,d2
	move.b	(a0,d2.w),(a2)+	
	move.l	d1,d2
	and.w	#$f,d2
	move.b	(a0,d2.w),(a2)+	
	lea	filename(pc),a0

	move.l	a1,-(a7)
	bsr.w	load			;load
	move.l	(a7)+,a0
	jsr	$140.w
	movem.l	(a7)+,d0-d2/a0-a2
;	moveq.l	#0,d0
	rts	

chars		dc.b	'0123456789ABCDEF'
filename	dc.b	'BLIN_'
filchar		dc.b	'000'
fil3		dc.b	0
	even

load	MOVE	SR,-(A7)
	MOVE	#$2700,SR
	MOVEM.L	A0-A6/D1-D7,-(A7)

	LEA	buff(pc),A4

	CLR.W	40(A4)
	MOVE.L	A0,26(A4)
L0000	TST.B	(A0)+
	BNE.S	L0000
	MOVE.L	A0,30(A4)
	MOVE.L	A1,(A4)
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVEQ	#0,D4
	MOVEQ	#0,D5
	MOVEQ	#0,D6
	MOVEQ	#0,D7
	BSR	L000D
	BMI	L000C
	BSR.S	L0001
	MOVE.L	#$E0E0707,-$7800.w
	MOVE.L	58(A4),D0
	MOVEM.L	(A7)+,A0-A6/D1-D7
	RTE
L0001	MOVE.W	4(A4),D0
	MOVE.W	#-1,42(A4)
L0002	MOVE.W	D0,4(A4)
	CMP.W	#$FFF,D0
	BEQ.S	L0003
	MOVEA.L	(A4),A6
	BSR.S	L0004
	ADDI.L	#$400,(A4)
	LEA	62(A4),A6
	BSR.S	L0005
	BRA.S	L0002
L0003	RTS
L0004	LSL.W	#1,D0
	ADD.W	6(A4),D0
	SUBQ.W	#4,D0
	BSR	L0033
	LEA	512(A6),A6
	ADDQ.W	#1,D0
	BSR	L0033
	RTS
L0005	LEA	512(A6),A3
	MOVE.W	4(A4),D0
	MOVE.W	42(A4),D1
	BSR.S	L000B
	MOVE.W	D0,D3
	CMP.W	D0,D1
	BEQ.S	L0006
	BSR	L0033
L0006	BSR.S	L000A
	BNE.S	L0008
	MOVE.B	(A5)+,D0
	CMPA.L	A3,A5
	BNE.S	L0007
	ADDQ.W	#1,D3
	MOVE.W	D0,-(A7)
	MOVE.W	D3,D0
	BSR	L0033
	MOVE.W	(A7)+,D0
	MOVEA.L	A6,A5
L0007	MOVE.B	(A5),D1
	ANDI.W	#$FF,D0
	ANDI.W	#$F,D1
	LSL.W	#8,D1
	ADD.W	D1,D0
	RTS
L0008	MOVE.B	(A5)+,D0
	CMPA.L	A3,A5
	BNE.S	L0009
	ADDQ.W	#1,D3
	MOVE.W	D0,-(A7)
	MOVE.W	D3,D0
	BSR	L0033
	MOVE.W	(A7)+,D0
	MOVEA.L	A6,A5
L0009	MOVE.B	(A5),D1
	ROL.B	#4,D0
	ANDI.W	#$F,D0
	ANDI.W	#$FF,D1
	LSL.W	#4,D1
	ADD.W	D1,D0
	RTS
L000A	CLR.W	D0
	LEA	62(A4),A5
	SWAP	D0
	ADDA.W	D0,A5
	MOVE.W	4(A4),D0
	DIVU	#2,D0
	SWAP	D0
	TST.W	D0
	RTS
L000B	MOVEM.W	D1-D2,-(A7)
	MOVE.W	D0,D2
	LSR.W	#1,D0
	LSL.W	#1,D0
	SUB.W	D0,D2
	LSR.W	#1,D0
	EXT.L	D0
	MULU	#3,D0
	ADDI.W	#$200,D0
	ADD.W	D2,D0
	DIVU	#$200,D0
	MOVE.W	D0,42(A4)
	MOVEM.W	(A7)+,D1-D2
	RTS
L000C	MOVE.L	#$E0E0707,-$7800.w
	MOVEQ	#-$21,D0
	MOVEM.L	(A7)+,A0-A6/D1-D7
	RTE
L000D	MOVEA.L	26(A4),A0
	MOVE.B	(A0)+,D0
	MOVE.B	(A0)+,D1
	ORI.B	#$20,D0
	LSL.W	#8,D0
	ADD.W	D0,D1
	PEA	L000E(PC)
	CMP.W	#$613A,D1
	BEQ	L0027
	CMP.W	#$623A,D1
	BEQ	L0029
	BRA	L0028
L000E	LEA	62(A4),A6
	MOVEQ	#1,D0
	MOVEQ	#0,D1
	MOVE.L	D4,-(A7)
	BSR	L0034
	MOVE.L	(A7)+,D4
	MOVE.B	17(A6),D4
	MOVE.B	22(A6),D0
	MOVE.B	24(A6),D1
	MOVE.B	26(A6),D2
	MOVE.W	D0,D3
	LSL.W	#1,D3
	ADDQ.W	#1,D3
	LSR.W	#4,D4
	MOVE.W	D3,10(A4)
	MOVE.W	D4,8(A4)
	LEA	6(A4),A5
	CLR.W	(A5)
	ADD.W	D3,(A5)
	ADD.W	D4,(A5)
	MOVE.W	D0,24(A4)
	MOVE.W	D1,20(A4)
	MOVE.W	D2,22(A4)
	BSR	L002A
	BNE.S	L0012
	MOVE.W	10(A4),38(A4)
	MOVE.W	40(A4),D7
	BEQ.S	L000F
	SUBQ.W	#1,D7
	BSR.S	L0015
	BMI.S	L0012
L000F	MOVE.W	38(A4),D0
	MOVE.W	D0,D3
	BSR	L0033
	CLR.W	56(A4)
	MOVEA.L	34(A4),A0
	BSR	L0022
	MOVEA.L	A6,A5
	MOVE.W	8(A4),D7
L0010	MOVEQ	#$F,D6
L0011	BSR	L001C
	BEQ.S	L0013
	BMI.S	L0012
	LEA	32(A5),A5
	DBF	D6,L0011
	ADDQ.W	#1,D3
	MOVE.W	D3,D0
	BSR	L0033
	MOVEA.L	A6,A5
	DBF	D7,L0010
L0012	MOVEQ	#-1,D0
	RTS
L0013	MOVE.B	27(A5),D1
	MOVE.B	26(A5),D0
	LSL.W	#8,D1
	ADD.W	D1,D0
	MOVEQ	#0,D1
	LEA	32(A5),A5
	MOVEQ	#3,D2
L0014	LSL.L	#8,D1
	MOVE.B	-(A5),D1
	DBF	D2,L0014
	MOVE.W	D0,4(A4)
	MOVE.L	D1,58(A4)
	MOVEQ	#0,D0
	RTS
L0015	MOVE.W	#$1000,56(A4)
	LEA	62(A4),A6
	MOVE.W	38(A4),D0
	MOVE.W	D0,D3
	BRA.S	L0017
L0016	MOVE.W	38(A4),D0
L0017	BSR	L0033
	MOVE.W	8(A4),D4
	SUBQ.W	#1,D4
	MOVEA.L	A6,A5
	BSR	L0020
L0018	MOVEQ	#$F,D6
L0019	BSR.S	L001C
	BEQ.S	L001A
	BMI.S	L001B
	LEA	32(A5),A5
	DBF	D6,L0019
	ADDQ.W	#1,D3
	MOVE.W	D3,D0
	BSR	L0033
	MOVEA.L	A6,A5
	DBF	D4,L0018
	BRA.S	L001B
L001A	MOVE.B	27(A5),D1
	MOVE.B	26(A5),D0
	LSL.W	#8,D1
	ADD.W	D1,D0
	LSL.W	#1,D0
	ADD.W	6(A4),D0
	SUBQ.W	#4,D0
	MOVE.W	D0,38(A4)
	DBF	D7,L0016
	RTS
L001B	MOVEQ	#-1,D0
	RTS
L001C	MOVEM.L	A4/D0-D7,-(A7)
	MOVE.L	(A5),D0
	BEQ.S	L001F
	MOVE.L	4(A5),D1
	MOVE.L	8(A5),D2
	MOVE.B	56(A4),D7
	BEQ.S	L001D
	CMP.B	D7,D2
	BNE.S	L001E
L001D	CLR.B	D2
	LEA	44(A4),A4
	MOVE.L	(A4),D3
	MOVE.L	4(A4),D4
	MOVE.L	8(A4),D5
	MOVE.L	#$20202020,D7
	OR.L	D7,D0
	OR.L	D7,D1
	OR.L	D7,D2
	OR.L	D7,D3
	OR.L	D7,D4
	OR.L	D7,D5
	CMP.L	D0,D3
	BNE.S	L001E
	CMP.L	D1,D4
	BNE.S	L001E
	CMP.L	D2,D5
	BNE.S	L001E
	MOVEM.L	(A7)+,A4/D0-D7
	MOVEQ	#0,D0
	RTS
L001E	MOVEM.L	(A7)+,A4/D0-D7
	MOVEQ	#1,D0
	RTS
L001F	MOVEM.L	(A7)+,A4/D0-D7
	MOVEQ	#-1,D0
	RTS
L0020	MOVEA.L	26(A4),A0
L0021	CMPI.B	#$5C,(A0)+
	BNE.S	L0021
	MOVE.L	A0,26(A4)
L0022	LEA	44(A4),A1
	MOVEQ	#$A,D5
L0023	MOVE.B	(A0)+,D0
	BEQ.S	L0024
	CMP.B	#$5C,D0
	BEQ.S	L0024
	CMP.B	#$2E,D0
	BEQ.S	L0025
	MOVE.B	D0,(A1)+
	DBF	D5,L0023
	RTS
L0024	MOVE.B	#$20,(A1)+
	DBF	D5,L0024
	RTS
L0025	SUBQ.W	#3,D5
	BMI.S	L0026
	BSR.S	L0024
L0026	MOVE.B	(A0)+,(A1)+
	MOVE.B	(A0)+,(A1)+
	MOVE.B	(A0)+,(A1)+
	RTS
L0027	MOVE.L	#$E0E0505,12(A4)
	MOVE.L	#$E0E0404,16(A4)
	RTS
L0028	TST.L	12(A4)
	BEQ.S	L0027
	RTS
L0029	MOVE.L	#$E0E0303,12(A4)
	MOVE.L	#$E0E0202,16(A4)
	RTS
L002A	MOVEA.L	26(A4),A0
	LEA	2(A0),A2
	MOVEA.L	30(A4),A1
	TST.B	-(A1)
L002B	CMPA.L	A0,A1
	BEQ.S	L002C
	MOVE.B	-(A1),D0
	MOVE.B	-1(A1),D1
	CMP.B	#$5C,D0
	BNE.S	L002B
	CMP.B	D0,D1
	BEQ.S	L0031
	CMPA.L	A1,A2
	BEQ.S	L002C
	CMPA.L	A0,A1
	BEQ.S	L002C
	ADDQ.W	#1,40(A4)
	BRA.S	L002B
L002C	MOVEA.L	26(A4),A0
	MOVEA.L	30(A4),A1
	TST.W	40(A4)
	BNE.S	L0030
	MOVE.B	(A0),D0
	MOVE.B	1(A0),D1
	MOVE.B	2(A0),D2
	CMP.B	#$5C,D0
	BNE.S	L002D
	ADDQ.W	#1,A0
	MOVE.L	A0,34(A4)
	BRA.S	L0032
L002D	ORI.B	#$20,D0
	LSL.W	#8,D0
	ADD.W	D0,D1
	CMP.W	#$613A,D1
	BEQ.S	L002F
	CMP.W	#$623A,D1
	BEQ.S	L002F
	MOVE.L	A0,34(A4)
	BRA.S	L0032
L002E	ADDQ.W	#2,A0
	MOVE.L	A0,34(A4)
	BRA.S	L0032
L002F	CMP.B	#$5C,D2
	BNE.S	L002E
	ADDQ.W	#3,A0
	MOVE.L	A0,34(A4)
	BRA.S	L0032
L0030	CMPI.B	#$5C,-(A1)
	BNE.S	L0030
	ADDQ.W	#1,A1
	MOVE.L	A1,34(A4)
	BRA.S	L0032
L0031	CMPA.W	#0,A7
	RTS
L0032	MOVE	#4,CCR
	RTS
L0033	MOVEM.L	A0-A6/D0-D7,-(A7)
	MOVE.W	22(A4),D2
	MOVE.W	20(A4),D3
	MOVE.W	D0,D4
	DIVU	D3,D4
	MOVE.W	D4,D5
	DIVU	D2,D5
	SWAP	D4
	ADDQ.W	#1,D4
	MOVE.W	D4,D0
	MOVE.W	D5,D1
	SWAP	D5
	MOVE.W	D5,D2
	BSR.S	L0034
	MOVEM.L	(A7)+,A0-A6/D0-D7
	RTS
L0034	MOVE.L	12(A4),-$7800.w
	TST.W	D2
	BEQ.S	L0035
	MOVE.L	16(A4),-$7800.w
L0035	LEA	-$79FC.w,A0
	BSR.S	L0036
	BSR.S	L003A
	BSR.S	L003B
	RTS
L0036	MOVEQ	#1,D6
	MOVE.W	#$84,2(A0)
	DIVU	D6,D6
	MOVE.W	D0,(A0)
	DIVU	D6,D6
	MOVE.W	#$86,2(A0)
	DIVU	D6,D6
	MOVE.W	D1,(A0)
	DIVU	D6,D6
	MOVE.W	#$80,2(A0)
	DIVU	D6,D6
	MOVE.W	#$13,(A0)
	DIVU	D6,D6
	BSR.S	L0037
	BNE.S	L0036
	RTS
L0037	MOVE.L	#$80000,D4
L0038	SUBQ.L	#1,D4
	BEQ.S	L0039
	BTST	#5,-$5FF.w
	BNE.S	L0038
	MOVE	#4,CCR
	RTS
L0039	CMPA.W	#0,A7
	RTS
L003A	MOVE.W	#$90,2(A0)
	MOVE.W	#$190,2(A0)
	MOVE.W	#$90,2(A0)
	DIVU	D6,D6
	MOVE.W	#1,(A0)
	MOVE.L	A6,D4
	MOVE.B	D4,-$79F3.w
	LSR.L	#8,D4
	MOVE.B	D4,-$79F5.w
	LSR.L	#8,D4
	MOVE.B	D4,-$79F7.w
	RTS
L003B	MOVEQ	#$A,D4
L003C	MOVE.L	D4,-(A7)
	MOVE.W	#$80,2(A0)
	DIVU	D6,D6
	MOVE.W	#$80,(A0)
	DIVU	D6,D6
	BSR.S	L0037
	BEQ.S	L003E
	MOVE.L	(A7)+,D4
	DBF	D4,L003C
L003D	MOVE.W	#$700,-$7DC0.w
	BRA.S	L003D
L003E	MOVE.L	(A7)+,D4
	MOVE.W	#$80,2(A0)
	MOVE.W	(A0),D4
	BTST	#3,D4
	BNE.S	L003C
	RTS

buff