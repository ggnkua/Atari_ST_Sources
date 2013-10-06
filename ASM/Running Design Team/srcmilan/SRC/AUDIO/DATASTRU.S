

AUDIOSYSSAMPLESPERCHANNEL	equ	4	; samples pro linkem/rechtem kanal
AUDIOSYSCALCVOLUMETABLE		equ	10	; nach wieviel durchlaeufen sollen die indizes fuer die lautstaerketabellen neu berechnet werden
AUDIOBUFFERPLAYLENGTH		equ	25000	; 25000 = 1 sek. wird jeweils vorberechnet

; slots mit bestimmten funktionen
AUDIOSYSMUSICSLOT		equ	0
AUDIOSYSSPEECHSLOT		equ	1

; bitdefinition von audioflag
AUDIOFLAGINITOKBIT		equ	0
AUDIOFLAGISDEACTIVEBIT		equ	1

; bitdefinition von audiosystem (bei erweiterung audiobufferplaylengthtab, audiomixer(first)samplerouts ebenfalls erweitern)
AUDIOSYSTEMSTEREOBIT		equ	0
AUDIOSYSTEMSURROUNDBIT		equ	1


; struktur sampledata (sampleslot)
			rsreset
SDLENGTH		rs.l	1		; laenge in samplewerten insgesamt
SDADDRESSLEFT		rs.l	1		; adresse fuer linken kanal
SDADDRESSRIGHT		rs.l	1		; adresse fuer rechten kanal
SDOFFSET		rs.l	1		; offset fuer aktuellen/nachfolgenden durchlauf
SDOFFSETPLAYNOW		rs.l	1		; offset fuer aktuellen durchlauf
SDPLAYERPOSITIONFLAG	rs.w	1		; flag zum anpassen der lautstaerke an spielerposition
SDPLAYERPOSITIONX	rs.l	1		; x-position des "samples"
SDPLAYERPOSITIONY	rs.l	1		; y-position des "samples"
SDVOLUMECOUNTER		rs.w	1		; zaehler zum neuberechnen der lautstaerketabelle (neg. = deaktiviert)
SDVOLUMELEFT		rs.w	1		; index der lautstaerke fuer linken kanal
SDVOLUMERIGHT		rs.w	1		; index der lautstaerke fuer rechten kanal
SDVOLUMETABLELEFT	rs.l	1		; adresse der lautstaerketabelle fuer linken kanal
SDVOLUMETABLERIGHT	rs.l	1		; adresse der lautstaerketabelle fuer rechten kanal
SDSPEEDINDEX		rs.w	1		; index der geschwindigkeit
SDLOOPFLAG		rs.w	1		; flag zum automatischen wiederholen
SDBYTES			rs.w	1		; laenge der struktur




		data


; aktuelle audiosystem einstellung
audioSystem	dc.w	0

; tabelle zur bestimmung der tatsaechlichen bufferlaenge in bytes (lsl.l)
audioBufferPlayLengthLslTab
		dc.w	1			; 16 bit mono
		dc.w	2			; 16 bit stereo
		dc.w	2			; 16 bit stereo (mono surround)
		dc.w	2			; 16 bit stereo (stereo surround)

; pointer auf sampledata-struktur, diese samples sind zum abspielen eingetragen
sampleDataPtr	ds.l	AUDIOSYSSAMPLESPERCHANNEL

; speicherbereich fuer sampledata (slots)
sampleDataX	ds.b	SDBYTES*AUDIOSYSSAMPLESPERCHANNEL
		even




		bss


; audio buffer start- und endadressen (struktur zusammenlassen)
audioBuffer1StartPtr	ds.l	1
audioBuffer1EndPtr	ds.l	1
audioBuffer2StartPtr	ds.l	1
audioBuffer2EndPtr	ds.l	1

; laenge des audiobuffers in byte
audioBufferLengthLong	ds.w	1
audioBufferLength	ds.w	1

; temporaerer audio mix-buffer zum zusammenmischen der samples, nimmt 16-bit-werte auf
audioMixBufferStartPtr	ds.l	1
audioMixBufferEndPtr	ds.l	1

; temporaeres array, das die im aktuellen interrupt abzuspielenden samples (pointer) aufnimmt
audioPlaySamplePtr	ds.l	AUDIOSYSSAMPLESPERCHANNEL

; einfache counter-variable
audioSystemCounter	ds.l	1

audioSystemCurrentNbOfSamples	ds.w	1

