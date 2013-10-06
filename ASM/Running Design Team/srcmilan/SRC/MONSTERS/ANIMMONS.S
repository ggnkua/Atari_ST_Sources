

		text


; ---------------------------------------------------------
; 12.06.00/vk
; komplettanimation/-bewegung der monster.
; wird von der hauptschleife aufgerufen.
; die aktuell sichtbaren gegner muessen bereits bestimmt
; worden sein.
animateMonsters
		move.w	monBufferNb,d7
		bmi.s	amOut
		movea.l	monBufferPtr,a1

		fmove.w	vblTime1000,fp0			; schrittweite fuer monster berechnen
		fdiv.w	#2*1000,fp0			; mal 2 -> monster bewegen sich mit halber geschwindigkeit
		fmul.w	#STEP1000,fp0			; konstante aus [.\src\moveit.s]
		fmove.w	fp0,monSpeed			; ... und abspeichern
		
amLoop
		movea.l	(a1)+,a2

		movem.l	d7/a1,-(sp)
		bsr	animateSingleMonsterPosition
		bsr	animateSingleMonsterShooting
		bsr	animateSingleMonsterTexture
		movem.l	(sp)+,d7/a1

		dbra	d7,amLoop
amOut
		rts


; ---------------------------------------------------------
; 26.06.00/vk
; positionsaniminierung der gegner.
; a2 = gegner (muss unveraendert bleiben)
animateSingleMonsterPosition

	; wenn bestimmte animationssequenzen laufen/aktiv sind

		tst.w	MONADIED(a2)			; sterbesequenz?
		bne	asmpOut
		tst.w	MONAHIT(a2)			; getroffensequenz?
		bne	asmpOut
		tst.w	MONASHOOT(a2)			; schiesssequenz?
		bne	asmpOut

	; keine bewegung, wenn die ml nicht existiert, auf der der gegner sich (angeblich) bewegt

		move.w	MONSEC(a2),d0
		movea.l	levelPtr,a6
		movea.l	LEVSECSTART(a6,d0.w*4),a1
		adda.l	a6,a1
		movea.l	SECAKTION(a1),a1
		adda.l	a6,a1
		move.w	AKTIONMLANZ(a1),d0		; gesamtzahl an ml dieses sektors
		cmp.w	MONSECML(a2),d0
		ble.s	asmpOut				; sofort raus

	; wenn der gegner nicht laufen darf, dann nur die koordinaten neu berechnen

		tst.b	MONWALKINGTYPE(a2)
		bmi.s	asmpSetPosition

	; gegner jedoch nicht animinieren, wenn in einem zu kleinen radius um den spieler

		move.l	MONLINE(a2),d0			; aktuelle x-koordinate (sind zu spielbeginn eigentlich nicht initialisiert)
		move.l	MONLINE+4(a2),d1		; aktuelle y-koordinate
		bsr	calcDistToPlayer
		cmpi.l	#$180,d0
		blt.s	asmpOut

	; jetzt entweder auf den spieler reagieren und laufen oder einfach nur weiterlaufen

;		cmp.l	MONACTRADIUS(a2),d0
;		bgt.s	asmpNoIntelligent

; todo		bsr	monsterDoIntelligentTurn

asmpNoIntelligent

		bsr	monsterWalkOneStep		; einen schritt in der aktuellen richtung normal weiterlaufen [.\src\monsters\walkstep.s]
		bra.s	asmpOut

asmpSetPosition
		move.w	MONSEC(a2),d0
		movea.l	levelPtr,a6
		movea.l	LEVSECSTART(a6,d0.w*4),a1
		adda.l	a6,a1
		movea.l	SECMONLINE(a1),a1
		adda.l	a6,a1
		move.w	MONSECML(a2),d0
		mulu.w	#MLBYTES,d0
		movea.l	(a1,d0.l),a1
		adda.l	a6,a1
		move.l	(a1),MONLINE(a2)		; x-koordinate der ml
		move.l	4(a1),MONLINE+4(a2)		; y-koordinate der ml
		move.w	8(a1),8+2(a2)			; hoehe

asmpOut
		rts


; ---------------------------------------------------------
; 12.06.00/vk
; bestimmt den zeitpunkt der reaktion des gegners.
; kann der gegner reagieren, wird die laufrichtung des
; gegners in richtung spieler gesetzt.
; eine unsichtbarkeit des spielers wird beruecksichtigt.
; a0 = sdat
; a2 = gegner
monsterDoIntelligentTurn

;		move.w	MONREACTCOUNT(a2),d0
;		sub.w	vblTime1000,d0
;		bpl.s	mditNoReaction
;
;
;
;
;
;
;	; wenn spieler unsichtbar ist, dann
;	; nicht auf spieler reagieren ...
;
;		movea.l	play_dat_ptr,a5
;		tst.w	pd_invis(a5)
;		bne	aomiw_no_intel
;
;		lea	pl_leiste_act,a5
;		move.w	#th_invis-1,d0
;		tst.w	(a5,d0.w*2)
;		bne	aomiw_no_intel
;
;                bsr.s   anim_intelligent_walk
;		move.w	mon_react_time(a2),d0		
;		bsr	get_zufall_256
;		lsr.w	#3,d1
;		subi.w	#16,d1
;		add.w	d1,d0
;		
;mditNoReaction
;		move.w	d0,MONREACTCOUNT(a2)

		rts


; ---------------------------------------------------------
; 12.06.00/vk
; berechnet den abstand zum spieler (in der maximumnorm).
; d0.l = x
; d1.l = y
; rueckgabe: d0 = abstand [0..?]
; rettet alle register.
calcDistToPlayer
		move.l	a6,-(sp)

		movea.l	playerDataPtr,a6
		sub.l	PDSX(a6),d0
		bpl.s	cdtpXOk
		neg.l	d0
cdtpXOk		sub.l	PDSY(a6),d1
		bpl.s	cdtpYOk
		neg.l	d1
cdtpYOk		cmp.l	d0,d1
		blt.s	cdtpYSmaller
		move.l	d1,d0
cdtpYSmaller
		movea.l	(sp)+,a6
		rts



