**************************************************************************************
*	MFP_S.S
*
*	MFP routines
*
*	[c] 2001 Reservoir Gods
**************************************************************************************

**************************************************************************************
;	EXPORTS / IMPORTS
**************************************************************************************

	export	Mfp_SaveRegisters
	export	Mfp_RestoreRegisters

	export	Mfp_GetTimerA
	export	Mfp_GetTimerB
	export	Mfp_GetTimerC
	export	Mfp_GetTimerD

	export	Mfp_InstallTimerA
	export	Mfp_InstallTimerB
	export	Mfp_InstallTimerC
	export	Mfp_InstallTimerD

	export	Mfp_InstallGPI7

	export	Mfp_InstallStandardTimerC
	export	Mfp_StandardTimerC

	export	Mfp_StcOldJump
	export	Mfp_StcNewJump
	export	Mfp_StcTime

	export	Mfp_HookIntoTimerC
	export	Mfp_HookDisableTimerC
	export	Mfp_HookEnableTimerC
	export	Mfp_DisableSystemTimerC

	export	gMfpStcTime
	export	gMfpStcCounter


**************************************************************************************
;	STRUCTS
**************************************************************************************

	OFFSET

sMfpTimer_Func:				ds.l	1
sMfpTimer_Freq:				ds.w	1
sMfpTimer_Mode:				ds.b	1
sMfpTimer_Data:				ds.b	1
sMfpTimer_Mask:				ds.b	1
sMfpTimer_Enable:			ds.b	1


	OFFSET

sMfp_BlankReg00:			ds.b	1
sMfp_PPDR:					ds.b	1
sMfp_BlankReg02:			ds.b	1
sMfp_AER:					ds.b	1
sMfp_BlankReg04:			ds.b	1
sMfp_DD:					ds.b	1
sMfp_BlankReg06:			ds.b	1
sMfp_IEA:					ds.b	1
sMfp_BlankReg08:			ds.b	1
sMfp_IEB:					ds.b	1
sMfp_BlankReg0A:			ds.b	1
sMfp_IPA:					ds.b	1
sMfp_BlankReg0C:			ds.b	1
sMfp_IPB:					ds.b	1
sMfp_BlankReg0E:			ds.b	1
sMfp_IISA:					ds.b	1
sMfp_BlankReg10:			ds.b	1
sMfp_IISB:					ds.b	1
sMfp_BlankReg12:			ds.b	1
sMfp_IMA:					ds.b	1
sMfp_BlankReg14:			ds.b	1
sMfp_IMB:					ds.b	1
sMfp_BlankReg16:			ds.b	1
sMfp_VR:					ds.b	1
sMfp_BlankReg18:			ds.b	1
sMfp_TAC:					ds.b	1
sMfp_BlankReg1A:			ds.b	1
sMfp_TBC:					ds.b	1
sMfp_BlankReg1C:			ds.b	1
sMfp_TCDC:					ds.b	1
sMfp_BlankReg1E:			ds.b	1
sMfp_TAD:					ds.b	1
sMfp_BlankReg20:			ds.b	1
sMfp_TBD:					ds.b	1
sMfp_BlankReg22:			ds.b	1
sMfp_TCD:					ds.b	1
sMfp_BlankReg24:			ds.b	1
sMfp_TDD:					ds.b	1
sMfp_BlankReg26:			ds.b	1
sMfp_SC:					ds.b	1
sMfp_BlankReg28:			ds.b	1
sMfp_UC:					ds.b	1
sMfp_BlankReg2A:			ds.b	1
sMfp_RS:					ds.b	1
sMfp_BlankReg2C:			ds.b	1
sMfp_TS:					ds.b	1
sMfp_BlankReg2E:			ds.b	1
sMfp_UD:					ds.b	1


**************************************************************************************
	TEXT
**************************************************************************************

*------------------------------------------------------------------------------------*
* FUNTION  : Mfp_Init( U32 * apSaveSpace )
* ACTION   : saves MFP registers
* CREATION : 24.01.01 PNK
*------------------------------------------------------------------------------------*

Mfp_SaveRegisters:
	movem.l	d0-a6,-(a7)			;	save registers
	move.w	sr,-(a7)			;	save status register

	or.w	#$0700,sr			;	disable interrupts

	movea.w	#$100.w,a1			;	start of MFP vectors
	moveq	#15,d0				;	16 vectors to save
.smfp_loop:
	move.l	(a1)+,(a0)+			;	save mfp registers
	dbra	d0,.smfp_loop		;	loop for all MFP vectors

	move.b	$FFFFFA03.w,(a0)+	;	save Active Edge Register
	move.b	$FFFFFA05.w,(a0)+	;	save Data Directionr Register
	move.b	$FFFFFA17.w,(a0)+	;	save Vector Register

	move.b	$FFFFFA01.w,(a0)+	;	save Parallel Port Data
	move.b	$FFFFFA1F.w,(a0)+	;	save Timer A Data
	move.b	$FFFFFA21.w,(a0)+	;	save Timer B Data
;	move.b	$FFFFFA23.w,(a0)+	;	save Timer C Data
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

	move.w	(a7)+,sr			;	restore status register
	movem.l	(a7)+,d0-a6			;	restore registers

	rts


*------------------------------------------------------------------------------------*
* FUNTION  : Mfp_DeInit( U32 * apSaveSpace )
* ACTION   : restores MFP registers
* CREATION : 24.01.01 PNK
*------------------------------------------------------------------------------------*

Mfp_RestoreRegisters:

	movem.l	d0-a6,-(a7)			;	save registers
	move.w	sr,-(a7)			;	save status register

	or.w	#$0700,sr			;	disable interrupts

	movea.w	#$100.w,a1			;	start of MFP vectors
	moveq	#15,d0				;	16 vectors to restore
.rmfp_loop:
	move.l	(a0)+,(a1)+			;	restore mfp registers
	dbra	d0,.rmfp_loop		;	loop for all MFP vectors

	clr.b	$FFFFFA19.w			;	stop Timer A
	clr.b	$FFFFFA1B.w			;	stop Timer B
	clr.b	$FFFFFA1D.w			;	stop Timer C+D

	move.b	(a0)+,$FFFFFA03.w	;	restore Active Edge Register
	move.b	(a0)+,$FFFFFA05.w	;	restore Data Directionr Register
	move.b	(a0)+,$FFFFFA17.w	;	restore Vector Register

	move.b	(a0)+,$FFFFFA01.w	;	restore Parallel Port Data
	move.b	(a0)+,$FFFFFA1F.w	;	restore Timer A Data
	move.b	(a0)+,$FFFFFA21.w	;	restore Timer B Data
;	move.b	(a0)+,$FFFFFA23.w	;	restore Timer C Data
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

	move.w	(a7)+,sr			;	restore Status Register
	movem.l	(a7)+,d0-a6			;	restore registers

	rts


*------------------------------------------------------------------------------------*
* FUNTION  : Mfp_InstallTimerA( sMfpTimer * apTimer )
* ACTION   : installs a timer a routine
* CREATION : 24.01.01 PNK
*------------------------------------------------------------------------------------*

Mfp_GetTimerA:

	movem.l	d0-a6,-(a7)						;	save registers
	move.w	sr,-(a7)						;	save status register

	or.w	#$0700,sr						;	disable interrupts

	movea.w	#$FA00,a1						;	base address of MFP 1

	move.l	$134.w,sMfpTimer_Func(a0)		;	Timer Rout
	move.b	sMfp_TAC(a1),sMfpTimer_Mode(a0)	;	Get control
	move.b	sMfp_TAD(a1),sMfpTimer_Data(a0)	;	Get data
	move.b	sMfp_IMA(a1),d0					;	Read MaskA
	lsr.b	#5,d0							;	Get TimerA bit
	and.b	#1,d0							;	Clear other bits
	move.b	d0,sMfpTimer_Mask(a0)			;	Store mask
	move.b	sMfp_IEA(a1),d0					;	Read EnableA
	lsr.b	#5,d0							;	Get TimerA bit
	and.b	#1,d0							;	Clear other bits
	move.b	d0,sMfpTimer_Enable(a0)			;	Store mask

	move.w	(a7)+,sr						;	restore Status Register
	movem.l	(a7)+,d0-a6						;	restore registers

	rts

*------------------------------------------------------------------------------------*
* FUNTION  : Mfp_InstallTimerA( sMfpTimer * apTimer )
* ACTION   : installs a timer a routine
* CREATION : 24.01.01 PNK
*------------------------------------------------------------------------------------*

Mfp_InstallTimerA:

	movem.l	d0-a6,-(a7)						;	save registers
	move.w	sr,-(a7)						;	save status register

	or.w	#$0700,sr						;	disable interrupts

	movea.w	#$FA00,a1						;	base address of MFP 1
	clr.b	sMfp_TAC(a1)					;	stop Timer A
	move.l	sMfpTimer_Func(a0),$134.w		;	Timer A routine
	move.b	sMfpTimer_Data(a0),sMfp_TAD(a1)	;	Timer A data

	move.b	sMfpTimer_Mask(a0),d0			;	Mask value
	and.b	#1,d0							;	get rid of unwanted bits
	lsl.b	#5,d0							;	shift into place
	and.b	#%11011111,sMfp_IMA(a1)			;	Timer A interrupt mask
	or.b	d0,sMfp_IMA(a1)					;	set mask

	move.b	sMfpTimer_Enable(a0),d0			;	Enable value
	and.b	#1,d0							;	get rid of unwanted bits
	lsl.b	#5,d0							;	shift into place
	and.b	#%11011111,sMfp_IEA(a1)			;	Timer A enable
	or.b	d0,sMfp_IEA(a1)					;	set enable

	move.b	sMfpTimer_Mode(a0),sMfp_TAC(a1)	;	Timer A control

	move.w	(a7)+,sr						;	restore Status Register
	movem.l	(a7)+,d0-a6						;	restore registers

	rts


*------------------------------------------------------------------------------------*
* FUNTION  : Mfp_GetTimerB( sMfpTimer * apTimer )
* ACTION   : gets current timer b routine
* CREATION : 24.01.01 PNK
*------------------------------------------------------------------------------------*

Mfp_GetTimerB:

	movem.l	d0-a6,-(a7)						;	save registers
	move.w	sr,-(a7)						;	save status register

	or.w	#$0700,sr						;	disable interrupts

	movea.w	#$FA00,a1						;	base address of MFP 1

	move.l	$120.w,sMfpTimer_Func(a0)		;	Timer Rout
	move.b	sMfp_TBC(a1),sMfpTimer_Mode(a0)	;	Get control
	move.b	sMfp_TBD(a1),sMfpTimer_Data(a0)	;	Get data
	move.b	sMfp_IMA(a1),d0					;	Read MaskA
	and.b	#1,d0							;	Clear other bits
	move.b	d0,sMfpTimer_Mask(a0)			;	Store mask
	move.b	sMfp_IEA(a1),d0					;	Read EnableA
	and.b	#1,d0							;	Clear other bits
	move.b	d0,sMfpTimer_Enable(a0)			;	Store mask

	move.w	(a7)+,sr						;	restore Status Register
	movem.l	(a7)+,d0-a6						;	restore registers

	rts


*------------------------------------------------------------------------------------*
* FUNTION  : Mfp_InstallTimerB( sMfpTimer * apTimer )
* ACTION   : installs a timer a routine
* CREATION : 24.01.01 PNK
*------------------------------------------------------------------------------------*

Mfp_InstallTimerB:

	movem.l	d0-a6,-(a7)						;	save registers
	move.w	sr,-(a7)						;	save status register

	or.w	#$0700,sr						;	disable interrupts

	movea.w	#$FA00,a1						;	base address of MFP 1
	clr.b	sMfp_TBC(a1)					;	stop Timer B
	move.l	sMfpTimer_Func(a0),$120.w		;	Timer B routine
	move.b	sMfpTimer_Data(a0),sMfp_TBD(a1)	;	Timer B data

	move.b	sMfpTimer_Mask(a0),d0			;	Mask value
	and.b	#1,d0							;	get rid of unwanted bits
	and.b	#%11111110,sMfp_IMA(a1)			;	Timer B interrupt mask
	or.b	d0,sMfp_IMA(a1)					;	set mask

	move.b	sMfpTimer_Enable(a0),d0			;	Enable value
	and.b	#1,d0							;	get rid of unwanted bits
	and.b	#%11111110,sMfp_IEA(a1)			;	Timer B enable
	or.b	d0,sMfp_IEA(a1)					;	set enable

	move.b	sMfpTimer_Mode(a0),sMfp_TBC(a1)	;	Timer B control

	move.w	(a7)+,sr						;	restore Status Register
	movem.l	(a7)+,d0-a6						;	restore registers

	rts


*------------------------------------------------------------------------------------*
* FUNTION  : Mfp_GetTimerC( sMfpTimer * apTimer )
* ACTION   : gets current timer c routine
* CREATION : 24.01.01 PNK
*------------------------------------------------------------------------------------*

Mfp_GetTimerC:

	movem.l	d0-a6,-(a7)						;	save registers
	move.w	sr,-(a7)						;	save status register

	or.w	#$0700,sr						;	disable interrupts

	movea.w	#$FA00,a1						;	base address of MFP 1

	move.l	$114.w,sMfpTimer_Func(a0)		;	Timer Rout
	move.b	sMfp_TCDC(a1),d0				;	Get TimerC control
	lsr.b	#4,d0							;	Get TimerC bits
	and.b	#$f,d0							;	Mask off unwanted bits
	move.b	d0,sMfpTimer_Mode(a0)			;	Get control
	move.b	sMfp_TCD(a1),sMfpTimer_Data(a0)	;	Get data
	move.b	sMfp_IMB(a1),d0					;	Read MaskB
	lsr.w	#5,d0
	and.b	#1,d0							;	Clear other bits
	move.b	d0,sMfpTimer_Mask(a0)			;	Store mask
	move.b	sMfp_IEB(a1),d0					;	Read EnableB
	lsr.w	#5,d0
	and.b	#1,d0							;	Clear other bits
	move.b	d0,sMfpTimer_Enable(a0)			;	Store mask

	move.w	(a7)+,sr						;	restore Status Register
	movem.l	(a7)+,d0-a6						;	restore registers

	rts


*------------------------------------------------------------------------------------*
* FUNTION  : Mfp_InstallTimerC( sMfpTimer * apTimer )
* ACTION   : installs a timer c routine
* CREATION : 24.01.01 PNK
*------------------------------------------------------------------------------------*

Mfp_InstallTimerC:

	movem.l	d0-a6,-(a7)						;	save registers
	move.w	sr,-(a7)						;	save status register

	or.w	#$0700,sr						;	disable interrupts

	movea.w	#$FA00,a1						;	base address of MFP 1
	and.b	#$0F,sMfp_TCDC(a1)				;	stop Timer C
	move.l	sMfpTimer_Func(a0),$114.w		;	Timer C routine
	move.b	sMfpTimer_Data(a0),sMfp_TCD(a1)	;	Timer C data

	move.b	sMfpTimer_Mask(a0),d0			;	Mask value
	and.b	#1,d0							;	get rid of unwanted bits
	lsl.b	#5,d0							;	shift into place
	and.b	#%11011111,sMfp_IMB(a1)			;	Timer C interrupt mask
	or.b	d0,sMfp_IMB(a1)					;	set mask

	move.b	sMfpTimer_Enable(a0),d0			;	Enable value
	and.b	#1,d0							;	get rid of unwanted bits
	lsl.b	#5,d0							;	shift into place
	and.b	#%11011111,sMfp_IEB(a1)			;	Timer C enable
	or.b	d0,sMfp_IEB(a1)					;	set enable

	move.b	sMfpTimer_Mode(a0),d0			;	mode
	lsl.b	#4,d0							;	into top 4 bits
	or.b	d0,sMfp_TCDC(a1)					;	Timer C control

	move.w	(a7)+,sr						;	restore Status Register
	movem.l	(a7)+,d0-a6						;	restore registers

	rts


*------------------------------------------------------------------------------------*
* FUNTION  : Mfp_GetTimerC( sMfpTimer * apTimer )
* ACTION   : gets current timer c routine
* CREATION : 24.01.01 PNK
*------------------------------------------------------------------------------------*

Mfp_GetTimerD:

	movem.l	d0-a6,-(a7)						;	save registers
	move.w	sr,-(a7)						;	save status register

	or.w	#$0700,sr						;	disable interrupts

	movea.w	#$FA00,a1						;	base address of MFP 1

	move.l	$110.w,sMfpTimer_Func(a0)		;	Timer Rout
	move.b	sMfp_TCDC(a1),d0				;	Get TimerC control
	and.b	#$f,d0							;	Mask off unwanted bits
	move.b	d0,sMfpTimer_Mode(a0)			;	Get control
	move.b	sMfp_TCD(a1),sMfpTimer_Data(a0)	;	Get data
	move.b	sMfp_IMB(a1),d0					;	Read MaskB
	lsr.w	#4,d0
	and.b	#1,d0							;	Clear other bits
	move.b	d0,sMfpTimer_Mask(a0)			;	Store mask
	move.b	sMfp_IEB(a1),d0					;	Read EnableB
	lsr.w	#4,d0
	and.b	#1,d0							;	Clear other bits
	move.b	d0,sMfpTimer_Enable(a0)			;	Store mask

	move.w	(a7)+,sr						;	restore Status Register
	movem.l	(a7)+,d0-a6						;	restore registers

	rts



*------------------------------------------------------------------------------------*
* FUNTION  : Mfp_InstallTimerD( sMfpTimer * apTimer )
* ACTION   : installs a timer d routine
* CREATION : 24.01.01 PNK
*------------------------------------------------------------------------------------*

Mfp_InstallTimerD:

	movem.l	d0-a6,-(a7)						;	save registers
	move.w	sr,-(a7)						;	save status register

	or.w	#$0700,sr						;	disable interrupts

	movea.w	#$FA00,a1						;	base address of MFP 1
	and.b	#$F0,sMfp_TCDC(a1)				;	stop Timer D
	move.l	sMfpTimer_Func(a0),$110.w		;	Timer D routine
	move.b	sMfpTimer_Data(a0),sMfp_TDD(a1)	;	Timer D data


	move.b	sMfpTimer_Mask(a0),d0			;	Mask value
	and.b	#1,d0							;	get rid of unwanted bits
	lsl.b	#4,d0							;	shift into place
	and.b	#%11101111,sMfp_IMB(a1)			;	Timer C interrupt mask
	or.b	d0,sMfp_IMB(a1)					;	set mask

	move.b	sMfpTimer_Enable(a0),d0			;	Enable value
	and.b	#1,d0							;	get rid of unwanted bits
	lsl.b	#4,d0							;	shift into place
	and.b	#%11101111,sMfp_IEB(a1)			;	Timer C enable
	or.b	d0,sMfp_IEB(a1)					;	set enable

	move.b	sMfpTimer_Mode(a0),d0			;	mode
	or.b	d0,sMfp_TCDC(a1)				;	Timer C control

	move.w	(a7)+,sr						;	restore Status Register
	movem.l	(a7)+,d0-a6						;	restore registers

	rts


*------------------------------------------------------------------------------------*
* FUNTION  : Mfp_InstallStandardTimerC( void )
* ACTION   : intasll standard timer c routine, with hookable call
* CREATION : 24.01.01 PNK
*------------------------------------------------------------------------------------*

Mfp_InstallStandardTimerC:

	move.w	sr,-(a7)						;	save status register

	ori.w	#$0700,sr						;	disable	interrupts

	move.l	$114.w,Mfp_StcOldJump+2			;	old timer c rout
	clr.b	gMfpStcNewEnableFlag			;	disable hookable timer c int
	move.l	#Mfp_StandardTimerC,$114.w		;	install my timer c routine

	move.w	(a7)+,sr						;	restore Status Register

	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Mfp_HookIntoTimerC( sMfpTimer * apTimer )
* ACTION   : hooks a routine into timer c vector
* CREATION : 24.01.01 PNK
*------------------------------------------------------------------------------------*

Mfp_HookIntoTimerC:

	move.w	sr,-(a7)								;	save status register

	ori.w	#$0700,sr								;	disable	interrupts

	clr.b	gMfpStcNewEnableFlag					;	disable hookable timer c int
	move.l	sMfpTimer_Func(a0),Mfp_StcNewJump+2		;	install new routine
	move.w	sMfpTimer_Freq(a0),gMfpStcNewHz			;	frequency to interrupt
	move.w	sMfpTimer_Freq(a0),gMfpStcNewCounter	;	init counter
	clr.b	gMfpStcNewLockFlag						;	ensure no deadlock
	st.b	gMfpStcNewEnableFlag					;	enble hookable timer c int

	move.w	(a7)+,sr								;	restore Status Register

	rts


*------------------------------------------------------------------------------------*
* FUNTION  : Mfp_StandardTimerC( void )
* ACTION   : standard timer c routine, with hookable call
* CREATION : 24.01.01 PNK
*------------------------------------------------------------------------------------*

Mfp_StandardTimerC:

	move.l	d0,-(a7)						;	save	d0
	move.w	sr,-(a7)
	move.w	#$2300,sr

	move.l	gMfpStcTime,d0					;	old clock value
	addq.b	#1,d0							;	inc microseconds (200hz)
	cmp.b	#199,d0							;	next second reached?
	bls.s	.tc_storeclock					;	no, store clock value
.tc_sectick:
	clr.b	d0								;	reset microseconds counter
	add.w	#256,d0							;	inc second counter
	cmp.w	#(59*256),d0					;	60 second reached?
	bls.s	.tc_storeclock					;	no, store clock value
.tc_mintick:
	clr.w	d0								;	clear seconds
	swap	d0								;	get hours:minutes
	addq.b	#1,d0							;	inc minutes
	cmp.b	#59,d0							;	60 minutes reached?
	bls.s	.tc_swapstore					;	no, swap & store clcok
.tc_hourtick:
	clr.b	d0								;	clear minutes
	add.w	#256,d0							;	inc hours
.tc_swapstore:
	swap	d0								;	hours:minutes into top 16 bits
.tc_storeclock:
	move.l	d0,gMfpStcTime					;	store clock

	addq.l	#1,gMfpStcCounter				;	inc 200hz counter;

	tst.b	gMfpStcNewEnableFlag			;	has new timer c int been installed?
	beq.s	Mfp_StcExit						;	no new int

	move.w	gMfpStcNewHz,d0					;	frequency of new timer c call
	sub.w	d0,gMfpStcNewCounter			;	dec new counter
	bgt.s	Mfp_StcExit						;	don't call interrupt yet

	add.w	#200,gMfpStcNewCounter			;	time until next int

	tas.b	gMfpStcNewLockFlag				;	test & set lock flag
	bne.s	Mfp_StcExit						;	already executing timer c int

Mfp_StcNewJump:
	jsr		$12345678						;	call new timer c rout

	clr.b	gMfpStcNewLockFlag				;	new timer c rout finished

Mfp_StcExit:
	move.w	(a7)+,sr
	move.l	(a7)+,d0						;	restore timer c

Mfp_StcOldJump:
	jmp		$1234568						;	jump to os


Mfp_HookDisableTimerC:
	clr.b	gMfpStcNewEnableFlag
	rts


Mfp_HookEnableTimerC:
	st.b	gMfpStcNewEnableFlag
	rts

Mfp_ReturnTimerC:
	bclr.b	#5,$FFFFFA11.w
	rte

Mfp_DisableSystemTimerC:
	move.l	#Mfp_ReturnTimerC,Mfp_StcOldJump+2
	rts

*------------------------------------------------------------------------------------*
* FUNTION  : Mfp_InstallGPI7( void (*apHandler)(void), U8 aPinLowHighFlag )
* ACTION   : installs a GPI7 routine
* CREATION : 24.01.01 PNK
*------------------------------------------------------------------------------------*

Mfp_InstallGPI7:

	movem.l	d0-a6,-(a7)						;	save registers
	move.w	sr,-(a7)						;	save status register

	or.w	#$0700,sr						;	disable interrupts

	movea.w	#$FA00,a1						;	base address of MFP 1
	move.l	a0,$13C.w						;	Timer A routine
	andi.b	#$7F,sMfp_AER(a1)				;	clear GPI7 pin transition bit
	lsl.b	#7,d0							;	PinLowHigh flag
	or.b	d0,sMfp_AER(a1)					;	set GPI7 pin transition type
	or.b	#%10000000,sMfp_IMA(a1)			;	Timer A interrupt mask
	or.b	#%10000000,sMfp_IEA(a1)			;	Timer A enable

	move.w	(a7)+,sr						;	restore Status Register
	movem.l	(a7)+,d0-a6						;	restore registers

	rts


**************************************************************************************
	DATA
**************************************************************************************

	ALIGN	4

gMfpStcTime:			dc.l	0
gMfpStcCounter:			dc.l	0
gMfpStcNewCounter:		dc.w	0
gMfpStcNewHz:			dc.w	0
gMfpStcNewEnableFlag:	dc.b	0
gMfpStcNewLockFlag:		dc.b	0

	ALIGN	4