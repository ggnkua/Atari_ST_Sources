

init_light:     >PART

*    DC.L $4AFC4E71

                lea     light_inc,A0

                lea     c2p_table(PC),A1

                lea     light_0,A2
                lea     64*64*4(A2),A3  ; double y

                moveq   #15*4,D5

                move.w  #64*64/16-1,D6
ill:
                REPT 16
                move.b  (A0)+,D0
                lsr.b   #4-2,D0
                and.w   D5,D0
                move.l  0(A1,D0.w),D0   ; c2p
                move.l  D0,(A2)+
                move.l  D0,(A3)+        ; double y
                ENDR
                dbra    D6,ill

; init the other shifts
                lea     light_0,A0      ; src
                lea     light_1,A1      ;
                lea     light_2,A2      ;
                lea     light_3,A3      ;

                move.l  #64*64*4,D5     ; double y offset

                move.w  #64*64/4-1,D6
ill_shifts:
                movem.l (A0)+,D0-D3

                lsr.l   #2,D0
                lsr.l   #2,D1
                lsr.l   #2,D2
                lsr.l   #2,D3
                movem.l D0-D3,(A1)
                movem.l D0-D3,0(A1,D5.l) ; double y

                lsr.l   #2,D0
                lsr.l   #2,D1
                lsr.l   #2,D2
                lsr.l   #2,D3
                movem.l D0-D3,(A2)
                movem.l D0-D3,0(A2,D5.l) ; double y

                lsr.l   #2,D0
                lsr.l   #2,D1
                lsr.l   #2,D2
                lsr.l   #2,D3
                movem.l D0-D3,(A3)
                movem.l D0-D3,0(A3,D5.l) ; double y

                lea     16(A1),A1
                lea     16(A2),A2
                lea     16(A3),A3
                dbra    D6,ill_shifts

; double y light
                lea     light_1,A0
                bsr.s   double_y_light

                lea     light_2,A0
                bsr.s   double_y_light

                lea     light_3,A0
                bsr.s   double_y_light

                rts

double_y_light:
                move.l  #64*64*4,D0     ; length
                lea     0(A0,D0.l),A1   ; dest
                bsr     memcpy
                rts

                ENDPART

light_inc:
                IBYTES 'LIGHT.8B'


