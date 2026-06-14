* --------------------------------------------------------------------
* Assembler-Routinen fr Pascal+ by Dirk Sabiwalsky 5/88
* --------------------------------------------------------------------

* *** Verschieben von Speicherbereichen

               xdef           MOVEBYTES
MOVEBYTES:     move.l         (a7)+,a0       * Returnadresse
               move.l         (a7)+,d0       * Anzahl
               move.l         (a7)+,a2       * Ziel
               move.l         (a7)+,a1       * Start
mbloop1:       move.b         (a1)+,(a2)+
               subq.l         #1,d0
               cmp.l          #0,d0
               bne            mbloop1
               jmp            (a0)           * Ende -> Return

               xdef           MOVEWORDS
MOVEWORDS:     move.l         (a7)+,a0       * Returnadresse
               move.l         (a7)+,d0       * Anzahl
               move.l         (a7)+,a2       * Ziel
               move.l         (a7)+,a1       * Start
mwloop1:       move.w         (a1)+,(a2)+
               subq.l         #1,d0
               cmp.l          #0,d0
               bne            mwloop1
               jmp            (a0)           * Ende -> Return

               xdef           MOVELONGS
MOVELONGS:     move.l         (a7)+,a0       * Returnadresse
               move.l         (a7)+,d0       * Anzahl
               move.l         (a7)+,a2       * Ziel
               move.l         (a7)+,a1       * Start
mlloop1:       move.l         (a1)+,(a2)+
               subq.l         #1,d0
               cmp.l          #0,d0
               bne            mlloop1
               jmp            (a0)           * Ende -> Return

* *** Fuellen und Loeschen von Speicherbereichen

               xdef           FILLBYTES
FILLBYTES:     move.l         (a7)+,a0       * Returnadresse
               move.w         (a7)+,d1       * Fllbyte
               move.l         (a7)+,d0       * Anzahl
               move.l         (a7)+,a1       * Start
fbloop1:       move.b         d1,(a1)+
               subq.l         #1,d0
               cmpi.l         #0,d0
               bne            fbloop1
               jmp            (a0)           * Ende -> Return

               xdef           ERASEBYTES
ERASEBYTES:    move.l         (a7)+,a0       * Returnadresse
               move.l         (a7)+,d0       * Anzahl
               move.l         (a7)+,a1       * Start
erloop1:       clr.b          (a1)+
               subq.l         #1,d0
               cmp.l          #0,d0
               bne            erloop1
               jmp            (a0)           * Ende -> Return

* *** Peek und Poke

               xdef           PEEK
PEEK:          move.l         (a7)+,a0       * Returnadresse
               move.l         (a7)+,a1       * Adresse
               clr.l          d0
               move.b         (a1),d0
               jmp            (a0)

               xdef           POKE
POKE:          move.l         (a7)+,a0       * Returnadresse
               move.w         (a7)+,d0       * Byte
               move.l         (a7)+,a1       * Adresse
               move.b         d0,(a1)
               jmp            (a0)

               xdef           LPEEK
LPEEK:         move.l         (a7)+,a0       * Returnadresse
               move.l         (a7)+,a1       * Adresse
               clr.l          d0
               move.l         (a1),d0
               jmp            (a0)

               xdef           LPOKE
LPOKE:         move.l         (a7)+,a0       * Returnadresse
               move.l         (a7)+,d0       * Long
               move.l         (a7)+,a1       * Adresse
               move.l         d0,(a1)
               jmp            (a0)

* *** Stringsuchen

               xdef           SEARCHSTRING
SEARCHSTRING:  move.l         (a7)+,Ret_Adresse             * Returnadresse
               move.l         (a7)+,Str_Adresse             * Stringadresse
               move.l         (a7)+,Ende                    * Anzahl
               move.l         (a7)+,Start                   * Startadresse
               move.l         Start,d0       * \  Ende  = Start + Anzahl
               move.l         Ende,d1        *  \
               add.l          d0,d1          *  /
               move.l         d1,Ende
               move.l         Str_Adresse,a0
               clr.l          d0
               move.b         (a0)+,d0       * Stringlaenge -> d0
               move.b         d0,Str_Laenge  * Str_Laenge sichern
               move.l         a0,Str_Adresse * Suchstring
               move.l         Ende,a0        * \  Ende  = Ende - Str_Laenge
               sub.l          d0,a0          *  \
               move.l         a0,Ende        *  /
               move.l         Start,d0       * \
               cmp.l          d0,a0          *  \ Falls Ende < Start -> Exit
               blt            exit           *  /
search:        clr.l          d0             * \  Str_Laenge in d0
               move.b         Str_Laenge,d0  *  \ zwischenspeichern und
               subq.b         #1,d0          *  / 1 abziehen
               move.l         Str_Adresse,a0 * Stringadresse nach a0
               move.l         Start,a1       * Startadresse nach a1
compare:       cmpm.b         (a0)+,(a1)+    * Vergleich
               bne            falsch         * Fehler -> Weitersuchen
               dbf            d0,compare     * ansonsten weitermachen
               move.l         Start,d0       * Jauchzzzz
               move.l         Ret_Adresse,a0 * \ Back to the Roots
               jmp            (a0)           * /
falsch:        move.l         Start,d0
               addq.l         #1,d0
               move.l         d0,Start
               move.l         Ende,d1
               cmp.l          d0,d1
               bne            search
exit:          move.l         #-1,d0
               move.l         Ret_Adresse,a0
               jmp            (a0)
               
* *** Vergleichen und Vertauschen von Speicherbereichen

               xdef           COMPAREBYTES
COMPAREBYTES:  move.l         (a7)+,Ret_Adresse
               move.l         (a7)+,d0       * Anzahl der Bytes
               move.l         (a7)+,a1       * Zweite Adresse
               move.l         (a7)+,a0       * Erste Adresse
vergleich:     cmpm.b         (a0)+,(a1)+    * Vergleiche die Bytes
               bne            ungleich       * Ungleich -> Vglende
               subq.l         #1,d0
               bne            vergleich
               clr.l          d0             * Alle gleich -> 0 zurueck
               move.l         Ret_Adresse,a0
               jmp            (a0)
ungleich:      clr.l          d0             * ungleich -> -1 zurueck
               move.l         #-1,d0
               move.l         Ret_Adresse,a0
               jmp            (a0)

               xdef           SWAPBYTES
SWAPBYTES:     move.l         (a7)+,Ret_Adresse
               move.l         (a7)+,d0       * Anzahl der Bytes
               move.l         (a7)+,a1       * Zweite Adresse
               move.l         (a7)+,a0       * Erste Adresse
vertausche:    clr.l          d1
               move.b         (a0),d1        * \  Vertauschen der Bytes
               move.b         (a1),(a0)+     *  \
               move.b         d1,(a1)+       *  /
               subq.l         #1,d0
               cmp.l          #0,d0
               bne            vertausche     * d0>0 -> weiter
               move.l         Ret_Adresse,a0
               jmp            (a0)

* *** Highbytes eines Speicherbereiches in einen anderen kopieren

               xdef           GETHIGH
GETHIGH:       move.l         (a7)+,Ret_Adresse
               move.l         (a7)+,d0       * Laenge des Quellbereiches
               move.l         (a7)+,a1       * Zielbereich
               move.l         (a7)+,a0       * Quellbereich
glloop1:       move.b         (a0)+,(a1)+
               addq.l         #1,a0
               subq.l         #2,d0
               bmi            glloop2
               bne            glloop1
glloop2:       move.l         Ret_Adresse,a0
               jmp            (a0)

* *** Lowbytes eines Speicherbereiches in einen anderen kopieren

               xdef           GETLOW
GETLOW:        move.l         (a7)+,Ret_Adresse
               move.l         (a7)+,d0       * Laenge des Quellbereiches
               move.l         (a7)+,a1       * Zielbereich
               move.l         (a7)+,a0       * Quellbereich
               addq.l         #1,a0
ghloop1:       move.b         (a0)+,(a1)+
               addq.l         #1,a0
               subq.l         #2,d0
               bmi            ghloop2
               bne            ghloop1
ghloop2:       move.l         Ret_Adresse,a0
               jmp            (a0)

* *** Bytes eines Speicherbereiches als Highbytes in einen anderen kopieren

               xdef           STOREHIGH
STOREHIGH:     move.l         (a7)+,Ret_Adresse
               move.l         (a7)+,d0       * Laenge des Quellbereiches
               move.l         (a7)+,a1       * Zielbereich
               move.l         (a7)+,a0       * Quellbereich
slloop1:       move.b         (a0)+,(a1)+
               addq.l         #1,a1
               subq.l         #1,d0
               bne            slloop1
               move.l         Ret_Adresse,a0
               jmp            (a0)

* *** Bytes eines Speicherbereiches als Lowbytes in einen anderen kopieren

               xdef           STORELOW
STORELOW:      move.l         (a7)+,Ret_Adresse
               move.l         (a7)+,d0       * Laenge des Quellbereiches
               move.l         (a7)+,a1       * Zielbereich
               move.l         (a7)+,a0       * Quellbereich
               addq.l         #1,a1
shloop1:       move.b         (a0)+,(a1)+
               addq.l         #1,a1
               subq.l         #1,d0
               bne            shloop1
               move.l         Ret_Adresse,a0
               jmp            (a0)

Start          dc.l           0
Ende           dc.l           0
Ret_Adresse    dc.l           0

               end
