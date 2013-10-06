

		text


		IFEQ FINAL


; ---
audioSystemDebug

		bsr.s	asdDrawSampleDataPtr
		bsr	asdDrawAudioPlaySamplePtr
		bsr	asdDrawAudioSystemCounter
		bsr	asdDrawAudioSystemCurrentNbOfSamples
		bsr	asdDrawAudioBufferPlayLengthTable

		rts


; ---
asdDrawSampleDataPtr
		movea.l	screen_1,a0
		adda.l	#1280*30+640,a0
		lea	sampleDataPtr,a1
		moveq	#AUDIOSYSSAMPLESPERCHANNEL-1,d0
asddsdpLoop	movea.l	(a1)+,a2
		movem.l	d0/a0-a1,-(sp)
		bsr	asdDrawSingleSampleData
		movem.l	(sp)+,d0/a0-a1
		adda.w	#120,a0
		dbra	d0,asddsdpLoop
		rts


; ---
; a0 = screen
; a2 = sampledata
asdDrawSingleSampleData

		movem.l	a0/a2,-(sp)
		move.l	a0,-(sp)
		move.l	SDLENGTH(a2),-(sp)
		jsr	paintHex
		addq.l	#8,sp
		movem.l	(sp)+,a0/a2

		adda.l	#1280*10,a0
		movem.l	a0/a2,-(sp)
		move.l	a0,-(sp)
		move.l	SDOFFSET(a2),-(sp)
		jsr	paintHex
		addq.l	#8,sp
		movem.l	(sp)+,a0/a2

		adda.l	#1280*10,a0
		movem.l	a0/a2,-(sp)
		move.l	a0,-(sp)
		moveq	#0,d0
		move.w	SDSPEEDINDEX(a2),d0
		move.l	d0,-(sp)
		jsr	paintHex
		addq.l	#8,sp
		movem.l	(sp)+,a0/a2

		rts


; ---
asdDrawAudioPlaySamplePtr

		movea.l	screen_1,a0
		adda.l	#1280*30+300,a0
		lea	audioPlaySamplePtr,a1
		moveq	#AUDIOSYSSAMPLESPERCHANNEL-1,d1
asddapspLoop	movem.l	d1/a0-a1,-(sp)
		move.l	a0,-(sp)
		move.l	(a1),d0
		move.l	d0,-(sp)
		jsr	paintHex
		addq.l	#8,sp
		movem.l	(sp)+,d1/a0-a1
		addq.l	#4,a1
		adda.l	#1280*10,a0
		dbra	d1,asddapspLoop

		rts


; ---
asdDrawAudioSystemCounter

		movea.l	screen_1,a0
		adda.l	#1280*15+300,a0
		move.l	a0,-(sp)
		move.l	audioSystemCounter,-(sp)
		jsr	paintHex
		addq.l	#8,sp
		rts


; ---
asdDrawAudioSystemCurrentNbOfSamples

		movea.l	screen_1,a0
		adda.l	#1280*15+640,a0
		move.l	a0,-(sp)
		moveq	#0,d0
		move.w	audioSystemCurrentNbOfSamples,d0
		move.l	d0,-(sp)
		jsr	paintHex
		addq.l	#8,sp
		rts


; ---
asdDrawAudioBufferPlayLengthTable

		movea.l	screen_1,a0
		adda.l	#1280*30+200,a0
		lea	audioBufferPlayLengthTable,a1
		moveq	#25-1,d1
asddabpltLoop	movem.l	d1/a0-a1,-(sp)
		move.l	a0,-(sp)
		move.l	(a1),d0
		move.l	d0,-(sp)
		jsr	paintHex
		addq.l	#8,sp
		movem.l	(sp)+,d1/a0-a1
		addq.l	#4,a1
		adda.l	#1280*10,a0
		dbra	d1,asddabpltLoop

		rts


		ENDC