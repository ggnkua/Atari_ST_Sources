**************************************************************************************
*	VBL_S.S
*
*	vbl based functions
*
*	[c] 2000 Reservoir Gods
**************************************************************************************



**************************************************************************************
;	EXPORTS / IMPORTS
**************************************************************************************

	export	Vbl_GetHandler
	export	Vbl_SetHandler
	export	Vbl_HandlerST
	export	Vbl_HandlerSTE
	export	Vbl_HandlerTT
	export	Vbl_HandlerFalcon
	export	Vbl_GetCounter
	export	Vbl_WaitVbl
	export	Vbl_Handler

	export	gVblHbiCounter

	export	Vbl_DummyFunc

	import	gVbl



**************************************************************************************
;	STRUCTS
**************************************************************************************

	OFFSET

sVBL_LockFlag:			ds.b	1
sVBL_TimerBScanLine:	ds.b	1
sVBL_HbiCounterStart:	ds.w	1
sVBL_HbiCounter:		ds.w	1
sVBL_CallCount:			ds.w	1
sVBL_pHbi:				ds.l	1
sVBL_pTimerBFunc:		ds.l	1
sVBL_pVideoFunc:		ds.l	1
sVBL_pCalls:			ds.l	1


**************************************************************************************
	TEXT
**************************************************************************************

*------------------------------------------------------------------------------------*
* Function:    void (*Get_VblHander( void ))()
* 
* Action:      returns pointer to current vbl handler function
*
* Created:     24.03.00 PNK
*------------------------------------------------------------------------------------*

Vbl_GetHandler:
	move.l	$70.w,a0
	rts


*------------------------------------------------------------------------------------*
* Function:    void Vbl_SetHander( void (*apHandler()) )
* 
* Action:      returns pointer to current vbl handler function
*
* Created:     24.03.00 PNK
*------------------------------------------------------------------------------------*

Vbl_SetHandler:
	move.w	sr,-(a7)
	ori.w	#$0700,sr

	move.l	a0,$70.w

	move.w	(a7)+,sr
	rts


*------------------------------------------------------------------------------------*
* Function:    Vbl_GetCounter()
* Action:      returns current vbl counter
* Created:     27.11.00 PNK
*------------------------------------------------------------------------------------*

Vbl_GetCounter:
	move.l	$466.w,d0
	rts


*------------------------------------------------------------------------------------*
* Function:    Vbl_WaitVbl()
* Action:      waits for vertical blank
* Created:     27.11.00 PNK
*------------------------------------------------------------------------------------*

Vbl_WaitVbl:
	move.l	$466.w,d0
.vbl_wait:
	cmp.l	$466.w,d0
	beq.s	.vbl_wait
	rts


*------------------------------------------------------------------------------------*
* Function:    Vbl_Handler()
* Action:      generic vbl handler
* Created:     02.01.03 PNK
*------------------------------------------------------------------------------------*

Vbl_Handler:
	ori.w	#$0700,sr						; don't interrupt me

	tst.l	gVbl+sVBL_pHbi
	beq.s	.no_hbi

	move.w	gVbl+sVBL_HbiCounterStart,gVbl+sVBL_HbiCounter
	move.l	gVbl+sVBL_pHbi,$68.w

.no_hbi:

	tst.l	gVbl+sVBL_pTimerBFunc
	beq.s	.no_tb
	clr.b	$FFFFFA1B.w								; timer B off
	move.l	gVbl+sVBL_pTimerBFunc,$120.w			; new timer B routine
	move.b	gVbl+sVBL_TimerBScanLine,$FFFFFA21.w	; first scanline for timer B
	move.b	#8,$FFFFFA1B.w							; start timer B
.no_tb:

	tas.b	gVbl+sVBL_LockFlag				; already in vbl interrupt?
	bne.s	.vbl_locked						; don't interrupt yourself
	movem.l	d0-d7/a0-a6,-(a7)				; save register
	
	move.l	gVbl+sVBL_pVideoFunc,a0
	jsr		(a0)

	move.w	#$2400,sr

	move.w	gVbl+sVBL_CallCount,d7			; call count
	lea		gVbl+sVBL_pCalls,a6				; start of vbl function table
	bra.s	.first							; begin the call
.call_loop:
	move.l	(a6)+,a0						; get function address
	jsr		(a0)							; call function
.first:
	dbra	d7,.call_loop					; loop for all functions

	movem.l	(a7)+,d0-d7/a0-a6				; restore registers
	clr.b	gVbl+sVBL_LockFlag				; unlock vbl
.vbl_locked:
	addq.l	#1,$466.w						; update vbl counter
	rte										; return from exception


*------------------------------------------------------------------------------------*
* Function:    Vbl_DummyFunc( void )
* Action:      dummy function
* Created:     02.01.03 PNK
*------------------------------------------------------------------------------------*

Vbl_DummyFunc:
	rts


**************************************************************************************
	DATA
**************************************************************************************

gVblHbiCounter:	dc.w	0