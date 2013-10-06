**************************************************************************************
*	AUDIO_S.S
*
*	AUDIO functions
*
*	[c] 2001 Reservoir Gods
**************************************************************************************

**************************************************************************************
;	EXPORTS / IMPORTS
**************************************************************************************

	export	gAudioDmaPlayingFlag
	export	Audio_ReplayEndInt
	export	Audio_SoundChipOff
	export	Audio_SaveYM
	export	Audio_RestoreYM
	export	Audio_SaveDmaSte
	export	Audio_RestoreDmaSte
	export	Audio_SaveDmaFalcon
	export	Audio_RestoreDmaFalcon
	export	Audio_MicroWireWrite


**************************************************************************************
	TEXT
**************************************************************************************

*------------------------------------------------------------------------------------*
* FUNCTION : Audio_ReplayEndInt
* ACTION   : interrupt at end of replay
* CREATION : 11.04.01 PNK
*------------------------------------------------------------------------------------*

Audio_ReplayEndInt:
	clr.b	gAudioDmaPlayingFlag
	bclr.b	#7,$fffffa0f.w			; signal end of ikbd interrupt
	
	rte


*------------------------------------------------------------------------------------*
* FUNCTION : Audio_SoundChipOff
* ACTION   : zeroes volume, disables tone+noise
* CREATION : 11.04.01 PNK
*------------------------------------------------------------------------------------*

Audio_SoundChipOff:
	movem.l	a0/a1,-(a7)				; save registers
	move.w	sr,-(a7)
	
	ori.w	#$0700,sr

	movea.w	#$8800,a0				; YM2149F register base
	lea		2(a0),a1				; YM2149F write regiter

	move.b	#8,(a0)					; select volume A
	clr.b	(a1)					; volume = 0
	move.b	#9,(a0)					; select volume B
	clr.b	(a1)					; volume = 0
	move.b	#10,(a0)				; select volume C
	clr.b	(a1)					; volume = 0

	move.b	#7,(a0)					; mixer control
	move.b	(a0),d0					; read current status
	andi.b	#%11000000,d0			; leave port flow bits intact, tone off
	or.b	#%111000,d0				; noise off
	move.b	d0,(a1)					; write back new mixer status

	move.w	(a7)+,sr
	movem.l	(a7)+,a0/a1				; restore registers

	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Audio_SaveYM
* ACTION   : saves ym registers
* CREATION : 11.04.01 PNK
*------------------------------------------------------------------------------------*

Audio_SaveYM:
	movem.l	d0/a0/a1,-(a7)
	move.w	sr,-(a7)

	ori.w	#$0700,sr

	movea.w	#$8800,a0				; YM2149F register base
	lea		gAudioSavedYM+16,a1

	moveq	#15,d0
.loop:
	move.b	d0,(a0)
	move.b	(a0),-(a1)
	dbra	d0,.loop

	move.w	(a7)+,sr
	movem.l	(a7)+,d0/a0/a1
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Audio_RestoreYM
* ACTION   : restores ym registers
* CREATION : 11.04.01 PNK
*------------------------------------------------------------------------------------*

Audio_RestoreYM:

	movem.l	d0/a0-a2,-(a7)
	move.w	sr,-(a7)

	ori.w	#$0700,sr

	movea.w	#$8800,a0				; YM2149F register base
	lea		2(a0),a1
	lea		gAudioSavedYM+16,a2

	moveq	#15,d0
.loop:
	move.b	d0,(a0)
	move.b	-(a2),(a1)
	dbra	d0,.loop

	move.w	(a7)+,sr
	movem.l	(a7)+,d0/a0-a2
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Audio_SaveDmaSte
* ACTION   : saves ym registers
* CREATION : 11.04.01 PNK
*------------------------------------------------------------------------------------*

Audio_SaveDmaSte:
	move.l	a0,-(a7)
	move.w	sr,-(a7)

	ori.w	#$0700,sr

	lea		gAudioSavedDma,a0
	move.b	$ffff8901,(a0)+
	move.b	$ffff8921,(a0)+

	move.w	(a7)+,sr
	move.l	(a7)+,a0
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Audio_RestoreDmaSte
* ACTION   : saves ym registers
* CREATION : 11.04.01 PNK
*------------------------------------------------------------------------------------*

Audio_RestoreDmaSte:
	move.l	a0,-(a7)
	move.w	sr,-(a7)

	ori.w	#$0700,sr

	lea		gAudioSavedDma,a0
	move.b	(a0)+,$ffff8901
	move.b	(a0)+,$ffff8921

	move.w	(a7)+,sr
	move.l	(a7)+,a0
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Audio_SaveDmaFalcon
* ACTION   : saves ym registers
* CREATION : 11.04.01 PNK
*------------------------------------------------------------------------------------*

Audio_SaveDmaFalcon:
	move.l	a0,-(a7)
	move.w	sr,-(a7)

	ori.w	#$0700,sr

	lea		gAudioSavedDma,a0
	move.b	$ffff8900,(a0)+
	move.b	$ffff8901,(a0)+
	move.b	$ffff8920,(a0)+
	move.b	$ffff8921,(a0)+

	move.w	$ffff8930,(a0)+
	move.w	$ffff8932,(a0)+
	move.b	$ffff8934,(a0)+
	move.b	$ffff8935,(a0)+
	move.b	$ffff8936,(a0)+
	move.b	$ffff8937,(a0)+
	move.b	$ffff8938,(a0)+
	move.b	$ffff8939,(a0)+
	move.w	$ffff893a,(a0)+
	move.b	$ffff893c,(a0)+
	move.b	$ffff8941,(a0)+
	move.b	$ffff8943,(a0)+

	move.w	(a7)+,sr
	move.l	(a7)+,a0
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Audio_RestoreDmaFalcon
* ACTION   : saves ym registers
* CREATION : 11.04.01 PNK
*------------------------------------------------------------------------------------*

Audio_RestoreDmaFalcon:
	move.l	a0,-(a7)
	move.w	sr,-(a7)

	ori.w	#$0700,sr

	lea		gAudioSavedDma,a0
	move.b	(a0)+,$ffff8900
	move.b	(a0)+,$ffff8901
	move.b	(a0)+,$ffff8920
	move.b	(a0)+,$ffff8921

	move.w	(a0)+,$ffff8930
	move.w	(a0)+,$ffff8932
	move.b	(a0)+,$ffff8934
	move.b	(a0)+,$ffff8935
	move.b	(a0)+,$ffff8936
	move.b	(a0)+,$ffff8937
	move.b	(a0)+,$ffff8938
	move.b	(a0)+,$ffff8939
	move.w	(a0)+,$ffff893a
	move.b	(a0)+,$ffff893c
	move.b	(a0)+,$ffff8941
	move.b	(a0)+,$ffff8943

	move.w	(a7)+,sr
	move.l	(a7)+,a0
	rts

Audio_MicroWireWrite:

	move.w	#$07FF,$FFFF8924
	move.w	d0,$FFFF8922

.wait:
	cmp.w	#$07FF,$FFFF8924
	bne.s	.wait

	move.w	d0,$FFFF8922

	rts

**************************************************************************************
	DATA
**************************************************************************************

gAudioDmaPlayingFlag:	dc.b	0


**************************************************************************************
	BSS
**************************************************************************************

gAudioSavedYM:			ds.b	16
gAudioSavedDma:			ds.b	20
