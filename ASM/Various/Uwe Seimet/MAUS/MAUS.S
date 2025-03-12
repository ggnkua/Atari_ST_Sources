*********************************************************
* Routinen zur effektiven Abfrage der rechten Maustaste *
*                  1989 by Uwe Seimet                   *
*********************************************************

*Initialisierung der Mausroutine
init:
         moveq #125,d0              ;vex_butv
         move.l #butvec,contrl+14
         bsr.s vdi                  ;neuer Vektor fÅr Mausbutton
         move.l contrl+18,oldvec+2  ;alten Vektor merken
         rts

*rechte Maustaste abschalten
exit:
         moveq #125,d0              ;vex_butv
         move.l oldvec+2(pc),contrl+14
         bra.s vdi                  ;alten Button-Vektor zurÅckschreiben

*neue Routine zur Behandlung der Mausbuttons
butvec:
         tst d0                     ;Maustaste losgelassen?
         beq.s oldvec               ;ja-
         cmp #2,d0                  ;rechte Maustaste?
         seq flag                   ;Flag fÅr rechte Maustaste
         bne.s oldvec               ;weiter, falls linke Taste-
         moveq #1,d0
oldvec:  jmp $ffff                  ;zurÅck zur alten Mausroutine

*Allgemeiner VDI-Aufruf, Funktionsnummer in D0
vdi:
         move vdi_h,contrl+12
         move d0,contrl
         move.l #vdipb,d1
         moveq #$73,d0              ;Code fÅr VDI
         trap #2
         rts


         data

vdipb:   dc.l contrl,intin,ptsin,intout,ptsout        ;VDI-Arrays


         bss

contrl:  ds.w 11

intin:   ds.w 64

ptsin:   ds.w 64

intout:  ds.w 64

ptsout:  ds.w 64

vdi_h:   ds.w 1                     ;muû VDI-Handle enthalten!

flag:    ds.b 1                     ;Flag fÅr rechte Maustaste
