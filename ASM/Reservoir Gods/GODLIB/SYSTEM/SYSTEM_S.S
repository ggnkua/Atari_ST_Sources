**************************************************************************************
*	SYSTEM_S.S
*
*	hardware save & restore functions
*
*	[c] 2000 Reservoir Gods
**************************************************************************************

**************************************************************************************
;	EXPORTS / IMPORTS
**************************************************************************************

	export	System_SaveVectors
	export	System_RestoreVectors
	export	System_SetIML
	export	System_GetIML
	export	System_SetDataCache030
	export	System_HblTemp
	export	System_200hzTemp

	export	System_GetEmuName0
	export	System_GetEmuName1
	export	System_GetpEmuDescLL

	export	gSystemHblTempCounter
	export	gSystem200hzTempCounter


**************************************************************************************
	TEXT
**************************************************************************************

*------------------------------------------------------------------------------------*
* FUNTION  : System_SaveVectors( U32 * apSaveArea )
* ACTION   : saves all system vectors
* CREATION : 23.01.00 PNK
*------------------------------------------------------------------------------------*

System_SaveVectors:

	movem.l	d0-a6,-(a7)			;	save registers
	move.w	sr,-(a7)			;	save status register

	or.w	#$0700,sr			;	disable interrupts

	move.w	#61,d0				;	62 vectors to saves
	movea.w	#8,a1				;	base address of vectors

.ssv_loop:
	move.l	(a1)+,(a0)+			;	save vector address
	dbra	d0,.ssv_loop		;	loop for all vectors

	move.w	(a7)+,sr			;	restore status register
	movem.l	(a7)+,d0-a6			;	restore registers

	rts

	move.b	$FFFFFA03.w,(a0)+	;	save Active Edge Register
	move.b	$FFFFFA05.w,(a0)+	;	save Data Directionr Register
	move.b	$FFFFFA17.w,(a0)+	;	save Vector Register

	move.b	$FFFFFA01.w,(a0)+	;	save Parallel Port Data
	move.b	$FFFFFA1F.w,(a0)+	;	save Timer A Data
	move.b	$FFFFFA21.w,(a0)+	;	save Timer B Data
	move.b	$FFFFFA23.w,(a0)+	;	save Timer C Data
	move.b	$FFFFFA25.w,(a0)+	;	save Timer D Data
	move.b	$FFFFFA27.w,(a0)+	;	save Sync Character
	move.b	$FFFFFA2F.w,(a0)+	;	save USART Data

	move.b	$FFFFFA29.w,(a0)+	;	save USART Control
	move.b	$FFFFFA2B.w,(a0)+	;	save Receiver Status
	move.b	$FFFFFA2D.w,(a0)+	;	save Transmitter Status

	move.b	$FFFFFA13.w,(a0)+	;	save Interrupt Mask A
	move.b	$FFFFFA15.w,(a0)+	;	save Interrupt Mask B
	move.b	$FFFFFA0F.w,(a0)+	;	save In Service A
	move.b	$FFFFFA11.w,(a0)+	;	save In Service B
	move.b	$FFFFFA0B.w,(a0)+	;	save Pending A
	move.b	$FFFFFA0D.w,(a0)+	;	save Pending B
	move.b	$FFFFFA07.w,(a0)+	;	save Enable A
	move.b	$FFFFFA09.w,(a0)+	;	save Enable B

	move.b	$FFFFFA19.w,(a0)+	;	save Timer A Control
	move.b	$FFFFFA1B.w,(a0)+	;	save Timer B Control
	move.b	$FFFFFA1D.w,(a0)+	;	save Timer C+D Control



*------------------------------------------------------------------------------------*
* FUNTION  : System_RestoreVectors( U32 * apSaveArea )
* ACTION   : restores all system vectors
* CREATION : 23.01.00 PNK
*------------------------------------------------------------------------------------*

System_RestoreVectors:

	movem.l	d0-a6,-(a7)			;	save registers
	move.w	sr,-(a7)			;	save status register

	or.w	#$0700,sr			;	disable interrupts

	move.w	#61,d0				;	62 vectors to restore
	movea.w	#8,a1				;	base address of vectors

.srv_loop:
	move.l	(a0)+,(a1)+			;	restore vector address
	dbra	d0,.srv_loop		;	loop for all vectors

	move.w	(a7)+,sr			;	restore Status Register
	movem.l	(a7)+,d0-a6			;	restore registers

	rts

	clr.b	$FFFFFA19.w			;	stop Timer A
	clr.b	$FFFFFA1B.w			;	stop Timer B
	clr.b	$FFFFFA1D.w			;	stop Timer C+D

	move.b	(a0)+,$FFFFFA03.w	;	restore Active Edge Register
	move.b	(a0)+,$FFFFFA05.w	;	restore Data Directionr Register
	move.b	(a0)+,$FFFFFA17.w	;	restore Vector Register

	move.b	(a0)+,$FFFFFA01.w	;	restore Parallel Port Data
	move.b	(a0)+,$FFFFFA1F.w	;	restore Timer A Data
	move.b	(a0)+,$FFFFFA21.w	;	restore Timer B Data
	move.b	(a0)+,$FFFFFA23.w	;	restore Timer C Data
	move.b	(a0)+,$FFFFFA25.w	;	restore Timer D Data
	move.b	(a0)+,$FFFFFA27.w	;	restore Sync Character
	move.b	(a0)+,$FFFFFA2F.w	;	restore USART Data

	move.b	(a0)+,$FFFFFA29.w	;	restore USART Control
	move.b	(a0)+,$FFFFFA2B.w	;	restore Receiver Status
	move.b	(a0)+,$FFFFFA2D.w	;	restore Transmitter Status

	move.b	(a0)+,$FFFFFA13.w	;	restore Interrupt Mask A
	move.b	(a0)+,$FFFFFA15.w	;	restore Interrupt Mask B
	move.b	(a0)+,$FFFFFA0F.w	;	restore In Service A
	move.b	(a0)+,$FFFFFA11.w	;	restore In Service B
	move.b	(a0)+,$FFFFFA0B.w	;	restore Pending A
	move.b	(a0)+,$FFFFFA0D.w	;	restore Pending B
	move.b	(a0)+,$FFFFFA07.w	;	restore Enable A
	move.b	(a0)+,$FFFFFA09.w	;	restore Enable B

	move.b	(a0)+,$FFFFFA19.w	;	restore Timer A Control
	move.b	(a0)+,$FFFFFA1B.w	;	restore Timer B Control
	move.b	(a0)+,$FFFFFA1D.w	;	restore Timer C+D Control

System_SetIML:
	andi.w	#7,d0
	lsl.w	#8,d0
	ori.w	#$2000,d0
	move.w	d0,sr
	rts

System_GetIML:
	move.w	sr,d0
	lsr.w	#8,d0
	andi.w	#7,d0
	rts

System_SetDataCache030:

	tst.w	d0
	beq.s	.cache_off

	moveq	#0,d0
	movec	CACR,d0
	bset	#8,d0
	movec	d0,CACR
	rts

.cache_off:
	moveq	#0,d0
	movec	CACR,d0
	bclr	#8,d0
	movec	d0,CACR
	rts

System_HblTemp:
	addq.l	#1,gSystemHblTempCounter
	rte

System_200hzTemp:
	addq.l	#1,gSystem200hzTempCounter
	bclr.b	#4,$FFFFFA11
	rte

System_GetEmuName0:
	movem.l	d1-d7/a0-a6,-(a7)

	move.l	#'Emu?',d6
	move.l	d6,d7
	move.w	#$25,-(a7)
	trap	#14
	addq.l	#2,a7

	move.l	d6,d0
	
	movem.l	(a7)+,d1-d7/a0-a6
	rts

System_GetEmuName1:
	movem.l	d1-d7/a0-a6,-(a7)

	move.l	#'Emu?',d6
	move.l	d6,d7
	move.w	#$25,-(a7)
	trap	#14
	addq.l	#2,a7

	move.l	d7,d0
	
	movem.l	(a7)+,d1-d7/a0-a6
	rts

System_GetEmuVers:
	movem.l	d1-d7/a0-a6,-(a7)

	move.l	#'Emu?',d6
	move.l	d6,d7
	move.w	#$25,-(a7)
	trap	#14
	addq.l	#2,a7

	moveq	#0,d0
	move.b	(a0)+,d0
	lsl.w	#8,d0
	move.b	(a0)+,d0
	
	movem.l	(a7)+,d1-d7/a0-a6
	rts

System_GetpEmuDescLL:
	movem.l	d1-d7/a1-a6,-(a7)

	move.l	#'Emu?',d6
	move.l	d6,d7
	move.w	#$25,-(a7)
	trap	#14
	addq.l	#2,a7

	movem.l	(a7)+,d1-d7/a1-a6
	rts

gSystemHblTempCounter:		dc.l	0
gSystem200hzTempCounter:	dc.l	0