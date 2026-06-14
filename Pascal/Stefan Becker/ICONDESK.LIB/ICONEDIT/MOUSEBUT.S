**********************************
* Ermittle Status der Maustasten *
* (c)1989 by Stefan Becker       *
**********************************
* Aufrufe in Pascal+:            *
*                                *
* 1) InitMaus();                 *
* 2) Function Buttons():Integer; *
**********************************

etv_term  equ       $408                * Adresse der Preterm-Routine

*********************************
* Gebe Pascal den Button-Status *
*********************************

          xdef      BUTTONS

BUTTONS:  move.l    (a7)+,a0            * Return-Adresse holen
          move.w    butt,d0             * Buttons in d0
          jmp       (a0)                * => Pascal

************
* Initmaus *
************

          xdef      INITMAUS            * Routine von auen erreichbar

INITMAUS: movem.l   a1-a6/d0-d7,regs    * Regs retten
          move.l    (a7)+,return        * Return-Adresse retten

          move.w    #34,-(a7)           * kbdvbase-Aufrufen:
          trap      #14
          addq.l    #2,a7
          move.l    d0,kbdbase          * Ergebnis merken

          pea       changevec(pc)       * "Enable-Routine" im Supervisormode
          move.w    #38,-(a7)           * mit Supexec ausfhren.
          trap      #14
          addq.l    #6,a7

          movem.l   regs,a1-a6/d0-d7    * regs retten
          move.l    return,a0           * zurck nach Pascal
          jmp       (a0)

****************************************
* Routine mu im Supervisormode laufen *
****************************************

changevec:move.l    etv_term,oldterm    * alte Preterm-Routine merken
          lea       preterm(pc),a0      * Preterm-Routine einh„ngen
          move.l    a0,etv_term

          move.l    kbdbase,a0
          lea       newmouse,a1
          move.l    16(a0),oldmvec      * alten Mausvektor merken
          move.l    a1,16(a0)           * Dann Newmouse einklinken
          rts

**************************
* Neue Etv-Term-Routine. *
**************************

preterm:  move.l    oldterm,etv_term    * Diese Pre-Term-Routine aush„ngen
          move.l    kbdbase,a0
          move.l    oldmvec,16(a0)      * Mausroutine aush„ngen
          rts                           * Fertig

********************
* Neue Mausroutine *
********************

newmouse: movem.l    d0/a0,-(a7)        * regs retten: d0/a0
          move.b     (a0)+,d0           * Ist es ein Mauspaket ?
          cmpi.b     #$f8,d0
          bcs.s      end_mouse          * Nein...
          cmpi.b     #$fc,d0
          bcc.s      end_mouse          * Nein...

          and.w     #3,d0               * Bitte nur Buttons
          move.w    d0,butt

end_mouse:movem.l    (a7)+,d0/a0        * regs laden: d0
          move.l     oldmvec,-(a7)      * Weiter mit alter Routine
          rts

*********
* Daten *
*********

butt:     dc.w      0
oldterm:  dc.l      0
return:   dc.l      0
kbdbase:  dc.l      0
oldmvec:  dc.l      0

regs:     ds.l      14

          end

