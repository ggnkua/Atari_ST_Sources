
*********** building fantasia logo *********

copy_fantasia:

                move.w  #1,spray_mode
the_spray:      bsr     vsync
                bsr     spray_on_screen
                lea     spray_pointers,A0
                moveq   #5,D0
test_rady:      tst.l   (A0)+
                bne.s   the_spray
                dbra    D0,test_rady

* we are ready .....


                moveq   #0,D6
wait_a_bit:     bsr     vsync
                addq.w  #1,D6
                cmp.w   #50*5,D6
                beq.s   raus
                cmpi.b  #$39,key
                bne.s   wait_a_bit
raus:

                bsr.s   prepare_spray_vars
                move.w  #-1,spray_mode
the_spray2:     bsr     vsync
                bsr.s   spray_on_screen
                lea     spray_pointers,A0
                moveq   #5,D0
test_rady2:     tst.l   (A0)+
                bne.s   the_spray2
                dbra    D0,test_rady2

* we are ready .....

                moveq   #7,D0           * black pal
                lea     $FFFF8240.w,A0
ship:           clr.l   (A0)+
                dbra    D0,ship

                rts

prepare_spray_vars:
                lea     spray_offs,A0
                move.w  #16*160,(A0)+
                clr.l   (A0)+
                clr.l   (A0)+
                clr.w   (A0)+

                lea     spray_pointers,A0
                lea     spray_list+20,A3
                moveq   #5,D0
init_me:        move.l  A3,(A0)+
                subq.l  #4,A3
                dbra    D0,init_me
                rts


************ spray on screen ***********


spray_on_screen:
                lea     builder_mask,A4
                lea     spray_offs,A5
                move.l  A5,D5

                lea     spray_pointers,A6
                moveq   #5,D6
repeat_sprays:  move.l  (A6),D0
                bne.s   in_action
                addq.l  #4,A6
                addq.l  #2,D5
                lea     16*2(A4),A4
                dbra    D6,repeat_sprays
                rts

in_action:      movea.l D0,A3
                move.w  (A3)+,D0
                move.w  (A3)+,D1
                cmpi.w  #99,(A3)
                bne.s   weiter
                suba.l  A3,A3
weiter:         move.l  A3,(A6)+

                movea.l D5,A5
                move.w  (A5),D2
                add.w   D0,D1
                add.w   D1,(A5)+

                movea.l screen,A0
                lea     14*160(A0),A0
                lea     fantasia_data,A3
                adda.w  D2,A0
                adda.w  D2,A3

                tst.w   spray_mode
                bpl.s   spray_in

                moveq   #15,D0          * spray out of the screen ....
repeat_spray2:  move.w  (A4)+,D1
                not.w   D1
                movem.w (A3),D2-D5
                and.w   D1,D2
                and.w   D1,D3
                and.w   D1,D4
                and.w   D1,D5
                movem.w D2-D5,(A0)
                lea     160(A0),A0
                lea     160(A3),A3
                dbra    D0,repeat_spray2
                move.l  A5,D5
                dbra    D6,repeat_sprays
                rts

spray_in:                               * spray in the screen .........

                moveq   #15,D0
repeat_spray:
                move.w  (A4)+,D1

                movem.w (A3),D2-D5
                and.w   D1,D2
                and.w   D1,D3
                and.w   D1,D4
                and.w   D1,D5
                movem.w D2-D5,(A0)
                lea     160(A0),A0
                lea     160(A3),A3
                dbra    D0,repeat_spray

                move.l  A5,D5

                dbra    D6,repeat_sprays
                rts

************* spray stuff *************

spray_mode:     DC.W 0
spray_offs:     DC.W 16*160
                DS.W 5
spray_pointers:
                DC.L spray_list+20
                DC.L spray_list+16
                DC.L spray_list+12
                DC.L spray_list+8
                DC.L spray_list+4
                DC.L spray_list

spray_list:     DS.W 2*4
                DC.W 0,160*16

                REPT 8
                DC.W 0,160*16
                ENDR
                REPT 19
                DC.W 8,0
                ENDR
                REPT 8
                DC.W 0,-160*16
                ENDR
                REPT 18
                DC.W -8,0
                ENDR
                REPT 7
                DC.W 0,160*16
                ENDR
                REPT 17
                DC.W 8,0
                ENDR
                REPT 6
                DC.W 0,-160*16
                ENDR
                REPT 16
                DC.W -8,0
                ENDR
                REPT 5
                DC.W 0,160*16
                ENDR
                REPT 15
                DC.W 8,0
                ENDR
                REPT 4
                DC.W 0,-160*16
                ENDR
                REPT 14
                DC.W -8,0
                ENDR
                REPT 3
                DC.W 0,160*16
                ENDR
                REPT 13
                DC.W 8,0
                ENDR
                REPT 2
                DC.W 0,-160*16
                ENDR
                REPT 12
                DC.W -8,0
                ENDR
                DC.W 0,160*16
                REPT 12
                DC.W 8,0
                ENDR
                DC.W 99

builder_mask:
                DC.W $00,$10,$00,$0800,$00,$00,$4044,$00
                DC.W $0200,$80,$8000,$04,$0100,$00,$00,$00

                DC.W $0422,$10,$4100,$0804,$0120,$0200,$4844,$20
                DC.W $1200,$90,$8800,$04,$2110,$00,$0812,$0100

                DC.W $A422,$0190,$5522,$0854,$A920,$02AA,$6A56,$81A8
                DC.W $1A41,$2094,$8A51,$10A4,$A551,$1008,$4A92,$0148

                DC.W $B5AA,$6B95,$D56A,$6AD6,$AD6D,$B6AF,$6A56,$B5BA
                DC.W $5AD7,$7DBC,$AB53,$5EAE,$E555,$35AB,$DAB6,$554A

                DC.W $B7AE,$EBDF,$DF6B,$EBD6,$FFFD,$B7FF,$FEF7,$BFFB
                DC.W $FBF7,$7FFE,$BBFF,$DFBE,$FFF7,$77AB,$FAB6,$D5FA

                DC.W $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
                DC.W $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF

