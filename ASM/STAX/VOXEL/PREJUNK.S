********** Source: Vorberechnungen der Junk Tabelle ***********

precalculate_junk_tab:

                lea     mammut_table,A0

                lea     d0_tab(PC),A1
                lea     d1_tab(PC),A2
                lea     d2_tab(PC),A3
                lea     d3_tab(PC),A4

                moveq   #0,D0
                moveq   #0,D1
                moveq   #0,D2
                moveq   #0,D3

loop:

; Spalte 0

                move.w  D0,D4
                lsl.w   #3,D4
                movem.l 0(A1,D4.w),D5-D6

; Spalte 1
                move.w  D1,D4
                lsl.w   #3,D4
                or.l    0(A2,D4.w),D5
                or.l    4(A2,D4.w),D6

; Spalte 2
                move.w  D2,D4
                lsl.w   #3,D4
                or.l    0(A3,D4.w),D5
                or.l    4(A3,D4.w),D6

; Spalte 3

                move.w  D3,D4
                lsl.w   #3,D4
                or.l    0(A4,D4.w),D5
                or.l    4(A4,D4.w),D6

; In Tabelle schreiben

                move.l  D5,(A0)+
                move.l  D6,(A0)+

; Nächste Kombination

                addq.w  #1,D0
                cmp.w   #16,D0	; 16 * ...
                blt.s   loop
                moveq   #0,D0

                addq.w  #1,D1
                cmp.w   #16,D1	; ... * 16 * ...
                blt.s   loop
                moveq   #0,D1

                addq.w  #1,D2
                cmp.w   #16,D2	; ... * 16 * ...
                blt.s   loop
                moveq   #0,D2

                addq.w  #1,D3
                cmp.w   #15,D3	; ... * 15
                blt.s   loop

                rts

d0_tab:         DC.W $000F,$000F,$000F,$000F
                DC.W $000F,0,0,0
                DC.W 0,$000F,0,0
                DC.W $000F,$000F,0,0
                DC.W 0,0,$000F,0
                DC.W $000F,0,$000F,0
                DC.W 0,$000F,$000F,0
                DC.W $000F,$000F,$000F,0
                DC.W 0,0,0,$000F
                DC.W $000F,0,0,$000F
                DC.W 0,$000F,0,$000F
                DC.W $000F,$000F,0,$000F
                DC.W 0,0,$000F,$000F
                DC.W $000F,0,$000F,$000F
                DC.W 0,$000F,$000F,$000F
                DS.W 4

d1_tab:         DC.W $00F0,$00F0,$00F0,$00F0
                DC.W $00F0,0,0,0
                DC.W 0,$00F0,0,0
                DC.W $00F0,$00F0,0,0
                DC.W 0,0,$00F0,0
                DC.W $00F0,0,$00F0,0
                DC.W 0,$00F0,$00F0,0
                DC.W $00F0,$00F0,$00F0,0
                DC.W 0,0,0,$00F0
                DC.W $00F0,0,0,$00F0
                DC.W 0,$00F0,0,$00F0
                DC.W $00F0,$00F0,0,$00F0
                DC.W 0,0,$00F0,$00F0
                DC.W $00F0,0,$00F0,$00F0
                DC.W 0,$00F0,$00F0,$00F0
                DS.W 4

d2_tab:         DC.W $0F00,$0F00,$0F00,$0F00
                DC.W $0F00,0,0,0
                DC.W 0,$0F00,0,0
                DC.W $0F00,$0F00,0,0
                DC.W 0,0,$0F00,0
                DC.W $0F00,0,$0F00,0
                DC.W 0,$0F00,$0F00,0
                DC.W $0F00,$0F00,$0F00,0
                DC.W 0,0,0,$0F00
                DC.W $0F00,0,0,$0F00
                DC.W 0,$0F00,0,$0F00
                DC.W $0F00,$0F00,0,$0F00
                DC.W 0,0,$0F00,$0F00
                DC.W $0F00,0,$0F00,$0F00
                DC.W 0,$0F00,$0F00,$0F00
                DS.W 4

d3_tab:         DC.W $F000,$F000,$F000,$F000
                DC.W $F000,0,0,0
                DC.W 0,$F000,0,0
                DC.W $F000,$F000,0,0
                DC.W 0,0,$F000,0
                DC.W $F000,0,$F000,0
                DC.W 0,$F000,$F000,0
                DC.W $F000,$F000,$F000,0
                DC.W 0,0,0,$F000
                DC.W $F000,0,0,$F000
                DC.W 0,$F000,0,$F000
                DC.W $F000,$F000,0,$F000
                DC.W 0,0,$F000,$F000
                DC.W $F000,0,$F000,$F000
                DC.W 0,$F000,$F000,$F000
                DS.W 4
