* --------------------------------------------------------------------------
* get_mpb.s (the real one!)                                      (c) br 2/90
* 1st revision: multiple tries in backtracking thru dead MD links    br 1/91
* 2nd revision: reverse scan direction                               br 2/91
* --------------------------------------------------------------------------
action:   move.l    4(sp),a0            ;basepage addr
          lea       stack+$400(pc),a1   ;end of code + $100 longs
          move.l    a1,d0
          andi.b    #$FC,d0             ;long align
          move.l    d0,sp               ;new sp
          suba.l    a0,a1               ;prog length

          pea       (a1)                ;newsize
          pea       (a0)                ;block
          clr       -(sp)               ;filler
          move      #$4A,-(sp)          ;Mshrink
          trap      #1                  ;GEMDOS
          lea       $C(sp),sp

          lea       title(pc),a0        ;Titelzeile
          bsr       conws               ;ausgeben

          pea       main(pc)            ;get_mpb
          move      #$26,-(sp)          ;Supexec
          trap      #14                 ;XBIOS
          addq      #6,sp

          tst.l     d0                  ;na ?
          beq.s     error               ;schade!

          move.l    d0,a3               ;Adresse mpb
          move.l    a3,d3
          bsr       prt_hex             ;ausgeben
          moveq     #2,d5               ;3 mal
loop_2:   bsr.s     space               ;Zwischenraum
          move.l    (a3)+,d3            ;mp_mfl, mp_mal, mp_rover
          bsr       prt_hex             ;ausgeben
          dbf       d5,loop_2

          lea       bye(pc),a0          ;'Taste drÅcken!'
          bsr.s     conws               ;ausgeben

term:     move      #7,-(sp)            ;Cnecin
          trap      #1                  ;GEMDOS
          clr       (sp)                ;Pterm0
          trap      #1                  ;GEMDOS

error:    lea       err_1(pc),a0        ;Fehlermeldung
          bsr.s     conws               ;ausgeben
          bra       term
* --------------------------------------------------------------------------
main:     lea       $48E,a3     ;themd = letzter MD der mal
          lea       $2000,a4    ;Startadresse
          movea.l   $432,a5     ;Endadresse = membot

loop_0:   movea.l   a4,a0       ;Startadresse
          moveq     #0,d6       ;VersuchszÑhler
loop_1:   addq      #2,a0       ;nur gerade Adressen
          cmpa.l    a0,a5       ;Endadresse erreicht?
          bls.s     stuck       ;war nichts

          cmpa.l    (a0),a3     ;Zeiger?
          bne       loop_1      ;weiter testen

          btst      #0,15(a0)   ;m_own gerade? (!)
          bne       loop_1      ;weiter testen
          btst      #0,7(a0)    ;m_start gerade? (!)
          bne       loop_1      ;weiter testen
          btst      #0,11(a0)   ;m_length gerade? (!)
          bne       loop_1      ;weiter testen

          move.l    a0,a3       ;neuer MD ?
          tst.l     12(a3)      ;m_own = 0  Besitzer? (!!!)
          bne       loop_0      ;nÑchster Zeiger

          subq      #4,a3       ;Adresse des MPB (!)
          move.l    a3,d0       ;RÅckgabewert
          rts

stuck:    addq      #1,d6       ;# Versuche hochzÑhlen
          move.l    a3,a0       ;ab hier weitersuchen
          move.l    (a3),a3     ;wieder alten Zeiger nehmen
          cmp       #10,d6      ;max. Anzahl der Versuche = 11
          bls       loop_1      ;nochmal versuchen!
          moveq     #0,d0       ;Fehler
          rts
* --------------------------------------------------------------------------
space:    lea       space_1(pc),a0      ;Zwischenraum
conws:    pea       (a0)                ;Stringadresse
          move      #9,-(sp)            ;Cconws
          trap      #1                  ;GEMDOS
          addq      #6,sp               ;SP restaurieren
          rts
* --------------------------------------------------------------------------
cconout:  move      d0,-(sp)            ;char
          move      #2,-(sp)            ;Cconout
          trap      #1                  ;GEMDOS
          addq      #4,sp
          rts
* --------------------------------------------------------------------------
* Langwort in d3 in Hex (als Text) auf Konsole ausgeben

prt_hex:  moveq     #7,d7               ;8 mal
nibble:   rol.l     #4,d3               ;jeweils ein Nibble
          move      d3,d0               ;ans Ende rollen
          andi      #$000f,d0           ;isolieren
          lea       hextab(pc),a0       ;Hextabelle holen
          move.b    0(a0,d0.w),d0       ;und Zeichen
          bsr       cconout             ;ausgeben
          dbf       d7,nibble           ;weiter
          rts
* --------------------------------------------------------------------------
hextab:   dc.b '0123456789ABCDEF'
title:    dc.b   13,'get_mpb (the real one!)     Ω br 90,91',13,10,10
          dc.b      'mpb_addr  mp_mfl    mp_mal    mp_rover',13,10
          dc.b      '--------------------------------------',13,10,0
space_1:  dc.b      '  ',0
bye:      dc.b  13,10,10,"* * *       press any key!       * * *",13,10,0
err_1:    dc.b           "* * *   sorry, could't get mpb!  * * *",13,10,0
          even
stack:
* --------------------------------------------------------------------------
          bss
          ds.l      100
* --------------------------------------------------------------------------

