
          ; Taktzyklen-Messung (von Gnther Donderer)
          ; Version fr Mono und kurzere Programme (ca. 1/90 Sekunde)

          moveq.l   #2,d0     ; Z„hler der Lesevorg„nge starten
          lea.l     datas(pc),a0        ; Zeiger auf Befehlscodes laden
again0:   move.w    (a0)+,pp  ; Befehle in Prog schreiben
          move.w    (a0)+,hh-6          ; (fr Start-, Endwert)
          move.w    d0,-(sp)  ; Z„hler und Zeiger
          pea       (a0)      ; auf Stack speichern

          pea       init      ; mit Supervisor-Mode
          move.w    #38,-(sp) ; in Test-Routine
          trap      #14       ; springen
          addq.l    #6,sp

          movea.l   (sp)+,a0  ; Z„hler und Zeiger wieder
          move.w    (sp)+,d0  ; aus Stack holen
          dbra      d0,again0 ; Schleife  dreimal durchlaufen

          ; !!! TZ ausgeben !!!

          lea.l     zahlen(pc),a0       ; Zeiger auf Mewerte laden
          lea.l     string+15(pc),a1    ; Zeiger auf String laden
          lea.l     ziff(pc),a2         ; Zifferntabellenzeiger laden
          subq.l    #4,4(a0)  ; zweiten Mewert angleichen
          move.l    (a0),d0   ; ersten Mewert laden
          sub.l     4(a0),d0  ; zweiten Mewert abziehen
          lsr.l     #1,d0     ; durch zwei teilen => Startwert
          move.b    0(a2,d0.w),27(a1)   ; Startwert in String schreiben
          move.l    (a0),d1   ; wieder ersten Wert laden
          sub.l     8(a0),d1  ; dritten Mewert abziehen
          lsr.l     #1,d1     ; durch zwei teilen => Endwert
          move.b    0(a2,d1.w),29(a1)   ; Endwert in String schreiben
          move.l    (a0),d2   ; wieder ersten Wert laden
          sub.l     d0,d2     ; Startwert abziehen
          sub.l     d1,d2     ; Endwert abziehen => Gesammtl„nge
          moveq.l   #4,d0     ; Nibblez„hler laden
          moveq.l   #12,d1    ; h”chstes benutztes Nibble auf
          rol.l     d1,d2     ; h”chste Position schieben
again1:   rol.l     #4,d2     ; erstes Nibble herschieben
          move.w    d2,d1     ; in anderes Register geben
          andi.w    #$f,d1    ; Nibble isolieren (fr Tabelle)
          move.b    0(a2,d1.w),(a1)+    ; Nibble in String schreiben
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

regs:     .DC.l 0,0,0,0,0,0,0,0         ; Dn
          .DC.l 0,0,0,0,0,0,0 ; An

ziff:     .DC.b "0123456789abcdef"

string:   .DC.b $1b,$45,"Taktzyklen: $"
          .DS.b 5
          .DC.b $a,$d,"Start und Endwert : x x",0

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
          beq       p2        ; wieder (low)
          moveq.l   #20,d1    ; Ungenauigkeiten in Timing ausgleichen
          sub.b     d0,d1
          rol.l     d1,d1
          lea.l     regs(pc),a0         ; Registerwerte fr zu
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
          .DCB.w 13,$4e71     ; zwischen den Lesevor-
          move.b    (a0),d3   ; g„ngen 68 TZ warten (low)
          move.b    (a1),d2   ; (mid)

          moveq.l   #0,d4     ; Index zun„chst l”schen
nochmal:  cmpi.b    #$fa,d1   ; testen, ob inzwischen
          bls       weiter1   ; šberlauf stattfand
          subq.b    #1,d0     ; gegebenenfalls ausgleichen
weiter1:  sub.b     (a2),d0   ; Mid-Wert-Differenz errechnen
          lsl.w     #8,d0     ; Platz fr Low-Wert machen
          move.b    d1,d0     ; Low-Wert dazuschreiben => Gesammtdifferenz
          ext.l     d0        ; fr Division erweitern
          divu      #80,d0    ; Division durch 80 => Anzahl der Zeilen + Rest
          swap.w    d0
          tst.w     d0        ; testen, ob im Rand (wenn Rest Null ist)
          bne       weiter2   ; sonst weiter
          move.b    d2,d0     ; aber wenn ja, dann die selbe Prozedur
          move.b    d3,d1     ; mit dem zweitem Wert durchfhren
          move.w    #68,d4    ; Index wird 68
          bra       nochmal
weiter2:  move.w    d0,d1     ; Rest in anderes Register
          add.w     d0,d1     ; und mal zwei => Tz in letzter Zeile
          swap.w    d0
          mulu      #224,d0   ; Zeilen mal 224 (pro Zeile 224 Tz)
          ext.l     d1
          add.l     d1,d0     ; beide Werte addieren
          sub.l     d4,d0     ; Index abziehen
          subi.l    #268,d0   ; Verschlei abziehen

          movea.l   zeiger(pc),a0       ; Zeiger fr Meergebnis laden
          move.l    d0,(a0)   ; Ergebnis speichern
          addq.l    #4,zeiger ; Zeiger auf n„chsten Wert stellen

          ; alles wiederherstellen

          move.w    #$2300,sr ; Interrupts wieder erlauben

          pea       bytes+1   ; Maus wieder einschalten
          clr.w     -(sp)
          move.w    #25,-(sp)
          trap      #14
          addq.l    #8,sp

          rts                 ; nun zur Textausgabe

          ; Speichervariablen

zeiger:   .DC.l zahlen
zahlen:   .DS.l 3

bytes:    .DC.b $12 ; Befehlsbyte fr Maus aus
          .DC.b $08 ; bzw. Maus ein

datas:    .DC.w $4e71,$4e71,$c140,$4e71
          .DC.w $4e71,$6004,$c140,$6004

