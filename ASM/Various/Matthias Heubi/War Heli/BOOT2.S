*****************************************
**** BOOT-SECTOR-LOADER for WAR-HELI ****
*****************************************   By GMC



regsel   equ      $ffff8606                  * FDC Register Select
datareg  equ      $ffff8604                  * FDC Dataregister
gpip     equ      $fffffa01                  * MFP Input Register
dmahigh  equ      $ffff8609                  * DMA High adress
dmamid   equ      $ffff860b                  * DMA Mid adress
dmalow   equ      $ffff860d                  * DMA Low adress


         .text

begin:   dc.l     bus_err
         dc.l     adr_err
         dc.l     ill_err                    * Vektoren verbiegen
         dc.l     0

         
start:   move.w   #7,d0
         lea      $ff8240,a0                 * Screenfarben: schwarz
         bra      clloop
         
atrace:  dc.l     0
aline:   dc.l     linea                      * Vektoren verbiegen
fline:   dc.l     linef

clloop:  clr.l    (a0)+                      * Alle Farbregister: schwarz
         dbra     d0,clloop
         
         move.l   #$ff0fff80,$ff8200         * Screen Adresse: $f8000
         lea      $ffd00-4,a7                * Stack auf Screen

         illegal                             * Jump zu Next
         
linef:   move.l   d7,-(a7)
         moveq.l  #$20,d7                    * Line F Exeption
wloop:   dbra     d7,wloop                   * Ein bisschen warten
         move.l   (a7)+,d7
         addq.l   #2,2(a7)                   * RÅcksprungadresse korrektur
         rte

*************************************************************************

regs:    dc.l     -17384                     * D1  No Sense But Negative !
         dc.l     0                          * D2
         dc.l     $b6                        * D4
         dc.l     $602e3490                  * D5   Oberes Word nach $18 
         dc.l     $137                       * D6   Adresse fÅr DMA
         
         dc.l     start+1                    * A1   Begin des Codes
         dc.l     vbl                        * A2   LEVEL 4 INTERRUPT VBL
         dc.l     $fffc00                    * A3   Tastatur ACIA
         dc.l     $315                       * A4   LEVEL 6 INTERRUPT MFP
         dc.l     $ff8260                    * A5   LEVEL 7 INTERRUPT NMI
         dc.l     0                          * A6   TRAP #0

*************************************************************************

next:    stop     #$2300                     * Auf VBL warten
         move.l   #there-here,atrace         * Jump zu there
         stop     #$2300              
here:
         neg.w    d0                         * 
         subq.w   #1,d0                      *
         divu.w   #16,d0                     * Nur MÅll
out:     move.w   d0,d4                      *
         asl.w    d4                         * Und AbgehÑngt ....  hehe
         move.w   d4,a5                      *
hehe:    btst     #5,$73fb(a0)               *
         bne      hehe                       * HAR, HAR, viel GlÅck 
         jmp      (a6)                       * bei (a6) ???!!! hehe
 
*************************************************************************

linea:   and.w    #$00ff,d5
         move.w   d5,(a0)                    * 90
         or.w     #$0100,d5
         move.w   d5,(a0)                    * 190  SET DMA to READ
         and.w    #$feff,d5
         move.w   d5,(a0)                    * 90

         dc.w     $f000         
         move.w   d1,(a1)                    * SECTOR COUNT REGISTER

         move.l   d6,a7                      * Stack nach $400
         
         move.l   #209712,d7                 *
         move.l   d6,a6                      * Ab $400 alle 20 Bytes ein 0.L
loop:    clr.l    (a6)                       * Speicher versauen !!!
         add.l    #20,a6                     * Bis es einen Bus-Error gibt
         subq.l   #1,d7                      *
         bne      loop                       * Eine Schlaufe vortÑuschen
         jmp      here                       * Hî, Hî, Hî ...

*************************************************************************

ill_err: move.b   $fffc00,d7                 * ACIA nach d7 , No Sense 
         
         move.w   (a7)+,d0                   * Statusregister vom Stack
         add.l    #$3a4,a0                   * In A0 ist nun : $ff8604

         btst     #15,d0                     * Wenn Trace-Bit gesetzt -->
         bne      return                     * Ende (fast zu offensichtlich)
         
         movem.l  regs,d1-d2/d4-d6/a1-a6     * Register holen
         
         tst.w    d1                         *
         bpl      label0                     *
         neg.w    d1                         * 

****************************************
         clr.b    (a5)                       * Niedrige Auflîsung
****************************************          

         sub.w    d1,d7                      * No Sense, but Fun ... 
         clr.l    d2                         * 
         move.w   d6,d2                      * Ein bisschen kalkulieren !
label0:  addq.w   #1,d2                      * 

****************************************
         move.b   d4,(a3)                    * Kill ACIA $B6,$FFFC00
****************************************

         asl.w    d2                         * 
         mulu.w   d1,d2                      * 

****************************************     * Gut versteckt
         add.w    d5,a5                      * A5 = $ff8260 + $3490
         move.l   d5,(a1)                    * Oberes Word von D5 nach $18
****************************************     * ****** Adress Error ******

back:    add.l    d2,a3                      * 
         lsl.l    #2,d2                      * 
         add.l    d2,a6                      * Alles Mist
         clr.l    d1                         * 
 

bout:    move.l   #out,(a7)                  * RÅcksprungadresse im grÅnen

         bclr     #15,d0                     * Trace Bit lîschen
         move.w   d0,-(a7)                   * SR auf Stack
return:  rte         
         
***************************************************************************
         bra      label0                     * Only a 'GAG'             
***************************************************************************
         
there:   move.w   #$2700,sr
         move.b   d6,7(a0)                   * Set DMA Adresse $400
************************************
         move.b   -$3490(a5),$1a             * Auflîsung nach $1a.B
************************************
         move.l   d6,d1
         lsr.w    #8,d1
         move.b   d1,7(a1)                   * Set DMA Adresse $400
         swap     d1
         move.b   d1,3(a0)

         move.w   #8,d1                      * Anzahl Sectoren zu Lesen: 8
         dc.w     $a000                      * Sprung Åber Line-A
         


***************************************************************************

bus_err: move.l   d6,a2
         
         move.w   #$60fe,(a2)                * $400  BRA $400
         
         move.w   d5,d4                      * In d5.w ist $90
         sub.w    #$10,d4                    * In D4.w ist $80
*************************************
         move.l   $49a-$315(a4),$1c          * Memory Discriptor nach $1c.L
*************************************
         move.w   d4,(a0)                    * Read Multiple Sectors
         dc.w     $f000
         move.w   d5,(a1)
         
         move.w   #$ffff,d0
         jmp      (a2)                       * Warten bis es geladen ist ??

***************************************************************************

vbl:     move.l   d0,-(a7)
         move.l   atrace,d0
         add.l    d0,6(a7)
         move.l   (a7)+,d0
         jmp      return

***************************************************************************

adr_err: move.l   #next,bout-start+1(a1)
         move.l   a0,a1
         lea      2(a0),a0                   * A1 = $ff8606
         sub.w    #$b6-$84,d4                * In D4 ist nun $84
         move.w   d4,(a0)                    * Sectorregister
         dc.w     $f000                      * Wait
         move.w   d6,d4
         sub.w    #$137-3,d4                 * In D4 ist nun $3
         move.w   d4,(a1)                    * Sector: 3

******************************************
         add.w    #$400-$137,d6              * Startadresse berechnen
******************************************

         dc.w     $f000                      * Wait
         clr.b    $7403(a0)
         clr.b    $7403(a1)                  * MFP irq disable

         clr.l    d1
         move.w   (a7),d1
         and.w    #$000f,d1
         move.w   d1,d4
         lsl.w    #4,d1
         or.w     d4,d1
         eor.w    #$d1,d1
         addq.l   #8,a7                      * Stack korrigieren
         move.l   d1,2(a7)         
         rte

***************************************************************************



