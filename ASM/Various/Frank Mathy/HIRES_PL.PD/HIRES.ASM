 SECTION S.GLOB

* Demoroutine zum Hirespac

start           bsr     screen_init     *Bildschirm initialisieren
                move.w  #200,d0         *Erste Line-Kooordinaten setzen
                move.w  #47,d1
                move.w  #120,d2
                move.w  #167,d3
                move.w  #1,color_plot   *Erste Farbe setzen
                move.w  #1,x1_richtung  *Bewegungsregister setzen
                move.w  #1,x2_richtung
                move.w  #1,y1_richtung
                move.w  #1,y2_richtung
st_loop         bsr     line            *Linie zeichnen
                add.b   #1,color_plot   *Farbe erh”hen
                and.b   #$f,color_plot  *Bits 4-7 ausblenden
                add.w   x1_richtung,d0  *Neue Punkte ermitteln
                add.w   y1_richtung,d1
                add.w   x2_richtung,d2
                add.w   y2_richtung,d3
                cmp.w   #319,d0         *Stožen Punkte an ?
                bcs.s   st_ok1
                bsr     runter_scroll   *Bildschirm runterscrollen
                neg.w   x1_richtung     *Richtung negieren
st_ok1          cmp.w   #319,d2
                bcs.s   st_ok2
                bsr     runter_scroll
                neg.w   x2_richtung
st_ok2          cmp.w   #199,d1
                bcs.s   st_ok3
                bsr     runter_scroll
                neg.w   y1_richtung
st_ok3          cmp.w   #199,d3
                bcs.s   st_ok4
                bsr     runter_scroll
                neg.w   y2_richtung
st_ok4          move.w  d0,-(sp)        *D0 sichern
                move.w  #$ff,-(sp)      *liegt Tastendruck vor?
                move.w  #6,-(sp)        *GEMDOS-Funktion 6 rawconio
                trap    #1
                addq.l  #4,sp           *Stack reparieren
                move.w  d0,d4           *Ergebnis kopieren
                move.w  (sp)+,d0        *D0 zurckholen
                tst.w   d4              *Ergebnis testen
                beq     st_loop         *Kein Tastendruck -> Schleife
                move.w  #1,-(sp)        *GEMDOS-Funktion 1
                trap    #1              *Aufrufen:Auf Taste warten
                addq.l  #2,sp           *Stack in Ordnung bringen
                clr.w   -(sp)           *GEMDOS-Fkt. 0 TERM
                trap    #1              *Beenden des Programmes

x1_richtung     dc.w    1
x2_richtung     dc.w    1
y1_richtung     dc.w    1
y2_richtung     dc.w    1



* Hires-Routinen fr den Atari ST
* Die Plot/Pixelabfrage-Routine ist speziell fr den 320x200 Grafikmodus
* geschrieben, die anderen (auch Line, wenn eine andere Plot-Routine
* aufgerufen wird) laufen auch in den anderen Modi

* Geschrieben von       Frank Mathy         (c) Januar 1986
*                       H.-Heine-Str. 20, 6200 Wiesbaden 13


* Setzen der Farbpalette

setze_farben    move.l  #farbpalette,-(sp)      *Adresse der Farbpalette
                move.w  #6,-(sp)                *XBIOS-Befehl setpalette
                trap    #14                     *Ausfhren des Befehls
                addq.l  #6,sp                   *Stackpointer korrigieren
                rts                             *Rckkehr

farbpalette     dc.w    $ffff,$ff88,$f8f8,$fda8,$f88f,$f8d8,$f88d,$fddd
                dc.w    $faaa,$f8ff,$f8dd,$fff8,$ff8f,$fdd8,$fd8d,$f888

* Setzen der Bildschirmparameter:
* Aufl”sung, physikalische und logische Bildschirmadresse

* Grafikmodi :  0 = 320*200 Pixels bei 16 Farben
*               1 = 640*200 Pixels bei 4  Farben
*               2 = 640*400 Pixels bei 2  Farben
*              -1 = nicht ver„ndern

* Adressen:     Wenn zu setzen, dann 4-Byte-Adresse
*               Wenn nicht zu setzen, dann -1

* Bei Aufruf :  D0 enth„lt physikalische Adresse/-1 (Longword-4 Bytes)
*               D1 enth„lt logische      Adresse/-1 (   "         "  )
*               D2 enth„lt Grafikmodusbefehl        (Byte)
               
screenpt        equ     $45e
v_bas_ad        equ     $44e        
sshiftmd        equ     $200

setscreen       tst.l   d0              *Wird physik. Adr. ge„ndert ?
                bmi.s   setb_1          *Nein -> weiter
                move.l  d0,physad       *Kopie der physikal. Bildschirmadr. 
                move.l  d0,screenpt     *Bei n„chstem VBL setzen
setb_1          tst.l   d1              *Wird log. Adr. ge„ndert ?
                bmi.s   setb_2          *Nein -> weiter
                move.l  d1,logad        *Kopie der logischen Bildschirmadr.
                move.l  d1,v_bas_ad     *Entspr. Systemvariable stellen
setb_2          tst.b   d2              *Wird Aufl”sung ge„ndert?
                bmi.s   setb_3          *Nein -> weiter
                clr.l   -(sp)           *Superv.-Stack-Pt.=User-Stack-Pt.
                move.w  #$20,-(sp)      *BIOS-Funktion $20 Super
                trap    #1              *BIOS-Aufruf
                add.l   #6,sp           *Stackpointer reparieren
                move.b  d2,$ff8260      *Aufl”sung setzen
                move.b  d2,sshiftmd     *Entspr. Systemvariable
                move.l  d0,-(sp)        *alter Supervisor-Stackpointer
                move.w  #$20,-(sp)      *Befehl Super
                trap    #1              *Aufruf
                add.l   #6,sp           *Stackpointer in Ordnung bringen
setb_3          rts                     *Das w„r's!

physad          ds.l    1               *Kopie der phys. Bildschirmadr.
logad           ds.l    1               *Kopie der log.  Bildschirmadr.


* Holen der physischen und logischen Bildschirmadresse und kopieren der
* Adressen in physad und logad, da auf diese im User-Mode zugegr.w.kann

hole_scrnparam  move.w  #2,-(sp)        *Befehl physbase
                trap    #14             *Aufrufen des XBIOS
                move.l  d0,physad       *Adresse kopieren
                move.w  #3,-(sp)        *Befehl logbase
                trap    #14             *Aufruf
                move.l  d0,logad        *Adresse kopieren
                addq.l  #4,sp           *Stackpointer reparieren
                rts                     *Ende der Routine

* Initialisieren aller verwendeten Parameter und Einstellungen
* Sollte beim Programmstart aufgerufen werden

screen_init     move.b  #0,d2
                move.l  #-1,d0
                move.l  #-1,d1
                bsr     setscreen
                bsr     setze_farben
                bsr.s   hole_scrnparam  *Kopien der Adressen
                move.w  #0,-(sp)        *Cursur ausschalten
                move.w  #21,-(sp)       *XBIOS-Funktion cursconf
                trap    #14
                addq.l  #4,sp           *Stackpointer zucksetzen
                bsr.s   screen_clear    *L”schen des Bildschirms
                rts

* L”schen des Bildschirms (logische Bildschirmadresse)

screen_clear    move.w  #7999,d0        *8000 Langw”rter zu l”schen
                movea.l logad,a0        *Pointer
scr_clr_loop    clr.l   (a0)+           *L”schen und Pointer erh”hen
                dbne    d0,scr_clr_loop *Schleife
                rts                     *Alles sauber...

* Plot-Routine, X/Y-Koordinaten in D0/D1(Wort), Farbe in color_plot (Byte)
* Wenn color_plot negativ (>$7f) dann wird die Farbe des entsprechenden
* Punktes auf der logischen Bildschirmseite geholt
* Die Farbe steht dann in color_plot (Byte)

plot            cmp.w   #320,d0         *x-Koordinate in zugel. Grenze?
                bcc.s   plot_ende       *Nein -> Ende
                cmp.w   #200,d1         *y-Koordinate in zugel. Grenze?
                bcc.s   plot_ende       *Nein -> Ende
                move.w  d0,d2           *x-Koordinate retten
                lsr.w   #1,d0           *d0=d0/2
                and.w   #$fff8,d0       *Bits 0-2 l”schen
                and.l   #$0000ffff,d0   *Damit Bits 16-31 auf 0
                mulu.w  #160,d1         *Y-Offset bestimmen:yoff=160*d1
                add.l   d1,d0           *d0=d0+y-Offset
                add.l   logad,d0        *Nun haben wir Zieladresse
                movea.l d0,a0           *Ins Adressregister damit
                move.w  #3,d1           *Bitz„hler
                and.w   #$0f,d2         *Bits 0-3 geben an, welches Bit
                eor.w   #$0f,d2         *Invertieren wegen Reihenfolge
                move.b  color_plot,d0   *Farbe in d0
                bmi.s   plot_get
plot_loop       move.w  (a0),d3
                lsr.b   #1,d0           *aktuel. Bit 0 d. Farbe ins Carry
                bcs.s   plot_1          *Branchen, wenn Carry=1
                bclr.l  d2,d3           *Entspr. Bit l”schen
                bra.s   plot_2          *Weiter
plot_1          bset.l  d2,d3           *Entspr. Bit setzen
plot_2          move.w  d3,(a0)+        *Zurckschreiben
                dbra    d1,plot_loop    *Erniedrigen und ggf. Schleife
plot_end        rts

* Farbe eines Pixels holen

plot_get        clr.b   color_plot      *Farbregister reinigen
pl_get_1        move.w  (a0)+,d0
                btst.l  d2,d0           *Bit testen
                bne.s   pl_get_2        *Gesetzt -> Verzweigen
                bclr.b  d1,color_plot   *Bit l”schen
                bra.s   pl_get_1        *Weiter an anderer Stelle
pl_get_2        bset.b  d1,color_plot   *Bit setzen
pl_get_3        dbra    d1,pl_get_1     *Erniedrigen und ggf. Schleife
                rts                     *Fertig


color_plot      ds.b     1


* Line-Routine, X1/Y1/X2/Y2 in D0/D1/D2/D3 (Wort)

line            movem.l d0-d7/a0,-(sp)  *Register in Sicherheit bringen
                move.w  d2,line_xend    *X2 retten
                move.w  d3,line_yend    *Y2 retten
                move.w  #1,d5           *X-Additionswert=1
                sub.w   d0,d2           *Delta X = X2-X1
                bpl.s   line_dxpos      *Delta X positiv -> weiter
                neg.w   d2              *Delta X negieren (dann positiv)
                move.w  #-1,d5          *X-Additionswert=-1
line_dxpos      clr.w   d4              *d4 ist der Z„hler
                tst.w   d2              *Delta X nochmal testen
                bne.s   lin_dxnnull     *Delta X <> 0 -> weiter
                move.w  #-1,d4          *Z„hler auf -1
lin_dxnnull     move.w  #1,d6           *Y-Additionswert=1
                sub.w   d1,d3           *Delta Y = Y2-Y1
                bpl.s   line_loop       *Delta Y positiv -> weiter
                neg.w   d3              *Delta Y negieren (dann positiv)
                move.w  #-1,d6          *Y-Additionswert=-1
line_loop       movem.w d0-d3,-(sp)     *Register retten
                bsr     plot            *Punkt setzen
                movem.w (sp)+,d0-d3     *Register zurckholen
                cmp.w   line_xend,d0    *Letzter x-Wert?
                bne.s   line_weiter     *Nein -> weiter
                cmp.w   line_yend,d1    *Auch letzter y-Wert?
                bne.s   line_weiter     *Nein -> weiter
                movem.l (sp)+,d0-d7/a0  *Alte Registerwerte wiederherst.
                rts                     *Line fertig, Rckkehr
line_weiter     tst.w   d4              *Testen des Z„hlers
                bmi.s   linneg          *Negativ -> Branch
                sub.w   d3,d4           *Z„hler=Z„hler-Delta y
                add.w   d5,d0           *X = X + x Additionswert
                bra.s   line_loop
linneg          add.w   d2,d4           *Z„hler=Z„hler+Delta x
                add.w   d6,d1           *Y = Y + y Additionswert
                bra.s   line_loop

line_xend       ds.w    1
line_yend       ds.w    1


* Soft-Scroll: Diese Routinen rollen den Bildschirm je um eine Bild-
* schirmzeile nach oben bzw. unten

hoch_scroll     movem.l d0/a0-a1,-(sp)
                movea.l logad,a0        *hierein wird kopiert
                movea.l logad,a1        *hieraus wird kopiert
                add.l   #160,a1         *deshalb muž a1 gr”žer sein
                move.w  #7959,d0        *so oft muž kopiert werden
sc_h_1          move.l  (a1)+,(a0)+     *kopieren
                dbra    d0,sc_h_1       *Z„hler erniedrigen, ggf. Schleife
                move.w  #39,d0          *so oft muž gel”scht werden
sc_h_2          clr.l   (a0)+           *l”schen
                dbra    d0,sc_h_2
                movem.l (sp)+,d0/a0-a1
                rts

runter_scroll   movem.l d0/a0-a1,-(sp)  *Register retten
                movea.l logad,a1        *hieraus wird kopiert
                add.l   #31840,a1       *da von unten kopiert wird
                movea.l a1,a0           *hierein wird kopiert
                add.l   #160,a0         *deshalb muž a0 gr”žer sein
                move.w  #7959,d0        *so oft muž kopiert werden
sc_r_1          move.l  -(a1),-(a0)     *kopieren
                dbra    d0,sc_r_1
                move.w  #39,d0          *so oft muž gel”scht werden
sc_r_2          clr.l   -(a0)           *l”schen
                dbra    d0,sc_r_2
                movem.l (sp)+,d0/a0-a1
                rts

 END

