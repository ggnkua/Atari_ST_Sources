;----------------------------------------------------------------------------
;File name:	TRACER.I			Revision date:	2000.07.02
;Created by:	Ulf Ronald Andersson		Creation date:	1998.06.23
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	IFND	BS_TRACER_defined
BS_TRACER_defined	set	1
;----------------------------------------------------------------------------
	include	RA_TOS.I
;----------------------------------------------------------------------------
trace_mode	set	1
;----------------------------------------------------------------------------
trace	MACRO	code
	IFNE	trace_mode
	bsr.\0	trace_CODE
	dc.b	\1,NUL
	ENDC
	ENDM	;trace
;----------------------------------------------------------------------------
trace_2	MACRO	code
	IFGT	(trace_mode-1)
	trace.\0	\1
	ENDC
	ENDM
;----------------------------------------------------------------------------
trace_3	MACRO	code
	IFGT	(trace_mode-2)
	trace.\0	\1
	ENDC
	ENDM
;----------------------------------------------------------------------------
trace_CODE	MACRO
	IFNE	trace_mode
trace_CODE:
	link	a6,#0
	movem.l	d0-d2/a0-a3,-(sp)
	lea	.trace_s(pc),a3
	move.l	4(a6),a1
	move.b	(a1),.trace_char-.trace_s(a3)
	addq.l	#2,4(a6)
	gemdos	Cconws,(a3)
	gemdos	Crawcin
	lea	.trace_count-.trace_s(a3),a0
	addq.b	#1,(a0)
	and.b	#$7F,(a0)
	or.b	#$40,(a0)
	movem.l	(sp)+,d0-d2/a0-a3
	unlk	a6
	rts
;-------
.trace_s:
	dc.b	'Trace = "'
.trace_char:
	dc.b	'@:'
.trace_count:
	dc.b	'@"',CR,LF,NUL
	EVEN
trace_CODE_end:
	ENDC
	ENDM	;trace_CODE
;----------------------------------------------------------------------------
	ENDC	;BS_TRACER_defined
;----------------------------------------------------------------------------
;End of file:	TRACER.I
;----------------------------------------------------------------------------
