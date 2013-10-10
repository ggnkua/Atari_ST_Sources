;*****************************************************************************;
;   routines to draw envelopes within axes area
;      also mazetabl used by copy protection
;   Copyright 1986 Tom Bajoras
;   input:  d6.l = operator # (0-5)
;*****************************************************************************;

 OPT DEBUG
 OPT HCLN

 INCLUDE D_A_L.INC
 INCLUDE D_M_Z.INC
 INCLUDE BSS.INC

 SECTION draweg,code

 XDEF drawege
 XDEF drawegw

 XREF message
 XREF initws
 XREF scrindx
 XREF catall
 XREF usebank
 XREF quick
 XREF sendtone
 XREF paramed
 XREF _para2w
 XREF drawsce
 XREF viewall
 XREF hardcopy
 XREF parsnam
 XREF cannot
 XREF pack
 XREF initdsc

 XREF dotline
 XREF line
 XREF drawaxes
 XREF outchar
 XREF encode

drawege movem.l d0-a6,-(a7) ; save registers
   move.l  x1,-(a7)  ; save x1-x5
   move.l  x2,-(a7)
   move.l  x3,-(a7)
   move.l  x4,-(a7)
   move.l  x5,-(a7)
   movea.l #0,a3   ; curves will be solid
   lea edspace,a2  ; a2 --> edited version
   bra _draweg

drawegw movem.l d0-a6,-(a7) ; save registers
   move.l  x1,-(a7)  ; save x1-x5
   move.l  x2,-(a7)
   move.l  x3,-(a7)
   move.l  x4,-(a7)
   move.l  x5,-(a7)
   movea.l #1,a3   ; curves will be dotted
   lea wkspace,a2  ; a2 --> original version

_draweg mulu  #21,d6
   move.l  #105,d0
   sub.l   d6,d0
   add.l   d0,a2   ; a2 --> R1,R2,R3,R4,L1,L2,L3,L4
   lea levels,a4
   lea times,a5
          ; build L array
   clr.w   0(a4)    ; L(0) = 0
   clr.w   d0
   move.b  4(a2),d0
   move.w  d0,2(a4)  ; L(1) = L1
   move.b  5(a2),d0
   move.w  d0,4(a4)  ; L(2) = L2
   move.b  6(a2),d0
   move.w  d0,6(a4)  ; L(3) = L3
   move.b  7(a2),d0
   move.w  d0,8(a4)  ; L(4) = L4

   clr.l   d7   ; for d7.w = 0 to 6 by 2
   clr.l   d6   ; for d6.w = 0 to 3 by 1
.loop   move.w  2(a4,d7.w),d0   ; for i = 1 to 4
   sub.w   0(a4,d7.w),d0   ; d0.w = L(i)-L(i-1)
   blt .fall
   clr.w   d1
   move.b  0(a2,d6.w),d1   ; d1.w = R(i)
   bsr t_rise
   bra .next
.fall   neg.w   d0  ; d0.w = L(i-1)-L(i)
   clr.w   d1
   move.b  0(a2,d6.w),d1   ; d1.w = R(i)
   bsr t_fall
.next   move.l  d0,(a5)+  ; build T array
   addq.w  #2,d7
   addq.w  #1,d6
   cmpi.w  #3,d6
   ble .loop

   lea times,a5
   move.l  12(a5),16(a5)   ; T(5) = T(4)
   move.l  (a5),d0
   add.l   4(a5),d0
   add.l   8(a5),d0
   add.l   16(a5),d0
   lsr.l   #2,d0
   addq.l  #1,d0
   move.l  d0,12(a5)   ; sustain segment= average T

   move.l  (a5),d0
   add.l   4(a5),d0
   add.l   8(a5),d0
   add.l   12(a5),d0
   add.l   16(a5),d0   ; d0.l = x-scaling factor=
          ;      = sum of all T's
   cmpi.l  #583,d0
   bge .ge583
   move.l  #583,d1
   sub.l   d0,d1   ; d1.l = 583 - xscaling factor
   add.l   d1,12(a5)   ; increase sustain segment so that
          ; x-scaling factor is 583
   move.l  #583,d0

; print out d0.l on screen: x-scaling factor
.ge583  move.b  #16,x3
   move.b  cmessge,x4
   cmpa.l  #1,a3
   bne .skip1
   move.b  #1,x2
   move.l  #xscmess,x1
   move.b  #31,x5  ; hard-code message length
   jsr message ; inform x-scaling factor
.skip1  move.l  d0,d1
   divu  #1000,d1  ; d1.l = milliseconds, seconds
   move.w  d1,x1
   jsr encode  ; encode seconds
   move.l  y1,a0
   cmpi.w  #99,d1
   bgt .gt99
   move.b  1(a0),2(a0)
   move.b  (a0),1(a0)
   move.b  ascisp,(a0)
   cmpi.w  #9,d1
   bgt .gt99
   move.b  1(a0),2(a0)
   move.b  (a0),1(a0)
   move.b  ascisp,(a0)
.gt99   cmpa.l  #1,a3
   bne .ed
   move.b  #33,x2
   bra .edor
.ed move.b  #52,x2
.edor   move.b  #3,x5
   move.l  a0,x1
   jsr message
   addq.b  #3,x2
   move.b  asciper,x1
   jsr outchar
   lsr.l   #8,d1
   lsr.l   #8,d1
   move.w  d1,x1
   jsr encode  ; encode milliseconds
   move.l  y1,a0
   cmpi.w  #99,d1
   bgt .gt99x
   move.b  1(a0),2(a0)
   move.b  (a0),1(a0)
   move.b  asci0,(a0)
   cmpi.w  #9,d1
   bgt .gt99x
   move.b  1(a0),2(a0)
   move.b  (a0),1(a0)
   move.b  asci0,(a0)
.gt99x  addq.b  #1,x2
   move.l  a0,x1
   jsr message
   addq.b  #4,x2
   cmpa.l  #1,a3
   bne .edx
   move.l  #ormess,x1
   move.b  #10,x5  ; hard-code "original /" length
   bra .edorx
.edx  move.l  #edmess,x1
   move.b  #6,x5   ; hard-code "edited" length
.edorx  jsr message

   divu  #583,d0
   addq.w  #1,d0   ; d0.w = t-scale

   move.w  8(a4),10(a4)
   move.w  6(a4),8(a4)

   move.w  #28,x1  ; starting (x,y) for envelope
   move.w  #116,x2

   move.b  cmessge,x5  ; color for all envelopes
   clr.l   d7   ; d7.w = 0 to 16 by 4
   move.w  #2,d6   ; d6.w = 2 to 10 by 2
.envloop move.l  0(a5,d7.w),d1
   divu  d0,d1   ; scale the x-length
   add.w   x1,d1
   move.w  d1,x3
   move.w  #116,d1
   sub.w   0(a4,d6.w),d1
   move.w  d1,x4
   bsr loc_line
   move.w  x3,x1
   move.w  x4,x2

   addq.w  #4,d7
   addq.w  #2,d6
   cmpi.w  #10,d6
   ble .envloop
   cmpi.w  #611,x3 ; room for tail?
   bge .repair
   cmpi.w  #116,x4
   bge .repair
   move.w  #611,x3
   bsr loc_line

; repair axes system:
.repair jsr drawaxes
   move.l  (a7)+,x5 ; restore x5-x1
   move.l  (a7)+,x4
   move.l  (a7)+,x3
   move.l  (a7)+,x2
   move.l  (a7)+,x1
   movem.l (a7)+,d0-a6 ; restore registers
   rts

loc_line cmpa.l  #1,a3   ; dotted or solid?
   beq .dot
   jsr line
   rts
.dot  jsr dotline
   rts

 XDEF t_rise
t_rise  lsl.w   #1,d0   ; d0.w = 2 * delta-L
   lea f1table,a0
   move.w  0(a0,d0.w),d0   ; d0.w = F1(delta-L)
   andi.l  #$FFFF,d0   ; d0.w = F1(delta-L)
   lsl.w   #1,d1   ; d1.w = 2R
   lea f2table,a0
   divu  0(a0,d1.w),d0   ; d0.w = F1(delta-L)/F2(R)
   andi.l  #$FFFF,d0
   rts

 XDEF t_fall
t_fall  mulu  #650,d0 ; d0.l = 650 * delta-L
   lsl.w   #1,d1   ; d1.w = 2R
   lea f3table,a0
   divu  0(a0,d1.w),d0   ; d0.w = 650*delta-L / F3(R)
   mulu  #4,d0   ; d0.l = 4 * d0.w
   rts

;******************************************************************************
;   mazetabl:  total nonsense used by copy protection
;******************************************************************************

 XDEF mazetabl
mazetabl:
   jsr initws
   jsr scrindx
   jsr catall
   jsr usebank
   jsr quick
   jsr sendtone
   jsr paramed
   jsr _para2w
   jsr drawege
   jsr drawsce
   jsr viewall
   jsr hardcopy
   jsr parsnam
   jsr cannot
   jsr pack
   jsr initdsc

;*****************************************************************************;
;   data:  tabular functions F1, F2, and F3
;*****************************************************************************;

 SECTION jones,data

f1table:
 dc.w    0,44,90,138,188,239,293,348,405,465
 dc.w      526,590,656,725,796,869,946,1025,1107,1192
 dc.w     1280,1371,1466,1564,1666,1771,1880,1994,2111,2233
 dc.w     2359,2489,2625,2765,2911,3062,3218,3380,3548,3722
 dc.w     3902,4089,4283,4484,4692,4908,5132,5364,5604,5853
 dc.w     6111,6379,6656,6944,7242,7551,7871,8203,8546,8903
 dc.w     9272,9655,10052,10464,10890,11332,11790,12265,12757,13267
 dc.w    13796,14344,14912,15501,16111,16744,17399,18079,18783,19513
 dc.w    20270,21054,21867,22709,23583,24488,25426,26398,27406,28451
 dc.w    29534,30656,31819,33025,34275,35570,36912,38304,39746,41241

f2table:

 dc.w    1,1,1,1,1,1,1,2,2,2
 dc.w    2,3,3,4,4,5,5,6,6,7
 dc.w    8,9,10,11,13,14,16,18,20,22
 dc.w   25,28,31,35,39,43,48,53,60,66
 dc.w   74,82,92,102,114,127,142,158,176,196
 dc.w      218,243,271,302,336,375,418,465,518,577
 dc.w      643,716,798,888,989,1102,1228,1367,1523,1696
 dc.w     1890,2105,2344,2611,2908,3239,3608,4019,4476,4985
 dc.w     5553,6185,6888,7672,8546,9518,10601,11808,13152,14648
 dc.w    16315,18172,20240,22543,25109,27966,31149,34694,38642,43039

f3table:
 dc.w    1,1,1,1,1,1,1,2,2,2
 dc.w    2,3,3,4,4,5,5,6,6,7
 dc.w    8,9,10,11,13,14,16,18,20,22
 dc.w   25,28,31,34,38,43,48,53,59,66
 dc.w   74,82,91,102,113,126,141,157,175,194
 dc.w      217,241,269,299,333,371,414,461,513,571
 dc.w      636,709,789,879,979,1090,1214,1352,1506,1677
 dc.w     1868,2080,2316,2580,2873,3199,3563,3968,4418,4921
 dc.w     5480,6102,6796,7568,8428,9385,10452,11639,12962,14434
 dc.w    16074,17900,19934,22199,24721,27530,30658,34141,38020,42340

xscmess dc.b  "Full envelope time (seconds) = "
ormess  dc.b  "original /"
edmess  dc.b  "edited"

 SECTION _MERGED,bss

levels  ds.b  12  ; storage for L array
times   ds.b  20  ; storage for T array
