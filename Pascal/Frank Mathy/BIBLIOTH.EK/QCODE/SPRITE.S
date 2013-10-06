* Setzen eines 16-farbigen Sprites und vorheriges saven des Inhaltes
* Aufruf mit fsetsprite(x,y,sprite,savebuffer,logbase,clipping,hoehe)
* <sprite> zeigt auf die Spritedaten (5*16 Worte).
* <savebuffer> ist ein Speicherraum zum retten des alten Bildschirminhaltes
* an der entsprechenden Stelle. Muž 12+Zeile*16 Bytes grož sein.
* <hoehe> gibt die H”he des Sprites an (<hoehe> = H”he-1)



.xdef _fsetsprite
.text
_fsetsprite:            movem.l d0-d7/a0-a3,-(a7) *Register retten

                        movea.l 68(a7),a1       *Zeiger auf Clipping-Feld
                        movea.l 56(a7),a2       *Zeiger auf Spritedaten
                        movea.l 60(a7),a3       *Zeiger auf Savebuffer
                        move.w  52(a7),d0       *x_Wert laden
                        move.w  d0,d1           *kopieren
                        add.w   #16,d1          *N„chstes Wort
                        move.w  0(a1),d2        *Clip_x1
                        move.w  4(a1),d3        *Clip_x2
                        and.w   #$fff0,d0       *Wort ermitteln
                        and.w   #$fff0,d1
                        and.w   #$fff0,d2
                        and.w   #$fff0,d3

                        cmp.w   d1,d2           *Wort(Clip_x1) > Wort(x+16) ?
                        bgt     ss_j5           *Ja --> Ende
                        cmp.w   d0,d3           *Wort(Clip_x2) < Wort(x) ?
                        blt     ss_j5           *Ja --> Ende

                        move.w  #$ffff,w1_mask  *Maske setzen
                        move.w  #$ffff,w2_mask
                        clr.w   w1_set          *Auf True setzen
                        clr.w   w2_set          *Auf True setzen

                        cmp.w   d0,d2           *Wort(Clip_x1) < Wort(x) ?
                        blt.s   ss_c2           *Ja --> Weiter

                        bne.s   ss_c1           *Ungleich --> Weiter

                        move.w  0(a1),d4        *Clip_x1 laden
                        and.w   #$f,d4          *Bitnummer
                        asl.w   #1,d4           *mal 2, da Wortetabelle
                        lea     atab,a0         *Zeiger auf Tabelle
                        move.w  0(a0,d4.w),d4   *Wert laden
                        move.w  d4,w1_mask      *ablegen
                        bra.s   ss_c2           *Weiter

ss_c1:                  move.w  #-1,w1_set      *Auf false setzen
                        move.w  0(a1),d4        *Clip_x1 laden
                        and.w   #$f,d4          *Bitnummer
                        asl.w   #1,d4           *mal 2,da Wortetabelle
                        lea     atab,a0         *Zeiger auf Tabelle
                        move.w  0(a0,d4.w),d4   *Wert laden
                        move.w  d4,w2_mask      *ablegen

ss_c2:                  cmp.w   d1,d3           *Wort(Clip_x2) > Wort(x+16)
                        bgt.s   ss_j1           *Ja --> Weiter

                        bne.s   ss_c3           *Ungleich --> Weiter

                        move.w  4(a1),d4        *Clip_x2 laden
                        and.w   #$f,d4          *Bitnummer
                        asl.w   #1,d4           *mal 2, da Wortetabelle
                        lea     etab,a0         *Zeiger auf Tabelle
                        move.w  0(a0,d4.w),d4   *Wert laden
                        and.w   d4,w2_mask      *ablegen
                        bra.s   ss_j1           *Weiter

ss_c3:                  move.w  #-1,w2_set      *Auf false setzen
                        move.w  4(a1),d4        *Clip_x2 laden
                        and.w   #$f,d4          *Bitnummer
                        asl.w   #1,d4           *mal 2, da Wortetabelle
                        lea     etab,a0         *Zeiger auf Tabelle
                        move.w  0(a0,d4.w),d4   *Wert laden
                        and.w   d4,w1_mask      *ablegen

ss_j1:                  move.w  w1_mask,w1_imask  *kopieren
                        not.w   w1_imask          *invertieren
                        move.w  w2_mask,w2_imask  *kopieren
                        not.w   w2_imask          *invertieren

                        movea.l 64(a7),a0       *Logbase laden
                        move.w  52(a7),d0       *x laden
                        move.w  54(a7),d1       *y laden
                        move.w  d0,(a3)+        *In Save_Buffer schreiben
                        move.w  d1,(a3)+
                        move.w  w1_set,(a3)+    *Merken
                        move.w  w2_set,(a3)+
                        move.w  2(a1),(a3)+     *Clipping retten
                        move.w  6(a1),(a3)+
                        muls    #160,d1         *y_Offset
                        adda.l  d1,a0           *hinzuaddieren
                        asr.w   #1,d0           *x_Offset / 2
                        and.l   #$fff8,d0       *Bits 0-2 l”schen
                        adda.l  d0,a0           *hinzuaddieren
                        move.w  52(a7),d0       *x laden
                        and.w   #$f,d0          *Bits 0-3 holen
                        move.w  54(a7),d1       *y laden
                        move.w  72(a7),d7       *Z„hler laden

ss_j2:                  cmp.w   6(a1),d1        *y > Clip_Y2 ?
                        bgt     ss_j5           *Ja --> Ende
                        clr.l   d2              *L”schen
                        clr.l   d3
                        clr.l   d4
                        clr.l   d5
                        clr.l   d6
                        move.w  (a2)+,d2
                        move.w  (a2)+,d3
                        move.w  (a2)+,d4
                        move.w  (a2)+,d5
                        move.w  (a2)+,d6

                        cmp.w   2(a1),d1        *y >= Clip_y1 ?
                        blt     ss_j4           *Nein --> Weiter

                        not.l   d6              *Maske invertieren

                        tst.w   d0              *d0 = 0 ?
                        beq.s   ss_norot        *Ja --> Weiter

                        ror.l   d0,d2           *Rechtsrotieren
                        ror.l   d0,d3
                        ror.l   d0,d4
                        ror.l   d0,d5
                        ror.l   d0,d6

ss_norot:               tst.w   w1_set          *Wort zu setzen ?
                        bmi     ss_j3           *Nein --> Weiter

                        and.w   w1_mask,d2      *x-Clipping
                        and.w   w1_mask,d3
                        and.w   w1_mask,d4
                        and.w   w1_mask,d5
                        or.w    w1_imask,d6

                        move.l  0(a0),(a3)+     *Alten Inhalt retten
                        move.l  4(a0),(a3)+

                        and.w   d6,0(a0)        *Mit Maske verknpfen
                        or.w    d2,0(a0)        *Farbe setzen
                        and.w   d6,2(a0)
                        or.w    d3,2(a0)
                        and.w   d6,4(a0)
                        or.w    d4,4(a0)
                        and.w   d6,6(a0)
                        or.w    d5,6(a0)

ss_j3:                  swap    d2              *Registerh„lften tauschen
                        swap    d3
                        swap    d4
                        swap    d5
                        swap    d6

                        tst.w   d0              *Am Wortanfang?
                        beq.s   ss_j4           *Ja --> Weiter
                        tst.w   w2_set          *Wort zu setzen ?
                        bne.s   ss_j4           *Nein --> Weiter

                        move.l  8(a0),(a3)+     *Alten Inhalt retten
                        move.l  12(a0),(a3)+

                        and.w   w2_mask,d2      *Clipping
                        and.w   w2_mask,d3
                        and.w   w2_mask,d4
                        and.w   w2_mask,d5
                        or.w    w2_imask,d6

                        and.w   d6,8(a0)        *setzen
                        or.w    d2,8(a0)
                        and.w   d6,10(a0)
                        or.w    d3,10(a0)
                        and.w   d6,12(a0)
                        or.w    d4,12(a0)
                        and.w   d6,14(a0)
                        or.w    d5,14(a0)

ss_j4:                  addq.w  #1,d1           *y erh”hen
                        add.l   #160,a0         *Adresse erh”hen
                        dbra    d7,ss_j2        *Zurck

ss_j5:                  movem.l (a7)+,d0-d7/a0-a3 *Register holen
ss_end:                 rts                     *Ende

* L”schen eines gesetzten Sprites
* Aufruf: fclrsprite(savebuffer,logbase,hoehe)


.xdef _fclrsprite
.text
_fclrsprite:            movem.l d0-d2/a0-a1,-(a7) *Register retten
                        movea.l 24(a7),a1       *Zeiger auf Savepuffer
                        movea.l 28(a7),a0       *Logbase laden
                        move.w  (a1)+,d0        *x_Position laden
                        move.w  d0,d1           *kopieren
                        and.w   #$f,d0          *Bitnummer holen
                        lsr.w   #1,d1           *x / 2
                        and.l   #$fff8,d1       *Bits 0 bis 2 aus
                        adda.l  d1,a0           *hinzuaddieren
                        move.w  (a1),d1         *y_Position laden
                        muls    #160,d1         *y_Offset errechnen
                        adda.l  d1,a0           *hinzuaddieren

                        move.w  (a1)+,d1        *y_Position laden
                        move.w  (a1)+,w1_set    *Setz-Flags holen
                        move.w  (a1)+,w2_set
                        move.w  (a1)+,sy1       *Clipping-Daten holen
                        move.w  (a1)+,sy2
                        move.w  32(a7),d2       *Z„hler fr Zeilen

cs_j1:                  cmp.w   sy2,d1          *y > Clip_Y2 ?
                        bgt     cs_j4           *Ja --> Ende
                        cmp.w   sy1,d1          *y >= Clip_Y1 ?
                        blt     cs_j3           *Nein --> Weiter

                        tst.w   w1_set          *Wort 1 setzen ?
                        bmi.s   cs_j2           *Nein --> Weiter

                        move.l  (a1)+,0(a0)     *Alten Inhalt restaurieren
                        move.l  (a1)+,4(a0)

cs_j2:                  tst.w   w2_set          *Wort 2 setzen ?
                        bmi.s   cs_j3
                        tst.w   d0              *d0 == 0 ?
                        beq.s   cs_j3           *Ja --> Weiter

                        move.l  (a1)+, 8(a0)    *Alten Inhalt restaurieren
                        move.l  (a1)+,12(a0)

cs_j3:                  addq.w  #1,d1           *y erh”hen
                        adda.l  #160,a0         *Zeiger erh”hen
                        dbra    d2,cs_j1

cs_j4                   movem.l (a7)+,d0-d2/a0-a1 *Register holen
                        rts

.bss

sy1:
w1_mask:                ds.w    1
sy2:
w1_imask:               ds.w    1

w2_mask:                ds.w    1
w2_imask:               ds.w    1

w1_set:                 ds.w    1
w2_set:                 ds.w    1

.data

atab:                   dc.w    %1111111111111111
                        dc.w    %0111111111111111
                        dc.w    %0011111111111111
                        dc.w    %0001111111111111
                        dc.w    %0000111111111111
                        dc.w    %0000011111111111
                        dc.w    %0000001111111111
                        dc.w    %0000000111111111
                        dc.w    %0000000011111111
                        dc.w    %0000000001111111
                        dc.w    %0000000000111111
                        dc.w    %0000000000011111
                        dc.w    %0000000000001111
                        dc.w    %0000000000000111
                        dc.w    %0000000000000011
                        dc.w    %0000000000000001

etab:                   dc.w    %1000000000000000
                        dc.w    %1100000000000000
                        dc.w    %1110000000000000
                        dc.w    %1111000000000000
                        dc.w    %1111100000000000
                        dc.w    %1111110000000000
                        dc.w    %1111111000000000
                        dc.w    %1111111100000000
                        dc.w    %1111111110000000
                        dc.w    %1111111111000000
                        dc.w    %1111111111100000
                        dc.w    %1111111111110000
                        dc.w    %1111111111111000
                        dc.w    %1111111111111100
                        dc.w    %1111111111111110
                        dc.w    %1111111111111111

