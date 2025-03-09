* Umwandlung des Packed Decimal String Real
* Formates in einen String

  lea       zahl,a0      ;Puffer fÅr Zahl
; fmove.f   <ea>,fpn
; fmove.p   fpn,(a0){#k}
  lea       string,a1    ;Puffer fÅr String
  btst.b    #7,(a0)      ;Zahl negativ ?
  beq       positiv      ;nein
  move.b    #'-',(a1)+   ;ja
positiv:
  move.b    3(a0),d0     ;erste Ziffer
  unpk      d0,d1,#$3030 ;in ASCII wandeln
  move.b    d1,(a1)+     ;in String schreiben
  move.b    #'.',(a1)+   ;Komma setzen
  moveq     #4,d2        ;Offset
  moveq     #7,d3        ;ZÑhler
m_loop:
  move.b    (a0,d2.w),d0 ;2 Ziffern holen
  unpk      d0,d1,#$3030 ;in ASCII wandeln
  move.w    d1,(a1)+     ;in String schreiben
  addq.w    #1,d2        ;Offset erhîhen
  dbf       d3,m_loop    ;bis zur letzten Ziffer
  move.b    #'e',(a1)+
  btst.b    #6,(a0)      ;Exponent negativ?
  beq       positiv2     ;nein
  move.b    #'-',(a1)+   ;ja
positiv2:
  bfextu    2(a0){0,4},d0;1. Stelle d. Exponents
  lsl.b     #4,d0
  bfextu    (a0){4,4},d1 ;2. Stelle d. Exponents
  or.b      d1,d0        ;1. u. 2. Stelle in D0
  unpk      d0,d1,#$3030 ;in ASCII wandeln
  move.w    d1,(a1)+
  move.b    1(a0),d0
  unpk      d0,d1,#$3030 ;3. und 4. Stelle
  move.w    d1,(a1)+
* ----------------------------------------------
zahl:     dc.l      0,0,0
*
          bss
string:   ds.b      20
