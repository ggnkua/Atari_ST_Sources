
generate_circle:>PART

                movea.l screen1(PC),A6

                move.w  radius(PC),D5
                mulu    D5,D5

                move.w  #16-1,D7        ;y
gc_yl0:
                move.w  #16/2,D0
                sub.w   D7,D0
                muls    D0,D0

                lea     x_plot_tab(PC),A5
                move.w  #16-1,D6
gc_xl0:
                move.w  #16/2,D1
                sub.w   D6,D1
                muls    D1,D1
                add.l   D0,D1
                sub.l   #4,D1
                cmp.l   D5,D1
                bgt.s   d1_gt_d5

                movem.l D0-D1,-(SP)
                movem.w (A5),D0-D1
                or.w    D0,0(A6,D1.w)
                movem.l (SP)+,D0-D1
d1_gt_d5:                               ;ausserhalb
                addq.l  #4,A5
                dbra    D6,gc_xl0
                lea     160(A6),A6
                dbra    D7,gc_yl0
                rts
                ENDPART


