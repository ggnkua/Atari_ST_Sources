;       ACIA KEYBOARD HARDWARE JOY READ ROUTINE         7/25

        BSS
;                       ***** JOY HANDLER BSS *****
JOY0    DS.B    1
JOY1    DS.B    1

        TEXT
JOY:            ;       ***** JOYSTICK HANDLER *****
WAITXMT:
        BTST    #1,ACIACTL      ; READY TO XMT?
        BEQ     WAITXMT
        MOVE.B  #$16,ACIADAT    ; REQUEST JOY PKG
WAITACIA1:
        BTST    #0,ACIACTL      ; CHAR READY?
        BEQ     WAITACIA1
        MOVE.B  ACIADAT,JOY0    ; FETCH COMMAND
        CMP.B   #$19,JOY0       ; P IS FOR PAUSE
        BNE     NOTPAUSE
;       ***** PAUSE PROCESSING *****
WAITACIA4:
        BTST    #0,ACIACTL      ; WAIT FOR P RELEASE
        BEQ     WAITACIA4
        CMP.B   #$19+$80,ACIADAT
        BNE     WAITACIA4
WAITACIA5:
        BTST    #0,ACIACTL      ; WAIT FOR P TO RESUME
        BEQ     WAITACIA5
        CMP.B   #$19,ACIADAT
        BNE     WAITACIA5
WAITACIA6:
        BTST    #0,ACIACTL      ; WAIT FOR P RELEASE
        BEQ     WAITACIA6
        CMP.B   #$19+$80,ACIADAT
        BNE     WAITACIA6
        CLR.B   RTIMING         ; DON'T HOLD UP RIVER
        BRA     JOY

NOTPAUSE:
        CMP.B   #$FD,JOY0       ; WAIT FOR OUR JOY PKG
        BNE     WAITACIA1

;               ***** JOY PROCESSING *****
WAITACIA2:
        BTST    #0,ACIACTL      ; CHAR READY?
        BEQ     WAITACIA2
        MOVE.B  ACIADAT,JOY0    ; NEXT JOY 0
WAITACIA3:
        BTST    #0,ACIACTL      ; CHAR READY?
        BEQ     WAITACIA3
        MOVE.B  ACIADAT,JOY1    ; AND JOY1
ENDJOY:
        RTS
        END
 