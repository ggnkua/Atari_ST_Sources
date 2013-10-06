



		text


; ---------------------------------------------------------
; 15.09.00/vk
; schiesssteuerung und -animierung der monster.
; a2 = gegner (muss unveraendert bleiben)
animateSingleMonsterShooting

		movea.l	playerDataPtr,a6
		tst.w	PDHEALTH(a6)			; wenn spieler bereits tot -> keine schusssteuerung
		bmi	asmsOut
		tst.w	PDINVIS(a6)			; wenn spieler unsichtbar -> keine schusssteuerung
		bne	asmsOut

		tst.w	MONADIED(a2)			; wenn gegner bereits tot -> keine schusssteuerung
		bne	asmsOut
		tst.w	MONZIVILIAN(a2)			; keine schuesse von zivilisten
		bpl	asmsOut

		cmpi.w	#-1,MONSHTTIME1(a2)
		beq	asmsOut

		tst.w	MONSHOOTTYPE(a2)
		bmi	asmsOut

		move.w	MONSHTCOUNT1000(a2),d0		; zeit bis zum naechsten schuss herunterzaehlen
		sub.w	vblTime1000,d0
		move.w	d0,MONSHTCOUNT1000(a2)
		bpl	asmsOut

		move.w	MONSHTTIME2(a2),d0		; neue zeit bis zum naechsten Schuss bestimmen
		sub.w	MONSHTTIME1(a2),d0
		bsr	getChance256
		mulu.w	d1,d0
		lsr.l	#8,d0
		add.w	MONSHTTIME1(a2),d0
		mulu.w	#20,d0				; auf basis 1000 erweitern
		move.w	d0,MONSHTCOUNT1000(a2)

		move.w	MONSHOOTTYPE(a2),d0
		btst	#MONSHOOTSINCEHITBIT,d0		; erst schiessen, wenn erstmals getroffen?
		beq.s	asmsSinceHitOk			; nein -> dann koennen wir loslegen
		btst	#MONSHOOTHASBEENHITBIT,d0	; wurde gegner bereits einmal getroffen?
		beq.s	asmsOut				; nein -> dann keinen schuss abgeben
asmsSinceHitOk

		btst	#MONSHOOTINACTRADONLYBIT,d0	; nur, wenn innerhalb des aktionsradius?
		beq.s	asmsInActRadOk			; nein -> dann koennen wir loslegen
		movem.l	MONLINE(a2),d0-d1
		bsr	calcDistToPlayer
		move.w	MONSHTACTRAD(a2),d1
		ext.l	d1
		cmp.l	d1,d0				; befindet sich spieler innerhalb des aktionsradius?
		bgt.s	asmsOut				; nein -> dann auch keinen schuss abgeben
		move.w	MONSHOOTTYPE(a2),d0		; register wieder restaurieren
asmsInActRadOk

		btst	#MONSHOOTINFORWONLYBIT,d0	; nur in vorwaertsrichtung einen schuss abgeben?
		beq.s	asmsInForwardOnlyOk		; nein -> dann koennen wir loslegen
		move.b	MONLINE+12+3(a2),d1		; normw vom monster
		addi.b	#$80,d1
		movea.l	playerDataPtr,a6
		move.w	PDALPHA(a6),d2
		lsr.w	#1,d2
		sub.b	d2,d1
		bpl.s	asmsifoPos
		neg.b	d1
asmsifoPos	cmpi.b	#$20,d1				; spieler in 90-grad-blickwinkel vom monster aus?
		bgt.s	asmsOut				; nein -> dann keinen schuss abgeben
asmsInForwardOnlyOk

		tst.w	MONASHOOT(a2)
		bne.s	asmsOut
		tst.w	MONAHIT(a2)
		bne.s	asmsOut

		move.w	#1,MONASHOOT(a2)

asmsOut
		rts


; ---------------------------------------------------------
; 16.09.00/vk
; das monster hat den spieler getroffen. jetzt dem spieler
; entsprechend energie abziehen.
; a2 = monster
; rettet alle register
monsterHitsPlayer
		movem.l	d0-a6,-(sp)
		lea	monsterStrengthTab,a5
		move.w	MONSTRENGTH(a2),d2
		move.w	(a5,d2.w*2),d1
		lsl.w	#8,d1				; faktor 256 fuer pdhealth

		bsr	decreasePlayerHealth

		movem.l	(sp)+,d0-a6
		rts


; ---------------------------------------------------------
; 16.09.00/vk
; dem spieler energie abziehen (shield/energy).
; d0 = soundflag (0 = keine geraeusche, 1 = geraeusche aktiv)
; d1 = absoluter wert, der abgezogen wird (0*256,..,100*256)
; rettet alle register
decreasePlayerHealth
		movem.l	d0-a6,-(sp)

		move.w	d0,d7				; soundflag zwischenspeichern

		move.w	#TINVUL,d0			; keine energie abziehen, wenn
		bsr	hasPlayerThingActivated		; spieler zur zeit unverwundbar ist
		tst.w	d0
		bne.s	dphOut

		cmpi.w	#100*256,d1
		beq.s	dphFullLoss

		tst.w	d7
		beq.s	dphNoSound

; SOUNDTODO	movem.l	d0-a6,-(sp)
;		moveq	#snd_ahh,d0
;		cmpi.w	#5*256,d2
;		blt.s	pdhm_default
;		moveq	#snd_arghh,d0
;pdhm_default	moveq	#0,d1
;		move.w	#1,dma_speech_flag
;		jsr	init_sam
;		movem.l	(sp)+,d0-a6
		nop
dphNoSound

		movea.l	playerDataPtr,a4
		move.w	PDHEALTH(a4),d0

		move.w	#128*256,d2
		sub.w	PDARMOR(a4),d2
		lsr.w	#7,d2			; <d2>/128 werden abgezogen
		mulu.w	d1,d2
		lsr.l	#8,d2
		sub.w	d2,d0
		bpl.s	dphHealthOk

dphFullLoss 
; SOUNDTODO	movem.l	a0-a2,-(sp)
;		move.w	#1,dma_speech_flag
;		moveq	#snd_player_died,d0
;		moveq	#0,d1
;		bsr	init_sam
;		movem.l	(sp)+,a0-a2

		movea.l	playerDataPtr,a4
		moveq	#-1,d0
		move.w	d0,PDHEALTH(a4)
		move.w	d0,PDARMOR(a4)
		move.w	#1,PDKILLEDFLAG(a4)
		bra.s	dphOut

dphHealthOk
		move.w	d0,PDHEALTH(a4)

		move.w	PDARMOR(a4),d0		; jetzt noch pdarmor verkleinern
		move.w	d1,d2
		add.w	d1,d1
		add.w	d2,d1
		lsr.w	#1,d1			; 3/2 von pdhealth werden pdarmor abgezogen
		sub.w	d1,d0
		bpl.s	dphArmorOk
		moveq	#-1,d0
dphArmorOk	move.w	d0,PDARMOR(a4)

dphOut
		movem.l	(sp)+,d0-a6
		rts








		data


; tabelle mit staerkenangaben
monsterStrengthTab
		dc.w	4,6,7,8,14,18,25,40

