**************************************************************************************
;	STRUCTS
**************************************************************************************

	DATA

	OFFSET

sVBL_LockFlag:			ds.b	1
sVBL_TimerBScanLine:	ds.b	1
sVBL_HbiCounterStart:	ds.w	1
sVBL_HbiCounter:		ds.w	1
sVBL_CallCount:			ds.w	1
sVBL_pHbi:				ds.l	1
sVBL_pTimerBFunc:		ds.l	1
sVBL_pCalls:			ds.l	1

	EVEN