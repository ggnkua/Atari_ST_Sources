


		text


; ---------------------------------------------------------
; tastaturabfragen zum einstellen des audio systems.
; wird i. d. R. von der hauptroutine keyHit aufgerufen,
; ein aufruf aus anderen routinen ist jedoch unter
; beachtung der uebergabeparameter moeglich.
; a0 = keyoverlay
; a1 = keytable
keyHitAudio

		move.w	KOAUDIOSWITCH(a0),d0
		tst.b	(a1,d0.w)
		beq.s	khNoAudioSwitch
		movem.l	a0-a1,-(sp)
		clr.b	(a1,d0.w)
		bsr	audioSwitchOnOff
		movem.l	(sp)+,a0-a1
khNoAudioSwitch

		move.w	KOAUDIOMONOSTEREOSWITCH(a0),d0
		tst.b	(a1,d0.w)
		beq.s	khNoStereoSwitch
		movem.l	a0-a1,-(sp)
		clr.b	(a1,d0.w)
		bsr	audioMonoStereoSwitch
		movem.l	(sp)+,a0-a1
khNoStereoSwitch

		move.w	KOAUDIOSURROUNDSWITCH(a0),d0
		tst.b	(a1,d0.w)
		beq.s	khNoSurroundSwitch
		movem.l	a0-a1,-(sp)
		clr.b	(a1,d0.w)
		bsr	audioSurroundSwitch
		movem.l	(sp)+,a0-a1
khNoSurroundSwitch

		rts


; ---------------------------------------------------------
; 04.10.00/vk
; soundwiedergabe ein- bzw. ausschalten
audioSwitchOnOff
		move.w	audioFlag,d0
		beq.s	asooOut
		btst	#1,d0
		beq.s	asooSwitchOff
		bsr	audioSystemStart
		lea	txtAudioOn,a0
		jsr	installMessage
		bra.s	asooOut
asooSwitchOff	bsr	audioSystemStop
		lea	txtAudioOff,a0
		jsr	installMessage
asooOut
		rts


; ---------------------------------------------------------
; 04.10.00/vk
audioMonoStereoSwitch
		tst.w	audioFlag
		beq.s	amssOut
		move.w	audioSystem,d0
		btst	#AUDIOSYSTEMSTEREOBIT,d0
		beq.s	amssSwitchStereo
		bsr	audioInitMonoSystem
		lea	txtAudioMono,a0
		jsr	installMessage
		bra.s	amssOut
amssSwitchStereo
		bsr	audioInitStereoSystem
		lea	txtAudioStereo,a0
		jsr	installMessage
amssOut
		rts


; ---------------------------------------------------------
; 04.10.00/vk
audioSurroundSwitch
		tst.w	audioFlag
		beq.s	amssOut

		lea	audioSystem,a0
		move.w	(a0),d0
		btst	#AUDIOSYSTEMSURROUNDBIT,d0
		beq.s	amsSwitchSurroundOn

		bclr	#AUDIOSYSTEMSURROUNDBIT,d0
		move.w	d0,(a0)
		bsr	audioInitSystem				; in: d0
		bsr	audioSystemStart

		lea	txtAudioSurroundOff,a0
		jsr	installMessage
		bra.s	amsOut

amsSwitchSurroundOn

		bset	#AUDIOSYSTEMSURROUNDBIT,d0
		move.w	d0,(a0)
		bsr	audioInitSystem				; in: d0
		bsr	audioSystemStart

		lea	txtAudioSurroundOn,a0
		jsr	installMessage
amsOut
		rts







		data


			IFEQ LANGUAGE
txtAudioOn		dc.b	"Audio system turned on",0
txtAudioOff		dc.b	"Audio system turned off",0
txtAudioMono		dc.b	"Audio system switched to mono system",0
txtAudioStereo		dc.b	"Audio system switched to stereo system",0
txtAudioSurroundOn	dc.b	"Surround effect for audio system turned on",0
txtAudioSurroundOff	dc.b	"Surround effect for audio system turned off",0
			ELSE
txtAudioOn		dc.b	"Audiosystem ist eingeschaltet",0
txtAudioOff		dc.b	"Audiosystem ist ausgeschaltet",0
txtAudioMono		dc.b	"Audiosystem verwendet Mono-Kanal",0
txtAudioStereo		dc.b	"Audiosystem verwendet Stereo-Kanal",0
txtAudioSurroundOn	dc.b	"Surroundeffekt des Audiosystems ist eingeschaltet",0
txtAudioSurroundOff	dc.b	"Surroundeffekt des Audiosystems ist ausgeschaltet",0
			ENDC
			even









