;---------------------------------------------------------------------
;;
; Swap.s
;
; Context Swapper and starter
; Enter and Exit critical section
;
; copyright (c) Jim Patchell 1995,2000
;
;---------------------------------------------------------------------

	SECTION code
	xref _CurrentTask,_Schedule,_ReadyTask
	xdef _Swap,__Start,Swap,_IrqSwap,_EnterCritical
	xdef _CriticalLevel
	.FREF	_ExitInterrupt,2	;this function removes two bytes
	.FDEF	_ExitCritical,2		;this function removes two bytes
	xref _EnterInterrupt

;---------------------------------------------------------------------
;
; _Swap can be called from the task level by a JSR to do a context swap
;
;---------------------------------------------------------------------
;
_Swap:
	move.w	sr,-(a7)				;push status register on stack (simulate trap)
;
;---------------------------------------------------------------------
;
; Swap can be called from the task level by a TRAP #0 instruction
;
;---------------------------------------------------------------------
;
Swap:
	movem.l	d0-d7/a0-a6,-(a7)		;save current task's context
	move.l	_CurrentTask,a0			;get pointer to stack pointer save area
	move.l	a7,(a0)					;save the stack pointer

	move.l	_ReadyTask,a0			;get pointer to stack pointer save area
	move.l	a0,_CurrentTask			;make ready task current task
	move.l	(a0),a7					;get new stack pointer
	movem.l	(a7)+,d0-d7/a0-a6		;restore context
	rte								;return to new task
;
;-----------------------------------------------------------------------
;
; This routine is called to do a context swap from the interrupt level
;
; It is called from ExitInterrupt via a JSR
; This routine assumes that all registers were pushed onto the stack
; when the interrupt service routine was entered
;
;-----------------------------------------------------------------------
;
_IrqSwap:
	lea		14(a7),a7				;Ignore returns from calls to
									;_IrqSwap,ExitInterrupt
	move.l	_CurrentTask,a0			;get pointer to stack pointer save area
	move.l	a7,(a0)					;save the stack pointer
	move.l	_ReadyTask,a0			;get pointer to stack pointer of new task
	move.l	a0,_CurrentTask			;Set Current Task=New Task
	move.l	(a0),a7					;get new stack pointer
	movem.l	(a7)+,d0-d7/a0-a6		;restore context
	rte								;return to new task

;------------------------------------------------------------------------
;
; This routine is called to run the first task and get multitasking
; running.
; This is called from the task level with a JSR
;
;------------------------------------------------------------------------

__Start:
	move.l	_ReadyTask,a0
	move.l	a0,_CurrentTask			;set currently running task
	move.l	(a0),a7					;set stack pointer
	movem.l	(a7)+,d0-d7/a0-a6		;pop registers from stack
	rte								;run the task

;------------------------------------------------------------------------
;
; Critical Enter and Exit routines.  We need to disable the interrupts
; and then re-enable them to the same interrupt level
;
;------------------------------------------------------------------------

	SECTION data
_CriticalLevel	dc	0
StatusReg		dc	0

	SECTION code

_EnterCritical:
	move	sr,d0		    ;move status register to D0 to Return
	ori.w	#0x0700,sr		;disable interrupts
	and.w	#0x0700,d0		;mask off all other garbage
	rts

_ExitCritical:
;
; this function recieves back the level to which to restore interrupts
;



; %+4(A7) <- m
	move	sr,d0
	and		#0xf8ff,d0
	or		4(A7),d0
	move	d0,sr
	MOVE.L	(A7)+,A0
	ADDQ.L	#2,A7
	JMP	(A0)

	END
