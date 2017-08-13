RENDER_TRI:     >PART

                DC.L $4AFC4E71

                lea     render_x_code+160*4(PC),A4
RT_loop:
                move.l  D0,D4           ;x_links
                move.l  D1,D5           ;x_rechts

                swap    D4
                swap    D5

;  sub.w   D4,D5           ;delta_X
;  bmi.s   rechts_lt_links

                sub.w   D5,D4           ;delta_X
                bpl     rechts_lt_links
delta_x_ok:
                pea     CRAM_X(A6)      ; save scanline pos.
                adda.w  D5,A6           ; X_START = x_rechts

                move.l  D3,D6           ; V
tex_adr0:       move.w  #0,D6
                swap    D6
                swap    D2
                move.b  D2,D6           ; U
                swap    D2
                movea.l D6,A5

C               EQU 15*8+$0006
                clr.w   D6              ***
                movea.l D6,A5
                move.b  #C,(A5)

                add.w   D4,D4
                add.w   D4,D4
                jmp     0(A4,D4.w)
render_x_code:
                REPT 160
                move.b  0(A5),-(A6)
                ENDR

                movea.l (SP)+,A6        ;next line

                add.l   A0,D0           ;x_links  inc
                add.l   A1,D1           ;x_rechts inc
                add.l   A2,D2           ;U Inc
                add.l   A3,D3           ;V Inc
                dbra    D7,RT_loop
rechts_lt_links:
                rts

                ENDPART



