;/----------------------------------\
;|     Replay Sourcecode for the    |
;|      SIDSOUND DESIGNER v2.42     |
;| by ANIMAL MINE / THE INDEPENDENT |
;\----------------------------------/
* Remember, TIMER A & D are in use !!!

                CLR.L   -(SP)
                MOVE.W  #$20,-(SP)
                TRAP    #1
                ADDQ.L  #6,SP
                MOVE.L  D0,ssp

                LEA     song1(PC),A0
                LEA     voice(PC),A1
                BSR     player          ; Init the player

                MOVE.L  #player+8,$04D2.w ; VBL

w:              CMPI.B  #$39,$FFFFFC02.w
                BNE.S   w

                CLR.L   $04D2.w

                BSR     player+4        ; Quit the replay

                MOVE.L  ssp,-(SP)
                MOVE.W  #$20,-(SP)
                TRAP    #1
                ADDQ.L  #6,SP

                CLR.W   -(SP)
                TRAP    #1

************************************************
* a0.l Adress of song
* a1.l Adress of voiceset
* +0 Init
* +4 Re-Init
* +8 Player
player:         INCBIN 'REPLAYER.BIN'
song1:          INCBIN '*.TRI'
voice:          INCBIN '*.TVS'
                EVEN
ssp:            DC.L 0
                END
