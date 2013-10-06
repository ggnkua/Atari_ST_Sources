
DSPCOMM		equ	0



MONSTERSPOINTSOFFSET	equ	C3PPOINTSMAX*2*4+C3PMONSTERSMAX*2*4
DOORSPOINTSOFFSET	equ	MONSTERSPOINTSOFFSET+C3PMONSTERSMAX*8*2
THINGSPOINTSOFFSET	equ	DOORSPOINTSOFFSET+C3PDOORSMAX*8*4+C3PTHINGSMAX*2*4
SWITCHESPOINTSOFFSET	equ	THINGSPOINTSOFFSET+C3PTHINGSMAX*4*4




		text




; ---------------------------------------------------------
; schicke alle 3d-daten in den dsp-bereich
dspSendAll
		bsr	dspResetOffsets
		bsr	dspSendPointsAndLines
;		bsr	dspSendTrains
		bsr	dspSendMonsters
		bsr	dspSendThings
;		bsr	dspSendMonLeftThings
		bsr	dspSendShoot				; todo
		bsr	dspSendSwitches
		bsr	dspSendDoors
		bsr	dspSendLifts

		rts


; ---------------------------------------------------------
; setzt die parameter fuer den himmel
dspSetSky
		rts


; ---------------------------------------------------------
; setzt alle notwendigen punktoffsets zurueck. notwendig,
; wenn ein neues bild dem dsp zur berechnung uebergeben
; wird. das offset fuer normale wandpunkte wird nicht
; hier, sondern in dspSendPointsAndLines geloescht, da dies
; auch die einzige routine ist, die es benoetigt.
dspResetOffsets
		lea	monstersPointsOffset,a1
		lea	doorsPointsOffset,a2
		lea	thingsPointsOffset,a3
		lea	switchesPointsOffset,a4

		move.l	#MONSTERSPOINTSOFFSET,(a1)+
		move.l	#DOORSPOINTSOFFSET,(a2)+
		move.l	#THINGSPOINTSOFFSET,(a3)+
		move.l	#SWITCHESPOINTSOFFSET,(a4)+

		move.l	#c3pMonstersAddFlags,(a1)+

		move.l	#c3pPointsMonsters,(a1)+
		move.l	#c3pPointsDoors,(a2)+
		move.l	#c3pPointsThings,(a3)+
		move.l	#c3pPointsSwitches,(a4)+

		move.l	#c3pLinesMonsters,(a1)+
		move.l	#c3pLinesDoors,(a2)+
		move.l	#c3pLinesThings,(a3)+
		move.l	#c3pLinesSwitches,(a4)+

		clr.w	c3pNbMonsters
		clr.w	c3pNbDoors
		clr.w	c3pNbThings
		clr.w	c3pNbSwitches

		rts


; ---------------------------------------------------------
; schicke alle punkte und linien normaler waende,
; wenn sich der aktuelle sektor geaendert hat.
dspSendPointsAndLines

		movea.l	levelPtr,a2
		lea	LEVSECSTART(a2),a2

	; die "normalen" punkte und linien nur dann rueberschicken, wenn sich der aktuelle standsektor
	; veraendert hat	

		movea.l	playerDataPtr,a4
		move.w	PDCURRENTSECTOR(a4),d0
		cmp.w	PDLASTSECTOR(a4),d0
		beq	dspspalOut

		move.w	d0,PDLASTSECTOR(a4)

		movea.l	(a2,d0.w*4),a3			; pointer sector (relativ)
		adda.l	levelPtr,a3			; absolut machen fuer naechsten zugriff

		movea.l	SECAKTION(a3),a4
		adda.l	levelPtr,a4
;		move.w	AKTIONVISIBLE(a4),trains_visible		; todo
		
		movea.l	SECPOINTS(a3),a0
		movea.l	SECLINES(a3),a1
		adda.l	levelPtr,a0
		adda.l	levelPtr,a1

		lea	c3pPoints,a5
		lea	c3pLines,a6

		clr.w	c3pNbPoints			; anzahl punkte und linien loeschen
		clr.w	c3pNbLines
		moveq	#0,d6				; offset fuer koordinatenindex loeschen (ist beim ersten sektor null)

		bsr.s	dspspalOneSector		; diesen einen sector uebertragen

		lea	SECEXTLINES(a3),a3
dspspalExtLoop
		move.w	(a3)+,d0			; weitere sichtbare sektornummern
		bmi.s	dspspalOut			; keine weiteren sichtbar -> raus

		movea.l	(a2,d0.w*4),a4
		adda.l	levelPtr,a4
		movea.l	SECPOINTS(a4),a0
		movea.l	SECLINES(a4),a1
		adda.l	levelPtr,a0
		adda.l	levelPtr,a1

		bsr.s	dspspalOneSector

		bra.s	dspspalExtLoop

dspspalOut
		rts


; --------------
; einen sector uebertragen
; a0 = punkte
; a1 = linien
; a2 belegt
; a3 belegt (extendedsectors)
; a5 = punktespeicher (wird fortlaufend beschrieben)
; a6 = linienspeicher (wird fortlaufend beschrieben)
; d6.l = point offset
; benutzte register: d0,d1,d5
dspspalOneSector
		move.l	(a0)+,d0			; anzahl koordinatenpaare
		move.l	d6,d5				; zwischenspeichern, d5 wird spaeter verwendet, d6 vorher upgedated
		add.w	d0,c3pNbPoints			; anzahl der punkte entsprechend erhoehen
		move.l	d0,d1
		lsl.l	#3,d1				; * 8
		add.l	d1,d6
		subq.w	#1,d0
		bmi.s	dspspalosOut			; keine punkte zu uebertragen -> auch keine linien

dspspalosPLoop
		move.l	(a0)+,(a5)+			; x
		move.l	(a0)+,(a5)+			; y
		dbra	d0,dspspalosPLoop

		move.l	(a1)+,d0			; anzahl linien
		add.w	d0,c3pNbLines			; anzahl eintragen
		subq.w	#1,d0
		bmi.s	dspspalosOut			; keine linien da -> raus

dspspalosLLoop
		move.l	(a1)+,(a6)
		add.l	d5,(a6)+
		move.l	(a1)+,(a6)
		add.l	d5,(a6)+
		move.l	(a1)+,(a6)+
		move.l	(a1)+,(a6)+
		move.l	(a1)+,(a6)+
		dbra	d0,dspspalosLLoop

dspspalosOut
		rts


; ---------------------------------------------------------
; alle (normal definierten) gegenstaende der sichtbaren
; sektoren senden
dspSendThings
		movea.l	levelPtr,a2
		move.l	a2,d7
		lea	LEVSECSTART(a2),a2
		movea.l	playerDataPtr,a1
		move.w	PDCURRENTSECTOR(a1),d0
		movea.l	(a2,d0.w*4),a3			; pointer sector (relativ)
		adda.l	d7,a3				; absolut machen fuer naechsten zugriff

		lea	thingsPointsOffset,a6
		move.l	(a6)+,d6
		move.l	(a6)+,a5			; c3pPointsThings+x
		move.l	(a6),a6				; c3pLinesThings+x

		move.l	SECTHINGS(a3),d0		; gegenstaende vorhanden?
		beq.s	dspstSkip			; nein -> (nur diesen) sektor ueberspringen
		movea.l	d0,a0
		adda.l	d7,a0
		bsr.s	dspstOneSector
dspstSkip
		lea	SECEXTLINES(a3),a3
dspstExtLoop
		move.w	(a3)+,d0			; weitere sichtbare sektornummern
		bmi.s	dspstOut			; keine weiteren sichtbar -> raus

		movea.l	(a2,d0.w*4),a4
		adda.l	d7,a4
		move.l	SECTHINGS(a4),d0
		beq.s	dspstExtLoop			; sektor ueberspringen
		movea.l	d0,a0
		adda.l	d7,a0
		bsr.s	dspstOneSector
		bra.s	dspstExtLoop
dspstOut
		lea	thingsPointsOffset,a4
		move.l	d6,(a4)+
		move.l	a5,(a4)+
		move.l	a6,(a4)

		rts


; --------------
; gegenstaende eines sektors uebertragen
; a0 = gegenstaende (pointer)
; a2 belegt
; a3 belegt (extendedsectors)
; a5 = punktespeicher (wird fortlaufend beschrieben)
; a6 = linienspeicher (wird fortlaufend beschrieben)
; d6.l = point offset
; d7.l = level offset
; benutzte register:
dspstOneSector
		move.l	(a0)+,d0
		beq.s	dspstOneSector
		bmi.s	dspstosOut
		movea.l	d0,a4
		adda.l	d7,a4

		tst.w	THINGTYPE(a4)		; nur senden, wenn noch nicht aufgenommen
		bmi.s	dspstOneSector
		
		move.w	THINGVISTAKEN(a4),d0	; muss ein gegenstand zur sichtbarkeit vorhanden sein?
		beq.s	dspstosNoTaken		; nein -> normal weiter
		bsr	hasPlayerThing
		tst.w	d0
		beq.s	dspstOneSector
dspstosNoTaken
		move.w	THINGVISACT(a4),d0
		beq.s	dspstosNoAct
		bsr	hasPlayerThingActivated
		tst.w	d0
		beq.s	dspstOneSector
dspstosNoAct		
		move.l	(a4)+,(a5)+		; punkte eintragen
		move.l	(a4)+,(a5)+
		move.l	d6,(a6)+		; point_1
		addq.w	#8,d6
		move.l	d6,(a6)+		; point_2
		addq.w	#8,d6
		move.l	(a4)+,(a6)+		; line_flag_1
		move.l	(a4)+,(a6)+		; line_flag_2
		move.l	(a4)+,(a6)+		; line_flag_3
		addq.w	#1,c3pNbThings

		bra.s	dspstOneSector
dspstosOut
		rts


; ---------------------------------------------------------
; alle schalter der sichtbaren sektoren senden
dspSendSwitches
		movea.l	levelPtr,a2
		move.l	a2,d7
		lea	LEVSECSTART(a2),a2
		movea.l	playerDataPtr,a1
		move.w	PDCURRENTSECTOR(a1),d0
		movea.l	(a2,d0.w*4),a3			; pointer sector (relativ)
		adda.l	d7,a3				; absolut machen fuer naechsten zugriff

		lea	switchesPointsOffset,a6
		move.l	(a6)+,d6
		move.l	(a6)+,a5			; c3pPointsSwitches+x
		move.l	(a6),a6				; c3pLinesSwitches+x

		move.l	SECSWITCHES(a3),d0		; schalter vorhanden?
		beq.s	dspssSkip			; nein -> (nur diesen) sektor ueberspringen
		movea.l	d0,a0
		adda.l	d7,a0
		bsr.s	dspssOneSector
dspssSkip
		lea	SECEXTLINES(a3),a3
dspssExtLoop
		move.w	(a3)+,d0			; weitere sichtbare sektornummern
		bmi.s	dspssOut			; keine weiteren sichtbar -> raus

		movea.l	(a2,d0.w*4),a4
		adda.l	d7,a4
		move.l	SECSWITCHES(a4),d0
		beq.s	dspssExtLoop			; sektor ueberspringen
		movea.l	d0,a0
		adda.l	d7,a0
		bsr.s	dspssOneSector
		bra.s	dspssExtLoop
dspssOut
		lea	switchesPointsOffset,a4
		move.l	d6,(a4)+
		move.l	a5,(a4)+
		move.l	a6,(a4)

		rts


; --------------
; schalter eines sektors uebertragen
; a0 = gegenstaende (pointer)
; a2 belegt
; a3 belegt (extendedsectors)
; a5 = punktespeicher (wird fortlaufend beschrieben)
; a6 = linienspeicher (wird fortlaufend beschrieben)
; d6.l = point offset
; d7.l = level offset
; benutzte register:
dspssOneSector
		move.l	(a0)+,d0
		beq.s	dspssOneSector
		bmi.s	dspssosOut
		movea.l	d0,a4
		adda.l	d7,a4
		
		move.w	SWITCHVISTAKEN(a4),d0	; muss ein gegenstand zur sichtbarkeit vorhanden sein?
		beq.s	dspssosNoTaken		; nein -> normal weiter
		bsr	hasPlayerThing
		tst.w	d0
		beq.s	dspssOneSector
dspssosNoTaken
		move.w	SWITCHVISACT(a4),d0
		beq.s	dspssosNoAct
		bsr	hasPlayerThingActivated
		tst.w	d0
		beq.s	dspssOneSector
dspssosNoAct		
		move.l	(a4)+,(a5)+		; punkte eintragen
		move.l	(a4)+,(a5)+
		move.l	(a4)+,(a5)+
		move.l	(a4)+,(a5)+
		move.l	d6,(a6)+		; point_1
		addq.w	#8,d6
		move.l	d6,(a6)+		; point_2
		addq.w	#8,d6
		move.l	(a4)+,(a6)+		; line_flag_1
		move.l	(a4)+,(a6)+		; line_flag_2
		move.l	(a4)+,(a6)+		; line_flag_3
		addq.w	#1,c3pNbSwitches

		bra.s	dspssOneSector
dspssosOut
		rts


; ---------------------------------------------------------
; alle tueren der sichtbaren sektoren senden
dspSendDoors
		movea.l	levelPtr,a2
		move.l	a2,d7
		lea	LEVSECSTART(a2),a2
		movea.l	playerDataPtr,a1
		move.w	PDCURRENTSECTOR(a1),d0
		movea.l	(a2,d0.w*4),a3			; pointer sector (relativ)
		adda.l	d7,a3				; absolut machen fuer naechsten zugriff

		lea	doorsPointsOffset,a6
		move.l	(a6)+,d6
		move.l	(a6)+,a5			; c3pPointsDoors+x
		move.l	(a6),a6				; c3pLinesDoors+x

		move.l	SECDOORS(a3),d0			; vorhanden?
		beq.s	dspsdSkip			; nein -> (nur diesen) sektor ueberspringen
		movea.l	d0,a0
		adda.l	d7,a0
		bsr.s	dspsdOneSector
dspsdSkip
		lea	SECEXTLINES(a3),a3
dspsdExtLoop
		move.w	(a3)+,d0			; weitere sichtbare sektornummern
		bmi.s	dspsdOut			; keine weiteren sichtbar -> raus

		movea.l	(a2,d0.w*4),a4
		adda.l	d7,a4
		move.l	SECDOORS(a4),d0
		beq.s	dspsdExtLoop			; sektor ueberspringen
		movea.l	d0,a0
		adda.l	d7,a0
		bsr.s	dspsdOneSector
		bra.s	dspsdExtLoop
dspsdOut
		lea	doorsPointsOffset,a4
		move.l	d6,(a4)+
		move.l	a5,(a4)+
		move.l	a6,(a4)

		rts


; --------------
; tueren eines sektors uebertragen
; a0 = tueren (pointer)
; a2 belegt
; a3 belegt (extendedsectors)
; a5 = punktespeicher (wird fortlaufend beschrieben)
; a6 = linienspeicher (wird fortlaufend beschrieben)
; d6.l = point offset
; d7.l = level offset
; benutzte register:
dspsdOneSector
		move.l	(a0)+,d0
		beq.s	dspsdOneSector
		bmi.s	dspsdosOut
		movea.l	d0,a4
		adda.l	d7,a4

		move.l	(a4)+,(a5)+		; punkte eintragen
		move.l	(a4)+,(a5)+
		move.l	(a4)+,(a5)+
		move.l	(a4)+,(a5)+
		move.l	(a4)+,(a5)+
		move.l	(a4)+,(a5)+
		move.l	(a4)+,(a5)+
		move.l	(a4)+,(a5)+

		moveq	#3,d5
dspsdosLoop	move.l	(a4)+,d4
		add.w	d6,d4
		move.l	d4,(a6)+		; point_1
		move.l	(a4)+,d4
		add.w	d6,d4
		move.l	d4,(a6)+		; point_2
		move.l	(a4)+,(a6)+		; line_flag_1
		move.l	(a4)+,(a6)+		; line_flag_2
		move.l	(a4)+,(a6)+		; line_flag_3
		dbra	d5,dspsdosLoop

		addi.l	#4*8,d6
		addq.w	#1,c3pNbDoors

		bra.s	dspsdOneSector
dspsdosOut
		rts


; ---------------------------------------------------------
; alle lifte der sichtbaren sektoren senden
dspSendLifts
		movea.l	levelPtr,a2
		move.l	a2,d7
		lea	LEVSECSTART(a2),a2
		movea.l	playerDataPtr,a1
		move.w	PDCURRENTSECTOR(a1),d0
		movea.l	(a2,d0.w*4),a3			; pointer sector (relativ)
		adda.l	d7,a3				; absolut machen fuer naechsten zugriff

		lea	doorsPointsOffset,a6
		move.l	(a6)+,d6
		move.l	(a6)+,a5			; c3pPointsDoors+x
		move.l	(a6),a6				; c3pLinesDoors+x

		move.l	SECLIFT(a3),d0			; vorhanden?
		beq.s	dspslSkip			; nein -> (nur diesen) sektor ueberspringen
		movea.l	d0,a0
		adda.l	d7,a0
		bsr.s	dspslOneSector
dspslSkip
		lea	SECEXTLINES(a3),a3
dspslExtLoop
		move.w	(a3)+,d0			; weitere sichtbare sektornummern
		bmi.s	dspslOut			; keine weiteren sichtbar -> raus

		movea.l	(a2,d0.w*4),a4
		adda.l	d7,a4
		move.l	SECLIFT(a4),d0
		beq.s	dspslExtLoop			; sektor ueberspringen
		movea.l	d0,a0
		adda.l	d7,a0
		bsr.s	dspslOneSector
		bra.s	dspslExtLoop
dspslOut
		lea	doorsPointsOffset,a4
		move.l	d6,(a4)+
		move.l	a5,(a4)+
		move.l	a6,(a4)

		rts


; --------------
; lift eines sektors uebertragen
; a0 = lift
; a2 belegt
; a3 belegt (extendedsectors)
; a5 = punktespeicher (wird fortlaufend beschrieben)
; a6 = linienspeicher (wird fortlaufend beschrieben)
; d6.l = point offset
; d7.l = level offset
; benutzte register:
dspslOneSector
		move.l	(a0)+,(a5)+		; punkte eintragen
		move.l	(a0)+,(a5)+
		move.l	(a0)+,(a5)+
		move.l	(a0)+,(a5)+
		move.l	(a0)+,(a5)+
		move.l	(a0)+,(a5)+
		move.l	(a0)+,(a5)+
		move.l	(a0)+,(a5)+

		moveq	#3,d5
dspslosLoop	move.l	(a0)+,d4
		add.w	d6,d4
		move.l	d4,(a6)+		; point_1
		move.l	(a0)+,d4
		add.w	d6,d4
		move.l	d4,(a6)+		; point_2
		move.l	(a0)+,(a6)+		; line_flag_1
		move.l	(a0)+,(a6)+		; line_flag_2
		move.l	(a0)+,(a6)+		; line_flag_3
		dbra	d5,dspslosLoop

		addi.l	#4*8,d6
		addq.w	#1,c3pNbDoors

		rts


; ---------------------------------------------------------
; sendet die schussanimation an den "dsp"
dspSendShoot
		lea	thingsPointsOffset,a6
		move.l	(a6)+,d6
		move.l	(a6)+,a5			; c3pPointsThings+x
		move.l	(a6),a6				; c3pLinesThings+x


		rts


; ---------------------------------------------------------
; 12.06.00/vk
; sendet die sichtbaren monster an den "dsp"
dspSendMonsters
		movea.l	monBufferPtr,a1
		move.w	monBufferNb,d7
		bmi.s	dspsmOut

		lea	monstersPointsOffset,a6
		move.l	(a6)+,d6
		move.l	(a6)+,a4			; c3pMonstersAddFlags+x
		movea.l	(a6)+,a5			; c3pPointsMonsters+x
		movea.l	(a6),a6				; c3pLinesMonsters+x

dspsmLoop
		movea.l	(a1)+,a0			; pointer auf monster

		move.l	(a0)+,(a5)+			; punkte eintragen
		move.l	(a0)+,(a5)+

		move.l	d6,(a6)+			; point_1
		addq.w	#8,d6
		move.l	d6,(a6)+			; point_2
		addq.w	#8,d6
		move.l	(a0)+,(a6)+			; lineflag_1
		move.l	(a0)+,(a6)+			; lineflag_2
		move.l	(a0)+,(a6)+			; lineflag_3

		move.l	(a0),(a4)+			; addflags

		addq.w	#1,c3pNbMonsters

		dbra	d7,dspsmLoop
dspsmOut
		lea	monstersPointsOffset,a0
		move.l	d6,(a0)+
		move.l	a4,(a0)+
		move.l	a5,(a0)+
		move.l	a6,(a0)

		rts














		IFNE DSPCOMM

;--------------------------------------

dsp_r_normal
		clr.w	dsp_error_flag
		clr.w	dsp_too_lame

		lea	dsp_puffer,a1
		lea	$ffffa204.w,a0
		lea	dsp_words_t,a2
		move.l	#$00ffffff,d6

drn_wait_for_texture

		btst	#0,-2(a0)
		bne.s	drn_can_send
		move.w	#1,dsp_too_lame
		bra.s	drn_wait_for_texture

drn_can_send
		move.l	(a0),d7			; anzahl oder error_flag
		cmp.l	d6,d7
		beq	dsp_error
		move.l	d7,(a2)
		subq.w	#1,d7
drn_read_texture
		move.l	(a0),(a1)+
		dbra	d7,drn_read_texture


drn_wait_for_boden

		btst	#0,-2(a0)
		beq.s	drn_wait_for_boden

		move.l	(a0),d7
		cmp.l	d6,d7
		beq	dsp_error
		move.l	d7,4(a2)
		subq.w	#1,d7
drn_read_boden
		move.l	(a0),(a1)+
		dbra	d7,drn_read_boden


drn_wait_for_mask

		btst	#0,-2(a0)
		beq.s	drn_wait_for_mask

		move.l	(a0),d7
		cmp.l	d6,d7
		beq.s	dsp_error
		move.l	d7,8(a2)
		subq.w	#1,d7
drn_read_mask
		move.l	(a0),(a1)+
		dbra	d7,drn_read_mask



drn_read_info
		bsr	dsp_read
		move.l	d0,min_entf

		bsr	dsp_read
		move.l	d0,dsp_calc_l_ii_anz

drn_read_hit
		btst	#0,-2(a0)
		beq.s	drn_read_hit
		move.l	(a0),d0
		beq.s	drn_no_hit

		subq.w	#1,d0
		move.w	d0,dsp_temp
		lea	shooted_mon,a1

drn_read_hit_loop

		btst	#0,-2(a0)
		beq.s	drn_read_hit_loop
		move.l	(a0),(a1)+
		dbra	d0,drn_read_hit_loop

drn_no_hit

		tst.w	dsp_error_flag
		beq.s	dsp_data_ok

		bsr	low_detail

dsp_data_ok

		rts


;---------------

dsp_error
		move.w	#1,dsp_error_flag
		lea	$ffffa204.w,a0
		bra.s	drn_read_info


;**************************************
;* initialisierungswerte senden
;**************************************

dsp_s_init_data:

                movea.l big_sector_ptr(PC),A6
                movea.l lev_init_data(A6),A6

                move.l  #%00000000000000000000000000000010,D0
                bsr     dsp_send

                moveq   #8,D7
dsp_id_loop:
                move.l  (A6)+,D0
                bsr     dsp_send

                dbra    D7,dsp_id_loop

                rts


;**************************************
;* monster senden
;**************************************

dsp_s_monsters
		lea	$ffffa204.w,a6

		movea.l	mon_buf1_ptr(pc),a1
		move.w	mon_buf1_anz,d7
		bmi.s	dsp_sm_out

dsp_sm_loop
		movea.l	(a1)+,a0	; pointer monster

		moveq	#%00001000,d0
		bsr	dsp_send

		moveq	#5,d1		; 6 long senden
dsp_mon_loop
		move.l	(a0)+,d0
		bsr	dsp_send
		
		dbra	d1,dsp_mon_loop

		dbra	d7,dsp_sm_loop

dsp_sm_out
		rts


;**************************************
;* trains senden
;**************************************
          
dsp_s_trains:   

                lea     $FFFFA204.w,A6

                move.w  trains_visible,D7

                movea.l big_sector_ptr(PC),A0
                movea.l lev_trains(A0),A0
                movea.l trn_data(A0),A0

                moveq   #0,D6
                move.w  max_trains,D5
		beq.s	dspst_out
		subq.w	#1,d5
s_trains_loop:
                btst    D6,D7
                beq.s   train_inaktiv

                move.l  A0,-(SP)

                bsr     send_one_door

                movea.l (SP)+,A0


train_inaktiv:
                lea     td_data_length(A0),A0
                addq.w  #1,D6

                dbra    D5,s_trains_loop
dspst_out
                rts


;**************************************
;* gegenstaende senden
;**************************************

; sowohl die vordefinierten als auch
; die von gegner liegengelassenen gegenstaende

dsp_s_things:   

                lea     $FFFFA204.w,A6

                movea.l big_sector_ptr(PC),A2
                adda.l  #lev_sec_start,A2

                movea.l play_dat_ptr(PC),A4
                move.w  pd_akt_sector(A4),D0

                lsl.w   #2,D0
                movea.l 0(A2,D0.w),A3
                move.l  sec_things(A3),D1
                beq.s   send_t_no_t

                movea.l D1,A1
                bsr.s   send_things_sec

send_t_no_t:

                moveq   #sec_ext_lines,D7
things_ext_loop:
                move.w  0(A3,D7.w),D6
                tst.w   D6
                bpl.s   things_extended

	; -----------------------------

	; und jetzt noch die gegenstaende von den
	; sichtbaren monstern senden ...

		move.w	mon_buf2_anz,d7
		bmi.s	st_out
		movea.l	mon_buf2_ptr,a6
st_left_loop
		movea.l	(a6)+,a0
		tst.w	mon_a_died(a0)
		beq.s	st_l_skip

	; monster ist gestorben, gibt es
	; einen liegengelassenen gegenstand ?
		
		move.l	mon_thing_typ(a0),d0
		beq.s	st_l_skip

		movea.l	d0,a0
		bsr.s	send_one_thing

st_l_skip
		dbra	d7,st_left_loop

st_out
		rts

;---

things_extended:
                addq.w  #2,D7

                lsl.w   #2,D6
                movea.l 0(A2,D6.w),A4
                move.l  sec_things(A4),D1
                beq.s   things_ext_loop

                movea.l D1,A1
                bsr.s   send_things_sec

                bra.s   things_ext_loop

;---------------

send_things_sec
                move.l  (A1)+,D0
                beq.s   send_things_sec
                bmi.s   send_things_sec_end

                movea.l D0,A0
                bsr.s   send_one_thing
                bra.s   send_things_sec

send_things_sec_end

                rts


;---------------

send_one_thing:

; a0: zeiger auf thing

		; nur senden, wenn noch nicht aufgenommen,
		; d.h. thing_type(a0) = -1, wenn aufgenommen

                tst.w   thing_type(A0)
                bmi.s   sot_out		

		; nur senden, wenn gegenstand zur
		; sichtbarkeit vorhanden ist

		tst.w	thing_vistaken(a0)
		beq.s	sot_no_vistaken

		movea.l	play_dat_ptr,a5
		movea.l	pd_things_ptr(a5),a5
		move.w	thing_vistaken(a0),d0
		tst.w	-4(a5,d0.w*4)
		beq.s	sot_out

sot_no_vistaken
		; nur senden, wenn gegenstand zur
		; sichtbarkeit aktiviert ist

		tst.w	thing_visact(a0)
		beq.s	sot_no_visact

		lea	pl_leiste_act,a5
		move.w	thing_visact(a0),d0
		tst.w	-2(a5,d0.w*2)
		beq.s	sot_out

sot_no_visact
		bra.s	send_one_thing_now
sot_out
                rts

send_one_thing_now:
                move.l  #%00000000000000000000001000000000,D0
                bsr     dsp_send

                adda.l  #thing_line,A0

                moveq   #4,D1
send_thing_loop	move.l  (A0)+,D0
                bsr     dsp_send

                dbra    D1,send_thing_loop

                rts


;**************************************
;* schussanimation senden
;**************************************

dsp_s_schuss
		movea.l	play_dat_ptr,a4
		lea	$ffffa204.w,a6
		lea	as_thing,a5

		moveq	#3,d7
dsp_ss_loop	
		tst.w	pd_as_send_flag(a4,d7.w*2)
		beq.s	dsp_ss_skip

		clr.w	pd_as_send_flag(a4,d7.w*2)

		move.l	#%1000000000,d0
		bsr	dsp_send

		movea.l	(a5,d7.w*4),a0
		moveq	#4,d1
send_schus_loop	move.l	(a0)+,d0
		bsr	dsp_send
		dbra	d1,send_schus_loop

dsp_ss_skip
		dbra	d7,dsp_ss_loop

		rts


;**************************************
;* schalter senden
;**************************************

dsp_s_schalter: 
                lea     $FFFFA204.w,A6

                movea.l big_sector_ptr(PC),A2
                adda.l  #lev_sec_start,A2

                movea.l play_dat_ptr(PC),A4
                move.w  pd_akt_sector(A4),D0

                lsl.w   #2,D0
                movea.l 0(A2,D0.w),A3
                move.l  sec_schalter(A3),D1
                beq.s   send_s_no_s

                movea.l D1,A1
                bsr.s   send_schalt_sec

send_s_no_s:

                moveq   #sec_ext_lines,D7
schalt_ext_loop:
                move.w  0(A3,D7.w),D6
                tst.w   D6
                bpl.s   schalt_extended

                rts


schalt_extended:
                addq.w  #2,D7

                lsl.w   #2,D6
                movea.l 0(A2,D6.w),A4
                move.l  sec_schalter(A4),D1
                beq.s   schalt_ext_loop

                movea.l D1,A1
                bsr.s   send_schalt_sec

                bra.s   schalt_ext_loop

;---------------

send_schalt_sec:
                move.l  (A1)+,D0
                beq.s   send_schalt_sec
                bmi.s   send_schalt_sec_end

                movea.l D0,A0
                bsr.s   send_one_schalt
                bra.s   send_schalt_sec

send_schalt_sec_end:

                rts


;---------------

send_one_schalt:

		; nur senden, wenn gegenstand zur
		; sichtbarkeit vorhanden ist

		tst.w	sch_vistaken(a0)
		beq.s	sos_no_vistaken

		movea.l	play_dat_ptr,a5
		movea.l	pd_things_ptr(a5),a5
		move.w	sch_vistaken(a0),d0
		tst.w	-4(a5,d0.w*4)
		beq.s	sos_out

sos_no_vistaken
		; nur senden, wenn gegenstand zur
		; sichtbarkeit aktiviert ist

		tst.w	sch_visact(a0)
		beq.s	sos_no_visact

		lea	pl_leiste_act,a5
		move.w	sch_visact(a0),d0
		tst.w	-2(a5,d0.w*2)
		beq.s	sos_out

sos_no_visact
		bra.s	send_one_schalter_now
sos_out
                rts

;---

send_one_schalter_now

                moveq   #%00010000,D0
                bsr     dsp_send

                adda.l  #sch_line,A0

                moveq   #6,D1
sos_loop:       move.l  (A0)+,D0
                bsr     dsp_send
                dbra    D1,sos_loop

                rts

                

		ENDC









		data



		bss

; offsets bei hinzufuegen einer linie in den dsp, wird staendig erhoeht
monstersPointsOffset	ds.l	1				; strukturen jeweils zusammenlassen
monstersWidthPtr	ds.l	1
monstersPointsPtr	ds.l	1
monstersLinesPtr	ds.l	1

thingsPointsOffset	ds.l	1
thingsPointsPtr		ds.l	1
thingsLinesPtr		ds.l	1

switchesPointsOffset	ds.l	1
switchesPointsPtr	ds.l	1
switchesLinesPtr	ds.l	1

doorsPointsOffset	ds.l	1
doorsPointsPtr		ds.l	1
doorsLinesPtr		ds.l	1
