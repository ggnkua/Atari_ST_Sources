
xbios	equ	14
kbdvbase	equ	34
key_vec	equ	$118
vblsem	equ	$452
hbl_hand	equ	$068
vbl_hand	equ	$070


execute	lea	tabelle(pc),a0		; Start der Sound_tabelle
	move.l	#$192,d0			; LÑnge der Tabelle in d0
.loop1	move.b	#8,(a0)			; Umwandeln
	move.b	#9,4(a0)			; der Pegelwerte
	move.b	#10,8(a0)			; in auszugebende
	move.b	3(a0),2(a0)		; LautstÑrken
	move.b	7(a0),6(a0)		; fÅr den Soundchip
	move.b	11(a0),10(a0)		; $ff8800,ff8802
	adda.l	#16,a0			; immer 16 Bytes
	dbf	d0,.loop1			; Und immer loopen

	pea 	chip(pc)			; Adresse der Routine
	move.w 	#$19,-(a7)		; In freien Vektor
	move.w 	#5,-(a7)			; schreiben.
	trap 	#13			; Aufruf
	addq.l	#8,a7			; Stack reparieren

	lea	pause(pc),a0		; pausen adresse
	move.l	#639,d0			; 640 nops
.loop	move.w	#$4e71,(a0)+		; setze 'nop'
	dbra	d0,.loop			; count down

	move.w 	#0,-(a7)			; Code ?
	move.l	#$1900,-(a7)		; 6400 Bytes Reservieren
	move.w 	#$31,-(a7)		; Return + Reserve
	trap 	#1			; Programmende


* Umschalten in den Supervisormodus

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


* Schalte alle Interrupts aus und setze neue Tastaturroutine

chip_off	movem.l	d0-d7/a0-a1,-(sp)		; Register retten

	lea	save_sr(pc),a0		; a0 --> save_status
	move.w	sr,(a0)			; status_reg sichern
	ori.w	#$700,sr			; Interrupts aus

	clr.b	$fffa1d			; Systemtimer aus!
	lea	save_vbl(pc),a0		; a0 --> save_vbl
	move.w	vblsem,(a0)		; flag fÅr vbl retten
	clr.w	vblsem			; lîschen
	lea	save_i07(pc),a0		; interrupt register
	move.b	$fffa07,(a0)		; retten
	clr.b	$fffa07			; neu setzen
	lea	save_i09(pc),a0		; interrupt register 
	move.b	$fffa09,(a0)		; retten
	move.b	#64,$fffa09		; neu setzen
	lea	save_vec(pc),a0		; a0 --> save_key_vector
	move.l	key_vec,(a0)		; key_vektor sichern
	lea	new_key(pc),a0		; neue keyboard routine
	move.l	a0,key_vec		; setzen
	lea	int_dummy(pc),a1		; a1 --> adr neu_vbl
	lea	save_vb2(pc),a0		; a0 --> save_vbl_vec
	move.l	vbl_hand,(a0)		; retten
	move.l	a1,vbl_hand		; neu setzen

	andi.w	#$f8ff,sr			; interrupt maskieren
	ori.w	#$300,sr			; prioritÑt 3

	movem.l	(sp)+,d0-d7/a0-a1		; Register zurÅck
	rts				; und ende
	

* All den MÅll wieder ein und zurÅck zum Aufrufprogramm

chip_on	ori.w	#$700,sr			; interrupts aus!
	move.l	save_vec(pc),key_vec	; alten key_vec setzen
	move.w	save_vbl(pc),vblsem		; vbl flag setzen
	move.l	save_vb2(pc),vbl_hand	; handler
	move.b	save_i07(pc),$fffa07	; interrupt reg 07
	move.b	save_i09(pc),$fffa09	; interrupt reg 09
	move.w	save_sr(pc),sr		; alten sr setzen
	move.b	#81,$fffa1d		; Systemtimer an!
	clr.l	d0			; d0 lîschen
	move.b	tas_key(pc),d0		; RÅckgabe der Taste
	rts				; ciao, baby


* Routinen Aufruf mit abschalten aller Interrupts und Timer
* Parameter: x1,x2,x3,x4,x5,x6... longs

adresse	dc.l	0

chip	bsr	super			; Supervisormodus ein
	bsr	chip_off			; allerlei humble

	move.l	4(a7),a0			; start adresse
	move.l	8(a7),d6			; LÑnge
	move.l	12(a7),a1			; hold adresse
	move.l	16(a7),d5			; hold LÑnge
	move.l	20(a7),d7			; Pausenwert
	lea	out(pc),a2		; centronics/rom port
	move.l	24(a7),(a2)		; ausgabe setzen

	lea	play_chip(pc),a4		; Speaker setzen
	tst.l	24(a7)			; auch wirklick
	beq.s	.ll			; aber ja doch
	lea	conv_chip(pc),a4		; nein, hardware
.ll	jsr	(a4)			; ab damit

	bsr	chip_on			; chip_ein und ende
	bsr	user			; Normalzustand
	rts				; bye, bye


* Spiele Sample Åber speaker ab adr a0,len d6,pause d7 bis key_press
* zusÑtzlich noch hold_start a1,hold_len d5
* Parameter: a0,d6 / a1,d5 / d7 (siehe oben)
* Taktzyklen: 160

play_chip	movem.l	d0-d7/a0-a6,-(sp)		; alle Register retten
	lea	(400+tabelle)(pc),a2	; a2 --> sound tabelle
	bsr	clr_key			; Tastenflag lîschen
	lea	tas_flag(pc),a4		; a4 --> taste_flag 
	lea	$ff8800,a3		; a3 --> soundchip
	move.l	#$7007f00,(a3)		; setze speaker
	move.l	#$80,d3			; fÅr add 128
	move.l	#$fe,d4			; fÅr and $fe
	lea	paus_zero(pc),a5		; ende von pausen
	btst.l	#14,d7			; bit 14 gesetzt ?
	bne.s	play_over			; ja, dann oversampling
	add.l	d7,d7			; nop = 2 byte lang
	sub.l	d7,a5			; minus ende
	lea	play_c_1(pc),a6		; Return fÅr Pause

play_c_1	move.b	(a0)+,d1		;  8	; d1 --> peek
	add.b	d3,d1		;  4	;    --> + 128 (0-255)
	and.w	d4,d1		;  4	;    --> even
	lsl.w	#3,d1		; 12	;    --> mul 8
	lsl.w	#2,d0		; 10	; dummy 10 Zyklen
	movem.l	(a2,d1.w),d0-d2	; 42	; d0-d2 --> sounds
	movem.l	d0-d2,(a3)	; 32	; chip --> d0-d2
	tst.b	(a4)		;  8	; taste gedrÅckt ?
	bne.s	play_c_3		;  8	; ja, dann ende
	subq.l	#1,d6		;  8	; count - 1
	beq.s	play_c_2		;  8	; counter = zero,stop
	jmp	(a5)		; 16+p*4	; Zyklen pause
play_c_2	tst.l	d5			; hold len vorhanden
	beq.s	play_c_3			; nein, dann ende
	move.l	a1,a0			; neuer Datenstart
	move.l	d5,d6			; neue LÑnge
	bra	play_c_1			; und weiter

play_c_3	movem.l	(sp)+,d0-d7/a0-a6		; alle Register zurÅck
	rts				; ende


* Spiel Åber speaker mit 2 fach oversampling
* Taktzyklen: 172

play_over	bclr.l	#14,d7			; oversamp_bit lîschen
	add.l	d7,d7			; wegen nop = 2 byte
	sub.l	d7,a5			; minus ende
	clr.l	d7			; flag lîschen
	lea	play_o_1(pc),a6		; Return fÅr Pause

play_o_1	move.b	(a0),d1		;  8	; d1 --> peek
	not.b	d7		;  4	; flag switchen
	bmi.s	play_o_2		; -/-	; abfrage

	move.b	-1(a0),d0		; 12+8	; alten wert holen
	sub.b	d1,d0		;  4	; d0 --> Differenz
	sub.b	d1,d2		;  4   	; 4 Zyklen Ferien
	asr.b	d0		;  8	; div 2
	sub.b	d0,d1		;  4	; Mittelwert
	bvc.s	play_o_3		; 10	; overflow ?
	add.b	d0,d1			; falls overflow
	bra	play_o_3			; und weiter

play_o_2	addq.l	#1,a0		;  8+10	; inc adresse
	subq.l	#1,d6		;  8	; counter sub 1
	beq.s	play_o_4		;  8	; zero count, ende
	tst.b	(a4)		;  8	; Taste ?
	bne.s	play_c_3		;  8	; ja, dann ende

play_o_3	add.b	d3,d1		;  4	;    --> + 128 (0-255)
	and.w	d4,d1		;  4	;    --> even
	lsl.w	#3,d1		; 12	;    --> mul 8
	movem.l	(a2,d1.w),d0-d2	; 42	; d0-d2 --> sounds
	movem.l	d0-d2,(a3)	; 32	; chip --> d0-d2
	jmp	(a5)		; 16+p*4  ; Zyklen pause

play_o_4	tst.l	d5			; hold len vorhanden
	beq.s	play_c_3			; nein, dann ende
	move.l	a1,a0			; neuer Datenstart
	move.l	d5,d6			; neue LÑnge
	bra	play_o_1			; und weiter


* Spiele Sample Åber Converter ab adr a0,len d6,pause d7 bis key_press
* zusÑtzlich noch hold_start a1,hold_len d5
* Parameter: a0,d6 / a1,d5 / d7 (siehe oben)
* Taktzyklen: 98

conv_chip	movem.l	d0-d7/a0-a6,-(sp)		; Register retten

	move.l	out(pc),d0		; Ausgabe Åber ?
	tst.l	d0			; 0 = Centronics
	beq.s	conv_0			; verzweigen

	lea	$fa0000,a3		; Rom Port Adresse
	lea	out_rom(pc),a2		; Ausgabe Routine setzen
	bra	conv_1			; next routine overjump 

conv_0	lea	$ff8800,a3		; a3 --> soundchip
	move.b	#7,(a3)			; Sound Reg.7
	move.b	(a3),d0			; Wert holen
	ori.b	#$80,d0			; Bit 7 setzen
	move.b	d0,2(a3)			; zurÅck schreiben
	lea	out_cen(pc),a2		; Ausgabe Routine setzen

conv_1	bsr	clr_key			; tasten lîschen
	lea	tas_flag(pc),a4		; a4 --> tasten flag
	lea	paus_zero(pc),a5		; ende von pausen
	btst.l	#14,d7			; oversampling ?
	bne.s	conv_over			; ja, dann los

	add.l	d7,d7			; nop = 2 byte lang
	sub.l	d7,a5			; minus ende
	lea	conv_2(pc),a6		; Return fÅr pause

conv_2	tst.b	(a4)		;  8	; taste gedrÅckt ?
	bne.s	conv_ende		;  8	; ja, dann ende
	subq.l	#1,d6		;  8	; adressen counter
	bmi.s	conv_3		;  8 	; zÑhle bis -1
	move.b	(a0)+,d0		;  8	; peek holen
	addi.b	#128,d0		;  8	; plus 128
	jmp	(a2)		;  8+42	; Ausgabe & Pause

conv_3	tst.l	d5			; hold len vorhanden
	beq.s	conv_ende			; nein, dann ende
	move.l	a1,a0			; neuer Datenstart
	move.l	d5,d6			; neue LÑnge
	bra	conv_2			; und weiter

conv_ende	movem.l	(sp)+,d0-d7/a0-a6		; Register zurÅck
	rts				; ende


; Ausgabe Åber Centronics Port d0 mit a3,a5
; 42 Taktzyklen

out_cen	move.b	#15,(a3)		; 12	; Leitung 15
	move.b	d0,2(a3)		;  8	; Ausgabe Centronics
	exg	d0,d0		;  6
	jmp	(a5)		; 16+p*4	; zur Pause

; Ausgabe Åber ROM Port d0 mit a3,a5
; 42 Taktzyklen

out_rom  	andi.w	#$ff,d0		;  8 	; Nur gerade Adresse
	add.w	d0,d0		;  4	; mul 2
	move.b	0(a3,d0),d0	; 14	; Ausgabe ROM Port
	jmp	(a5)		; 16+p*4	; zur Pause
	

* Abspielen Åber Converter mit 2 fach Oversampling
* Taktzyklen: 116

conv_over	bclr.l	#14,d7			; oversamp bit lîschen
	add.l	d7,d7			; nop = 2 byte
	sub.l	d7,a5			; Einsprung adresse
	clr.l	d7			; flag lîschen
	move.b	#128,d2			; d2 = sub 128
	lea	conv_o_1(pc),a6		; Return fÅr pause

conv_o_1	move.b	(a0),d0		;  8	; peek holen
	not.b	d7		;  4	; flag switchen
	bmi.s	conv_o_2		; -/-	; 

	move.b	-1(a0),d1		; 12+8	; alten wert holen
	sub.b	d0,d4		;  4	; 4 Zyklen
	sub.b	d0,d1		;  4	; Differenz
	asr.b	d1		;  8	; div 2
	sub.b	d1,d0		;  4	; Mittelwert
	bvc.s	conv_o_3		; 10	; overflow ?
	add.b	d1,d0			; ja, dann korrekt
	bra	conv_o_3

conv_o_2	addq.l	#1,a0		;  8+10	; Adresse erhîhen
	subq.l	#1,d6		;  8	; counter sub 1
	bmi.s	conv_o_4		;  8	; zero
	tst.b	(a4)		;  8	; Taste gedrÅckt
	bne.s	conv_ende		;  8	; ja, dann ende

conv_o_3	add.b	d2,d0		;  4	; plus 128
	jmp	(a2)		;  8+42	; Ausgabe von d0...

conv_o_4	tst.l	d5			; hold len vorhanden
	beq.s	conv_ende			; nein, dann ende
	move.l	a1,a0			; neuer Datenstart
	move.l	d5,d6			; neue LÑnge
	bra	conv_o_1			; und weiter


* Neue Keyboard Routine

new_key	movem.l	d0/a0,-(sp)		; Register retten

	lea	tas_key(pc),a0		; a0 --> adr_taste
	move.b	#0,1(a0)			; flag reset
	move.b	$fffc02,d0		; taste setzen
	bmi.s	new_key_e			; bit 7 = echo

	move.b	d0,(a0)			; Taste setzen
	move.b	#255,1(a0)		; flag setzen

new_key_e	movem.l	(sp)+,d0/a0		; Register zurÅck		

	move.l	save_vec(pc),-(sp)		; original routine
	rts				; und hin damit

int_dummy	rte				; gleich ende

* Lîsche Tasten Key und Flag

clr_key	move.l	a0,-(sp)			; a0 retten
	lea	tas_key(pc),a0		; a0 --> taste_adr
	clr.b	(a0)			; lîsche taste
	clr.b	1(a0)			; lîsche flag
	move.l	(sp)+,a0			; a0 zurÅck
	rts				; und ende


*****************************************
* Datenbereiche			*
* ------------------------------------- *
* 				*
*****************************************

shap_flag	ds.l	1
mouse_vec	ds.l	1
kbdv_adr	ds.l	1
save_vb2	dc.l	0
stack	dc.l	0
ssp	dc.l	0
out	dc.l	0

routines	dc.l	play_chip
	dc.l	conv_chip

tas_key	dc.b	0
tas_flag	dc.b	0
save_sr	dc.l	0
save_vbl	dc.l	0
save_i07	dc.l	0
save_i09	dc.l	0
save_vec	dc.l	0

pause	ds.w	640
paus_zero	jmp	(a6)
	
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

