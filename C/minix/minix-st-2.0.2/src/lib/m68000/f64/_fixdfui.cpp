#
 ! C68 8 byte floating point => 32 bit unsigned conversion routines
 !-----------------------------------------------------------------------------
 ! ported to 68000 by Kai-Uwe Bloem, 12/89
 !	#1	original author: Peter S. Housel 6/12/89,6/14/89
 !	#2	replaced shifts by swap if possible for speed increase -kub-, 01/90
 !	#3	Added wrapper routine to provide C68 IEEE support
 !											   Dave & Keith Walker	   02/92
 !	#4	Changed entry/exit code for C68 v4.3 compatibility
 !		Removed ACK entry point
 !		Changed exception handling code 						-djw-	09/93
 !	#5	Changed to use new parameter formats					-djw-	01/96
 !-----------------------------------------------------------------------------

BIAS8  =	   0x3FF - 1

	   .sect .text

!	   .define .Ydftoul
	.define	fpdtoul

!----------------------------------------
!	   sp	   Return address
!	   sp+4    double
!----------------------------------------
!.Ydftoul:
fpdtoul:
	   move.w  4(sp),d0 	   ! extract exp
	   move.w  d0,a1		   ! extract sign
	   lsr.w   #4,d0
	   and.w   #0x07ff,d0	   ! kill sign bit

	   cmp.w   #BIAS8,d0	   ! check exponent
	   blt	   zer8 		   ! strictly factional, no integer part ?
	   cmp.w   #BIAS8+32,d0    ! is it too big to fit in a 32-bit integer ?
	   bgt	   oflow

	   movem.l 4(sp),d1-d2	   ! get the value
	   and.l   #0x0fffff,d1    ! remove exponent from mantissa
	   or.l    #0x100000,d1    ! restore implied leading "1"

	   sub.w   #BIAS8+21,d0    ! adjust exponent
	   bgt	   2f			   ! shift up
	   beq	   3f			   ! no shift

	   cmp.w   #-8,d0		   ! replace far shifts by swap
	   bgt	   1f
	   move.w  d1,d2		   ! shift fast, 16 bits
	   swap    d2
	   clr.w   d1
	   swap    d1
	   add.w   #16,d0		   ! account for swap
	   bgt	   2f
	   beq	   3f

1:	   lsr.l   #1,d1		   ! shift down to align radix point;
	   add.w   #1,d0		   ! extra bits fall off the end (no rounding)
	   blt	   1b			   ! shifted all the way down yet ?
	   bra	   3f

2:	   add.l   d2,d2		   ! shift up to align radix point
	   addx.l  d1,d1
	   sub.w   #1,d0
	   bgt	   2b
	   bra	   3f
zer8:
	   clr.l   d1			   ! make the whole thing zero

3:	   move.l  d1,d0
	   move.w  a1,d2		   ! get sign into d2
	   tst.w   d2			   ! is it negative ?
	   bpl	   finish
	   neg.l   d0			   ! negate

finish:
!	move.l	(sp)+,a0			! get return address
!	add.l	#8,sp				! tidy stack ( 1 x double)
!	jmp 	(a0)				! and return to caller
	rts

oflow:
!	jsr .overflow
	move.l	#-1,d0				! set ULONG_MAX as reply ( same bits as -1)
	bra finish
