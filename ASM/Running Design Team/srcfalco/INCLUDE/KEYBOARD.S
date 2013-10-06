
;**************************************
;* ikbd_handler
;**************************************

; V0.6: written 1997
; V0.7: rewritten 23/02/98 -> fixpack #1
; V0.8: rewritten 21/04/98 -> midiplay


ikbd		equ	$118
ikbd_key_ctl	equ	$fffffc00
ikbd_key_dat	equ	$fffffc02


; fuer maussteuerung -> nur in diesem file benoetigt
mx		equ	0
my		equ	2
mx_last		equ	4
my_last		equ	6
mdx		equ	8
mdy		equ	10
mdirection	equ	12
mbuttons	equ	14


;**************************************
;* ikbd_handler
;**************************************

; interrupt-routine fuer den empfang von
; keyboard und midi-daten

; rewritten 21/04/98 nach tos-auszuegen
; dank an lepo!

ikbd_handler

		movem.l	d0-d2/a0-a2,-(sp)	; register retten

ih_another_one
		bsr	ikbd_keyboard_handler
		ifne midiplay
		jsr	ikbd_midi_handler
		endc

		btst	#4,$fffffa01.w		; mfp gpip pruefen, ob noch ein weiterer irq vorhanden
		beq.s	ih_another_one		; wenn ja -> dann das ganze nochmal

		bclr	#6,$fffffa11.w		; interrupt service bit loeschen

		movem.l	(sp)+,d0-d2/a0-a2
		rte


;**************************************
;* ikbd_keyboard_handler
;**************************************

; unterroutine, die prueft, ob der keyboard-acia ein
; byte zum empfang bereitgestellt hat
; -> eintragen in keytable

; zur verfuegung: d0-d2/a0-a2

ikbd_keyboard_handler

		btst	#7,ikbd_key_ctl.w	; war es ein keyboard-interrupt?
		beq.s	ikh_out			; wenn nein -> dann rausspringen
		move.b	ikbd_key_dat.w,d0	; byte holen

		lea	ikh_routine(pc),a1	; zeiger auf versch. routinen
		move.w	ikh_mode(pc),d1		; modus (keyboard, mouse_x oder mouse_y)
		movea.l	(a1,d1.w*4),a1		; richtige routine holen
		jsr	(a1)			; und ausfuehren
ikh_out
		rts				; beenden


;**************************************
;* ikh_key
;**************************************

; d0.b = empfangenes byte

ikh_key

	; jetzt auf mouse-events pruefen

		move.b	d0,d1
		andi.b	#$fc,d1
		cmpi.b	#$f8,d1
		beq.s	ikhk_mouse_event

	; taste wurde gedrueckt oder losgelassen

		lea	keytable(pc),a0
		moveq	#0,d1
		btst	#7,d0			; gedrueckt oder losgelassen
		bne.s	ikhk_released
		moveq	#-1,d1
ikhk_released	andi.w	#$7f,d0
		move.b	d1,(a0,d0.w)
		bra.s	ikhk_out

ikhk_mouse_event

	; die nachfolgenden bytes sind mausmeldungen

		andi.w	#$3,d0			; status der mousebuttons
		move.w	d0,mouse_buttons
		move.w	#1,ikh_mode		; naechstes mal mouse_x empfangen

ikhk_out
		rts


;**************************************
;* ikh_mouse_x
;**************************************

; d0.b = empfangenes byte

ikh_mouse_x
		ext.w	d0
		add	d0,mouse_x
		move.w	#2,ikh_mode
		rts


;**************************************
;* ikh_mouse_y
;**************************************

; d0.b = empfangenes byte

ikh_mouse_y
		ext.w	d0
		add	d0,mouse_y
		clr.w	ikh_mode
		rts


;**************************************
;* tabellen, daten
;**************************************

keytable	ds.b	128		; aktueller status der tastatur (alle tasten)
keytable_help	ds.b	128		; hilfstabelle zum speichenspeichern

ikh_mode	dc.w	0		; welche routine bei keyboard-daten
					; 0 = keyboard (norm. taste)
					; 1 = mouse x
					; 2 = mouse y

ikh_routine	dc.l	ikh_key		; zeiger auf diese unterschied-
		dc.l	ikh_mouse_x	; lichen routinen
		dc.l	ikh_mouse_y


mouse_x		dc.w	0		; status der mouse
mouse_y		dc.w	0
mouse_x_last	dc.w	0
mouse_y_last	dc.w	0
mouse_dx	dc.w	0
mouse_dy	dc.w	0
mouse_direction	dc.w	0
mouse_buttons	dc.w	0

