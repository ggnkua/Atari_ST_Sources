
          ; Taktzyklen-Messung (von Gnther Donderer)
          ; Version fr Farbe und l„ngere Programme (ca. 4 Sekunden)

          pea       init      ; mit Supervisor-Mode
          move.w    #38,-(sp) ; in Test-Routine
          trap      #14       ; springen
          addq.l    #6,sp     ;

          ; !!! TZ ausgeben !!!

          lea.l     string+15(pc),a1    ; Stringzeiger laden
          lea.l     ziff(pc),a2         ; Zifferntabellenzeiger laden
          move.l    zahl,d2   ; Mewert laden
          moveq.l   #6,d0     ; Nibblez„hler laden
          rol.l     #4,d2     ; h”chstes benutztes Nibble hoch
again1:   rol.l     #4,d2     ; Nibble herschieben
          move.w    d2,d1     ; und in anderes Register
          andi.w    #$f,d1    ; Nibble isolieren (wegen Tabelle)
          move.b    0(a2,d1.w),(a1)+    ; Zeichen in String schreiben
          dbra      d0,again1 ; bis letztes Nibble geschreiben

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
          .DCB.b 9,0

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
          lea.l     $fffa07,a3          ; Interrupt Enable A
          lea.l     $fffa1b,a4          ; Timer B Control Reg
          lea.l     $fffa21,a5          ; Timer B Data Reg

          andi.b    #$fe,(a3) ; Interrupt fr Timer B aus
          clr.b     (a4)      ; Timer B stoppen
          move.b    #201,(a5) ; Timer B auf Anfangswert 201

          move.b    (a2),d0   ; testen, ob Bildschirm-
p1:       tst.b     (a0)      ; anfang erreicht
          bne.s     p1        ; (low)
          cmp.b     (a1),d0
          bne.s     p1        ; (mid)
p2:       move.b    (a0),d0
          tst.b     d0
          beq.s     p2        ; (wieder low)

          move.b    #8,(a4)   ; Timer B als Ereignisz„hler init

          moveq.l   #20,d1    ; Ungenauigkeiten im Timing ausgleichen
          sub.b     d0,d1
          rol.l     d1,d1
          lea.l     regs(pc),a0         ; Startregister fr zu
          movem.l   (a0),d0-d7/a0-a6    ; testende Routine lesen

          ; zu testendes Programm !!!

          .INCLUDE "PROG.IS"

          ; weiter

          lea.l     $ff8209,a0          ; Video-Count low
          lea.l     $ff8207,a1          ; Video-Count mid
          lea.l     $ff8203,a2          ; Video-Ram mid
          lea.l     $fffa1b,a3          ; Timer B Control Reg
          lea.l     $fffa21,a4          ; Timer B Data Reg

          moveq.l   #0,d5     ; Index2 wird zun„chst 0
wieder:   move.b    (a0),d1   ; Video-Counter lesen (low)
          move.b    (a1),d0   ; (mid)
          .DCB.w 45,$4e71     ; zwischen den Lesevor-
          move.b    (a0),d3   ; g„ngen 196 TZ warten (low)
          move.b    (a1),d2   ; (mid)

          moveq.l   #0,d4     ; Index1 wird zun„chst 0
nochmal:  cmpi.b    #$fa,d1   ; testen, ob inzwischen
          bls.s     weiter1   ; šberlauf stattfand
          subq.b    #1,d0     ; gegebenenfalls ausgleichen
weiter1:  sub.b     (a2),d0   ; Mid-Differenz errechnen
          lsl.w     #8,d0     ; Platz fr Low-Wert machen
          move.b    d1,d0     ; in anderes Register schreiben
          ext.l     d0        ; fr Division erweitern
          divu      #160,d0   ; testen, ob Messung im Rand war
          tst.w     d0        ; Zeitunterschiede bei Division
          beq.s     h1        ; ausgleichen (wenn obere H„lfte des
          nop                 ; Bildschirms anfing, dauert sie aufgrund
          nop                 ; eines anderen Zieloperanden 4 Tz mehr)
h1:       swap.w    d0
          tst.w     d0
          bne.s     weiter2
          tst.w     d4        ; wenn ja, dann testen, ob bereits
          bne.s     rand      ; der 2. Wert getestet wurde
          move.b    d2,d0     ; sonst wird dieselbe Prozedur
          move.b    d3,d1     ; mit dem zweitem Wert durchgefhrt
          move.w    #196,d4   ; Index1 wird 196
          bra       nochmal

rand:     moveq.l   #-1,d0    ; warten, bis Rand sicher zuende
          .DCB.w 432,$e078    ; Dummy: Rol.w D0,D0 => 432*132 Taktzyklen
          .DCB.w 15,$4e71     ; Dummy: Nop => 15*4 Taktzyklen
          move.l    #57856,d5 ; Index2 wird 57856
          bra       wieder    ; Messungen wiederholen

weiter2:  move.b    (a2),d2   ; testen, ob n„chster
p3:       tst.b     (a0)      ; Bildschirmanfang erreicht
          bne       p3        ; (low)
          cmp.b     (a1),d2
          bne       p3        ; (mid)
p4:       move.b    (a0),d2
          tst.b     d2
          beq       p4        ; wieder (low)

          move.b    (a4),d2   ; Seitenzahl lesen
          subq.w    #1,d2
          andi.w    #$ff,d2
          mulu      #626,d2
          lsl.l     #8,d2     ; => 160256 Tz pro Seite

          move.w    d0,d1
          add.w     d0,d1     ; => Tz in letzter Zeile
          swap.w    d0
          mulu      #512,d0   ; => 512 TZ pro Zeile
          ext.l     d1
          add.l     d1,d0     ; beide Werte addieren
          sub.l     d4,d0     ; Index1 abziehen
          sub.l     d5,d0     ; Index2 abziehen
          add.l     d2,d0     ; Index3 zuz„hlen
          subi.l    #296,d0   ; Verschlei abziehen

          lea.l     zahl(pc),a0         ; Ergebniszeiger laden
          move.l    d0,(a0)   ; Ergebnis speichern

          ; alles wiederherstellen

          clr.b     (a3)      ; Timer B stoppen
          move.w    #$2300,sr ; Interrupts wieder erlauben

          pea       bytes+1   ; Maus wieder einschalten
          clr.w     -(sp)
          move.w    #25,-(sp)
          trap      #14
          addq.l    #8,sp

          rts                 ; nun zur Textausgabe

          ; Speichervariablen

zahl:     .DC.l 0

bytes:    .DC.b $12 ; Befehlsbyte fr Maus aus
          .DC.b $08 ; bzw. Maus ein

