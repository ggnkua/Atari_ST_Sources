;----------------------------------------
; vectorprodukt
                movem.w (A1),D0-D1      ;y0 x0
                movem.w (A2),D2-D3      ;y1 x1
                movem.w (A3),D4-D5      ;y2 x2

                sub.w   D1,D3           ;x1-x0   X0
                sub.w   D0,D2           ;y1-y0   Y0

                sub.w   D1,D5           ;x2-x0   X1
                sub.w   D0,D4           ;y2-y0   Y1

                muls    D3,D4           ; X0*Y1
                muls    D2,D5           ; Y0*X1

                sub.l   D5,D4           ; X0*Y1 - Y0*X1
                bpl.s   tri_nvis        ; WAS: bmi   ??!!??

                addq.w  #1,tri_count

                bra     TRI_MAP
tri_nvis:
                rts

