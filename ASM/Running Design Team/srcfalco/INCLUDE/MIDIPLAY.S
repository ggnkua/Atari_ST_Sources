
; Running Midiplay Edition
; (c) 1998 by RDT

; Sammlung aller Routinen, die als Ergaenzung zur
; Running Midiplay Edition notwendig sind 
; (ausser Protokoll-Routinen)

; Routinen werden eingebunden, falls
; die Konstante midiplay ungleich Null gesetzt ist.

; Projektstart: 10.4.98



;**************************************
;* mp_midiplay
;**************************************

; verbindungsaufbau-screen
; aufruf aus dem startmenue heraus
; vollkommen eigenstaendige routine

; benutzte speicherbereiche:
; - truecolor_tab
; - dith_data

mpme_screen	equ	0
mpme_master	equ	mpme_screen+153768
mpme_world	equ	mpme_master+179328
mpme_connect	equ	mpme_world+12416
mpme_glitzer	equ	mpme_connect+24448
		;equ	mpme_glitzer+1728


mp_midiplay

		bsr	mpm_loadFiles
		bsr	mpm_fadeout
		bsr	mpm_connect_in

mpm_main	bsr	mpm_glitzer
		bsr	mpm_paint
		bsr	mpm_make_world
		bsr	mpm_keys
		bsr	mpm_animate

		jsr	vsync
		jsr	vsync
		jsr	swap_me

		tst.b	keytable+$1
		beq.s	mpm_main
		clr.b	keytable+$1

		tst.w	midi_dat+midi_connected
		bne.s	mpmm_connected
		bsr	mpm_connect_out
		bra.s	mpmm_ok
mpmm_connected	bsr	mpm_established_out

mpmm_ok
		bsr	mpm_fadein

		rts

;-----------------------

mpm_glitzer
		lea	mpmgl_wait,a0
		tst.w	(a0)
		bmi.s	mpmgl_animate
		subq.w	#1,(a0)
		bmi.s	mpmgl_animate
		moveq	#0,d1
		bsr.s	mpmgl_paint_phase
		bra.s	mpmgl_out
mpmgl_animate
		move.w	2(a0),d1		; mpmgl_pos
		bsr.s	mpmgl_paint_phase
		addq.w	#1,d1
		cmpi.w	#11,d1
		bgt.s	mpmgl_anim_end
		move.w	d1,2(a0)		; mpmgl_pos zurueckschreiben
		bra.s	mpmgl_out

mpmgl_anim_end	clr.w	2(a0)			; mpmgl_pos loeschen
		jsr	get_zufall_256
		move.w	d1,(a0)			; mpmgl_wait
mpmgl_out
		rts

;---

mpmgl_paint_phase
		movea.l	screen_1,a6
		adda.w	#79*2+16*640,a6
		lea	truecolor_tab+mpme_glitzer+128,a5
		adda.w	4(a0,d1.w*2),a5
		moveq	#9,d7
		move.w	#640,d6
mpmglph_loop	movem.l	(a5),d0/d2-d5
		movem.l	d0/d2-d5,(a6)
		lea	160(a5),a5
		lea	640(a6),a6
		dbra	d7,mpmglph_loop
		rts

;-----------------------

; laesst die connection-anweisung von links einfliegen

mpm_connect_in

		lea	truecolor_tab+mpme_connect+128,a0
		bsr	mpm_cin

		rts

;-----------------------

; laesst die connection-anweisung nach links ausfliegen

mpm_connect_out

		lea	truecolor_tab+mpme_connect+128,a0
		bsr	mpm_cout

		rts

;-----------------------

; laesst die established-anweisung von links einfliegen

mpm_established_in

		lea	truecolor_tab+mpme_connect+128+320,a0
		bsr	mpm_cin

		rts

;-----------------------

; laesst die established-anweisung nach links ausfliegen

mpm_established_out

		lea	truecolor_tab+mpme_connect+128+320,a0
		bsr	mpm_cout

		rts

;---------------

; a0 = einzufliegende grafik

mpmcin_dx	equ	180
mpmcin_y	equ	140

mpm_cin
		move.l	a0,-(sp)

		movea.l	screen_2,a0
		movea.l	screen_1,a1
		jsr	copy_240

		movea.l	(sp)+,a0
		move.w	#32,d7
mpmci_loop
		movem.l	d7/a0,-(sp)
		bsr	mpm_make_world
		movem.l	(sp)+,d7/a0
		bsr	mpmci_clear_white
		bsr	mpmci_calc_x1y1		; rueckgabe in d0/d1
		bsr	mpmci_paint
		movem.l	d7/a0,-(sp)
		jsr	vsync
		jsr	swap_me
		movem.l	(sp)+,d7/a0
		dbra	d7,mpmci_loop
mpmci_skip
		movea.l	screen_2,a0
		movea.l	screen_1,a1
		jsr	copy_240

		rts

;---

mpm_cout
		move.l	a0,-(sp)

		movea.l	screen_2,a0
		movea.l	screen_1,a1
		jsr	copy_240

		movea.l	(sp)+,a0
		moveq	#0,d7
mpmco_loop
		movem.l	d7/a0,-(sp)
		bsr	mpm_make_world
		movem.l	(sp)+,d7/a0
		bsr	mpmci_clear_white
		bsr	mpmci_calc_x1y1		; rueckgabe in d0/d1
		bsr	mpmci_paint
		movem.l	d7/a0,-(sp)
		jsr	vsync
		jsr	swap_me
		movem.l	(sp)+,d7/a0
		addq.w	#1,d7
		cmpi.w	#33,d7
		blt.s	mpmco_loop
mpmco_skip
		movea.l	screen_2,a0
		movea.l	screen_1,a1
		jsr	copy_240

		rts

;---

; a0 = zu zeichnende grafik
; d0 = x1
; d1 = y1
; d7 = counter (dbra)

mpmci_paint
		movem.l	d7/a0,-(sp)
		movea.l	screen_1,a1
		mulu	#640,d1
		adda.l	d1,a1

		move.w	#160-1,d6	; defaultbreite
		tst.w	d0		; x1
		bpl.s	mpmcip_no_clip

		neg.w	d0
		sub.w	d0,d6		; breite veringern
		bmi.s	mpmcip_out	; notfalls -> raus
		lea	(a0,d0.w*2),a0
		moveq	#0,d0
mpmcip_no_clip

	; d6 = breite
	; d0 = x1

		lea	(a1,d0.w*2),a1
		moveq	#38-1,d7
mpmcip_loop1	movea.l	a0,a2
		movea.l	a1,a3
		move.w	d6,d5
mpmcip_loop2	move.w	(a2)+,(a3)+
		dbra	d5,mpmcip_loop2
		lea	640(a0),a0
		lea	640(a1),a1
		dbra	d7,mpmcip_loop1
mpmcip_out
		movem.l	(sp)+,d7/a0
		rts

;---

; d7 = pos [32..0]
; rueckgabe: d0/d1

mpmci_calc_x1y1
		movem.l	d7/a0,-(sp)
		lsl.w	#2,d7
		lea	sinus_256_tab,a4
		addi.w	#$40,d7			; brauche cosinus
		move.w	(a4,d7.w*2),d0		; d0 = cosinus
		muls	#mpmcin_dx/2,d0
		lsl.l	#2,d0
		swap	d0
		addi.w	#mpmcin_dx/2-160/2,d0	; d0 = mx
		subi.w	#80,d0			; d0 = x1
		move.w	#mpmcin_y,d1
		movem.l	(sp)+,d7/a0
		rts

;---

mpmci_clear_white

		movem.l	a0/d7,-(sp)
		movea.l	screen_1,a6
		adda.l	#mpmcin_y*640,a6
		moveq	#-1,d0			; weiss

		moveq	#38-1,d6
mpmcicw_loop1	move.w	#mpmcin_dx-1,d7
		movea.l	a6,a5
mpmcicw_loop2	move.w	d0,(a5)+
		dbra	d7,mpmcicw_loop2
		lea	640(a6),a6
		dbra	d6,mpmcicw_loop1
		movem.l	(sp)+,a0/d7

		rts


;-----------------------

mpm_make_world

		clr.w	mpmmwb_anz

	;---

		lea	dith_data+153768+35*640+45*2,a0
		movea.l	screen_1,a1
		adda.l	#35*640+45*2,a1

		moveq	#99,d7
mpmmw_l1	moveq	#9,d6
mpmmw_l2	movem.l	(a0)+,d0-d5/a2-a6
		movem.l	d0-d5/a2-a6,(a1)
		lea	44(a1),a1
		dbra	d6,mpmmw_l2
		movem.l	(a0)+,d0-d4
		movem.l	d0-d4,(a1)
		lea	180(a0),a0
		lea	180+20(a1),a1
		dbra	d7,mpmmw_l1

	;---

		lea	mpmmw_pos,a0
		move.w	(a0),d0
		addq.w	#1,d0
		andi.w	#$ff,d0
		move.w	d0,(a0)

		bsr.s	mpmmw_one_world

		tst.w	midi_dat+midi_connected
		beq	mpmmw_out

		move.w	mpmmw_anz,d1
		subq.w	#2,d1
		bmi.s	mpmmw_out

mpmmw_loop
		move.w	d1,-(sp)
		move.w	mpmmw_pos,d0
		addq.w	#1,d1
		lsl.w	#4,d1
		add.w	d1,d0
		bsr.s	mpmmw_one_world
		move.w	(sp)+,d1
		dbra	d1,mpmmw_loop

mpmmw_out
		bsr	mpmmw_paint_all
mpmmw_skip
		rts

;---

; berechnet die bildschirmkoordinaten einer weltkugel

; d0 = mpmmw_pos [0..255]

mpmmw_one_world

		lea	sinus_256_tab,a4
		andi.w	#$ff,d0
		move.w	(a4,d0.w*2),d6		; sinus
		addi.w	#$40,d0
		andi.w	#$ff,d0
		move.w	(a4,d0.w*2),d7		; cosinus

	; (1) x/y-koordinaten im kreis berechnen

		moveq	#50,d5
		muls	d5,d6
		muls	d5,d7
		lsl.l	#2,d6
		lsl.l	#2,d7
		swap	d6
		swap	d7			; d7.w = x, d6.w = y

	; (2) entfernung zum betrachter berechnen

		addi.w	#100,d6

	; (3) bildschirmkoordinaten berechnen

		move.l	#5000,d1
		divu	d6,d1
		move.w	d1,d2
		move.w	d1,d0
		addi.w	#10,d1			; d1.w = by

		muls	d7,d0
		asr.l	#5,d0
		addi.w	#160,d0

		ext.l	d2
		lsl.l	#8,d2
		divu	#50,d2

		move.w	mpmmw_pos,d3
		lsr.w	#1,d3
		andi.w	#%111,d3

		move.w	mpmmwb_anz,d7
		addq.w	#1,mpmmwb_anz
		lea	mpmmwb_buffer,a0
		mulu	#12,d7
		adda.l	d7,a0

		move.l	screen_1,(a0)+
		movem.w	d0-d3,(a0)
		addq.l	#8,a0
		
		rts

;-----------------------

; zeichnen aller vorberechneten weltkugeln in 
; der richtigen reihenfolge (hinterste zuerst)

mpmmw_paint_all

		move.w	mpmmwb_anz,d7
		clr.w	mpmmwb_anz
		subq.w	#1,d7
		bmi.s	mpmmwpa_out
		lea	mpmmwb_buffer,a1

mpmmwpa_loop
		move.l	(a1)+,a0
		movem.w	(a1)+,d0-d3
		movem.l	d7/a1,-(sp)
		bsr	mpm_paint_world
		movem.l	(sp)+,d7/a1

		dbra	d7,mpmmwpa_loop
mpmmwpa_out
		rts

;-----------------------

mpm_paint

		move.w	mpm_selection,d0
		lsl.w	#3,d0
		add.w	mpm_pos,d0
		andi.w	#$f,d0

	; zeichne animationsphase <d0>

		movea.l	screen_1,a1
		move.w	#200,d1		; x
		move.w	#140,d2		; y
		bsr	mpmp_now

		rts

mpmp_now

	; !!! clipping nur in x-richtung !!!
	; a1 = screenadresse (lo)
	; d0 = animationsphase
	; d1 = x
	; d2 = y

		lea	truecolor_tab+mpme_master+128,a0
		mulu	#112*2*50,d0
		adda.l	d0,a0

		mulu	#640,d2
		move.w	d1,d3
		add.w	d1,d1
		ext.l	d1
		add.l	d1,d2
		adda.l	d2,a1

		moveq	#49,d7
		move.w	#319,d0
		sub.w	d3,d0			
		cmpi.w	#110,d0
		blt.s	mpmpn_xok
		moveq	#109,d0
mpmpn_xok	moveq	#109,d1
		sub.w	d0,d1
		
	; d0 = anzahl zu zeichn. pixel in x (-1), z.B. 99
	; d1 = anzahl ausgelassener pixel in x, z.B. 10

		add.w	d1,d1		

mpmpn_loop1	move.w	d0,d2
mpmpn_loop2	move.w	(a0)+,(a1)+
		dbra	d2,mpmpn_loop2
		addq.w	#4,a0
		adda.w	d1,a0
		adda.w	d1,a1
		lea	640-220(a1),a1
		dbra	d7,mpmpn_loop1

		rts

;-----------------------

mpm_keys
		lea	keytable,a0

		tst.b	$48(a0)
		beq.s	mpmk_no_48
		move.w	#1,mpm_direction
mpmk_no_48

		tst.b	$50(a0)
		beq.s	mpmk_no_50
		move.w	#-1,mpm_direction
mpmk_no_50

		tst.b	$1c(a0)			; enter
		beq.s	mpmk_no_1c
		clr.b	$1c(a0)
		bsr	mpm_connect
mpmk_no_1c

		rts

;-----------------------

mpm_connect

		tst.w	midi_dat+midi_connected
		bne.s	mpmc_connect
		bsr	mpm_connect_out
		bra.s	mpmc_start
mpmc_connect	bsr	mpm_established_out
mpmc_start

		lea	mpmc_txt_wait,a0
		movea.l	screen_2,a6
		adda.l	#640*150+10*2,a6
		bsr	paint_text

		clr.w	mirqe_pos		; empfangsbuffer loeschen

		move.w	#1,midi_start

		lea	midi_dat,a2
		clr.w	midi_pos(a2)
		clr.w	midi_anz(a2)
		clr.w	midi_anzm1(a2)
		clr.w	midi_connected(a2)

	; flags von der animation loeschen

		clr.w	mpm_direction
		clr.w	mpm_pos

	; master oder slave

		move.w	mpm_selection,d0
		andi.w	#%01,d0
		bne	mpmc_slave

mpmc_master

	; dieses ist der master falcon

		lea	midi_dat,a6
		clr.w	midi_pos(a6)
		clr.w	midi_anz(a6)
		clr.w	midi_anzm1(a6)
		move.w	#1,midi_mode(a6)	; masterflag setzen
		clr.w	midi_connected(a6)

	; (1) midi kommando 0 (verbindungsaufbau) schicken

		lea	mirq0_raw,a0
		move.b	#16,1(a0)		; max. ttl (-> max. 16 falcons)
		clr.b	m0_counter(a0)		; anzahl loeschen
		bsr	mp_send_data

	; (2) solange warten, bis midi_anz gesetzt wurde

		lea	keytable,a0
mpmcm_wait	
		tst.b	$1(a0)			; esc
		bne.s	mpmc_out		; -> abbrechen und raus

		tst.w	midi_anz(a6)
		beq.s	mpmcm_wait

	; (3) verbindung wurde hergestellt -> solange warten,
	;     bis flag midi_connected gesetzt ist (dann haben
	;     alle falcons ihre positionsdaten erhalten

mpmcm_wait2
		tst.b	$1(a0)			; esc
		bne.s	mpmc_out

		tst.w	midi_connected(a6)
		beq.s	mpmcm_wait2

		move.w	midi_anz(a6),mpmmw_anz

		bra	mpmc_out


mpmc_slave

	; dieses ist ein slave falcon

		lea	midi_dat,a6
		clr.w	midi_pos(a6)
		clr.w	midi_anz(a6)
		clr.w	midi_anzm1(a6)
		move.w	#-1,midi_mode(a6)	; slaveflag setzen
		clr.w	midi_connected(a6)

	; (1) solange warten, bis flag midi_connected gesetzt wurde

mpmcs_wait
		tst.b	keytable+$1		; esc
		bne.s	mpmc_out

		tst.w	midi_connected(a6)
		beq.s	mpmcs_wait

		move.w	midi_anz(a6),mpmmw_anz

mpmc_out
		clr.b	keytable+$1		; esc-taste zur sicherheit loeschen

	; ist keine verbindung zustande gekommen, dann midi_start auch
	; wieder loeschen -> keine weitere uebertragung von midi-daten

	; a6 = midi_dat

		tst.w	midi_connected(a6)
		bne.s	mpmc_connected

		clr.w	midi_start
		bsr	mpm_connect_in
		bra.s	mpmc_ok

mpmc_connected
		bsr	mpm_established_in
		bsr	mpmc_get_name

mpmc_ok
		rts


;-----------------------

mpmcgn_x	equ	50
mpmcgn_y	equ	120

mpmc_get_name

	; physischen screen kopieren
		movea.l	screen_2,a0
		movea.l	screen_1,a1
		jsr	copy_240
	; screen abdunkeln
		movea.l	screen_1,a0
		jsr	screen_abdunkeln
	; schwarze zeile zeichnen
		movea.l	screen_1,a0
		adda.l	#(mpmcgn_y-2)*640,a0
		move.w	#320/4*1-1,d0
mpmcgnb_loop1	move.l	#$ffffffff,640(a0)
		clr.l	(a0)+
		move.l	#$ffffffff,640(a0)
		clr.l	(a0)+
		dbra	d0,mpmcgnb_loop1
		movea.l	screen_1,a0
		adda.l	#mpmcgn_y*640,a0
		move.w	#320/4*19-1,d0
mpmcgnb_loop2	clr.l	(a0)+
		clr.l	(a0)+
		dbra	d0,mpmcgnb_loop2
		movea.l	screen_1,a0
		adda.l	#(mpmcgn_y+19)*640,a0
		move.w	#320/4*1-1,d0
mpmcgnb_loop3	move.l	#$ffffffff,640(a0)
		clr.l	(a0)+
		move.l	#$ffffffff,640(a0)
		clr.l	(a0)+
		dbra	d0,mpmcgnb_loop3
	; drumherum zeichnen
		lea	mpmcgn_name,a0
		movea.l	screen_1,a6
		adda.l	#mpmcgn_y*640-24*640+mpmcgn_x*2,a6
		jsr	paint_menutext
	; ueberblenden
		jsr	vsync
		jsr	swap_me

	; hauptschleife

		lea	midi_dat,a0
		move.w	midi_pos(a0),d0
		lea	mplayers,a0
		movea.l	(a0,d0.w*4),a6
		lea	mon_midi_name(a6),a6		; a6 = pointer auf namen
		move.l	#"NONA",(a6)
		move.w	#"ME",4(a6)
		clr.b	6(a6)				; nullzeichen setzen
		lea	mpmcgn_pos,a5
		move.w	#6,(a5)				; position setzen
mpmcgn_loop
		movem.l	a5-a6,-(sp)
		jsr	get_next_ascii			; ascii-code holen
		movem.l	(sp)+,a5-a6			; register zurueck
		tst.b	d0				; ist einer vorhanden?
		beq.s	mpmcgn_no_new			; nein -> nur wieder zeichnen

		cmpi.b	#8,d0				; backspace?
		beq.s	mpmcgn_8			; ja -> eigene routine
		cmpi.b	#13,d0				; return?
		beq	mpmcgn_done			; ja -> name fertig
		cmpi.b	#" ",d0
		beq.s	mpmcgn_ok
		cmpi.b	#$30,d0				; wenn jetzt kleiner als null
		blt.s	mpmcgn_no_new			; -> ueberspringen
		cmpi.b	#$39+1,d0			; kleiner gleich "9"?
		blt.s	mpmcgn_ok			; zeichnen -> es ist eine zahl
		subi.b	#$20,d0				; kleinbuchstaben -> grossbuchstaben
		cmpi.b	#$41,d0
		blt.s	mpmcgn_no_new
		cmpi.b	#$5b,d0
		bgt.s	mpmcgn_no_new

mpmcgn_ok
		move.w	(a5),d1
		cmpi.w	#10,d1
		bgt.s	mpmcgn_no_new

		; normales ascii-zeichen
		move.w	(a5),d1				; position holen
		addq.w	#1,(a5)				; eins addieren
		move.b	d0,(a6,d1.w)			; zeichen eintragen
		clr.b	1(a6,d1.w)			; endemarkierung eintragen
		bra.s	mpmcgn_no_new			; -> weiter zum zeichnen
mpmcgn_8
		; backspace
		move.w	(a5),d1				; position holen
		beq.s	mpmcgn_no_new			; wenn schon anfang -> weiter zum zeichnen
		subq.w	#1,(a5)				; position erniedrigen
		clr.b	-1(a6,d1.w)			; endemarkierung setzen

mpmcgn_no_new
		movea.l	screen_2,a0
		adda.l	#mpmcgn_y*640,a0
		move.w	#320/4*19-1,d0
mpmcgnb_loop4	clr.l	(a0)+
		clr.l	(a0)+
		dbra	d0,mpmcgnb_loop4

		movea.l	a6,a0				; textpointer
		movem.l	a5-a6,-(sp)
		movea.l	screen_2,a6			; screenadresse
		adda.l	#mpmcgn_y*640+640+mpmcgn_x*2,a6	; berechnen
		movem.l	a5-a6,-(sp)
		jsr	paint_menutext			; und text zeichnen
		movem.l	(sp)+,a5-a6
		move.w	(a5),d0
		mulu	#10*2,d0
		addi.w	#640+2,d0
		adda.l	d0,a6
		bsr	mpmcgn_cursor

		jsr	vsync				; flackern unterbinden
		movem.l	(sp)+,a5-a6			; register endgueltig zurueck
		tst.b	keytable+1			; esc gedrueckt?
		beq	mpmcgn_loop			; -> loopen

mpmcgn_done
		; ueberblenden
		jsr	vsync
		moveq	#0,d0
		jsr	make_blenden

mpmcgn_out
		move.b	#1,keytable+$1		; esc setzen -> autom. midiplay-rout. beenden

		bsr	mp_send_3		; namen uebermitteln

		rts

mpmcgn_pos	dc.w	0
mpmcgn_name	dc.b	"PLAYERS NAME",0
		even

;---

; a6 = adresse

mpmcgn_cursor
		move.l	vbl_count,d0
		move.l	#%01111011111011110111101111101111,d7	; farbe
		btst	#4,d0
		beq.s	mpmcgnc_color2
		moveq	#0,d7
mpmcgnc_color2	moveq	#16-1,d6
mpmcgnc_loop	move.l	d7,(a6)
		move.l	d7,4(a6)
		move.l	d7,8(a6)
		move.l	d7,12(a6)
		move.l	d7,16(a6)
		lea	640(a6),a6
		dbra	d6,mpmcgnc_loop

		rts
		
;-----------------------

mpm_animate
		move.w	mpm_pos,d1
		move.w	mpm_direction,d0
		beq.s	mpma_out
		bpl.s	mpma_forward

mpma_backward
		add.w	d0,d1
		bmi.s	mpmab_selchange
		bne.s	mpmab_no_end
		clr.w	mpm_direction
		movem.l	d0-d1,-(sp)
		move.w	#snd_door_rastet,d0
		moveq	#0,d1
		jsr	init_sam
		movem.l	(sp)+,d0-d1
		bra	mpmab_no_end
mpmab_selchange	subq.w	#1,mpm_selection
		andi.w	#%11,mpm_selection
		add.w	mpm_animmax,d1
mpmab_no_end	move.w	d1,mpm_pos
		bra.s	mpma_out

mpma_forward
		add.w	d0,d1
		cmp.w	mpm_animmax,d1
		blt.s	mpmaf_no_end
		moveq	#0,d1
		clr.w	mpm_direction
		addq.w	#1,mpm_selection
		andi.w	#%11,mpm_selection
		movem.l	d0-d1,-(sp)
		move.w	#snd_door_rastet,d0
		moveq	#0,d1
		jsr	init_sam
		movem.l	(sp)+,d0-d1
mpmaf_no_end	move.w	d1,mpm_pos

mpma_out
		rts

;-----------------------

; alle noetigen dateien fuer den verbindungsscreen einladen
; - master-slave box animation
; - weltkugel animation
; - hintergrundbild

mpm_loadFiles

	; master-slave box animation

		lea	loadsave_file,a1
		lea	mpm_file,a0
		move.l	(a0)+,lsf_size(a1)
		move.l	a0,lsf_name_ptr(a1)
		move.l	#truecolor_tab+mpme_master,lsf_buf_ptr(a1)
		jsr	load_file

	; weltkugel animation

		lea	loadsave_file,a1
		lea	mpm_file_wo,a0
		move.l	(a0)+,lsf_size(a1)
		move.l	a0,lsf_name_ptr(a1)
		move.l	#truecolor_tab+mpme_world,lsf_buf_ptr(a1)
		jsr	load_file

	; connect statusmeldungen

		lea	loadsave_file,a1
		lea	mpm_file_co,a0
		move.l	(a0)+,lsf_size(a1)
		move.l	a0,lsf_name_ptr(a1)
		move.l	#truecolor_tab+mpme_connect,lsf_buf_ptr(a1)
		jsr	load_file

	; glitzer-effekt

		lea	loadsave_file,a1
		lea	mpm_file_gl,a0
		move.l	(a0)+,lsf_size(a1)
		move.l	a0,lsf_name_ptr(a1)
		move.l	#truecolor_tab+mpme_glitzer,lsf_buf_ptr(a1)
		jsr	load_file

	; hintergrundbild
	; zum einen in den logischen screen ...

		lea	loadsave_file,a1
		lea	mpm_file_ms,a0
		move.l	(a0)+,lsf_size(a1)
		move.l	a0,lsf_name_ptr(a1)
		move.l	screen_1,d0
		subi.l	#128,d0
		move.l	d0,lsf_buf_ptr(a1)
		jsr	load_file

	; ... zum anderen als spaetere sicherung nach dith_data

		movea.l	screen_1,a0
		lea	dith_data+153768,a1
		jsr	copy_240

		rts

;-----------------------

; ueberblenden vom hauptmenue in den verbindungsscreen
; - midi flags initialisieren
; - master-slave box initialisieren
; - box (phase #0) zeichnen
; - hauptmenue als screen zwischenspeichern
; - ueberblenden

mpm_fadeout

	; midi flags initialisieren

		clr.w	mirqe_pos		; empfangsbuffer loeschen

		lea	midi_dat,a6
		clr.w	midi_pos(a6)
		clr.w	midi_anz(a6)
		clr.w	midi_anzm1(a6)
		clr.w	midi_mode(a6)
		clr.w	midi_connected(a6)
		clr.w	midi_level_flag(a6)

	; master-slave box animation initialisieren

		clr.w	mpm_selection
		clr.w	mpm_pos
		clr.w	mpm_direction

	; box (phase #0) in logischen zeichnen
	; hintergrundbild existiert schon

		movea.l	screen_1,a1
		moveq	#0,d0
		move.w	#200,d1
		move.w	#140,d2
		bsr	mpmp_now

	; hauptmenue als screen zwischenspeichern

		movea.l	screen_2,a0
		lea	truecolor_tab+mpme_screen,a1
		jsr	copy_240

	; ... und ueberblenden

		moveq	#1,d0
		jsr	make_blenden

		rts

;-----------------------

; zum hauptmenue wieder ueberblenden

mpm_fadein
		lea	truecolor_tab+mpme_screen,a0
		movea.l	screen_1,a1
		jsr	copy_240

		moveq	#1,d0
		jsr	make_blenden

		rts

;**************************************
;* mpm_paint_world
;**************************************

; a0 = screen
; d0 = xm
; d1 = ym
; d2 = zoom (8 vorkomma, 8 nachkomma)
; d3 = animationsphase (0..7)

; !!! kein clipping !!!

mpm_paint_world

	; (1) zeiger auf grafik ermitteln

		lea	truecolor_tab+mpme_world+128,a1
		mulu	#32*24*2,d3
		adda.l	d3,a1

	; (2) breite und hoehe berechnen

		moveq	#24,d3
		mulu	d2,d3
		lsr.w	#8,d3
		subq.w	#1,d3		; fuer dbra

	; (3) anfangsadresse im bildschirm bestimmen

		add.w	d0,d0
		sub.w	d3,d0
		bclr	#0,d0
		adda.w	d0,a0
		move.w	d3,d0
		lsr.w	#1,d0
		sub.w	d0,d1
		mulu	#640,d1
		adda.l	d1,a0

	; (4) ... und zeichnen

	; a0 = screenadresse sprite links oben
	; d2 = zoomfaktor (8:8)
	; a1 = sprite (24x24)
	; d3 = hoehe/breite (fuer dbra)

		move.l	#$10000,d7
		divu	d2,d7
		move.w	d7,d2
		ext.l	d2
		lsl.l	#8,d2
		move.l	d2,d6
		swap	d6
		moveq	#0,d4		; y zaehler
		move.w	d3,d0
mpmpw_loop1	movea.l	a0,a2
		move.w	d3,d1
		moveq	#0,d5		; x zaehler
mpmpw_loop2	
		move.w	(a1,d5.w*2),d7
		cmpi.w	#%0000000000100000,d7
		beq.s	mpmpw_skip
		move.w	d7,(a2)
mpmpw_skip	addq.l	#2,a2
		addx.l	d6,d5

		dbra	d1,mpmpw_loop2

		add.l	d2,d4
		swap	d4
		move.l	d4,d5
		mulu	#64,d5
		adda.l	d5,a1
		clr.w	d4
		swap	d4

		lea	640(a0),a0

		dbra	d0,mpmpw_loop1

		rts



;********************************************************************
;********************************************************************
;*
;* mc2e routinen: midi command -> engine
;*
;* a0 = mirqe_buffer
;* zur verfuegung: d0-d2/a1-a2
;* alle anderen register muessen bei verwendung gerettet werden
;*
;********************************************************************
;********************************************************************

; 0 = anzahl falcons zaehlen

mc2e0
		lea	midi_dat,a2
		tst.w	midi_mode(a2)	; master oder slave?
		bmi.s	mc2e0_slave
		beq.s	mc2e0_out
mc2e0_master
		
	; master
	; (1) midi-commando loeschen -> ttl negativ

		neg.w	1(a0)

	; (2) anzahl falcons lokal eintragen

		moveq	#0,d0
		move.b	m0_counter(a0),d0
		clr.w	midi_pos(a2)		; master hat position 0
		move.w	d0,midi_anzm1(a2)	; anzahl eintragen (-1)
		addq.w	#1,d0
		move.w	d0,midi_anz(a2)		; anzahl eintragen

	; (3) anderen falcons ihre position mitteilen
	;     -> ueber verbindung kontrollieren

		lea	mirq1_raw,a0
		move.b	d0,1(a0)		; ttl -> bis an master zurueck
		move.b	d0,m1_anz(a0)		; anzahl falcons
		bsr	mp_send_data
		
		bra.s	mc2e0_out

mc2e0_slave

	; slave:
	; counter (anzahl falcons im token-ring) einfach erhoehen

		addq.b	#1,m0_counter(a0)

mc2e0_out
		rts

;**************************************

; 1 = verbindung kontrollieren

mc2e1
		lea	midi_dat,a2
		tst.w	midi_mode(a2)
		bmi.s	mc2e1_slave
		beq.s	mc2e1_out

mc2e1_master
	
	; verbindungsflag zuletzt am master falcon setzen

		move.w	#1,midi_connected(a2)

		bra.s	mc2e1_out

mc2e1_slave

	; verbindung kontrollieren -> position des falcons im
	; token-ring lokal eintragen

		moveq	#0,d0
		move.b	m1_anz(a0),d0		; d0 = anzahl falcons
		move.w	d0,midi_anz(a2)
		move.w	d0,d1
		subq.w	#1,d0
		move.w	d0,midi_anzm1(a2)
		sub.b	1(a0),d1		; ttl abziehen
		moveq	#1,d2
		add.w	d2,d1
		move.w	d1,midi_pos(a2)
		move.w	d2,midi_connected(a2)	; flag setzen
mc2e1_out
		rts

;**************************************

; 3 = spielername uebertragen

mc2e3
		lea	mplayers,a1
		move.b	m3_falcon(a0),d0
		andi.w	#%1111,d0
		movea.l	(a1,d0.w*4),a1
		move.l	m3_name(a0),mon_midi_name(a1)
		move.l	m3_name+4(a0),mon_midi_name+4(a1)
		move.l	m3_name+8(a0),mon_midi_name+8(a1)
		rts

;**************************************

; 10 = spielerposition folgt

mc2e10

	; falcon bestimmen, dessen position gemeldet wird

		move.b	m10_spieler(a0),d0	; spielernummer
		andi.w	#%0000000000001111,d0	; nur max. 16 falcons		

		lea	mplayers,a1
		movea.l	(a1,d0.w*4),a1		; a1 = pointer auf gegner

		move.b	m10_sector(a0),mon_midi_sector+1(a1)
		move.b	m10_sx(a0),d0
		ext.w	d0
		move.w	d0,mon_midi_x(a1)
		move.b	m10_sx+1(a0),mon_midi_x+2(a1)
		move.b	m10_sx+2(a0),mon_midi_x+3(a1)

		move.b	m10_sy(a0),d0
		ext.w	d0
		move.w	d0,mon_midi_y(a1)
		move.b	m10_sy+1(a0),mon_midi_y+2(a1)
		move.b	m10_sy+2(a0),mon_midi_y+3(a1)

		move.b	m10_sh(a0),mon_midi_sh(a1)

		move.b	m10_salpha(a0),mon_midi_alpha(a1)

		move.b	m10_walk_flag(a0),mon_midi_walk(a1)

		rts

;**************************************

; 11 = spieler wurde getroffen

mc2e11
		moveq	#0,d0
		move.b	m11_wen(a0),d0
		cmp.w	midi_dat+midi_pos,d0	; ist der getroffene dieser rechner selbst?
		bne.s	mc2e11_another

	; (1) routine fuer: getroffener spieler ist dieser falcon

		moveq	#0,d1
		move.b	m11_energy_loss(a0),d1
		lsl.w	#8,d1
		lsl.w	#2,d1
		movem.l	d3-d7/a3-a6,-(sp)
		jsr	pd_health_minimieren
		movem.l	(sp)+,d3-d7/a3-a6

		movea.l	play_dat_ptr,a1
		tst.w	pd_health(a1)
		bpl.s	mc2e11_out
		bsr	mp_send_12
		bra.s	mc2e11_out

mc2e11_another

	; (2) routine fuer: getroffener spieler ist ein anderer midiplayer

		lea	mplayers,a1
		movea.l	(a1,d0.w*4),a1
		tst.w	mon_visible(a1)		; gegner ueberhaupt sichtbar?
		beq.s	mc2e11_out		; nein -> raus
		move.w	#1,mon_midi_hit(a1)	; flag fuer animation setzen
		move.w	mon_hit_snd(a1),d2	; sample fuer getroffen
 		movem.l	mon_line(a1),d0-d1	; und abhaengig von der position
		jsr	init_sam_dist		; das sample abspielen
mc2e11_out
		rts

;**************************************

; 12 = spieler stirbt

mc2e12
		moveq	#0,d0
		move.b	m12_wer(a0),d0
		lea	mplayers,a1
		movea.l	(a1,d0.w*4),a1
		move.b	#1,mon_midi_die(a1)
		tst.w	mon_visible(a1)
		beq.s	mc2e12_out
		move.w	mon_died_snd(a1),d2
		movem.l	mon_line(a1),d0-d1
		jsr	init_sam_dist
mc2e12_out
		rts


;**************************************

; 13 = spieler schiesst

mc2e13
		movem.l	d0-a6,-(sp)
		movea.l	screen_2,a2
		adda.l	#640*200,a2
		movem.l	d0-a6,(a2)
		movem.l	d0-a6,640(a2)
		movem.l	(sp)+,d0-a6

		moveq	#0,d0
		move.b	m13_wer(a0),d0
		lea	mplayers,a1
		movea.l	(a1,d0.w*4),a1
		move.b	#1,mon_midi_shoot(a1)
		tst.w	mon_visible(a1)
		beq.s	mc2e13_out
		move.w	mon_shoot_snd(a1),d2
		movem.l	mon_line(a1),d0-d1
		jsr	init_sam_dist
mc2e13_out
		rts


;**************************************

; 20 = tuer oeffnen

mc2e20
		movea.l	big_sector_ptr,a1
		moveq	#0,d0
		move.b	m20_sector(a0),d0
		movea.l	lev_sec_start(a1,d0.w*4),a1
		movea.l	sec_doors(a1),a1
		move.b	m20_door(a0),d0
		movea.l	(a1,d0.w*4),a0
		move.w	#%10010,door_status(a0)		; bit #4 = kein autom. schliessen, bit #1 = oeffnen
		bsr	door_to_anim
		rts


;**************************************

; 21 = tuer schliessen

mc2e21
		movea.l	big_sector_ptr,a1
		moveq	#0,d0
		move.b	m21_sector(a0),d0
		movea.l	lev_sec_start(a1,d0.w*4),a1
		movea.l	sec_doors(a1),a1
		move.b	m21_door(a0),d0
		movea.l	(a1,d0.w*4),a0
		move.w	#%101,door_status(a0)		; bit #2 = schliessen, bit #0 = bewegungsrichtung
		bsr	door_to_anim
		rts

;**************************************

; 24 = item verschwindet

mc2e24
		movea.l	big_sector_ptr,a1
		moveq	#0,d0
		move.b	m24_sector(a0),d0
		movea.l	lev_sec_start(a1,d0.w*4),a1
		movea.l	sec_things(a1),a1
		move.b	m24_item(a0),d0
		movea.l	(a1,d0.w*4),a1
		tst.w	thing_type(a1)		; ist item schon unsichtbar?
		bmi.s	mc2e24_skip		; ja -> dann uebergehen
		neg.w	thing_type(a1)		; item als aufgen./unsichtb. kennzeichnen
mc2e24_skip	rts

;**************************************

; 25 = item erscheint

mc2e25
		movem.l	d0-a6,-(sp)
		move.l	(a0),d0
		moveq	#7,d7
		movea.l	screen_2,a2
		adda.l	#640*180+80,a2
		jsr	paint_hex
		movem.l	(sp)+,d0-a6
		movem.l	d0-a6,-(sp)
		move.l	(a0),d0
		moveq	#7,d7
		movea.l	screen_1,a2
		adda.l	#640*180+80,a2
		jsr	paint_hex
		movem.l	(sp)+,d0-a6

		movem.l	d0-a6,-(sp)
		move.l	4(a0),d0
		moveq	#7,d7
		movea.l	screen_2,a2
		adda.l	#640*190+80,a2
		jsr	paint_hex
		movem.l	(sp)+,d0-a6
		movem.l	d0-a6,-(sp)
		move.l	4(a0),d0
		moveq	#7,d7
		movea.l	screen_1,a2
		adda.l	#640*190+80,a2
		jsr	paint_hex
		movem.l	(sp)+,d0-a6

		movea.l	big_sector_ptr,a1
		moveq	#0,d0
		move.b	m25_sector(a0),d0
		movea.l	lev_sec_start(a1,d0.w*4),a1
		movea.l	sec_things(a1),a1
		move.b	m25_item(a0),d0
		movea.l	(a1,d0.w*4),a1
		tst.w	thing_type(a1)		; ist item schon sichtbar?
		bpl.s	mc2e25_skip		; ja -> dann uebergehen
		neg.w	thing_type(a1)		; item als sichtbar kennzeichnen
mc2e25_skip	rts






