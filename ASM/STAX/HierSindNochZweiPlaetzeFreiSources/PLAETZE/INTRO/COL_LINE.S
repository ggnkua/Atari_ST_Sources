*****************************************
*********** colored triangle ************
*****************************************

                pea     0
                move.w  #$20,-(SP)
                trap    #1
                addq.l  #6,SP

                move.l  D0,save_stack

                bsr     install_system

                movem.l line_pal(PC),D0-D7
                movem.l D0-D7,$FFFF8240.w


space:          bsr     vsync

                bsr.s   colored_line

                cmpi.b  #$39,key
                bne.s   space

leave:          bsr     restore_system

                move.l  save_stack(PC),-(SP)
                move.w  #$20,-(SP)
                trap    #1
                addq.l  #6,SP

                clr.w   -(SP)
                trap    #1

********* colored lines **********

colored_line:

                lea     color_tab_0(PC),A0
                adda.w  the_offset_d(PC),A0
                movea.l screen(PC),A1
                lea     160*40+64+8(A1),A1
                bsr     dia_line_2

                lea     color_tab_0(PC),A0
                adda.w  the_offset_d(PC),A0
                movea.l screen(PC),A1
                lea     160*40+72+8(A1),A1
                bsr.s   dia_line_1

                lea     color_tab_1(PC),A0
                adda.w  the_offset_h(PC),A0

                cmpa.l  #ende,A0
                blt.s   okk
                addq.l  #4,SP
                bra.s   leave

okk:            movea.l screen(PC),A1

                lea     160*136+24+8(A1),A1
                bsr.s   hori_line

                addq.w  #3,the_offset_d
                addq.w  #5,the_offset_h

                rts

hori_line:      >PART
                lea     point_tab(PC),A2

                moveq   #11,D0

do_it_0:        moveq   #15,D1
                moveq   #0,D2

                moveq   #0,D4
                moveq   #0,D5
                moveq   #0,D6
                moveq   #0,D7

do_it_1:
                movea.l A2,A3

                move.b  (A0)+,D3
                ext.w   D3
                asl.w   #3,D3
                adda.w  D3,A3

                move.w  (A3)+,D3
                ror.w   D2,D3
                or.w    D3,D4

                move.w  (A3)+,D3
                ror.w   D2,D3
                or.w    D3,D5

                move.w  (A3)+,D3
                ror.w   D2,D3
                or.w    D3,D6

                move.w  (A3)+,D3
                ror.w   D2,D3
                or.w    D3,D7

                addq.w  #1,D2

                dbra    D1,do_it_1

                movem.w D4-D7,(A1)

                addq.l  #8,A1

                dbra    D0,do_it_0

                rts
                ENDPART
dia_line_1:     >PART
                lea     point_tab(PC),A2

                moveq   #5,D0

do_it_0a:       moveq   #15,D1
                moveq   #0,D2

do_it_1a:       move.b  (A0)+,D3
                ext.w   D3
                asl.w   #3,D3

                movem.w 0(A2,D3.w),D4-D7

                ror.w   D2,D4
                ror.w   D2,D5
                ror.w   D2,D6
                ror.w   D2,D7

                movem.w D4-D7,(A1)

                addq.w  #1,D2

                lea     160(A1),A1

                dbra    D1,do_it_1a

                addq.l  #8,A1

                dbra    D0,do_it_0a

                rts
                ENDPART
dia_line_2:     >PART
                lea     point_tab(PC),A2

                moveq   #5,D0

do_it_0b:       moveq   #15,D1

do_it_1b:       move.b  (A0)+,D3
                ext.w   D3
                asl.w   #3,D3

                movem.w 0(A2,D3.w),D4-D7

                ror.w   D1,D4
                ror.w   D1,D5
                ror.w   D1,D6
                ror.w   D1,D7

                movem.w D4-D7,(A1)

                lea     160(A1),A1

                dbra    D1,do_it_1b

                subq.l  #8,A1

                dbra    D0,do_it_0b

                rts
                ENDPART

********* things in general*******

                >PART

clear_bss:      lea     bss_start(PC),A0
                lea     bss_end,A1
cherry:         clr.b   (A0)+
                cmpa.l  A0,A1
                bne.s   cherry
                rts

send_ikbd:
                lea     $FFFFFC00.w,A0
waitkeyready:   btst    #1,(A0)
                beq.s   waitkeyready
                move.b  D0,2(A0)
                rts

vsync:          lea     $0466.w,A0
                move.l  (A0),D0
wait:           cmp.l   (A0),D0
                beq.s   wait
                rts

install_system:

                bsr.s   clear_bss

                lea     save_system(PC),A1

                move.b  $FFFF820A.w,(A1)
                move.b  $FFFF8260.w,1(A1)
                movem.l $FFFF8240.w,D0-D7
                movem.l D0-D7,2(A1)
                lea     $FFFF8201.w,A0
                movep.w 0(A0),D0
                move.w  D0,34(A1)

                movem.l black(PC),D0-D7
                movem.l D0-D7,$FFFF8240.w

                lea     screen_mem(PC),A0 ;init new screen memory ...
                lea     screen(PC),A1
                move.l  A0,D0
                clr.b   D0
                move.l  D0,(A1)+

                lsr.l   #8,D0
                move.b  D0,$FFFF8203.w
                lsr.w   #8,D0
                move.b  D0,$FFFF8201.w
                move.b  #0,$FFFF8260.w

                bsr.s   vsync

                moveq   #$12,D0         + Maus aus
                bsr.s   send_ikbd
                bsr.s   vsync

                move.b  #2,$FFFF820A.w  ; 50 Hz

                bsr.s   vsync

                bsr.s   init_mfp

                rts

restore_system:

                bsr     restore_mfp

                bsr.s   vsync
                move.b  #2,$FFFF820A.w  + 50Hz
                bsr     vsync
                move.b  #0,$FFFF820A.w  ; 60Hz
                bsr     vsync

                lea     save_system(PC),A1

                move.b  (A1)+,$FFFF820A.w
                move.b  (A1)+,$FFFF8260.w
                movem.l (A1)+,D0-D7
                movem.l D0-D7,$FFFF8240.w
                move.w  (A1)+,D0
                lea     $FFFF8201.w,A0
                movep.w D0,0(A0)        ;old screen

                moveq   #$08,D0
                bsr     send_ikbd

                rts

init_mfp:
                move    SR,-(SP)
                move    #$2700,SR
                lea     save_mfp(PC),A1
                move.l  $0118.w,(A1)+
                move.l  $0120.w,(A1)+
                move.l  $70.w,(A1)+
                move.l  $68.w,(A1)+
                lea     $FFFFFA00.w,A0  ; MFP
                move.b  $07(A0),(A1)+
                move.b  $09(A0),(A1)+
                move.b  $11(A0),(A1)+
                move.b  $13(A0),(A1)+
                move.b  $15(A0),(A1)+
                move.b  $17(A0),(A1)+
                move.b  $1B(A0),(A1)+
                move.b  $21(A0),(A1)+
                clr.b   $07(A0)         ; alles aus
                clr.b   $09(A0)
                clr.b   $13(A0)
                clr.b   $15(A0)
;bset    #0,$07(A0)      ; Timer B an
;bset    #0,$13(A0)
                bset    #6,$09(A0)      ; keys an
                bset    #6,$15(A0)
                bclr    #3,$17(A0)      ; automatic an

                move.l  #new_key,$0118.w
                move.l  #my_vbl,$70.w
                move.l  #timer_rte,$0120.w

                move.b  #$03,$FFFFFC00.w + ACIA-Init
                move.b  #$96,$FFFFFC00.w

                move    (SP)+,SR
                rts

restore_mfp:
                move    SR,-(SP)
                move    #$2700,SR
                lea     save_mfp(PC),A1
                move.l  (A1)+,$0118.w
                move.l  (A1)+,$0120.w
                move.l  (A1)+,$70.w
                move.l  (A1)+,$68.w
                lea     $FFFFFA00.w,A0  ; MF@
                move.b  (A1)+,$07(A0)
                move.b  (A1)+,$09(A0)
                move.b  (A1)+,$11(A0)
                move.b  (A1)+,$13(A0)
                move.b  (A1)+,$15(A0)
                move.b  (A1)+,$17(A0)
                move.b  (A1)+,$1B(A0)
                move.b  (A1)+,$21(A0)

                move.b  #$03,$FFFFFC00.w ; ACIA-Init
                move.b  #$96,$FFFFFC00.w

                move    (SP)+,SR
                rts

********* my interrupts ************

timer_rte:      rte

new_key:        move.w  D0,-(SP)
                move.b  $FFFFFC00.w,D0
                btst    #7,D0
                beq.s   outs
                btst    #0,D0
                beq.s   outs
                move.b  $FFFFFC02.w,key
outs:           move.w  (SP)+,D0
                rte

my_vbl:         addq.l  #1,$0466.w
                rte

                ENDPART

*********************************
********** data *****************
*********************************

                DATA

screen:         DC.L 0
save_stack:     DC.L 0

pal:            DS.W 15
                DC.W $0777

********** point stuff **********

the_offset_d:   DC.W 0
the_offset_h:   DC.W 0

line_pal:       DC.W 0,$0102,$0203,$0304,$0405,$0506,$0607,$0707
                DC.W $0717,$0727,$0737,$0747,$0757,$0767,$0777,0,0

color_tab_1:    DS.B 100
                DS.B 150
                DS.B 7,1
                DS.B 7,2
                DS.B 7,3
                DS.B 7,4
                DS.B 7,5
                DS.B 7,6
                DS.B 7,7
                DS.B 7,8
                DS.B 7,9
                DS.B 7,10
                DS.B 7,11
                DS.B 7,12
                DS.B 6,13
                DS.B 5,14
                DS.B 6,13
                DS.B 7,12
                DS.B 7,11
                DS.B 7,10
                DS.B 7,9
                DS.B 7,8
                DS.B 7,6
                DS.B 7,5
                DS.B 7,4
                DS.B 7,3
                DS.B 7,2
                DS.B 7,1
                DS.B 150
ende:           DS.B 200
                EVEN

color_tab_0:    DS.B 150
                DS.B 5,1
                DS.B 5,2
                DS.B 5,3
                DS.B 5,4
                DS.B 5,5
                DS.B 5,6
                DS.B 5,7
                DS.B 5,8
                DS.B 5,9
                DS.B 5,10
                DS.B 5,11
                DS.B 5,12
                DS.B 4,13
                DS.B 3,14
                DS.B 4,13
                DS.B 5,12
                DS.B 5,11
                DS.B 5,10
                DS.B 5,9
                DS.B 5,8
                DS.B 5,6
                DS.B 5,5
                DS.B 5,4
                DS.B 5,3
                DS.B 5,2
                DS.B 5,1
                DS.B 150
                DS.B 200
                EVEN

point_tab:      DS.W 4
                DC.W $8000,0,0,0
                DC.W 0,$8000,0,0
                DC.W $8000,$8000,0,0
                DC.W 0,0,$8000,0
                DC.W $8000,0,$8000,0
                DC.W 0,$8000,$8000,0
                DC.W $8000,$8000,$8000,0
                DC.W 0,0,0,$8000
                DC.W $8000,0,0,$8000
                DC.W 0,$8000,0,$8000
                DC.W $8000,$8000,0,$8000
                DC.W 0,0,$8000,$8000
                DC.W $8000,0,$8000,$8000
                DC.W 0,$8000,$8000,$8000
                DC.W $8000,$8000,$8000,$8000


                BSS

bss_start:

key:            DS.W 1
save_mfp:       DS.L 6
save_system:    DS.L 9
black:          DS.L 8

                DS.W 256
screen_mem:     DS.L 8000
                DS.W 256


bss_end:
                END
