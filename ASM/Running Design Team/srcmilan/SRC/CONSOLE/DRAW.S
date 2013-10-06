


		text


; ---------------------------------------------------------
; 08.08.00/vk
; zeichnet die console in ihrem aktuellen zustand in den
; logischen screen. zeichnet ggf. weitere bestandteile
; der console wie z. b. den scanner.
drawConsole

		movea.l	screen_1,a0

		lea	console,a1
		move.w	CONSOLEPOSXRIGHT(a1),d0			; koordinaten der rechten
		move.w	CONSOLEPOSYDOWN(a1),d1			; unteren ecke

		movea.l	playerDataPtr,a3

	; d0/d1 = rechte untere ecke vom rahmenteil
	; a0 = screen
	; a1 = console
	; a3 = playerdata

	; -------------------------------------------------
	; rahmen

		move.w	d0,d6
		move.w	d1,d7

		lea	bmpCCons02,a2				; rechtes unteres eckstueck
		sub.w	BITMAPWIDTH(a2),d6
		sub.w	BITMAPHEIGHT(a2),d7
		bsr	bitBlt

		move.w	d7,d5					; y-koordinate merken

		lea	bmpCCons01,a2				; rechtes seitenstueck
		sub.w	BITMAPHEIGHT(a2),d7
		bsr	bitBlt

		move.w	d5,d7

		move.w	CONSOLESTRETCHP2(a1),d5
		sub.w	d5,d6
		lea	bmpCCons03s,a2
		bsr	d3bHorizontalStretch

		lea	bmpCCons04,a2
		sub.w	BITMAPWIDTH(a2),d6
		bsr	bitBlt

		move.w	CONSOLESTRETCHP1(a1),d5
		sub.w	d5,d6
		lea	bmpCCons05s,a2
		bsr	d3bHorizontalStretch

		lea	bmpCCons06,a2
		sub.w	BITMAPWIDTH(a2),d6
		bsr	bitBlt

	; -------------------------------------------------
	; energy

		move.w	d0,d6
		move.w	d1,d7

		lea	bmpCCons02,a2				; rechtes unteres eckstueck
		sub.w	BITMAPWIDTH(a2),d6
		sub.w	BITMAPHEIGHT(a2),d7

		move.w	d7,d5
		lea	bmpCEnergyBk,a2
		sub.w	BITMAPWIDTH(a2),d6
		sub.w	BITMAPHEIGHT(a2),d7
		bsr	dcDrawEnergy
		move.w	d5,d7

		lea	bmpCEnergyTx,a2
		sub.w	BITMAPWIDTH(a2),d6
		sub.w	BITMAPHEIGHT(a2),d7
		bsr	bitBlt

		sub.w	CONSOLESPACEENERGY(a1),d6

	; -------------------------------------------------
	; shield

		move.w	d5,d7

		lea	bmpCShieldBk,a2
		sub.w	BITMAPWIDTH(a2),d6
		sub.w	BITMAPHEIGHT(a2),d7
		bsr	dcDrawShield

		move.w	d5,d7
		lea	bmpCShieldTx,a2
		sub.w	BITMAPWIDTH(a2),d6
		sub.w	BITMAPHEIGHT(a2),d7
		bsr	bitBlt

		sub.w	CONSOLESPACESHIELD(a1),d6

	; -------------------------------------------------
	; bag

		move.w	d5,d7
		lea	bmpCBagBk,a2
		sub.w	BITMAPWIDTH(a2),d6
		sub.w	BITMAPHEIGHT(a2),d7
		move.w	d6,consoleItemsXOffset
		move.w	d7,consoleItemsYOffset

		bsr	getCurrentItemPos
		tst.w	d0
		bmi.s	dcdiDrawNullItem

		lea	things,a4
		movea.l	(a4,d0.w*4),a4
		move.w	THGGFXINDEX(a4),d0
		bmi.s	dcdiDrawNullItem
		bsr	consoleItemsDrawSingleIcon
		bra.s	dcdiOk
dcdiDrawNullItem
		bsr	bitBlt
dcdiOk

		move.w	d5,d7
		lea	bmpCBagTx,a2
		sub.w	BITMAPWIDTH(a2),d6
		sub.w	BITMAPHEIGHT(a2),d7
		bsr	bitBlt

		sub.w	CONSOLESPACEBAG(a1),d6

	; -------------------------------------------------
	; waffenstandsanzeige (ikone und munitionsanzahl)

		subi.w	#CONSOLEWEAPONWIDTH,d6
		subi.w	#CONSOLEWEAPONSINGLEHEIGHT,d5
		move.w	d6,wpconsXOffset
		move.w	d5,wpconsYOffset

		addi.w	#CONSOLEWEAPONWIDTH-2,d6
		addi.w	#CONSOLEWEAPONSINGLEHEIGHT-CONSOLEWEAPONCOUNTERHEIGHT-2,d5

		mulu.w	lineoffset,d5
		add.w	d6,d6
		ext.l	d6
		add.l	d5,d6
		move.l	d6,wpcountOffset

		movea.l	playerDataPtr,a0
		move.w	PDMUNTYPE(a0),d0
		bsr	wpconsDrawWeaponIcon		
		move.w	PDMUN0ANZ(a0,d0.w*2),d0
		bsr	wpcountDrawValue


	; -------------------------------------------------
	; zustandsbestandteile

		bsr	drawConsoleItemActivationOrTimelimit

		bsr	drawScannerIfRequired			; .\src\console\scanner.s
		bsr	drawGeigerIfRequired			; .\src\console\geiger.s
		bsr	drawAltTabIfRequired			; .\src\console\alttab.s

		rts


; ---------------------------------------------------------
; 09.08.00/vk
; zeichnet die lampe fuer die aktivierung des angezeigten
; gegenstandes bzw. dessen zeitlimit.
; rettet alle register
drawConsoleItemActivationOrTimelimit

		movem.l	d0-a6,-(sp)

		bsr	recalcCurrentItem

		movea.l	playerDataPtr,a0
		move.w	PDCURRENTITEM(a0),d0
		bmi.s	dciaotOut

		lea	playerThings,a0
		mulu.w	#PTHGBYTES,d0
		adda.l	d0,a0

		tst.w	PTHGACTFLAG(a0)				; angezeigter gegenstand aktiviert?
		beq.s	dciaotOut				; nein -> dann raus

		tst.l	PTHGTIMELIMIT(a0)			; zeitlimit vorhanden?
		bpl.s	dciaotTime

		movea.l	screen_1,a0
		adda.l	#1280*440+900,a0
		move.l	a0,-(sp)
		move.l	#$12345678,-(sp)
		jsr	paintHex
		addq.l	#8,sp

		bra.s	dciaotOut

dciaotTime
		move.l	PTHGTIMECOUNTER(a0),d0
		movea.l	screen_1,a0
		adda.l	#1280*440+900,a0
		move.l	a0,-(sp)
		move.l	d0,-(sp)
		jsr	paintHex
		addq.l	#8,sp

dciaotOut
		movem.l	(sp)+,d0-a6
		rts


; ---------------------------------------------------------
; d6/d7 = linke obere ecke
; a2 = bmpcenergybk
; a3 = playerdata
; rettet alle register
dcDrawEnergy
		movem.l	d0-a6,-(sp)

		move.w	PDHEALTH(a3),d3				; wie ist die aktuelle health?
		bmi.s	dcdeBlackOnly				; wenn negativ (gestorben) oder null ...
		beq.s	dcdeBlackOnly				; ... dann nur blackonly zeichnen

		move.w	BITMAPHEIGHT(a2),d5			; gesamthoehe des balkens (hier anhand blackonly bitmap)
		mulu.w	d5,d3
		divu.w	#100*256,d3				; d3 = balkenhoehe color
		bne.s	dcdeValPos
		moveq	#1,d3
dcdeValPos	cmp.w	d5,d3
		bge.s	dcdeColorOnly

		move.w	BITMAPWIDTH(a2),d4
		sub.w	d3,d5					; d5 = balkenhoehe black
		bsr	bitBltSize

		lea	bmpCEnergyCl,a2
		moveq	#0,d2
		add.w	d5,d7
		exg	d3,d5
		bsr	bitBltSizeOffset

		bra.s	dcdeOut

dcdeColorOnly	lea	bmpCEnergyCl,a2
dcdeBlackOnly	bsr	bitBlt

dcdeOut
		movem.l	(sp)+,d0-a6
		rts


; ---------------------------------------------------------
; d6/d7 = linke obere ecke
; a2 = bmpcshieldbk
; a3 = playerdata
; rettet alle register
dcDrawShield
		movem.l	d0-a6,-(sp)

		move.w	PDARMOR(a3),d3				; wie ist das aktuelle shield?
		bmi.s	dcdsBlackOnly				; wenn negativ (gestorben) oder null ...
		beq.s	dcdsBlackOnly				; ... dann nur blackonly zeichnen

		move.w	BITMAPHEIGHT(a2),d5			; gesamthoehe des balkens (hier anhand blackonly bitmap)
		mulu.w	d5,d3
		divu.w	#100*256,d3				; d3 = balkenhoehe color
		bne.s	dcdsValPos
		moveq	#1,d3
dcdsValPos	cmp.w	d5,d3
		bge.s	dcdsColorOnly

		move.w	BITMAPWIDTH(a2),d4
		sub.w	d3,d5					; d5 = balkenhoehe black
		bsr	bitBltSize

		lea	bmpCShieldCl,a2
		moveq	#0,d2
		add.w	d5,d7
		exg	d3,d5
		bsr	bitBltSizeOffset

		bra.s	dcdsOut

dcdsColorOnly	lea	bmpCShieldCl,a2
dcdsBlackOnly	bsr	bitBlt

dcdsOut
		movem.l	(sp)+,d0-a6
		rts







		data




		bss




