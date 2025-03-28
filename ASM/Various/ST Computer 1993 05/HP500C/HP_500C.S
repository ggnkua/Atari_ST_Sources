; Ausdruck von DEGAS-PI1-Bildern auf HP DeskJet 500C
; (c) 1992 MAXON Computer

; Datei laden

                bsr     open

                lea     filepos,A0
                move.l  #32034,D0
                bsr     read

                lea     filedesc,A0
                move.w  (A0),D0
                bsr     close

; Datei richtig ?

                lea     filepos,A0
                move.w  (A0),D0
                cmp.w   #0,D0
                bne     datei_f
                lea     datei_l,A0
                move.l  (A0),D0
                cmp.l   #32034,D0
                bne     datei_f

; Druckposition bestimmen

                pea     d_position(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP
warte1:         move.w  #7,-(SP)
                trap    #1
                addq.l  #2,SP
                lea     position,A0
                move.w  D0,(A0)
                cmp.w   #49,D0
                beq     weiter
                cmp.w   #50,D0
                bne     warte1

; Farben ermitteln & umwandeln

weiter:         lea     filepos2,A0
                clr.w   D0
schleife_1:     clr.l   D1
                move.w  (A0),D1
                divu    #256,D1
                and.w   #7,D1
                move.w  #7,D2
                sub.w   D1,D2
                move.w  #0,D1
                bsr     mask
                clr.l   D1
                move.w  (A0),D1
                divu    #16,D1
                and.w   #7,D1
                move.w  #7,D2
                sub.w   D1,D2
                move.w  #1,D1
                bsr     mask
                clr.l   D1
                move.w  (A0),D1
                and.w   #7,D1
                move.w  #7,D2
                sub.w   D1,D2
                move.w  #2,D1
                bsr     mask
                adda.l  #2,A0
                addq.w  #1,D0
                cmp.w   #16,D0
                bne     schleife_1

; Drucker bereit ?

                move.w  #17,-(SP)
                trap    #1
                cmp.w   #-1,D0
                bne     drucker_f

; Papier einziehen

                lea     papier_ein,A0
                move.w  #5,D0
                bsr     druck

; Position unten ? -> 34*LPRINT

                lea     position,A0
                move.w  (A0),D0
                cmp.w   #49,D0
                beq     oben
                lea     unten,A0
                move.w  #6,D0
                bsr     druck

; Drucker installieren

oben:           lea     drucker_inst,A0
                move.w  #18,D0
                bsr     druck

; Druckerdaten berechnen ...

                lea     filepos3,A0
                lea     a_speich,A1
                move.l  A0,(A1)
                clr.w   D1
                lea     d_speich1,A1
schleife_11:    move.w  D1,(A1)
                lea     d_0,A1
                move.w  #4320,D1
schleife_6:     clr.w   (A1)
                adda.l  #2,A1
                subq.w  #1,D1
                cmp.w   #0,D1
                bne     schleife_6

                clr.w   D1
                lea     d_speich2,A1
schleife_10:    move.w  D1,(A1)
                move.l  #32768,D1
                lea     d_speich3,A1
                move.l  D1,(A1)
                clr.w   D1
                lea     d_speich4,A1
schleife_9:     move.w  D1,(A1)

                lea     d_speich3,A1
                move.l  (A1),D0
                clr.w   D2
                lea     a_speich,A1
                movea.l (A1),A0
                move.w  0(A0),D1
                and.w   D0,D1
                cmp.w   #0,D1
                beq     weiter1
                move.w  #1,D2
weiter1:        move.w  2(A0),D1
                and.w   D0,D1
                cmp.w   #0,D1
                beq     weiter2
                or.w    #2,D2
weiter2:        move.w  4(A0),D1
                and.w   D0,D1
                cmp.w   #0,D1
                beq     weiter3
                or.w    #4,D2
weiter3:        move.w  6(A0),D1
                and.w   D0,D1
                cmp.w   #0,D1
                beq     weiter4
                or.w    #8,D2

weiter4:        mulu    #1680,D2
                lea     f,A2
                adda.w  D2,A2

; Abschnitt aus der Matrix

                lea     d_speich1,A1
                clr.l   D1
                move.w  (A1),D1
                mulu    #6,D1
                divu    #14,D1
                lsr.l   #4,D1
                lsr.l   #4,D1
                lsr.l   #4,D1
                lsr.l   #4,D1
                mulu    #84,D1
                adda.w  D1,A2
                lea     d_speich2,A1
                move.w  (A1),D1
                lsl.w   #4,D1
                lea     d_speich4,A1
                move.w  (A1),D2
                add.w   D2,D1
                mulu    #6,D1
                move.w  D1,D2
                divu    #14,D1
                lsr.l   #4,D1
                lsr.l   #4,D1
                lsr.l   #4,D1
                lsr.l   #4,D1
                mulu    #2,D1
                adda.w  D1,A2
                move.w  D2,D0
                lsr.w   #2,D0
                and.w   #$FFFE,D0
                and.w   #7,D2

; Maske uebertragen

                cmp.w   #0,D2
                bne     weiter5
                move.w  #0,D1
schleife_12:    move.w  D1,D2
                mulu    #480,D2
                move.w  (A2),D3
                lsl.w   #2,D3
                adda.w  #28,A2
                lea     d_0,A1
                adda.w  D0,A1
                adda.w  D2,A1
                or.w    D3,(A1)
                move.w  (A2),D3
                lsl.w   #2,D3
                adda.w  #28,A2
                lea     d_1,A1
                adda.w  D0,A1
                adda.w  D2,A1
                or.w    D3,(A1)
                move.w  (A2),D3
                lsl.w   #2,D3
                adda.w  #28,A2
                lea     d_2,A1
                adda.w  D0,A1
                adda.w  D2,A1
                or.w    D3,(A1)
                addq.w  #1,D1
                cmp.w   #6,D1
                bne     schleife_12
                bra     weiter8

weiter5:        cmp.w   #2,D2
                bne     weiter6
                clr.w   D1
schleife_13:    move.w  D1,D2
                mulu    #480,D2
                move.w  (A2),D3
                adda.w  #28,A2
                lea     d_0,A1
                adda.w  D0,A1
                adda.w  D2,A1
                or.w    D3,(A1)
                move.w  (A2),D3
                adda.w  #28,A2
                lea     d_1,A1
                adda.w  D0,A1
                adda.w  D2,A1
                or.w    D3,(A1)
                move.w  (A2),D3
                adda.w  #28,A2
                lea     d_2,A1
                adda.w  D0,A1
                adda.w  D2,A1
                or.w    D3,(A1)
                addq.w  #1,D1
                cmp.w   #6,D1
                bne     schleife_13
                bra     weiter8

weiter6:        cmp.w   #4,D2
                bne     weiter7
                clr.w   D1
schleife_14:    move.w  D1,D2
                mulu    #480,D2
                clr.l   D3
                move.w  (A2),D3
                move.w  D3,D4
                lsr.w   #2,D3
                and.w   #3,D4
                lsl.w   #6,D4
                adda.w  #28,A2
                lea     d_0,A1
                adda.w  D0,A1
                adda.w  D2,A1
                or.w    D3,(A1)
                adda.w  #2,A1
                or.w    D4,(A1)
                clr.l   D3
                move.w  (A2),D3
                move.w  D3,D4
                lsr.w   #2,D3
                and.w   #3,D4
                lsl.w   #6,D4
                adda.w  #28,A2
                lea     d_1,A1
                adda.w  D0,A1
                adda.w  D2,A1
                or.w    D3,(A1)
                adda.w  #2,A1
                or.w    D4,(A1)
                clr.l   D3
                move.w  (A2),D3
                move.w  D3,D4
                lsr.w   #2,D3
                and.w   #3,D4
                lsl.w   #6,D4
                adda.w  #28,A2
                lea     d_2,A1
                adda.w  D0,A1
                adda.w  D2,A1
                or.w    D3,(A1)
                adda.w  #2,A1
                or.w    D4,(A1)
                addq.w  #1,D1
                cmp.w   #6,D1
                bne     schleife_14
                bra     weiter8

weiter7:        clr.w   D1
schleife_15:    move.w  D1,D2
                mulu    #480,D2
                clr.l   D3
                move.w  (A2),D3
                move.w  D3,D4
                lsr.w   #4,D3
                and.w   #15,D4
                lsl.w   #4,D4
                adda.w  #28,A2
                lea     d_0,A1
                adda.w  D0,A1
                adda.w  D2,A1
                or.w    D3,(A1)
                adda.w  #2,A1
                or.w    D4,(A1)
                clr.l   D3
                move.w  (A2),D3
                move.w  D3,D4
                lsr.w   #4,D3
                and.w   #15,D4
                lsl.w   #4,D4
                adda.w  #28,A2
                lea     d_1,A1
                adda.w  D0,A1
                adda.w  D2,A1
                or.w    D3,(A1)
                adda.w  #2,A1
                or.w    D4,(A1)
                clr.l   D3
                move.w  (A2),D3
                move.w  D3,D4
                lsr.w   #4,D3
                and.w   #15,D4
                lsl.w   #4,D4
                adda.w  #28,A2
                lea     d_2,A1
                adda.w  D0,A1
                adda.w  D2,A1
                or.w    D3,(A1)
                adda.w  #2,A1
                or.w    D4,(A1)
                addq.w  #1,D1
                cmp.w   #6,D1
                bne     schleife_15

; naechsten Punkte

weiter8:        lea     d_speich3,A1
                move.l  (A1),D1
                lsr.w   #1,D1
                move.l  D1,(A1)
                lea     d_speich4,A1
                move.w  (A1),D1
                addq.w  #1,D1
                cmp.w   #16,D1
                bne     schleife_9
                lea     a_speich,A1
                move.l  (A1),D1
                addq.l  #8,D1
                move.l  D1,(A1)
                lea     d_speich2,A1
                move.w  (A1),D1
                addq.w  #1,D1
                cmp.w   #20,D1
                bne     schleife_10

; ... und drucken

                clr.w   D1
schleife_8:     lea     farb_1,A0
                move.w  #7,D0
                bsr     druck
                bsr     leer
                move.w  D1,D3
                mulu    #480,D3
                lea     d_0,A0
                adda.w  D3,A0
                move.w  #240,D0
                bsr     druck
                lea     farb_1,A0
                move.w  #7,D0
                bsr     druck
                bsr     leer
                move.w  D1,D3
                mulu    #480,D3
                lea     d_1,A0
                adda.w  D3,A0
                move.w  #240,D0
                bsr     druck
                lea     farb_2,A0
                move.w  #7,D0
                bsr     druck
                bsr     leer
                move.w  D1,D3
                mulu    #480,D3
                lea     d_2,A0
                adda.w  D3,A0
                move.w  #240,D0
                bsr     druck
                addq.w  #1,D1
                cmp.w   #6,D1
                bne     schleife_8

                lea     d_speich1,A1
                move.w  (A1),D1
                addq.w  #1,D1
                cmp.w   #200,D1
                bne     schleife_11

; Bild fertig -> Auswurf

                lea     auswurf,A0
                move.w  #5,D0
                bsr     druck

ende:           clr.w   -(SP)
                trap    #1
                rts

; Unterprogramme ------------------

; Oeffne Datei

open:           move.w  #0,-(SP)
                pea     filenam(PC)
                move.w  #$3D,-(SP)
                trap    #1
                addq.l  #8,SP
                lea     filedesc,A0
                move.w  D0,(A0)
                bmi     open_f
                rts
open_f:         pea     f_open(PC)
                bra     fehler

; Lese Datei

read:           move.l  A0,-(SP)
                move.l  D0,-(SP)
                move.w  filedesc,-(SP)
                move.w  #$3F,-(SP)
                trap    #1
                adda.l  #12,SP
                move.l  D0,(datei_l)
                tst.w   D0
                bmi     read_f
                rts
read_f:         pea     f_read(PC)
                bra     fehler

; Schliesse Datei

close:          move.w  D0,-(SP)
                move.w  #$3E,-(SP)
                trap    #1
                addq.l  #4,SP
                tst.w   D0
                bmi     close_f
                rts
close_f:        pea     f_close(PC)
                bra     fehler

; Falsche Datei(laenge)

datei_f:        pea     f_datei(PC)
                bra     fehler

; Drucker nicht bereit

drucker_f:      pea     f_drucker(PC)

fehler:         move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP
warte:          move.w  #7,-(SP)
                trap    #1
                addq.l  #2,SP
                cmp.w   #13,D0
                bne     warte
                bra     ende

; Linken Rand des Bildes verschieben

leer:           move.w  #30,D0
schleife_7:     movem.l D0-D1,-(SP)
                move.w  #0,-(SP)
                move.w  #5,-(SP)
                trap    #1
                addq.l  #4,SP
                movem.l (SP)+,D0-D1
                subq.w  #1,D0
                cmp.w   #0,D0
                bne     schleife_7
                rts

; Drucke D0 Zeichen ab Adresse A0

druck:          movem.l D0-D1/A0,-(SP)
                move.w  (A0),D1
                move.w  D1,-(SP)
                move.w  #5,-(SP)
                trap    #1
                addq.l  #4,SP
                movem.l (SP)+,D0-D1/A0
                adda.l  #2,A0
                subq.w  #1,D0
                cmp.w   #0,D0
                bne     druck
                rts

; Druckerfarbmasken erstellen

mask:           clr.w   D3
schleife_3:     clr.w   D4
schleife_2:     move.w  D3,D6
                lsl.w   #2,D6
                move.w  D6,D7
                move.w  D2,D6
                mulu    #80,D6
                add.w   D6,D7
                lea     m2,A1
                adda.w  D7,A1
                move.l  (A1),D6
                move.w  D4,D5
weiter10:       cmp.w   #13,D5
                beq     weiter9
                lsr.l   #1,D6
                addq.w  #1,D5
                bra     weiter10
weiter9:        and.w   #63,D6
                move.w  D4,D5
                lsl.w   #1,D5
                move.w  D5,D7
                move.w  D1,D5
                mulu    #28,D5
                add.w   D5,D7
                move.w  D3,D5
                mulu    #84,D5
                add.w   D5,D7
                move.w  D0,D5
                mulu    #1680,D5
                add.w   D5,D7
                lea     f,A2
                adda.w  D7,A2
                move.w  D6,(A2)
                addq.w  #1,D4
                cmp.w   #14,D4
                bne     schleife_2
                addq.w  #1,D3
                cmp.w   #20,D3
                bne     schleife_3
                rts

filename:       DC.L 0
position:       DC.W 0
filedesc:       DC.W 0
datei_l:        DC.L 0
a_speich:       DC.L 0
d_speich1:      DC.W 0
d_speich2:      DC.W 0
d_speich3:      DC.L 0
d_speich4:      DC.W 0
filenam:        DC.B 'PICTURE.PI1',0
f_open:         DC.B 'OPEN-Error',0,0
f_read:         DC.B 'READ-Error',0,0
f_close:        DC.B 'CLOSE-Error',0
f_datei:        DC.B 'Keine *.PI1-Datei',0
f_drucker:      DC.B 'Drucker nicht bereit',0,0
d_position:     DC.B 'Druckposition ( 1=oben ,'
                DC.B ' 2=unten ) ?          '
                DC.B 13,10,0,0
papier_ein:     DC.W 27,38,108,48,72
drucker_inst:   DC.W 27,42,114,45,51,85,27
                DC.W 42,116,51,48,48,82,27
                DC.W 42,98,48,89
farb_1:         DC.W 27,42,98,50,55,48,118
farb_2:         DC.W 27,42,98,50,55,48,87
auswurf:        DC.W 27,38,108,48,72
unten:          DC.W 27,38,97,51,52,82
filepos:        DC.W 0
filepos2:       DS.B 32
filepos3:       DS.B 32000
f:              DS.B 27000
d_0:            DS.B 2880
d_1:            DS.B 2880
d_2:            DS.B 2880
m2:             DC.L 0,0,0,0,0,0,0,0,0,0
                DC.L 0,0,0,0,0,0,0,0,0,0
                DC.L 524320,1024,32770,64,2048
                DC.L 65540,128,4096,131080,256
                DC.L 8192,262160,512,16385,524320
                DC.L 1024,32770,64,2048,65540
                DC.L 589860,1152,36866,131144
                DC.L 2304,73732,262288,4608
                DC.L 147465,524576
                DC.L 9216,294930,576,18433,589860
                DC.L 1152,36866,131144,2304,73732
                DC.L 593956,132232,37122,139336
                DC.L 264464,74244,278673,528928
                DC.L 148489,557346
                DC.L 9280,296978,66116,18561
                DC.L 593956,132232,37122,139336
                DC.L 264464,74244
                DC.L 594468,148617,561442,140360
                DC.L 297234,74308,280721,594468
                DC.L 148617,561442
                DC.L 140360,297234,74308,280721
                DC.L 594468,148617,561442,140360
                DC.L 297234,74308
                DC.L 594532,150665,626982,140488
                DC.L 301330,205388,280977,602660
                DC.L 410777,561954
                DC.L 156745,821554,75332,313491
                DC.L 594532,150665,626982,140488
                DC.L 301330,205388
                DC.L 733804,413081,635686,419033
                DC.L 826162,222797,838067,603748
                DC.L 445595,627558
                DC.L 158921,891190,206540,317843
                DC.L 733804,413081,635686,419033
                DC.L 826162,222797
                DC.L 1048575,1048575,1048575
                DC.L 1048575,1048575,1048575
                DC.L 1048575,1048575,1048575
                DC.L 1048575,1048575,1048575
                DC.L 1048575,1048575,1048575
                DC.L 1048575,1048575,1048575
                DC.L 1048575,1048575

                END
