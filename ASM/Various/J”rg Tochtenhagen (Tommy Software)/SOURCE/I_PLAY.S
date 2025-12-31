* Interrupt Player
* Initialisierung der Interrupt Routine


new_play	lea	tabelle(pc),a0		; Adresse der Tabelle
	move.l	#$C0,D0			; LÑnge der Tabelle in d0
.loop	move.b	#8,(A0)			; ...
	move.b	#9,4(A0)			; ...
	move.b	#10,8(A0)			; ...
	move.b	3(A0),2(A0)		; ...
	move.b	7(A0),6(A0)		; ...
	move.b	11(A0),10(A0)		; ...
	adda.l	#16,A0			; immer 16 Bytes
	dbf	D0,.loop			; loopen


	lea	play_adr(pc),a0		; Vektoradressen

	lea	play_now(pc),a1		; Player_basis_routine
	move.l	a1,(a0)			; setzen
	lea	play_s(pc),a1		; Play Speaker ONCE
	move.l	a1,20(a0)			; setzen
	lea	play_sh(pc),a1		; Play Speaker HOLD
	move.l	a1,24(a0)			; setzen
	lea	conv_p(pc),a1		; Play Converter ONCE
	move.l	a1,28(a0)			; setzen
	lea	conv_ph(pc),a1		; Play Converter HOLD
	move.l	a1,32(a0)			; setzen

	pea 	play_adr(pc)		; Adresse der Daten
	move.w 	#$19,-(a7)		; In freien Vektor
	move.w 	#5,-(a7)			; schreiben.
	trap 	#13			; Aufruf
	addq.l	#8,a7			; Stack reparieren

	move.w 	#0,-(a7)			; Return Code
	move.l	#$fa0,-(a7)		; 4000 Bytes Reservieren
	move.w 	#$31,-(a7)		; Return + Reserve
	trap 	#1			; Programmende


* Einschalten von Supervisormodus

super	clr.l	-(sp)			; 0.l auf stack
	move.w	#32,-(sp)			; SUPER
	trap	#1			; gemdos
	addq.l	#6,sp			; stack reparieren
	lea	ssp(pc),a0		; Superstack_save
	move.l	d0,(a0)			; retten
	rts				; und ende


* Und wieder zurÅck in den Usermodus

user	move.l	ssp(pc),-(sp)		; alten super_stack
	move.w	#32,-(sp)			; SUPER
	trap	#1			; gemdos
	addq.l	#6,a7			; stack reparieren
	rts				; und ende


* Play Sample / Direkter Einsprung nach Interrupt mit Parametern
* Parameter: Startadresse,LÑnge,Holdstart,HoldlÑnge,Routine Nr,Delay

play_now	bsr	super			; Supervisor on

	clr.b	$fffa19			; Sample aus!
	clr.w	$452			; VBL Stop
	lea 	start_sam(pc),a0		; Basisadresse
	move.l	4(a7),(a0)		; Start_sample
	move.l	8(a7),4(a0)		; LÑnge
	move.l	12(a7),8(a0)		; Hold_start
	move.l	16(a7),12(a0)		; Hold_lÑnge
	move.l	20(a7),d0			; Routine Nr.
	move.l	24(a7),d1			; Delay
	mulu	#4,d0			; Routine * 4

	move.l	16(a0,d0.l),-(a7)		; --> Adresse Routine
	move.w	d1,-(a7)			; --> Delay
	move.w	#0,-(a7)			; --> Control
	move.w	#0,-(a7)			; --> Timer A
	move.w	#$1f,-(a7)		; XBIOS : Xbtimer
	trap	#14			; Aufruf
	adda.l	#12,a7			; Stack reparieren

	lea	$ff8800,a0		; Adresse Soundchip
	cmpi.l	#1,20(a7)			; Routine 0/1 ?
	bgt.s	.rout_2_			; nein,weiter	
	move.l	#$7007f00,(a0)		; Setzen fÅr PLAY-SPEAKER
	bra	.ende			; und ende

.rout_2_	move.l	#$08000000,(a0)		; Shut Up 
	move.l	#$09000000,(a0)		; Signal
	move.l	#$0a000000,(a0)		; an Soundchip
	move.b	#7,(a0)			; Sound Reg.7
	move.b	(a0),d0			; Wert holen
	ori.b	#$80,d0			; Bit 7 setzen
	move.b	d0,2(a0)			; zurÅck schreiben	

.ende	move.b	#1,$fffa19		; und los geht's
	bsr	user			; Supervisor off
	rts				; terminator

* Play Sample --> Speaker ONCE

play_s	movem.l	d0-d2/a0-a1,-(a7)		; Register retten
	lea	start_sam(pc),a1		; Daten fÅr spielen --> a1
	move.l	(a1),A0			; Samplestart in daten
	move.b	(A0)+,D1			; Datenbyte nach d1
	addi.b	#$80,D1			; +128 (0-255)
	move.l	A0,(a1)			; Neue Adresse des Samples
	lea	(400+tabelle)(pc),A0	; Soundbytes
	and.w	#$fe,d1			; d1 --> even
	lsl.w	#3,d1			;    --> d1 * 8
	adda.w	D1,A0			; Aktuelle Daten nach a0
	movem.l	(A0)+,D0-D2		; 12 Bytes Holen
	movem.l	D0-D2,$ff8800		; beep,beep,beep
	subq.l	#1,4(a1)			; ZÑhler minus 1
	beq.s	play_s_1			; Wenn Ende --> STOP
	movem.l	(a7)+,d0-d2/a0-a1		; Register holen
	rte				; Und ZurÅck
play_s_1	move.b	4(a1),$FFFA19		; Timer ausschalten
	move.b	4(a1),$FFFA19		; Timer ausschalten
	move.b	#72,$fffa17
	move.b	#81,$fffa1d
	move.w	#1,$452
	movem.l	(A7)+,d0-d2/a0-a1		; Register holen
	rte				; Und ZurÅck

* Play Sample --> Speaker HOLD

play_sh	movem.l	d0-d2/a0-a1,-(a7)		; Register retten
	lea	start_sam(pc),a1		; Daten fÅr spielen
	move.l	(a1),A0			; Samplestart in daten
	move.b	(A0)+,D1			; Datenbyte nach d1
	addi.b	#$80,D1			; +128 (0-255)
	move.l	A0,(a1)			; Neue Adresse des Samples
	lea	(400+tabelle)(pc),A0	; Soundbytes
	and.w	#$fe,d1			; d1 --> even
	lsl.w	#3,d1			;    --> d1 * 8 --> Offset
	adda.w	D1,A0			; Aktuelle Daten nach a0
	movem.l	(A0)+,D0-D2		; 12 Bytes Holen
	movem.l	D0-D2,$ff8800		; beep,beep,beep
	subq.l	#1,4(a1)			; ZÑhler minus 1
	beq.s	play_sh_1			; Wenn nicht Ende-->weiter
	movem.l	(a7)+,d0-d2/a0-a1		; Register Holen
	rte				; Und ZurÅck
play_sh_1	move.l	8(a1),(a1)		; Neuer Samplestart
	move.l	12(a1),4(a1)		; Neue SamplelÑnge
	movem.l	(A7)+,d0-d2/a0-a1		; Register holen
	rte				; Und ZurÅck


* Play Sample --> Converter ONCE
	
conv_p	movem.l	d0-d2/a0-a1,-(a7)		; Register retten
	lea	start_sam(pc),a1		; Daten fÅr spielen
	move.l	(a1),a0			; Samplestart in daten
	move.b	(A0)+,D1			; Datenbyte nach d1
	addi.b	#$80,D1			; +128 (0-255)
	move.l	A0,(a1)			; Neue Adresse des Samples
	move.b	#$f,$ff8800		; 20
	move.b	d1,$ff8802		; 16
	subq.l	#1,4(a1)			; ZÑhler minus 1
	beq.s	conv_p_1			; Wenn nicht Ende-->weiter
	movem.l	(a7)+,d0-d2/a0-a1		; Register holen
	rte				; Und ZurÅck
conv_p_1	move.b	4(a1),$FFFA19		; Timer ausschalten
	move.b	4(a1),$FFFA19		; Timer ausschalten
	move.b	#72,$fffa17
	move.b	#81,$fffa1d
	move.w	#1,$452
	movem.l	(A7)+,d0-d2/a0-a1		; Register holen
	rte				; Und ZurÅck

* Play Sample --> Converter HOLD
	
conv_ph	movem.l	d0-d2/a0-a1,-(a7)		; Register retten
	lea	start_sam(pc),a1		; Daten fÅr spielen
	move.l	(a1),a0			; Samplestart in daten
	clr.w	d1			; d1 auf word lîschen
	move.b	(A0)+,D1			; Datenbyte nach d1
	addi.b	#$80,D1			; +128 (0-255)
	move.l	A0,(a1)			; Neue Adresse des Samples
	move.b	#$f,$ff8800		; Soundregister
	move.b	d1,$ff8802		; Byte schreiben
	subq.l	#1,4(a1)			; ZÑhler minus 1
	beq.s	conv_ph_1			; Wenn nicht Ende-->weiter
	movem.l	(a7)+,d0-d2/a0-a1		; Register holen
	rte				; Und ZurÅck
conv_ph_1	move.l	8(a1),(a1)		; Datenadresse Hold
	move.l	12(a1),4(a1)		; Hold LÑnge
	movem.l	(A7)+,d0-d2/a0-a1		; Register holen
	rte				; Und ZurÅck


play_adr	dc.l	0	; +  0

start_sam	dc.l 	0	; +  4
len_sam	dc.l	0	; +  8
start_new	dc.l 	0	; + 12
len_new	dc.l 	0	; + 16
	
p_speak	dc.l 	0	; + 20
p_speak_h dc.l 	0	; + 24
p_conv	dc.l 	0	; + 28
p_conv_h	dc.l 	0	; + 32

dummy	dc.l	0	; + 36
ssp	dc.l	0
	
* Tabelle ist (start_sam + 44)

tabelle	dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l 0,0,0,0,0,0,0,0,1,0,0,0,2,0,0,0,3,0,0,0
	dc.l 3,1,0,0,4,0,0,0,4,1,0,0,5,0,0,0,5,1,0,0
	dc.l 5,2,0,0,6,0,0,0,6,1,0,0,6,2,0,0,6,3,0,0
	dc.l 7,0,0,0,7,1,0,0,7,2,0,0,7,3,0,0,7,3,1,0
	dc.l 7,4,0,0,7,4,1,0,8,0,0,0,8,1,0,0,8,2,0,0
	dc.l 8,3,0,0,8,3,1,0,8,4,0,0,8,4,1,0,8,5,0,0
	dc.l 9,0,0,0,9,1,0,0,9,2,0,0,9,3,0,0,9,3,1,0
	dc.l 9,4,0,0,9,4,1,0,9,5,0,0,9,5,1,0,9,5,2,0
	dc.l 9,6,0,0,9,6,1,0,9,6,2,0,9,6,3,0,9,7,0,0
	dc.l 10,0,0,0,10,1,0,0,10,2,0,0,10,3,0,0,10,3,1,0
	dc.l 10,4,0,0,10,4,1,0,10,5,0,0,10,5,1,0,10,5,2,0
	dc.l 10,6,0,0,10,6,1,0,10,6,2,0,10,6,3,0,10,7,0,0
	dc.l 10,7,1,0,10,7,2,0,10,7,3,0,11,0,0,0,11,1,0,0
	dc.l 11,2,0,0,11,3,0,0,11,3,1,0,11,4,0,0,11,4,1,0
	dc.l 11,5,0,0,11,5,1,0,11,5,2,0,11,6,0,0,11,6,1,0
	dc.l 11,6,2,0,11,6,3,0,11,7,0,0,11,7,1,0,11,7,2,0
	dc.l 11,7,3,0,11,7,4,0,11,8,0,0,11,8,1,0,11,8,2,0
	dc.l 11,8,3,0,11,8,4,0,11,8,5,0,11,8,6,0,12,0,0,0
	dc.l 12,1,0,0,12,2,0,0,12,3,0,0,12,3,1,0,12,4,0,0
	dc.l 12,4,1,0,12,5,0,0,12,5,1,0,12,5,2,0,12,6,0,0
	dc.l 12,6,1,0,12,6,2,0,12,6,3,0,12,7,0,0,12,7,1,0
	dc.l 12,7,2,0,12,7,3,0,12,7,4,0,12,8,0,0,12,8,1,0
	dc.l 12,8,2,0,12,8,3,0,12,8,4,0,12,8,5,0,12,9,0,0
	dc.l 12,9,1,0,12,9,2,0,12,9,3,0,12,9,4,0,12,9,5,0
	dc.l 12,9,6,0,12,10,0,0,12,10,1,0,12,10,2,0,13,0,0,0
	dc.l 13,1,0,0,13,2,0,0,13,3,0,0,13,3,1,0,13,4,0,0
	dc.l 13,4,1,0,13,5,0,0,13,5,1,0,13,5,2,0,13,6,0,0
	dc.l 13,6,1,0,13,6,2,0,13,6,3,0,13,7,0,0,13,7,1,0
	dc.l 13,7,2,0,13,7,3,0,13,7,4,0,13,8,0,0,13,8,1,0
	dc.l 13,8,2,0,13,8,3,0,13,8,4,0,13,8,5,0,13,9,0,0
	dc.l 13,9,1,0,13,9,2,0,13,9,3,0,13,9,4,0,13,9,5,0
	dc.l 13,9,6,0,13,10,0,0,13,10,1,0,13,10,2,0,13,10,3,0
	dc.l 13,10,4,0,13,10,5,0,13,10,6,0,13,10,7,0,13,10,8,0
	dc.l 13,10,8,0,13,10,8,0,13,10,8,0,13,10,8,0,13,10,8,0
	dc.l 13,10,8,0,13,10,8,0,13,10,8,0,13,10,8,0,13,10,8,0
	dc.l 13,10,8,0,13,10,8,0,13,10,8,0,13,10,8,0,13,10,8,0
	dc.l 13,10,8,0,13,10,8,0,13,10,8,0,13,10,8,0,13,10,8,0
	dc.l 13,10,8,0,13,10,8,0,13,10,8,0,0,0,0,0,0,0,0,0
