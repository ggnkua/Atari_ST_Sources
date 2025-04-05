a1:             move.w  $1234(A0),$2234(A1) ; 20
; 20
a2:             move.l  $1234(A0),$2234(A1) ; 28
; 14
a3:             move.l  $1234(A0),$2234(A1) ; 28
                move.w  $1234(A0),$2234(A1) ; 20
; 16
a4:             move.l  $1234(A0),$2234(A1) ; 28
                move.l  $1234(A0),$2234(A1) ; 28
; 14
a5:             movem.w $1234(A0),D0-D4
                movem.w D0-D4,$2234(A1)
; 13.6
a6:             movem.l $1234(A0),D0-D2
                movem.l D0-D2,$2234(A1)
; 12.6666
a7:             movem.w $1234(A0),D0-D6
                movem.w D0-D6,$2234(A1)
; 12
a8:             movem.l $1234(A0),D0-D3
                movem.l D0-D3,$2234(A1)
; 11.5
a9:             movem.w $1234(A0),D0-D7/A2
                movem.w D0-D7/A2,$2234(A1)
; 11.1111
a10:            movem.l $1234(A0),D0-D4
                movem.l D0-D4,$2234(A1)
; 10.8
a11:            movem.w $1234(A0),D0-D7/A2-A4
                movem.w D0-D7/A2-A4,$2234(A1)
; 10.5454
a12:            movem.l $1234(A0),D0-D5
                movem.l D0-D5,$2234(A1)
; 10.3333
a13:            movem.w $1234(A0),D0-D7/A2-A6
                movem.w D0-D7/A2-A6,$2234(A1)
; 10.1538
a14:            movem.l $1234(A0),D0-D6
                movem.l D0-D6,$2234(A1)
; 10
a16:            movem.l $1234(A0),D0-D7
                movem.l D0-D7,$2234(A1)
; 9.75
a18:            movem.l $1234(A0),D0-D7/A2
                movem.l D0-D7/A2,$2234(A1)
; 9.5555
a20:            movem.l $1234(A0),D0-D7/A2-A3
                movem.l D0-D7/A2-A3,$2234(A1)

a22:            movem.l $1234(A0),D0-D7/A2-A4
                movem.l D0-D7/A2-A4,$2234(A1)

a24:            movem.l $1234(A0),D0-D7/A2-A5
                movem.l D0-D7/A2-A5,$2234(A1)

a26:            movem.l $1234(A0),D0-D7/A2-A6
                movem.l D0-D7/A2-A6,$2234(A1)
                rts
