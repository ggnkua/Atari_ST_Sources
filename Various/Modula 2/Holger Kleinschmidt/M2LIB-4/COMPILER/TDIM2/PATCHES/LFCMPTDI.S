V_Bit     EQU %00000000000000000000000000000010
N_Bit     EQU %00000000000000000000000000001000

  movem.l D0-D5,-(SP)
  movem.l 4+24(SP),D0-D3
  moveq   #$ff,D5
  lsr.l   #1,D5
  move.l  D0,D4
  bpl.s   null1
  eor.l   D5,D0
  not.l   D1
null1:
  andi.l  #$7ff00000,D4
  bne.s   t2nd
  moveq   #$00,D0
  moveq   #$00,D1
t2nd:
  move.l  D2,D4
  bpl.s   null2
  eor.l   D5,D2
  not.l   D3
null2:
  andi.l  #$7ff00000,D4
  bne.s   cmp2
  moveq   #$00,D2
  moveq   #$00,D3
cmp2:
  cmp.l   D0,D2
  bne.s   ende
  cmp.l   D1,D3

* Der Compiler baut hinter den Code fuer den Aufruf der Prozedur einen
* bedingten Sprung ein, der auf ein Ergebnis mit Zweierkomplement-
* Arithmetik abfragt (BLT, BLE, BGE, BGT), der zweite Teil der Mantisse
* hat aber kein Vorzeichen, so dass fuer diesen Teil auf einen
* Vergleich/Subtraktion vorzeichenloser Zahlen abgefragt werden muss
* (CARRY-Bit). Die folgenden Befehle uebernehmen also das
* Umwandeln des Ergebnisses einer UNSIGNED-Subtraktion (nur CARRY-Bit
* beachten) in ein Ergebnis fuer Zweierkomplement-Vergleich (das
* Ergebnis der Exclusiv-Oder-Verknuepfung von NEGATIVE und OVERFLOW
* muss gleich dem Ergebnis von CARRY sein).
*
* CARRY = 0  =>  NEGATIVE := 0, OVERFLOW := 0  <=> NEGATIVE xor OVERFLOW = 0
* CARRY = 1  =>  NEGATIVE := 1, OVERFLOW := 0  <=> NEGATIVE xor OVERFLOW = 1
*

  andi    #$ff-N_Bit-V_Bit,CCR  ; N- und V-Bit loeschen, C- und Z-Bit nicht
                                ; beeinflussen !
  bcc.s   ende      ; B: second >= first
  moveq   #-1,d3    ;    second <  first, NEGATIVE-Bit setzen, Zahlen koennen
                    ; nicht gleich sein, also ist ZERO-Bit egal
ende:
  movem.l (SP)+,D0-D5
  rts
          DC.W $fabd            ; Korrektur der Pruefsumme

