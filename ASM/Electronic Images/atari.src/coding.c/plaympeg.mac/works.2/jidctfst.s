; V.Fast 8x8 IDCT Routine (not 100% accurate)

DCTSIZE		EQU	8
		
; a0 -> input

I_dct_fast:	move.w	DCTSIZE*2*0(a0),d0		;tmp0
		move.w	DCTSIZE*2*1(a0),d1		;tmp4
		move.w	DCTSIZE*2*2(a0),d2		;tmp1
		move.w	DCTSIZE*2*3(a0),d3		;tmp5
		move.w	DCTSIZE*2*4(a0),d4		;tmp2
		move.w	DCTSIZE*2*5(a0),d5		;tmp6
		move.w	DCTSIZE*2*6(a0),d6		;tmp3
		move.w	DCTSIZE*2*7(a0),d7		;tmp7
		or.w	d1,d7
		or.w	d2,d7
		or.w	d3,d7
		or.w	d4,d7
		or.w	d5,d7
		or.w	d6,d7
		bne.s	.notquick_c
		move.w	d0,DCTSIZE*2*0(a0)
		move.w	d0,DCTSIZE*2*1(a0)
		move.w	d0,DCTSIZE*2*2(a0)
		move.w	d0,DCTSIZE*2*3(a0)
		move.w	d0,DCTSIZE*2*4(a0)
		move.w	d0,DCTSIZE*2*5(a0)
		move.w	d0,DCTSIZE*2*6(a0)
		move.w	d0,DCTSIZE*2*7(a0)
		rts

.notquick_c	
		move.w	d0,a1
		add.w	d4,a1				; tmp10 = tmp0 + tmp2;	
		move.w	d0,a2
		sub.w	d4,a2				; tmp11 = tmp0 - tmp2;
		move.w	d2,a2
		add.w	d6,a2				; tmp13 = tmp1 + tmp3;	/* phases 5-3 */
		move.w	
    tmp12 = MULTIPLY(tmp1 - tmp3, FIX_1_414213562) - tmp13; /* 2*c4 */

.notquick_c	 