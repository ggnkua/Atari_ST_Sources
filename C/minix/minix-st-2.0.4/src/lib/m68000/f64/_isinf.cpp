#ifdef SOZOBON
;
; _isinf: needed by gcc-1.xx
; return true if number >= 0x7ff00000,0
; N.B.: just the opposite of Finite! (_isnan.cpp)
;
	.text
	.even
	.globl	_isinf

_isinf:	move.l	4(sp),d0
	bclr	#31,d0		; clear sign bit
	cmp.l	#$7ff00000,d0	; compare with infinity
	blt	No
	moveq.l	#1,d0
	rts
No:	clr.l	d0
	rts
#endif /* SOZOBON */
#ifdef __GNUC__
|
| _isinf: needed by gcc-1.xx
| return true if number >= 0x7ff00000,0
| N.B.: just the opposite of Finite! (_isnan.cpp)
|
	.text
	.even
	.globl	_isinf

_isinf:	movel	sp@(4),d0
	bclr	#31,d0		| clear sign bit
	cmpl	#0x7ff00000,d0	| compare with infinity
	blt	No
	moveql	#1,d0
	rts
No:	clrl	d0
	rts
#endif /* __GNUC__ */
