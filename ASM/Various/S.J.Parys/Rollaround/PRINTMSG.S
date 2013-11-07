
*-------------------------------------------------------------------------
*       PRINTING ROUTINE ON ALL FOUR PLANES WITH MASK 4 BYTES WIDE
*-------------------------------------------------------------------------

PRINTALL        MOVE.L  #15,D0
LOPALL          
                MOVE.L  #0,D1
                MOVE.W  (A1),D1
                OR.W    2(A1),D1
                OR.W    4(A1),D1        
                OR.W    6(A1),D1        MASK
                NOT.W   D1
                MOVE.W  D1,D2
                SWAP    D1
                OR.W    D2,D1           MASK IN HIGH AND LOW WORD

                MOVE.L  (A0),D2         SCREEN
                AND.L   D1,D2           MASK OUT HOLE
                OR.L    (A1)+,D2        OR IN DATA
                MOVE.L  D2,(A0)+        PUT BACK ALTERED SCREEN
                MOVE.L  (A0),D2
                AND.L   D1,D2
                OR.L    (A1)+,D2        SECOND HALF
                MOVE.L  D2,(A0)+        PUT BACK ALTERED SCREEN
                MOVE.L  #0,D1
                MOVE.W  (A1),D1
                OR.W    2(A1),D1
                OR.W    4(A1),D1        
                OR.W    6(A1),D1        MASK
                NOT.W   D1
                MOVE.W  D1,D2
                SWAP    D1
                OR.W    D2,D1           MASK IN HIGH AND LOW WORD

                MOVE.L  (A0),D2         SCREEN
                AND.L   D1,D2           MASK OUT HOLE
                OR.L    (A1)+,D2        OR IN DATA
                MOVE.L  D2,(A0)+        PUT BACK ALTERED SCREEN
                MOVE.L  (A0),D2
                AND.L   D1,D2
                OR.L    (A1)+,D2
                MOVE.L  D2,(A0)
                ADDA.L  #148,A0

