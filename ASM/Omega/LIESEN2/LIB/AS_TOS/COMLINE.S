                movea.l 4(A7),A5
                lea     _Stack(PC),A7
                lea     128(A5),A5
                moveq   #0,D0
                move.b  (A5)+,D0
                clr.b   0(A5,D0.w)
