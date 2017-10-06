                movea.l buffscr,A0      ; 1. Zeile l敗chen
                move.w  #319,D0
anti_clear_1:   clr.l   (A0)+
                dbra    D0,anti_clear_1

                move.w  #3,D6
anti_loop_1:    movea.l buffscr,A0
                lea     642(A0),A0      ; In der 2. Zeile beim 2. Pixel beginnen
                move.w  #64000,D7
anti_loop_2:    clr.l   D1
                clr.l   D2
                clr.l   D3
                clr.l   D4
                clr.l   D5
                move.w  -640(A0),D1
                move.w  D1,D2
                and.l   #%11111,D2      ; Blau
                lsr.w   #5,D1
                move.w  D1,D3
                and.l   #%111111,D3     ; Gr］
                lsr.w   #6,D1
                move.w  D1,D4
                and.l   #%11111,D4      ; Rot

                move.w  -2(A0),D1
                move.w  D1,D5
                and.l   #%11111,D5
                add.w   D5,D2           ; Blau
                lsr.w   #5,D1
                move.w  D1,D5
                and.l   #%111111,D5
                add.w   D5,D3           ; Gr］
                lsr.w   #6,D1
                move.w  D1,D5
                and.l   #%11111,D5
                add.w   D5,D4           ; Rot

                move.w  0(A0),D1
                move.w  D1,D5
                and.l   #%11111,D5
                add.w   D5,D2           ; Blau
                lsr.w   #5,D1
                move.w  D1,D5
                and.l   #%111111,D5
                add.w   D5,D3           ; Gr］
                lsr.w   #6,D1
                move.w  D1,D5
                and.l   #%11111,D5
                add.w   D5,D4           ; Rot

                move.w  2(A0),D1
                move.w  D1,D5
                and.l   #%11111,D5
                add.w   D5,D2           ; Blau
                lsr.w   #5,D1
                move.w  D1,D5
                and.l   #%111111,D5
                add.w   D5,D3           ; Gr］
                lsr.w   #6,D1
                move.w  D1,D5
                and.l   #%11111,D5
                add.w   D5,D4           ; Rot

                move.w  640(A0),D1
                move.w  D1,D5
                and.l   #%11111,D5
                add.w   D5,D2           ; Blau
                lsr.w   #5,D1
                move.w  D1,D5
                and.l   #%111111,D5
                add.w   D5,D3           ; Gr］
                lsr.w   #6,D1
                move.w  D1,D5
                and.l   #%11111,D5
                add.w   D5,D4           ; Rot

;                divu    #5,D2           ; Blau
;                divu    #5,D3           ; Gr］
;                divu    #5,D4           ; Rot
                lsr.l   #2,D2
                lsr.l   #2,D3
                lsr.l   #2,D4

                and.l   #%11111,D2
                and.l   #%111111,D3
                and.l   #%11111,D4
                move.w  D4,D1
                lsl.w   #6,D1
                add.w   D3,D1
                lsl.w   #5,D1
                add.w   D2,D1
                move.w  D1,(A0)+
                dbra    D7,anti_loop_2
                dbra    D6,anti_loop_1
