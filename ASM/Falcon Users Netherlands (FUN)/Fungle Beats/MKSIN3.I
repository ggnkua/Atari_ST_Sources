*==========================================================================
* Sinewave table generator.
* By EarX/~fUn~, 10-5-1998
* 68020 or higher is required!
*==========================================================================

******** GLOBAL CONSTANTS ********

includemode	equ	1		* 0=standalone prg, 1=include

* >WARNING< for these equ's: when using a new 'sintbllen' you must
* recalculate 'cos1' and 'sin1'!
sintbllen	equ	2048		* MUST BE A EXPONENTIAL VALUE OF 2!
sin1		equ	13176774	* sin(2ã/2048)*2^32
cos1		equ	4294947083	* cos(2ã/2048)*2^32

******** MACROS ********

* Macro that returns the modulo of a given angle.
* INPUT: angle: type: data-register (word) or RAM (word)
Do_SinModulo	MACRO	angle
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
Get_SinCos	MACRO	base,inpreg,sinreg,cosreg
	movem.w	(\1,\2.w*4),\3/\4
	ENDM

* Macro that returns sine of a given angle.
* PRECONDITION: INIT_SINETABLE has been called!
* INPUT: a0: address of sine_tbl
*        base: type: address-register or address or relative address
*        inpreg: type: data-register or address-register (lower word)
*                contains: angle (0=0ø, sintbllen=360ø)
* OUTPUT: sinreg: type: data-register (long) or address-register
*                 contains: sine value (signed: -32768 to 32767)
Get_Sin	MACRO	base,inpreg,sinreg
	move.w	(\1,\2.w*4),\3
	ENDM

* Macro that returns cosine of a given angle.
* PRECONDITION: INIT_SINETABLE has been called!
* INPUT: a0: address of sine_tbl
*        base: type: address-register or address or relative address
*        inpreg: type: data-register or address-register (lower word)
*                contains: angle (0=0ø, sintbllen=360ø)
* OUTPUT: cosreg: type: data-register (long) or address-register
*                 contains: cosine value (signed: -32768 to 32767)
Get_Cos	MACRO	base,inpreg,sinreg,cosreg
	move.w	2(\1,\2.w*4),\3
	ENDM

* Creates the a combined sine and cosine table for quick fetching.
* Macro is exactly 96 bytes in length :-)
* INPUT: a0: address of sine_tbl
Init_SineTable	MACRO
	moveq	#$ffffffff,d0		* /cos(0)=1
	lsr.l	#1,d0			* \(=$7fffffff)
	moveq	#0,d1			* sin(0)=0
	move.l	#sin1,d6
	move.w	#sintbllen/4-1,d7

.genlop	swap	d0			* Get high-word of cosa
	swap	d1			* Get high-word of sina
	move.w	d1,2+(sintbllen)*3(a0)	* Copy sina in cos-4th quadrant
	move.w	d0,sintbllen*1(a0)	* Copy cosa in sin-2nd quadrant
	sub.w	d1,2+(sintbllen)*1(a0)	* Copy -sina in cos-2nd quadrant
	sub.w	d0,sintbllen*3(a0)	* Copy -cosa in sin-4th quadrant
	sub.w	d0,2+(sintbllen)*2(a0)	* Copy -cosa in cos-3rd quadrant
	sub.w	d1,sintbllen*2(a0)	* Copy -sina in sin-3rd quadrant
	move.w	d1,(a0)+		* Save sina (16 bit signed value) in first quadrant
	move.w	d0,(a0)+		* Save cosa (16 bit signed value) in first quadrant
	swap	d0			* Change cosa back to fixedpoint
	swap	d1			* Change sina back to fixedpoint
	move.l	d1,d4			* / Backup sina 
	move.l	d0,d5			* | and cosa
	move.l	d1,d2			* | for use in
	move.l	d0,d3			* \ multiplications.
	mulu.l	d6,d3:d1		* d3:=sin1*sina
	mulu.l	#cos1,d2:d0		* d2:=cos1*cosa
	mulu.l	d6,d1:d5		* d0:=sin1*cosa
	mulu.l	#cos1,d0:d4		* d1:=cos1*sina
	sub.l	d3,d2			* d2:=(cos1*cosa)-(sin1*sina)
	add.l	d0,d1			* sina:=(sin1*cosa)+(cos1*sina)
	move.l	d2,d0			* cosa:=(cos1*cosa)-(sin1*sina)
	dbra	d7,.genlop
	ENDM

******** GLOBAL DATA + INCLUDES ********

	data

******** GLOBAL RESERVES ********

	bss
	even