EXPORT sqrt_strt

if 01
; high speed sqrt
; call: DO = x, integer
; return: D0 = SQRT(x)

sqrt_strt:
     move.w  #$100,a0
     cmp.l   a0,d0        ; d0<256?
     bcs.s   .8bit        ; yep
     move.l  d0,a1        ; x
     swap    d0
     tst.w   d0
     bne.s   .32bit
     move.l  a1,d0
     moveq   #0,d1
.loop:
     addq.w  #1,d1        ;
.loop_start:              ; 16 bits left
     lsr.w   #2,d0        ;
     cmp.w   a0,d0
     bcc.s   .loop
     move.b  .sqrt_table(pc,d0.w),d0 ; table lookup
     lsl.w   d1,d0       ; order 0
     move.l  a1,d1       ; x
     divu    d0,d1       ; x/tmp
     add.w   d1,d0       ; tmp+=x/tmp
     lsr.w   #1,d0       ; tmp/=2            order 1
     move.l  a1,d1
     divu    d0,d1       ; x/tmp
     add.w   d1,d0       ; tmp+=x/tmp
     lsr.w   #1,d0       ; tmp/=2            order 2
     rts
.8bit:
     move.b  .sqrt_table(pc,d0.w),d0 ; table lookup
     rts
.32bit:
     cmp.w   a0,d0        ; 24 bit?
     bcc.s   .24bit
     move.l  a1,d0
     lsr.l   #8,d0
     moveq   #5,d1
     bra.s   .loop_start
.24bit:
     cmpi.w  #$3fc0,d0    ; bignum?
     bcc.s   .bignum      ; yep
     move.l  a1,d0
     clr.w   d0
     swap    d0
     moveq   #9,d1
     bra.s   .loop_start
.bignum:                  ; big nums cause overflows
     cmpi.w  #$fffd,d0    ; big bignum?
     bcc.s   .bigbignum   ; yep!
     move.l  a1,-(sp)     ; store x
     swap    d0
     lsr.l   #4,d0        ; x geen bignum meer
     move.l  d0,a1        ; x
     clr.w   d0
     swap    d0
     moveq   #9,d1
     bsr.s   .loop_start
     add.w   d0,d0
     add.w   d0,d0        ; d0 is our guess now
     move.l  (sp)+,d1     ; x
     divu    d0,d1        ; i/tmp
     bvc.s   .cont0
     moveq   #1,d1        ; overflow!
     bra.s   .cont1
.cont0:
     swap    d1
     clr.w   d1
.cont1:
     swap    d1
     add.l   d1,d0        ; tmp+=i/tmp
     lsr.l   #1,d0        ; tmp/=2       
     rts
.bigbignum:
     moveq   #0,d0
     subq.w  #1,d0        ; d0=$0000ffff
     rts

.sqrt_table:
dc.b 0,1,1,1,2,2,2,2,2,3,3,3,3,3,3,3
dc.b 4,4,4,4,4,4,4,4,4,5,5,5,5,5,5,5
dc.b 5,5,5,5,6,6,6,6,6,6,6,6,6,6,6,6
dc.b 6,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7
dc.b 8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8
dc.b 8,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9
dc.b 9,9,9,9,10,10,10,10,10,10,10,10,10,10,10,10
dc.b 10,10,10,10,10,10,10,10,10,11,11,11,11,11,11,11
dc.b 11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11
dc.b 12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12
dc.b 12,12,12,12,12,12,12,12,12,13,13,13,13,13,13,13
dc.b 13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13
dc.b 13,13,13,13,14,14,14,14,14,14,14,14,14,14,14,14
dc.b 14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14
dc.b 14,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15
dc.b 15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15


else

sqrt_strt:
     cmpi.w  #2,d0       ; >2? dan wat doen, anders direct klaar
     bcc.s   .cont
     rts
.cont:
     move.l  d2,-(sp)
     moveq   #32,d2      ; bitcount
     move.l  d0,d1
     bmi.s   .start_l
.loop:
     subq.w  #1,d2       ;
     add.l   d1,d1       ; find bit
     bpl.s   .loop
.start_l:     
     lsr.w   #1,d2
     move.l  d0,d1       ; i
     lsr.l   d2,d1       ; tmp = i>>(bits/2) order 0
     move.l  d0,d2       ; i
     divu    d1,d2       ; i/tmp
     swap    d2
     clr.w   d2
     swap    d2
     add.l   d2,d1       ; tmp+=i/tmp
     lsr.l   #1,d1       ; tmp/=2            order 1
     move.l  d0,d2       ; i
     divu    d1,d2       ; i/tmp
     swap    d2
     clr.w   d2
     swap    d2
     add.l   d2,d1       ; tmp+=i/tmp
     lsr.l   #1,d1       ; tmp/=2            order 2
     move.l  d0,d2       ; i
     divu    d1,d2       ; i/tmp
     swap    d2
     clr.w   d2
     swap    d2
     add.l   d2,d1       ; tmp+=i/tmp
     lsr.l   #1,d1       ; tmp/=2            order 3
     move.l  d1,d0
     move.l  (sp)+,d2
     rts

endif