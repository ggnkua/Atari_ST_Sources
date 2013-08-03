;                *****************************************
;                ***        YM-2149 Synthesizer        ***
;                *** Programm von Gunnar / Delta Force ***
;                ***     Version vom Dezember 1991     ***
;                ***  ½ 1992 ICP Verlag / TOS-Magazin  ***
;                *****************************************
;      Code for TurboAss V1.7 from Markus Fritze & S”ren Hellwig
;                    and DevPac V2.23 from HiSoft

	OPT	P+
speed	EQU	5

	>PART
	pea	clr(PC)
	move.w	#9,-(SP)
	trap	#1
	addq.l	#6,SP
	pea	routine(PC)
	move.w	#38,-(SP)
	trap	#14
	addq.l	#6,SP
	clr.w	-(SP)
	trap	#1
clr:	DC.B	27,'E',0
	EVEN
routine:
	move.b	#10,$0484.w
	moveq	#1,D0		; Enable sound
	bsr.s	on_off
	lea	oldvbl(PC),A0
	move.l	$70.w,(A0)
	lea	vbl(PC),A0
	move.l	A0,$70.w
	move.w	#7,-(SP)
	trap	#1
	addq.l	#2,SP
	move.l	oldvbl(PC),$70.w
	moveq	#0,D0		; Disable sound
	jsr	on_off(PC)
	rts
vbl:
	movem.l	D0-A6,-(SP)
	bsr	synthy
	movem.l	(SP)+,D0-A6
	rte
oldvbl:	DC.L 0
	ENDPART
	>PART
on_off:
	tst.w	D0
	bne.s	init
	moveq	#0,D0
	lea	(internal+4)(PC),A0
	move.w	D0,(A0)
	lea	$FFFF8800.w,A0
	move.b	#8,(A0)
	move.b	D0,2(A0)
	move.b	#9,(A0)
	move.b	D0,2(A0)
	move.b	#10,(A0)
	move.b	D0,2(A0)
	rts
init:
	lea	$FFFF8800.w,A0
	move.b	#7,(A0)
	move.b	#$F8,2(A0)
	moveq	#0,D2
	lea	voice1(PC),A0
	moveq	#0,D0
	moveq	#3,D1
	bsr.s	clr_int
	lea	voice2(PC),A0
	moveq	#1,D0
	moveq	#4,D1
	bsr.s	clr_int
	lea	voice3(PC),A0
	moveq	#2,D0
	moveq	#5,D1
	bsr.s	clr_int
	lea	b(PC),A5
	lea	voice1(PC),A0
	lea	track1(PC),A1
	bsr.s	get_seq
	lea	voice2(PC),A0
	lea	track2(PC),A1
	bsr.s	get_seq
	lea	voice3(PC),A0
	lea	track3(PC),A1
	bsr.s	get_seq
	lea	internal+4(PC),A0
	move.w	#1,(A0)
	rts
clr_int:
	movea.l	A0,A1
	moveq	#16,D3
clr_first:
	move.l	D2,(A0)+
	dbra	D3,clr_first
	move.b	D1,$37(A1)
	move.b	D0,$38(A1)
	rts
get_seq:
	moveq	#0,D0
	move.l	A1,4(A0)		;Song Start Write
	move.b	(A1)+,D0
	btst	#7,D0
	beq.s	ino_trans
	btst	#6,D0
	beq.s	ino_volume
	move.b	(A1)+,D1
	eori.b	#$0F,D1
	move.b	D1,$10(A0)		;Write...
ino_volume:
	andi.b	#$1F,D0
	move.b	D0,$11(A0)		;Transpose Write
	move.b	(A1)+,D0
ino_trans:
	move.l	A1,(A0)
	add.w	D0,D0
	lea	seqtab(PC),A3
	move.w	0(A3,D0.w),D0
	lea	0(A5,D0.w),A1
	move.l	A1,8(A0)
	rts
	ENDPART
	>PART
synthy:
	lea	internal(PC),A0
	tst.w	4(A0)
	beq	not_active
	moveq	#0,D0
	lea	b(PC),A5	;Adress of Data
	lea	$FFFF8800.w,A6
	move.b	#7,(A6)
	move.b	(A6),D7		;d7 - mix register
	subq.w	#1,(A0)
	bpl.s	nosynchro
	move.w	2(A0),(A0)
	lea	voice1(PC),A0
	bsr	notework
	lea	voice2(PC),A0
	bsr	notework
	lea	voice3(PC),A0
	bsr.s	notework
nosynchro:
	lea	voice1(PC),A0
	bsr	soundwork
	move.b	#0,(A6)
	move.b	D5,2(A6)
	lsr.w	#8,D5
	move.b	#1,(A6)
	move.b	D5,2(A6)
	move.b	#8,(A6)
	move.b	D6,2(A6)
	lea	voice2(PC),A0
	bsr	soundwork
	move.b	#2,(A6)
	move.b	D5,2(A6)
	lsr.w	#8,D5
	move.b	#3,(A6)
	move.b	D5,2(A6)
	move.b	#9,(A6)
	move.b	D6,2(A6)
	lea	voice3(PC),A0
	bsr	soundwork
	move.b	#4,(A6)
	move.b	D5,2(A6)
	lsr.w	#8,D5
	move.b	#5,(A6)
	move.b	D5,2(A6)
	move.b	#10,(A6)
	move.b	D6,2(A6)
	move.b	#7,(A6)
	move.b	D7,2(A6)
not_active:
	rts
	ENDPART
	>PART
notework:
	subq.b	#1,$12(A0)
	bpl	no
	moveq	#0,D0
	movea.l	8(A0),A1
	move.b	(A1)+,D0
	cmpi.b	#$FF,D0		;End of Sequence?
	bne.s	cont_seq
	movea.l	(A0),A3
	move.b	(A3)+,D0
	cmpi.b	#$FF,D0		;End of Song?
	bne.s	cont_song
	movea.l	4(A0),A3	;Start Song
	move.b	(A3)+,D0
cont_song:
	btst	#7,D0		;Transp..?
	beq.s	no_trans
	btst	#6,D0
	beq.s	no_volume
	move.b	(A3)+,D1
	eori.b	#$0F,D1
	move.b	D1,$10(A0)
no_volume:
	andi.b	#$1F,D0
	move.b	D0,$11(A0)	;Write Transpose
	move.b	(A3)+,D0            ;n„chstes Byte
no_trans:
	move.l	A3,(A0)		;Position of Sequenz (Write)
	andi.w	#$3F,D0		;Max. 64 Sequence
	add.w	D0,D0		;d0 *2 for Offset
	lea	seqtab(PC),A3
	move.w	0(A3,D0.w),D0
	lea	0(A5,D0.w),A1	;a1 - Start of neu Sequence
	move.b	(A1)+,D0
cont_seq:
	move.b	D0,D6
	move.b	D6,$39(A0)	;Write Flags
	andi.w	#$1F,D0
	move.b	D0,$12(A0)
	btst	#6,D6		;Pause?
	bne	return
	btst	#7,D6
	beq.s	no_bend
	move.b	(A1)+,$3A(A0)
	clr.w	$40(A0)		;P.B.-Position deleted
no_bend:
	btst	#5,D6
	bne.s	cont
	clr.b	$42(A0)		;Vibrato Position deleted
cont:
	move.b	(A1)+,D0
	btst	#7,D0
	beq.s	no_change	;None Instrument
	clr.b	$29(A0)		;Loop flags & vib. dir. deleted
	andi.w	#$3F,D0		;d0 - instrument
	lea	instrtab(PC),A2	;New Instr. holen
	add.w	D0,D0
	move.w	0(A2,D0.w),D0	;Offset holen
	lea	0(A5,D0.w),A4	;a4 - Zeiger auf Instr.
	move.b	(A4)+,D0	;Function des Instr. ...
	move.b	D0,$13(A0)	;...sichern
	cmpi.b	#$00,D0		; Normaler Ton?
	bne.s	c_notype0
	bsr	c_normal_tone
	bra.s	c_end_of_diff
c_notype0:
	cmpi.b	#$01,D0		; BASS TYPE 1?
	bne.s	c_notype1
	bsr	c_buzz_tone1
	bra.s	c_end_of_diff
c_notype1:
	cmpi.b	#$02,D0		; BASS TYPE 2?
	bne.s	c_notype2
	bsr	c_buzz_tone2
	bra.s	c_end_of_diff
c_notype2:
	cmpi.b	#$03,D0		; BASS TYPE 3?
	bne.s	c_end_of_diff
	bsr	c_buzz_tone3
c_end_of_diff:
	bra	return
no_change:
	move.b	$13(A0),D1	;D1 - Type of Instruments
	cmpi.b	#$00,D1		;NORMAL Ton?
	beq.s	normal
	cmpi.b	#$01,D1		;BASS TYPE 1?
	beq.s	type1
	cmpi.b	#$02,D1		;BASS TYPE 2?
	beq.s	type2
	bra	type3		;BASS TYPE 3...
	ENDPART
normal:
	>PART			;normal
	btst	#5,D6		;Note halten?
	bne.s	connect_norm
	clr.b	$2A(A0)		;Arpeggioverz”g. init.
	clr.b	$35(A0)		;Wave init
	clr.b	$3B(A0)		;Rauschverz”g. init
	move.l	$18(A0),$14(A0)	;Arpeggio starten
	move.l	$22(A0),$1E(A0)	;Wave starten
	move.l	$30(A0),$2C(A0)	;Rauschen starten
connect_norm:
	move.b	D0,$34(A0)	;Note write
	bra	return
	ENDPART
type1:
	>PART			;BASS TYPE 1
	btst	#5,D6		;Note halten?
	bne.s	connect_type1a
	clr.b	$35(A0)		;Waveverz”gerung
	clr.b	$3B(A0)		;Rauschverz”gerung
	move.l	$30(A0),$2C(A0)	;Rauschen starten
	move.l	$22(A0),$1E(A0)	;Wave starten
connect_type1a:
	cmp.b	$36(A0),D0
	beq.s	connect_type1b
	move.b	D0,$36(A0)
	move.b	#11,(A6)
	move.b	D0,2(A6)	;Bassnote set
	move.b	#12,(A6)
	move.b	#0,2(A6)
connect_type1b:
	move.b	(A1)+,$3C(A0)	;Modulation Highbyte
	move.b	(A1)+,$3D(A0)	;Modulation Lowbyte
	bra	return
	ENDPART
type2:
	>PART			;BASS TYPE 2
	btst	#5,D6		;Note halten?
	bne.s	connect_type2a
	clr.b	$2A(A0)		;Arpeggioverz”grung
	clr.b	$35(A0)		;Waveverz”gerung
	clr.b	$3B(A0)		;Rauschverz”gerung
	move.l	$30(A0),$2C(A0)	;Rauschen start
	move.l	$22(A0),$1E(A0)	;Wave start
	move.l	$18(A0),$14(A0)	;Arpeggio start
connect_type2a:
	add.b	$11(A0),D0	;Bass transponieren
	cmp.b	$36(A0),D0
	beq.s	connect_type2b
	move.b	D0,$36(A0)
	lea	buzzfreqtab(PC),A3
	andi.w	#$3F,D0
	move.b	#11,(A6)
	move.b	(A3,D0.w),2(A6)	;Bassnote setzen
	move.b	#12,(A6)
	move.b	#0,2(A6)
connect_type2b:
	move.b	(A1)+,$34(A0)	;Note write
	bra.s	return
	ENDPART
type3:
	>PART			;BASS TYPE 3
	btst	#5,D6		;Note halten?
	bne.s	connect_type3a
	clr.b	$35(A0)		;Waveverz”gerung
	move.l	$22(A0),$1E(A0)	;Wave start
connect_type3a:
	add.b	$11(A0),D0	;Bass transponieren
	cmp.b	$36(A0),D0
	beq.s	return
	move.b	D0,$36(A0)
	lea	buzzfreqtab(PC),A3
	andi.w	#$3F,D0
	move.b	#11,(A6)
	move.b	(A3,D0.w),2(A6)	;Bassnote write
	move.b	#12,(A6)
	move.b	#0,2(A6)
	ENDPART
return:
	move.l	A1,8(A0)	;Sequenz Position write
no:
	rts
c_normal_tone:
	>PART			;Arpeggios

	move.b	(A4)+,D0	;Arpeggionr. holen
	andi.w	#$1F,D0
	add.w	D0,D0
	lea	arptab(PC),A3
	move.w	(A3,D0.w),D0	;Offset
	lea	(A5,D0.w),A3	;Zeiger produzieren
	move.b	(A3)+,$1C(A0)	;Verz”gerung des Arpeggios
	clr.b	$2A(A0)		;Z„hler auf 0 fr Anfangsbeding.
	move.b	(A3)+,D0	;loopen?
	beq.s	no_arp_loop_norm
	bset	#0,$29(A0)
no_arp_loop_norm:
	move.l	A3,$18(A0)	;Start des Arpeggios
	move.l	A3,$14(A0)	;Position

	ENDPART
	>PART			;Vibrato & Rauschen

	move.b	(A4)+,$26(A0)	;Vibratotyp
	move.b	(A4)+,$27(A0)	;Vibratoweite
	move.b	(A4)+,$28(A0)	;Vibratoschrittweite
	move.b	(A4)+,D0	;Rauschen
	andi.w	#$1F,D0
	add.w	D0,D0
	lea	noisetab(PC),A3	;Rauschen:
	move.w	(A3,D0.w),D0	;Offset
	lea	(A5,D0.w),A3	;Zeiger produzieren
	move.b	(A3)+,$2B(A0)	;Verz”gerung
	clr.b	$3B(A0)		;Z„hler auf 0
	move.b	(A3)+,D0	;loopen?
	beq.s	no_noz_loop_norm
	bset	#1,$29(A0)
no_noz_loop_norm:
	move.l	A3,$30(A0)	;Startposition
	move.l	A3,$2C(A0)	;Position
	ENDPART
	>PART			;Wave
	move.b	(A4)+,$1D(A0)	;Verz”gerung
	clr.b	$35(A0)		;Z„hler auf 0
	move.l	A4,$1E(A0)	;Position
	move.l	A4,$22(A0)	;Startposition
	ENDPART
	move.b	(A1)+,$34(A0)	;Note sichern
	rts
c_buzz_tone1:
	>PART			;Modulohllkurve
	move.b	(A4)+,D0
	move.b	#13,(A6)
	move.b	D0,2(A6)	;Hllkurve auf PSG
	ENDPART
	>PART			;Rauschen
	move.b	(A4)+,D0	;Rauschnr. holen
	andi.w        #$1F,D0
	add.w	D0,D0
	lea	noisetab(PC),A2
	move.w	(A2,D0.w),D0	;Offset
	lea	(A5,D0.w),A2	;Zeiger produzieren
	move.b	(A2)+,$2B(A0)	;Verz”gerung
	clr.b	$3B(A0)		;Z„hler auf 0
	move.b	(A2)+,D0	;loopen?
	beq.s	no_noz_loop_type1
	bset	#1,$29(A0)
no_noz_loop_type1:
	move.l	A2,$2C(A0)	;Position
	move.l	A2,$30(A0)	;Startposition
	ENDPART
	>PART			;Wave
	move.b	(A4)+,$1D(A0)	;Waveverz”gerung
	clr.b	$35(A0)		;Z„hler auf 0
	move.l	A4,$1E(A0)	;Position
	move.l	A4,$22(A0)	;Startposition
	ENDPART
	>PART			;Bassnote
	move.b	(A1)+,D0	;Bassnote sichern
	move.b	D0,$36(A0)
	move.b	#11,(A6)
	move.b	D0,2(A6)
	move.b	#12,(A6)
	move.b	#0,2(A6)
	ENDPART
	move.b	(A1)+,$3C(A0)	;Modulation High Byte
	move.b	(A1)+,$3D(A0)	;Modulation Low Byte
	rts
c_buzz_tone2:
	>PART			;Modulohllkurve
	move.b	(A4)+,D0
	move.b	#13,(A6)
	move.b	D0,2(A6)	;Hllkurve auf PSG
	ENDPART
	>PART			;Arpeggios
	move.b	(A4)+,D0	;Arpeggionr. holen
	andi.w	#$1F,D0
	add.w	D0,D0
	lea	arptab(PC),A2
	move.w	(A2,D0.w),D0	;Offset
	lea	(A5,D0.w),A2	;Zeiger produzieren
	move.b	(A2)+,$1C(A0)	;Verz”gerung
	clr.b	$2A(A0)		;Z„hler auf 0
	move.b	(A2)+,D0	;loopen?
	beq.s	no_arp_loop_type2
	bset	#0,$29(A0)
no_arp_loop_type2:
	move.l	A2,$14(A0)	;Position
	move.l	A2,$18(A0)	;Startposition
	ENDPART
	>PART			;Vibrato & Rauschen
	move.b	(A4)+,$26(A0)	;Vibratotyp,
	move.b	(A4)+,$27(A0)	;Vibratoweite &
	move.b	(A4)+,$28(A0)	;Vibratoschrittweite holen
	move.b	(A4)+,D0	;Rauschnr. holen
	andi.w	#$1F,D0
	add.w	D0,D0
	lea	noisetab(PC),A2
	move.w	(A2,D0.w),D0	;Offset
	lea	(A5,D0.w),A2	;Zeiger produzieren
	move.b	(A2)+,$2B(A0)	;Verz”gerung
	clr.b	$3B(A0)		;Z„hler auf 0
	move.b	(A2)+,D0	;loopen?
	beq.s	no_noz_loop_type2
	bset	#1,$29(A0)
no_noz_loop_type2:
              move.l        A2,$2C(A0)          ;Position
              move.l        A2,$30(A0)          ;Startposition

              ENDPART

              >PART                             ;Wave

              move.b        (A4)+,$1D(A0)       ;Verz”gerung
              clr.b         $35(A0)             ;Z„hler auf 0
              move.l        A4,$1E(A0)          ;Position
              move.l        A4,$22(A0)          ;Startposition

              ENDPART

              >PART                             ;Bassnote

              move.b        (A1)+,D0            ;Bassnote holen
              add.b         $11(A0),D0          ;transponieren
              move.b        D0,$36(A0)
              lea           buzzfreqtab(PC),A2
              andi.w        #$3F,D0
              move.b        #11,(A6)
              move.b        0(A2,D0.w),2(A6)
              move.b        #12,(A6)
              move.b        #0,2(A6)

              ENDPART

              move.b        (A1)+,$34(A0)       ;Note sichern
              rts

c_buzz_tone3:

              >PART                             ;Modulohllkurve

              move.b        (A4)+,D0
              move.b        #13,(A6)
              move.b        D0,2(A6)            ;Hllkurve auf PSG

              ENDPART

              >PART                             ;Wave

              move.b        (A4)+,$1D(A0)       ;Verz”gerung
              clr.b         $35(A0)             ;Z„hler auf 0
              move.l        A4,$1E(A0)          ;Position
              move.l        A4,$22(A0)          ;Startposition

              ENDPART

              >PART                             ;Bassnote

              move.b        (A1)+,D0            ;Bassnote holen
              add.b         $11(A0),D0          ;transponieren
              move.b        D0,$36(A0)
              lea           buzzfreqtab(PC),A2
              andi.w        #$3F,D0
              move.b        #11,(A6)
              move.b        0(A2,D0.w),2(A6)
              move.b        #12,(A6)
              move.b        #0,2(A6)

              ENDPART

              move.w        #0,$3C(A0)          ;Modulation high & low Byte
              rts

;=========================================================================
;=========================================================================


              >PART                             ; Sound bearbeiten
soundwork:

              btst          #6,$39(A0)          ;Test auf Pause
              beq.s         no_pause
              moveq         #0,D5
              moveq         #0,D6
              bra           fin                 ;Ciao...
no_pause:
              cmpi.b        #$03,$13(A0)
              beq.s         no_noz

              subq.b        #1,$3B(A0)
              bpl.s         no_noz
              move.b        $37(A0),D1          ;Rauschbit
              move.b        $2B(A0),$3B(A0)
              movea.l       $2C(A0),A1          ;Position
              move.b        (A1)+,D0            ;Fertig?
              bpl.s         noendnoise
              btst          #1,$29(A0)
              beq.s         no_noz
              movea.l       $30(A0),A1          ;Rauschen neu starten
              move.b        (A1)+,D0
noendnoise:
              move.l        A1,$2C(A0)          ;Position sichern
              btst          #5,D0               ;Kein Rauschen?
              beq.s         noise_on            ;n”...
              bset          D1,D7               ;Rauschen maskieren
              bra.s         no_noz
noise_on:
              bclr          D1,D7               ;Rauschen an
              move.b        #6,(A6)             ;Rauschfrequenz auf
              move.b        D0,2(A6)            ;den PSG schreiben
no_noz:

****** Hllkurven ******

              move.b        $3E(A0),D6
              subq.b        #1,$35(A0)
              bpl.s         no_adsr
              move.b        $1D(A0),$35(A0)     ;Verz”gerung restaurieren
              movea.l       $1E(A0),A1          ;Position ermitteln
              move.b        (A1)+,D0
              bmi.s         no_adsr
              move.l        A1,$1E(A0)          ;Neue Position sichern
              move.b        $10(A0),D1          ;max. Lautst„rke?
              cmp.b         D1,D0               ;geht subtrahieren noch?
              bgt.s         ok_sub
              moveq         #0,D6               ;wenn nicht, dann auf 0 setzen
              move.b        D6,$3E(A0)          ;Lautst„rke sichern
              bra.s         no_adsr
ok_sub:
              move.b        D0,D6
              sub.b         D1,D6               ;subtrahieren
              move.b        D6,$3E(A0)
no_adsr:
;                                               ;d6 - Lautst„rke des Kanals
              move.b        $38(A0),D1          ;Bass-Bit
              btst          #4,D6               ;Hllkurven modus?
              beq.s         silent
              btst          #0,D6               ;laut oder leise?
              bne.s         loud
silent:
              bclr          D1,D7               ;Kanal demaskieren
              bra.s         no_envelope
loud:
              bset          D1,D7               ;Kanal maskieren
no_envelope:


*** Bass Typ 1 ***

              cmpi.b        #$03,$13(A0)
              beq.s         hurz1
              cmpi.b        #$01,$13(A0)        ;Bass 1?
              bne.s         hurz2
hurz1:
              move.w        $3C(A0),D5          ;d5 - Frequenz des Kanals
              bra           fin                 ;Ciao
*****************
hurz2:

****** Arpeggios *****

              moveq         #0,D4
              move.b        $3F(A0),D4
              subq.b        #1,$2A(A0)          ;Verz”gerung fertig?
              bpl.s         no_arp
              move.b        $1C(A0),$2A(A0)
              movea.l       $14(A0),A1          ;Position...
              move.b        (A1)+,D0            ;am Ende?
              bpl.s         noendarp
              btst          #0,$29(A0)          ;wiederholen?
              beq.s         no_arp
              movea.l       $18(A0),A1          ;Neustart
              move.b        (A1)+,D0
noendarp:
              move.b        D0,D4
              move.l        A1,$14(A0)          ;Position sichern
no_arp:
              move.b        D4,$3F(A0)          ;d4 - Arpeggio Schritt
              add.b         $34(A0),D4          ;d4 - Note
              add.b         $11(A0),D4          ;transponieren
              lea           freqtab(PC),A1      ;...
              add.w         D4,D4               ;*2
              move.w        0(A1,D4.w),D5       ;d5 - Frequenz
              move.b        $42(A0),D0          ;d0 - Vibrato Pos.
              move.b        $28(A0),D1          ;d1 - Schrittweite
              move.b        $27(A0),D2          ;d2 - Gesamtweite
              cmpi.b        #1,$26(A0)          ;Vibratotyp feststellen
              beq.s         up_step             ;/|/|/|?

              bgt.s         down_step           ;\|\|\|?

              btst          #3,$29(A0)          ;/\/\! auf oder ab?
              beq.s         up_vib
              add.b         D1,D0               ;Abw„rts: Schritt addieren!
              cmp.b         D0,D2               ;Ende erreicht?
              bcc.s         end_vib             ;n”...
              bchg          #3,$29(A0)          ;joh, Richtungswechsel!
              bra.s         end_vib             ;ciao!
up_vib:
              sub.b         D1,D0               ;Aufw„rts: Schritt subtrahieren!
              bls.s         vib_anew            ;Ende? joh, und andersrum!
              bra.s         end_vib             ;wenn nicht, dann ciao!
vib_anew:
              bchg          #3,$29(A0)          ;Richtungswechsel
              bra.s         end_vib             ;und tschss!
up_step:
              add.b         D1,D0               ;Addieren
              cmp.b         D0,D2               ;Ende?
              bcc.s         end_vib             ;Wenn nicht, dann raus hier!
              moveq         #0,D0               ;Joh, und von vorn
              bra.s         end_vib             ;...ciao!
down_step:
              sub.b         D1,D0               ;Subtrahieren (how low can u go?)
              bls.s         lowest              ;ganz tiiieeef unten?
              bra.s         end_vib             ;wenn nicht, tschss...
lowest:
              move.b        D2,D0               ;Maximum setzen
end_vib:                                        ;d0 - Vibrato Wert
              move.b        D0,$42(A0)          ;sichern
              ext.w         D0                  ;d0 erweitern
              move.w        D0,D1               ;... (no comment!)
              lsr.w         #1,D1               ;durch 2 teilen
              add.w         D1,D5               ;"..."
              sub.w         D0,D5               ;Vibrato auf Frequenz schlagen
************ Pitch Bend ***********
              btst          #7,$39(A0)
              beq.s         fin
              move.b        $3A(A0),D0          ;Pitch Bend Wert
              move.w        $40(A0),D1          ;und Position
              ext.w         D0                  ;"..."
              add.w         D0,D1               ;"bend" den "pitch"
              move.w        D1,$40(A0)          ;Position sichern
              sub.w         D1,D5               ;und mit Frequenz kombinieren
*********** Das war's! ***********
fin:
              rts

              ENDPART

              >PART                             ; Interne Daten

********** 128*2 Bytes Frequenz Tabelle ************
freqtab:
	DC.B	14,235,14,24,13,75,12,140,11,218,11
	DC.B	48,10,145,9,246,9,105,8,225,8
	DC.B	96,7,234,7,120,7,12,6,165,6
	DC.B	72,5,237,5,151,5,71,4,251,4
	DC.B	180,4,112,4,48,3,244,3,187,3
	DC.B	134,3,83,3,35,2,246,2,203,2
	DC.B	163,2,125,2,90,2,56,2,24,1
	DC.B	250,1,221,1,195,1,169,1,145,1
	DC.B	123,1,101,1,81,1,62,1,45,1
	DC.B	28,1,12,0,253,0,238,0,225,0
	DC.B	212,0,200,0,189,0,178,0,168,0
	DC.B	159,0,150,0,142,0,134,0,126,0
	DC.B	119,0,112,0,106,0,100,0,94,0
	DC.B	89,0,84,0,79,0,75,0,71,0
	DC.B	67,0,63,0,59,0,56,0,53,0
	DC.B	50,0,47,0,44,0,42,0,39,0
	DC.B	37,0,35,0,33,0,31,0,29,0
	DC.B	28,0,26,0,25,0,23,0,22,0
	DC.B	21,0,19,0,18,0,17,0,16,0
	DC.B	15,0,0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
buzzfreqtab:
	DC.B	240,226,212,200,190,178,168,158,150,142,134,126
	DC.B	120,113,106,100,95,89,84,79,75,71,67,63
	DC.B	60,56,53,50,47,45,42,40,38,36,34,32
	DC.B	30,28,27,25,24,22,21,20,19,18,17,16
	DC.B	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
internal:
	DC.W	-1	;$00 - speedcounter
	DC.W	speed	;$02 - speedsave
	DC.W	0	;$04 - activeness
voice1:
	DC.L	0	;$00 - position in song
	DC.L	0	;$04 - start of song
	DC.L	0	;$08 - position in sequence
	DC.L	0	;$0C - pointer on wave
	DC.B	0	;$10 - volume
	DC.B	0	;$11 - transpose
	DC.B	0	;$12 - notelength
	DC.B	0	;$13 - instrument
	DC.L	0	;$14 - position in arpeggio
	DC.L	0	;$18 - start of arpeggio
	DC.B	0	;$1C - speed of arpeggio
	DC.B	0	;$1D - speed of wave
	DC.L	0	;$1E - position in wave
	DC.L	0	;$22 - start of wave
	DC.B	0	;$26 - vibratotype
	DC.B	0	;$27 - vibratowidth
	DC.B	0	;$28 - vibratostep
	DC.B	0	;$29 - loop register & vib. inf.
	DC.B	0	;$2A - speed of arp2
	DC.B	0	;$2B - speed of noise
	DC.L	0	;$2C - position of noise
	DC.L	0	;$30 - start of noise
	DC.B	0	;$34 - actual note
	DC.B	0	;$35 - speed of wave2
	DC.B	0	;$36 - actual buzz note
	DC.B	0	;$37 - noisebit
	DC.B	0	;$38 - buzz-bit
	DC.B	0	;$39 - flags 1
	DC.B	0	;$3A - pitchbend
	DC.B	0	;$3B - speed of noise2
	DC.B	0	;$3C - modulation hi
	DC.B	0	;$3D - modulation lo
	DC.B	0	;$3E - actual volume
	DC.B	0	;$3F - actual arpeggio
	DC.W	0	;$40 - pitch bend position
	DC.B	0	;$42 - vibrato position
	EVEN
voice2:
	DC.L	0	;$00 - position in song
	DC.L	0	;$04 - start of song
	DC.L	0	;$08 - position in sequence
	DC.L	0	;$0C - pointer on wave
	DC.B	0	;$10 - volume
	DC.B	0	;$11 - transpose
	DC.B	0	;$12 - notelength
	DC.B	0	;$13 - instrument
	DC.L	0	;$14 - position in arpeggio
	DC.L	0	;$18 - start of arpeggio
	DC.B	0	;$1C - speed of arpeggio
	DC.B	0	;$1D - speed of wave
	DC.L	0	;$1E - position in wave
	DC.L	0	;$22 - start of wave
	DC.B	0	;$26 - vibratotype
	DC.B	0	;$27 - vibratowidth
	DC.B	0	;$28 - vibratostep
	DC.B	0	;$29 - loop register & vib. inf.
	DC.B	0	;$2A - speed of arp2
	DC.B	0	;$2B - speed of noise
	DC.L	0	;$2C - position of noise
	DC.L	0	;$30 - start of noise
	DC.B	0	;$34 - actual note
	DC.B	0	;$35 - speed of wave2
	DC.B	0	;$36 - actual buzz note
	DC.B	0	;$37 - noisebit
	DC.B	0	;$38 - buzz-bit
	DC.B	0	;$39 - flags 1
	DC.B	0	;$3A - pitchbend
	DC.B	0	;$3B - speed of noise2
	DC.B	0	;$3C - modulation hi
	DC.B	0	;$3D - modulation lo
	DC.B	0	;$3E - actual volume
	DC.B	0	;$3F - actual arpeggio
	DC.W	0	;$40 - pitch bend position
	DC.B	0	;$42 - vibrato position
	EVEN
voice3:
	DC.L	0	;$00 - position in song
	DC.L	0	;$04 - start of song
	DC.L	0	;$08 - position in sequence
	DC.L	0	;$0C - pointer on wave
	DC.B	0	;$10 - volume
	DC.B	0	;$11 - transpose
	DC.B	0	;$12 - notelength
	DC.B	0	;$13 - instrument
	DC.L	0	;$14 - position in arpeggio
	DC.L	0	;$18 - start of arpeggio
	DC.B	0	;$1C - speed of arpeggio
	DC.B	0	;$1D - speed of wave
	DC.L	0	;$1E - position in wave
	DC.L	0	;$22 - start of wave
	DC.B	0	;$26 - vibratotype
	DC.B	0	;$27 - vibratowidth
	DC.B	0	;$28 - vibratostep
	DC.B	0	;$29 - loop register & vib. inf.
	DC.B	0	;$2A - speed of arp2
	DC.B	0	;$2B - speed of noise
	DC.L	0	;$2C - position of noise
	DC.L	0	;$30 - start of noise
	DC.B	0	;$34 - actual note
	DC.B	0	;$35 - speed of wave2
	DC.B	0	;$36 - actual buzz note
	DC.B	0	;$37 - noisebit
	DC.B	0	;$38 - buzz-bit
	DC.B	0	;$39 - flags 1
	DC.B	0	;$3A - pitchbend
	DC.B	0	;$3B - speed of noise2
	DC.B	0	;$3C - modulation hi
	DC.B	0	;$3D - modulation lo
	DC.B	0	;$3E - actual volume
	DC.B	0	;$3F - actual arpeggio
	DC.W	0	;$40 - pitch bend position
	DC.B	0	;$42 - vibrato position
	EVEN
	ENDPART
	>PART		;DATA Sound

**********************************
*** System Exclusive Song Data ***
**********************************

b:		; Wichtig!!! Niemals l”schen!!!
arptab:
	DC.W	noarp-b,bdrmarp-b,arp2-b,arp3-b,arp4-b
noarp:	DC.B	6,0,0,0,0,$FF
bdrmarp: DC.B	0,0,25,20,15,10,5,0,$FF
arp2:	DC.B	0,1,0,7,12,$FF
arp3:	DC.B	0,0,24,12,0,$FF
arp4:	DC.B	0,0,0,$FF,$FF
	EVEN
instrtab:
	DC.W	bdrm-b,ins1-b,hihat-b,ins3-b
	DC.W	ins4-b,ins5-b,snare-b
bdrm:	DC.B	$00,1,0,0,0,1,0,14,15,15,14,12,8,0,$FF
ins1:	DC.B	$00,2,2,2,2,3,0,14,13,12,$FF
hihat:	DC.B	$00,0,0,0,0,3,0,14,0,$FF,13,11,9,7,5,3,1,0,$FF
ins3:	DC.B	$02,$0E,0,0,2,2,0,1,16,$FF
ins4:	DC.B	$00,0,0,12,4,0,0,12,13,$FF
ins5:	DC.B	$00,0,2,3,3,0,0,12,13,$FF
snare:	DC.B	$00,1,0,0,0,2,0,15,15,14,13,12,12,0,$FF
	EVEN
noisetab:
	DC.W	nonoise-b,bdrnoz-b,snrnoz-b,hihatnoz-b
nonoise: DC.B	0,0,$20,$20,$FF
bdrnoz:	DC.B	0,0,9,$20,$20,$FF
snrnoz:	DC.B	0,0,$20,9,12,$20,$FF
hihatnoz: DC.B	0,0,0,$20,$FF
	EVEN
track1:	DC.B	$C0,15,2,2,2,2,2,2,4,4,2,2,7,7,2,2,2,2,4,4,2,2,7,7,$FF
track2:	DC.B	$C0,15,11,1,1,3,3,5,5,3,3,10,10,3,3,3,3,5,5,3,3,10,10,$FF
track3:	DC.B	$C0,15,0,0,6,8,6,9,0,6,8,6,9,$FF
	EVEN
seqtab:
	DC.W	pause-b,seq1-b,seq2-b,seq3-b,seq4-b,seq5-b
	DC.W	seq6-b,seq7-b,seq8-b,seq9-b,seq10-b,seq11-b
seq11:
	DC.B	0,$82,$78
	REPT	63
	DC.B	0,$78
	ENDR
	DC.B	$FF
seq6:
	DC.B	5,$84,$32,5,$31,3,$30,$0F,$2B
	DC.B	0,$2B,0,$29,0,$2B,0,$2D,0,$2E,0,$2B,0,$2E,0,$30,0,$32
	DC.B	0,$35,0,$37,0,$35,0,$32,0,$30,0,$2E,0,$30,0,$2E,0,$2B
	DC.B	0,$29,0,$26,0,$24,0,$26,0,$29,0,$2B,0,$2E,0,$30,0,$32
	DC.B	0,$35,0,$37,0,$35,0,$32,0,$30
	DC.B	$FF
seq8:
	DC.B	5,$84,$2E,5,$2B,1,$29,$11,$2B
	DC.B	0,$29,0,$2B,0,$29,0,$2B,0,$29,0,$2B,0,$29,0,$2B
	DC.B	0,$29,0,$2B,0,$29,0,$2B,0,$29,0,$2B,0,$29,0,$2B
	DC.B	0,$2B,0,$29,0,$26,0,$24
	DC.B	0,$2B,0,$29,0,$26,0,$24
	DC.B	0,$2B,0,$29,0,$26,0,$24
	DC.B	0,$2B,0,$29,0,$26,0,$24
	DC.B	$FF
seq9:
	DC.B	5,$84,$2E,5,$2D,3,$29,5,$26,5,$27,3,$26,$1B,$24,3,$22
	DC.B	5,$2E,5,$2D,3,$29,5,$26,5,$27,1,$26,$81,4,$26,$3F,$29
	DC.B	$FF
seq1:
	DC.B	0,$80,5,0,$82,$78,0,$82,$78
	DC.B	0,$80,5,0,$82,$78,0,$82,$78
	DC.B	0,$80,5,0,$82,$78,0,$81,$30-5
	DC.B	0,$80,5,0,$81,$30-5,0,$81,$30-5
	DC.B	0,$80,5,0,$81,$30-5,0,$80,5,0,$81,$30-5
	DC.B	0,$80,5,0,$82,$78,0,$82,$78
	DC.B	0,$80,5,0,$82,$78,0,$82,$78
	DC.B	0,$80,5,0,$82,$78,0,$81,$30-2
	DC.B	0,$80,5,0,$81,$30-2,0,$81,$30-2
	DC.B	0,$80,5,0,$81,$30,0,$80,5,0,$81,$30
	DC.B	$FF
seq3:
	DC.B	0,$80,5,0,$81,$30-5,0,$81,$30-5
	DC.B	0,$80,5,0,$86,7,0,$81,$30-5
	DC.B	0,$80,5,0,$81,$30-5,0,$30-5
	DC.B	0,$80,5,0,$81,$30-5,0,$81,$30-5
	DC.B	0,$86,7,0,$81,$30-5,0,$86,7,0,$81,$30-5
	DC.B	0,$80,5,0,$81,$30-5,0,$81,$30-5
	DC.B	0,$80,5,0,$86,7,0,$81,$30-5
	DC.B	0,$80,5,0,$81,$30-5,0,$30-2
	DC.B	0,$80,5,0,$81,$30-2,0,$81,$30-2
	DC.B	0,$86,7,0,$81,$30,0,$86,7,0,$81,$30
	DC.B	$FF
seq5:
	DC.B	0,$80,5,0,$81,$30,0,$81,$30
	DC.B	0,$80,5,0,$86,7,0,$81,$30
	DC.B	0,$80,5,0,$81,$30,0,$30
	DC.B	0,$80,5,0,$81,$30,0,$81,$30
	DC.B	0,$86,7,0,$81,$30,0,$86,7,0,$81,$30
	DC.B	0,$80,5,0,$81,$30,0,$81,$30
	DC.B	0,$80,5,0,$86,7,0,$81,$30
	DC.B	0,$80,5,0,$81,$30,0,$30-2
	DC.B	0,$80,5,0,$81,$30-2,0,$81,$30-2
	DC.B	0,$86,7,0,$81,$30,0,$86,7,0,$81,$30
	DC.B	$FF
seq10:
	DC.B	0,$80,5,0,$81,$27,0,$81,$27
	DC.B	0,$80,5,0,$86,7,0,$81,$27
	DC.B	0,$80,5,0,$81,$27,0,$27
	DC.B	0,$80,5,0,$81,$27,0,$81,$27
	DC.B	0,$86,7,0,$81,$27,0,$86,7,0,$81,$27
	DC.B	0,$80,5,0,$81,$2E,0,$81,$2E
	DC.B	0,$80,5,0,$86,7,0,$81,$2E
	DC.B	0,$80,5,0,$81,$2E,0,$2E
	DC.B	0,$80,5,0,$81,$2E,0,$81,$2E
	DC.B	0,$86,7,0,$81,$2E,0,$86,7,0,$81,$2E
	DC.B	0,$80,5,0,$81,$29,0,$81,$29
	DC.B	0,$80,5,0,$86,7,0,$81,$29
	DC.B	0,$80,5,0,$81,$29,0,$29
	DC.B	0,$80,5,0,$81,$29,0,$81,$29
	DC.B	0,$86,7,0,$81,$29,0,$86,7,0,$81,$29
	DC.B	0,$80,5,0,$81,$29,0,$81,$29
	DC.B	0,$80,5,0,$86,7,0,$81,$29
	DC.B	0,$80,5,0,$81,$29,0,$29
	DC.B	0,$80,5,0,$81,$29,0,$81,$29
	DC.B	0,$86,7,0,$81,$29,0,$86,7,0,$81,$29
	DC.B	$FF
seq2:
	DC.B	$03,$83,$18-5,$18+7-5,0,$24-5,$24-5+7
	DC.B	1,$18-5,$18-5+7,0,$24-5,$24-5+7
	DC.B	$03,$83,$18-5,$18+7-5,0,$24-5,$24-5+7
	DC.B	1,$18-5,$18-5+7,0,$24-5,$24-5+7
	DC.B	$03,$83,$18-5,$18+7-5,0,$24-5,$24-5+7
	DC.B	1,$18-5,$18-5+7,0,$24-5,$24-5+7
	DC.B	0,$83,$24-2,$24-2+7,1,$18-2,$18-2+7,0,$24-2,$24-2+7
	DC.B	0,$83,$24,$24+7,1,$18,$18+7,0,$24,$24+7
	DC.B	$FF
seq7:
	DC.B	$03,$83,$18-9,$18+7-9,0,$24-9,$24-9+7
	DC.B	1,$18-9,$18-9+7,0,$24-9,$24-9+7
	DC.B	$03,$83,$18-9,$18+7-9,0,$24-9,$24-9+7
	DC.B	1,$18-9,$18-9+7,0,$24-9,$24-9+7
	DC.B	$03,$83,$18-2,$18+7-2,0,$24-2,$24-2+7
	DC.B	1,$18-2,$18-2+7,0,$24-2,$24-2+7
	DC.B	$03,$83,$18-2,$18+7-2,0,$24-2,$24-2+7
	DC.B	1,$18-2,$18-2+7,0,$24-2,$24-2+7
	DC.B	$03,$83,$18-7,$18+7-7,0,$24-7,$24-7+7
	DC.B	1,$18-7,$18-7+7,0,$24-7,$24-7+7
	DC.B	$03,$83,$18-7,$18+7-7,0,$24-7,$24-7+7
	DC.B	1,$18-7,$18-7+7,0,$24-7,$24-7+7
	DC.B	$03,$83,$18-7,$18+7-7,0,$24-7,$24-7+7
	DC.B	1,$18-7,$18-7+7,0,$24-7,$24-7+7
	DC.B	$03,$83,$18-7,$18+7-7,0,$24-7,$24-7+7
	DC.B	1,$18-7,$18-7+7,0,$24-7,$24-7+7
	DC.B	$FF
seq4:
	DC.B	$03,$83,$18,$1F,0,$24,$2B
	DC.B	1,$18,$1F,0,$24,$2B
	DC.B	$03,$83,$18,$1F,0,$24,$2B
	DC.B	1,$18,$1F,0,$24,$2B
	DC.B	$03,$83,$18,$1F,0,$24,$2B
	DC.B	1,$18,$1F,0,$24,$2B
	DC.B	0,$83,$22,$29,1,$16,$1D,0,$22,$29
	DC.B	0,$83,$24,$2B,1,$18,$1F,0,$24,$2B
	DC.B	$FF
pause:
	DC.B	$5F,$5F,$FF
	EVEN
	ENDPART
	END
