*  watcher.s
*  written by ww&js on 13.2.86/14.2.86

* Dieses Programm ermoeglicht es, Programme mit Endlosschleifen
* abzubrechen.

gemdos    equ   1        * System-Aufruf Konstanten
xbios     equ  14
print     equ $09        * GEMDOS Systemaufrufe
keep      equ $31
readline  equ $0a
iorec     equ  14        * XBIOS Systemaufrufe
super     equ  38
ibuf      equ   0        * Offsets of struct iorec
isize     equ   4
ihd       equ   6
itail     equ   8
ctrl_b    equ   2        * Control-B
_vblqueue equ $456       * Systemaddresen: VBL Adressen
nvbls     equ $454       * Anzahl VBL-Routinen
level_4   equ $70        * Level 4 Interruptvector

     .bss
laenge    .ds.l     1
iorecp    .ds.l     1
oldlevel  .ds.l     1
merksp    .ds.l     1
merkpc    .ds.l     1
count     .ds.l     1

* Berechne Groesse des Programms:
     .text
     move.l    4(sp),a0       * basepage Adresse
     move.l    #$100,d6       * basepage Groesse
     add.l     12(a0),d6      * text Groesse
     add.l     20(a0),d6      * data Groesse
     add.l     28(a0),d6      * bss Groesse
     move.l    d6,laenge      * abspeichern

     move      #1,-(sp)       * XBIOS iorec(1) (Tastaturpuffer)
     move      #iorec,-(sp)   * (liefert den Beschreibungsblock)
     trap      #xbios
     addq.l    #4,sp
     move.l    d0,iorecp      * Adresse merken

     move.l    #main,-(sp)    * Routine main im Supervisormode ...
     move      #super,-(sp)   * ...laufen lassen
     trap      #xbios
     addq.l    #6,sp

     clr       -(sp)          * GEMDOS keep(laenge,0)
     move.l    laenge,-(sp)   * (Programm wird beendet, aber...
     move      #keep,-(sp)    * ...im Speicher resident gehalten)
     trap      #gemdos


* Routine vbl in Liste der VBL-Routinen eintragen
main
     move      nvbls,d0       * Anzahl VBL-Routinen
     lsl       #2,d0
     move.l    _vblqueue,a0   * Adr. der VBL-Routinen
     clr       d1
loop1
     tst.l     (a0,d1)        * Routine frei?
     beq       free           * ja, freier Platz gefunden
     addq      #4,d1          * naechste Routine
     cmp       d0,d1          * Ende?
     bne       loop1
     rts                      * keine freie Routine gefunden, return

* freie VBL-Routine gefunden; Interruptvektor und eigene Routine
* eintragen:
free
     move.l    level_4,oldlevel    * bisherigen Int.-Vektor merken
     move.l    #newlevel,level_4   * neuen Int.-Vektor eintragen

     lea       (a0,d1),a2     * Adr. der freien VBL-Routine
     move.l    #vbl,(a2)      * eigene VBL-Routine eintragen

     rts                      * fertig

* eigene Level 4 Interruptbehandlung (VBL Interrupt)
newlevel
     move.l    sp,merksp      * Stackpointer merken
     move.l    oldlevel,-(sp) * zur System-Interruptbehandlung springen
     rts

* eigene VBL-Routine
vbl  move.l    merksp,a0      * Interrupt-Stackpointer laden
     move      (a0),d0        * SSR des unterbrochenen Programms
     and       #$2000,d0      * User/Supervisor Bit testen
     beq       continue       * nicht gesetzt -> User-Mode
     rts                      * unterbrochenes Programm war im Super-
*                             * visor Mode; nicht abbrechen

* unterbrochenes Programm ist im User-Mode; XBIOS Tastaturpuffer
* nach CTRL-B durchsuchen:
continue
     clr.l     count          * Zaehler init.
     move.l    iorecp,a0      * Adr. Pufferbeschreibungsblock
     move.l    ibuf(a0),a1    * Adr. Tastaturpuffer
     move      isize(a0),d1   * Puffergroesse (in bytes)
     move      ihd(a0),d2     * Ringpuffer Anfang (Index)
     move      itail(a0),d3   * Ringpuffer Ende (Index)

     move      d3,d4          * D4: Ende fuer erste Schleife
     move      d2,d5          * D5: Laufvariable
     cmp       d2,d3          * Testen ob Puffer leer
     bne       cont2          * nicht leer
     rts                      * leer;
cont2
     bgt       nowrap         * nur eine Schleife
     move      d1,d4          * 2 Schleifen; erste bis Puffergroesse...
     subq      #4,d4          * ...-4
nowrap
     cmp.b     #ctrl_b,3(a1,d5) * CTRL-B im Puffer?
     bne       cont3          * nein
     addq.l    #1,count       * zaehlen
cont3
     addq      #4,d5          * naechster Index
     cmp       d5,d4          * Ende erreicht?
     bge       nowrap         * Nein, weiter

     cmp       d2,d3          * Test ob 2 Schleifen
     bgt       ende           * nein, fertig mit Durchsuchen
     clr       d5             * Schleife 2 von 0 bis...
     move      d3,d4          * ...Ende Index
loop3
     cmp.b     #ctrl_b,3(a1,d5) * Schleife wie oben
     bne       cont4
     addq.l    #1,count
cont4
     addq      #4,d5
     cmp       d5,d4
     bge       loop3          * Schleifenende
ende
     cmp.l     #3,count       * mindestens 3 mal CTRL-B gefunden?
     bge       kill           * ja, kill'em all
     rts                      * sonst normaler Ruecksprung

* Ruecksprung des unterbrochenen Programms umleiten:
kill
     move.l    merksp,a0      * Interrupt Stackpointer
     move.l    2(a0),merkpc   * Original-Ruecksprungadresse merken
     move.l    #abort,2(a0)   * neue Ruecksprungadr. dafuer eintragen
     rts                      * Ende VBL-Routine

* An diese Stelle wird der Ruecksprung des unterbrochenen Programms
* umgeleitet, falls 3 mal CTRL-B im Tastaturpuffer gefunden wurde
abort
     move.l    merkpc,-(sp)   * Original-Ruecksprungadresse
     movem.l   d0-d2/a0-a2,-(sp) * Register retten
     move.l    #ibuff,-(sp)   * Eingabezeile lesen
     move      #readline,-(sp)
     trap      #gemdos
     addq.l    #6,sp

     tst.b     ibuff+1        * Eingabe da?
     beq       exit           * Nein, vermutlich EOF bei Input Redirection

     movem.l   (sp)+,d0-d2/a0-a2 * ansonsten Programm fortsetzen
     rts

exit
     clr       -(sp)
     trap      #gemdos
     .data
ibuff
     .dc.b     8,0
     .ds.b     8
     .end
