i2r4:
    MOVE.W    i2rx,D3
    MOVE.W    #$FFF8,D6
    SUBA.L    A2,A2
i2r4l:
    MOVE.W    D3,D4
    LSR.W     #1,D4
    AND.W     D6,D4
    MOVE.W    D3,D5
    BTST      D7,D5
    BEQ       na4
    ADDQ.W    #1,D4             ;  Offset / au d‚but de la ligne en octets
na4:
    MOVE.L    A1,A2
    ADD.L     D4,A2
    MOVE.W    D3,D1
    ANDI.W    #7,D1
    NEG.W     D1
    ADDQ.W    #7,D1             ; Bit … affecter
    MOVE.B    (A0)+,D5
    BTST      #0,D5
    BEQ       n41
    BSET      D1,(A2)
n41:BTST      #1,D5
    BEQ       n42
    BSET      D1,2(A2)
n42:BTST      #2,D5
    BEQ       n43
    BSET      D1,4(A2)
n43:BTST      #3,D5
    BEQ       n44
    BSET      D1,6(A2)
n44:ADDQ.W    #1,D3
    CMP.W     D3,A3
    BNE       nl4
    ADD.L     i2rlo,A1
    MOVEQ.L   #0,D3
nl4:SUBQ.L    #1,D0
    BNE       i2r4l
    BRA       i2r_end

