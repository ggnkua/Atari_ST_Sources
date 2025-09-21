                EXPORT  graf_rubberbox, graf_dragbox
                IMPORT  aes, intin

graf_rubberbox: move.l  A1,-(A7)
                move.l  A0,-(A7)		;8 Bytes mehr auf dem Stack
                lea     intin,A0
                move.w  D0,(A1)+                ;x
                move.w  D1,(A1)+                ;y
                move.w  D2,(A1)+                ;minwidth
                move.w  8+4(A7),(A1)+           ;minheight
                move.l  #$46040300,D0
                bra.b   graf_2io

graf_dragbox:   move.l  A1,-(A7)
                move.l  A0,-(A7)		;8 Bytes mehr auf dem Stack
                lea     intin,A1
                lea     8+4(A7),A0
                move.w  D0,(A1)+                ;width
                move.w  D1,(A1)+                ;height
                move.w  D2,(A1)+                ;startx
                move.l  (A0)+,(A1)+             ;starty, boundx
                move.l  (A0)+,(A1)+             ;boundy, boundw
                move.w  (A0)+,(A1)+             ;boundh
                move.l  #$47080300,D0
graf_2io:       bsr     aes                     ;2 (zus„tzliche) IntOut
                move.l  (A7)+,A1
                move.w  (A0)+,(A1)              ;lastwidth
                move.l  (A7)+,A1
                move.w  (A0)+,(A1)              ;lastheight
                rts

