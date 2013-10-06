

TESTACTF	equ	0



		text


testActionFields
		movea.l	playerDataPtr,a6
		tst.w	PDHEALTH(a6)
		bmi.s	tafOut

		bsr.s	testThings
; todo		bsr	testLeftThings
; todo		bsr	testThingsSamples
; todo		bsr	testTrainsSamples

		lea	keytable,a1
		move.w	keyoverlay+KOACTION,d0
		tst.b	(a1,d0.w)
		beq.s	tafOut

		clr.b	(a1,d0.w)

		bsr	testActionDoor
		bsr	testActionLift
; todo		bsr	testActionSwitch

tafOut
		rts


; ---------------------------------------------------------
; 30.07.00/vk
; testet die gegenstaende des sektors, ob diese aufgenommen wurden.
; ruft die entsprechenden unterroutinen zur weiterverarbeitung
; des gegenstandes auf.
testThings
		movea.l	levelPtr,a6
		movea.l	playerDataPtr,a4
		move.w	PDCURRENTSECTOR(a4),d0		; aktuelle sektornummer
		movea.l	LEVSECSTART(a6,d0.w*4),a3
		adda.l	a6,a3				; a3 = zeiger auf aktuellen sektor
		move.l	SECTHINGS(a3),d0
		beq.s	ttOut
		movea.l	d0,a5
		adda.l	a6,a5
ttLoop
		move.l	(a5)+,d1
		beq.s	ttLoop
		bmi.s	ttOut
		movea.l	d1,a0
		adda.l	a6,a0

		tst.w	THINGTYPE(a0)
		bmi.s	ttSkip
		beq.s	ttSkip

; todo test		move.w	#TSCANNER,THINGTYPE(a0)

		movem.l	a5-a6,-(sp)
		bsr	testThingOneThing
		movem.l	(sp)+,a5-a6
ttSkip
		bra.s	ttLoop
ttOut
		rts


; ---------------------------------------------------------
; 30.07.00/vk
; testet einen gegenstand und ruft die entsprechenden
; routinen auf.
; a0 = pointer gegenstand
testThingOneThing
		move.w	THINGBREITE(a0),d2
		ext.l	d2

		movea.l	playerDataPtr,a4

		move.l	THINGLINE(a0),d0		; tx
		move.l	THINGLINE+4(a0),d1		; ty
		sub.l	PDSX(a4),d0
		bpl.s	ttotDxPos
		neg.l	d0
ttotDxPos	cmp.l	d2,d0
		bgt.s	ttotOut

		sub.l	PDSY(a4),d1
		bpl.s	ttotDyPos
		neg.l	d1
ttotDyPos	cmp.l	d2,d1
		bgt.s	ttotOut

	; befinden uns innerhalb des aufnahmeradiusº

		move.w	THINGTYPE(a0),d0
		beq.s	ttotOut
		bmi.s	ttotOut

		lea	things,a1
		movea.l	(a1,d0.w*4),a1
		move.l	THGROUT(a1),d1
		beq.s	ttotOut
		movea.l	d1,a2
		jsr	(a2)

		tst.w	THINGTYPE(a0)
		bpl.s	ttotOut				; dann auch keinen sound

		lea	things,a1
		movea.l	(a1,d0.w*4),a1
		move.w	THGSAMPLE(a1),d0
		cmpi.w	#-1,d0				; samplewert gueltig?
		beq.s	ttotOut
		moveq	#0,d1
; todo		bsr	initSam

ttotOut
		rts


; ---------------------------------------------------------
; steuert die bewegung der tueren
; spieleraktion: tuer oeffnen und schliessen
testActionDoor
		movea.l	levelPtr,a2
		movea.l	playerDataPtr,a4
		move.w	PDCURRENTSECTOR(a4),d0
		movea.l	LEVSECSTART(a2,d0.w*4),a3
		adda.l	a2,a3
		move.l	SECDOORS(a3),d0
		beq.s	tadOut				; keine tueren vorhanden -> raus
		movea.l	d0,a5
		adda.l	a2,a5

		bsr.s	testActionDoorOneSector

tadOut
		rts


; ---------------------------------------------------------
; tueren eines sektors testen
; a2 = levelPtr
; a4 = playerDataPtr
; a5 = (absoluter) pointer auf tuerpointer
testActionDoorOneSector

tadosLoop
		move.l	(a5)+,d1
		beq.s	tadosLoop
		bmi	tadosOut

		add.l	a2,d1
		lea	interPtr,a0
		add.l	#DOOROPSEC,d1
		move.l	d1,(a0)+
		addq.l	#8,d1
		move.l	d1,(a0)+
		addq.l	#8,d1
		move.l	d1,(a0)+
		addq.l	#8,d1
		move.l	d1,(a0)

		lea	PDSX(a4),a1
		movem.l	a2/a4-a5,-(sp)
		bsr	testIfInsideOneSquare		; eingabe: a1,interPtr
		movem.l	(sp)+,a2/a4-a5
		tst.w	d0				; innerhalb?
		bmi.s	tadosLoop			; nein -> auf zur naechsten tuer

		movea.l	-4(a5),a0			; (rel.) pointer auf diese tuer nochmals holen
		adda.l	a2,a0				; und absolut machen
		move.w	DOORNEEDTHING(a0),d7		; gegenstand zum oeffnen notwendig?
		beq.s	tadosCanOpen			; nein -> kann geoeffnet werden

		move.w	d7,d0				; diesen gegenstand
		bsr	hasPlayerThing			; besitzt ihn der spieler?
		tst.w	d0				; <>0: ja
		bne.s	tadosCanOpen			; dann koennen wir oeffnen

		bra.s	tadosCanOpen	; todo

		move.w	d7,-(sp)
; todo		movem.l	DOORPTR(a0),d0-d1
; todo		moveq	#SNDDOORLOCKED,d2
; todo		bsr	init_sam_dist
		move.w	(sp)+,d7

		lea	things,a2
		movea.l	(a2,d7.w*4),a2
		move.l	THGNEEDTXT(a2),a0
		bsr	installMessage
		bra.s	tadosOut

tadosCanOpen
		move.w	DOORSTATUS(a0),d0
		btst	#0,d0
		beq.s	tadosDoorIsClosed

	; tuer ist offen und soll geschlossen werden

		move.w	#%101,DOORSTATUS(a0)
		bsr.s	insertDoorAnimation

		movem.l	DOORPTS(a0),d0-d1
		moveq	#SNDDOORCLOSE,d2
; todo		bsr	initSamDist
		bra.s	tadosOut

tadosDoorIsClosed

	; tuer ist geschlossen und soll geoeffnet werden

		move.w	#%10,DOORSTATUS(a0)
		bsr.s	insertDoorAnimation

		movem.l	DOORPTS(a0),d0-d1
		moveq	#SNDDOOROPEN,d2
; todo		bsr	initSamDist

tadosOut
		rts


; ---------------------------------------------------------
; tuerpointer in die animationsliste eintragen
; dazu den absoluten pointer in einen relativen umwandeln
; a0 = absoluter tuerpointer (darf nicht geaendert werden)
insertDoorAnimation
		movea.l	a0,a1
		sub.l	levelPtr,a1			; a1 = relativer pointer

		lea	adData,a2			; animationsliste
		moveq	#ANIMATEDOORSMAX-1,d0
idaFindLoop	tst.w	ADFLAG(a2)			; hier ein eintrag vorhanden?
		beq.s	idaFindSkip			; nein -> dann ab zum naechsten
		cmpa.l	ADRELPOINTER(a2),a1		; pointer hier schon vorhanden?
		beq.s	idaOut				; ja -> dann raus
idaFindSkip	addq.l	#ADBYTES,a2
		dbra	d0,idaFindLoop

		lea	adData,a2			; animationsliste
		moveq	#ANIMATEDOORSMAX-1,d0
idaLoop		tst.w	ADFLAG(a2)
		beq.s	idaFoundFree
		addq.l	#ADBYTES,a2
		dbra	d0,idaLoop

		lea	adData,a2			; kein platz frei -> ersten pointer ueberschreiben
idaFoundFree
		move.w	#1,ADFLAG(a2)
		move.l	a1,ADRELPOINTER(a2)
idaOut
		rts



; ---------------------------------------------------------
; steuert die bewegung der lifte
; spieleraktion: lift nach oben und unten
testActionLift
		movea.l	levelPtr,a2
		movea.l	playerDataPtr,a4
		move.w	PDCURRENTSECTOR(a4),d0
		movea.l	LEVSECSTART(a2,d0.w*4),a3
		adda.l	a2,a3
		move.l	SECLIFT(a3),d0
		beq.s	talOut
		movea.l	d0,a5
		adda.l	a2,a5

		bsr	testActionLiftOneSector

talOut
		rts


; ---------------------------------------------------------
; lift des sektor testen
; a2 = levelPtr
; a4 = playerDataPtr
; a5 = (absoluter) pointer auf lift
testActionLiftOneSector

		move.w	LIFTNEEDTHING(a5),d7
		beq.s	talosCanOpen

		move.w	d7,d0
		bsr	hasPlayerThing
		tst.w	d0
		bne.s	talosCanOpen

		move.w	d7,-(sp)
; todo		movem.l	LIFTPTS(a5),d0-d1
; todo		moveq	#SNDDOORLOCKED,d2
; todo		bsr	init_sam_dist
		move.w	(sp)+,d7

		lea	things,a2
		movea.l	(a2,d7.w*4),a2
		movea.l	THGNEEDTXT(a2),a0
		bsr	installMessage
		bra	talosOut

talosCanOpen
		lea	interPtr,a0
		lea	LIFTOPSEC(a5),a3
		move.l	a3,(a0)+
		addq.l	#8,a3
		move.l	a3,(a0)+
		addq.l	#8,a3
		move.l	a3,(a0)+
		addq.l	#8,a3
		move.l	a3,(a0)

		lea	PDSX(a4),a1
		movem.l	a2/a4-a5,-(sp)
		bsr	testIfInsideOneSquare
		movem.l	(sp)+,a2/a4-a5
		tst.w	d0
		bmi.s	talosOut

		move.w	LIFTSTATUS(a5),d0
		btst	#0,d0
		beq.s	talosLiftIsDown

	; lift ist oben und soll nach unten

		move.w	#%101,LIFTSTATUS(a5)
		bsr	insertLiftAnimation

		movem.l	LIFTPTS(a5),d0-d1
		moveq	#SNDLIFTCLOSE,d2
; todo		bsr	initSamDist
		bra.s	talosOut

talosLiftIsDown

	; lift ist unten und soll nach oben

		move.w	#%10,LIFTSTATUS(a5)
		bsr	insertLiftAnimation

		movem.l	LIFTPTS(a5),d0-d1
		moveq	#SNDLIFTOPEN,d2
; todo		bsr	initSamDist

talosOut
		rts		


; ---------------------------------------------------------
; liftpointer in die animationslisten eintragen
; dazu den absoluten pointer in einen relativen umwandeln
; a5 = absoluter tuerpointer (darf nicht geaendert werden)
insertLiftAnimation
		movea.l	a5,a1
		sub.l	levelPtr,a1			; a1 = relativer pointer

		lea	alData,a2			; animationsliste
		moveq	#ANIMATELIFTSMAX-1,d0
ilaFindLoop	tst.w	ALFLAG(a2)			; hier ein eintrag vorhanden?
		beq.s	ilaFindSkip			; nein -> dann ab zum naechsten
		cmpa.l	ALRELPOINTER(a2),a1		; pointer hier schon vorhanden?
		beq.s	ilaOut				; ja -> dann raus
ilaFindSkip	addq.l	#ALBYTES,a2
		dbra	d0,ilaFindLoop

		lea	alData,a2			; animationsliste
		moveq	#ANIMATELIFTSMAX-1,d0
ilaLoop		tst.w	ALFLAG(a2)
		beq.s	ilaFoundFree
		addq.l	#ALBYTES,a2
		dbra	d0,ilaLoop

		lea	alData,a2			; kein platz frei -> ersten pointer ueberschreiben
ilaFoundFree
		move.w	#1,ALFLAG(a2)
		move.l	a1,ALRELPOINTER(a2)
ilaOut
		rts















		ifne TESTACTF


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


		endc