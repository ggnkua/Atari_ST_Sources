;**************************************
;* test_action_fld
;**************************************

test_action_fld:
                movea.l play_dat_ptr,A6
                tst.w   pd_health(A6)
                bmi.s   no_action_space

                bsr     test_act_things
		bsr	test_things_samples
		bsr	test_zuege_samples

		tst.w	menue_flag
		bne.s	no_action_space
                tst.b   keytable+$0039
                beq.s   no_action_space

                clr.b   keytable+$0039

                bsr.s   test_act_door
                bsr     test_act_lift
		bsr	test_act_schalter

no_action_space:

                rts


;**************************************
;* test_act_door
;**************************************

test_act_door
		movea.l	big_sector_ptr,a2
		movea.l	play_dat_ptr,a4
		move.w	pd_akt_sector(a4),d0
		movea.l	lev_sec_start(a2,d0.w*4),a3
		move.l	sec_doors(a3),d0
		beq.s	tad_no_doors

		movea.l	d0,a5
		bsr.s	test_act_doors_sec

tad_no_doors
		rts

;---------------

; a5 = zeiger auf tueren eines sektors

test_act_doors_sec

		move.l	(a5)+,d1
		beq.s	test_act_doors_sec
		bmi	tads_out

		lea	inter_ptr,a0
		add.l	#door_op_sec,d1
		move.l	d1,(a0)+		; pointer auf erste ecke
		addq.l	#8,d1
		move.l	d1,(a0)+
		addq.l	#8,d1
		move.l	d1,(a0)+
		addq.l	#8,d1
		move.l	d1,(a0)+

		bsr	intersect_fouredge

		cmpi.w	#1,schnitt_anz
		bne.s	test_act_doors_sec

		movea.l	-4(a5),a0		; jetzt nachschauen, ob
		move.w	door_need_thing(a0),d7	; tuer bewegt werden darf ...
		beq.s	tads_can_open

		movea.l	play_dat_ptr,a2
		movea.l	pd_things_ptr(a2),a2
		tst.w	-4(a2,d7.w*4)
		bne.s	tads_can_open

		movem.l	d0-d2/a0,-(sp)
		movem.l	door_pts(a1),d0-d1
		moveq	#snd_door_locked,d2
		bsr	init_sam_dist
		lea	need_things_ptr,a2
		movea.l	-4(a2,d7.w*4),a0
		bsr	install_message
		movem.l	(sp)+,d0-d2/a0

		rts

tads_can_open
		move.w	door_status(a0),d0
		btst	#0,d0
		beq.s	tads_d_geschl

	; tuer ist offen und soll geschlossen werden ...

		move.w	#%101,door_status(a0)
		bsr.s	door_to_anim

		movem.l	door_pts(a0),d0-d1
		moveq	#snd_door_close,d2
		bsr	init_sam_dist

		rts

tads_d_geschl

	; tuer ist geschlossen und soll geoeffnet werden ...

		move.w	#%10,door_status(a0)
		bsr.s	door_to_anim

		movem.l	door_pts(a0),d0-d1
		moveq	#snd_door_close,d2
		bsr	init_sam_dist

tads_out

		rts


;---------------

; traegt den tuerpointer in die animationsliste ein ...

door_to_anim
		move.w	an_doors_flag,d0
		beq.s	dta_no_door

	; es sind bereits zu animierende tueren vorhanden ...

		moveq	#0,d2
		lea	an_doors_ptr,a1
		moveq	#anim_doors_max-1,d1
dta_find_loop
		btst	d2,d0
		beq.s	dta_not_in
		cmpa.l	(a1),a0
		bne.s	dta_not_in
		rts
dta_not_in
		addq.w	#1,d2
		addq.l	#4,a1
		dbra	d1,dta_find_loop

	; jetzt einen freien eintrag suchen ...

		moveq	#0,d1
dta_find_free
		btst	d1,d0
		beq.s	dta_found_free
		addq.w	#1,d1
		cmpi.w	#anim_doors_max,d1
		blt.s	dta_find_free

	; kein eintrag frei, also einfach den ersten ueberschreiben ...

		move.l	a0,an_doors_ptr

		rts

dta_found_free
		bset	d1,d0
		move.w	d0,an_doors_flag
		lea	an_doors_ptr,a1
		move.l	a0,(a1,d1.w*4)

		rts

dta_no_door

	; keine tuer vorhanden, also einfach den ersten eintrag nehmen ...

		move.w	#%1,an_doors_flag
		move.l	a0,an_doors_ptr

		rts


;-----------------------

test_act_lift:
                movea.l big_sector_ptr,A2
                adda.l  #lev_sec_start,A2

                movea.l play_dat_ptr,A4
                move.w  pd_akt_sector(A4),D0
                lsl.w   #2,D0
                movea.l 0(A2,D0.w),A3
                move.l  sec_lift(A3),D0
                beq.s   test_a_no_l

                movea.l D0,A5
                bsr.s   test_act_lift_sec

test_a_no_l:
                rts

;---------------

; a5 = pointer lift

test_act_lift_sec

	;******************************

	; nachschauen, ob der lift ueberhaupt bewegt werden darf ...

		move.w	lift_need_thing(a5),d1
		beq.s	tals_can_open

		movea.l	play_dat_ptr,a2
		movea.l	pd_things_ptr(a2),a2
		tst.w	-4(a2,d1.w*4)
		bne.s	tals_can_open

	; jetzt entsprechende meldungen und samples ausgeben ...

		movem.l	d1/a5,-(sp)
		movem.l	lift_pts(a5),d0-d1
		moveq	#snd_lift_locked,d2
		bsr	init_sam_dist
		movem.l	(sp)+,d1/a5

		lea	need_things_ptr,a2
		movea.l	-4(a2,d1.w*4),a0
		bsr	install_message

		rts

tals_can_open

	;******************************

                move.l  A5,-(SP)

                lea     inter_ptr,A0
                adda.l  #lift_op_sec,A5
                move.l  A5,(A0)+                  ; pointer auf erste ecke
                addq.l  #8,A5
                move.l  A5,(A0)+
                addq.l  #8,A5
                move.l  A5,(A0)+
                addq.l  #8,A5
                move.l  A5,(A0)+

                bsr     intersect_fouredge

                movea.l (SP)+,A0

                cmpi.w  #1,schnitt_anz
                bne.s   test_act_l_sec_no

                move.w  lift_status(A0),D0
                btst    #0,D0
                beq.s   act_l_geschl

                move.w  #%0000000000000101,lift_status(A0)
                bsr.s   lift_to_anim

                movem.l lift_pts(A0),D0-D1
                moveq   #snd_lift_close,D2
                bsr     init_sam_dist

                rts

act_l_geschl:
                move.w  #%0000000000000010,lift_status(A0)
                bsr.s   lift_to_anim

                movem.l lift_pts(A0),D0-D1
                moveq   #snd_lift_open,D2
                bsr     init_sam_dist

test_act_l_sec_no:

                rts

;---------------

;*  traegt den liftpointer in die animationsliste ein ...

lift_to_anim:
                move.w  an_lifts_flag,D0
                beq.s   lta_no_lift

                moveq   #0,D2
                lea     an_lifts_ptr,A1
                moveq   #anim_lifts_max-1,D1
l_find_if_still:
                btst    D2,D0
                beq.s   not_in_lta
                cmpa.l  (A1),A0
                bne.s   not_in_lta
                rts
not_in_lta:
                addq.w  #1,D2
		addq.l	#4,a1
                dbra    D1,l_find_if_still

                moveq   #0,D1
find_lta_free:
                btst    D1,D0
                beq.s   lta_found_free

                addq.w  #1,D1
                cmpi.w  #anim_lifts_max,D1
                blt.s   find_lta_free

;*  kein Eintrag frei, also einfach den ersten ueberschreiben

                move.w  #$FFFF,an_lifts_flag
                move.l  A0,an_lifts_ptr

                rts

lta_found_free:
                bset    D1,D0
                move.w  D0,an_lifts_flag
                lea     an_lifts_ptr,A1
                lsl.w   #2,D1
                move.l  A0,0(A1,D1.w)

                rts

lta_no_lift:
                move.w  #%0000000000000001,an_lifts_flag
                move.l  A0,an_lifts_ptr

                rts

;**************************************
;* test_act_things
;**************************************

; teste alle gegenstaende in dem aktuellen sektor
; sowie die liegengelassenen gegenstaende der
; sichtbaren gegner ...

test_act_things

		bsr	tat_things
		bsr	tat_left_things

		rts

;---

; gegenstaende im aktuellen sektor

tat_things
		movea.l	big_sector_ptr,a2
		movea.l	play_dat_ptr,a4
		move.w	pd_akt_sector(a4),d0
		movea.l	lev_sec_start(a2,d0.w*4),a3
		move.l	sec_things(a3),d0
		beq.s	tatt_out
		movea.l	d0,a5

tatt_loop
		move.l	(a5)+,d1
		beq.s	tatt_loop
		bmi.s	tatt_out
		movea.l	d1,a0

		tst.w	thing_type(a0)
		bmi.s	tatt_skip
		beq.s	tatt_skip

		move.l	a5,-(sp)
		bsr	test_one_thing
		movea.l	(sp)+,a5
tatt_skip
		bra.s	tatt_loop

tatt_out
		rts

;--------------------------------------

tat_left_things

		move.w	mon_buf2_anz,d7
		bmi.s	tatlt_out
		movea.l	mon_buf2_ptr,a5

tatlt_loop
		movea.l	(a5)+,a0		; a0 = pointer gegner
		tst.w	mon_a_died(a0)		; schon gestorben ?
		beq.s	tatlt_skip		; wenn nein, dann raus ...

		move.l	mon_thing_typ(a0),d0	; pointer gegenstand holen
		beq.s	tatlt_skip		; ueberhaupt vorhanden ?
		movea.l	d0,a0			; a0 = pointer gegenstand

		movem.l	d7/a5,-(sp)
		bsr	test_one_thing
		movem.l	(sp)+,d7/a5
tatlt_skip
		dbra	d7,tatlt_loop

tatlt_out
		rts

;--------------------------------------

; testet einen gegenstand, ruft die routinen auf ...

; a0 = pointer gegenstand

test_one_thing

		move.w	thing_breite(a0),d2
		ext.l	d2

		movem.l	thing_line(a0),d0-d1	; tx/ty
		sub.l	sx_test,d0
		bpl.s	tot_xdif_pos
		neg.l	d0
tot_xdif_pos	cmp.l	d2,d0
		bgt.s	tot_out

		sub.l	sy_test,d1
		bpl.s	tot_ydif_ok
		neg.l	d1
tot_ydif_ok	cmp.l	d2,d1
		bgt.s	tot_out

		move.w	thing_type(a0),d0
		beq.s	tot_out
		bmi.s	tot_out
		move.w	#1,plf_things
		lea	things_routs,a1
		move.l	-4(a1,d0.w*4),d1
		beq.s	tot_out			; nullpointer ?
		movea.l	d1,a2
		jsr	(a2)

		move.w	thing_type(a0),d0	; wenn nicht aufgenommen,
		bpl.s	tot_out			; dann auch keinen sound

		move.l	a0,-(sp)
		lea	things_samples,a1
		neg.w	d0
		move.w	-2(a1,d0.w*2),d0
		cmpi.w	#-1,d0
		beq.s	tot_no_sam
		moveq	#0,d1
		bsr	init_sam
tot_no_sam	move.l	(sp)+,a0

tot_out
		rts


;**************************************
;* test_act_schalter
;**************************************

test_act_schalter

		movea.l	big_sector_ptr,a2
		adda.w	#lev_sec_start,a2

		movea.l	play_dat_ptr,a4
		move.w	pd_akt_sector(a4),d0
		movea.l	(a2,d0.w*4),a3
		move.l	sec_schalter(a3),d0
		beq.s	tas_out

		movea.l	d0,a5

tas_loop
		move.l	(a5)+,d1
		beq.s	tas_loop
		bmi.s	tas_out
		
		movea.l	d1,a0
		move.l	a5,-(sp)
		bsr	test_one_schalter
		movea.l	(sp)+,a5
		bra.s	tas_loop

tas_out
		rts

;---

; testet einen schalter, ruft die routinen auf ...

; a0: pointer schalter
; a5: reserviert

test_one_schalter
		
	; ist sch_type negativ, dann wurde der schalterzyklus
	; bereits einmal durchlaufen und der schalter soll
	; nicht geloopt werden, also dann raus ...

		tst.w	sch_type(a0)
		bmi	tos_out

		movem.l	sch_line(a0),d0-d3
		add.l	d2,d0
		add.l	d3,d1
		asr.l	#1,d0
		asr.l	#1,d1

	; ist sch_breite gleich null, so kann der schalter
	; nicht aktiviert werden ...

		move.w	sch_breite(a0),d2
		beq	tos_out
		ext.l	d2

		sub.l	sx_test,d0
		bpl.s	tos_xdif_pos
		neg.l	d0
tos_xdif_pos	cmp.l	d2,d0
		bgt	tos_out

		sub.l	sy_test,d1
		bpl.s	tos_ydif_ok
		neg.l	d1
tos_ydif_ok	cmp.l	d2,d1
		bgt	tos_out

	; ok - der schalter ist aktiviert worden

		tst.w	sch_zustand_anz(a0)
		beq	tos_einfacher_schalter

	; wir haben einen schalter mit mehreren zustaenden

	; jetzt einen zustand heraufzaehlen

		move.w	sch_zustand(a0),d0
		addq.w	#1,d0
		cmp.w	sch_zustand_anz(a0),d0
		blt.s	tosm_anz_ok
		moveq	#0,d0

	; soll der schalter nicht geloopt werden, dann
	; sch_type negieren ...

		tst.w	sch_loopflag(a0)
		bne.s	tosm_anz_ok
		neg.w	sch_type(a0)

tosm_anz_ok	move.w	d0,sch_zustand(a0)

	; schalter (grafik) animieren ...

		movea.l	sch_animation(a0),a1
		movea.l	animation_data(a1),a2
		move.w	2(a2,d0.w*4),sch_line+8+18(a0)
		move.b	1(a2,d0.w*4),sch_line+8+9(a0)

	; jetzt virtuellen gegenstand erzeugen

		bsr	tos_create_thing

		lea	sch_action_ptr(a0),a2
		movea.l	(a2,d0.w*4),a2

	; type kopieren

		move.w	(a2)+,d0
		move.w	d0,thing_type(a1)

	; optionales argument kopieren
	; hier maximal 128 bytes ...

		lea	thing_action(a1),a3
		moveq	#15,d1
tosm_copy_opt	move.l	(a2)+,(a3)+
		move.l	(a2)+,(a3)+
		dbra	d1,tosm_copy_opt

	; jetzt fuer den neu erzeugten gegenstand die routine aufrufen

tos_einfach_ok
		movem.l	a0/a5,-(sp)
		movea.l	a1,a0
		move.w	thing_type(a0),d0
		beq.s	tos_routs_null
		bmi.s	tos_routs_null
		move.w	#1,plf_things
		lea	things_routs,a1
		move.l	-4(a1,d0.w*4),d1
		beq.s	tos_routs_null		; nullpointer ?
		movea.l	d1,a2
		move.w	d0,-(sp)
		jsr	(a2)
		move.w	(sp)+,d0
tos_routs_null	movem.l	(sp)+,a0/a5

		tst.w	sch_sample(a0)
		beq.s	tos_normal_sample

		move.l	a0,-(sp)
		move.w	sch_sample(a0),d0
		moveq	#0,d1
		bsr	init_sam
		movea.l	(sp)+,a0

		bra.s	tos_out

tos_normal_sample

		lea	things_samples,a1
		move.w	-2(a1,d0.w*2),d0
		cmpi.w	#-1,d0
		beq.s	tos_out

		move.l	a0,-(sp)
		move.w	#snd_schalter,d0
		moveq	#0,d1
		bsr	init_sam
		movea.l	(sp)+,a0

tos_out
		rts

;---

tos_einfacher_schalter

		bsr	tos_create_thing

	; optionales argument kopieren
	; hier maximal 128 bytes ...

		lea	sch_action_ptr(a0),a2
		lea	thing_action(a1),a3
		moveq	#15,d1
tos_copy_opt	move.l	(a2)+,(a3)+
		move.l	(a2)+,(a3)+
		dbra	d1,tos_copy_opt

		bra.s	tos_einfach_ok

;---

; a0: pointer schalter

tos_create_thing
		
		lea	tos_thing(pc),a1

		movem.l	sch_line(a0),d1-d7
		add.l	d1,d3
		add.l	d2,d4
		asr.l	#1,d3
		asr.l	#1,d4
		movem.l	d3-d7,thing_line(a1)

		move.w	sch_breite(a0),thing_breite(a1)
		move.w	sch_type(a0),thing_type(a1)

		rts

;---

tos_thing	ds.b	256
		even


;--------------------------------------

; konzept: trage die hoerbaren samples in eine
; liste ein, diese wird also mit jedem bilddurchlauf
; aktualisiert. ein zweites durchgehen entfernt
; nicht mehr hoerbare (sichtbare) samples ...

test_things_samples

	; hoerbare (sichtbare) samples eintragen

		bsr	tts_neue_eintragen

	; nicht mehr hoerbare samples entfernen

		bsr.s	tts_alte_entfernen

	; und dann hoerbar machen ...

		bsr.s	tts_make_sound

		rts

;--------------------------------------

tts_make_sound

		moveq	#tts_anz-1,d7
		lea	tts_pointer,a0
ttsms_loop	move.l	(a0)+,d1
		beq.s	ttsms_skip
		movem.l	d7/a0,-(sp)
		movea.l	d1,a1
		movem.l	thing_line(a1),d0-d1
		move.w	thing_sample(a1),d2
		jsr	init_sam_dist_ndl
		movem.l	(sp)+,d7/a0
ttsms_skip
		dbra	d7,ttsms_loop

		rts


;--------------------------------------

tts_alte_entfernen

	; schritt 1: aufstellen einer linearen liste
	; mit den nummern aller sektoren, die sichtbar sind

		lea	tts_visible,a0
		movea.l	big_sector_ptr,a1
		movea.l	play_dat_ptr,a2
		move.w	pd_akt_sector(a2),d0
		move.w	d0,(a0)+
		movea.l	lev_sec_start(a1,d0.w*4),a3
		lea	sec_ext_lines(a3),a3
ttsae_loop	move.w	(a3)+,(a0)+
		bpl.s	ttsae_loop

	; schritt 2: jeden sampleplatz darauf ueberpruefen,
	; ob die sektornummer des samples ueberhaupt in
	; der liste der sichtbaren sektoren vorhanden ist

		lea	tts_visible,a0		; pointer auf sichtbare sektoren
		lea	tts_pointer,a1		; pointer fuer samples
		moveq	#tts_anz-1,d0		; anzahl samplepointer
ttsae_loop2	tst.l	(a1)+			; ein sample hier vorhanden?
		beq.s	ttsae_skip		; wenn nein -> skip
		move.w	tts_anz*4-4(a1),d1	; sektornummer des samples holen
		movea.l	a0,a2			; eigener pointer auf sichtb. sektoren
ttsae_iloop	move.w	(a2)+,d2		; naechsten sichtbaren sektor holen
		bmi.s	ttsae_delete		; listenende erreicht -> loeschen
		cmp.w	d2,d1			; vergleichen
		beq.s	ttsae_skip		; wenn gleich -> vorhanden -> skip
		bra.s	ttsae_iloop		; und weitermachen
ttsae_delete	movem.l	a6/d0,-(sp)
		movea.l	-4(a1),a6		; sampleadresse holen
		clr.l	-4(a1)			; sampleplatz loeschen
		move.w	thing_sample(a6),d0
		jsr	init_sam_delete
		movem.l	(sp)+,a6/d0
ttsae_skip	dbra	d0,ttsae_loop2		; loop fuer alle sampleplaetze

		rts


;--------------------------------------

tts_neue_eintragen

		movea.l	big_sector_ptr,a0
		movea.l	play_dat_ptr,a1
		move.w	pd_akt_sector(a1),d0
		movea.l	lev_sec_start(a0,d0.w*4),a2

	; zuerst mit dem aktuellen sektor ...

		movem.l	a0-a2,-(sp)
		bsr.s	ttsne_sektor
		movem.l	(sp)+,a0-a2		

	; ... danach mit allen anderen sichtbaren!

		lea	sec_ext_lines(a2),a3
ttsne_loop	move.w	(a3)+,d0
		bmi.s	ttsne_out
		movea.l	lev_sec_start(a0,d0.w*4),a2
		movem.l	a0/a3,-(sp)
		bsr.s	ttsne_sektor
		movem.l	(sp)+,a0/a3
		bra.s	ttsne_loop

ttsne_out
		rts


;---------------

; a2 = pointer auf sektor
; a0 = big_sector_ptr
; d0 = sektornummer

ttsne_sektor
		move.l	sec_things(a2),d1	; pointer auf gegenstaende testen
		beq	ttsnes_out		; keine gegenstaende da -> raus
		movea.l	d1,a1
ttsnes_loop	move.l	(a1)+,d1		; pointer fuer naechsten gegenst. holen
		beq.s	ttsnes_loop		; nicht vorhanden -> zum naechsten
		bmi.s	ttsnes_out		; kennzeichen ende -> raus
		movea.l	d1,a2
		tst.w	thing_type(a2)
		bmi.s	ttsnes_loop
		move.w	thing_sample(a2),d1	; sample vorhanden?
		cmpi.w	#-1,d1			; -1 = kein sample
		beq.s	ttsnes_loop		; wenn so -> raus
		bsr.s	ttsnes_eintragen	; sample eintragen
		bra.s	ttsnes_loop		; und zum schleifenanfang
ttsnes_out
		rts

;---------------

; d0 = sektornummer
; a2 = pointer auf gegenstand
; a1 = besetzt

ttsnes_eintragen

	; schritt 1: alle plaetze durchgehen, ob
	; gegenstand schon vorhanden ist ...

		moveq	#tts_anz-1,d1
		lea	tts_pointer,a3
ttsnese_loop	cmpa.l	(a3)+,a2
		beq.s	ttsnese_out
		dbra	d1,ttsnese_loop

	; schritt 2: einen freien platz suchen ...

		moveq	#tts_anz-1,d1
		lea	tts_pointer,a3
ttsnese_loop2	tst.l	(a3)+
		beq.s	ttsnese_found_free
		dbra	d1,ttsnese_loop2

	; schritt 3: keinen freien platz gefunden, also
	; einfach platz 0 ueberschreiben ...

		lea	tts_pointer+4,a3

ttsnese_found_free

		move.l	a2,-4(a3)
		move.w	d0,tts_anz*4-4(a3)

ttsnese_out
		rts



;--------------------------------------

tts_pointer	ds.l	tts_anz
		ds.w	tts_anz

tts_visible	ds.w	32


;**************************************
;* test_zuege_samples
;**************************************

test_zuege_samples

	; zug mit der geringsten entfernung raussuchen

		bsr	tzs_nearest
		bsr	tzs_make_sound

		rts

;--------------------------------------

tzs_make_sound
		cmpi.l	#$7fffffff,tzs_distance
		bne.s	tzs_now
		tst.w	tzs_flag
		beq	tzsms_out

		clr.w	tzs_flag
		move.w	#snd_ubahn,d0
		jsr	init_sam_delete
		bra.s	tzsms_out

tzs_now
		movem.l	tzs_position(pc),d0-d1
		move.w	#snd_ubahn,d2
		jsr	init_sam_dist_ndl

tzsms_out
		rts

;---------------

tzs_nearest
		lea	tzs_distance(pc),a1
		move.l	#$7fffffff,(a1)

		move.w	trains_visible,d7
		beq.s	tzsn_out

		movea.l	big_sector_ptr,a0
		movea.l	lev_trains(a0),a0
		movea.l	trn_data(a0),a0

		moveq	#0,d6
		move.w	max_trains,d5
		beq.s	tzsn_out
		subq.w	#1,d5
tzsn_loop	btst	d6,d7
		beq.s	tzsn_inaktiv

		movem.l	(a0),d0-d1
		movem.l	d5-d7/a0-a1,-(sp)
		jsr	calc_dist_to_player
		movem.l	(sp)+,d5-d7/a0-a1
		cmp.l	(a1),d0
		bgt.s	tzsn_not_nearer
		move.l	d0,(a1)
		movem.l	(a0),d0-d1
		movem.l	d0-d1,tzs_position
		move.w	#1,tzs_flag
		move.w	d6,tzs_train_nb
tzsn_not_nearer	

tzsn_inaktiv	lea	td_data_length(a0),a0
		addq.w	#1,d6
		dbra	d5,tzsn_loop

tzsn_out
		rts

;---------------

tzs_distance	dc.l	0
tzs_flag	dc.w	0
tzs_position	dc.l	0,0
tzs_train_nb	dc.w	0


