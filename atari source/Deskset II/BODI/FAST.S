**********************************************************************	
* FILE:	FAST.S							     *
* DATE: November 6, 1989					     *
* DESCRIPTION: Rewrites of many of the conversion routines in...     *
*	       CONVERT.C					     *
*	       ASM.C						     *
*	       IFOUT.C						     *
**********************************************************************	
false equ 0
true  equ $FFFF
STUFF equ true
SCALED equ true

**********************************************************************
* VARIABLES							     *
**********************************************************************	
	.globl	 _zdevice			;Device index
	.globl	 _axdpi				;xdpi array
	.globl	 _aydpi				;ydpi array
	.globl	 _xdpi				;GOG xdpi array
	.globl	 _ydpi				;GOG ydpi array
	.globl	 _sdevm				;GOG index into array
	.globl	 _zrat				;GOG variable for ratio to use
	.globl	 _pgeptr
	.globl	 _pixtbl

**********************************************************************	
* FUNCTIONS							     *
**********************************************************************	
	.globl	 _hmupix			; Horizontal Machine Units to Pixel
	.globl	 _vmupix			; Vertical Machine Units to Pixel
	.globl	 _hpixmu			; Horizontal Pixel to Machine Units
	.globl	 _vpixmu			; Vertical Pixel to Machine Units
	.globl	 _scaler			; Scaler routine
	.globl	 _scaleme			; Replaces scale_me()

	.globl	 _worldx			; MU to Pixel conversion GOG
	.globl	 _worldy			; MU to Pixel conversion GOG
	.globl	 _zvalue			; SCALER GOG

	.globl	 _f_move			; forward block moves	GOG
	.globl	 _Lf_move			; long forward block moves GOG
	.globl	 _r_move			; reverse block moves GOG
	.globl	 _Lr_move			; long reverse block moves GOG

	.globl	 _put_pix

**********************************************************************
* Horizontal Machine Units to Pixel Conversions			     *
* Handles negative numbers too					     *
* Formerly hmutopix()						     *
* IN:  		D0 - Units to convert (munits)(signed)		     *
*								     *
* INTERNAL:	A0 - axdpi array				     *
* 		D1 - index into xdpi array			     *
*								     *
* OUT: 		D0 - converted number				     *
*								     *
* Algorithm:	( munits * axdpi(zdevice) + 648)/1296		     *
**********************************************************************
_hmupix:
	move.w	_zdevice,d1			;get index
	add.w	d1,d1				;double it to get bytes
	lea	_axdpi,a0			;get array
	move.w	4(sp),d0			;munits
	bmi.s	.10				;branch if neg
	mulu	(a0,d1.w),d0			;munits * axdpi[zdevice]
	add.l	#648,d0				;add 648
	divu	#1296,d0			;divide by 1296
	rts
.10:
	neg.w	d0				;handle sign
	mulu	(a0,d1.w),d0			;munits * axdpi[zdevice]
	add.l	#648,d0				;add 648
	divu	#1296,d0			;divide by 1296
	neg.w	d0				;restore sign
	rts


**********************************************************************	
* Vertical Machine Units to Pixel Conversion			     *
* Formerly vmutopix()						     *
* Handles negative numbers too					     *
* IN:		d0 - Number to convert (munits)	(signed)	     *
*								     *
* INTERNAL:	a0 - aydpi array				     *
*		d1 - zdevice - index into aydpi array		     *
*								     *
* OUT:		d0 - converted units				     *
*								     *
* Algorithm:    (munits * aydpi[zdevice] + 576)/1152		     *
**********************************************************************		
_vmupix:
	move.w	_zdevice,d1			;Index into aydpi array
	add.w	d1,d1				;double to get bytes
	lea	_aydpi,a0			;get aydpi array
	move.w	4(sp),d0			;munits
	bmi.s	.10				;branch if neg
	mulu	(a0,d1.w),d0			;munits * aydpi[zdevice]
	add.l	#576,d0				;add 576
	divu	#1152,d0			;divide by 1152
	rts
.10:
	neg.w	d0				;handle the sign
	mulu	(a0,d1.w),d0			;munits * aypdi[zdevice]
	add.l	#576,d0				;add 576
	divu	#1152,d0			;divide by 1152
	neg.w	d0				;restore sign
	rts
	

**********************************************************************	
* Horizontal Pixel to Machine Units				     *
* Formerly hpixtomu()						     *
* Handles negative numbers too!					     *
* IN:		d0 - number to convert (pixels)(signed)		     *
*								     *
* INTERNAL:	d1 - zdevice - index into axdpi array		     *
*		a0 - axdpi array				     *
*		d2 - xdpi/2					     *
*		d3 - current xdpi				     *
*								     *
* OUT:		d0 - converted number in munits			     *
* 								     *
* Algorithm:	(pixels * 1296 + (axdpi[zdevice]/2))/axdpi[zdevice]  *
**********************************************************************		
_hpixmu:
	move.w	_zdevice,d1			;Get index into array
	add.w	d1,d1				;get it in byes	
	lea	_axdpi,a0			;get array
	moveq	#0,d2
	move.w	(a0,d1.w),d2			;put xdpi into d2
	move.l	d2,d3				;copy to d3
	asr.l	#1,d2				;Get xdpi/2
	move.w	4(sp),d0			;pixels
	bmi.s	.10				;branch if negative
	mulu	#1296,d0			;pixels * 1296
	add.l	d2,d0				;add xdpi/2
	divu	d3,d0				;divide by xdpi
	rts
.10:
	neg.w	d0				;make positive
	mulu	#1296,d0			;pixels * 1296
	add.l	d2,d0				;add xdpi/2
	divu	d3,d0				;divide by xdpi
	neg.w	d0				;restore sign
	rts



**********************************************************************	
* Vertical Pixel to Machine Units				     *
* Formerly vpixtomu()						     *
* Handles negative numbers too!					     *
* IN:		d0 - number to convert (pixels)(signed)		     *
*								     *
* INTERNAL:	d1 - zdevice - index into aydpi array		     *
*		a0 - aydpi array				     *
*		d2 - ydpi /2					     *
*		d3 - current y dpi				     *
*								     *
* OUT:		d0 - converted number in munits			     *
*								     *
* Algorithm:	(pixels * 1152 + aydpi[zdevice]/2)/aydpi[zdevice]    *
**********************************************************************	
_vpixmu:
	move.w	_zdevice,d1			;Get index into array
	add.w	d1,d1				;get it in bytes
	lea	_aydpi,a0			;get array
	moveq	#0,d2
	move.w	(a0,d1.w),d2			;get dpi
	move.l	d2,d3				;copy it to d3
	asr.l	d2				;get ydpi/2
	move.w	4(sp),d0			;pixels
	bmi.s	.10				;branch if negative
	mulu	#1152,d0			;pixels * 1152
	add.l	d2,d0				;add ydpi/2
	divu	d3,d0				;divide by ydpi
	rts
.10:
	neg.w	d0				;make positive
	mulu	#1152,d0			;pixels * 1152
	add.l	d2,d0				;add ydpi/2
	divu	d3,d0				;divide by ydpi
	neg.w	d0				;restore sign
	rts


.if SCALED
**********************************************************************	
* General Purpose Scaler					     *
* Replaces scale_iv() and scale_v()				     *
* Algorithm: (visible * factor + total/2)/total			     *
* where A,B and C are signed.					     *
* IN:		d0 - visible (signed)				     *
*		d1 - total   (signed)				     *
*								     *
* INTERNAL:	d2 - total/2					     *
*								     *
* OUT:		d0 - Returns converted number			     *
**********************************************************************	
_scaler:
	move.w	4(sp),d0	
	move.w	8(sp),d1
	move.w	d1,d2
	muls	6(sp),d0
	bmi.s	.10
	asr.w	#1,d2
	bpl.s	.11
	bra.s	.12
.10:
	asr.w	#1,d2
	bmi.s	.11
.12:
	neg.w	d2
.11:	
	ext.l	d2
	add.l	d2,d0
	divs	d1,d0
	rts
.endif

**********************************************************************	
* GOG World to x Coordinates					     *
* Replace world_rc_x()						     *
* Also, this incorporates zvalue directly into the routine	     *
* IN:		d0 - number to be converted to pixels(signed)	     *
*								     *
* INTERNAL:							     *
*	        zvalue: d1 - ratio(100,75,50 etc - zrat)	     *
*								     *			
*		scaler: d1 - sdevm (index into xdpi array)	     *
*			a0 - xdpi array				     *
*								     *
* OUT:		d0 - converted number				     *
*								     *
* Algorithm:    (a * b + c/2)/c					     *
**********************************************************************	
_worldx:
	move.w	_zrat,d1		;Get current ratio
	move.w	4(sp),d0		;get pixels
	bmi.s	.11			;branch if negative
	cmpi.w	#100,d1			;check current ratio
	beq.s	.10			;skip zvalue handling if 100%
	mulu	d1,d0			;handle zvalue - zrat * pixel
	add.l	#50,d0			;add 50
	divu	#100,d0			;divide by 100
*
.10:					;handle number AFTER zvalue handling
	move.w	_sdevm,d1		;Index int xdpi array
	add.w	d1,d1			;convert to bytes
	lea	_xdpi,a0		;get array
	mulu	(a0,d1.w),d0		;pixels * xdpi[sdevm]
	add.l	#648,d0			;add 648
	divu	#1296,d0		;divide by 1296
	rts
*
.11:					;Negative #s
	neg.w	d0			;make positive
	cmpi.w	#100,d1			;if 100%
	beq.s	.12			;skip zvalue handling
	mulu	d1,d0			;pixels * zrat
	add.l	#50,d0			;add 50
	divu	#100,d0			;divide by 100
*
.12:					;handle #s AFTER zvalue handling
	move.w	_sdevm,d1		;get index into xdpi array
	add.w	d1,d1			;convert to bytes
	lea	_xdpi,a0		;get array
	mulu	(a0,d1.w),d0		;pixels * xdpi[sdevm]
	add.l	#648,d0			;add 648
	divu	#1296,d0		;divide by 1296
	neg.w	d0			;restore sign
	rts



**********************************************************************	
* GOG World to Y Coordinates					     *
* Replaces world_rc_y()						     *
* Includes zvalue() internally					     *
* IN:		d0 - number to convert (pixels)(signed)		     *
*								     *
* INTERNAL:							     *
*	zvalue: d1 - zrat (ratio 100,75,etc)			     *
*								     *
*	scaler: d1 - sdevm (index into ydpi array)		     *
*		a0 - ydpi array					     *
*								     *
* OUT:		d0 - Converted number				     *
*								     *
* Algorithm: 	(a * b + c/2)/c					     *
**********************************************************************	
_worldy:
	move.w	_zrat,d1		;Get zratio		     
	move.w	4(sp),d0		;get pixels
	bmi.s	.11			;branch if negative number
	cmpi.w	#100,d1			;if 100%...
	beq.s	.10			;skip zvalue handling
	mulu	d1,d0			;pixels * zrat
	add.l	#50,d0			;add 50
	divu	#100,d0			;divide by 100
*
.10:					;handle # AFTER zvalue
	move.w	_sdevm,d1		;get index into array
	add.w	d1,d1			;convert to bytes
	lea	_ydpi,a0		;get array
	mulu	(a0,d1.w),d0		;pixels * ydpi[sdevm]
	add.l	#576,d0			;add 576
	divu	#1152,d0		;divide by 1152
	rts
*
.11:					;negative number
	neg.w	d0			;make positive
	cmpi.w	#100,d1			;if 100%
	beq.s	.12			;skip zvalue handling
	mulu	d1,d0			;pixel * zrat
	add.l	#50,d0			;add 50
	divu	#100,d0			;divide by 100
*
.12:					;handle neg values AFTER zvalue
	move.w	_sdevm,d1		;get index into array
	add.w	d1,d1			;convert to bytes
	lea	_ydpi,a0		;get array	
	mulu	(a0,d1.w),d0		;pixels * ydpi[sdevm]
	add.l	#576,d0			;add 576
	divu	#1152,d0		;divide by 1152
	neg.w	d0			;restore sign
	rts


**********************************************************************	
* GOG ZVALUE() rewritten					     *
* IN:		d0 - number to be converted	(signed)	     *
*								     *
* INTERNAL:	d1 - zrat (current ratio 100,75,50 etc)		     *
*								     *
* OUT:		d0 - converted number				     *
*								     *
* Algorithm: (a * b + 50)/100					     *
**********************************************************************	
_zvalue:
	 move.w	_zrat,d1		;get ratio
	 cmpi.w	#100,d1			;we at 100%?
	 beq.s	.11			;skip entirely if so...
	 move.w	4(sp),d0		;get number to convert
	 bmi.s	.10			;branch if negative
	 mulu	d1,d0			;num * zrat
	 add.l	#50,d0			;add 50
	 divu	#100,d0			;divide by 100
	 rts
.10:
	 neg.w	d0			;make positive
	 mulu	d1,d0			;num * zrat
	 add.l	#50,d0			;add 50
	 divu	#100,d0			;divide by 100
	 neg.w	d0			;restore sign
.11:	
	rts


**********************************************************************	
* FUNCTION: _scaleme()						     *
* Formerly scale_me() in convert.c				     *
* IN:		d0 - number to scale	(signed)		     *
*		d1 - scaler		(unsigned)		     *
*		d2 - flag 0 - convert from mu to percentage	     *
*								     *
* INTERNAL:	d3 - scaler/2					     *
*								     *
* OUT:		d0 - converted number				     *
* 								     *
* Algorithm:    (a * b + c/2)/c					     *
**********************************************************************	
_scaleme:
	moveq	#0,d1
	move.w	6(sp),d1	; scaler
	move.w	8(sp),d2	; flag
	tst.b	d2		; test the flag
	bne.s 	.10		; 1 or 0?
	move.w	4(sp),d0	; convert from mu to percentage
	bmi.s	.11		; branch if minus
	mulu	d1,d0		; num * scaler
	add.l	#50,d0		; add 50
	divu	#100,d0		; divide by 100
	rts
*	
.11:				; negative
	neg.w	d0		; make positive
	mulu	d1,d0		; num * scaler
	add.l	#50,d0		; add 50
	divu	#100,d0		; divide by 100
	neg.w	d0		; restore sign
	rts
*
.10:				; Convert from percentage to mu
	move.l	d1,d3		; copy scaler
	asr.l	#1,d3		; divide it by 2
	move.w	4(sp),d0	; get number
	bmi.s	.12		; branch if minus
	mulu	#100,d0		; num * 100
	add.l	d3,d0		; add scaler/2
	divu	d1,d0		; divide by scaler
	rts
*
.12:				; negative
	neg.w	d0		; make positive
	mulu	#100,d0		; num * 100
	add.l	d3,d0		; add scaler/2
	divu	d1,d0		; divide by scaler
	neg.w	d0		; restore sign
	rts


**********************************************************************
* FUNCTIONS: _f_move() and _Lf_move()				     *
* Replaces the fmove() and Lf_move() in asm.c			     *
* and takes into account whether the src/dst and count are odd/even  *
* when even, we can do word moves instead of byte moves		     *
**********************************************************************
_f_move:
	move.l	4(sp),d0	;SRC
	move.l  8(sp),d1	;DST
	moveq	#0,d2
	move.w	12(sp),d2	;COUNT
	bra.s	_entry		;br to rest of routine

_Lf_move:
	lea	4(sp),a0
	movem.l	(a0),d0-d2	;d0-> SRC, d1-> DST, d2.l = count
_entry:
	move.l	d0,a0		;copy SRC to a0
	move.l	d1,a1		;copy DST to a1
	eor.w	d1,d0		;check for ODD/EVEN or EVEN/ODD SRC/DST
	andi.w	#1,d0
	bne.s	.oddeveni	;br if mixed ODD/EVEN SRC/DST;do bytes

*
*	SRC/DST are both either ODD/ODD or EVEN/EVEN...
*
	lsr.l	#1,d2		;divide count by 2 for word moves
	bcc.s	.evcount	;br if even count
*
*	COUNT is ODD... (must be at least 1)
*
	andi.w	#1,d1		;is SRC/DST EVEN/EVEN or ODD/ODD?
	beq.s	.doev		;br if EVEN/EVEN
*
*	SRC/DST is ODD/ODD
*
	move.b	(a0)+,(a1)+	;need to start w/byte move
	bra.s	.oddoddi
.oddotop:
	swap	d2
.oddodd:
	move.w	(a0)+,(a1)+
.oddoddi:
	dbra	d2,.oddodd
	swap	d2
	dbra	d2,.oddotop
	rts
*
*
*
.evnetop:
	swap	d2
.evnevn:
	move.w	(a0)+,(a1)+
.doev:
	dbra	d2,.evnevn
	swap	d2
	dbra	d2,.evnetop
	move.b	(a0)+,(a1)+
	rts
*
*	COUNT is EVEN
*
.evcount:
	andi.w	#1,d1		;is SRC/DST EVEN/EVEN or ODD/ODD?
	beq.s	.doevx		;br if EVEN/EVEN
*
*	SRC/DST is ODD/ODD
*
	subq.l	#1,d2		;is count = 0?
	bmi.s	.oddxx		;exit if so...
*
	move.b	(a0)+,(a1)+	;need to start w/byte move
	bra.s	.oddoddxi
.oddotopx:
	swap	d2
.oddoddx:
	move.w	(a0)+,(a1)+
.oddoddxi:
	dbra	d2,.oddoddx
	swap	d2
	dbra	d2,.oddotopx
	move.b	(a0)+,(a1)+
.oddxx:
	rts
*
*
*
.evnetopx:
	swap	d2
.evnevnx:
	move.w	(a0)+,(a1)+
.doevx:
	dbra	d2,.evnevnx
	swap	d2
	dbra	d2,.evnetopx
	rts
*
*
*	need to use byte moves
.oddevtop:
	swap	d2
.oddeven:
	move.b	(a0)+,(a1)+
.oddeveni:
	dbra	d2,.oddeven
	swap	d2
	dbra	d2,.oddevtop
	rts



**********************************************************************
* FUNCTIONS: _r_move() and _Lr_move()				     *
* Replaces the fmove() and Lf_move() in asm.c			     *
* and takes into account whether the src/dst and count are odd/even  *
* when even, we can do word moves instead of byte moves		     *
**********************************************************************
_r_move:
	move.l	4(sp),d0	;SRC
	move.l  8(sp),d1	;DST
	moveq	#0,d2
	move.w	12(sp),d2	;COUNT
	bra.s	_entry2		;br to rest of routine

_Lr_move:
	lea	4(sp),a0
	movem.l	(a0),d0-d2	;d0-> SRC, d1-> DST, d2.l = count
_entry2:
	addq.l	#1,d0
	addq.l	#1,d1
	move.l	d0,a0		;copy SRC to a0
	move.l	d1,a1		;copy DST to a1
	eor.w	d1,d0		;check for ODD/EVEN or EVEN/ODD SRC/DST
	andi.w	#1,d0
	bne.s	.oddeveni	;br if mixed ODD/EVEN SRC/DST;do bytes

*
*	SRC/DST are both either ODD/ODD or EVEN/EVEN...
*
	lsr.l	#1,d2		;divide count by 2 for word moves
	bcc.s	.evcount	;br if even count
*
*	COUNT is ODD... (must be at least 1)
*
	andi.w	#1,d1		;is SRC/DST EVEN/EVEN or ODD/ODD?
	beq.s	.doev		;br if EVEN/EVEN
*
*	SRC/DST is ODD/ODD
*
	move.b	-(a0),-(a1)	;need to start w/byte move
	bra.s	.oddoddi
.oddotop:
	swap	d2
.oddodd:
	move.w	-(a0),-(a1)
.oddoddi:
	dbra	d2,.oddodd
	swap	d2
	dbra	d2,.oddotop
	rts
*
*
*
.evnetop:
	swap	d2
.evnevn:
	move.w	-(a0),-(a1)
.doev:
	dbra	d2,.evnevn
	swap	d2
	dbra	d2,.evnetop
	move.b	-(a0),-(a1)
	rts
*
*	COUNT is EVEN
*
.evcount:
	andi.w	#1,d1		;is SRC/DST EVEN/EVEN or ODD/ODD?
	beq.s	.doevx		;br if EVEN/EVEN
*
*	SRC/DST is ODD/ODD
*
	subq.l	#1,d2		;is count = 0?
	bmi.s	.oddxx		;exit if so...
*
	move.b	-(a0),-(a1)	;need to start w/byte move
	bra.s	.oddoddxi
.oddotopx:
	swap	d2
.oddoddx:
	move.w	-(a0),-(a1)
.oddoddxi:
	dbra	d2,.oddoddx
	swap	d2
	dbra	d2,.oddotopx
	move.b	-(a0),-(a1)
.oddxx:
	rts
*
*
*
.evnetopx:
	swap	d2
.evnevnx:
	move.w	-(a0),-(a1)
.doevx:
	dbra	d2,.evnevnx
	swap	d2
	dbra	d2,.evnetopx
	rts
*
*
*	need to use byte moves
.oddevtop:
	swap	d2
.oddeven:
	move.b	-(a0),-(a1)
.oddeveni:
	dbra	d2,.oddeven
	swap	d2
	dbra	d2,.oddevtop
	rts




_put_pix:
	move.l	_pgeptr,d0
	move.w	6(sp),d1
	ext.l	d1
	mulu	8(sp),d1
	add.l	d1,d0
	move.w	4(sp),d1
	ext.l	d1
	divu	#8,d1
	move.l	d1,d2
	ext.l	d1
	add.l	d1,d0
	swap.w	d2
	movea.w d2,a1
	adda.l	_pixtbl,a1
	move.b	(a1),d3
	movea.l	d0,a0
	or.b	d3,(a0)
	rts
