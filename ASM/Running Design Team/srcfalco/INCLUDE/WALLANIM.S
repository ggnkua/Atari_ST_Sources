
;**************************************
;* wall_animation
;**************************************

; wall_animation versieht things oder schalter
; mit beliebigen animationen. die funktionalitaet
; der things bzw. schalter bleibt voll erhalten.
; zuerst werden alle sichtbaren things und schalter
; bestimmt, die sichtbar sind (sein koennen) - vorausgesetzt,
; dass der sektor gewechselt wurde. anschliessend
; werden diese things und schalter animiert.

; -> things
; -> schalter
; -> liegengel. things von gegnern (standard + midi)

wall_animation:

		bsr	wa_find_walls
		bsr.s	wa_animation

		rts


;**************************************
;* wa_animation
;**************************************

wa_animation:
		move.w	wall_anim_t_anz,d0
		bmi.s	waa_schalter

		lea	wall_anim_t_ptr,a0
waa_loop:
		move.l	(a0)+,a2		; a2 = thing
		move.l	thing_animation(a2),a1

		move.w	animation_count(a1),d1
		add.w	vbl_time,d1
		move.w	d1,animation_count(a1)
		cmp.w	animation_speed(a1),d1
		blt.s	waa_no_change

		clr.w	animation_count(a1)
		move.w	animation_pos(a1),d1
		addq.w	#1,d1
		cmp.w	animation_anz(a1),d1
		blt.s	waa_no_begin
		moveq	#0,d1
waa_no_begin:	move.w	d1,animation_pos(a1)

		movea.l	animation_data(a1),a3
		lsl.w	#2,d1
		move.w	2(a3,d1.w),thing_line+18(a2)
		move.b	1(a3,d1.w),thing_line+9(a2)
		
waa_no_change:
		dbra	d0,waa_loop

		; und jetzt alle
		; schalter animieren ...

waa_schalter:
		move.w	wall_anim_s_anz,d0
		bmi.s	waa_out

		lea	wall_anim_s_ptr,a0
waas_loop:
		move.l	(a0)+,a2		; a2 = schalter
		move.l	sch_animation(a2),a1

		move.w	animation_count(a1),d1
		add.w	vbl_time,d1
		move.w	d1,animation_count(a1)
		cmp.w	animation_speed(a1),d1
		blt.s	waas_no_change

		clr.w	animation_count(a1)
		move.w	animation_pos(a1),d1
		addq.w	#1,d1
		cmp.w	animation_anz(a1),d1
		blt.s	waas_no_begin
		moveq	#0,d1
waas_no_begin:	move.w	d1,animation_pos(a1)

		movea.l	animation_data(a1),a3
		lsl.w	#2,d1
		move.w	2(a3,d1.w),sch_line+26(a2)
		move.b	1(a3,d1.w),sch_line+17(a2)
		
waas_no_change:
		dbra	d0,waas_loop

waa_out:
		rts


;**************************************
;* wa_find_walls
;**************************************

; trage alle zu animierenden waende in
; einen speziellen buffer ein

wa_find_walls

	; (1) alle sektoren

		movea.l	play_dat_ptr,a0			; pointer auf spielerdaten
		move.w	pd_akt_sector(a0),d0		; aktueller sektor
		cmp.w	pd_wall_anim_sec(a0),d0		; wurde sektor zuletzt schon bearbeitet?
		beq	wafw_sector_out			; ja -> routine fuer sektoren ueberspringen

		move.w	d0,pd_wall_anim_sec(a0)		; sektor als bearbeitet kennzeichnen
		lea	wall_anim_s_ptr,a5		; pointer auf zu anim. switches
		lea	wall_anim_t_ptr,a6		; dito fuer things
		moveq	#-1,d1				; anzahl fuer things und switches
		move.l	d1,wall_anim_s_anz		; auf null setzen

		movea.l	big_sector_ptr,a1		; leveladresse holen
		movea.l	lev_sec_start(a1,d0.w*4),a2	; adresse akt. sektor holen
		move.l	a2,a3				; und duplizieren

		bsr	wafw_one_sector			; unterroutine fuer things
		bsr	wafw_s_one_sector		; unterroutine fuer schalter

		lea	sec_ext_lines(a2),a2		; andere sichtbare sektoren
wafw_loop
		move.w	(a2)+,d1			; naechster sektor
		bmi.s	wafw_sector_out			; ende erreicht? -> sektoren beenden
		movea.l	big_sector_ptr,a1		; leveladresse holen
		movea.l	lev_sec_start(a1,d1.w*4),a3	; adresse akt. sector holen
		bsr	wafw_one_sector			; unterroutine fuer things
		bsr	wafw_s_one_sector		; unterroutine fuer schalter
		bra.s	wafw_loop			; und loopen

wafw_sector_out

	; jetzt zuerst wieder die richtige
	; adresse zum eintragen bestimmen

		lea	wall_anim_t_ptr,a6
		move.w	wall_anim_t_anz,d4
		addq.w	#1,d4
		lea	(a6,d4.w*4),a6		; ab hier kann eingetragen werden

	; (2) alle standard-gegner

		move.w	mon_buf2_anz,d7		; anzahl standard-gegner
		bmi.s	wafw_no_monsters	; keine vorhanden -> ueberspringen
		movea.l	mon_buf2_ptr,a5		; pointer auf gegnerpointer

wafw_monst_loop
		movea.l	(a5)+,a4		; naechste gegneradresse
		tst.w	mon_a_died(a4)		; gegner noch am leben?
		beq.s	wafw_monst_skip		; ja -> gegner ueberspringen
		move.l	mon_thing_typ(a4),d1	; ex. liegengel. thing?
		beq.s	wafw_monst_skip		; nein -> gegner ueberspringen
		movea.l	d1,a4
		tst.l	thing_animation(a4)	; ex. animation fuer thing?
		beq.s	wafw_monst_skip		; nein -> gegner ueberspringen
		tst.w	thing_type(a4)		; thing schon aufgenommen?
		bmi.s	wafw_monst_skip		; ja -> gegner ueberspringen
		move.l	a4,(a6)+		; adresse thing eintragen
		addq.w	#1,wall_anim_t_anz	; und anzahl erhoehen
wafw_monst_skip
		dbra	d7,wafw_monst_loop	; bis alle (standard-) gegner bearbeitet sind
wafw_no_monsters

	; (3) alle midi-gegner

		ifne midiplay
		move.w	mmon_buf2_anz,d7	; anzahl midi-gegner
		bmi.s	wafw_no_mmonsters	; keine vorhanden -> ueberspringen
		movea.l	mmon_buf2_ptr,a5	; pointer auf midi-gegnerpointer

wafw_mmonst_loop
		movea.l	(a5)+,a4		; naechste gegneradresse
		tst.w	mon_a_died(a4)		; gegner noch am leben?
		beq.s	wafw_mmonst_skip	; ja -> gegner ueberspringen
		move.l	mon_thing_typ(a4),d1	; ex. liegengel. thing?
		beq.s	wafw_mmonst_skip	; nein -> gegner ueberspringen
		movea.l	d1,a4
		tst.l	thing_animation(a4)	; ex. animation fuer thing?
		beq.s	wafw_mmonst_skip	; nein -> gegner ueberspringen
		tst.w	thing_type(a4)		; thing schon aufgenommen?
		bmi.s	wafw_mmonst_skip	; ja -> gegner ueberspringen
		move.l	a4,(a6)+		; adresse thing eintragen
		addq.w	#1,wall_anim_t_anz	; und anzahl erhoehen
wafw_mmonst_skip
		dbra	d7,wafw_mmonst_loop	; bis alle (standard-) gegner bearbeitet sind
wafw_no_mmonsters
		endc
wafw_out
		rts


;**************************************
;* wafw_one_sector
;**************************************

wafw_one_sector:

		move.l	a3,-(sp)
		move.l	sec_things(a3),d2
		beq.s	wafwos_out

		move.l	d2,a3
wafwos_loop:
		move.l	(a3)+,d2
		beq.s	wafwos_no_thing
		bmi.s	wafwos_out
		move.l	d2,a4
		tst.l	thing_animation(a4)
		beq.s	wafwos_no_thing
		tst.w	thing_type(a4)
		bmi.s	wafwos_no_thing

		move.l	a4,(a6)+
		addq.w	#1,wall_anim_t_anz

wafwos_no_thing:
		bra.s	wafwos_loop

wafwos_out:
		move.l	(sp)+,a3
		rts


;**************************************
;* wafw_s_one_sector
;**************************************

wafw_s_one_sector:

		move.l	sec_schalter(a3),d2
		beq.s	wafwsos_out

		move.l	d2,a3
wafwsos_loop:
		move.l	(a3)+,d2
		beq.s	wafwsos_no_thing
		bmi.s	wafwsos_out
		move.l	d2,a4
		tst.l	sch_animation(a4)
		beq.s	wafwsos_no_thing
		tst.w	sch_zustand_anz(a4)
		bne.s	wafwsos_no_thing
		move.l	a4,(a5)+
		addq.w	#1,wall_anim_s_anz

wafwsos_no_thing:
		bra.s	wafwsos_loop

wafwsos_out:
		rts


