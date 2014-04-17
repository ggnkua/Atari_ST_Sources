*******************
* VERIFY.S: Schaltet Verify an/aus
* (C) 1986 by Claus Brod, Am Felsenkeller 2, 8772 Marktheidenfeld
* Aus SCHEIBENKLEISTER, dem etwas anderen Floppybuch
********************
                OPT F+          ; fÅr TurboAss

                lea     text1(PC),A0    ; 'Verify o'
                bsr.s   out             ; ausgeben
                pea     change(PC)      ; change ausfÅhren
                move.w  #38,-(SP)       ; SUPEXEC
                trap    #14             ; XBIOS
                addq.l  #6,SP

                clr.w   -(SP)           ; PTERM0
                trap    #1              ; Sense!

*******
* change: Verify ein/aus
*******
change:
                lea     text2(PC),A0    ; 'n'
                moveq   #0,D0
                tst.w   $0444.w         ; Verify-Flag testen
                seq     D0              ; wenn gelîscht, dann setzen
                beq.s   off             ; gesetzt?
                lea     text3(PC),A0    ; 'ff' ausgeben
off:
                move.w  D0,$0444.w
out:
                move.l  A0,-(SP)
                move.w  #9,-(SP)        ; PRINTLINE
                trap    #1              ; GEMDOS
                addq.l  #6,SP
                rts

text1:          DC.B 13,10,'Verify o',0
text2:          DC.B 'n.',10,13,0
text3:          DC.B 'ff.',10,13,0
                END
