#
 ; C68 floating point => 32 bit unsigned conversion routines
 ;-----------------------------------------------------------------------------
 ; ported to 68000 by Kai-Uwe Bloem, 12/89
 ;	#1	original author: Peter S. Housel 6/12/89,6/14/89
 ;	#2	replaced shifts by swap if possible for speed increase -kub-, 01/90
 ;	#3	Added wrapper routine to provide C68 IEEE support
 ;											   Dave & Keith Walker	   02/92
 ;	#4	Changed entry/exit code for C68 v4.3 compatibility
 ;		Removed ACk entry points										09/93
 ;	#5	Changed to new parameter formats						-djw-	01/96
 ;-----------------------------------------------------------------------------

BIAS4  .equ	   $7F - 1

;	   .sect .text

;	   .define .Ysftoul
	.globl	fpftoul

;----------------------------------------
;	   sp	   Return address
;	   sp+4    float to convert
;----------------------------------------
;.Ysftoul:
fpftoul:
	   move.w  4(sp),d0 		; extract exp
	   move.w  d0,d2		   ; extract sign
	   lsr.w   #7,d0		   ; shift down 7
	   and.w   #$0ff,d0	   ; kill sign bit

	   cmp.w   #BIAS4,d0	   ; check exponent
	   blt	   zer4 		   ; strictly fractional, no integer part ?
	   cmp.w   #BIAS4+32,d0    ; is it too big to fit in a 32-bit integer ?
	   bgt	   toobig

	   move.l  4(sp),d1
	   and.l   #$7fffff,d1    ; remove exponent from mantissa
	   or.l    #$800000,d1    ; restore implied leading "1"

	   sub.w   #BIAS4+24,d0    ; adjust exponent
	   bgt	   m2			   ; shift up
	   beq	   m2			   ; no shift

	   cmp.w   #-8,d0		   ; replace far shifts by swap
	   bgt	   m1
	   clr.w   d1			   ; shift fast, 16 bits
	   swap    d1
	   add.w   #16,d0		   ; account for swap
	   bgt	   m2
	   beq	   m3

m1:	   lsr.l   #1,d1		   ; shift down to align radix point;
	   add.w   #1,d0		   ; extra bits fall off the end (no rounding)
	   blt	   m1			   ; shifted all the way down yet ?
	   bra	   m3

m2:	   add.l   d1,d1		   ; shift up to align radix point
	   sub.w   #1,d0
	   bgt	   m2
	   bra	   m3
zer4:
	   clr.l   d1			   ; make the whole thing zero
m3:	   move.l  d1,d0
	   tst.w   d2			   ; is it negative ?
	   bpl	   m8
	   neg.l   d0			   ; negate

m8:
;	move.l	(sp)+,a0			; get return address
;	add.l	#4,sp				; tidy stack ( 1 x float )
;	jmp 	(a0)				; return to caller
	rts

toobig:
;	jsr .overflow
	move.l	#$ffffffff,d0	; set ULONG_MAX as reply
	bra m8
