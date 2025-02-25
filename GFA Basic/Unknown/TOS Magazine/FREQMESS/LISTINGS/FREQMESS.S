                TEXT            ;Codesegment
count:          move.l  #5000,D7        ;D7 mit 5000 laden
                moveq   #$00,D0         ;D0 l�schen
                bsr.s   user_super      ;in Super-Mode schalten
                move.l  D0,D6           ;USP sichern

                move    SR,D5           ;Statusregister(SR) sichern
                move    #$2700,SR       ;alle IRQ's sperren

                lea     $FFFA01,A0      ;Offset f�r MFP laden

                move.b  #$00,$18(A0)    ;Timer stoppen
                bclr    #$05,$12(A0)    ;IRQ maskieren
                bset    #$05,$06(A0)    ;IRQ-Eingang einschalten
                bclr    #$05,$0A(A0)    ;IRQ-Pending l�schen
                bclr    #$05,$0E(A0)    ;IRQ-InService l�schen

                move.b  #$FF,$1E(A0)    ;Timer laden
                move.b  #$08,$18(A0)    ;und los

wait:           nop                     ;warten...
                dbra    D7,wait

                move.b  #$00,$18(A0)    ;Timer stoppen
                moveq   #$00,D7         ;D7 l�schen
                move.b  $1E(A0),D7      ;Timer auslesen
                moveq   #$00,D4         ;Flag l�schen

                btst    #$05,$0A(A0)    ;�berlauf?
                bne.s   overcount       ;->ja -> Flag setzen

ende:           move    D5,SR           ;IRQ's wieder zulassen
                bclr    #$05,$06(A0)    ;IRQ-Eingang ausschalten

                move.l  D6,D0
                bsr.s   user_super

                move.l  D7,D0           ;D7 nach D0 schieben
                moveq   #$00,D1         ;D1 l�schen
                move.b  D4,D1           ;Flag nach D1
                rts                     ;ins Basic zur�ck


overcount:      st      D4              ;Flag setzen
                bra.s   ende            ;zur�ck zum HP

user_super:     move.l  D0,-(SP)        ;in D0 mu� der Parameter �bergeben
                move.w  #$20,-(SP)      ;werden
                trap    #$01            ;in Super bzw. Usermodus per GEMDOS
                addq.l  #$06,SP         ;Stack korrigieren
                rts
                END             ;Ende der Fahnenstange
;erlaubt w�hre zwar noch ein DATA-Segment, da aber nur Register benutzt
;werden wird es nicht gebraucht!
