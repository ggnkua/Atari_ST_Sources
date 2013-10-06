

		text


calc3dPicture

		tst.w	c3pMode				; welcher algorithmus?
		bne.s	c3pAlgorithm2			; mit boden und decke berechnen
		
		bsr	c3pQuickAccess
		bsr	c3pDeletePicture
		bsr	c3pShiftAndRotate
		bsr	c3pPlaceThings
		bsr	c3pPlaceMonsters
		bsr	c3pMakePartitions
		bsr	c3pCollision

		bra	c3pOut

c3pAlgorithm2						; algorithmus mit texturiertem boden und decke

		bsr	c3pQuickAccess			; schnellzugriff auf einige versteckte variablen
		bsr	c3pA2DeletePicture		; strahlbuffer komplett/bild loeschen
		bsr	c3pShiftAndRotate
		;bsr	c3pPlaceThings
		;bsr	c3pPlaceMonsters
		bsr	c3pA2MakePartition		; .\src\3dengine\a2.s
		bsr	c3pA2CalcDXYRayIndex
		bsr	c3pA2SortLines			; .\src\3dengine\a2sort.s
		bsr	c3pA2Collision


		bsr	c3pA2MakeRayEntries		; kompletten strahlbuffer in zeichnenbuffer umwandeln

c3pOut
		rts

