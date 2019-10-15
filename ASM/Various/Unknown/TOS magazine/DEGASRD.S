; liest Degasbild names BILD.PI3 in den Bildschirmspeicher
readDegas:

                clr.w   -(SP)           ; Datei lesen
                pea     bildname        ; Dateiname
                move.w  #$3D,-(SP)      ; Fopen-Funktionsnummer
                trap    #1              ; GEMDOS-Aufruf
                addq.l  #8,SP
                tst.w   D0              ; <0, dann Fehler
                bmi.s   error

                move.w  D0,D7           ; ansonsten Handle merken
                clr.w   -(SP)           ; Seek ab Dateianfang
                move.w  D7,-(SP)        ; Handle
                move.l  #34,-(SP)       ; 34 Byte berlesen
                move.w  #66,-(SP)       ; Fseek-Funktionsnummer
                trap    #1
                adda.w  #10,SP

                move.w  #3,-(SP)        ; Logbase: Bildschirmadresse
                trap    #14
                addq.l  #2,SP
                move.l  D0,-(SP)        ; Logbase = Zieladresse
                move.l  #32000,-(SP)    ; 32000 Byte lesen
                move.w  D7,-(SP)        ; Handle
                move.w  #$3F,-(SP)      ; Fread-Funktionsnummer
                trap    #1
                adda.w  #12,SP

                move.w  D7,-(SP)
                move.w  #$3E,-(SP)      ; Fclose-Funktionsnummer
                trap    #1
                addq.l  #4,SP

error:
                rts

bildname:       DC.B "BILD.PI3",0
                END
