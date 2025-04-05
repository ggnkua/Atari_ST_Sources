;--------------------------------------------------------------------------
; Falcon-Schnellstart
; nach Quicktip in "ST-Computer"
; in Assembler getippt und erkl„rt von Apache of TNB
;--------------------------------------------------------------------------
; das 10. Byte des "Non-Volatile-Memory" im Falcon bestimmt, ob beim
; Einschalten ein Speichertest durchgefhrt wird und wie lange auf die
; Festplatte gewartet wird
;--------------------------------------------------------------------------
                pea     data(PC)        ; NVM-Daten
                move.w  #1,-(SP)        ; 1 Byte
                move.w  #10,-(SP)       ; ab Byte 10
                move.w  #1,-(SP)        ; schreiben mit Prfsummenkorrektur
                move.w  #$2E,-(SP)      ;    NVM-Access
                trap    #14             ; -> XBIOS-Trap
                lea     12(SP),SP       ;    Stack-Korrektur
                clr.w   -(SP)           ;    Pterm0
                trap    #1              ; -> GEMDOS-Trap
data:           DC.B 0
;--------------------------------------------------------------------------
;  Dauer der "Schweigeminute":
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;  0...kein Mem-Test, kein Warten
; >2...Mem-Test, Wartezeit entspr. Wert
; 32...Standarteinstellung
;--------------------------------------------------------------------------
                END
