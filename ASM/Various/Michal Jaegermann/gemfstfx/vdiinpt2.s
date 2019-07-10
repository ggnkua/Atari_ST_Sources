*
*  Most of this source was created by disassembling file vdiinpt2.o
*  from vdifast.a library by Ian Lepore.  Code for vsm_string(),
*  vrq_string() was replaced to fix an original buggy version.
*
*  Michal Jaegermann, October 1990
*
	.even
	.text
	.globl _vsin_mode
_vsin_mode:

	link     a6,#-2
	move.w   8(a6),-(sp)
	clr.l    -(sp)
	move.w   #2,-(sp)
	subq.w   #2,sp
	clr.w    -(sp)
	move.w   #33,-(sp)
	subq.l   #4,sp
	pea      -2(a6)
	subq.l   #4,sp
	pea      10(a6)
	pea      16(sp)
	jmp      vdicall

	.globl _vrq_locator, _vsm_locator
_vrq_locator:
_vsm_locator:
	link     a6,#-4
	move.w   8(a6),-(sp)
	clr.l    -(sp)
	clr.l    -(sp)
	move.w   #1,-(sp)
	move.w   #28,-(sp)
	pea      -4(a6)
	move.l   22(a6),-(sp)
	pea      10(a6)
	subq.l   #4,sp
	pea      16(sp)
	moveq    #115,d0
	move.l   sp,d1
	trap     #2
	move.l   14(a6),a0
	move.w   -4(a6),(a0)
	move.l   18(a6),a0
	move.w   -2(a6),(a0)
	move.w   28(sp),d0
	lsl.w    #1,d0
	or.w     24(sp),d0
	unlk     a6
	rts      

	.globl _vsm_valuator
_vsm_valuator:
	link     a6,#-6
	st       -6(a6)
	bra      D0

	.globl _vrq_valuator
_vrq_valuator:
	link     a6,#-6
	clr.b    -6(a6)
D0:
	move.w   8(a6),-(sp)
	clr.l    -(sp)
	move.w   #1,-(sp)
	subq.w   #2,sp
	clr.w    -(sp)
	move.w   #29,-(sp)
	subq.l   #4,sp
	pea      -4(a6)
	subq.l   #4,sp
	pea      10(a6)
	pea      16(sp)
	moveq    #115,d0
	move.l   sp,d1
	trap     #2
	move.l   12(a6),a0
	move.w   -4(a6),(a0)
	move.l   16(a6),a0
	move.w   -2(a6),(a0)
	tst.b    -6(a6)
	beq      D1
	move.l   20(a6),a0
	move.w   28(sp),(a0)
D1:
	unlk     a6
	rts      
	.globl _vrq_choice
_vrq_choice:
	link     a6,#0
	move.w   8(a6),-(sp)
	clr.l    -(sp)
	move.w   #1,-(sp)
	subq.w   #2,sp
	clr.w    -(sp)
	move.w   #30,-(sp)
	subq.l   #4,sp
	move.l   12(a6),-(sp)
	subq.l   #4,sp
	pea      10(a6)
	pea      16(sp)
	jmp      vdicall
	.globl _vsm_choice
_vsm_choice:
	link     a6,#0
	move.w   8(a6),-(sp)
	clr.l    -(sp)
	clr.l    -(sp)
	clr.w    -(sp)
	move.w   #30,-(sp)
	subq.l   #4,sp
	pea      10(a6)
	subq.l   #8,sp
	pea      16(sp)
	moveq    #115,d0
	move.l   sp,d1
	trap     #2
	move.w   28(sp),d0
	unlk     a6
	rts      
*
* Replacement for vrq_string and vsm_string in gemfast 1.3 libraries
* Blocking or non-blocking mode is set by a call to vsin_mode.
* Returns a number of characters received ond fills supplied string
* buffer.  An information on scan codes is lost
*
* Modifies registers d0, d1, a0 and a1.
*
* Michal Jaegermann, Edmonton - October 1990
*
	.even
	.globl _vrq_string, _vsm_string
_vsm_string:
_vrq_string:
	link     a6,#0
	move.w   10(a6),d0
	bpl      L0
	neg.w    d0
L0:
	add.w    d0,d0
	sub.w    d0,sp		;reserve space for max_length words - intout
	move.w   8(a6),-(sp)	;handle - contrl[6]
	clr.l    -(sp)		;contrl[5, 4]
	move.w   #2,-(sp)	;# in intin - contrl[3]
*	moveq	 #2,d0
*	move.l	 d0,-(sp)
	subq.w   #2,sp		; contrl[2]
*	move.w   #1,-(sp)	;# in ptsin
*	move.w   #31,-(sp)	;opcode - top of cntrl array
	move.l   #$001f0001,-(sp) ; save two bytes - contrl [1, 0]
*				;ptsout not used
	pea      14(sp)		;intout
	pea	 14(a6)		;ptsin	echo x and y
	pea      10(a6)		;intin	max_len, mode
	pea      12(sp)		;cntrl - now at location 16(sp)
	moveq    #115,d0
	move.l   sp,d1
	trap     #2
	move.w   24(sp),d0      ;cntrl[4] -> d0
	move.w	 d0,d1
	lea      30(sp),a0	;intout - same as &cntrl[7]
	move.l   18(a6),a1	;output string address
	bra	 L2
L1:
	addq.l   #1,a0		;skip one byte
	move.b   (a0)+,(a1)+	;get a character
L2:
	dbra	 d1,L1
	clr.b	 (a1)		;write string terminator
	unlk     a6
	rts      
