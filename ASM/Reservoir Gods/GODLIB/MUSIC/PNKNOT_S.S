**************************************************************************************
*	PNKNOT_S.S
*
*	Pink Note functions
*
*	Plays YM2149F sounds in conjunction with existing chip music
*	useful for sound fx in games
*
*	[c] 2001 Reservoir Gods
**************************************************************************************

**************************************************************************************
;	EXPORTS / IMPORTS
**************************************************************************************


	export	PinkNote_Player

	export	PinkNote_NotePlayChannelA
	export	PinkNote_NotePlayChannelB
	export	PinkNote_NotePlayChannelC

	import	gPinkNoteChannel


**************************************************************************************
;	STRUCTS
**************************************************************************************

	OFFSET

oPinkNoteChannel_Index:			ds.l	1
oPinkNoteChannel_pNotes:		ds.l	1
oPinkNoteChannel_Pause:			ds.w	1
oPinkNoteChannel_ActiveFlag:	ds.b	1
oPinkNoteChannel_LoopingFlag:	ds.b	1

oPinkNoteChannel_ToneFreq:		ds.w	1
oPinkNoteChannel_EnvFreq:		ds.w	1

oPinkNoteChannel_Volume:		ds.b	1
oPinkNoteChannel_NoiseTone:		ds.b	1
oPinkNoteChannel_NoiseFreq:		ds.b	1
oPinkNoteChannel_EnvType:		ds.b	1

oPinkNoteChannel_sizeof:		ds.b	1

	EVEN

	OFFSET

oPinkNote_Control:			ds.b	1
oPinkNote_Data0:			ds.b	1
oPinkNote_Data1:			ds.b	1
oPinkNote_Data2:			ds.b	1

	EVEN

**************************************************************************************
	TEXT
**************************************************************************************

*------------------------------------------------------------------------------------*
* FUNCTION : PinkNote_Player( void )
* ACTION   : processes note data and plays YM sounds.
*            should be called immediately after call to interrupt chip player
* CREATION : 04.02.01 PNK
*------------------------------------------------------------------------------------*

PinkNote_Player:
	movem.l	d0-d1/a0-a2,-(a7)									;	save registers

.PlayA:
	lea		gPinkNoteChannel+(oPinkNoteChannel_sizeof*0),a0		;	base of ChannelA data
	tst.b	oPinkNoteChannel_ActiveFlag(a0)						;	is ChannelA on?
	beq.s	.PlayB												;	no

	bsr		PinkNote_ProcessChannel								;	read data from note stream
	bsr		PinkNote_NotePlayChannelA							;	play sounds on ChannelA

.PlayB:
	lea		gPinkNoteChannel+(oPinkNoteChannel_sizeof*1),a0		;	base of ChannelB data
	tst.b	oPinkNoteChannel_ActiveFlag(a0)						;	is ChannelB on?
	beq.s	.PlayC												;	no

	bsr		PinkNote_ProcessChannel								;	read data from note stream
	bsr		PinkNote_NotePlayChannelB							;	play sounds on ChannelB

.PlayC:
	lea		gPinkNoteChannel+(oPinkNoteChannel_sizeof*2),a0		;	base of ChannelC data
	tst.b	oPinkNoteChannel_ActiveFlag(a0)						;	is ChannelC on?
	beq.s	.PlayRts											;	no

	bsr		PinkNote_ProcessChannel								;	read data from note stream
	bsr		PinkNote_NotePlayChannelC							;	play sounds on ChannelC

.PlayRts:
	movem.l	(a7)+,d0-d1/a0-a2									;	restore registers
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : PinkNote_ProcessNote( sPinkNote * apNote, sPinkNoteChannel * apChannel )
* ACTION   : reads all data values from a note into the relevant channel fields
* CREATION : 04.02.01 PNK
*------------------------------------------------------------------------------------*

PinkNote_ProcessChannel:

	tst.w	oPinkNoteChannel_Pause(a0)			;	should we pause the note stream?
	beq.s	.noPause							;	not a chance

	subq.w	#1,oPinkNoteChannel_Pause(a0)		;	dec pause counter
	rts

.noPause:
	move.l	oPinkNoteChannel_pNotes(a0),a1		;	get pointer to note stream
	add.l	oPinkNoteChannel_Index(a0),a1		;	get to place in stream

	move.b	oPinkNote_Control(a1),d0			;	read control byte
	andi.b	#7,d0								;	keep it legal
	lsl.w	#2,d0								;	as index into table
	jmp		(2,pc,d0.w)							;	jump to relevant rout

PinkNote_ProcessFuncTable:

	bra.w	PinkNote_ProcessVolume				;	0
	bra.w	PinkNote_ProcessNoiseTone			;	1
	bra.w	PinkNote_ProcessToneFreq			;	2
	bra.w	PinkNote_ProcessNoiseFreq			;	3
	bra.w	PinkNote_ProcessEnvelope			;	4

	bra.w	PinkNote_ProcessPause				;	5
	bra.w	PinkNote_ProcessLoop				;	6
	bra.w	PinkNote_ProcessEnd					;	7

PinkNote_ProcessVolume:
	move.b	oPinkNote_Data0(a1),oPinkNoteChannel_Volume(a0)
	addq.l	#4,oPinkNoteChannel_Index(a0)
	rts

PinkNote_ProcessNoiseTone:
	move.b	oPinkNote_Data0(a1),oPinkNoteChannel_NoiseTone(a0)
	addq.l	#4,oPinkNoteChannel_Index(a0)
	rts

PinkNote_ProcessToneFreq:
	move.w	oPinkNote_Data1(a1),oPinkNoteChannel_ToneFreq(a0)
	addq.l	#4,oPinkNoteChannel_Index(a0)
	rts

PinkNote_ProcessNoiseFreq:
	move.b	oPinkNote_Data0(a1),oPinkNoteChannel_NoiseFreq(a0)
	addq.l	#4,oPinkNoteChannel_Index(a0)
	rts

PinkNote_ProcessEnvelope:
	move.b	oPinkNote_Data0(a1),oPinkNoteChannel_EnvType(a0)
	move.w	oPinkNote_Data1(a1),oPinkNoteChannel_EnvFreq(a0)
	addq.l	#4,oPinkNoteChannel_Index(a0)
	rts

PinkNote_ProcessPause:
	move.w	oPinkNote_Data1(a1),oPinkNoteChannel_Pause(a0)
	addq.l	#4,oPinkNoteChannel_Index(a0)
	rts

PinkNote_ProcessLoop:
	st.b	oPinkNoteChannel_LoopingFlag(a0)
	clr.l	oPinkNoteChannel_Index(a0)
	rts

PinkNote_ProcessEnd:
	clr.b	oPinkNoteChannel_ActiveFlag(a0)
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : PinkNote_NotePlayChannelA( U32 * apNote )
* ACTION   : plays a note on channel A
* CREATION : 04.02.01 PNK
*------------------------------------------------------------------------------------*

PinkNote_NotePlayChannelA:

	movea.w	#$8800,a1								;	YM2149F register base
	lea		2(a1),a2								;	YM2149F write regiter

	move.b	#8,(a1)									;	select VolumeA register
	move.b	oPinkNoteChannel_Volume(a0),d0			;	read volume
	move.b	d0,(a2)									;	set VolumeA

	btst.b	#4,d0									;	are we using envelopes?
	beq.s	.noEnvA									;	not likely matey

	move.b	#12,(a1)								;	select EnvelopeFreg_HI register
	move.b	oPinkNoteChannel_EnvFreq+0(a0),(a2)		;	set EnvelopeFreq_HI
	move.b	#11,(a1)								;	select EnvelopeFreg_LO register
	move.b	oPinkNoteChannel_EnvFreq+1(a0),(a2)		;	set EnvelopeFreq_LO

	move.b	#13,(a1)								;	select EnvelopeType register
	move.b	(a1),d0									;	read EnvelopeType from YM
	move.b	oPinkNoteChannel_EnvType(a0),d1			;	desired EnvelopeType
	cmp.b	d0,d1									;	is this EnvelopeType in YM
	beq.s	.noEnvA									;	yes, don't set again (resets freq clock)

	move.b	d1,(a2)									;	set	EnvelopeType

.noEnvA:
	
	move.b	oPinkNoteChannel_NoiseTone(a0),d0		;	read NoiseTone flags
	andi.b	#%00001001,d0							;	ensure no naughty bits
	move.b	#7,(a1)									;	select NoiseToneRegister
	move.b	(a1),d1									;	read current NoiseTone settings
	andi.b	#%11110110,d1							;	clear channel A bits
	or.b	d0,d1									;	set new channel A bits
	move.b	d1,(a2)									;	set new Noise/Tone

	btst.b	#3,d1									;	is there noise on this channel?
	bne.s	.noNoiseA								;	no, don't set noise frequency

	move.b	#6,(a1)									;	select NoiseFrequency register
	move.b	oPinkNoteChannel_NoiseFreq(a0),(a2)		;	set NoiseFrequncy register

.noNoiseA:

	move.b	#1,(a1)									;	select ToneFrequencyA_HI register
	move.b	oPinkNoteChannel_ToneFreq+0(a0),(a2)	;	set ToneFrequencyA_HI register
	move.b	#0,(a1)									;	select ToneFrequencyA_LO register
	move.b	oPinkNoteChannel_ToneFreq+1(a0),(a2)	;	set ToneFrequencyA_LO register

	rts


*------------------------------------------------------------------------------------*
* FUNCTION : PinkNote_NotePlayChannelB( U32 * apNote )
* ACTION   : plays a note on channel B
* CREATION : 04.02.01 PNK
*------------------------------------------------------------------------------------*

PinkNote_NotePlayChannelB:

	movea.w	#$8800,a1								;	YM2149F register base
	lea		2(a1),a2								;	YM2149F write regiter

	move.b	#9,(a1)									;	select VolumeB register
	move.b	oPinkNoteChannel_Volume(a0),d0			;	read volume
	move.b	d0,(a2)									;	set VolumeB

	btst.b	#4,d0									;	are we using envelopes?
	beq.s	.noEnvB									;	not likely matey

	move.b	#12,(a1)								;	select EnvelopeFreg_HI register
	move.b	oPinkNoteChannel_EnvFreq+0(a0),(a2)		;	set EnvelopeFreq_HI
	move.b	#11,(a1)								;	select EnvelopeFreg_LO register
	move.b	oPinkNoteChannel_EnvFreq+1(a0),(a2)		;	set EnvelopeFreq_LO

	move.b	#13,(a1)								;	select EnvelopeType register
	move.b	(a1),d0									;	read EnvelopeType from YM
	move.b	oPinkNoteChannel_EnvType(a0),d1			;	desired EnvelopeType
	cmp.b	d0,d1									;	is this EnvelopeType in YM
	beq.s	.noEnvB									;	yes, don't set again (resets freq clock)

	move.b	d1,(a2)									;	set	EnvelopeType

.noEnvB:
	
	move.b	oPinkNoteChannel_NoiseTone(a0),d0		;	read NoiseTone flags
	add.b	d0,d0									;	shift into channel B
	andi.b	#%00010010,d0							;	ensure no naughty bits
	move.b	#7,(a1)									;	select NoiseToneRegister
	move.b	(a1),d1									;	read current NoiseTone settings
	andi.b	#%11101101,d1							;	clear channel A bits
	or.b	d0,d1									;	set new channel A bits
	move.b	d1,(a2)									;	set new Noise/Tone

	btst.b	#4,d1									;	is there noise on this channel?
	bne.s	.noNoiseB								;	no, don't set noise frequency

	move.b	#6,(a1)									;	select NoiseFrequency register
	move.b	oPinkNoteChannel_NoiseFreq(a0),(a2)		;	set NoiseFrequncy register

.noNoiseB:

	move.b	#3,(a1)									;	select ToneFrequencyB_HI register
	move.b	oPinkNoteChannel_ToneFreq+0(a0),(a2)	;	set ToneFrequencyB_HI register
	move.b	#2,(a1)									;	select ToneFrequencyB_LO register
	move.b	oPinkNoteChannel_ToneFreq+1(a0),(a2)	;	set ToneFrequencyB_LO register

	rts


*------------------------------------------------------------------------------------*
* FUNCTION : PinkNote_NotePlayChannelB( U32 * apNote )
* ACTION   : plays a note on channel B
* CREATION : 04.02.01 PNK
*------------------------------------------------------------------------------------*

PinkNote_NotePlayChannelC:

	movea.w	#$8800,a1								;	YM2149F register base
	lea		2(a1),a2								;	YM2149F write regiter

	move.b	#10,(a1)								;	select VolumeC register
	move.b	oPinkNoteChannel_Volume(a0),d0			;	read volume
	move.b	d0,(a2)									;	set VolumeC

	btst.b	#4,d0									;	are we using envelopes?
	beq.s	.noEnvC									;	not likely matey

	move.b	#12,(a1)								;	select EnvelopeFreg_HI register
	move.b	oPinkNoteChannel_EnvFreq+0(a0),(a2)		;	set EnvelopeFreq_HI
	move.b	#11,(a1)								;	select EnvelopeFreg_LO register
	move.b	oPinkNoteChannel_EnvFreq+1(a0),(a2)		;	set EnvelopeFreq_LO

	move.b	#13,(a1)								;	select EnvelopeType register
	move.b	(a1),d0									;	read EnvelopeType from YM
	move.b	oPinkNoteChannel_EnvType(a0),d1			;	desired EnvelopeType
	cmp.b	d0,d1									;	is this EnvelopeType in YM
	beq.s	.noEnvC									;	yes, don't set again (resets freq clock)

	move.b	d1,(a2)									;	set	EnvelopeType

.noEnvC:
	
	move.b	oPinkNoteChannel_NoiseTone(a0),d0		;	read NoiseTone flags
	lsl.b	#2,d0									;	shift into channel B
	andi.b	#%00100100,d0							;	ensure no naughty bits
	move.b	#7,(a1)									;	select NoiseToneRegister
	move.b	(a1),d1									;	read current NoiseTone settings
	andi.b	#%11011011,d1							;	clear channel C bits
	or.b	d0,d1									;	set new channel C bits
	move.b	d1,(a2)									;	set new Noise/Tone

	btst.b	#5,d1									;	is there noise on this channel?
	bne.s	.noNoiseC								;	no, don't set noise frequency

	move.b	#6,(a1)									;	select NoiseFrequency register
	move.b	oPinkNoteChannel_NoiseFreq(a0),(a2)		;	set NoiseFrequncy register

.noNoiseC:

	move.b	#5,(a1)									;	select ToneFrequencyC_HI register
	move.b	oPinkNoteChannel_ToneFreq+0(a0),(a2)	;	set ToneFrequencyC_HI register
	move.b	#4,(a1)									;	select ToneFrequencyA_LO register
	move.b	oPinkNoteChannel_ToneFreq+1(a0),(a2)	;	set ToneFrequencyC_LO register

	rts


**************************************************************************************
	BSS
**************************************************************************************

	ALIGN	4
	
gPinkNoteChannel:	ds.b	(oPinkNoteChannel_sizeof*3)
