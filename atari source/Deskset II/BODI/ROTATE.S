*  Calls bigrot.s 

             .globl _rotate
	     .globl recrot

* a0 - address of buffer
* a1 - 16 * DST form in even bytes
* d0 - src width in even bytes
* d1 - dest width in even bytes
* d2 - # of multiples to use...see fastrot.s
* src width must be greater than dest width

_rotate: move.l $4(a7),a0
         move.l $8(a7),a1
         move.w $C(a7),d0
	 move.w $E(a7),d1
	 move.w $10(a7),d2
         jsr recrot
         rts
