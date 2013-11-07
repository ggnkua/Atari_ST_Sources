*-------------------------------------------------------------------------
*       PRINTING ROUTINE ON FOUR PLANES WITH MASK 6 BYTES WIDE
*-------------------------------------------------------------------------

PRINT2          
                MOVE.L  (A2)+,D1

                MOVE.L  (A0),D2         SCREEN
                AND.L   D1,D2           MASK OUT HOLE
                OR.L    (A1)+,D2        OR IN DATA
                MOVE.L  D2,(A0)+        PUT BACK ALTERED SCREEN
                MOVE.L  (A0),D2
                AND.L   D1,D2
                OR.L    (A1)+,D2
                MOVE.L  D2,(A0)+        WORD 1
                MOVE.L  (A2)+,D1        MASK IN HIGH AND LOW WORD

                MOVE.L  (A0),D2         SCREEN
                AND.L   D1,D2           MASK OUT HOLE
                OR.L    (A1)+,D2        OR IN DATA
                MOVE.L  D2,(A0)+        PUT BACK ALTERED SCREEN
                MOVE.L  (A0),D2
                AND.L   D1,D2
                OR.L    (A1)+,D2
                MOVE.L  D2,(A0)+        WORD 2

                MOVE.L  (A2)+,D1

                MOVE.L  (A0),D2         SCREEN
                AND.L   D1,D2           MASK OUT HOLE
                MOVE.L  (A1)+,D7
                AND.L   MASKEDGE,D7
                OR.L    D7,D2                OR IN DATA
                MOVE.L  D2,(A0)+        PUT BACK ALTERED SCREEN
                MOVE.L  (A0),D2
                AND.L   D1,D2
                MOVE.L  (A1)+,D7
                AND.L   MASKEDGE,D7
                OR.L    D7,D2
                MOVE.L  D2,(A0)+        WORD 3
                ADDA.L  #136,A0

