
          ; Taktzyklen-Messung (von Gnther Donderer)
          ; Version fr Farbe und kurze Programme (ca. 1/80 Sekunde)

          moveq.l   #2,d0     ; Z„hler der Lesevorg„nge (drei Stck)
          lea.l     datas,a0  ; Zeiger auf Befehlscodes
again0:   move.w    (a0)+,pp  ; Befehle in Prog schreiben
          move.w    (a0)+,hh-6
          move.w    d0,-(sp)  ; Z„hler und Zeiger auf Stack
          pea       (a0)

          pea       init      ; mit Supervisor-Mode
          move.w    #38,-(sp) ; in Test-Routine springen
          trap      #14
          addq.l    #6,sp

          movea.l   (sp)+,a0  ; Z„hler und Zeiger
          move.w    (sp)+,d0  ; aus Stack zurck
          dbra      d0,again0 ; Schleife wiederholen

          ; !!! TZ ausgeben !!!

          lea.l     zahlen,a0 ; Ergebniszeiger laden
          lea.l     string+15(pc),a1    ; Zahlenstringzeiger laden
          lea.l     ziff(pc),a2         ; Zifferntabelle laden
          subq.l    #4,4(a0)  ; zweiten Mewert angleichen
          move.l    (a0),d0   ; ersten Mewert laden
          sub.l     4(a0),d0  ; zweiten Mewert abziehen
          lsr.l     #1,d0     ; durch zwei => Startwert
          move.b    0(a2,d0.w),27(a1)   ; Startwert in String schreiben
          move.l    (a0),d1   ; nochmal ersten Wert laden
          sub.l     8(a0),d1  ; zweiten Mewert abziehen
          lsr.l     #1,d1     ; durch zwei => Endwert
          move.b    0(a2,d1.w),29(a1)   ; Endwert in String schreiben
          move.l    (a0),d2   ; nochmal ersten Wert lesen
          sub.l     d0,d2     ; Startwert abziehen
          sub.l     d1,d2     ; Endwert abziehen => Gesammtl„nge
          moveq.l   #4,d0     ; Ziffernz„hler laden
          moveq.l   #12,d1    ; h”chstes benutztes Nibble
          rol.l     d1,d2     ; auf oberstes Nibble schieben
again1:   rol.l     #4,d2     ; zu berarbeitendes Nibble holen
          move.b    d2,d1     ; in anderes Register kopieren
          andi.w    #$f,d1    ; Nibble isolieren (wegen Tabelle)
          move.b    0(a2,d1.w),(a1)+    ; Zeichen in String schreiben
          dbra      d0,again1 ; fnf Nibbles schreiben

          pea       string    ; String ausgeben
          move.w    #9,-(sp)
          trap      #1
          addq.l    #6,sp

          move.w    #8,-(sp)  ; auf Taste warten
          trap      #1
          addq.l    #2,sp

          clr.w     -(sp)     ; Ende
          trap      #1

ziff:     .DC.b "0123456789abcdef"

string:   .DC.b $1b,$45,"Taktzyklen: $"
          .DS.b 5
          .DC.b $a,$d,"Start und Endwert : x x",0

regs:     .DC.l 0,0,0,0,0,0,0,0         ; Dn
          .DC.l 0,0,0,0,0,0,0 ; An

          ; Initialisieren

init:     pea       bytes     ; Mausabfrage ausschalten
          clr.w     -(sp)
          move.w    #25,-(sp)
          trap      #14
          addq.l    #8,sp

          move.w    #$2700,sr ; Interrupts ausschalten

          ; Testroutine

          lea.l     $ff8209,a0          ; Video-Count low
          lea.l     $ff8207,a1          ; Video-Count mid
          lea.l     $ff8203,a2          ; Video-Ram mid

          move.b    (a2),d0   ; testen, ob Bildschirm-
p1:       tst.b     (a0)      ; anfang erreicht
          bne       p1        ; (low)
          cmp.b     (a1),d0
          bne       p1        ; (mid)
p2:       move.b    (a0),d0
          tst.b     d0
          beq       p2        ; (wieder low)
          moveq.l   #20,d1    ; Ungenauigkeiten der
          sub.b     d0,d1     ; Position ausgleichen
          rol.l     d1,d1
          lea.l     regs(pc),a0         ; Startregister fr zu
          movem.l   (a0),d0-d7/a0-a6    ; testende Routine lesen

pp:       nop                 ; nop/exg

          ; zu testendes Programm !!!



          ; weiter

          nop                 ; nop/bra
          nop       
          nop       

hh:       lea.l     $ff8209,a0          ; Video-Count low
          lea.l     $ff8207,a1          ; Video-Count mid
          lea.l     $ff8203,a2          ; Video-Ram mid

          move.b    (a0),d1   ; Video-Counter lesen (low)
          move.b    (a1),d0   ; (mid)
          .DCB.w 45,$4e71     ; zwischen den Lesevorg„ngen
          move.b    (a0),d3   ; 196 TZ warten (low)
          move.b    (a1),d2   ; (mid)

          moveq.l   #0,d4     ; Index zun„chst 0
nochmal:  cmpi.b    #$fa,d1   ; testen, ob inzwischen
          bls       weiter1   ; šberlauf stattfand
          subq.b    #1,d0     ; gegebenenfalls ausgleichen
weiter1:  sub.b     (a2),d0   ; Mid-Differenz errechnen
          lsl.w     #8,d0     ; fr Low-Wert Platz machen
          move.b    d1,d0     ; => Gesammtdifferenz
          ext.l     d0        ; Wert fr Division erweitern
          divu      #160,d0   ; testen, ob Messung im Rand war
          swap.w    d0
          tst.w     d0
          bne       weiter2
          move.b    d2,d0     ; wenn ja, dann dieselbe Prozedur
          move.b    d3,d1     ; mit dem zweitem Mewert
          move.w    #196,d4   ; Index wird 196
          bra       nochmal
weiter2:  move.w    d0,d1     ; Divisionsrest in anderes Register
          add.w     d0,d1     ; und mal zwei => Tz in letzter Zeile
          swap.w    d0        ; Ganzzahliges Ergebnis mit
          mulu      #512,d0   ; 512 multiplizieren
          ext.l     d1
          add.l     d1,d0     ; beide Werte addieren => Taktzyklen
          sub.l     d4,d0     ; Index abziehen
          subi.l    #268,d0   ; Messungs-Verschlei abziehen

          movea.l   zeiger(pc),a0       ; Ergebniszeiger laden
          move.l    d0,(a0)   ; Ergebnis speichern
          addq.l    #4,zeiger ; Zeiger erh”hen

          ; alles wiederherstellen

          move.w    #$2300,sr ; Interrupts wieder erlauben

          pea       bytes+1   ; Maus wieder einschalten
          clr.w     -(sp)
          move.w    #25,-(sp)
          trap      #14
          addq.l    #8,sp

          rts                 ; nun zurck zur Textausgabe

          ; Speichervariablen

zeiger:   .DC.l zahlen
zahlen:   .DS.l 3

bytes:    .DC.b $12 ; Befehlsbyte fr Maus aus
          .DC.b $08 ; bzw. Maus ein

datas:    .DC.w $4e71,$4e71,$c140,$4e71
          .DC.w $4e71,$6004,$c140,$6004

