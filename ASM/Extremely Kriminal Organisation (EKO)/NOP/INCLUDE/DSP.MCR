
Dsp_doblock		macro
	move.l	#\4,-(sp)
	pea	\3
	move.l	#\2,-(sp)
	pea	\1
	move.w	#96,-(sp)
	trap	#14
	lea	18(sp),sp
	endm


Dsp_blkhandshake	macro
	move.l	#\4,-(sp)
	pea	\3
	move.l	#\2,-(sp)
	pea	\1
	move.w	#97,-(sp)
	trap	#14
	lea	18(sp),sp
	endm


Dsp_blkunpacked		macro
	move.l	#\4,-(sp)
	pea	\3
	move.l	#\2,-(sp)
	pea	\1
	move.w	#98,-(sp)
	trap	#14
	lea	18(sp),sp
	endm



*#define	Dsp_InStream(a,b,c,d)			(void) xbios(99,a,b,c,d)
*#define	Dsp_OutStream(a,b,c,d)			(void) xbios(100,a,b,c,d)
*#define	Dsp_IOStream(a,b,c,d,e,f)		(void) xbios(101,a,b,c,d,e,f)
*#define	Dsp_RemoveInterrupts(a)			(void) xbios(102,a)

Dsp_getwordsize		macro
	move.w	#103,-(sp)
	trap	#14
	addq.l	#2,sp
	endm	


Dsp_lock		macro
	move.w	#104,-(sp)
	trap	#14
	addq.l	#2,sp
	endm	

Dsp_unlock		macro
	move.w	#105,-(sp)
	trap	#14
	addq.l	#2,sp
	endm	

Dsp_available		macro
	pea	\2
	pea	\1
	move.w	#106,-(sp)
	trap	#14
	lea	10(sp),sp
	endm

*#define	Dsp_Reserve(a,b)			(int) xbios(107,a,b)

Dsp_loadprog		macro
	pea	\3
	move.w	#\2,-(sp)
	pea	\1
	move.w	#108,-(sp)
	trap	#14
	lea	12(sp),sp
	endm

Dsp_execprog	macro
	move.w	#\3,-(sp)
	move.l	#\2,-(sp)
	pea	\1
	move.w	#109,-(sp)
	trap	#14
	lea	12(sp),sp
	endm

Dsp_execboot	macro
	move.w	#\3,-(sp)
	move.l	#\2,-(sp)
	pea	\1
	move.w	#110,-(sp)
	trap	#14
	lea	12(sp),sp
	endm

*#define	Dsp_LodToBinary(a,b)			(long) xbios(111,a,b)
*#define	Dsp_TriggerHC(a)			(void) xbios(112,a)

Dsp_requestuniqueability 	macro
	move.w	#113,-(sp)
	trap	#14
	addq.l	#2,sp
	endm	





Dsp_getprogability	macro
	move.w	#114,-(sp)
	trap	#14
	addq.l	#2,sp
	endm	


Dsp_flushsubroutines	macro
	move.w	#115,-(sp)
	trap	#14
	addq.l	#2,sp
	endm	




*#define	Dsp_LoadSubroutine(a,b,c)		(int)  xbios(116,a,b,c)
*#define	Dsp_InqSubrAbility(a)			(int)  xbios(117,a)
*#define	Dsp_RunSubroutine(a)			(int)  xbios(118,a)
*#define	Dsp_Hf0(a)				(int)  xbios(119,a)
*#define	Dsp_Hf1(a)				(int)  xbios(120,a)

Dsp_hf2			macro
	move.w	#121,-(sp)
	trap	#14
	addq.l	#2,sp
	endm	


Dsp_hf3			macro
	move.w	#122,-(sp)
	trap	#14
	addq.l	#2,sp
	endm	


Dsp_blkwords		macro
	move.l	#\4,-(sp)
	pea	\3
	move.l	#\2,-(sp)
	pea	\1
	move.w	#123,-(sp)
	trap	#14
	lea	18(sp),sp
	endm


Dsp_blkbytes		macro
	move.l	#\4,-(sp)
	pea	\3
	move.l	#\2,-(sp)
	pea	\1
	move.w	#124,-(sp)
	trap	#14
	lea	18(sp),sp
	endm


Dsp_hstat		macro
	move.w	#125,-(sp)
	trap	#14
	addq.l	#2,sp
	endm	


*#define Dsp_SetVectors(a,b)			(void) xbios(126,a,b)
