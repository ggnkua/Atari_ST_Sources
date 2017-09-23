Dsp_BlkHandShake	macro	data_in,size_in,data_out,size_out
			move.l	\4,-(sp)
			move.l	\3,-(sp)
			move.l	\2,-(sp)
			move.l	\1,-(sp)
			move.w	#97,-(sp)
			trap	#14
			lea	18(sp),sp
			endm

Dsp_BlkUnpacked	macro	data_in,size_in,data_out,size_out
		move.l	\4,-(sp)
		move.l	\3,-(sp)
		move.l	\2,-(sp)
		move.l	\1,-(sp)
		move.w	#98,-(sp)
		trap	#14
		lea	18(sp),sp
		endm

Dsp_Lock	macro
		move.w	#104,-(sp)
		trap	#14
		addq.l	#2,sp
		endm

Dsp_Unlock	macro
		move.w	#105,-(sp)
		trap	#14
		addq.l	#2,sp
		endm

Dsp_Available	macro	xavailable,yavailable
		move.l	\2,-(sp)
		move.l	\1,-(sp)
		move.w	#106,-(sp)
		trap	#14
		lea	10(sp),sp
		endm

Dsp_Reserve	macro	xreserve,yreserve
		move.l	\2,-(sp)
		move.l	\1,-(sp)
		move.w	#107,-(sp)
		trap	#14
		lea	10(sp),sp
		endm

Dsp_LoadProg	macro	file,ability,buffer
		move.l	\3,-(sp)
		move.w	\2,-(sp)
		move.l	\1,-(sp)
		move.w	#108,-(sp)
		trap	#14
		lea	10(sp),sp
		endm

Dsp_ExecProg	macro	codeptr,codesize,ability
		move.w	\3,-(sp)
		move.l	\2,-(sp)
		move.l	\1,-(sp)
		move.w	#109,-(sp)
		trap	#14
		lea	12(sp),sp
		endm

Dsp_RequestUniqueAbility	macro
				move.w	#113,-(sp)
				trap	#14
				addq.l	#2,sp
				endm

Dsp_BlkWords	macro	data_in,size_in,data_out,size_out
		move.l	\4,-(sp)
		move.l	\3,-(sp)
		move.l	\2,-(sp)
		move.l	\1,-(sp)
		move.w	#123,-(sp)
		trap	#14
		lea	18(sp),sp
		endm

Dsp_BlkBytes	macro	data_in,size_in,data_out,size_out
		move.l	\4,-(sp)
		move.l	\3,-(sp)
		move.l	\2,-(sp)
		move.l	\1,-(sp)
		move.w	#124,-(sp)
		trap	#14
		lea	18(sp),sp
		endm
