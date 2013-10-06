

		text


; ----------------------------------------------------------
; 24.09.00/vk
; timer a interrupt-routine des soundsystems.
; muss mit rte abgeschlossen werden.
audioSystemTimerA

		movem.l	d0-a6,-(sp)

		addi.l	#$10000,audioSystemCounter

		tst.w	audioFlag			; schnelle abfrage zur sicherheit
		beq.s	astaOut				; soundsystem nicht moeglich -> sofort raus

		bsr	audioSwapBufferAndPlay

		pea	audioSystemHbl
		move.w	#1,-(sp)			; data
		move.w	#1,-(sp)			; control
		move.w	#1,-(sp)			; 0 = timer a, 1 = timer b
		move.w	#31,-(sp)
		trap	#14
		lea	12(sp),sp

astaOut
		movem.l	(sp)+,d0-a6
		rte


; ----------------------------------------------------------
; 24.09.00/vk
audioSystemHbl
		movem.l	d0-a6,-(sp)

		addq.l	#1,audioSystemCounter

		bsr	audioCalcBuffer

		move.w	#8,-(sp)
		move.w	#26,-(sp)			; _jdisint()
		trap	#14
		addq.l	#4,sp

		movem.l	(sp)+,d0-a6
		rte


; ---------------------------------------------------------
; 24.09.00/vk
; berechnet den naechsten (logischen) audiobuffer.
audioCalcBuffer
		moveq	#0,d6
		lea	sampleDataPtr,a0		; array der pointer auf die sampledata-struktur
		lea	volumeTables,a4
		lea	audioBufferPlayLengthTable,a5	; array mit laengenangaben bei unterschiedlichen speedindizes
		lea	audioPlaySamplePtr,a6		; zwischenarray zur aufnahme der tatsaechlich jetzt abgespielten samples

		moveq	#AUDIOSYSSAMPLESPERCHANNEL-1,d7
acbcsLoop	move.l	(a0)+,a1			; naechster zeiger auf sampledata-struktur
		bsr	audioCalcSample			; (belegt: d7/a0) sampledata-struktur neu berechnen
		dbra	d7,acbcsLoop			; ueber maximal alle sampledata-strukturen

		move.w	d6,audioSystemCurrentNbOfSamples
		subq.w	#1,d6				; fuer dbra reduzieren. keine slots besetzt?
		bmi.s	acbNoSamples			; dann zur routine zum loeschen des buffers

		lea	audioPlaySamplePtr,a6		; mindestens ein sample ist jetzt vorhanden
		movea.l	(a6)+,a0			; pointer auf ersten slot
		movem.l	d6/a6,-(sp)
		bsr	audioMixerFirstSample		; und mit erstem sample den buffer beschreiben
		movem.l	(sp)+,d6/a6

		subq.w	#1,d6				; fuer dbra der restlichen slots
		bmi.s	acbMix				; keine weiteren vorhanden, dann sofort raus

acbmxLoop	movea.l	(a6)+,a0
		movem.l	d6/a6,-(sp)
		bsr	audioMixerAddSample		; sample zum bisherigen buffer hinzuaddieren
		movem.l	(sp)+,d6/a6
		dbra	d6,acbmxLoop			; loop ueber alle noch vorhandenen slots

acbMix
		bsr	audioMainVolumeMixer
		bra.s	acbOut				; und fertig

acbNoSamples
		bsr	audioClearBuffer1		; buffer loeschen

acbOut

		rts


; ---------------------------------------------------------
; 24.09.00/vk
; sampledata-struktur neu berechnen.
; d6 = aktuelle anzahl abzuspielender samples (wird ggf. durch diese routine erhoeht)
; d7 belegt
; a0 belegt
; a1 = zeiger auf aktuelle sampledata-struktur
; a4 = array der pointer der volumetables
; a5 = array mit laengenangaben pro speedindex (audiobufferplaylengthtable)
; a6 = zwischenarray, das die abzuspielenden samples aufnimmt (wird ggf. erhoeht)
audioCalcSample
		move.l	SDLENGTH(a1),d3			; ist in diesem slot ein sample vorhanden?
		beq.s	acsOut				; nein -> dann nichts berechnen und somit raus

		move.l	SDOFFSET(a1),d2			; offset holen
		move.l	d2,SDOFFSETPLAYNOW(a1)		; ab hier dann abspielen, da sdoffset wieder geaendert wird
		move.w	SDSPEEDINDEX(a1),d4		; geschwindigkeitsindex holen
		add.l	(a5,d4.w*4),d2			; anzahl bytes, die abgespielt werden, addieren
		cmp.l	d3,d2				; ende schon erreicht?
		blt.s	acsNoEndReached			; ja -> verzweigen

		tst.w	SDLOOPFLAG(a1)			; muss geloopt werden?
		bne.s	acsLoopNow
		clr.l	SDLENGTH(a1)			; slot wieder deaktivieren
		bra.s	acsOut				; und vorzeitig raus (letzter rest wird nicht mehr abgespielt)
acsLoopNow
		clr.l	SDOFFSETPLAYNOW(a1)		; ab hier dann abspielen
		move.l	(a5,d4.w*4),d2			; anzahl bytes, die abgespielt werden, bilden neues ende

acsNoEndReached
		move.l	d2,SDOFFSET(a1)			; neues offset fuer darauffolgenden irq abspeichern

;		tst.w	SDVOLUMECALCFLAG(a1)		; muss jetzt lautstaerketabelle neu berechnet werden?
;		beq.s	acsNoVolume
		bra.s	acsNoVolume

;		clr.w	SDVOLUMECALCFLAG(a1)			; flag wieder loeschen
		clr.w	SDVOLUMELEFT(a1)			; todo
		clr.w	SDVOLUMERIGHT(a1)
		move.w	SDVOLUMELEFT(a1),d2			; linker kanal (keine unterscheidung mono/stereo -> immer stereo berechnen)
		move.l	(a4,d2.w*4),SDVOLUMETABLELEFT(a1)
		move.w	SDVOLUMERIGHT(a1),d2			; rechter kanal (keine unterscheidung mono/stereo -> immer stereo berechnen)
		move.l	(a4,d2.w*4),SDVOLUMETABLERIGHT(a1)
acsNoVolume
		move.l	a1,(a6)+			; dieses sample als abzuspielend in zwischenbuffer eintragen
		addq.w	#1,d6				; anzahl abzuspielender bytes um eins erhoehen

acsOut
		rts


; ---------------------------------------------------------
; 24.09.00/vk
; aus dem zusammengemischten 16 bit-samplebuffer werden
; die endgueltigen 16 bit-samplewerte in den abzuspielenden
; speicherbereich konvertiert/eingetragen (low/high).
audioMainVolumeMixer
		movea.l	audioMixBufferStartPtr,a0
		lea	mainVolumeTable,a1

		movea.l	audioBuffer1StartPtr,a2

		lea	audioMainVolumeMixerRouts,a3
		move.w	audioSystem,d3
		andi.w	#%11,d3
		movea.l	(a3,d3.w*4),a3
		jsr	(a3)

		rts


; ---
; 24.09.00/vk
; a0 = audiomixbuffer
; a1 = mainvolumetable
; a2 = audiobuffer1start
amvmMono
		move.w	#AUDIOBUFFERPLAYLENGTH-1,d7
amvmmLoop	move.w	(a0)+,d0
		move.w	(a1,d0.w*2),(a2)+			; tabellenwert bereits im intel-format
		dbra	d7,amvmmLoop
		rts


; ---
; 24.09.00/vk
; a0 = audiomixbuffer
; a1 = mainvolumetable
; a2 = audiobuffer1start
amvmStereo
		move.w	#AUDIOBUFFERPLAYLENGTH-1,d7
amvmsLoop	move.w	(a0)+,d0
		move.w	(a1,d0.w*2),(a2)+			; tabellenwert bereits im intel-format
		move.w	(a0)+,d0
		move.w	(a1,d0.w*2),(a2)+			; tabellenwert bereits im intel-format
		dbra	d7,amvmsLoop
		rts


; ---
; 24.09.00/vk
; a0 = audiomixbuffer
; a1 = mainvolumetable
; a2 = audiobuffer1start
amvmMonoSurround
		move.w	#AUDIOBUFFERPLAYLENGTH-1,d7
amvmmsLoop	move.w	(a0)+,d0
		move.w	(a1,d0.w*2),(a2)+			; tabellenwert bereits im intel-format
		neg.w	d0
		move.w	(a1,d0.w*2),(a2)+
		dbra	d7,amvmmsLoop
		rts


; ---
; 24.09.00/vk
; a0 = audiomixbuffer
; a1 = mainvolumetable
; a2 = audiobuffer1start
amvmStereoSurround
		move.w	#AUDIOBUFFERPLAYLENGTH-1,d7
amvmssLoop	move.w	(a0)+,d0
		move.w	(a1,d0.w*2),(a2)+			; tabellenwert bereits im intel-format
		move.w	(a0)+,d0
		neg.w	d0
		move.w	(a1,d0.w*2),(a2)+			; tabellenwert bereits im intel-format
		dbra	d7,amvmssLoop
		rts


; ---------------------------------------------------------
; 24.09.00/vk
; a0 = pointer auf aktuellen sampleslot
audioMixerFirstSample

		move.w	SDSPEEDINDEX(a0),d0
		lea	interpolatedOffsetTables,a1
		movea.l	(a1,d0.w*4),a1				; a1 = zugriff-offsets auf sampledaten

		lea	audioMixerFirstSampleRouts,a2
		move.w	audioSystem,d2
		andi.w	#%01,d2
		movea.l	(a2,d2.w*4),a2
		jsr	(a2)

		rts


;---
; 24.09.00/vk
; a0 = sample
; a1 = interpolatedOffsetTable fuer aktuellen speed
amfsMono
		movea.l	SDADDRESSLEFT(a0),a2
		adda.l	SDOFFSETPLAYNOW(a0),a2
		movea.l	SDVOLUMETABLELEFT(a0),a3
		movea.l	audioMixBufferStartPtr,a6
		moveq	#0,d2
		move.w	#AUDIOBUFFERPLAYLENGTH-1,d7
amfsmLoop	move.w	(a1)+,d1				; sampleoffset holen
		move.b	(a2,d1.w),d2				; samplewert holen
		move.w	(a3,d2.w*2),(a6)+			; angepasste lautstaerke eintragen
		dbra	d7,amfsmLoop

		rts


;---
; 24.09.00/vk
; a0 = sample
; a1 = interpolatedOffsetTable fuer aktuellen speed
amfsStereo
		movea.l	SDADDRESSLEFT(a0),a2
		movea.l	SDADDRESSRIGHT(a0),a3
		adda.l	SDOFFSETPLAYNOW(a0),a2
		adda.l	SDOFFSETPLAYNOW(a0),a3
		movea.l	SDVOLUMETABLELEFT(a0),a4
		movea.l	SDVOLUMETABLERIGHT(a0),a5
		movea.l	audioMixBufferStartPtr,a6
		moveq	#0,d2
		moveq	#0,d3
		move.w	#AUDIOBUFFERPLAYLENGTH-1,d7
amfssLoop	move.w	(a1)+,d1				; sampleoffset holen
		move.b	(a2,d1.w),d2				; samplewert (l) holen
		move.b	(a3,d1.w),d3				; samplewert (r) holen
		move.w	(a4,d2.w*2),(a6)+			; angepasste lautstaerke eintragen
		move.w	(a5,d3.w*2),(a6)+			; angepasste lautstaerke eintragen
		dbra	d7,amfssLoop

		rts


; ---------------------------------------------------------
; 24.09.00/vk
; a0 = pointer auf aktuellen sampleslot
audioMixerAddSample

		move.w	SDSPEEDINDEX(a0),d0
		lea	interpolatedOffsetTables,a1
		movea.l	(a1,d0.w*4),a1				; a1 = zugriff-offsets auf sampledaten

		lea	audioMixerAddSampleRouts,a2
		move.w	audioSystem,d2
		andi.w	#%01,d2
		movea.l	(a2,d2.w*4),a2
		jsr	(a2)

		rts


;---
; 24.09.00/vk
; a0 = sample
; a1 = interpolatedOffsetTable fuer aktuellen speed
amasMono
		movea.l	SDADDRESSLEFT(a0),a2
		adda.l	SDOFFSETPLAYNOW(a0),a2
		movea.l	SDVOLUMETABLELEFT(a0),a3
		movea.l	audioMixBufferStartPtr,a6
		moveq	#0,d2
		move.w	#AUDIOBUFFERPLAYLENGTH-1,d7
amasmLoop	move.w	(a1)+,d1				; sampleoffset holen
		move.b	(a2,d1.w),d2				; samplewert holen
		move.w	(a3,d2.w*2),d3				; angepasste lautstaerke holen
		add.w	d3,(a6)+				; und hinzuaddieren
		dbra	d7,amasmLoop

		rts


;---
; 24.09.00/vk
; a0 = sample
; a1 = interpolatedOffsetTable fuer aktuellen speed
amasStereo
		movea.l	SDADDRESSLEFT(a0),a2
		movea.l	SDADDRESSRIGHT(a0),a3
		adda.l	SDOFFSETPLAYNOW(a0),a2
		adda.l	SDOFFSETPLAYNOW(a0),a3
		movea.l	SDVOLUMETABLELEFT(a0),a4
		movea.l	SDVOLUMETABLERIGHT(a0),a5
		movea.l	audioMixBufferStartPtr,a6
		moveq	#0,d2
		moveq	#0,d3
		move.w	#AUDIOBUFFERPLAYLENGTH-1,d7
amassLoop	move.w	(a1)+,d1				; sampleoffset holen
		move.b	(a2,d1.w),d2				; samplewert (l) holen
		move.b	(a3,d1.w),d3				; samplewert (r) holen
		move.w	(a4,d2.w*2),d4				; angepasste lautstaerke holen
		move.w	(a5,d3.w*2),d5				; angepasste lautstaerke holen
		add.w	d4,(a6)+				; und hinzuaddieren
		add.w	d5,(a6)+				; und hinzuaddieren
		dbra	d7,amassLoop

		rts


; ---------------------------------------------------------
; 17.09.00/vk
; bisheriger audiobuffer1 wird als buffer2 gesetzt und
; abgespielt. bisheriger buffer2 wird als buffer1 eingetragen
; und kann anschliessend nun neu geschrieben werden.
audioSwapBufferAndPlay

		lea	audioBuffer1StartPtr,a0
		movem.l	(a0),d0-d3
		exg	d0,d2				; anfangs- und endpointer von buffer 1 und 2 vertauschen
		exg	d1,d3
		movem.l	d0-d3,(a0)

		move.l	d3,-(sp)			; buffer 2 als aktuellen abspielen
		move.l	d2,-(sp)
		clr.w	-(sp)				; 0 = play, 1 = record
		move.w	#131,-(sp)			; _setbuffer(0,anfang,ende)
		trap	#14
		lea	12(sp),sp
		tst.l	d0
		bne.s	asbap131Error

		move.w	#%0011,-(sp)
		move.w	#136,-(sp)			; _buffoper(<value>)
;		trap	#14
		addq.l	#4,sp
; todo		tst.l	d0
;		bne.s	asbap131Error

		bra.s	asbapOut

asbap131Error
		lea	ltSoundSetbufferError,a0
		bsr	logString

		clr.w	audioFlag
asbapOut
		rts


; ---------------------------------------------------------
; 28.01.00/vk
; loescht den audiobuffer1 komplett. die buffer muessen
; bereits allokiert und gesetzt sein.
audioClearBuffer1
		movea.l	audioBuffer1StartPtr,a0
		bsr.s	audioClearBuffer
		rts


; ---------------------------------------------------------
; 28.01.00/vk
; loescht den audiobuffer2 komplett. die buffer muessen
; bereits allokiert und gesetzt sein.
audioClearBuffer2
		movea.l	audioBuffer2StartPtr,a0
		bsr.s	audioClearBuffer
		rts


; ---------------------------------------------------------
; 28.01.00/vk
; loescht beide audiobuffer komplett. die buffer muessen
; bereits allokiert und gesetzt sein.
audioClearBuffers
		movea.l	audioBuffer1StartPtr,a0
		bsr.s	audioClearBuffer
		movea.l	audioBuffer2StartPtr,a0
		bsr.s	audioClearBuffer
		rts


; ---------------------------------------------------------
; 28.01.00/vk
; loescht den uebergebenen audiobuffer komplett (mix-/speicherbereich).
; a0 = buffer
; rettet alle register.
audioClearBuffer
		movem.l	d0/a0-a1,-(sp)
		move.w	audioBufferLength,d0
		subq.w	#1,d0
acbLoop		clr.b	(a0)+
		dbra	d0,acbLoop
		movem.l	(sp)+,d0/a0-a1
		rts




		data


audioMixerFirstSampleRouts

		dc.l	amfsMono
		dc.l	amfsStereo

audioMixerAddSampleRouts

		dc.l	amasMono
		dc.l	amasStereo

audioMainVolumeMixerRouts

		dc.l	amvmMono
		dc.l	amvmStereo
		dc.l	amvmMonoSurround
		dc.l	amvmStereoSurround

