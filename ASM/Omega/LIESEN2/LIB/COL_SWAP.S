****************************************************
** Change colors on Image
**
**   d0=New color section (0-2) on section 0
**   d1=New color section (0-2) on section 1
**   d2=New color section (0-2) on section 2
**   a0=start of image data
**   a1=end of image data
****************************************************
colorswap:      movem.l D0-A6,-(A7)
                lea     changetab+3(PC),A3
                lea     sectioncols(PC),A3
                lsl.w   #2,D0
                lsl.w   #2,D1
                lsl.w   #2,D2
                move.b  0(A2,D0.w),(A3)+
                move.b  1(A2,D0.w),(A3)+
                move.b  2(A2,D0.w),(A3)+
                move.b  3(A2,D0.w),(A3)+
                move.b  0(A2,D1.w),(A3)+
                move.b  1(A2,D1.w),(A3)+
                move.b  2(A2,D1.w),(A3)+
                move.b  3(A2,D1.w),(A3)+
                move.b  0(A2,D2.w),(A3)+
                move.b  1(A2,D2.w),(A3)+
                move.b  2(A2,D2.w),(A3)+
                move.b  3(A2,D2.w),(A3)+
                lea     changetab(PC),A2
                bsr.s   colorchange
                movem.l (A7)+,D0-A6
                rts
sectioncols:    DC.B 3,4,5,6
                DC.B 7,8,9,10
                DC.B 11,12,13,14
changetab:      DC.B 0,1,2,-1
                DS.B 11,-1
                DC.B 15

*********************************************
** Color Change Rout  (Pc relativ)
**
** a0=address to start of object
** a1=address to end of object
** a2=address to a 16 bytes conversion tab
**     where byte 1 contain what all color 1 will
**     get and so on.....
*********************************************
colorchange:    movem.l D0-A6,-(A7)
newword:        movem.w (A0)+,D0-D3
                moveq   #15,D7
bitloop:        moveq   #0,D4
                roxl.w  #1,D3
                roxl.w  #1,D4
                ror.w   #1,D3
                roxl.w  #1,D2
                roxl.w  #1,D4
                ror.w   #1,D2
                roxl.w  #1,D1
                roxl.w  #1,D4
                ror.w   #1,D1
                roxl.w  #1,D0
                roxl.w  #1,D4
                ror.w   #1,D0

                move.b  0(A2,D4.w),D4

                roxr.w  #1,D4
                roxl.w  #1,D0
                roxr.w  #1,D4
                roxl.w  #1,D1
                roxr.w  #1,D4
                roxl.w  #1,D2
                roxr.w  #1,D4
                roxl.w  #1,D3
                dbra    D7,bitloop
                movem.l D0-D3,-8(A0)
                cmpa.l  A1,A0
                blo.s   newword
                movem.l (A7)+,D0-A6
                rts
                END
