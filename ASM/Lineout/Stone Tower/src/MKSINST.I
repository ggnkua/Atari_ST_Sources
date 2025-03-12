*==========================================================================
* Sinewave table fetcher.
* By EarX/~fUn~, 21-09-98
* Runs on 68000, not optimised for 68020 in any way.
*==========================================================================

******** GLOBAL CONSTANTS ********

sintbllen:	equ	2048		* MUST BE A EXPONENTIAL VALUE OF 2!

******** MACROS ********

* Macro that returns the modulo of a given angle.
* INPUT: angle: type: data-register (word) or RAM (word)
Do_SinModulo:	MACRO	angle
	andi.w	#sintbllen-1,\1
	ENDM

* Macro that returns sine & cosine of a given angle.
* PRECONDITION: INIT_SINETABLE has been called!
* INPUT: a0: address of sine_tbl
*        base: type: address-register or address or relative address
*        inpreg: type: data-register or address-register (lower word)
*                contains: angle (0=0ø, sintbllen=360ø)
* OUTPUT: sinreg: type: data-register (long) or address-register
*                 contains: sine value (signed: -32768 to 32767)
*         cosreg: type: data-register (long) or address-register
*                 contains: cosine value (signed: -32768 to 32767)
* WARNING: inpreg.w will be shifted!
Get_SinCos:	MACRO	base,inpreg,sinreg,cosreg
	lsl.w	#2,\2
	movem.w	(\1,\2.w),\3/\4
	ENDM

* Macro that returns sine of a given angle.
* PRECONDITION: INIT_SINETABLE has been called!
* INPUT: a0: address of sine_tbl
*        base: type: address-register or address or relative address
*        inpreg: type: data-register or address-register (lower word)
*                contains: angle (0=0ø, sintbllen=360ø)
* OUTPUT: sinreg: type: data-register (long) or address-register
*                 contains: sine value (signed: -32768 to 32767)
* WARNING: inpreg.w will be shifted!
Get_Sin:	MACRO	base,inpreg,sinreg
	lsl.w	#2,\2
	move.w	(\1,\2.w),\3
	ENDM

* Macro that returns cosine of a given angle.
* PRECONDITION: INIT_SINETABLE has been called!
* INPUT: a0: address of sine_tbl
*        base: type: address-register or address or relative address
*        inpreg: type: data-register or address-register (lower word)
*                contains: angle (0=0ø, sintbllen=360ø)
* OUTPUT: cosreg: type: data-register (long) or address-register
*                 contains: cosine value (signed: -32768 to 32767)
* WARNING: inpreg.w will be shifted!
Get_Cos:	MACRO	base,inpreg,sinreg,cosreg
	lsl.w	#2,\2
	move.w	2(\1,\2.w),\3
	ENDM