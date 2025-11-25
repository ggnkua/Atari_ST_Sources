*****************************************************
*   Falcon Video Macro Definitions as by 10/01/92   *
*      Atari Sound Documentation. Version 1.0	    *
*		  Low Level Calls		    *
*		  By CDE 10/11/92		    *
*	Corrected by Martin Randall 19/11/92	    *
*****************************************************


********************************************************
*
*	returns d0.l
*
*	1 if you have locked else SNDLOCKED (-128)
*

locksnd	macro
	move.w	#128,-(sp)
	trap	#14
	addq.l	#2,sp
	endm

********************************************************
*
*	returns d0.l
*
*	0 if you have unlocked else SNDNOTLOCK (-129)
*

unlocksnd	macro
	move.w	#129,-(sp)
	trap	#14
	addq.l	#2,sp
	endm



********************************************************
*
*	returns d0.l
*
*	if data.w is -ive then %xxxx xxxx MMMM xxxx
*
*	inputs	mode.w,data.w
*
*	data as the format above +ve to set -ive to read
*	mode	0 = LTATTEN
*		1 = RTATTEN
*		2 = LTGAIN
*		3 = RTGAIN
*		4 = ADDERIN
*		5 = ADCINPUT
*		6 = PRESCALE


soundcmd	macro
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp
	endm


********************************************************
*
*	returns d0.l
*
*	0 = no error
*
*	inputs	reg.w,begaddr.l,endaddr.l
*

setbuffer	macro
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#131,-(sp)
	trap	#14
	lea	12(sp),sp
	endm


********************************************************
*
*	returns d0.l
*
*	0 = no error
*
*	inputs	mode.w
*

setmode	macro
	move.w	\1,-(sp)
	move.w	#132,-(sp)
	trap	#14
	addq.l	#4,sp
	endm


********************************************************
*
*	returns d0.l
*
*	0 = no error
*
*	inputs	playtracks.w,rectracks.w
*

settracks	macro
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#133,-(sp)
	trap	#14
	addq.l	#6,sp
	endm

********************************************************
*
*	returns d0.l
*
*	0 = no error
*
*	inputs	montrack.w
*

setmontracks	macro
	move.w	\1,-(sp)
	move.w	#134,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

********************************************************
*
*	returns d0.l
*
*	0 = no error
*
*	inputs	src_inter.w,cause.w
*
*	src_inter.w	0 = timer A
*			1 = MFP i7
*	cause.w		0 = No interrupt
*			1 = Play
*			2 = Record
*			3 = Play or Record
*

setinterrupt	macro
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#135,-(sp)
	trap	#14
	addq.l	#6,sp
	endm

********************************************************
*
*	returns d0.l
*
*	0 = no error
*	if mode.w -ive then .b is xxxx MMMM
*
*	input	mode.w
*

buffoper	macro
	move.w	\1,-(sp)
	move.w	#136,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

********************************************************
*
*	returns d0.l
*
*	0 = no error
*
*	inputs	dspxmit.w,dsprec.w
*
*	dspxmit.w	0 = Tristate , 1 = Enable
*	dsprec.w	0 = Tristate , 1 = Enable
*

dsptristate	macro
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#137,-(sp)
	trap	#14
	addq.l	#6,sp
	endm

********************************************************
*
*	returns d0.l
*
*	0 = no error
*	if mode = 1 then returns value
*
*	inputs	mode.w,data.w
*
*	mode.w		1 = Read
*			2 = Write
*	data.w		bit set then output
*			bit clear then input
*

gpio	macro
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#138,-(sp)
	trap	#14
	addq.l	#6,sp
	endm


********************************************************
*
*	returns d0.l
*
*	0 = no error
*
*	inputs	src.w,dst.w,srcclk.w,prescale.w,protocol.w
*
*	src.w	0 = DMA Play
*		1 = DSP Transmit
*		2 = Ext. Input
*		3 = ADC Microphone\PSG
*	dst.w	0x1 = DMA Record
*		0x2 = DSP Receive
*		0x4 = External Out
*		0x8 = DAC Headphone\ Ext Speaker
*	srclk.w	0 = Internal 25.175MHz
*		1 = External Clock
*		2 = Internal 32MHz
*	prescale.w	1 -> 12 if >12 then mute 0 use TT
*	protcol.w
*		0 = Enable Handshaking
*		1 = Disable Handshaking

devconnect	macro
	move.w	\5,-(sp)
	move.w	\4,-(sp)
	move.w	\3,-(sp)
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#139,-(sp)
	trap	#14
	lea	12(sp),sp
	endm



********************************************************
*
*	returns d0.l
*
*	bits 0-7 hold the status
*
*	inputs	reset.w  If 1 then reset occurs
*

sndstatus	macro
	move.w	\1,-(sp)
	move.w	#140,-(sp)
	trap	#14
	addq.l	#4,sp
	endm




********************************************************
*
*	returns d0.l
*
*	0 = no error
*
*	input	pointer.l
*

buffptr	macro
	pea	\1
	move.w	#141,-(sp)
	trap	#14
	addq.l	#6,sp
	endm




*********************************
*	End Of SND macros	*
*********************************
