

THNGROUT	equ	0



		text


thingsRout001	bsr	tSetThing
		bsr	tInstallMessage
		rts

thingsRout002	bsr	tSetThing
		bsr	tInstallMessage
		rts

thingsRout003	bsr	tSetThing
		bsr	tInstallMessage
		rts

thingsRout004	bsr	tSetThing
		bsr	tInstallMessage
		rts

thingsRout005	moveq	#1,d0
		bsr	thingsRoutTAMMOx
		rts

thingsRout006	moveq	#2,d0
		bsr	thingsRoutTAMMOx
		rts

thingsRout007	moveq	#3,d0
		bsr	thingsRoutTAMMOx
		rts

thingsRout008	moveq	#4,d0
		bsr	thingsRoutTAMMOx
		rts

; ultra-scanner
thingsRout009	bsr	tSetThing
		bsr	tInstallMessage
		rts
; night-viewer
thingsRout010	bsr	tSetThing
		bsr	tInstallMessage
		rts
; gas_mask
thingsRout011	bsr	tSetThing
		bsr	tInstallMessage
		rts
; small_medikit
thingsRout012	bsr	tSetThing
		bsr	tInstallMessage
		rts
; big_medikit
thingsRout013	bsr	tSetThing
		bsr	tInstallMessage
		rts

; small_medikit
thingsRout014	move.w	#10*256,d0
		bsr	tAddHealth
		tst.w	d7
		bne.s	tr014Out
		move.w	#1,dmaSpeechFlag
		bsr	tDeleteThing
		bsr	tInstallMessage
tr014Out	rts

; big_medikit
thingsRout015	move.w	#30*256,d0
		bsr	tAddHealth
		tst.w	d7
		bne.s	tr015Out
		move.w	#1,dmaSpeechFlag
		bsr	tDeleteThing
		bsr	tInstallMessage
tr015Out	rts

; small_armor
thingsRout016	move.w	#20*256,d0
		bsr	tAddArmor
		tst.w	d7
		bne.s	tr016Out
; todo		move.w	#1,audioSpeechFlag
		bsr	tDeleteThing
		bsr	tInstallMessage
tr016Out	rts

; big_armor
thingsRout017	move.w	#40*256,d0
		bsr	tAddArmor
		tst.w	d7
		bne.s	tr017Out
; todo		move.w	#1,audioSpeechFlag
		bsr	tDeleteThing
		bsr	tInstallMessage
tr017Out	rts

; invulnerability
thingsRout018	bsr	tSetThing
		bsr	tInstallMessage
		rts
; invisibility
thingsRout019	bsr	tSetThing
		bsr	tInstallMessage
		rts

; pistol1
thingsRout020	moveq	#1,d0
		bsr	thingsRoutTPISTOLx
		rts
; pistol2
thingsRout021	moveq	#2,d0
		bsr	thingsRoutTPISTOLx
		rts
; pistol3
thingsRout022	moveq	#3,d0
		bsr	thingsRoutTPISTOLx
		rts
; pistol4
thingsRout023	moveq	#4,d0
		bsr	thingsRoutTPISTOLx
		rts

; radiation suit
thingsRout024	bsr	tSetThing
		bsr	tInstallMessage
		rts
; geiger counter
thingsRout025	bsr	tSetThing
		bsr	tInstallMessage
		rts
; jetpack
thingsRout026	bsr	tSetThing
		bsr	tInstallMessage
		rts
; backpack
thingsRout027	bsr	tDeleteThing
		bsr	tInstallMessage
		movea.l	playerDataPtr,a6
		move.w	#MUNX0BACKPACK,PDMUNX0ANZ(a6)
		move.w	#MUNX1BACKPACK,PDMUNX1ANZ(a6)
		move.w	#MUNX2BACKPACK,PDMUNX2ANZ(a6)
		move.w	#MUNX3BACKPACK,PDMUNX3ANZ(a6)
		rts
; monster detector
thingsRout028	bsr	tSetThing
		bsr	tInstallMessage
		rts
; full plan
thingsRout029	bsr	tSetThing
		bsr	tInstallMessage
		rts

; tammo1def
thingsRout030	moveq	#1,d0
		move.w	#MUN1STATIC,d1
		bsr	thingsRoutTAMMOxDEF
		rts
; tammo2def
thingsRout031	moveq	#2,d0
		move.w	#MUN2STATIC,d1
		bsr	thingsRoutTAMMOxDEF
		rts
; tammo3def
thingsRout032	moveq	#3,d0
		move.w	#MUN3STATIC,d1
		bsr	thingsRoutTAMMOxDEF
		rts
; tammo4def
thingsRout033	moveq	#4,d0
		move.w	#MUN4STATIC,d1
		bsr	thingsRoutTAMMOxDEF
		rts

; open door
thingsRout034	movea.l	levelPtr,a6
		move.w	THINGACTION(a0),d0		; optionales argument
		movea.l	LEVSECSTART(a6,d0.w*4),a5	; sektor
		adda.l	a6,a5
		move.l	SECDOORS(a5),d0			; pointer tueren
		beq.s	tr034Out
		movea.l	d0,a1
		adda.l	a6,a1
		movea.l	(a1),a1				; bezieht sich immer nur auf die erste tuer des sektors
		adda.l	a6,a1
		btst	#0,DOORSTATUS+1(a1)
		beq.s	tr034Out			; tuer ist schon offen
		move.l	a0,-(sp)			; pointer auf aktuellen gegenstand sichern
		move.w	#%10,DOORSTATUS(a1)
		movea.l	a1,a0
; todo		bsr	doorToAnim
		move.l	DOORPTS(a0),d0
		move.l	DOORPTS+4(a0),d1
; todo		moveq	#SNDDOOROPEN,d2
;		bsr	initSamDist
		movea.l	(sp)+,a0			; pointer zurueckholen
		bsr	tDeleteThing
tr034Out	rts

; open lift
thingsRout035	movea.l	levelPtr,a6
		move.w	THINGACTION(a0),d0		; optionales argument
		movea.l	LEVSECSTART(a6,d0.w*4),a5	; sektor
		adda.l	a6,a5
		move.l	SECLIFT(a5),d0			; pointer lift
		beq.s	tr035Out
		movea.l	d0,a1
		adda.l	a6,a1
		btst	#0,LIFTSTATUS+1(a1)
		bne.s	tr035Out			; list ist schon oben
		move.l	a0,-(sp)
		move.w	#%10,LIFTSTATUS(a1)
		movea.l	a1,a0
; todo		bsr	liftToAnim
		move.l	LIFTPTS(a0),d0
		move.l	LIFTPTS+4(a0),d1
; todo		moveq	#SNDLIFTOPEN,d2
;		bsr	initSamDist
		movea.l	(sp)+,a0
		bsr	tDeleteThing
tr035Out	rts

; close door
thingsRout036	movea.l	levelPtr,a6
		move.w	THINGACTION(a0),d0		; optionales argument
		movea.l	LEVSECSTART(a6,d0.w*4),a5	; sektor
		move.l	SECDOORS(a5),d0			; pointer tueren
		beq.s	tr036Out
		movea.l	d0,a1
		adda.l	a6,a1
		movea.l	(a1),a1				; bezieht sich auf die erste tuer des sektors
		adda.l	a6,a1
		btst	#0,DOORSTATUS+1(a1)
		beq.s	tr036Out
		move.l	a0,-(sp)
		move.w	#%101,DOORSTATUS(a1)
		movea.l	a1,a0
; todo		bsr	doorToAnim
		move.l	DOORPTS(a0),d0
		move.l	DOORPTS+4(a0),d1
; todo		moveq	#SNDDOORCLOSE,d2
;		bsr	initSamDist
		movea.l	(sp)+,a0
		bsr	tDeleteThing
tr036Out	rts

; close lift
thingsRout037	movea.l	levelPtr,a6
		move.w	THINGACTION(a0),d0
		movea.l	LEVSECSTART(a6,d0.w*4),a5	; sektor
		move.l	SECLIFT(a5),d0			; pointer lift
		beq.s	tr037Out
		movea.l	d0,a1
		adda.l	a6,a1
		clr.w	LIFTNEEDTHING(a1)
		btst	#0,LIFTSTATUS+1(a1)
		beq.s	tr037Out
		move.l	a0,-(sp)
		move.w	#%101,LIFTSTATUS(a1)
		movea.l	a1,a0
; todo		bsr	liftToAnim
		move.l	LIFTPTS(a0),d0
		move.l	LIFTPTS+4(a0),d1
; todo		moveq	#SNDLIFTCLOSE,d2
;		bsr	initSamDist
		movea.l	(sp)+,a0
		bsr	tDeleteThing
tr037Out	rts

; teleporter
thingsRout038	move.l	a0,-(sp)
		movea.l	playerDataPtr,a1
		move.w	THINGACTION(a0),PDCURRENTSECTOR(a1)
		move.l	THINGACTION+2(a0),PDSX(a1)
		move.l	THINGACTION+6(a0),PDSY(a1)
		move.l	THINGACTION+10(a0),d0
		move.w	d0,PDSH(a1)
		move.w	d0,PDSHREAL(a1)
		move.l	THINGACTION+14(a0),d0
		add.w	d0,d0
		move.w	d0,PDALPHA(a1)

; todo		move.w	#snd_teleporter,d0
;		moveq	#0,d1
;		jsr	init_sam

;		moveq	#0,d0
;		bsr	make_blenden
;		bsr	set_speed_to_zero

		movea.l	(sp)+,a0	
		rts

; cameraview
thingsRout039	movem.l	d0-a6,-(sp)
		bsr	clearMessages
		move.w	#2,clearBackgroundFlag
		move.w	#1,cameraviewFlag
		lea	THINGACTION(a0),a0
		move.l	a0,-(sp)
; todo		move.w	#SNDCAMERAVIEW,d0
;		moveq	#0,d1
;		bsr	initSam
		movea.l	(sp)+,a0
tr039Loop	move.w	(a0)+,d0			; naechsten cameraindex
		bmi.s	tr039Out			; ende erreicht?
		move.l	a0,-(sp)
; todo		bsr	makeCameraview
; todo		move.w	#SNDCAMERAVIEW,d0
;		moveq	#0,d1
;		bsr	initSam
		movea.l	(sp)+,a0
		bra.s	tr039Loop
tr039Out	;bsr	setSpeedToZero			; todo
		clr.w	cameraviewFlag
		movem.l	(sp)+,d0-a6
		rts

; terminal
thingsRout040	movem.l	d0-a6,-(sp)
		move.w	#1,terminalFlag
		lea	THINGACTION(a0),a0
		move.w	keyoverlay+KOTERMINAL,d2
		lea	keytable,a1
		move.b	#1,(a1,d2.w)
		move.l	a0,mtConnectAddr
; todo		bsr	makeTwo180Turn
;		bsr	makeTerminal
		clr.w	terminalFlag
		movem.l	(sp)+,d0-a6
		rts

; welder
thingsRout041	bsr	tSetThing
		bsr	tInstallMessage
		rts

; deact. timelimit
thingsRout042	movea.l	playerDataPtr,a1
		tst.b	PDTIMEFLAG(a1)
		beq.s	tr042Out
		bsr	tDeleteThing
		bsr	tInstallMessage
		movea.l	playerDataPtr,a1
		clr.b	PDTIMEFLAG(a1)
tr042Out	rts

; gift
thingsRout043	bsr	tSetThing
		bsr	tInstallMessage
		rts

; levelend
thingsRout044	move.l	a0,-(sp)			; missionen erfuellt?
		moveq	#0,d7
		movea.l	playerDataPtr,a1
		tst.w	PDPRIMARY(a1)
		bne.s	tr044PrimaryOk
		moveq	#1,d7
		lea	msgPrimaryNot,a0
		bsr	installMessage
tr044PrimaryOk	tst.w	PDSECONDARY(a1)
		bne.s	tr044SecondaryOk
		moveq	#1,d7
		lea	msgSecondaryNot,a0
		bsr	installMessage
tr044SecondaryOk
		movea.l	(sp)+,a0
		tst.w	d7
		bne.s	tr044Out
		bsr	tDeleteThing
		moveq	#1,d0
		move.w	d0,PDQUITFLAG(a1)
		move.w	d0,quitFlag
tr044Out	rts

; sample
thingsRout045	bsr	tDeleteThing
		move.l	a0,-(sp)
		move.w	THINGACTION(a0),d0
		moveq	#0,d1
; todo		bsr	initSam
		movea.l	(sp)+,a0
		rts


; full plan
thingsRout046	bsr	tSetThing
		bsr	tInstallMessage
		rts
; nevergetable
thingsRout047	bsr	tSetThing
		rts

; sftozero
; setzt im angegebenen sektor alle sektorfields so, dass keine energie mehr abgezogen wird
; opt. arg.: 0.w = sektornummer
thingsRout048	move.w	THINGACTION(a0),d0
		movea.l	levelPtr,a2
		movea.l	LEVSECSTART(a2,d0.w*4),a1
		adda.l	a2,a1				; a1 = pointer sektor
		movea.l	SECSECT(a1),a1
		adda.l	a2,a1
		move.w	(a1)+,d7			; anzahl sektorfields
tr048Loop	clr.b	SFNEEDTHING(a1)
		clr.b	SFNEEDACT(a1)
		lea	SFBYTES(a1),a1
		dbra	d7,tr048Loop
		rts

; changevis
; aendert im angegebenen sektor die sichtbarkeitsoption von gegenstaenden und schaltern
; opt. arg.: 0.w = sektornummer, 2.w = typefrom, 4.w = typeto
thingsRout049	movem.w	THINGACTION(a0),d0/d6-d7
		movea.l	levelPtr,a4
		movea.l	LEVSECSTART(a4,d0.w*4),a1
		adda.l	a4,a1
		movea.l	SECTHINGS(a1),a2
tr049ThgLoop	move.l	(a2)+,d0
		beq.s	tr049ThgLoop
		bmi.s	tr049ThingsOut
		movea.l	d0,a3
		adda.l	a4,a3
		cmp.w	THINGVISTAKEN(a3),d6
		bne.s	tr049ThgSkip
		move.w	d7,THINGVISTAKEN(a3)
tr049ThgSkip	cmp.w	THINGVISACT(a3),d6
		bne.s	tr049ThgLoop
		move.w	d7,THINGVISACT(a3)
		bra.s	tr049ThgLoop
tr049ThingsOut
		move.l	SECSWITCHES(a1),d0
		beq.s	tr049SwitchesOut
		movea.l	d0,a2
		adda.l	a4,a2
tr049SwtLoop	move.l	(a2)+,d0
		beq.s	tr049SwtLoop
		bmi.s	tr049SwitchesOut
		movea.l	d0,a3
		adda.l	a4,a3
		cmp.w	SWITCHVISTAKEN(a3),d6
		bne.s	tr049SwtSkip
		move.w	d7,SWITCHVISTAKEN(a3)
tr049SwtSkip	cmp.w	SWITCHVISACT(a3),d6
		bne.s	tr049SwtLoop
		move.w	d7,SWITCHVISACT(a3)
		bra.s	tr049SwtLoop
tr049SwitchesOut
		rts

; laserdeact
; deaktiviert die lasersperre durch sftozero und changevis
; opt. arg.: 0.w = sektornummer, 2.w = benoetigter aufgenommener gegenstand, 4.w = benoetigter aktivierter gegenstand
thingsRout050

things_rout50	bsr	thingsRout048		; sftozero
		move.w	#TNIGHT,d0
		move.w	#TNEVERGET,d1
		movem.w	d0-d1,THINGACTION+2(a0)
		bsr	thingsRout049		; changevis
		rts

; message
thingsRout051	bsr	tDeleteThing
		move.l	a0,-(sp)
		lea	THINGACTION(a0),a0
		bsr	installMessage
		movea.l	(sp)+,a0
		rts

; sprengstoff
thingsRout052	bsr	tSetThing
		bsr	tInstallMessage
		rts
; zuender
thingsRout053	bsr	tSetThing
		bsr	tInstallMessage
		rts
; primarymission
thingsRout054	bsr	tDeleteThing
		bsr	tInstallMessage
		movea.l	playerDataPtr,a1
		move.w	#1,PDPRIMARY(a1)
		rts
; secondarymission
thingsRout055	bsr	tDeleteThing
		bsr	tInstallMessage
		movea.l	playerDataPtr,a1
		move.w	#1,PDSECONDARY(a1)
		rts
; general invulnerability
thingsRout056	bsr	tSetThing
		bsr	tInstallMessage
		rts
; general invisibility
thingsRout057	bsr	tSetThing
		bsr	tInstallMessage
		rts
; colortable0
thingsRout058	bsr	tDeleteThing
		moveq	#0,d0
		bsr	setColortable
		rts
; colortable1
thingsRout059	bsr	tDeleteThing
		moveq	#1,d0
		bsr	setColortable
		rts
; colortable2
thingsRout060	bsr	tDeleteThing
		moveq	#2,d0
		bsr	setColortable
		rts
; colortable3
thingsRout061	bsr	tDeleteThing
		moveq	#3,d0
		bsr	setColortable
		rts
; colortable4
thingsRout062	bsr	tDeleteThing
		moveq	#4,d0
		bsr	setColortable
		rts
; colortable5
thingsRout063	bsr	tDeleteThing
		moveq	#5,d0
		bsr	setColortable
		rts
; colortable6
thingsRout064	bsr	tDeleteThing
		moveq	#6,d0
		bsr	setColortable
		rts
; colortable7
thingsRout065	bsr	tDeleteThing
		moveq	#7,d0
		bsr	setColortable
		rts
; colortable
thingsRout066	bsr	tDeleteThing
		move.w	THINGACTION(a0),d0
		bsr	setColortable
		rts
; bierkrug
thingsRout067	move.w	#30*256,d0
		bsr	tAddHealth
		tst.w	d7
		bne.s	tr067Out
		bsr	tSetThing
		bsr	tInstallMessage
tr067Out	rts
; traindetector
thingsRout068	bsr	tSetThing
		bsr	tInstallMessage
		rts
; delete colortable0
thingsRout069	bsr	tDeleteThing
		moveq	#0,d0
		bsr	deleteColortable
		rts
; delete colortable1
thingsRout070	bsr	tDeleteThing
		moveq	#1,d0
		bsr	deleteColortable
		rts
; delete colortable2
thingsRout071	bsr	tDeleteThing
		moveq	#2,d0
		bsr	deleteColortable
		rts
; delete colortable3
thingsRout072	bsr	tDeleteThing
		moveq	#3,d0
		bsr	deleteColortable
		rts
; delete colortable4
thingsRout073	bsr	tDeleteThing
		moveq	#4,d0
		bsr	deleteColortable
		rts
; delete colortable5
thingsRout074	bsr	tDeleteThing
		moveq	#5,d0
		bsr	deleteColortable
		rts
; delete colortable6
thingsRout075	bsr	tDeleteThing
		moveq	#6,d0
		bsr	deleteColortable
		rts
; delete colortable7
thingsRout076	bsr	tDeleteThing
		moveq	#7,d0
		bsr	deleteColortable
		rts
; delete colortable
thingsRout077	bsr	tDeleteThing
		moveq	#0,d0
		bsr	deleteColortable
		rts

; secchangevis
; aendert die sichtbarkeiten und setzt die secondary mission durch secondary und changevis
thingsRout078	bsr	thingsRout049
		bsr	thingsRout055
		rts

; burger
thingsRout079	move.w	#25*256,d0
		bsr	tAddHealth
		tst.w	d7
		bne.s	tr079Out
		bsr	tDeleteThing
		bsr	tInstallMessage
tr079Out	rts

; condom
thingsRout080	bsr	tSetThing
		bsr	tInstallMessage
		rts
; idcard
thingsRout081	bsr	tSetThing
		bsr	tInstallMessage
		rts
; episodeend
thingsRout082	bsr	tDeleteThing
		movea.l	playerDataPtr,a6
		move.w	THINGACTION(a0),PDWHICHEND(a6)
		rts

; tammo0
thingsRout083	moveq	#0,d0
		bsr	thingsRoutTAMMOx
		rts
; tammo5
thingsRout084	moveq	#5,d0
		bsr	thingsRoutTAMMOx
		rts
; tammo6
thingsRout085	moveq	#6,d0
		bsr	thingsRoutTAMMOx
		rts
; tammo7
thingsRout086	moveq	#7,d0
		bsr	thingsRoutTAMMOx
		rts
; tammo8
thingsRout087	moveq	#8,d0
		bsr	thingsRoutTAMMOx
		rts
; tammo9
thingsRout088	moveq	#9,d0
		bsr	thingsRoutTAMMOx
		rts

; tammo0def
thingsRout089	moveq	#0,d0
		move.w	#MUN0STATIC,d1
		bsr	thingsRoutTAMMOxDEF
		rts
; tammo5def
thingsRout090	moveq	#5,d0
		move.w	#MUN5STATIC,d1
		bsr	thingsRoutTAMMOxDEF
		rts
; tammo6def
thingsRout091	moveq	#6,d0
		move.w	#MUN6STATIC,d1
		bsr	thingsRoutTAMMOxDEF
		rts
; tammo7def
thingsRout092	moveq	#7,d0
		move.w	#MUN7STATIC,d1
		bsr	thingsRoutTAMMOxDEF
		rts
; tammo8def
thingsRout093	moveq	#8,d0
		move.w	#MUN8STATIC,d1
		bsr	thingsRoutTAMMOxDEF
		rts
; tammo9def
thingsRout094	moveq	#9,d0
		move.w	#MUN9STATIC,d1
		bsr	thingsRoutTAMMOxDEF
		rts

; pistol0
thingsRout095	moveq	#0,d0
		bsr	thingsRoutTPISTOLx
		rts
; pistol5
thingsRout096	moveq	#5,d0
		bsr	thingsRoutTPISTOLx
		rts
; pistol6
thingsRout097	moveq	#6,d0
		bsr	thingsRoutTPISTOLx
		rts
; pistol7
thingsRout098	moveq	#7,d0
		bsr	thingsRoutTPISTOLx
		rts
; pistol8
thingsRout099	moveq	#8,d0
		bsr	thingsRoutTPISTOLx
		rts
; pistol9
thingsRout100	moveq	#9,d0
		bsr	thingsRoutTPISTOLx
		rts
; revolvingplan
thingsRout101	bsr	tSetThing
		bsr	tInstallMessage
		rts



; tammox
; d0 = index (0..9)
; a0 = pointer auf aktuellen gegenstand
thingsRoutTAMMOx
		move.w	THINGACTION(a0),d1
		bsr.s	thingsRoutTAMMOxDEF
		rts

; tammoxdef
; d0 = index (0..9)
; d1 = munitionszahl, die hinzukommen soll
; a0 = pointer auf aktuellen gegenstand
thingsRoutTAMMOxDEF
		movea.l	playerDataPtr,a6
		move.w	PDMUN0ANZ(a6,d0.w*2),d2
		cmp.w	PDMUNX0ANZ(a6,d0.w*2),d2
		beq.s	trtaxdNotTaken
		bsr	tDeleteThing
		add.w	d1,d2
		cmp.w	PDMUNX0ANZ(a6,d0.w*2),d2
		blt.s	trtaxdNoMax
		move.w	PDMUNX0ANZ(a6,d0.w*2),d2
trtaxdNoMax	move.w	d2,PDMUN0ANZ(a6,d0.w*2)
		bsr	tInstallMessage
		move.w	#1,plAmmoFlag
trtaxdNotTaken	rts

; tpistolx
; d0 = index (0..9)
; a0 = pointer auf aktuellen gegenstand
thingsRoutTPISTOLx
		move.w	#1,dmaSpeechFlag
		bsr	tDeleteThing
		bsr	tInstallMessage
		movea.l	playerDataPtr,a6
		move.w	#1,PDPISTOL0(a6,d0.w*2)
		move.w	#1,plWeaponFlag
		rts


; ---------------------------------------------------------

plActionRout009	move.w	#TSCANNER,d0
		bsr	tActivateText
		rts

plActionRout010	move.w	#TNIGHT,d0
		bsr	tActivateText
		moveq	#1,d0
		bsr	setColortable
		rts

plActionRout011	move.w	#TMASK,d0
		bsr	tActivateText
		rts

; 24.07.00/vk
plActionRout012	move.w	#10*256,d0		; diesen wert ...
		bsr	tAddHealth		; ... hinzufuegen
		tst.w	d7			; war hinzufuegen moeglich?
		bne.s	plar012NoUse		; nein -> dann wurde gegenstand nicht benutzt
		move.w	#TSMEDKITI,d0
		bsr	tActivateText		; textmeldung zeigen
		move.w	#TSMEDKITI,d0
		bsr	tRemoveOneThing		; einen gegenstand (dieser sorte) jetzt entfernen
		move.w	#TSMEDKITI,d0
		bsr	tDeactivateThing	; und gegenstand (allgemein) wieder deaktivieren
; todo		move.w	#1,audioSpeechFlag
; todo		move.w	#SNDLIKE,d0
; todo		moveq	#0,d1
; todo		bsr	initSam
plar012NoUse	rts

plActionRout013	move.w	#30*256,d0
		bsr	tAddHealth
		tst.w	d7
		bne.s	plar013NoUse
		move.w	#TSMEDKITI,d0
		bsr	tActivateText		; textmeldung zeigen
		move.w	#TSMEDKITI,d0
		bsr	tRemoveOneThing		; einen gegenstand (dieser sorte) jetzt entfernen
		move.w	#TSMEDKITI,d0
		bsr	tDeactivateThing	; und gegenstand (allgemein) wieder deaktivieren
; todo		move.w	#1,audioSpeechFlag
; todo		move.w	#SNDGOOD,d0
; todo		moveq	#0,d1
; todo		bsr	initSam
plar013NoUse	rts

plActionRout018	move.w	#TINVUL,d0
		bsr	tActivateText
		movea.l	playerDataPtr,a1
		move.w	#1,PDINVUL(a1)
		rts

plActionRout019	move.w	#TINVIS,d0
		bsr	tActivateText
		movea.l	playerDataPtr,a1
		move.w	#1,PDINVIS(a1)
		rts

plActionRout024	move.w	#TRADSUIT,d0
		bsr	tActivateText
		rts

plActionRout025	move.w	#TGEIGERCOUNTER,d0
		bsr	tActivateText
		rts

plActionRout026	lea	msgNoFuel,a0
		bsr	installMessage
		rts

plActionRout028	move.w	#TMONDETECTOR,d0
		bsr	tActivateText
		rts

plActionRout029	move.w	#TPLAN,d0
		bsr	tActivateText
		rts

plActionRout041	move.w	#TWELDER,d0
		bsr	tActivateText
		rts

plActionRout043	movea.l	levelPtr,a2
		movea.l	LEVINITDATA(a2),a3
		adda.l	a2,a3
		movea.l	INITVISSECPTR(a3),a3
		adda.l	a2,a3
		movea.l	playerDataPtr,a4
		move.w	PDCURRENTSECTOR(a4),d7
		bset	#1,(a3,d7.w)
		move.w	#TGIFT,d0
		bsr	tActivateText
		move.w	#TGIFT,d0
		bsr	tRemoveThing
		rts

plActionRout046	move.w	#TSMALLPLAN,d0
		bsr	tActivateText
		rts

plActionRout056	move.w	#TGENINVUL,d0
		bsr	tActivateText
		movea.l	playerDataPtr,a1
		move.w	#1,PDINVUL(a1)
		rts

plActionRout057	move.w	#TGENINVIS,d0
		bsr	tActivateText
		movea.l	playerDataPtr,a1
		move.w	#1,PDINVIS(a1)
		rts

plActionRout067	move.w	#TBIERKRUG,d0
		bsr	tActivateText
		rts

plActionRout068	move.w	#TTRNDETECTOR,d0
		bsr	tActivateText
		rts

plActionRout101	move.w	#TREVOLVINGPLAN,d0
		bsr	tActivateText
		rts



; ---------------------------------------------------------

plDeactionRout009
		move.w	#TSCANNER,d0
		bsr	tDeactivateText
                rts

plDeactionRout010
		move.w	#TNIGHT,d0
		bsr	tDeactivateText
		moveq	#1,d0
		bsr	deleteColortable
		rts

plDeactionRout011
		move.w	#TMASK,d0
		bsr	tDeactivateText
		rts

plDeactionRout018
		move.w	#TINVUL,d0
		bsr	tDeactivateText
		movea.l	playerDataPtr,a1
		clr.w	PDINVUL(a1)
		rts

plDeactionRout019
		move.w	#TINVIS,d0
		bsr	tDeactivateText
		movea.l	playerDataPtr,a1
		clr.w	PDINVIS(a1)
		rts

plDeactionRout024
		move.w	#TRADSUIT,d0
		bsr	tDeactivateText
		rts

plDeactionRout025
		move.w	#TGEIGERCOUNTER,d0
		bsr	tDeactivateText
		rts

plDeactionRout028
		move.w	#TMONDETECTOR,d0
		bsr	tDeactivateText
		rts

plDeactionRout029
		move.w	#TPLAN,d0
		bsr	tDeactivateText
		rts

plDeactionRout041
		move.w	#TWELDER,d0
		bsr	tDeactivateText
		rts

plDeactionRout046
		move.w	#TSMALLPLAN,d0
		bsr	tDeactivateText
		rts

plDeactionRout056
		move.w	#TGENINVUL,d0
		bsr	tDeactivateText
		movea.l	playerDataPtr,a1
		clr.w	PDINVUL(a1)
		rts

plDeactionRout057
		move.w	#TGENINVIS,d0
		bsr	tDeactivateText
		movea.l	playerDataPtr,a1
		clr.w	PDINVIS(a1)
		rts

plDeactionRout067
		move.w	#TBIERKRUG,d0
		bsr	tDeactivateText
		rts

plDeactionRout068
		move.w	#TTRNDETECTOR,d0
		bsr	tDeactivateText
		rts

plDeactionRout101
		move.w	#TREVOLVINGPLAN,d0
		bsr	tDeactivateText
		rts





; ---------------------------------------------------------
; 23.07.00/vk
; macht den gegenstand unsichtbar.
; a0 = pointer gegenstand (unveraendert)
; rettet alle register
tDeleteThing	neg.w	THINGTYPE(a0)
		rts


; ---------------------------------------------------------
; 23.07.00/vk
; zeigt die (aufnahme-) message fuer den gegenstand an.
; a0 = pointer gegenstand (unveraendert)
; rettet alle register
tInstallMessage	movem.l	d0/a0-a1,-(sp)
		move.w	THINGTYPE(a0),d0	; wurde gegenstand gerade aufgenommen?
		bpl.s	timOut			; nein -> raus
		neg.w	d0			; gegenstand ist negiert (d. h. aufgenommen) -> rueckgaengig machen
		lea	things,a1
		movea.l	(a1,d0.w*4),a1		; a1 = pointer auf gegenstand
		move.l	THGTXT(a1),d0
		beq.s	timOut			; string (pointer) nicht gueltig/vorhanden
		movea.l	d0,a0
		bsr	installMessage
timOut		movem.l	(sp)+,d0/a0-a1
		rts


; ---------------------------------------------------------
; 24.07.00/vk
; aufgenommenen gegenstand dem spieler wieder wegnehmen.
; es werden - falls mehrfach vorhanden - alle gegenstaende entfernt.
; d0 = gegenstand
; rettet alle register
tRemoveThing	movem.l	d0/a2,-(sp)
		lea	playerThings,a2
		mulu.w	#PTHGBYTES,d0
		clr.w	PTHGFLAG(a2,d0.w)
		movem.l	(sp)+,d0/a2
		rts


; ---------------------------------------------------------
; 24.07.00/vk
; einen einzelnen aufgenommenen gegenstand dem spieler wieder wegnehmen.
; es wird - falls mehrfach vorhanden - nur ein gegenstand entfernt.
; d0 = gegenstand
; rettet alle register
tRemoveOneThing	movem.l	d0/a2,-(sp)
		lea	playerThings,a2
		mulu.w	#PTHGBYTES,d0
		adda.l	d0,a2
		tst.w	PTHGMULTIPLE(a2)		; kann gegenstand mehrfach vorhanden sein?
		beq.s	trotRemoveAll			; nein -> dann alle (einen) loeschen
		subq.w	#1,PTHGNB(a2)
		bmi.s	trotRemoveAll			; (sicherheitsabfrage)
		bra.s	trotOut
trotRemoveAll	clr.w	PTHGFLAG(a2)
trotOut		movem.l	(sp)+,d0/a2
		rts


; ---------------------------------------------------------
; 24.07.00/vk
; einen einzelnen aufgenommenen gegenstand deaktivieren.
; d0 = gegenstand
; rettet alle register
tDeactivateThing
		movem.l	d0/a2,-(sp)
		lea	playerThings,a2
		mulu.w	#PTHGBYTES,d0
		clr.w	PTHGACTFLAG(a2,d0.w)
		movem.l	(sp)+,d0/a2
		rts


; ---------------------------------------------------------
; 23.07.00/vk
; gegenstand dem spieler als aufgenommen kennzeichnen
; (falls noch nicht vorhanden).
; a0 = pointer gegenstand (unveraendert)
tSetThing	move.w	THINGTYPE(a0),d0		; typ des aufgenommenen gegenstands
		bmi.s	tstOut				; negativ -> dann gegenstand nicht gueltig bzw. bereits aus dem level aufgenommen

		move.w	d0,d1
		mulu.w	#PTHGBYTES,d1
		lea	playerThings,a2
		adda.l	d1,a2				; a2 = gegenstandstyp im array der aufgenommenen gegenstaende

		lea	things,a3			; array der allgemeinen gegenstandsdaten
		movea.l	(a3,d0.w*4),a3

		tst.w	PTHGFLAG(a2)			; gegenstand bereits (mindestens einmal) aufgenommen?
		beq.s	tstSetFirst			; nein -> dann ersten gegenstand fest eintragen

		tst.w	THGMULTIPLE(a3)			; gegenstand bereits vorhanden. ist er mehrfach aufnehmbar?
		beq.s	tstOut				; nein -> dann verbleibt gegenstand im level

		addq.w	#1,PTHGNB(a2)			; dann einfach einen hinzuaddieren
		bra.s	tstRemoveInLevel

tstSetFirst
		move.w	#1,PTHGFLAG(a2)
		move.w	THGMULTIPLE(a3),PTHGMULTIPLE(a2)
		move.w	#1,PTHGNB(a2)
		move.w	THGTIMELIMIT(a3),d1
		bpl.s	tstsfHasTime
		moveq	#-1,d1
		bra.s	tstsfTimeOk
tstsfHasTime	mulu.w	#20,d1
tstsfTimeOk	move.l	d1,PTHGTIMELIMIT(a2)
		move.l	d1,PTHGTIMECOUNTER(a2)
		clr.w	PTHGACTFLAG(a2)

tstRemoveInLevel
		neg.w	THINGTYPE(a0)			; gegenstand im level als aufgenommen kennzeichnen
		movea.l	playerDataPtr,a1
		move.w	d0,PDCURRENTITEM(a1)		; und als aktuell anzuzeigenden gegenstand eintragen
tstOut
		rts


; ---------------------------------------------------------
; 24.07.00/vk
; gesundheit fuer den spieler hinzufuegen.
; d0 = health
; rueckgabe: d7: 0 = erfolgreich, 1 = bereits volle gesundheit
; rettet alle register
tAddHealth	movem.l	d0-d1/a1,-(sp)
		movea.l	playerDataPtr,a1
		move.w	PDHEALTH(a1),d1
		cmpi.w	#100*256,d1
		beq.s	tahIsFull
		ext.l	d1
		ext.l	d0
		add.l	d0,d1
		cmpi.l	#100*256,d1
		blt.s	tahOk
		move.w	#100*256,d1
tahOk		move.w	d1,PDHEALTH(a1)
		moveq	#0,d7
		bra.s	tahOut
tahIsFull	moveq	#1,d7
tahOut		movem.l	(sp)+,d0-d1/a1
		rts


; ---------------------------------------------------------
; 24.07.00/vk
; armor fuer den spieler hinzufuegen (parameter wie oben).
; rettet alle register
tAddArmor	movem.l	d0-d1/a1,-(sp)
		movea.l	playerDataPtr,a1
		move.w	PDARMOR(a1),d1
		cmpi.w	#100*256,d1
		beq.s	taaIsFull
		ext.l	d1
		ext.l	d0
		add.l	d0,d1
		cmpi.l	#100*256,d1
		blt.s	taaOk
		move.w	#100*256,d1
taaOk		move.w	d1,PDARMOR(a1)
		moveq	#0,d7
		bra.s	taaOut
taaIsFull	moveq	#1,d7
taaOut		movem.l	(sp)+,d0-d1/a1
		rts


; ---------------------------------------------------------
; 24.07.00/vk
; gegenstand aktivieren und meldung zeigen.
; d0 = gegenstandnummer (unveraendert)
; rettet alle register
tActivateText	movem.l	d0-d1/a0,-(sp)
		lea	things,a0
		movea.l	(a0,d0.w*4),a0
		move.l	THGACTIONTXT(a0),d1
		beq.s	tatSkipMessage
		movea.l	d1,a0
		bsr	installMessage
tatSkipMessage	lea	playerThings,a0
		move.w	d0,d1
		mulu.w	#PTHGBYTES,d1
		move.w	#1,PTHGACTFLAG(a0,d1.w)		; gegenstand als aktiviert kennzeichnen
		movem.l	(sp)+,d0-d1/a0
		rts


; ---------------------------------------------------------
; 24.07.00/vk
; gegenstand deaktivieren und meldung zeigen
; d0 = gegenstandsnummer
; rettet alle register
tDeactivateText	movem.l	d0-d1/a0,-(sp)
		lea	things,a0
		movea.l	(a0,d0.w*4),a0
		move.l	THGDEACTIONTXT(a0),d1
		beq.s	tdtSkipMessage
		movea.l	d1,a0
		bsr	installMessage
tdtSkipMessage	lea	playerThings,a0
		move.w	d0,d1
		mulu.w	#PTHGBYTES,d1
		clr.w	PTHGACTFLAG(a0,d1.w)		; gegenstand als deaktiviert kennzeichnen
		movem.l	(sp)+,d0-d1/a0
		rts


; ---------------------------------------------------------
; geschwindigkeit des spielers auf 0 setzen
; keine aenderung von registern
setSpeedToZero	movem.l	d0/a1-a2,-(sp)
		lea	keytable,a1
		lea	keyoverlay,a2
		move.w	KOLEFT(a2),d0
		clr.b	(a1,d0.w)
		move.w	KORIGHT(a2),d0
		clr.b	(a1,d0.w)
		move.w	KOFORWARD(a2),d0
		clr.b	(a1,d0.w)
		move.w	KOBACKWARD(a2),d0
		clr.b	(a1,d0.w)
		movea.l	playerDataPtr,a1
		clr.w	PDLASTSTEP(a1)
		clr.w	PDLASTALPHA(a1)
		clr.w	PDLASTSTRAFE(a1)
		movem.l	(sp)+,d0/a1-a2
		rts






		data






		bss


temporaryThing	ds.b	THGBYTES



