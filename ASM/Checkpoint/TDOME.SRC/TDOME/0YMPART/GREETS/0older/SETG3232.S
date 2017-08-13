;-------------------------------------------------------------------------------
; A1...colorram
set_gfx_32x32:  >PART           ; add

*   adda.l  gfx_offset(PC),A1

                and.w   #$00FF,D2
                lea     font_ftb(PC),A0
                move.b  0(A0,D2.w),D2

                lea     font_gfx,A0
                mulu    #FONT_Y*FONT_X,D2
                adda.l  D2,A0

                bclr    #0,D0

                adda.w  D0,A1
                muls    #XW,D1
                adda.l  D1,A1

                move.w  #32-1,-(SP)
sgt5_y:
; 32/4 = 8
                REPT 1
                movem.l (A0)+,D0-D7
                or.l    D0,(A1)+
                or.l    D1,(A1)+
                or.l    D2,(A1)+
                or.l    D3,(A1)+
                or.l    D4,(A1)+
                or.l    D5,(A1)+
                or.l    D6,(A1)+
                or.l    D7,(A1)+
                ENDR

                lea     XW-32(A1),A1
                subq.w  #1,(SP)
                bpl.s   sgt5_y
                addq.l  #2,SP

                rts
                ENDPART
;-------------------------------------------------------------------------------

