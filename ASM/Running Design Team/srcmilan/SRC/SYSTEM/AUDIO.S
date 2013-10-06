
; running audio system
; 25 khz, 16 bit
; mono oder stereo


; tatsaechliche laenge des audio buffers in bytes pro interrupt
; 25 kHz mono/16 bit = 2 * AUDIOBUFFERPLAYLENGTH bytes
; 25 kHz stereo/16 bit = 2 * 2 * AUDIOBUFFERPLAYLENGTH bytes
; 25 kHz mono surround/16 bit = 2 * 2 * AUDIOBUFFERPLAYLENGTH bytes
; 25 kHz stereo surround/16 bit = 2 * 2 * AUDIOBUFFERPLAYLENGTH bytes



		text


; ---------------------------------------------------------
; 17.09.00/vk
; systeminitialisierung des audio subsystems.
initAudio
		tst.w	audioFlag			; keine doppel-initialisierung zulassen
		bne	iaDoubleInit

		bsr	readSNDCookie
		tst.w	d0				; cookie gefunden?
		beq	iaFailed			; nein -> fehlerroutine
		btst	#2,d1				; codec verfuegbar?
		beq	iaNoCodecAvail

		lea	ltSoundCodec,a0			; meldung ueber vorhandenen
		bsr	logString			; codec im logfile ausgeben

		move.w	#129,-(sp)			; _unlocksnd() (sicherheitshalber lt. r. mannigel durchfuehren)
		trap	#14
		addq.l	#2,sp

		move.w	#128,-(sp)			; _locksnd()
		trap	#14
		addq.l	#2,sp

		cmpi.l	#1,d0
		bne	iaLocked

		lea	ltSoundLocked,a0		; soundsystem erfolgreich fuer running gesperrt
		bsr	logString

	; als wiedergabespur spur 0 festgelegen

		clr.w	-(sp)
		move.w	#134,-(sp)			; _setmontracks(0)
		trap	#14
		addq.l	#4,sp
		tst.l	d0
		bne	ia134Error

	; eine wiedergabe- und eine aufnahmespur festlegen
		
		clr.w	-(sp)
		clr.w	-(sp)
		move.w	#133,-(sp)			; _settracks(0,0)
		trap	#14
		addq.l	#6,sp
		tst.l	d0
		bne	ia133Error

	; audiosubsystem verbinden (src, dst, srcclock...)

		move.w	#0,-(sp)
		move.w	#0,-(sp)
		move.w	#1,-(sp)			; 1 = externer takt (44100 khz)
		move.w	#%0000000000001100,-(sp)
		clr.w	-(sp)
		move.w	#139,-(sp)			; _devconnect(0,$c,0,0,1) -> auch in logfile.s eintragen
		trap	#14
		lea	12(sp),sp
		tst.l	d0
		bne	ia139Error

	; vorteiler festlegen

		move.w	#2,-(sp)
		move.w	#6,-(sp)
		move.w	#130,-(sp)			; _soundcmd(6,2)
		trap	#14
		addq.l	#6,sp
		cmpi.l	#2,d0
		bne	ia130Error

	; interrupts festlegen

		move.w	#%1,-(sp)
		clr.w	-(sp)
		move.w	#135,-(sp)			; _setinterrupt(0,1)
		trap	#14
		addq.l	#6,sp		
		tst.l	d0
		bne	ia135Error

	; timer a im system freischalten und auf eigene routine setzen

		pea	audioSystemTimerA
		move.w	#13,-(sp)
		move.w	#13,-(sp)			; _setexec()
		trap	#14
		addq.l	#8,sp

		move.w	#13,-(sp)
		move.w	#27,-(sp)			; _jenabint()
		trap	#14
		addq.l	#4,sp

	; tabellen erstellen, dma-faehigen speicher allokieren usw.

		moveq	#0,d0
		bset	#AUDIOFLAGINITOKBIT,d0		; audiosystem auf initialisiert setzen
		bset	#AUDIOFLAGISDEACTIVEBIT,d0	; aber z. zt. noch auf deaktiviert (d. h. nicht hoerbar)
		move.w	d0,audioFlag

		bsr	calcVolumeTables		; alle lautstaerketabellen nun einmalig erzeugen
		bsr	calcInterpolatedOffsetTables	; offsettabellen zum zugriff auf samples bei untersch. speedindizes einmalig vorberechnen
		bsr	audioInitSampleDataPtr

		bsr	audioAllocateAndSetBuffers
		tst.w	audioFlag
		beq	iaFailed

		bsr	audioInitMonoSystem
		tst.w	audioFlag
		beq	iaFailed

	; erfolgreiche initialisierung protokollieren

		lea	ltSoundOk,a0			; meldung ueber erfolgreiche initialisierung ausgeben
		bsr	logString

		bsr	audioClearBuffers		; .\src\audio\audiosys.s
		bsr	audioSystemStart
		bra	iaOut

	; fehlerroutinen

iaDoubleInit	lea	ltSoundDoubleInit,a0
		bsr	logString
		bra.s	iaOut

iaNoCodecAvail
		lea	ltSoundNoCodec,a0		; meldung ueber fehlenden
		bsr	logString			; codec im logfile ausgeben
		bra.s	iaFailed			; kein audiosystem verfuegbar

iaLocked	
		bsr	binToHex
		lea	ltSoundLockFailedM,a1
		move.l	(a0),(a1)
		move.l	4(a0),4(a1)
		lea	ltSoundLockFailed,a0
		bsr	logString
		bra	iaFailed
ia134Error
		lea	ltSoundSetmontracksError,a0
		bsr	logString
		bra	iaFailed
ia133Error
		lea	ltSoundSettracksError,a0
		bsr	logString
		bra	iaFailed
ia139Error
		lea	ltSoundDevconnectError,a0
		bsr	logString
		bra	iaFailed
ia130Error
		lea	ltSoundSoundcmdError,a0
		bsr	logString
		bra	iaFailed
ia135Error
		lea	ltSoundSetinterruptError,a0
		bsr	logString

iaFailed
		lea	ltSoundFailed,a0
		bsr	logString

		clr.w	audioFlag
iaOut
		rts


; ---------------------------------------------------------
; 27.01.00/vk
; soundsystem wieder zuruecksetzen zum ursprungszustand,
; d. h. fuer andere applikationen wieder freigeben (unlock).
restoreAudio
		bsr	audioSystemStop			; soundwiedergabe anhalten

		move.w	#129,-(sp)			; _unlocksnd()
		trap	#14
		addq.l	#2,sp

		clr.w	audioFlag

		pea	audioSystemHbl
		move.w	#1,-(sp)
		move.w	#0,-(sp)
		move.w	#1,-(sp)			; 0 = timer a, 1 = timer b
		move.w	#31,-(sp)
		trap	#14
		lea	12(sp),sp

		rts


; ----------------------------------------------------------
; 17.09.00/vk
; erstellt die pointer auf die sampledata. muss nur einmalig aufgerufen werden.
; rettet alle register.
audioInitSampleDataPtr

		movem.l	d1-d2/a0-a1,-(sp)

		lea	sampleDataPtr,a0
		lea	sampleDataX,a1				; anfangsadresse
		move.w	#SDBYTES,d1				; offset

		move.w	#AUDIOSYSSAMPLESPERCHANNEL-1,d2
aisdpLoop	clr.l	SDLENGTH(a1)
		move.l	a1,(a0)+
		adda.w	d1,a1
		dbra	d2,aisdpLoop

		movem.l	(sp)+,d1-d2/a0-a1
		rts


; ---------------------------------------------------------
; 29.01.00/vk
; liest den _SND cookie aus. der cookie wert wird ggf. nach
; sndcookie geschrieben.
; rueckgabe: d0 = 0 (kein cookie gefunden), 1 (cookie gefunden)
;            d1 = cookie wert (falls gefunden)
readSNDCookie
		move.l	$5a0.w,d0			; cookie-jar (anscheinend auch auf dem milan)
		beq	rscNoCookieJar			; keiner da

		movea.l	d0,a0				; adresse in adressregister
rscLoop		move.l	(a0),d0				; naechsten cookie holen
		beq	rscNoSNDCookie			; ende schon erreicht, also cookie nicht gefunden
		cmpi.l	#"_SND",d0			; cookie gefunden?
		beq.s	rscFound			; ja -> verzweigen
		addq.l	#8,a0				; zeiger auf naechsten cookie setzen
		bra.s	rscLoop				; und von vorne

rscFound
		move.l	4(a0),d0
		move.l	d0,sndCookie			; abspeichern
		move.l	d0,-(sp)
		bsr	binToHex
		lea	ltSoundCookieValueM,a1
		move.l	(a0),(a1)
		move.l	4(a0),4(a1)
		lea	ltSoundCookieValue,a0
		bsr	logString
		move.l	(sp)+,d1
		moveq	#1,d0				; rueckgabewert fuer erfolg setzen
		bra.s	rscOut

rscNoCookieJar
		lea	ltSoundNoCookieJar,a0
		bsr	logString
		lea	ltSoundNoSoundAvailable,a0
		bsr	logString

		moveq	#0,d0
		bra.s	rscOut

rscNoSNDCookie
		lea	ltSoundNoSNDCookie,a0
		bsr	logString
		lea	ltSoundNoSoundAvailable,a0
		bsr	logString

		moveq	#0,d0
rscOut
		rts


; ---------------------------------------------------------
; 17.09.00/vk
; allokiert den st-ram speicher und setzt die pointer fuer
; die audiobuffer entsprechend.
; dito fuer den audiomixbuffer.
audioAllocateAndSetBuffers

	; buffer im st-ram (logisch und physikalischer buffer)

		move.w	#%00,d0				; st-ram
		move.l	#AUDIOBUFFERPLAYLENGTH*2*2*2,d1	; groesse/laenge (benoetigen zwei buffer a 16 bit fuer stereobetrieb)
		bsr	allocateMemory
		tst.l	d0
		beq.s	aaasbError

		lea	audioBuffer1StartPtr,a0
		move.l	d0,(a0)				; anfangsadresse fuer buffer 1
		addi.l	#AUDIOBUFFERPLAYLENGTH*2*2,d0
		move.l	d0,8(a0)			; anfangsadresse fuer buffer 2

	; temporaerer mixbuffer (linker und rechter kanal) fuer audiosystem

		move.w	#%11,d0				; egal, tt-ram bevorzugt
		move.l	#AUDIOBUFFERPLAYLENGTH*2*2,d1	; einen buffer fuer 16-bit-werte (ggf. wird in stereo l/r gemischt)
		bsr	allocateMemory
		tst.l	d0
		beq.s	aaasbError

		lea	audioMixBufferStartPtr,a0
		move.l	d0,(a0)
		addi.l	#AUDIOBUFFERPLAYLENGTH*2*2,d0
		move.l	d0,4(a0)

		bra.s	aaasbOut

aaasbError
		clr.w	audioFlag			; kein soundsystem verfuegbar

		lea	ltSoundAllocBufferError,a0
		bsr	logString

aaasbOut
		rts


; ---------------------------------------------------------
; 17.09.00/vk
; setzt das soundsystem auf mono (zurueck).
; audioflag muss korrekt gesetzt sein und zeigt an, ob das
; soundsystem z. zt. aktiv (d. h. hoerbar) ist.
; soundsystem wird ggf. gestoppt, wenn noch aktiv.
; rettet alle register.
audioInitMonoSystem
		move.l	d0,-(sp)
		moveq	#0,d0
		bsr.s	audioInitSystem
		move.l	(sp)+,d0
		rts


; ---------------------------------------------------------
; 17.09.00/vk
; setzt das soundsystem auf stereo (zurueck).
; audioflag muss korrekt gesetzt sein und zeigt an, ob das
; soundsystem z. zt. aktiv (d. h. hoerbar) ist.
; soundsystem wird ggf. gestoppt, wenn noch aktiv.
; rettet alle register.
audioInitStereoSystem
		move.l	d0,-(sp)
		moveq	#1,d0
		bsr.s	audioInitSystem
		move.l	(sp)+,d0
		rts


; ---------------------------------------------------------
; 17.09.00/vk
; setzt das soundsystem auf eine betriebsart. routine muss
; zum funktionieren des audio systems mindestens einmal aufgerufen werden.
; audioflag muss korrekt gesetzt sein und zeigt an, ob das
; soundsystem z. zt. aktiv (d. h. hoerbar) ist.
; soundsystem wird ggf. gestoppt, wenn noch aktiv.
; d0 = modus vgl. variable/feld audiosystem
; rettet alle register.
audioInitSystem
		movem.l	d0-d7/a0-a6,-(sp)

		move.w	d0,-(sp)

		move.w	audioFlag,d1			; soundsystem ueberhaupt vorhanden?
		beq.s	aisOut				; nein -> dann auch keine initialisierung
		btst	#AUDIOFLAGISDEACTIVEBIT,d1	; soundsystem vorhanden, z. zt. noch deaktiviert?
		bne.s	aisStartInit			; ja -> dann koennen wir sofort initialisieren

		bsr	audioSystemStop			; wiedergabe vorher anhalten

aisStartInit
		move.w	(sp)+,d0
		move.w	d0,audioSystem

	; bufferstart- und -endadressen anpassen (auf neue laenge)

		lea	audioBufferPlayLengthLslTab,a0
		move.w	(a0,d0.w*2),d2			; lsl.l-faktor zur bestimmung der bytelaenge

		move.l	#AUDIOBUFFERPLAYLENGTH,d1	; laenge bei 8 bit-mono-betrieb
		lsl.l	d2,d1				; bei stereobetrieb verdoppeln
		lea	audioBuffer1StartPtr,a0
		move.l	(a0),a1				; anfang buffer 1 holen
		adda.l	d1,a1				; laenge addieren
		move.l	a1,4(a0)			; und ende neu setzen
		move.l	8(a0),a1			; anfang buffer 2 holen
		adda.l	d1,a1				; laenge addieren
		move.l	a1,12(a0)			; und ende neu setzen

	; bytelaenge der buffer separat nochmals abspeichern

		move.l	d1,audioBufferLengthLong

	; soundkarte auf mono- oder stereobetrieb stellen

		lsr.w	#1,d2				; d2 = 0 bei mono-, 1 bei stereo-betrieb
		move.w	d2,d0
		not.w	d0
		andi.w	#$0001,d0
		lsl.w	#1,d0				; 2 = mono, 0 = stereo
		bset	#0,d0				; 16 bit aktivieren
		move.w	d0,-(sp)			; 3 = 16 bit mono, 1 = 16 bit stereo
		move.w	#132,-(sp)			; _setmode(x)
		trap	#14
		addq.l	#4,sp

		tst.l	d0
		beq.s	ais132Ok

		clr.w	audioFlag

		lea	ltSoundSetmodeError,a0
		bsr	logString
		bra.s	aisOut
ais132Ok

	; (neuen) wiedergabebuffer dem system bekannt machen

		bsr	audioSetBuffer1
aisOut
		movem.l	(sp)+,d0-d7/a0-a6
		rts


; ---------------------------------------------------------
; 04.10.00/vk
; startet die wiedergabe mit den aktuellen parametern.
; die wiedergabe des aktuellen audiobuffers wird angestossen.
; rettet alle register.
audioSystemStart
		movem.l	d0-a6,-(sp)

		move.w	audioFlag,d0			; aktueller status des soundsystems
		beq.s	asstartOut			; nicht verfuegbar -> keine aktion durchfuehren und beenden
		btst	#AUDIOFLAGISDEACTIVEBIT,d0	; noch deaktiviert?
		beq.s	asstartOut			; nein -> muss also bereit gestartet sein, also keine aktion durchfuehren und beenden

		move.w	#%0011,-(sp)
		move.w	#136,-(sp)			; _buffoper(<value>)
		trap	#14
		addq.l	#4,sp
		tst.l	d0
		bne.s	ass136Error

		move.w	#%1,-(sp)
		clr.w	-(sp)
		move.w	#135,-(sp)			; _setinterrupt(0,1)
		trap	#14				; den interrupt nochmals aktivieren, da
		addq.l	#6,sp				; er bei einem start des audiosystem nach einem stop
		tst.l	d0				; nicht wieder automatisch aktiv wird (04.10.00/vk).
		bne.s	ass135Error

		lea	audioFlag,a0
		move.w	(a0),d0
		bclr	#AUDIOFLAGISDEACTIVEBIT,d0
		move.w	d0,(a0)				; flags wieder korrekt setzen

		bra.s	asstartOut			; und beenden

ass135Error
		lea	ltSoundSetinterruptError,a0
		bsr	logString
		bra.s	asstartError
ass136Error
		lea	ltSoundBuffoperError,a0
		bsr	logString
asstartError
		clr.w	audioFlag

asstartOut
		movem.l	(sp)+,d0-a6
		rts


; ---------------------------------------------------------
; 17.09.00/vk
; stoppt die komplette audio wiedergabe.
; rettet alle register.
audioSystemStop
		movem.l	d0-a6,-(sp)

		move.w	audioFlag,d0			; ueberhaupt moeglich?
		beq.s	asstopOut			; nein -> beenden
		btst	#AUDIOFLAGISDEACTIVEBIT,d0	; bereits angehalten?
		bne.s	asstopOut			; ja -> beenden

		move.w	#%0000,-(sp)
		move.w	#136,-(sp)			; _buffoper(0)
		trap	#14
		addq.l	#4,sp
		tst.l	d0
		bne.s	asstopError

		lea	audioFlag,a0
		move.w	(a0),d0
		bset	#AUDIOFLAGISDEACTIVEBIT,d0
		move.w	d0,(a0)				; flags wieder korrekt setzen
		bra.s	asstopOut

asstopError
		lea	ltSoundBuffoperError,a0
		bsr	logString

		clr.w	audioFlag

asstopOut
		movem.l	(sp)+,d0-a6
		rts


; ---------------------------------------------------------
; 17.09.00/vk
; setzt den audiobuffer1 als neuen wiedergabepuffer.
audioSetBuffer1
		lea	audioBuffer1StartPtr,a0
		move.l	4(a0),a1
		move.l	(a0),a0
		bsr	audioSetBuffer
		rts


; ---------------------------------------------------------
; 17.09.00/vk
; setzt den audiobuffer als wiedergabepuffer.
; a0 = pufferanfang
; a1 = pufferende + 1
audioSetBuffer
		move.l	a1,-(sp)
		move.l	a0,-(sp)
		clr.w	-(sp)				; 0 = play, 1 = record
		move.w	#131,-(sp)			; _setbuffer(0,anfang,ende)
		trap	#14
		lea	12(sp),sp
		tst.l	d0
		beq.s	asb131Ok

		clr.w	audioFlag

		lea	ltSoundSetbufferError,a0
		bsr	logString
asb131Ok
		rts







		data


sndCookie	dc.l	0			; _SND cookie
audioFlag	dc.w	0			; bits: 0 = soundsystem verfuegbar, 1 = z. zt. keine wiedergabe



