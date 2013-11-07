******* Eutanasia tool
******* This program convert the "buged" version of PREVIEW1.MED to
******* a error free version with the same header but with correct fast
******* blocks.
*******           91 10 28 M†ndag 20:05
                                                                                                                                                                                                                                                                


                lea     A+4(pc),a0
                lea     B(pc),a1


.LOOP_A_LOT:    move.w  (a0),d0

                cmp.w   #$0040,d0
                bne.s   .X1
                move.w  #2,d0
.X1:            cmp.w   #$0010,d0
                bne.s   .X2
                move.w  #1,d0
.X2:            cmp.w   #$0050,d0
                bne.s   .X3
                move.w  #3,d0
.X3:
                move.w  d0,(a0)+

                cmpa.l  a0,a1
                bne.s   .LOOP_A_LOT

                lea     A(pc),a0
                rts

                path 'K:\IBYTES'
A:              ibytes 'PREVIEW1.MED'
B:
                end
