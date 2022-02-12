#ifndef SOZOBON
| not needed with -__M68881__

#ifndef	__M68881__
	.text
	.even
	.globl	__truncdfsf2, ___truncdfsf2

__truncdfsf2:
___truncdfsf2:
# ifdef	sfp004

| double float to single float conversion routine
| oflow checking is omitted. The ''881 returns a signed infinity.
|
| Written by M.Ritzert
| 5.10.90
| ritzert@dfg.dbp.de
|

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
	movew	#0x5400,a0@(comm)	| load double to  fp0
	cmpiw	#0x8900,a0@(resp)	| check
	movel	a7@(4),a0@		| push arguments
	movel	a7@(8),a0@		|
	movew	#0x6400,a0@(comm)	| result (real) to d0
	.long	0x0c688900, 0xfff067f8
	movel	a0@,d0
	rts

# else	sfp004

| double float to single float conversion routine
|
| written by Kai-Uwe Bloem (I5110401@dbstu1.bitnet).
| Based on a 80x86 floating point packet from comp.os.minix, written by P.Housel
|
| Revision 1.2.2 michal 05-93: (ntomczak@vm.ucs.ualberta.ca)
|  + corrected bug in setting sign of returned Inf
|  + code cleanup
|
| patched by Olaf Flebbe (flebbe@tat.physik.uni-tuebingen.de)
|
| Revision 1.2.1 olaf 12-92 :
|  + added support for Inf and NaN.
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

	moveml	sp@(4),d0-d1	| get number
	moveml	d2-d5,sp@-	| save regs

	movel	d0,d4		| save for norm_df
	swap	d0		| extract exponent
	movew	d0,d2		| extract sign
	bclr	#15,d0		| kill sign bit
	lsrw	#4,d0
	andl	#0x0fffff,d4	| remove exponent from mantissa
|
|
|
	cmpw	#0x7ff,d0
	bne	nospec
	orl	d4,d1
	bne	retnan
	movel   #0xff00000,d0
	lslw	#1,d2
	roxrl	#1,d0
return:	moveml	sp@+,d2-d5
	rts
retnan:	moveq	#-1,d0
	lsrl	#1,d0		| #0x7fffffff -> d0
	bra	return

| Should we really return SNaN, which has a sign bit set accordingly??
| if yes, then the following code can be used instead -- mj
|
|	cmpw	#0x7ff,d0
|	bne	nospec
|	orl	d4,d1
|	bne	retnan
|	movel   #0xff00000,d0
|return:
|	lslw	#1,d2		| set X bit
|	roxrl	#1,d0		| roll in sign bit
|	moveml	sp@+,d2-d5
|	rts
|retnan:	moveq	#-1,d0
|	bra	return

nospec:	movel	d1,d5
	bset	#20,d4		| restore implied leading "1"
	tstw	d0		| check for zero exponent - no leading "1"
	bne	1f		| for denormalized numbers
	bclr	#20,d4		| ... so do not do it but instead
	addw	#1,d0		| "normalize" exponent
1:
	addw	#BIAS4-BIAS8,d0	| adjust bias

	addl	d5,d5		| shift up to realign mantissa for floats
	addxl	d4,d4
	addl	d5,d5
	addxl	d4,d4
	addl	d5,d5
	addxl	d4,d4

	movel	d5,d1		| set rounding bits
	roll	#8,d1
	andl	#0x00ffffff,d5	| check to see if sticky bit should be set
	beq	2f
	orb	#1,d1		| set sticky bit
2:
	jmp	norm_sf		| (leave regs on stack for norm_sf)

# endif	sfp004
#endif	__M68881__

#else

	.text
	.even
#ifdef GNUNAMES
	.globl	__truncdfsf2, ___truncdfsf2
__truncdfsf2:
___truncdfsf2:
#else
	.globl	fpdtof
#endif /* GNUNAMES */
fpdtof:
; double float to single float conversion routine
;
; written by Kai-Uwe Bloem (I5110401@dbstu1.bitnet).
; Based on a 80x86 floating point packet from comp.os.minix, written by P.Housel
;
; Revision 1.2.2 michal 05-93: (ntomczak@vm.ucs.ualberta.ca)
;  + corrected bug in setting sign of returned Inf
;  + code cleanup
;
; patched by Olaf Flebbe (flebbe@tat.physik.uni-tuebingen.de)
;
; Revision 1.2.1 olaf 12-92 :
;  + added support for Inf and NaN.
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

	movem.l	4(sp),d0-d1	; get number
	movem.l	d2-d5,-(sp)	; save regs

	move.l	d0,d4		; save for norm_df
	swap	d0		; extract exponent
	move.w	d0,d2		; extract sign
	bclr	#15,d0		; kill sign bit
	lsr.w	#4,d0
	and.l	#$0fffff,d4	; remove exponent from mantissa
;
;
;
	cmp.w	#$7ff,d0
	bne	nospec
	or.l	d4,d1
	bne	retnan
	move.l  #$ff00000,d0
	lsl.w	#1,d2
	roxr.l	#1,d0
return:	movem.l	(sp)+,d2-d5
	rts
retnan:	moveq	#-1,d0
	lsr.l	#1,d0		; #0x7fffffff -> d0
	bra	return

; Should we really return SNaN, which has a sign bit set accordingly??
; if yes, then the following code can be used instead -- mj
;
;	cmp.w	#$7ff,d0
;	bne	nospec
;	or.l	d4,d1
;	bne	retnan
;	move.l   #$ff00000,d0
;return:
;	lsl.w	#1,d2		; set X bit
;	roxr.l	#1,d0		; roll in sign bit
;	movem.l	(sp)+,d2-d5
;	rts
;retnan:	moveq	#-1,d0
;	bra	return

nospec:	move.l	d1,d5
	bset	#20,d4		; restore implied leading "1"
	tst.w	d0		; check for zero exponent - no leading "1"
	bne	l1		; for denormalized numbers
	bclr	#20,d4		; ... so do not do it but instead
	add.w	#1,d0		; "normalize" exponent
l1:
	add.w	#BIAS4-BIAS8,d0	; adjust bias

	add.l	d5,d5		; shift up to realign mantissa for floats
	addx.l	d4,d4
	add.l	d5,d5
	addx.l	d4,d4
	add.l	d5,d5
	addx.l	d4,d4

	move.l	d5,d1		; set rounding bits
	rol.l	#8,d1
	and.l	#$00ffffff,d5	; check to see if sticky bit should be set
	beq	l2
	or.b	#1,d1		; set sticky bit
l2:
	jmp	norm_sf		; (leave regs on stack for norm_sf)

#endif /* SOZOBON */
