;
; Beispielprogramm zum Programmier-Schwerpunkt
; Achtung: Es findet keine öberprÅfungen der Eingabe statt!!!
; Ebenso ist der Rechenbereich eingeschrÑnkt, d.h.
; a,b Ó N mit a,b = 0,1,2,...,99999
;

                clr.l   D5              ; d5 lîschen

in_1:           lea     eingabe_a(PC),A0 ; Ersten Text
                bsr     print           ; ausgeben
                bsr     input           ; Input-Routine (1.Zahl)

                tst.b   puffer+1        ; Zahl da ?
                beq.s   in_1            ; nein, dann nochmal

                bsr.s   to_hex          ; Zahl umwandeln

                add.l   D2,D5           ; Zahl speichern

in_2:           lea     eingabe_b(PC),A0 ; Zweiten Text
                bsr.s   print           ; ausgeben
                bsr     input           ; Input-Routine (2.Zahl)

                tst.b   puffer+1        ; Zahl da ?
                beq.s   in_2            ; nein, dann nochmal

                bsr.s   to_hex          ; Zahl umwandeln

                add.l   D2,D5           ; Addieren
                move.l  D5,D0           ; Zahl wandeln

                lea     dezimal_out(PC),A1 ; Zahl umwandeln
                bsr.s   dezi_out        ;

                lea     ausgabe(PC),A0  ; Zahl jetzt als String
                bsr.s   print           ; ausgeben

                move.w  #7,-(SP)        ; Auf Tastendruck warten
                trap    #1
                addq.l  #2,SP

                clr.w   -(SP)           ; Pterm()
                trap    #1              ; Programm beenden

dezi_out:
                move.w  D1,D4

                lea     dezimal_tab(PC),A0 ; Werte-Tabelle
                lea     dezimal_out(PC),A1 ; a1 zeigt auf Ausgabestring

                move.w  #5,D3           ; max. sechs Stellen

_dezi_0:        move.l  (A0)+,D2        ; (nÑchsten) Tabellenwert holen
                move.b  #'0',D1         ; ASCII fÅr '0'

_dezi_1:        sub.l   D2,D0           ; Tabellenwert abziehen
                bmi.s   _next_tenth     ; wenn negativ -> nÑchste Stelle
                addq.b  #1,D1           ; Stelle um eins erhîhen
                bra.s   _dezi_1         ; nochmal abziehen

_next_tenth:    add.l   D2,D0           ; Wert wieder addieren
                move.b  D1,(A1)+        ; Zahl in String kopieren
                dbra    D3,_dezi_0      ; 5 mal das Ganze

                rts                     ; zurÅck zu main()
to_hex:
                clr.l   D0              ; d0 lîschen
                clr.l   D2              ; d2 lîschen
                lea     hex_tab(PC),A1
                lea     puffer(PC),A0   ; Eingabepuffer nach a0

                move.b  1(A0),D0        ; Anzahl der eingegeben Zeichen nach d0
                addq.b  #2,D0           ;
                adda.l  D0,A0           ; a0 zeigt hinter letzte Stelle

                subq.b  #3,D0           ;

loop:           move.b  -(A0),D1        ; Stellen von rechts nach links
                subi.b  #'0',D1         ; ASCII-Wert "0" abziehen

                move.l  (A1)+,D3        ; auf Zahlenbasis 10 umrechnen
                mulu    D3,D1

                add.l   D1,D2           ; und zum Hauptwert addieren

                clr.l   D1              ; d1 lîschen

                dbra    D0,loop         ; FÅr alle gefundenen Stellen

                rts

print:          move.l  A0,-(SP)        ; Adresse des Ausgabetext auf Stack
                move.w  #9,-(SP)        ; GEMDOS-Funtkion Cconws()
                trap    #1              ; aufrufen
                addq.l  #6,SP           ; Stack aufrÑumen

                rts                     ; ZurÅck ins Hauptprogramm

input:          pea     puffer(PC)      ; Adresse des Eingabepuffer Åbergeben
                move.w  #$0A,-(SP)      ; GEMDOS-Funktion Cconrs()
                trap    #1              ; aufrufen
                addq.l  #6,SP           ; Stack aufrÑumen

                rts

                DATA

dezimal_tab:    DC.L 100000,10000,1000,100,10,1
hex_tab:        DC.L 1,10,100,1000,10000
eingabe_a:      DC.B 27,'e',13,10,'Bitte geben Sie die erste Zahl ein: ',27,'j','     ',27,'k',0
eingabe_b:      DC.B 13,10,'Bitte geben Sie die zweite Zahl ein: ',27,'j','     ',27,'k',0
ausgabe:        DC.B 13,10,'Die Summe von a und b ist: '
dezimal_out:    DC.B '000000',13,10,13,10
                DC.B 'Beliebige Taste fÅr Desktop...',27,'f',13,10,0
puffer:         DC.B 5,0,'00000'

                END
