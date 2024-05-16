; --------------------------------------------------------------------------------------------------------------

		xdef	_InstallContextSwitchHandler
		xdef	_RemoveContextSwitchHandler		
		xdef 	_PreemptiveContextSwitchHandler	
		xdef	_NormalContextSwitchHandler		
		xdef	_ActivateThread					

		section text
; --------------------------------------------------------------------------------------------------------------

_InstallContextSwitchHandler:

		move.w	sr,-(sp)
		ori		#$700,sr

		move.w	#1,timeSliceCounter
		move.l	$114.w,oldTimerHandler
		move.l	#_PreemptiveContextSwitchHandler,$114.w
		
		move.w	(sp)+,sr
	
		rts

; --------------------------------------------------------------------------------------------------------------

_RemoveContextSwitchHandler:

		move.w	sr,-(sp)
		ori		#$700,sr
		
		move.l	oldTimerHandler,$114.w

		move.w	(sp)+,sr
	
		rts
	
; --------------------------------------------------------------------------------------------------------------

_PreemptiveContextSwitchHandler:
	;	not.l		$ffff9800

		subq.w		#1,timeSliceCounter
		bne.b		.endSwitch
		
		fsave		-(sp)
		fmovem.l 	fpcr/fpsr/fpiar,-(sp)
		fmovem		fp0-fp7,-(sp)
		movem.l		d0-d7/a0-a6,-(sp)
		
		ori			#$700,sr										; disable ints
		
		jsr			__ZN14ThreadSheduler16GetCurrentThreadEv
		move.l		d0,a0
		move.l		sp,(a0)						; save context		
		jsr			__ZN14ThreadSheduler13GetNextThreadEv
		move.l		d0,a0
		move.l		(a0),sp
		move.l		4(a0),d0
		move.w		d0,timeSliceCounter
		
		movem.l		(sp)+,d0-d7/a0-a6		
		fmovem		(sp)+,fp0-fp7
		fmovem.l 	(sp)+,fpcr/fpsr/fpiar
		frestore	(sp)+
.endSwitch:
		jmp			([oldTimerHandler])
		
; --------------------------------------------------------------------------------------------------------------

_NormalContextSwitchHandler:

		rts

; --------------------------------------------------------------------------------------------------------------

_ActivateThread:

		rts
		
; --------------------------------------------------------------------------------------------------------------

		section bss
timeSliceCounter	ds.w	1		
oldTimerHandler:	ds.l	1