**************************************************************************************
*	AMIXER_S.S
*
*	AUDIO mixer functions
*
*	[c] 2001 Reservoir Gods
**************************************************************************************

**************************************************************************************
;	EXPORTS / IMPORTS
**************************************************************************************

	export	AudioMixer_Vbl

	export	gpAudioMixerBuffer
	export	gpAudioMixerSilence
	export	gpAudioMixerMulTable
	export	gAudioMixerLockFlag
	export	gAudioMixerBufferOffset
	export	gAudioMixerSamples
	export	gAudioMixerEnableFlag


**************************************************************************************
;	EQUATES
**************************************************************************************

eAMIXER_BUFFER_SIZE		EQU	(8*1024)
eAMIXER_PLAY_OFFSET		EQU	(6*1024)
eAMIXER_CHANNEL_LIMIT	EQU	2

**************************************************************************************
;	STRUCTS
**************************************************************************************

	OFFSET

sAmixerSpl_pStart:		ds.l	1
sAmixerSpl_pCurrent:	ds.l	1
sAmixerSpl_Length:		ds.l	1
sAmixerSpl_Type:		ds.b	1
sAmixerSpl_Volume:		ds.b	1
sAmixerSpl_StereoPos:	ds.b	1
sAmixerSpl_ActiveFlag:	ds.b	1
sAmixerSpl_sizeof:		ds.b	1


**************************************************************************************
	TEXT
**************************************************************************************

*------------------------------------------------------------------------------------*
* FUNCTION : Audio_MixerVbl
* ACTION   : interrupt based mixer
* CREATION : 11.04.01 PNK
*------------------------------------------------------------------------------------*

AudioMixer_Vbl:
	tas.b	gAudioMixerLockFlag			; already in a mixer interrupt?
	bne		.locked						; yes, don't try further mixing

	movem.l	d0-a6,-(a7)					; save registers

	lea		gAudioMixerSamples,a0
	lea		sAmixerSpl_sizeof(a0),a1

	move.l	gpAudioMixerMulTable,a2
	moveq	#0,d0
	move.b	sAmixerSpl_StereoPos(a0),d0
	lsl.w	#8,d0
	lea		(a2,d0.l),a3				; stereo pos 0
	moveq	#0,d0
	move.b	sAmixerSpl_Volume(a0),d0
	lsl.w	#8,d0
	lea		(a2,d0.l),a4				; volume 0

	moveq	#0,d0
	move.b	sAmixerSpl_StereoPos(a1),d0
	lsl.w	#8,d0
	lea		(a2,d0.l),a5				; stereo pos 1
	moveq	#0,d0
	move.b	sAmixerSpl_Volume(a1),d0
	lsl.w	#8,d0
	lea		(a2,d0.l),a6				; volume 1

	move.l	sAmixerSpl_pCurrent(a0),a0
	move.l	sAmixerSpl_pCurrent(a1),a1

	movea.w	#$8909,a2					; dma sound frame ptr
	movep.l	(a2),d7						; read address
	lsr.l	#8,d7						; ignore frame end address high byte

	move.l	gpAudioMixerBuffer,a2
	sub.l	a2,d7
	move.l	gAudioMixerBufferOffset,d6
	and.l	#(eAMIXER_BUFFER_SIZE-1),d6
	lea		(a2,d6.l),a2

	and.l	#(eAMIXER_BUFFER_SIZE-1)&$FFFFFFF8,d7
	move.l	d7,gAudioMixerBufferOffset
	sub.l	d6,d7
	bpl.s	.lpls

	move.l	#(eAMIXER_BUFFER_SIZE),d0
	add.l	d0,d7
	sub.l	d6,d0
	bsr		AudioMixer_DoMixing2

	move.l	gpAudioMixerBuffer,a2
	move.l	gAudioMixerBufferOffset,d0
	bsr		AudioMixer_DoMixing2
	bra.s	.update
.lpls:
	move.l	d7,d0
	bsr		AudioMixer_DoMixing2

.update:
	move.l	d7,d0
	bsr		AudioMixer_UpdateSamples

	clr.b	gAudioMixerLockFlag			; signal end of mixing
	movem.l	(a7)+,d0-a6					; restore registers

.locked:

	rts

*------------------------------------------------------------------------------------*
* FUNCTION : Audio_DoMixing( U8 * apSpl0, U8 * apSpl1, U8 * apBuffer, U32 aBytes )
* ACTION   : interrupt based mixer
* CREATION : 11.04.01 PNK
*------------------------------------------------------------------------------------*

AudioMixer_DoMixing:

	lsr.l	#3,d0
	subq.w	#1,d0
	bmi.s	.nomix

.loop:

	move.b	(a0)+,d1					; byte of sample0
	lsl.w	#8,d1						; into top byte
	move.b	(a1)+,d1					; byte of sample1

	move.w	d1,(a2)+					; write L.R into buffer
	move.w	d1,(a2)+					; write L.R into buffer
	move.w	d1,(a2)+					; write L.R into buffer
	move.w	d1,(a2)+					; write L.R into buffer

	dbra	d0,.loop

.nomix:
	rts


AudioMixer_DoMixing2:

	lsr.l	#3,d0
	subq.w	#1,d0
	bmi.s	.nomix

.loop:
	moveq	#0,d1
	move.b	(a0)+,d1					; byte of sample
	move.b	(a3,d1.w),d2				; *stereo pos
	sub.b	d2,d1
;	move.b	(a4,d1.w),d1				; *volume
;	move.b	(a4,d2.w),d2				; *volume

	moveq	#0,d3
	move.b	(a1)+,d3					; byte of sample
	move.b	(a5,d3.w),d4				; *stereo pos
	sub.b	d4,d3
;	move.b	(a6,d3.w),d3				; *volume
;	move.b	(a6,d4.w),d4				; *volume

	add.b	d3,d1
	add.b	d4,d2
		
	lsl.w	#8,d1						; into top byte
	move.b	d2,d1						; byte of sample1

	move.w	d1,(a2)+					; write L.R into buffer
	move.w	d1,(a2)+					; write L.R into buffer
	move.w	d1,(a2)+					; write L.R into buffer
	move.w	d1,(a2)+					; write L.R into buffer

	dbra	d0,.loop

.nomix:
	rts


AudioMixer_DoMixing3:

	lsr.l	#3,d0
	subq.w	#1,d0
	bmi.s	.nomix

	moveq	#0,d1
	move.b	(a0)+,d1					; byte of sample
	move.b	(a3,d1.w),d2				; *stereo pos
	sub.b	d2,d1

	moveq	#0,d3
	move.b	(a1)+,d3					; byte of sample
	move.b	(a5,d3.w),d4				; *stereo pos
	sub.b	d4,d3

	add.b	d3,d1
	add.b	d4,d2
.loop:

	moveq	#0,d3
	move.b	(a0)+,d3					; byte of sample
	move.b	(a3,d3.w),d4				; *stereo pos
	sub.b	d4,d3

	moveq	#0,d5
	move.b	(a1)+,d5					; byte of sample
	move.b	(a5,d5.w),d6				; *stereo pos
	sub.b	d6,d5

	add.b	d5,d3
	add.b	d6,d4
		
	move.b	d3,d5
	move.b	d4,d6
	sub.b	d1,d5
	sub.b	d4,d6
	asr.w	#2,d5
	asr.w	#2,d6

	move.b	d1,(a2)+
	move.b	d2,(a2)+
	add.b	d5,d1
	add.b	d6,d2
	move.b	d1,(a2)+
	move.b	d2,(a2)+
	add.b	d5,d1
	add.b	d6,d2
	move.b	d1,(a2)+
	move.b	d2,(a2)+
	add.b	d5,d1
	add.b	d6,d2
	move.b	d1,(a2)+
	move.b	d2,(a2)+

	move.w	d3,d1
	move.w	d4,d2

	dbra	d0,.loop

.nomix:
	rts

*------------------------------------------------------------------------------------*
* FUNCTION : AudioMixer_UpdateSamples( U32 aBytes )
* ACTION   : interrupt based mixer
* CREATION : 11.04.01 PNK
*------------------------------------------------------------------------------------*

AudioMixer_UpdateSamples:

	lsr.l	#3,d0
	moveq	#eAMIXER_CHANNEL_LIMIT-1,d1
	move.l	gpAudioMixerSilence,a1
	lea		gAudioMixerSamples,a0

.loop:
	
	tst.b	sAmixerSpl_ActiveFlag(a0)
	beq.s	.next

.active:
	move.l	sAmixerSpl_pCurrent(a0),d2
	add.l	d0,d2
	move.l	d2,sAmixerSpl_pCurrent(a0)
	sub.l	sAmixerSpl_pStart(a0),d2
	sub.l	sAmixerSpl_Length(a0),d2
	bmi.s	.next

	move.l	a1,sAmixerSpl_pStart(a0)
	move.l	a1,sAmixerSpl_pCurrent(a0)
	clr.b	sAmixerSpl_ActiveFlag(a0)
	
.next:
	lea		sAmixerSpl_sizeof(a0),a0
	dbra	d1,.loop

	rts


**************************************************************************************
	DATA
**************************************************************************************

gpAudioMixerBuffer:			dc.l	0
gpAudioMixerSilence:		dc.l	0
gpAudioMixerMulTable:		dc.l	0
gAudioMixerBufferOffset:	dc.l	0
gAudioMixerLockFlag:		dc.b	0
gAudioMixerEnableFlag:		dc.b	0


**************************************************************************************
	BSS
**************************************************************************************

gAudioMixerSamples:			ds.l	(sAmixerSpl_sizeof*eAMIXER_CHANNEL_LIMIT)

