;---------------------------------------------------- ldl --------
; extern int ldl ( int n, int ldmax ) ;
;					d0		d1

		.export ldl
ldl:	move	d0,d2
		beq		ld_bad

ld_loop:bclr	d1,d2
		dbne	d1,ld_loop

		tst		d2
		bne		ld_bad

		move	d1,d0	; ok
		rts

ld_bad:	moveq	#-1,d0	; error
		rts
				
;---------------------------------------------------- mul16x16 --------
; long mul16x16 ( int a, int b )
;					d0		d1
; {
;		return ( (long)a * (long)b ) ;
; }

			.export	mul16x16
mul16x16:	muls	d1,d0
			rts

; int iscale ( int a, int b, int c)
;			d0		d1		d2
; {
;		return ( (int)( (long)a * (long)b / (long)c ) ) ;
; }

			.export	iscale
iscale:		muls	d1,d0
			divs	d2,d0
			rts

; unsigned uscale ( unsigned a, unsigned b, unsigned c)
;			d0		d1		d2
; {
;		return ( (unsigned)( (long)a * (long)b / (long)c ) ) ;
; }

			.export	uscale
uscale:		mulu	d1,d0
			divu	d2,d0
			rts

;---------------------------------------------------- midcolw --------
; void midcolw ( int *dest, int factor, int *low, int *high, int unit )
;					a0			d0			a1	 	4(a7)		d1

			.export	midcolw
midcolw:	movem.l	d3/a2,-(A7)

			move.l	12(sp),a2
			moveq	#2,d3		; bc = B

;		*dest++ = *low++ + iscale ( *high++ - *low, factor, unit ) ;

mcwloop:	move	(a2)+,d2	; *high++
			sub		(a1),d2		;	.. - *low

			muls	d0,d2		; .. * factor
			divs	d1,d2		; .. / unit

			add		(a1)+,D2
			move	d2,(a0)+
			dbra	d3,mcwloop

			movem.l	(sp)+,d3/a2
			rts

.if 0
; ??? asm - bug ??? Endlos-Schleife bei swizz&X& ( s. u. )
BITSb	.equ	 8
BITSw	.equ	16
BITSl	.equ	32


.macro	swizz.X
			.local	sw_loop
			.export	swizz&X&
swizz&X&:	move.X	d0,d1
			clr.l	d0
swizz&X&e:	moveq	#BITS&X&-1,d2
  sw_loop:	roxr.l	#1,d1	; shift --> out
  			roxl.X	#1,d0	; shift <-- in
  			dbra	d2,sw_loop
  			
  			rts
.endm

; byte     swizzb ( byte     b )
	swizz.b

; unsigned swizzw ( unsigned w )
	swizz.w

; ulong    swizzl ( ulong    l )
	swizz.l


; uword swizzbb ( uword bb )

			.export	swizzbb
swizzbb:	; illegal

			move.w	d0,d1
			clr.l	d0
			bsr		swizzbe	; lo byte
			ror.w	#8,d0	; -> hi byte
			bsr		swizzbe	; hi byte
			ror.w	#8,d0	; lo hi -> hi lo

			rts
.endif

			.export	swap_long
swap_long:	swap	d0
			rts
			
