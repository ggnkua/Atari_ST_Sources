;=============================================================================
; DANCE DANCE DANCE !!
;  Tobe / MJJ PROD
;  DHS 10 years online compo
;-----------------------------------------------------------------------------
; MATH.S : fast integer maths
;=============================================================================


;=============================================================================
				SECTION TEXT
;=============================================================================


;-----------------------------------------------------------------------------
; fast_sqrt : compute a fast integer inverse square root
;	arg : d0
;	ret : d0
;-----------------------------------------------------------------------------
;  original C code by Jim Ulery :
;      static unsigned mborg_isqrt3(unsigned long val)
;      {
;        unsigned long temp, g=0, b = 0x8000, bshft = 15;
;        do {
;          if (val >= (temp = (((g<<1)+b)<<bshft--))) {
;            g += b;
;            val -= temp;
;          }
;        } while (b >>= 1);
;        return g;
;      }
;-----------------------------------------------------------------------------

fast_sqrt:
	movem.l		d1-d4,			-(sp)
	moveq		#0,				d1			; g = 0
	move.l		#$8000,			d2			; b = $8000
	moveq		#15,			d3			; bshft = 15
fast_sqrt_0:
	move.l		d1,				d4			; temp = g
	add.l		d1,				d4			; temp = g<<1
	add.l		d2,				d4			; temp = (g<<1)+b
	lsl.l		d3,				d4			; temp = ((g<<1)+b)<<bshft
	subq.l		#1,				d3			; bshft--
	cmp.l		d0,				d4			; val >= temp ?
	bhi.s		fast_sqrt_1					;	no -> fast_sqrt_1
	add.l		d2,				d1			; g += b
	sub.l		d4,				d0			; val -= temp
fast_sqrt_1:
	lsr.l		#1,				d2			; b >>= 1, b!=0 ?
	bne.s		fast_sqrt_0					;	yes -> fast_sqrt_0
	move.l		d1,				d0			; return g
	movem.l 	(sp)+,			d1-d4
	rts

;-----------------------------------------------------------------------------
; int_rnd : compute a pseudo random integer
;-----------------------------------------------------------------------------

int_rnd:
	move.l		d1,				-(sp)
	move.l		d2,				-(sp)
	move.l		math_rnd,		d0			; get current
	moveq		#4,				d2			; do this 5 times
int_rnd_0:
	moveq		#0,				d1			; clear bit count
	ror.l		#2,				d0			; bit 31 -> carry
	bcc			int_rnd_1					; skip increment if =0
	addq.b		#1,				d1			; else increment bit count
int_rnd_1:
	ror.l		#3,				d0			; bit 28 -> carry
	bcc			int_rnd_2					; skip increment if =0
	addq.b		#1,				d1			; else increment bit count
int_rnd_2:
	rol.l		#5,				d0			; restore prng longword
	roxr.b		#1,				d1			; eor bit into xb
	roxr.l		#1,				d0			; shift bit to most significant
	dbf			d2,int_rnd_0				; loop 5 times
	move.l		d0,math_rnd					; save back to seed word
	move.l		(sp)+,			d2
	move.l		(sp)+,			d1
	rts


;=============================================================================
				SECTION TEXT
;=============================================================================


math_rnd:		dc.l		$87654321


;=============================================================================
;				END OF FILE
;=============================================================================

