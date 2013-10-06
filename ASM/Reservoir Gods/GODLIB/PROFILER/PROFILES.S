**************************************************************************************
*	PROFILERS.S
*
*	Profiler interrupt
*
*	[c] 2001 Reservoir Gods
**************************************************************************************

**************************************************************************************
;	EXPORTS / IMPORTS
**************************************************************************************

	export	Profiler_HBL
	export	Profiler_HBLDummy
	export	Profiler_VBL

	import	Profiler_Update

	import	gpProfilerBuffer
	import	gProfilerIndex


**************************************************************************************
	TEXT
**************************************************************************************

*------------------------------------------------------------------------------------*
* FUNCTION : Profiler_HBL
* ACTION   : 68000 version of HBL interrupt
* CREATION : 01.05.01 PNK
*------------------------------------------------------------------------------------*

Profiler_HBL:
	move.l	d0,-(a7)
	move.l	a0,-(a7)

	move.l	gProfilerIndex,d0
	move.l	gpProfilerBuffer,a0
	addq.l	#4,d0
	andi.l	#(32*1024)-1,d0
	move.l	d0,gProfilerIndex
	move.l	8+2(sp),(a0,d0.l)

	move.l	(a7)+,a0
	move.l	(a7)+,d0

	rte


*------------------------------------------------------------------------------------*
* FUNCTION : Profiler_HBLDummy
* ACTION   : does nowt
* CREATION : 01.05.01 PNK
*------------------------------------------------------------------------------------*

Profiler_HBLDummy:
	
	rte


*------------------------------------------------------------------------------------*
* FUNCTION : Profiler_VBL
* ACTION   : 68000 version of VBL interrupt
* CREATION : 01.05.01 PNK
*------------------------------------------------------------------------------------*

Profiler_VBL:
	tas.b	gProfilerVblLockFlag
	bne.s	.locked
	movem.l	d0-a6,-(a7)
	jsr		Profiler_Update
	movem.l	(a7)+,d0-a6
	clr.b	gProfilerVblLockFlag
.locked:
	rts

gProfilerVblLockFlag:	ds.b	1