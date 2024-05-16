x:      bra     main
; A new 3d scroller

vsync:  st      ready
        rte


;d0 = x 0-80
;d1 = y
;d2 = char
;d3 = rot
spritebehind:
        lea     rotate(pc),a2
        lsl.l   #7,d3
        add.l   d3,a2
        move.l  (a2)+,d7
        sub.w   d7,d1
        lsl.l   #1,d7
        move.l  d0,d4
        and.l   #3,d0
        lsl.w   #2,d0
        lea     shiftedfont,a0
        lea     tab600(pc),a1
        add.l   (a1,d0.w),a0
        lsl.w   #2,d1
        lea     tab160(pc),a1
        move.l  (a1,d1.w),a1
        add.l   currpicadd(pc),a1
        lsr.l   #2,d4
        cmp.l   #17,d4
        bhi     forbish1
        bra     forbish2
forbish1:
        cmp.w   #18,d4
        beq     shfall18
        cmp.w   #19,d4
        beq     shfall19
        cmp.w   #-1,d4
        beq     shfallm1
        cmp.w   #-2,d4
        beq     shfallm2
        bra     forbish3

forbish2:
        lsl.l   #3,d4
        adda.l  d4,a1
        mulu    #2400,d2
        adda.l  d2,a0
omsh1:  move.l  a0,a3
        adda.l  (a2)+,a3
        movem.l (a3)+,d0-d5

        move.w  6(a1),d6
        not.l   d6
        and.w   d6,d0
        swap    d0
        and.w   d6,d0
        swap    d0
        swap    d1
        and.w   d6,d1
        or.w    d1,4(a1)
        or.l    d0,(a1)

        move.w  14(a1),d6
        not.l   d6
        and.w   d6,d2
        swap    d2
        and.w   d6,d2
        swap    d2
        swap    d3
        and.w   d6,d3
        or.w    d3,12(a1)
        or.l    d2,8(a1)

        move.w  22(a1),d6
        not.l   d6
        and.w   d6,d4
        swap    d4
        and.w   d6,d4
        swap    d4
        swap    d5
        and.w   d6,d5
        or.w    d5,20(a1)
        or.l    d4,16(a1)




        lea     160(a1),a1
        dbra    d7,omsh1       
forbish3:
        rts


shfall18:
        lsl.l   #3,d4
        adda.l  d4,a1
        mulu    #2400,d2
        adda.l  d2,a0
omsh21: move.l  a0,a3
        adda.l  (a2)+,a3
        movem.l (a3)+,d0-d3
        addq.l  #8,a3

        move.w  6(a1),d6
        not.l   d6
        and.w   d6,d0
        swap    d0
        and.w   d6,d0
        swap    d0
        swap    d1
        and.w   d6,d1
        or.w    d1,4(a1)
        or.l    d0,(a1)

        move.w  14(a1),d6
        not.l   d6
        and.w   d6,d2
        swap    d2
        and.w   d6,d2
        swap    d2
        swap    d3
        and.w   d6,d3
        or.w    d3,12(a1)
        or.l    d2,8(a1)

        lea     160(a1),a1
        dbra    d7,omsh21       
        rts


shfall19:
        lsl.l   #3,d4
        adda.l  d4,a1
        mulu    #2400,d2
        adda.l  d2,a0
omsh31: move.l  a0,a3
        adda.l  (a2)+,a3
        move.l  (a3)+,d0
        move.l  (a3)+,d1
        lea     16(a3),a3



        move.w  6(a1),d6
        not.l   d6
        and.w   d6,d0
        swap    d0
        and.w   d6,d0
        swap    d0
        swap    d1
        and.w   d6,d1
        or.w    d1,4(a1)
        or.l    d0,(a1)

        lea     160(a1),a1
        dbra    d7,omsh31       
        rts

shfallm1:
        mulu    #2400,d2
        adda.l  d2,a0
        addq.l  #8,a0
omsh41: move.l  a0,a3
        adda.l  (a2)+,a3
        movem.l (a3)+,d0-d3
        addq.l  #8,a3




        move.w  6(a1),d6
        not.l   d6
        and.w   d6,d0
        swap    d0
        and.w   d6,d0
        swap    d0
        swap    d1
        and.w   d6,d1
        or.w    d1,4(a1)
        or.l    d0,(a1)

        move.w  14(a1),d6
        not.l   d6
        and.w   d6,d2
        swap    d2
        and.w   d6,d2
        swap    d2
        swap    d3
        and.w   d6,d3
        or.w    d3,12(a1)
        or.l    d2,8(a1)

        lea     160(a1),a1
        dbra    d7,omsh41       
        rts

shfallm2:
        mulu    #2400,d2
        adda.l  d2,a0
        lea     16(a0),a0
omsh51: move.l  a0,a3
        adda.l  (a2)+,a3
        move.l  (a3)+,d0
        move.l  (a3)+,d1
        lea     16(a3),a3



        move.w  6(a1),d6
        not.l   d6
        and.w   d6,d0
        swap    d0
        and.w   d6,d0
        swap    d0
        swap    d1
        and.w   d6,d1
        or.w    d1,4(a1)
        or.l    d0,(a1)

        lea     160(a1),a1
        dbra    d7,omsh51       
        rts










;d0 = x 0-80
;d1 = y
;d2 = char
;d3 = rot
spritebefore:
        lea     rotate(pc),a2
        lsl.l   #7,d3
        add.l   d3,a2
        move.l  (a2)+,d7
        sub.w   d7,d1
        lsl.l   #1,d7
        move.l  d0,d4
        and.l   #3,d0
        lsl.w   #2,d0
        lea     shiftedfont,a0
        lea     tab600(pc),a1
        add.l   (a1,d0.w),a0
        lsl.w   #2,d1
        lea     tab160(pc),a1
        move.l  (a1,d1.w),a1
        add.l   currpicadd(pc),a1
        lsr.l   #2,d4
        cmp.l   #17,d4
        bhi     forbisb1
        bra     forbisb2
forbisb1:
        cmp.w   #18,d4
        beq     sbfall18
        cmp.w   #19,d4
        beq     sbfall19
        cmp.w   #-1,d4
        beq     sbfallm1
        cmp.w   #-2,d4
        beq     sbfallm2
        bra     forbisb3

forbisb2:
        lsl.l   #3,d4
        adda.l  d4,a1
        mulu    #2400,d2
        adda.l  d2,a0
omsb1:  move.l  a0,a3
        adda.l  (a2)+,a3
        movem.l (a3)+,d0-d5
        move.w  d1,d6
        swap    d6
        move.w  d1,d6
        not.l   d6
        and.l   d6,(a1)
        and.l   d6,4(a1)
        or.l    d0,(a1)+
        or.l    d1,(a1)+

        move.w  d3,d6
        swap    d6
        move.w  d3,d6
        not.l   d6
        and.l   d6,(a1)
        and.l   d6,4(a1)
        or.l    d2,(a1)+
        or.l    d3,(a1)+


        move.w  d5,d6
        swap    d6
        move.w  d5,d6
        not.l   d6
        and.l   d6,(a1)
        and.l   d6,4(a1)
        or.l    d4,(a1)+
        or.l    d5,(a1)+


        lea     136(a1),a1
        dbra    d7,omsb1       
forbisb3:
        rts


sbfall18:
        lsl.l   #3,d4
        adda.l  d4,a1
        mulu    #2400,d2
        adda.l  d2,a0
omsb21: move.l  a0,a3
        adda.l  (a2)+,a3
        movem.l (a3)+,d0-d3
        addq.l  #8,a3
        move.w  d1,d6
        swap    d6
        move.w  d1,d6
        not.l   d6
        and.l   d6,(a1)
        and.l   d6,4(a1)
        or.l    d0,(a1)+
        or.l    d1,(a1)+

        move.w  d3,d6
        swap    d6
        move.w  d3,d6
        not.l   d6
        and.l   d6,(a1)
        and.l   d6,4(a1)
        or.l    d2,(a1)+
        or.l    d3,(a1)+



        lea     144(a1),a1
        dbra    d7,omsb21       
        rts


sbfall19:
        lsl.l   #3,d4
        adda.l  d4,a1
        mulu    #2400,d2
        adda.l  d2,a0
omsb31: move.l  a0,a3
        adda.l  (a2)+,a3
        move.l  (a3)+,d0
        move.l  (a3)+,d1
        lea     16(a3),a3
        move.w  d1,d6
        swap    d6
        move.w  d1,d6
        not.l   d6
        and.l   d6,(a1)
        and.l   d6,4(a1)
        or.l    d0,(a1)+
        or.l    d1,(a1)+


        lea     152(a1),a1
        dbra    d7,omsb31       
        rts

sbfallm1:
        mulu    #2400,d2
        adda.l  d2,a0
        addq.l  #8,a0
omsb41: move.l  a0,a3
        adda.l  (a2)+,a3
        movem.l (a3)+,d0-d3
        addq.l  #8,a3
        move.w  d1,d6
        swap    d6
        move.w  d1,d6
        not.l   d6
        and.l   d6,(a1)
        and.l   d6,4(a1)
        or.l    d0,(a1)+
        or.l    d1,(a1)+

        move.w  d3,d6
        swap    d6
        move.w  d3,d6
        not.l   d6
        and.l   d6,(a1)
        and.l   d6,4(a1)
        or.l    d2,(a1)+
        or.l    d3,(a1)+


        lea     144(a1),a1
        dbra    d7,omsb41       
        rts

sbfallm2:
        mulu    #2400,d2
        adda.l  d2,a0
        lea     16(a0),a0
omsb51: move.l  a0,a3
        adda.l  (a2)+,a3
        move.l  (a3)+,d0
        move.l  (a3)+,d1
        lea     16(a3),a3
        move.w  d1,d6
        swap    d6
        move.w  d1,d6
        not.l   d6
        and.l   d6,(a1)
        and.l   d6,4(a1)
        or.l    d0,(a1)+
        or.l    d1,(a1)+


        lea     152(a1),a1
        dbra    d7,omsb51       
        rts





rotate:
r0:     dc.l    12,00,01,02,03,04,05,06,07,08,09,10,11,12,13,14
        dc.l    15,16,17,18,19,20,21,22,23,24,00,00,00,00,00,00
r1:     dc.l    11,00,01,02,03,04,05,07,08,09,10,11,12,13,14,15
        dc.l    16,17,19,20,21,22,23,24,00,00,00,00,00,00,00,00
r2:     dc.l    10,00,01,02,04,05,06,07,08,10,11,12,13,14,16,17
        dc.l    18,19,20,22,23,24,00,00,00,00,00,00,00,00,00,00
r3:     dc.l    09,00,01,03,04,05,07,08,09,11,12,13,15,16,17,19
        dc.l    20,21,23,24,00,00,00,00,00,00,00,00,00,00,00,00
r4:     dc.l    08,00,02,03,05,06,08,09,11,12,13,15,16,18,19,21
        dc.l    22,24,00,00,00,00,00,00,00,00,00,00,00,00,00,00
r5:     dc.l    07,00,02,04,05,07,09,10,12,14,15,17,19,20,22,24
        dc.l    00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
r6:     dc.l    06,00,02,04,06,08,10,12,14,16,18,20,22,24,00,00
        dc.l    00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
r7:     dc.l    05,01,03,05,07,10,12,14,17,19,21,23,00,00,00,00
        dc.l    00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
r8:     dc.l    04,01,04,06,09,12,15,18,20,23,00,00,00,00,00,00
        dc.l    00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
r9:     dc.l    03,01,05,08,12,16,19,23,00,00,00,00,00,00,00,00
        dc.l    00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
r10:    dc.l    02,02,07,12,17,22,00,00,00,00,00,00,00,00,00,00
        dc.l    00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
r11:    dc.l    01,04,12,20,00,00,00,00,00,00,00,00,00,00,00,00
        dc.l    00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
r12:    dc.l    00,12,00,00,00,00,00,00,00,00,00,00,00,00,00,00
        dc.l    00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
r13:    dc.l    01,20,12,04,00,00,00,00,00,00,00,00,00,00,00,00
        dc.l    00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
r14:    dc.l    02,22,17,12,07,02,00,00,00,00,00,00,00,00,00,00
        dc.l    00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
r15:    dc.l    03,23,19,16,12,08,05,01,00,00,00,00,00,00,00,00
        dc.l    00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
r16:    dc.l    04,23,20,18,15,12,09,06,04,01,00,00,00,00,00,00
        dc.l    00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
r17:    dc.l    05,23,21,19,17,14,12,10,07,05,03,01,00,00,00,00
        dc.l    00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
r18:    dc.l    06,24,22,20,18,16,14,12,10,08,06,04,02,00,00,00
        dc.l    00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
r19:    dc.l    07,24,22,20,19,17,15,14,12,10,09,07,05,04,02,00
        dc.l    00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
r20:    dc.l    08,24,22,21,19,18,16,15,13,12,11,09,08,06,05,03
        dc.l    02,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
r21:    dc.l    09,24,23,21,20,19,17,16,15,13,12,11,09,08,07,05
        dc.l    04,03,01,00,00,00,00,00,00,00,00,00,00,00,00,00
r22:    dc.l    10,24,23,22,20,19,18,17,16,14,13,12,11,10,08,07
        dc.l    06,05,04,02,01,00,00,00,00,00,00,00,00,00,00,00
r23:    dc.l    11,24,23,22,21,20,19,17,16,15,14,13,12,11,10,09
        dc.l    08,07,05,04,03,02,01,00,00,00,00,00,00,00,00,00
r24:    dc.l    12,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10
        dc.l    09,08,07,06,05,04,03,02,01,00,00,00,00,00,00,00




        dc.b    12,13,13,14,14,15,15,16,17,17,18,18,19,19,20,20
        dc.b    20,21,21,22,22,22,23,23,23,23,23,23,24,24,24,24
        dc.b    24,24,24,24,24,24,23,23,23,23,23,22,22,22,21,21
        dc.b    20,20,20,19,19,18,18,17,17,16,15,15,14,14,13,13
        dc.b    12,11,11,10,10,09,09,08,07,07,06,06,05,05,04,04
        dc.b    04,03,03,02,02,02,01,01,01,01,01,00,00,00,00,00
        dc.b    00,00,00,00,00,00,01,01,01,01,01,02,02,02,03,03
        dc.b    04,04,04,05,05,06,06,07,07,08,09,09,10,10,11,11
RotData:
        dc.b    12,13,13,14,14,15,15,16,17,17,18,18,19,19,20,20
        dc.b    20,21,21,22,22,22,23,23,23,23,23,23,24,24,24,24
        dc.b    24,24,24,24,24,24,23,23,23,23,23,22,22,22,21,21
        dc.b    20,20,20,19,19,18,18,17,17,16,15,15,14,14,13,13
        dc.b    12,11,11,10,10,09,09,08,07,07,06,06,05,05,04,04
        dc.b    04,03,03,02,02,02,01,01,01,01,01,00,00,00,00,00
        dc.b    00,00,00,00,00,00,01,01,01,01,01,02,02,02,03,03
        dc.b    04,04,04,05,05,06,06,07,07,08,09,09,10,10,11,11
        dc.b    12,13,13,14,14,15,15,16,17,17,18,18,19,19,20,20
        dc.b    20,21,21,22,22,22,23,23,23,23,23,23,24,24,24,24
        dc.b    24,24,24,24,24,24,23,23,23,23,23,22,22,22,21,21
        dc.b    20,20,20,19,19,18,18,17,17,16,15,15,14,14,13,13
        dc.b    12,11,11,10,10,09,09,08,07,07,06,06,05,05,04,04
        dc.b    04,03,03,02,02,02,01,01,01,01,01,00,00,00,00,00
        dc.b    00,00,00,00,00,00,01,01,01,01,01,02,02,02,03,03
        dc.b    04,04,04,05,05,06,06,07,07,08,09,09,10,10,11,11
        dc.b    12,13,13,14,14,15,15,16,17,17,18,18,19,19,20,20
        dc.b    20,21,21,22,22,22,23,23,23,23,23,23,24,24,24,24
        dc.b    24,24,24,24,24,24,23,23,23,23,23,22,22,22,21,21
        dc.b    20,20,20,19,19,18,18,17,17,16,15,15,14,14,13,13
        dc.b    12,11,11,10,10,09,09,08,07,07,06,06,05,05,04,04
        dc.b    04,03,03,02,02,02,01,01,01,01,01,00,00,00,00,00
        dc.b    00,00,00,00,00,00,01,01,01,01,01,02,02,02,03,03
        dc.b    04,04,04,05,05,06,06,07,07,08,09,09,10,10,11,11


yposs:
        dc.b    25,26,27,29,30,31,32,33,35,36,37,38,39,40,41,42
        dc.b    43,44,44,45,46,46,47,48,48,49,49,49,50,50,50,50
        dc.b    50,50,50,50,50,49,49,49,48,48,47,46,46,45,44,44
        dc.b    43,42,41,40,39,38,37,36,35,33,32,31,30,29,27,26
        dc.b    25,24,23,21,20,19,18,17,15,14,13,12,11,10,09,08
        dc.b    07,06,06,05,04,04,03,02,02,01,01,01,00,00,00,00
        dc.b    00,00,00,00,00,01,01,01,02,02,03,04,04,05,06,06
        dc.b    07,08,09,10,11,12,13,14,15,17,18,19,20,21,23,24
        dc.b    25,26,27,29,30,31,32,33,35,36,37,38,39,40,41,42
        dc.b    43,44,44,45,46,46,47,48,48,49,49,49,50,50,50,50
        dc.b    50,50,50,50,50,49,49,49,48,48,47,46,46,45,44,44
        dc.b    43,42,41,40,39,38,37,36,35,33,32,31,30,29,27,26
        dc.b    25,24,23,21,20,19,18,17,15,14,13,12,11,10,09,08
        dc.b    07,06,06,05,04,04,03,02,02,01,01,01,00,00,00,00
        dc.b    00,00,00,00,00,01,01,01,02,02,03,04,04,05,06,06
        dc.b    07,08,09,10,11,12,13,14,15,17,18,19,20,21,23,24
        dc.b    25,26,27,29,30,31,32,33,35,36,37,38,39,40,41,42
        dc.b    43,44,44,45,46,46,47,48,48,49,49,49,50,50,50,50
        dc.b    50,50,50,50,50,49,49,49,48,48,47,46,46,45,44,44
        dc.b    43,42,41,40,39,38,37,36,35,33,32,31,30,29,27,26
        dc.b    25,24,23,21,20,19,18,17,15,14,13,12,11,10,09,08
        dc.b    07,06,06,05,04,04,03,02,02,01,01,01,00,00,00,00
        dc.b    00,00,00,00,00,01,01,01,02,02,03,04,04,05,06,06
        dc.b    07,08,09,10,11,12,13,14,15,17,18,19,20,21,23,24
        dc.b    25,24,23,21,20,19,18,17,15,14,13,12,11,10,09,08
        dc.b    07,06,06,05,04,04,03,02,02,01,01,01,00,00,00,00
        dc.b    00,00,00,00,00,01,01,01,02,02,03,04,04,05,06,06
        dc.b    07,08,09,10,11,12,13,14,15,17,18,19,20,21,23,24





scroller:
        addq.l  #4,rotpos
        and.l   #127,rotpos
        move.l  rotpos(pc),d2
        add.l   #12,d2
        lea     rotdata(pc),a2
        add.l   d2,a2
        lea     yposs(pc),a3
        add.l   d2,a3
        move.l  scrollpos(pc),d0
        move.l  miniscrollpos(pc),d1
        addq.l  #1,d1
        cmp.l   #9,d1
        blt     forbis1
        moveq   #0,d1
        addq.l  #1,d0
        cmp.l   #textlen,d0
        blt     forbis2
        moveq   #0,d0
forbis2:
forbis1:
        move.l  d0,scrollpos
        move.l  d1,miniscrollpos
        neg.l   d1
        add.l   d1,a2
        add.l   d1,a2
        add.l   d1,a3
        add.l   d1,a3
        lea     text(pc),a0
        add.l   d0,a0
        lea     stasc(pc),a1
        move.l  d1,d0
        moveq   #9,d7
oms1:   moveq   #0,d2
        move.b  (a0)+,d2
        move.b  (a1,d2.w),d2
        moveq   #100,d1
        add.b   32(a3),d1
        moveq   #0,d3
        move.b  (a2),d3
        movem.l d0-d7/a0-a3,-(sp)

        cmp.w   #12,d3
        bhi     forbis3
        bsr     spritebefore
        bra     forbis4        
forbis3:
        bsr     spritebehind
forbis4:
        movem.l (sp)+,d0-d7/a0-a3
        add.l   #9,d0
        lea     18(a2),a2
        lea     18(a3),a3
        dbra    d7,oms1
        rts



scrollpos:      dc.l    0
miniscrollpos:  dc.l    0
rotpos:         dc.l    0




tab600: dc.l    0,600,1200,1800
        


slack:
        move.l  currpicadd(pc),a1
        lea     24640(a1),a1
        moveq   #0,d1
        move.l  d1,d2
        move.l  d1,d3
        move.l  d1,d4
        move.l  d1,d5
        move.l  d1,d6
        move.l  d1,d7
        move.l  d1,a2
        moveq   #15,d0
omsl1:  movem.l d1-d7/a2,-(a1)
        movem.l d1-d7/a2,-(a1)
        movem.l d1-d7/a2,-(a1)
        movem.l d1-d7/a2,-(a1)
        movem.l d1-d7/a2,-(a1)
        dbra    d0,omsl1
        lea     block,a0
        lea     3840(a0),a0
        moveq   #24,d0
omsl2:  
        movem.l 128(a0),d1-d7/a2
        movem.l d1-d7/a2,-(a1)
        movem.l 96(a0),d1-d7/a2
        movem.l d1-d7/a2,-(a1)
        movem.l 64(a0),d1-d7/a2
        movem.l d1-d7/a2,-(a1)
        movem.l 32(a0),d1-d7/a2
        movem.l d1-d7/a2,-(a1)
        movem.l (a0),d1-d7/a2
        movem.l d1-d7/a2,-(a1)
        lea     -160(a0),a0
        dbra    d0,omsl2
        moveq   #0,d1
        move.l  d1,d2
        move.l  d1,d3
        move.l  d1,d4
        move.l  d1,d5
        move.l  d1,d6
        move.l  d1,d7
        move.l  d1,a2
        moveq   #15,d0
omsl3:  movem.l d1-d7/a2,-(a1)
        movem.l d1-d7/a2,-(a1)
        movem.l d1-d7/a2,-(a1)
        movem.l d1-d7/a2,-(a1)
        movem.l d1-d7/a2,-(a1)
        dbra    d0,omsl3


        rts



getblock:
        lea     block,a1
        move.l  currpicadd(pc),a0
        lea     18080(a0),a0
        move.l  #24,d0
omgb1:  movem.l (a0)+,d1-d7/a2
        movem.l d1-d7/a2,(a1)
        movem.l (a0)+,d1-d7/a2
        movem.l d1-d7/a2,32(a1)
        movem.l (a0)+,d1-d7/a2
        movem.l d1-d7/a2,64(a1)
        movem.l (a0)+,d1-d7/a2
        movem.l d1-d7/a2,96(a1)
        movem.l (a0)+,d1-d7/a2
        movem.l d1-d7/a2,128(a1)
        lea     160(a1),a1
        dbra    d0,omgb1
        rts


updatevars:
        not.l   oddvsync
        tst.l   oddvsync
        bne     forbiudv1
        move.l  #picadd1,currpicadd
        bra     forbiudv2
forbiudv1:
        move.l  #picadd2,currpicadd
forbiudv2:
        move.l  currpicadd,d0
        lsr.l   #8,d0
        move.b  d0,$ff8203
        lsr.l   #8,d0
        move.b  d0,$ff8201
        rts

oddvsync:
        dc.l    0       

shiftfont:
        lea     font(pc),a0
        lea     shiftedfont,a1
        moveq   #47,d0
omssp1: moveq   #12,d1
omssp2: move.l  a0,a2
        moveq   #16,d4
        sub.l   d1,d4
        move.w  #-1,d2
        lsr.w   d4,d2
        move.w  d2,d5
        swap    d5
        move.w  d2,d5
        move.l  d1,d6
        movem.l d0-d1/a0,-(sp)
        moveq   #24,d2
omssp3: movem.l (a2),d0-d1

        move.l  d0,d7
        lsr.l   d4,d7
        and.l   d5,d7
        lsl.l   d6,d0
        not.l   d5
        and.l   d5,d0
        not.l   d5
        move.l  d7,(a1)
        move.l  d0,8(a1)
        


        move.l  d1,d7
        lsr.l   d4,d7
        and.l   d5,d7
        lsl.l   d6,d1
        eor.l   #-1,d5
        and.l   d5,d1
        eor.l   #-1,d5
        move.l  d7,4(a1)
        move.l  d1,12(a1)


        movem.l 8(a2),d0-d1

        move.l  d0,d7
        lsr.l   d4,d7
        and.l   d5,d7
        lsl.l   d6,d0
        not.l   d5
        and.l   d5,d0
        not.l   d5
        or.l    d7,8(a1)
        move.l  d0,16(a1)

        move.l  d1,d7
        lsr.l   d4,d7
        and.l   d5,d7
        lsl.l   d6,d1
        eor.l   #-1,d5
        and.l   d5,d1
        eor.l   #-1,d5
        or.l    d7,12(a1)
        move.l  d1,20(a1)


        adda.l  #16,a2
        adda.l  #24,a1

        dbra    d2,omssp3
        movem.l (sp)+,d0-d1/a0
        subq.l  #4,d1
        tst.l   d1
        bge     omssp2
        adda.l  #400,a0
        dbra    d0,omssp1
        rts




setints:
        move.w  #37,-(sp)
        trap    #14
        addq.l  #2,sp
        move.w  #$2700,sr
        move.l  #vsync,$70
        move.b  #0,$fffa07
        move.b  #0,$fffa09
;        move.l  #hs1,-(sp)
;        move.w  #150,-(sp)
;        move.w  #8,-(sp)
;        move.w  #1,-(sp)
;        move.w  #31,-(sp)
;        trap    #14
;        add.l   #12,sp

        move.w  #$2300,sr

        rts


saveints:
        move.w  #$2700,sr
        move.b  $fffa07,mfpiea
        move.b  $fffa09,mfpieb
        move.b  $fffa13,mfpima
        move.b  $fffa15,mfpimb
        move.b  $fffa19,mfptac
        move.b  $fffa1b,mfptbc
        move.b  $fffa1f,mfptad
        move.b  $fffa21,mfptbd

        move.l  $120,timbvec
        move.l  $68,hsynvec
        move.l  $70,oldvsync
        rts

retints:
        move.w  #$2700,sr
        move.b  mfpiea,$fffa07
        move.b  mfpieb,$fffa09
        move.b  mfpima,$fffa13
        move.b  mfpimb,$fffa15
        move.b  mfptac,$fffa19
        move.b  mfptbc,$fffa1b
        move.b  mfptad,$fffa1f
        move.b  mfptbd,$fffa21


        move.l  timbvec,$120
        move.l  hsynvec,$68
        move.l  oldvsync,$70
        move.w  #$2300,sr
        rts


clearscreen:
        move.l  oldphys(pc),a0
        add.l   #32000,a0
        move.l  #1999,d0
        movem.l tom,d1-d7/a1
omcs1:  movem.l d1-d7/a1,-(a0)
        dbra    d0,omcs1
        rts

tom:    blk.l   10,0


initvars:

        move.w  #2,-(sp)
        trap    #14
        addq.l  #2,sp
        move.l  d0,oldphys

        move.w  #4,-(sp)
        trap    #14
        addq.l  #2,sp
        move.w  d0,oldres


        move.w  #0,-(sp)
        move.l  #-1,-(sp)
        move.l  #-1,-(sp)
        move.w  #5,-(sp)
        trap    #14
        add.l   #12,sp

        lea     oldpal(pc),a0
        movem.l $ff8240,d0-d7
        movem.l d0-d7,(a0)
        lea     palette(pc),a0
        movem.l (a0),d0-d7
        movem.l d0-d7,$ff8240
        bsr     shiftfont

;       move.w  #3,-(sp)
;       trap    #14
;       addq.l  #2,sp
;       move.l  d0,iglogscr


        moveq   #0,d1
        move.w  #199,d0
        lea     tab160,a0
omiv1:  move.l  d1,(a0)+
        add.l   #160,d1
        dbra    d0,omiv1

        lea     rotate(pc),a0
        moveq   #24,d0
omiv2:  addq.l  #4,a0
        moveq   #30,d1
omiv3:  move.l  (a0),d2
        mulu    #24,d2
        move.l  d2,(a0)+
        dbra    d1,omiv3
        dbra    d0,omiv2

        bsr     saveints
        bsr     setints

        rts
        
        
endp:   tst.b   ready
        beq     endp
        bsr     retints

        lea     oldpal(pc),a0
        movem.l (a0),d0-d7
        movem.l d0-d7,$ff8240

        move.w  oldres,-(sp)
        move.l  oldphys,-(sp)
        move.l  oldphys,-(sp)
        move.w  #5,-(sp)
        trap    #14
        adda.l  #12,sp

        rts



main:
        move.l  sp,oldstck
        move.l  #stck,sp
        clr.l   -(sp)
        move.w  #32,-(sp)
        trap    #1
        addq.l  #6,sp
        move.l  d0,savstk

        bsr     initvars
        bsr     clearscreen

        move.l  oldphys,currpicadd

        moveq   #4,d0
        move.l  #125,d1
        moveq   #0,d3
        lea     theunion(pc),a0
        lea     stasc(pc),a1
        moveq   #8,d4
omm7:   move.b  (a0)+,d2
        move.b  (a1,d2.b),d2
        movem.l d0-d4/a0-a1,-(sp)
        bsr     spritebefore
        movem.l (sp)+,d0-d4/a0-a1
        add.l   #8,d0
        dbra    d4,omm7
        bsr     getblock

omm1:   
;       move.w  #$100,$ff8240
        bsr     updatevars
        bsr     slack



        bsr     scroller
;       move.w  #$000,$ff8240
        cmp.b   #185,$fffc02
        beq     utm1
omm2:   tst.b   ready
        beq     omm2
        clr.b   ready
        bra     omm1
utm1:
        bsr     endp
        move.l  savstk,-(sp)
        move.w  #32,-(sp)
        trap    #1
        addq.l  #6,sp
        move.l  oldstck,sp      
        illegal

        
savstk:         dc.l    0
oldstck:        dc.l    0
ustck:          blk.l   100
stck:           dc.l    0
ready:          dc.b    0,0
oldstack:       dc.l    0
mfpiea:         dc.b    0
mfpieb:         dc.b    0
mfpima:         dc.b    0
mfpimb:         dc.b    0
mfptac:         dc.b    0
mfptbc:         dc.b    0
mfptad:         dc.b    0
mfptbd:         dc.b    0
timbvec:        dc.l    0
hsynvec:        dc.l    0
oldvsync:       dc.l    0
oldphys:        dc.l    0
oldres:         dc.w    0
oldpal:         blk.w   16
tab160:         blk.l   200,0
palette:        dc.w    $000,$076,$075,$064,$053,$042,$031,$002
                dc.w    $000,$760,$750,$640,$530,$420,$310,$003
palette2:       dc.w    $000,$000,$076,$760,$075,$750,$064,$640
                dc.w    $053,$530,$042,$420,$031,$310,$002,$003
currpicadd:     dc.l    0
picadd1:        equ     1048576-32000
picadd2:        equ     1048576-64000
theunion:       dc.b    'THE UNION',0

text:           
                DC.B    '         ','          '
                DC.B    'HELLO! THIS IS A TEST. THE CAREBEARS'
                DC.B    ' ARE PROUD TO PRESENT - THE HARD TO READ'
                DC.B    ' SCROLLER. ANDREAS GOT A HEADACHE AFTER'
                DC.B    ' FIVE MINUTES AND SO DID I AFTER TEN...'
                DC.B    ' WHY DO WE WRITE ANYTHING AT ALL IN THESE'
                DC.B    ' PREVIEWS, YOU MIGHT WANT TO ASK. WELL,'
                DC.B    ' WE DONœT KNOW, BUT WE MIGHT AS WELL'
                DC.B    ' GREET SOME PEOPLE. MEGAGREETINGS GO TO:'
                DC.B    ' ALL THE OTHER MEMBERS OF THE UNION.'
                DC.B    ' A BIT SMALLER GREETING (8 OUT OF 10)'
                DC.B    ' GOES TO AN COOL (YOUR LATEST INTRO IS REALLY'
                DC.B    ' SOMETHING). A COUPLE OF ORDINARY GREETINGS'
                DC.B    ' GO TO THE BLADERUNNERS (ESPECIALLY HCC)'
                DC.B    ', PYROTECHNICS (WEœRE YOUR BIGGEST FANS)'
                DC.B    ', SYNC, ZZAP GAMES (SEE, WE DO GREET YOU)'
                DC.B    '. FINALLY, I SUPPOSE I SHOULD GREET GROWTWIG,'
                DC.B    ' MATTI AND BEAR OF BLOCKBUSTERS TOO, SO A'
                DC.B    ' COUPLE OF HELLO(E)S GO TO YOU TOO:'
                DC.B    ' - HELLO, HELLO, HELLO '
                DC.B    ' LETœS START ALL OVER AGAIN.......'
                DC.B    '         ','          '
EVEN
textlen:        equ     800



STASC:  DC.B    47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47
        DC.B    47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47
        DC.B    47,26,46,47,47,47,47,45,40,41,47,47,43,42,44,47
        DC.B    30,31,32,33,34,35,36,37,38,39,28,29,47,47,47,27
        DC.B    47,0 ,1 ,2 ,3 ,4 ,5 ,6 ,7 ,8 ,9 ,10,11,12,13,14
        DC.B    15,16,17,18,19,20,21,22,23,24,25,47,47,47,47,47
        DC.B    47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47
        DC.B    47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47
        DC.B    47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47
        DC.B    47,47,47,47,47,47,47,47,47,47,47,47,45,47,47,47
        DC.B    47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47
        DC.B    47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47
        DC.B    47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47
        DC.B    47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47
        DC.B    47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47
        DC.B    47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47





font:           blk.l   4800
shiftedfont:                                    ;blk.l  28800
block:          equ     shiftedfont+115200      ;blk.l  1000







