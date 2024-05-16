;  **********************************************************
;  *            THRUST-MUSIC, COMPOSED BY DAVID.W           *
;  *    RIPPED BY THE DISK BUSTER OF THE MAGIC HACKERS      *
;  **********************************************************
;
 MOVE.L A7,A5
 MOVE.L 4(A5),A5
 MOVE.L $C(A5),D0
 ADD.L $14(A5),D0
 ADD.L $1C(A5),D0
 ADD.L #$1100,D0
 MOVE.L A5,D1
 ADD.L D0,D1
 AND.L #-2,D1
 MOVE.L D1,A7
 MOVE.L D0,-(SP)
 MOVE.L A5,-(SP)
 MOVE.W D0,-(SP)
 MOVE.W #$4A,-(SP) ; Setblock.
 TRAP #1
 ADD.L #12,SP
;
 MOVE.L #SETUP,-(SP)
 MOVE.W #38,-(SP)
 TRAP #14
 ADDQ.L #6,SP
 MOVE.W #0,-(SP)
 MOVE.L #1024*6,-(SP)
 MOVE.W #$31,-(SP)
 TRAP #1
SETUP:
 JSR MUSIC+84
 JSR MUSIC+$54
 MOVE.L #THRUST,$4D2
 RTS
THRUST:
 JSR MUSIC+180
 MOVEQ #3,D1
 RTS

MUSIC:
 INCBIN C:\SOURCE.S\MUSIX\MUSIC.OBJ
 END



?