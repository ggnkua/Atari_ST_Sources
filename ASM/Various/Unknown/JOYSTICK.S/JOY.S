;
; Joystick initialisieren
;
                lea joybewegen(pc),a0   ; Adresse der Joystickroutine nach a0
                move.l a0,$de4          ; und als Joystickvektor abspeichern

                lea ikbinit(pc),a0      ; Adresse der Initialisierungsbefehle
                                        ; fÅr den Tastaturprozessor holen
                move.l a0,-(sp)         ; Und auf Stack speichern
                clr -(sp)               ; LÑnge des Initcodes-1 auf Stack legen
                move #25,-(sp)          ; Funktionsnummer fÅr IKBDWS auf Stack
                trap #14                ; Betriebssystem aufrufen
                add.l #8,sp             ; und Stack korrigieren

                rts                     ; Ende der Initialisierung

;
; Joystickbewegungen abfangen und auswerten
;
joybewegen:     
                movem.l d0-d1,-(sp)     ; D0/D1 retten (einzige benîtigte Reg.)
                move.b (a0),d1          ; Joysticknummer holen (a0 zeigt auf
                                        ; dieses Byte - Vom Betriebssystem ge-
                                        ; stellt !)
                move.b $fffc02,d0       ; Und Richtung vom IKB abholen

                cmp.b #255,d1           ; Ist Joystick#=255 ?
                bne joybewegen_1        ; Nein,dann ist es Joystick 0 (Maus)

                move.b d0,$3fe          ; Richtung in $3fe speichern
                bra joy_bewegen_ende    ; und zum RÅcksprung

joybewegen_1:   move.b d0,$3ff          ; Richtung in $3ff speichern

joy_bewegen_ende:movem.l (sp)+,d0-d1    ; Register zurÅckholen
                rts                     ; und RÅcksprung

ikbinit:        dc.b $14,0

