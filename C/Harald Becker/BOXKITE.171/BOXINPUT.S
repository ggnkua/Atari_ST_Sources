           EXPORT    fsel_boxinput

           TEXT

fsel_boxinput:
           MOVEM.L   D2/A2-A3,-(A7)
           LEA.L     -$9E(A7),A7
           LEA.L     $4C(A7),A0
           LEA.L     $86(A7),A2
           MOVE.L    A0,(A2)
           LEA.L     $2E(A7),A1
           MOVE.L    A1,$04(A2)
           LEA.L     $0E(A7),A1
           MOVE.L    A1,$08(A2)
           LEA.L     (A7),A1
           MOVE.L    A1,$0C(A2)
           LEA.L     $6E(A7),A1
           MOVE.L    A1,$10(A2)
           LEA.L     $56(A7),A3
           MOVE.L    A3,$14(A2)
           MOVE.W    #$5B,(A0)
           CLR.W     $02(A0)
           MOVE.W    #$02,$04(A0)
           MOVE.W    #$04,$06(A0)
           CLR.W     $08(A0)
           MOVE.L    $AE(A7),(A1)
           MOVE.L    $B2(A7),$04(A1)
           MOVE.L    $BA(A7),$08(A1)
           MOVE.L    $BE(A7),$0C(A1)
           MOVE.L    A2,D1
           MOVE.W    #$C8,D0
           TRAP      #2
           MOVEA.L   $B6(A7),A0
           MOVE.W    $02(A7),(A0)
           MOVE.W    (A7),D0
           LEA.L     $9E(A7),A7
           MOVEM.L   (A7)+,D2/A2-A3
           RTS

