*************************************************************************
* MEMOPS.S - MC68000 Machine language cohort for a DRI C host           *
*   whose sole function in life is the wholesale altering of memory     *
* Copyright 1986 Daniel Matejka                                         *
*   Feel free to use these things, but credit would be appreciated...   *
*************************************************************************

.globl  _setmem
.globl  _movmem

.text

*************************************************************************
* setmem(addr,count,value)                                              *
*   char *addr; int count,value;                                        *
* fills memory beginning at "addr" with "count" reps of "value"         *
*************************************************************************

* a0.l is "addr"
* d0.w is "count"
* d1.b is "value"

_setmem:

* load data from stack to appropriate registers
*
                clr.l   d0
                clr.l   d1
                move.l  4(sp),a0
                move.w  8(sp),d0
                move.w  10(sp),d1
                move.w  d1,d2           * copy for future reference
                tst     d0              * count is zero?
                beq     fillend         * if so, bail out
*
* d1 becomes the (byte) fill value repeated four times (long word)
*
                lsl.l   #8,d1
                or.b    d2,d1
                lsl.l   #8,d1
                or.b    d2,d1
                lsl.l   #8,d1
                or.b    d2,d1
*
* is destination address odd?  if so, fix that
*
                move.l  a0,d2
                btst    #0,d2
                beq     lfinit
                move.b  d1,(a0)+        * set first byte
                subq.w  #1,d0
*
* hokay, fill memory with long register value, count / 4 times
*
lfinit:         move.l  d0,d2
                lsr     #2,d0           * divide count by 4
                bra     lfs
lfb:            move.l  d1,(a0)+
lfs:            dbf     d0,lfb
*
* now clean up the remaining fill (by the byte, count mod 4 times)
*
                andi.w  #3,d2
                bra     bfs
bfb:            move.b  d1,(a0)+
bfs:            dbf     d2,bfb
fillend:        rts


*************************************************************************
* movmem(source,destination,count)                                      *
*   char *source,*destination;                                          *
*   int   count;                                                        *
* movmem moves "count" bytes from "source" to "destination"             *
*************************************************************************

* a0 is "source"
* a1 is "destination"
* d0 is "count"

_movmem:

* transfer data from stack to appropriate registers
*
                clr.l   d0
                move.l  4(sp),a0
                move.l  8(sp),a1
                move.w  12(sp),d0
                tst     d0                   * is count zero?
                bne     movbeg               * if not, continue
                rts
*
* if destination > source, branch to routine which moves from high to low
*
movbeg:         cmpa.l  a0,a1
                bhi     revord               * to reverse order routines
*
* here we are moving from low to high addresses
*
                move.l  a0,d1
                btst    #0,d1                * is source odd?
                beq     nseven
                move.l  a1,d1
                btst    #0,d1                * is destination odd?
                beq     nmix
*
* source, destination both odd.  make them both even
*
                move.b  (a0)+,(a1)+
                subq.w  #1,d0
                bra     nlm
*
* one is odd, the other even.  sorry.  do the move byte-by-byte
*
nmloop:         move.b  (a0)+,(a1)+
nmix:           dbf     d0,nmloop
                rts
*
* source is even.  check destination for same
*
nseven:         move.l  a1,d1
                btst    #0,d1
                bne     nmix                 * odd destination
*
* move memory by 4-byte chunks, then clean up with 1-byte chunk routine
*
nlm:            move.l  d0,d1
                andi.w  #3,d0                * d0 mod 4
                asr.w   #2,d1                * d0 div 4
                bra     nls
nlloop:         move.l  (a0)+,(a1)+
nls:            dbf     d1,nlloop
                bra     nmix                 * finish up remaining move
*
* here we are doing things from high to low addresses.  this is otherwise
* the same as the low-to-high routine described above.
*
revord:         adda.l  d0,a0
                adda.l  d0,a1                * go to high end of move
                move.l  a0,d1
                btst    #0,d1                * source even?
                beq     rseven
                move.l  a1,d1
                btst    #0,d1                * destination even?
                beq     rmix

                move.b  -(a0),-(a1)          * both odd: move one byte
                subq.w  #1,d0
                bra     rlm

rmloop:         move.b  -(a0),-(a1)          * one odd, one even
rmix:           dbf     d0,rmloop
                rts

rseven:         move.l  a1,d1
                btst    #0,d1                * destination odd?
                bne     rmix

rlm:            move.l  d0,d1
                andi.w  #3,d0
                lsr.w   #2,d1
                bra     rls
rlloop:         move.l  -(a0),-(a1)          * both even
rls:            dbf     d1,rlloop
                bra     rmix

