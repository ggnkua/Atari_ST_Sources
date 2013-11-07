*-------------------------------------------------------------------------
*               ENTRY D5 =X Y A0=CURRENT SCREEN EXIT A0= ADDRESS 
*               CURRUPTS  D0,D5,A0 

XYCO1           CLR.L   D0
                MOVE.W  D5,D0           Y CO
                SWAP    D5
                ANDI.L  #$0000FFFF,D5   X CO
                BRA.S   XYSUB
XYCO            CLR.L   D0
                MOVE.W  Y_CO(A6),D0     LOAD WORD WITH Y POS INTI D0
                MOVE.W  X_CO(A6),D5
XYSUB           MULS    #160,D0         TIMES LINE LENTH
                ANDI.W  #$FFF0,D5
                ASR     #1,D5           DIVIDE BY 16 TIMES 6
                ADD.W   D5,D0           NUMBER OR BYTES DOWN THE SCREEN
                ADDA.L  D0,A0           ADD OFSET
                RTS
*
