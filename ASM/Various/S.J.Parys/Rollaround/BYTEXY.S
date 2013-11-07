BYTEXY          MOVE.L  PSEUDO,A0
BYTEXYR         MOVE.L  D5,D7
                JSR     XYCO1
                MOVE.L  D7,D5
                SWAP    D5
                ANDI.L  #$0000FFFF,D5   X CO
                ANDI.W  #$FFF8,D5
                LSR     #3,D5           DIVIDE BY 8
                OR.W    D5,D5           
                BEQ.S   OKH
                BTST.B  #0,D5           TEST IF ODD OR EVEN
                BNE.S   MULP
                BRA.S   OKH
MULP            ADDA.L  #1,A0
OKH             RTS
*
