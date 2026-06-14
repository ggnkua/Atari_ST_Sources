
**************************************************************
* Programm fhrt einen Reset aus, wenn Ctrl-Alternate-Delete *
* gedrckt werden.                                           *
* Bei Ctrl-Alternate-(right!)Shift-Delete wird ein Kaltstart *
* ausgefhrt!                                                *
**************************************************************
* (C)1988 Stefan Becker                                      *
**************************************************************

nvbls     equ       $454                * Anzahl VBL-Routinen
vblqueue  equ       $456                * VBL-Routinen-Liste
osbase    equ       $4f2                * Systemvariable osbase
stacksize equ       500                 * Programm-Stackgr”že

del       equ       $53                 * Scancode der Delete-Taste

bconin    equ       2
cconws    equ       9
supexec   equ       38
ptermres  equ       $31

basepag   equ       4                   * Basepage-Konstanten:
text_sg   equ       12
data_sg   equ       20
bss_sg    equ       28

          move.l    basepag(a7),a0      * Startadresse des Programms nach a0
          clr.l     d0
          move.w    #$100,d0            * Programml„nge: 256 Bytes Base-Page
          add.l     text_sg(a0),d0      * + L„nge des Text-Segments
          add.l     data_sg(a0),d0      * + L„nge des Data-Segments
          add.l     bss_sg(a0),d0       * + L„nge des BSS-Segments
          move.l    d0,bedarf           * Speicherbedarf merken
          lea       stack(pc),a0        * Stack setzen...
          adda.w    #stacksize,a0       * (auf stack+stacksize)
          move.l    a0,a7

          bsr.s     calcadr             * Keyboard-Code-Adresse berechnen
          bsr.s     initvbl             * VBL-Routine einh„ngen

          clr.w     -(a7)               * Return-Code 0
          move.l    bedarf(pc),-(a7)    * Speicherbedarf
          move.w    #ptermres,-(a7)     * Ptermres
          trap      #1                  * ausfhren => Programmende

***************************
* Fhre einen Reset durch *
***************************

reset:    move.l    4,a0
          jmp       (a0)                * Reset, Bumm!

***********************************
* Berechne die Keyboard-Scancode- *
* und Keyboardshift-Adresse       *
***********************************

calcadr:  pea       calmain(pc)
          move.w    #supexec,-(a7)
          trap      #14
          addq.l    #6,a7
          rts

calmain:  move.l    osbase,a0           * Start des Betriebssystems
          move.l    a0,a1
          move.l    $24(a0),a0          * Adresse von KBSHIFT ab Blitter-Tos
          cmpi.b    #$86,$1b(a1)        * altes Tos von 86 ?
          bne.s     newtos
          move.l    #$e1b,a0            * bei altem Tos undocum. Kbshift e1b
newtos:   move.l    a0,kbshift          * Adresse Kbshift merken
          adda.w    #$1e,a0
          move.l    a0,kbscan           * Adresse von Scancode merken
          rts

**********************************************
* H„nge die VBL-Routine in den Interrupt ein *
**********************************************

initvbl:  clr.w     erfolg              * erfolg=0
          pea       inmain(pc)          * inmain in S-Mode starten
          move.w    #supexec,-(a7)
          trap      #14
          addq.l    #6,a7
          cmp.w     #0,erfolg           * erfolg=0?
          bne.s     instok              * Nein: O.K.

          pea       insterr(pc)         * Fehlermeldung rausleiern
          move.w    #cconws,-(a7)
          trap      #1
          addq.l    #6,a7

          move.w    #2,-(a7)            * Bconin(2)
          move.w    #bconin,-(a7)
          trap      #13
          addq.l    #4,a7
          clr.w     -(a7)               * Programm abbrechen
          trap      #1

instok:   pea       message(pc)
          move.w    #cconws,-(a7)
          trap      #1
          addq.l    #6,a7
          rts

inmain:   move.l    #vblqueue,a0        * VBL-Queue abklappern
          move.l    (a0),a0
          clr.l     d0
          move.w    nvbls,d0
          move.l    d0,d1
          subq.w    #1,d0               * d0=nvbls-1 (Z„hler)
          asl.l     #2,d1
          adda.l    d1,a0               * a0=nvbls*4+vblqueue
search:   cmp.l     #0,-(a0)            * freier Slot?
          beq.s     found               * Ja => Einh„ngen
          dbf       d0,search           * weitersuchen
          rts                           * Nix frei!
found:    lea       vbl(pc),a1
          move.l    a1,(a0)             * "vbl" einklinken
          move.w    #1,erfolg           * Flagge: Erfolg (Jauchz!)
          rts

***************
* VBL-Routine *
***************

vbl:      move.l    kbscan(pc),a0       * Lese akt. Scancode
          move.b    (a0),d0
          cmp.b     #del,d0             * Delete-Taste?
          bne.s     nixlos
          move.l    kbshift(pc),a0      * Keyboardshift:
          move.b    (a0),d0
          cmp.b     #%1100,d0           * ? CTRL-ALT
          beq       reset
          cmp.b     #%1101,d0           * ? CTRL-ALT-RightSHIFT
          beq.s     coldboot
nixlos:   rts

*******************************
* Fhre einen Kaltstart durch *
*******************************

coldboot: move      #$2700,sr           * Interrrupts sperren
          suba.l    a0,a0               * Folgenden Befehl vorbereiten (a0=0)
          move.l    4(a0),8(a0)         * Bus-Error:=Reset!
          lea       clear(pc),a0        * Clear-Routine nach 12 kopieren...
          move.l    #12,a1
          move.w    #(clrend-clear-1),d0 * L„nge der Clear-Routine berechnen
copyloop: move.b    (a0)+,(a1)+         * Kopiere jeweils 1 Byte
          dbf       d0,copyloop         * Fertig? Nein => copyloop
          movem.l   zeros(pc),d0-d7/a1-a6 * Register flott l”schen
          jmp       12                  * Clear-Routine starten
clear:    lea       clrend(pc),a0       * Hinter Clear-Schleife l”schen...
clearlp:  movem.l   d0-d7/a1-a6,(a0)    * Schnelle L”schschleife...
          adda.w    #56,a0              * Adresse hochsetzen
          bra.s     clearlp             * und wieder und wieder...
clrend:

zeros:    dc.l      0,0,0,0,0,0,0,0     * d0-d7
          dc.l      0,0,0,0,0,0         * a1-a6

*************
* Variablen *
*************

erfolg:   dc.w      0                   * Flagge 1 VBL installiert
bedarf:   dc.l      0                   * Speicherbedarf des Programms
kbshift:  dc.l      0                   * Zeiger auf Keyboardshift
kbscan:   dc.l      0                   * Zeiger auf Keyboard-Scancode

***********
* Strings *
***********

message:  dc.b      "Reset/Coldboot resident. (C)1988 Stefan Becker"
          dc.b      13,10,0
insterr:  dc.b      "Reset/Coldboot konnte nicht installiert werden!"
          dc.b      13,10,0

***************
* Bss-Segment *
***************

stack:    dsbss.b   stacksize           * Programm-Stack

          end

