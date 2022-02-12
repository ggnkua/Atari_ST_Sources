#ifndef SOZOBON
|
| single float to double float conversion routine
|
	.text
	.even
	.globl	__extendsfdf2, ___extendsfdf2

__extendsfdf2:
___extendsfdf2:

#ifndef	__M68881__
# ifndef sfp004
|
| written by Kai-Uwe Bloem (I5110401@dbstu1.bitnet).
| Based on a 80x86 floating point packet from comp.os.minix, written by P.Housel
|
| Revision 1.3, michal 05-93 :
| code cleanup
|
| Revision 1.2, kub 01-90 :
| added support for denormalized numbers
|
| Revision 1.1, kub 12-89 :
| Ported over to 68k assembler
|
| Revision 1.0:
| original 8088 code from P.S.Housel

BIAS4	=	0x7F-1
BIAS8	=	0x3FF-1

	movel   sp@(4),d0	| get number
	moveml	d2-d7,sp@-	| save regs to keep norm_df happy
	moveq	#0,d5		| prepare double mantissa

	movel	d0,d4
	swap	d0		| extract exponent
	movew	d0,d2		| extract sign
	bclr	#15,d0		| kill sign bit (exponent is 8 bits)
	lsrw	#7,d0
	andl	#0x7fffff,d4	| remove exponent from mantissa

	moveql	#-1,d1
	cmpb	d1,d0
	bne	nospec
	tstl	d4
	beq	retinf
| ret nan
	movel	d1,d0
	lsrl	#1,d0		| #0x7fffffff -> d0
	bra	return
retinf:	movel	d4,d1		| 0 -> d1
	movel	#0xffe00000,d0
	lslw	#1,d2		| get extension bit
	roxrl	#1,d0		| shift in sign bit
return:	moveml	sp@+,d2-d7
	rts

nospec: bset	#23,d4		| restore implied leading "1"
	tstw	d0		| check for zero exponent - no leading "1"
	bne	1f		| for denormalized numbers
	bclr	#23,d4		| so clear it and ...
	addw	#1,d0		| "normalize" exponent
1:
	addw	#BIAS8-BIAS4-3,d0	| adjust bias, account for shift
	clrw	d1		| dummy rounding info

	jmp	norm_df

# else	sfp004

| single precision floating point stuff for Atari-gcc using the SFP004
| developed with gas
|
| single float to double float conversion routine
|
| M. Ritzert (mjr at dmzrzu71)
|
| 4.10.1990
|
| no NAN checking implemented since the 68881 treats this situation "correct",
| i.e. according to IEEE

| addresses of the 68881 data port. This choice is fastest when much data is
| transferred between the two processors.

comm =	 -6
resp =	-16
zahl =	  0

| waiting loop ...
|
| wait:
| ww:	cmpiw	#0x8900,a1@(resp)
| 	beq	ww
| is coded directly by
|	.long	0x0c688900, 0xfff067f8

	lea	0xfffffa50:w,a0
	movew	#0x4400,a0@(comm)	| load argument to fp0
	cmpiw	#0x8900,a0@(resp)	| check
	movel	sp@(4),a0@		| now push arg
	movew	#0x7400,a0@(comm)	| result to d0/d1
	.long	0x0c688900, 0xfff067f8
	movel	a0@,d0			| pop double float
	movel	a0@,d1
	rts

# endif	sfp004
#else	__M68881__

| mjr:	provided for safety. should be never called.
|
| single precision floating point stuff for Atari-gcc
| developed with gas
|
| single float to double float conversion routine
|
| M. Ritzert (mjr at dfg.dbp.de)
|
| 4.10.1990
| 11.11.1991
|
| no NAN checking implemented since the 68881 treats this situation "correct",
| i.e. according to IEEE

	fmoves	sp@(4),fp0	| load argument to fp0
	fmoved	fp0,sp@-	| read back as double
	moveml	sp@+,d0-d1
	rts

#endif	__M68881__

#else

;
; single float to double float conversion routine
;
	.text
	.even
#ifdef GNUNAMES
	.globl	__extendsfdf2, ___extendsfdf2

__extendsfdf2:
___extendsfdf2:

#else
	.globl	fpftod
#endif /* GNUNAMES */

fpftod:
;
; written by Kai-Uwe Bloem (I5110401@dbstu1.bitnet).
; Based on a 80x86 floating point packet from comp.os.minix, written by P.Housel
;
; Revision 1.3, michal 05-93 :
; code cleanup
;
; Revision 1.2, kub 01-90 :
; added support for denormalized numbers
;
; Revision 1.1, kub 12-89 :
; Ported over to 68k assembler
;
; Revision 1.0:
; original 8088 code from P.S.Housel

BIAS4	.equ	$7F-1
BIAS8	.equ	$3FF-1

	move.l  4(sp),d0	; get number
	movem.l	d2-d7,-(sp)	; save regs to keep norm_df happy
	moveq	#0,d5		; prepare double mantissa

	move.l	d0,d4
	swap	d0		; extract exponent
	move.w	d0,d2		; extract sign
	bclr	#15,d0		; kill sign bit (exponent is 8 bits)
	lsr.w	#7,d0
	and.l	#$7fffff,d4	; remove exponent from mantissa

	moveq.l	#-1,d1
	cmp.b	d1,d0
	bne	nospec
	tst.l	d4
	beq	retinf
; ret nan
	move.l	d1,d0
	lsr.l	#1,d0		; #0x7fffffff -> d0
	bra	return
retinf:	move.l	d4,d1		; 0 -> d1
	move.l	#$ffe00000,d0
	lsl.w	#1,d2		; get extension bit
	roxr.l	#1,d0		; shift in sign bit
return:	movem.l	(sp)+,d2-d7
	rts

nospec: bset	#23,d4		; restore implied leading "1"
	tst.w	d0		; check for zero exponent - no leading "1"
	bne	l1f		; for denormalized numbers
	bclr	#23,d4		; so clear it and ...
	add.w	#1,d0		; "normalize" exponent
l1f:
	add.w	#BIAS8-BIAS4-3,d0	; adjust bias, account for shift
	clr.w	d1		; dummy rounding info

	jmp	norm_df

#endif /*  SOZOBON */
