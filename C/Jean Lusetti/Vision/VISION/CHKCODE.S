    .IMPORT sfault, reset
    .EXPORT chk_code
    
chk_code:
    MOVEM.L D2/A2-A3,-(SP)
    LEA.L   sfault,A4
    LEA.L   expected_sfault,A5
    MOVE.B  2(A5),D2
    CMP.B   0(A4),D2      ; $72
    BNE.S   force_bug
    MOVE.B  3(A5),D2
    CMP.B   2(A4),D2      ; $E4
    BNE.S   force_bug
    MOVE.B  0(A5),D2
    CMP.B   1(A4),D2      ; $11
    BNE.S   force_bug
    MOVE.B  6(A5),D2
    CMP.B   6(A4),D2      ; $4E
    BNE.S   force_bug
    MOVE.B  5(A5),D2
    CMP.B   7(A4),D2      ; $92
    BNE.S   force_bug
    MOVE.B  7(A5),D2
    CMP.B   3(A4),D2      ; $89
    BNE.S   force_bug
    MOVE.B  1(A5),D2
    CMP.B   5(A4),D2      ; $41
    BNE.S   force_bug
    MOVE.B  4(A5),D2
    CMP.B   4(A4),D2      ; $24
    BNE.S   force_bug

    MOVEQ.L #1,D0
    BRA     chk_rts
force_bug:
    MOVEQ.L #0,D0
chk_rts:
    MOVEM.L (SP)+,D2/A2-A3
    RTS

expected_sfault:
*   expected_sequence: $7211, $E489, $2441, $4E92
*   DC.B    $72, $11, $E4, $89, $24, $41, $4E, $92
    DC.B    $11, $41, $72, $E4, $24, $92, $4E, $89