* --------------------------------------------------------------------------
* _get_mpb.s link module dev'd from get_mpb (the real one!)      (c) br 2/90
* --------------------------------------------------------------------------
* 1st revision: multiple tries in backtracking thru dead MD links    br 1/91
* 2nd revision: split mfl/mal search, reverse first scan direction   br 2/91
* --------------------------------------------------------------------------
* long _get_mpb(void);  IN: nothing, OUT: address of MPB or NULL in D0.L
* --------------------------------------------------------------------------
themd     = $48E
membot    = $432
memtop    = $436
MAX       = 10      ;max # Versuche = 11
* --------------------------------------------------------------------------
          globl     _get_mpb            ;C & assembly language entry
          globl     GETMPB              ;FORTRAN & Pascal entry
GETMPB:
* --------------------------------------------------------------------------
_get_mpb: movem.l   d1-d2/a0-a2,-(sp)   ;Register retten
          pea       get_mpb(pc)         ;Routine
          move      #$26,-(sp)          ;Supexec
          trap      #14                 ;XBIOS
          addq      #6,sp
          movem.l   (sp)+,d1-d2/a0-a2   ;Register zurÅck
          rts
* --------------------------------------------------------------------------
get_mpb:  lea     themd,a1    ;Ausgangspunkt
          movea.l membot,a2   ;Suchende
          move.l  memtop,d0
          sub.l   a2,d0       ;freien Speicher berechnen
          cmp.l   8(a1),d0    ;m_length = memtop - membot ?
          bne.s   loop_0      ;fehlt schon etwas

          lea     $4000,a0    ;Suchbeginn
t_loop:   addq    #2,a0       ;nur gerade Adressen
          cmpa.l  a0,a2       ;Endadresse erreicht?
          bls.s   error       ;fertig

          cmpa.l  (a0),a1     ;Zeiger auf themd ?
          bne     t_loop      ;weiter suchen
          bra.s   fini        ;das war's

loop_0:   move.l  a2,a0       ;Suchbeginn = membot
          moveq   #0,d2       ;VersuchszÑhler
loop_1:   subq    #2,a0       ;nur gerade Adressen
          cmpa.l  #$2000,a0   ;Endadresse erreicht?
          bls.s   stuck       ;war nichts

          cmpa.l  (a0),a1     ;Zeiger da ?
          bne     loop_1      ;weiter testen

* PlausibilitÑts-Tests fÅr MD's, falls mp_mal gefunden wurde, kritisch!

          btst    #0,15(a0)   ;m_own gerade? (!)
          bne     loop_1      ;weiter testen
          btst    #0,7(a0)    ;m_start gerade? (!)
          bne     loop_1      ;weiter testen
          btst    #0,11(a0)   ;m_length gerade? (!)
          bne     loop_1      ;weiter testen

          move.l  a0,a1       ;evtl. neuer MD
          tst.l   12(a0)      ;Besitzer = 0 ? (!!!)
          bne     loop_0

          subq    #4,a0       ;Adresse des MPB
fini:     move.l  a0,d0       ;RÅckgabewert
          rts

stuck:    addq    #1,d2       ;# Versuche hochzÑhlen
          move.l  a1,a0       ;war kein gÅltiger m_link
          move.l  (a1),a1     ;alten Zeiger nehmen
          cmp     #MAX,d6     ;max. Anzahl der Versuche
          bne     loop_1      ;nochmal versuchen!
error:    moveq   #0,d0       ;Fehler
          rts
* --------------------------------------------------------------------------


