*  Listing 3: SAM_ASM
*  (c)1992 by MAXON-Computer
*  Autor: Torsten Thiel

* - Sampelt Stereo-Sound in STE/TT (ST)
*   wobei beim ST noch 2*50000
*   Messungen/Sekunde mîglich sind

* - vor dem Aufruf mÅssen Datenelemente
*   gesetzt sein startadr > Startadresse
*   zum Ablegen der Sampledaten.

*   anzahl   > Anzahl der Messungen
*   zaehler, vorteiler
*            > legen Abtastfrequenz fest
*   AFrequenz=2457600/(vorteiler*zaehler)

  movem.l d0-d7/a1-a6,-(sp)

  clr.l   -(sp)
  move.w  #$20,-(sp)
  trap    #1           in den Supervisormodus
  addq.l  #6,sp        schalten
  lea.l   oldsp(pc),a0
  move.l  d0,(a0)      alten Stack merken

  move.w  #$2600,sr    ab jetzt kein IRQ mehr

  movea.l startadr(pc),a1 Startadresse
  movea.l a1,a2
  adda.l  anzahl(pc),a2  Endadresse
  movea.l #$ffff8800,a5  SID-Basis
  movea.l #$ffff8802,a4  SID-Basis+2
  movea.l #$fffffa00,a6  MFP-Basis
  movea.l #$fffffa0d,a3  MFP-Basis+13
  moveq.l #15,d1         SID-Register fÅr Druckerport
  moveq.l #4,d2          fÅr Bit 4 testen
  move.l  #$0e002f00,d3  Long fÅr STROBE Hi
  move.l  #$0e000f00,d4  Long FÅr STROBE Lo

  move.b  zaehler(pc),d0 ZÑhlerstartwert holen
  move.b  d0,$25(a6)     und setzen
  move.b  $1d(a6),d0     Vorteiler des Timer's C/D holen
  andi.b  #$f0,d0        und Timer D neu setzen
  move.b  vorteil(pc),d7
  or.b    d7,d0
  move.b  d0,$1d(a6)
  bset    #4,9(a6)       Timer D muû IRQ geben kînnen

  move.b  #7,(a5)        Port B auf Eingabe
  move.b  (a5),d0        schalten
  andi.b  #$7f,d0
  move.b  d0,2(a5)

  move.l  d3,(a5)        STROBE Hi senden
  move.b  d1,(a5)        Port B selektieren
  move.b  (a5),d0        Port B testen
  beq.s   Takt1          wenn 'Ja' > Sampler bei Takt4
  move.l  d4,(a5)        wenn 'Nein' > STROBE Lo und
  move.l  d3,(a5)        STROBE Hi senden
Takt1:
  move.l  d4,(a5)        STROBE Lo senden  TAKT1(Start)
  bclr    d2,(a3)
  move.b  (a3),d5        move ist schneller als bclr
inplr:
  btst    d2,(a3)        warten bis Timerzeit
  beq.s   inplr          abgelaufen
  move.b  d5,(a3)        Timer zurÅcksetzen
  move.b  d1,(a5)        Port B selektieren
  move.b  (a5),(a1)+     Port B lesen
  move.l  d3,(a5)        STROBE Hi senden  TAKT2
  move.b  d1,(a5)        Port B selektieren
  move.b  (a5),(a1)+     Port B lesen
  move.l  d4,(a5)        STROBE Lo senden  TAKT3
  move.w  d3,(a4)        STROBE Hi senden  TAKT4
  move.w  d4,(a4)        STROBE Lo senden  TAKT1(Start)
  cmpa.l  a1,a2          ist Endadressen schon erreicht?
  bne.s   inplr          wenn 'Nein' noch ein Durchlauf

  move.b  $1d(a6),d0
  andi.b  #$f0,d0        Timer D stoppen
  move.b  d0,$1d(a6)
  bclr    #4,9(a6)

  move.l  d3,(a5)        STROBE Hi senden  TAKT2
  move.l  d4,(a5)        STROBE Lo senden  TAKT3

  move.w  #$2300,sr      IRQ's wieder erlauben

  move.l  oldsp(pc),-(sp)
  move.w  #$20,-(sp)
  trap    #1             in User-Modus zurÅck
  addq.l  #6,sp

  move.l  #%01111111011111110111111101111111,d0
  movea.l startadr(pc),a1 Startadresse
  movea.l a1,a2
  movea.l anzahl(pc),a3
  move.l  a3,d7
  andi.l  #%11111111111111111111111111100000,d7
  beq.s   neg32end
  adda.l  d7,a2
neglr32:
  eor.l   d0,(a1)+  aus GeschwindigkeitsgrÅnden
  eor.l   d0,(a1)+  gleich 32 Byte
  eor.l   d0,(a1)+
  eor.l   d0,(a1)+
  eor.l   d0,(a1)+
  eor.l   d0,(a1)+
  eor.l   d0,(a1)+
  eor.l   d0,(a1)+
  cmp.l   a1,a2     ist Endadressen schon erreicht?
  bne.s   neglr32   wenn 'Nein' noch ein Durchlauf
neg32end:
  move.l  a3,d7
  andi.l  #%00000000000000000000000000011111,d7
  beq.s   ende
neglr1:
  eor.b   d0,(a1)+  die restlichen Bytes byteweise
  dbf     d7,neglr1
ende:
  movem.l (sp)+,d0-d7/a1-a6
  rts

DATA

startadr:   DC.l 0
anzahl:     DC.l 0
zaehler: DC.l 20
vorteil:    DC.l 1
oldsp:      DC.l 0
