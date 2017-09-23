Vsetscreen	macro
	
	move.w	\4,-(sp)
	move.w	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	14(sp),sp
	
	endm
	
Vsetmode	macro

	move.w	\1,-(sp)
	move.w	#88,-(sp)
	trap	#14
	addq.w	#4,sp
	
	endm
	
mon_type	macro

	move.w	#89,-(sp)
	trap	#14
	addq.w	#2,sp
	
	endm
	
VgetSize	macro

	move.w	\1,-(sp)
	move.w	#91,-(sp)
	trap	#14
	addq.w	#4,sp
	
	endm

VsetSync	macro

	move.w	\1,-(sp)
	move.w	#90,-(sp)
	trap	#14
	addq.w	#4,sp
	
	endm
	
VsetRGB	macro

	move.l	\3,-(sp)
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#93,-(sp)
	trap	#14
	lea	10(sp),sp
	
	endm

VgetRGB	macro

	move.l	\3,-(sp)
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#94,-(sp)
	trap	#14
	lea	10(sp),sp
	
	endm

VsetMask	macro

	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#93,-(sp)
	trap	#14
	addq.w	#6,sp
	
	endm



Dsp_DoBlock	macro
	
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#96,-(sp)
	trap	#14
	lea	18(sp),sp
	
	endm
	
Dsp_BlkHandShake	macro
	
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#97,-(sp)
	trap	#14
	lea	18(sp),sp
	
	endm

Dsp_BlkUnpacked	macro
	
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#98,-(sp)
	trap	#14
	lea	18(sp),sp
	
	endm
	
Dsp_BlkWords	macro
	
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#123,-(sp)
	trap	#14
	lea	18(sp),sp
	
	endm

Dsp_BlkBytes	macro
	
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#124,-(sp)
	trap	#14
	lea	18(sp),sp
	
	endm

Dsp_MultBlocks	macro
	
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#127,-(sp)
	trap	#14
	lea	18(sp),sp
	
	endm
	
Dsp_InStream	macro
	
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#99,-(sp)
	trap	#14
	lea	18(sp),sp
	
	endm

Dsp_OutStream	macro
	
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#100,-(sp)
	trap	#14
	lea	18(sp),sp
	
	endm
	
Dsp_IOStream	macro
	
	move.l	\6,-(sp)
	move.l	\5,-(sp)
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#101,-(sp)
	trap	#14
	lea	26(sp),sp
	
	endm
	
Dsp_SetVectors	macro

	move.l	\2,-(sp)	
	move.l	\1,-(sp)	
	move.w	#126,-(sp)
	trap	#14
	lea	10(sp),sp
	
	endm
	
Dsp_RemoveInterrupts	macro

	move.w	\1,-(sp)
	move.w	#102,-(sp)
	trap	#14
	addq.w	#4,sp
	
	endm
	
Dsp_GetWordSize	macro

	move.w	#103,-(sp)
	trap	#14
	addq.w	#2,sp
	
	endm
	
Dsp_Lock	macro

	move.w	#104,-(sp)
	trap	#14
	addq.w	#2,sp
	
	endm

Dsp_Unlock	macro

	move.w	#105,-(sp)
	trap	#14
	addq.w	#2,sp
	
	endm
	
	
Dsp_Available	macro

	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#106,-(sp)
	trap	#14
	lea	10(sp),sp
	
	endm

Dsp_Reserve	macro

	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#107,-(sp)
	trap	#14
	lea	10(sp),sp
	
	endm

Dsp_LoadProg	macro

	move.l	\3,-(sp)
	move.w	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#108,-(sp)
	trap	#14
	lea	12(sp),sp
	
	endm
	
Dsp_ExecProg	macro

	move.w	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#109,-(sp)
	trap	#14
	lea	12(sp),sp
	
	endm

Dsp_ExecBoot	macro

	move.w	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#110,-(sp)
	trap	#14
	lea	12(sp),sp
	
	endm
	
Dsp_LodToBinary	macro

	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#111,-(sp)
	trap	#14
	lea	10(sp),sp
	
	endm
	
Dsp_TriggerHC	macro

	move.w	\1,-(sp)
	move.w	#112,-(sp)
	trap	#14
	addq.w	#4,sp
	
	endm
	
Dsp_RequestUniqueAbility	macro

	move.w	#113,-(sp)
	trap	#14
	addq.w	#2,sp
	
	endm
	
Dsp_GetProgAbility	macro

	move.w	#114,-(sp)
	trap	#14
	addq.w	#2,sp
	
	endm
	
Dsp_FlushSubroutines	macro

	move.w	#115,-(sp)
	trap	#14
	addq.w	#2,sp
	
	endm

Dsp_LoadSubroutine	macro

	move.w	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#116,-(sp)
	trap	#14
	lea	12(sp),sp
	
	endm
	
Dsp_InqSubrAbility	macro

	move.w	\1,-(sp)
	move.w	#117,-(sp)
	trap	#14
	addq.w	#4,sp
	
	endm
	
Dsp_RunSubroutine	macro

	move.w	\1,-(sp)
	move.w	#118,-(sp)
	trap	#14
	addq.w	#4,sp
	
	endm

Dsp_Hf0	macro

	move.w	\1,-(sp)
	move.w	#119,-(sp)
	trap	#14
	addq.w	#4,sp
	
	endm

Dsp_Hf1	macro

	move.w	\1,-(sp)
	move.w	#120,-(sp)
	trap	#14
	addq.w	#4,sp
	
	endm

Dsp_Hf2	macro

	move.w	#121,-(sp)
	trap	#14
	addq.w	#4,sp
	
	endm

Dsp_Hf3	macro

	move.w	#122,-(sp)
	trap	#14
	addq.w	#4,sp
	
	endm

Dsp_HStat	macro

	move.w	#125,-(sp)
	trap	#14
	addq.w	#4,sp
	
	endm
	

locksnd	macro

	move.w	#128,-(sp)
	trap	#14
	addq.w	#2,sp

	endm

unlocksnd	macro

	move.w	#129,-(sp)
	trap	#14
	addq.w	#2,sp

	endm
	
soundcmd	macro

	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.w	#6,sp
	
	endm
	
setbuffer	macro

	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#131,-(sp)
	trap	#14
	lea	12(sp),sp
	
	endm
	
setmode	macro

	move.w	\1,-(sp)
	move.w	#132,-(sp)
	trap	#14
	addq.w	#4,sp
	
	endm
	
settracks	macro

	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#133,-(sp)
	trap	#14
	addq.w	#6,sp
	
	endm
	
setmontracks	macro

	move.w	\1,-(sp)
	move.w	#134,-(sp)
	trap	#14
	addq.w	#4,sp
	
	endm
	
setinterrupt	macro

	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#135,-(sp)
	trap	#14
	addq.w	#6,sp
	
	endm
	
buffoper	macro

	move.w	\1,-(sp)
	move.w	#136,-(sp)
	trap	#14
	addq.w	#4,sp
	
	endm
	
dsptristate	macro

	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#137,-(sp)
	trap	#14
	addq.w	#6,sp
	
	endm
	
gpio	macro

	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#138,-(sp)
	trap	#14
	addq.w	#6,sp
	
	endm
	
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
	
sndstatus	macro

	move.w	\1,-(sp)
	move.w	#140,-(sp)
	trap	#14
	addq.w	#4,sp
	
	endm
	
buffptr	macro

	move.l	\1,-(sp)
	move.w	#141,-(sp)
	trap	#14
	addq.w	#6,sp
	
	endm
	
	
	
	
	