** Include file for PS3M
** For version 0.950 020+ / 03.03.1995
** Copyright 1994-95 Jarno Paananen

	ifnd	PS3M_I

PS3M_I	set	1

;/***************************************************************************\
;*       struct mChanBlock
;*       -----------------
;* Description:  PS3M mixer channel block
;\***************************************************************************/


	STRUCTURE mChanBlock,0
	LONG	mStart
	LONG	mLength
	LONG	mLStart
	LONG	mLLength
	UWORD	mPeriod
	UWORD	mVolume
	LONG	mFPos
	UBYTE	mLoop
	UBYTE	mOnOff
	LABEL	mChanBlock_SIZE


;/***************************************************************************\
;*       struct s3mChanBlock
;*       -------------------
;* Description:  S3M and XM player channel block
;\***************************************************************************/

	STRUCTURE s3mChanBlock,0
	UBYTE	nt
	UBYTE	inst
	UBYTE	vol
	UBYTE	cmd
	UBYTE	info
	UBYTE	flgs

	APTR	sample
	UWORD	linst
	UWORD	period
	UWORD	volume
	UBYTE	note
	UBYTE	lastcmd

	UWORD	toperiod
	UBYTE	notepspd

	UBYTE	panning

	UWORD	rVolume
	UWORD	rPeriod
	UWORD	fadeOut
	UBYTE	fading
	UBYTE	keyoff

	UBYTE	age
	UBYTE	filler

	UBYTE	retrigcn
	UBYTE	vibcmd
	UBYTE	vibpos
	UBYTE	lastOffset

	UBYTE	volEnvOn
	UBYTE	volCurPnt
	UWORD	volEnvX
	UWORD	volEnvY
	UWORD	volEnvDelta
	UBYTE	volRecalc
	UBYTE	volSustained

	UBYTE	panEnvOn
	UBYTE	panCurPnt
	UWORD	panEnvX
	UWORD	panEnvY
	UWORD	panEnvDelta
	UBYTE	panRecalc
	UBYTE	panSustained

	LABEL	s3mChanBlock_SIZE


;/***************************************************************************\
;*       struct s3mInstHdr
;*       -----------------
;* Description:  S3M instrument header
;\***************************************************************************/


	STRUCTURE s3mInstHdr,0

	UBYTE	instype
	STRUCT	insdosname,12
	UBYTE	inssig1
	UWORD	insmemseg
	LONG	inslength
	LONG	insloopbeg
	LONG	insloopend
	UBYTE	insvol
	UBYTE	insdsk
	UBYTE	inspack
	UBYTE	insflags
	UWORD	insloc2spd
	UWORD	inshic2spd
	STRUCT	inssig2,4
	UWORD	insgvspos
	UWORD	insint512
	LONG	insintlastused
	STRUCT	insname,28
	STRUCT	inssig,4
	LABEL	s3mInstHdr_SIZE


;/***************************************************************************\
;*       struct s3mHeader
;*       ----------------
;* Description:  S3M main header
;\***************************************************************************/

	STRUCTURE s3mHeader,0

	STRUCT	name,28
	UBYTE	sig1
	UBYTE	type
	STRUCT	sig2,2
	UWORD	ordernum
	UWORD	insnum
	UWORD	patnum
	UWORD	flags
	UWORD	cwtv
	UWORD	ffv
	STRUCT	s3msig,4
	UBYTE	mastervol
	UBYTE	initialspeed
	UBYTE	initialtempo
	UBYTE	mastermul
	STRUCT	sig3,12
	STRUCT	chanset,32
	UBYTE	orders
	;UWORD	*parapins
	;UWORD   *parappat
	LABEL	s3mHeader_SIZE


;/***************************************************************************\
;*       struct xmHeader
;*       ---------------
;* Description:  Extended Module file header
;\***************************************************************************/

	STRUCTURE xmHeader,0

	STRUCT	xmExtended,17		; "Extended Module: "
	STRUCT	xmName,20		; module name
	UBYTE	xmNum1A			; 0x1A
	STRUCT	xmTrackerName,20	; tracker name
	UWORD	xmVersion		; version number, major-minor
	LONG	xmHdrSize		; header size
	UWORD	xmSongLength		; song length
	UWORD	xmRestart		; restart position
	UWORD	xmNumChans		; number of channels
	UWORD	xmNumPatts		; number of patterns
	UWORD	xmNumInsts		; number of instruments
	UWORD	xmFlags			; flags
	UWORD	xmSpeed			; initial speed
	UWORD	xmTempo			; initial tempo
	STRUCT	xmOrders,256		; pattern order table
	LABEL	xmHeader_SIZE

; Flag bits:

xmLinearFreq = 0			; linear frequency table


;/***************************************************************************\
;*       struct xmPattHdr
;*       ----------------
;* Description:  Fasttracker 2 Extended Module pattern header
;\***************************************************************************/

	STRUCTURE xmPattHdr,0

	LONG	xmPattHdrLength		; pattern header length
	UBYTE	xmPackType		; packing type (now 0)
	UWORD	xmNumRows		; number of rows
	UWORD	xmPattDataSize		; pattern data size
	LABEL	xmPattData		; packed pattern data
	LABEL	xmPattHdr_SIZE



;/***************************************************************************\
;*       struct xmInstHdr
;*       ----------------
;* Description:  Fasttracker 2 Extended Module instrument header
;\***************************************************************************/

	STRUCTURE xmInstHdr,0
	
	LONG	xmInstSize		; instrument size
	STRUCT	xmInstName,22		; instrument filename
	UBYTE	xmInstType		; instrument type (now 0)
	UWORD	xmNumSamples		; number of samples in instrument
	LABEL	xmInstHdr_SIZE

; If numSamples > 0, this will follow

	LONG	xmSmpHdrSize		; sample header size
	STRUCT	xmSmpNoteNums,96	; sample numbers for notes
	STRUCT	xmVolEnv,48		; volume envelope points
	STRUCT	xmPanEnv,48		; panning envelope points
	UBYTE	xmNumVolPnts		; number of volume points
	UBYTE	xmNumPanPnts		; number of panning points
	UBYTE	xmVolSustain		; volume sustain point
	UBYTE	xmVolLoopStart		; volume loop start point
	UBYTE	xmVolLoopEnd		; volume loop end point
	UBYTE	xmPanSustain		; panning sustain point
	UBYTE	xmPanLoopStart		; panning loop start point
	UBYTE	xmPanLoopEnd		; panning loop end point
	UBYTE	xmVolType		; volume envelope flags
	UBYTE	xmPanType		; panning envelope flags

	UBYTE	xmVibType		; vibrato type
	UBYTE	xmVibSweep		; vibrato sweep
	UBYTE	xmVibDepth		; vibrato depth
	UBYTE	xmVibRate		; vibrato rate
	UWORD	xmVolFadeout		; volume fadeout
	UWORD	xmReserved
	LABEL	xmInstHdr2_SIZE


; Envelope flags:

xmEnvOn = 0				; envelope on
xmEnvSustain = 1			; envelope sustain on
xmEnvLoop = 2				; envelope loop on


;/***************************************************************************\
;*       struct xmSmpHdr
;*       ---------------
;* Description:  Fasttracker 2 Extended Module sample header
;\***************************************************************************/

	STRUCTURE xmSmpHdr,0

	LONG	xmSmpLength		; sample length
	LONG	xmLoopStart		; loop start
	LONG	xmLoopLength		; loop length
	UBYTE	xmVolume		; volume
	BYTE	xmFinetune		; finetune
	UBYTE	xmSmpFlags		; sample flags
	UBYTE	xmPanning		; sample panning
	BYTE	xmRelNote		; relative note number
	UBYTE	xmReserved2
	STRUCT	xmSmpName,22		; sample name
	LABEL	xmSmpHdr_SIZE


; sample flags

xmLoopType = 3
xm16bit = $10
xm16bitf = 4
	endc
