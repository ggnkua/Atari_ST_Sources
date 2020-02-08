                move.w  #$14,-(SP)      ;IKBD Jystick Ereignisse
                move.w  #4,-(SP)        ;Ziel IKBD
                move.w  #3,-(SP)        ;bconout
                trap    #13             ;bios
                addq.l  #6,SP

                move.w  #34,-(SP)       ;Kbdvbase
                trap    #14             ;xbios
                addq.l  #2,SP
                movea.l D0,A5           ;gibt Zeiger zurÅck
                lea     puffer(PC),A1
                move.l  24(A5),(A1)
                lea     myjoy(PC),A1    ;eigene Joystickroutine
                move.l  A1,24(A5)       ;in Joyvector eintragen
                lea     tableadr(PC),A1
                move.l  A5,(A1)

                lea     joy1(PC),A4
loop:

;************ STICK 2

                cmpi.w  #0,(A4)
                beq.s   loop
                lea     stick2(PC),A5   ;Text Stick 2
                bsr.s   ausgabe
                move.b  joy2(PC),D5     ;"Variable" fÅr Joystick Port 2 in D5
                btst    #7,D5           ;teste auf Schussknopf
                bne.s   quit            ;wenn gedrÅckt QUIT
                bsr.s   position        ;Springe zum Positionstest

;************ STICK 1

                lea     stick1(PC),A5   ;Text Stick 1
                bsr.s   ausgabe
                move.b  joy1(PC),D5     ;"Variable" fÅr Joystick Port 1 in D%
                btst    #7,D5           ;teste auf Schussknopf
                bne.s   quit            ;wenn gedrÅckt QUIT
                bsr.s   position        ;Springe zum Positionstest
                clr.w   (A4)
                bra.s   loop
quit:

                pea     befehl(PC)      ;IKBD Befehle
                move.w  #1,-(SP)        ;Befehle -1
                move.w  #25,-(SP)       ;Ikbdws
                trap    #14             ;XBIOS
                addq.l  #8,SP

******* IKBD  Tabelle wieder herstellen

                movea.l tableadr(PC),A1
                lea     puffer(PC),A2
                move.l  (A2),24(A1)

                clr.w   -(SP)           ;QUIT
                trap    #1






position:
                btst    #0,D5           ;OBEN ?
                bne.s   oben

                btst    #1,D5           ;UNTEN ?
                bne.s   unten
a2:
                btst    #2,D5           ;LINKS ?
                bne.s   links

                btst    #3,D5           ;RECHTS ?
                bne.s   rechts
exit:
                rts



oben:
                lea     otext(PC),A5    ;Text "oben" ausgeben
                bsr.s   ausgabe
                bra.s   a2
unten:
                lea     utext(PC),A5    ;Text "unten" ausgeben
                bsr.s   ausgabe
                bra.s   a2
links:
                lea     ltext(PC),A5    ;Text "links" ausgeben
                bsr.s   ausgabe
                bra.s   exit
rechts:
                lea     rtext(PC),A5    ;Text "rechts" ausgeben
                bsr.s   ausgabe
                bra.s   exit


***********     Textausgabe **********

ausgabe:

                move.l  A5,-(SP)
                move.w  #9,-(SP)        ; GEMDOS 9 (Stringausgabe)
                trap    #1
                addq.l  #6,SP


                rts

myjoy:

* bekommt in A0 Adresse auf Packet

                lea     joy1(PC),A1     ;Adresse wo Daten
;                                        abgelegt werden
                adda.w  #1,A0           ;Kennbyte Åberspringen
                move.b  (A0)+,(A1)+     ;kopieren in Joy1
                move.b  (A0)+,(A1)+     ;kopieren in Joy2


                rts


puffer:         DS.L 1
tableadr:       DS.L 1
befehl:         DC.B $15,8
joy1:           DS.B 1
joy2:           DS.B 1

otext:          DC.B "oben",0
                EVEN
utext:          DC.B "unten",0
                EVEN
ltext:          DC.B "links",0
                EVEN
rtext:          DC.B "rechts",0
                EVEN
stick1:         DC.B "   Stick 1  ",0
                EVEN
stick2:         DC.B 27,"EStick 2  ",0
                END
