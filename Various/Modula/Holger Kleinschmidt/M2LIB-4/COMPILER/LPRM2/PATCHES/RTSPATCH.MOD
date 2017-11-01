MODULE RtsPatch;

(*****************************************************************************)
(* Korrektur des LPR-Laufzeitsystems                                         *)
(* --------------------------------------------------------------------------*)
(* Feb-91 / 01-Okt-95, Holger Kleinschmidt                                   *)
(*****************************************************************************)

FROM SYSTEM IMPORT
(* TYPE *) ADDRESS,
(* PROC *) ADR, VAL, INLINE;

FROM OSCALLS IMPORT
(* PROC *) Fseek, Fread, Fwrite, Fopen, Fclose;

FROM Terminal IMPORT
(* PROC *) WriteString, WriteLn, Write, Read;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

CONST
  ESC = 033C;

 (* Die folgenden Offsets sind bei einer Version # 1.4 zu aendern !  *)

  ShellOffset  = 295EH;  (* Offset des 'System'-Moduls in der Shell *)

  OffsetFLOATs = 056AH;  (* Offsets der Routinen im 'System'-Modul *)
  OffsetFDIVd  = 0A00H;
  OffsetFCMPd  = 0CBEH;
  OffsetTRUNCd = 0DDAH;
  OffsetFSHORT = 0ECAH;

  LenProcHead  = 10;     (* Groesse des Prozedurkopfes *)

  LenNewFLOATs = 80;     (* Groesse der neuen Assemblerroutinen *)
  LenNewFDIVd  = 284;
  LenNewFCMPd  = 74;
  LenNewTRUNCd = 126;
  LenNewFSHORT = 112;


VAR
  OrigFDIVd,
  OrigFLOATs,
  OrigFCMPd,
  OrigTRUNCd,
  OrigFSHORT,
  OrigCode,
  CompareCode   : ARRAY [0..15] OF CARDINAL;

  patchAdr,
  vergleich     : ADDRESS;
  offset,
  position,
  schreiben,
  geschrieben,
  gelesen,
  einlesen      : LONGINT;

  done          : BOOLEAN;
  allProcs      : BOOLEAN;
  file          : INTEGER;
  i             : INTEGER;
  datei,prozedur: ARRAY [0..20] OF CHAR;
  dat, proc, ch : CHAR;


(*###########################################################################*)

PROCEDURE TRUNCd ( toTrunc : LONGREAL ): LONGINT;
(*T*)
(* Da die zusaetzliche Abfrage auf MINLInt nicht mehr in die Original-
   routine reingepasst hat, habe ich sie etwas umgeschrieben; sie darf
   aber auch kein Byte laenger werden.
*)
BEGIN
(*
HALTX       EQU -$00000020
IEEEofl     EQU 3

BIAS        EQU 1023
ExpMask     EQU $000007FF

toTrunc     EQU 12
RETURN      EQU toTrunc+8

TRUNCd:
  move.l  d2,-(sp)            ; benutzes Register retten
  movem.l toTrunc(a6),d0-d1
  move.l  d0,d2               ; d2 := Vorzeichen + Exponent
  smi     -(sp)               ; S: Zahl negativ, Vorzeichen merken
  swap    d2                  ; Exponent als CARDINAL-Zahl
  lsr.w   #4,d2               ;
  andi.w  #ExpMask,d2         ;
  subi.w  #BIAS,d2            ;
  bge.s   tstofl              ; B: Zahl >= 1
  moveq   #0,d0               ; Zahlen kleiner als eins werden zu Null
  bra.s   ende                ;
tstofl:
  andi.l  #$000FFFFF,d0       ; Mantisse isolieren
  cmpi.w  #31,d2              ; Zahl zu gross fuer LONGINT ?
  bgt.s   ofl                 ; B: ja
  blt.s   shift               ; B: auf keinen Fall, da < 2^31
  tst.b   (sp)                ; Zahl negativ ?
  beq.s   ofl                 ; B: nein, Zahl >= 2^31 nicht darstellbar
  tst.l   d0                  ; Wenn Zahl genau -2^31, dann darstellbar
  bne.s   ofl                 ; B: nein Zahl < -2^31
  cmpi.l  #$00200000,d1       ;
  bhs.s   ofl                 ; B: Zahl < -2^31
shift:
  bset    #20,d0              ; implizite eins setzen
  subi.w  #20,d2              ; wenn Zahl <= 2^20 direkt nach rechts
  bgt.s   shiftleft           ; schieben ( verkleinern )
  neg.w   d2                  ;
  lsr.l   d2,d0               ;
  bra.s   tstsign
leftlp:                       ; sonst nach links schieben
  add.l   d1,d1               ;
  addx.l  d0,d0               ;
shiftleft:                    ;
  dbra    d2,leftlp           ;
tstsign:
  tst.b   (sp)+               ; Zahl negativ ? Flag vom Stack entfernen
  beq.s   ende                ; B: nein, positiv -> fertig
  neg.l   d0                  ; sonst negativ machen
  bra.s   ende

ofl:
  moveq   #IEEEofl,d0         ; Meldung des Laufzeitsystems: IEEE-öberlauf
  movea.l HALTX(a4),a3        ;
  jsr     (a3)                ;
  moveq   #-1,d0              ; MAX( LONGINT ) bzw. MIN( LONGINT ) liefern
  lsr.l   #1,d0               ;
  tst.b   (sp)+               ;
  beq.s   ende                ;
  not.l   d0                  ;

ende:
  move.l  d0,RETURN(a6)
  move.l  (sp)+,d2            ; gerettetes Register zurueck

  unlk    a6
  movea.l (sp)+,a4
  movea.l (sp)+,a0
  addq.l  #8,sp
  jmp     (a0)
*)
INLINE( 2F02H,4CEEH,0003H,000CH,2400H,5BE7H,4842H,0E84AH,0242H );
INLINE( 07FFH,0442H,03FFH,6C04H,7000H,6050H,0280H,000FH,0FFFFH );
INLINE( 0C42H,001FH,6E32H,6D10H,4A17H,672CH,4A80H,6628H,0C81H );
INLINE( 0020H,0000H,6420H,08C0H,0014H,0442H,0014H,6E0AH,4442H );
INLINE( 0E4A8H,6008H,0D281H,0D180H,51CAH,0FFFAH,4A1FH,6716H,4480H );
INLINE( 6012H,7003H,266CH,0FFE0H,4E93H,70FFH,0E288H,4A1FH,6702H );
INLINE( 4680H,2D40H,0014H,241FH,4E5EH,285FH,205FH,508FH,4ED0H );

END TRUNCd;


PROCEDURE FCMPd ( first, second : LONGREAL );
(*T*)
(* Das ist bis auf den Schluss die Originalroutine, die glÅcklicherweise
   um 8 Bytes gekuerzt werden konnte, sodass die Erweiterung gerade noch
   reinpasst. Die Routine darf aber kein Byte laenger werden !
   Merkwuerdig ist, dass zwar die beiden zu vergleichenden Zahlen als
   Parameter uebergeben werden, die Routine diese aber nicht beachtet,
   sondern erwartet, dass die Argumente in bestimmten Registern stehen.
   Anscheinend ist die Argumentangabe ueberfluessig.
*)
BEGIN
(*
V_Bit   EQU %00000010
N_Bit   EQU %00001000

FCMPd:
  move.l  d0,d4
  bpl.s   pos1          ; B: erste Zahl ist positiv
  eori.l  #$7FFFFFFF,d0 ; Zahl im Einerkomplement negieren
  not.l   d1            ;
pos1:
  andi.l  #$7FF00000,d4 ; Ist Zahl gleich Null ( <=> Exponent gleich Null ) ?
  bne.s   notnull1      ; B: nein
  moveq   #0,d0         ; sonst auch Mantisse auf Null setzen
  moveq   #0,d1         ; ( keine denormalisierten Zahlen )
notnull1:
  move.l  d2,d4         ; das gleiche mit der zweiten Zahl
  bpl.s   pos2          ;
  eori.l  #$7FFFFFFF,d2 ;
  not.l   d3            ;
pos2:
  andi.l  #$7FF00000,d4 ;
  bne.s   notnull2      ;
  moveq   #0,d2         ;
  moveq   #0,d3         ;
notnull2:
  sub.l   d0,d2         ; obere Mantissenhaelften vergleichen
  bne.s   ende          ; B: Ergebnis ergibt sich bereits aus oberer Mantisse
  sub.l   d1,d3         ; hintere Matissenhaelften vergleichen

* Der Compiler baut hinter den Code fuer den Aufruf der Prozedur einen
* bedingten Sprung ein, der aber auf ein Ergebnis mit Zweierkomplement-
* Arithmetik abfragt ( BLT, BLE, BGE, BGT ), der zweite Teil der Mantisse
* hat aber kein Vorzeichen, sodass fuer diesen Teil auf einen
* Vergleich/Subtraktion vorzeichenloser Zahlen abgefragt werden muss
* ( CARRY-Bit ). Die folgenden Befehle uebernehmen also das
* Umwandeln des Ergebnisses einer UNSIGNED-Subtraktion ( nur CARRY-Bit
* beachten ) in ein Ergebnis fuer Zweierkomplement-Vergleich ( das
* Ergebnis der Exclusiv-Oder-Verknuepfung von NEGATIVE und OVERFLOW
* muss gleich dem Ergebnis von CARRY sein ).
*
* CARRY = 0  =>  NEGATIVE := 0, OVERFLOW := 0  <=> NEGATIVE xor OVERFLOW = 0
* CARRY = 1  =>  NEGATIVE := 1, OVERFLOW := 0  <=> NEGATIVE xor OVERFLOW = 1
*

  andi    #$FF-N_Bit-V_Bit,ccr  ; N- und V-Bit loeschen, C- und Z-Bit nicht
                                ; beeinflussen !
  bcc.s   ende      ; B: second >= first
  moveq   #-1,d3    ;    second <  first, NEGATIVE-Bit setzen, Zahlen koennen
                    ; nicht gleich sein, also ist ZERO-Bit egal
ende:

  unlk    a6
  movea.l (sp)+,a4
  movea.l (sp)+,a0
  lea     16(sp),sp
  jmp     (a0)
*)
INLINE( 2800H,6A08H,0A80H,7FFFH,0FFFFH,4681H,0284H,7FF0H,0000H );
INLINE( 6604H,7000H,7200H,2802H,6A08H,0A82H,7FFFH,0FFFFH,4683H );
INLINE( 0284H,7FF0H,0000H,6604H,7400H,7600H,9480H,660AH,9681H );
INLINE( 023CH,00F5H,6402H,76FFH,4E5EH,285FH,205FH,4FEFH,0010H );
INLINE( 4ED0H );

END FCMPd;


PROCEDURE FSHORT ( long : LONGREAL ): REAL;
(*T*)
(* Da die Originalroutine sowieso etwas umstaendlich programmiert
   war, habe ich lieber gleich eine neue geschrieben.
   Da im Original auch keine Register gerettet wurden, hab ichs
   hier auch nicht gemacht...
*)
BEGIN
(*
IEEEofl     EQU 3
HALTX       EQU -$00000020

long        EQU 12
RETURN      EQU long+8

FSHORT:
  movem.l long(A6),D0-D1
  moveq   #0,D2
  swap    D0                 ; Exponent, Vorzeichen ins untere Wort
  move.w  D0,D1              ; Vorzeichen in nicht ben. Mantisse aufbewahren
  swap    D1
  move.w  #$7FF0,D2
  and.w   D0,D2              ; d2 := Exponent
  andi.w  #$000F,D0          ; d0 : nur Mantisse
  swap    D0                 ;
  subi.w  #(1023-127)<<4,D2  ; Differenz von LONGREAL- und REAL-Bias
  lsl.l   #3,D0              ; Mantisse 3 Bits nach links
  rol.w   #3,D1              ; einschliesslich 3 Bit Uebertrag
  andi.b  #7,D1              ; von unterer Mantisse
  or.b    D1,D0              ;
  tst.w   D1                 ; muss aufgerundet werden ?
  bpl.s   tstexp             ; B: nein, Bit hinter Mantisse nicht gesetzt
  addq.l  #1,D0              ; sonst Mantisse aufrunden
  bclr    #23,D0             ; falls Mantisse $7FFFF war, Uebertrag loeschen
                             ; Mantisse ist dann Null, sodass nicht nach rechts
                             ; geschoben zu werden braucht
  beq.s   tstexp             ; B: kein Uebertrag
  addi.w  #1<<4,D2           ; sonst als Ausgleich fuer das "Schieben",
                             ; Exponent um eins erhoehen
tstexp:
  tst.w   D2                 ; Exponent <= Null ?
  ble.s   null               ; B: ja, zu klein fuer REAL
  cmpi.w  #254<<4,D2
  bhi.s   ofl                ; B: zu gross fuer REAL
  lsl.w   #3,D2              ; Exponent in richtige Position
  swap    D2
  or.l    D2,D0              ; im Ergebnis plazieren
  bra.s   return
null:
  moveq   #0,D0
  bra.s   ende
ofl:
  moveq   #IEEEofl,D0        ; Meldung: IEEE-Ueberlauf
  movea.l HALTX(A4),A3
  jsr     (A3)
  move.l  #$7F7FFFFF,D0
return:
  add.l   D0,D0
  add.l   D1,D1              ; Vorzeichen ins X/C-Bit
  roxr.l  #1,D0              ; und ins Ergebnis
ende:
  move.l  D0,RETURN(A6)

  unlk    A6
  movea.l (SP)+,A4
  movea.l (SP)+,A0
  addq.l  #8,SP
  jmp     (A0)
*)
INLINE( 4CEEH,0003H,000CH,7400H,4840H,3200H,4841H,343CH,7FF0H );
INLINE( 0C440H,0240H,000FH,4840H,0442H,3800H,0E788H,0E759H,0201H );
INLINE( 0007H,8001H,4A41H,6A0CH,5280H,0880H,0017H,6704H,0642H );
INLINE( 0010H,4A42H,6F0EH,0C42H,0FE0H,620CH,0E74AH,4842H,8082H );
INLINE( 6012H,7000H,6014H,7003H,266CH,0FFE0H,4E93H,203CH,7F7FH );
INLINE( 0FFFFH,0D080H,0D281H,0E290H,2D40H,0014H,4E5EH,285FH,205FH );
INLINE( 508FH,4ED0H );

END FSHORT;

(*---------------------------------------------------------------------------*)

PROCEDURE FLOATs ( lint : LONGINT ): REAL;
(* Das ist, bis auf die zusaetzliche Abfrage des
   Vorzeichens, die Originalroutine. Achtung! Sie
   darf kein einziges Byte laenger werden.
*)
BEGIN
(*
  lint    EQU 12
  RETURN  EQU lint+4

  FLOATs:
    move.w  d2,-(SP)
    move.l  lint(A6),D0
    beq.s   return         ; B: ganzzahlig Null = REAL-Null
    smi     D2             ; Vorzeichen merken
    bpl.s   tst16bit
    neg.l   D0             ; <int> positiv
  tst16bit:
    move.w  #127+31,D1     ; BIAS + max. Default-Exponent 2^31
    cmp.l   #$0000FFFF,D0  ; <int>  >  16 Bit ?
    bhi.s   tst24bit       ; B: ja
    swap    D0
    sub.w   #16,D1         ; sonst Exponent max. 2^15
  tst24bit:
    cmp.l   #$00FFFFFF,D0  ; <int>  >  24 ( 8 ) Bit ?
    bhi.s   norm           ; B: ja
    lsl.l   #8,D0
    subq.w  #8,D1          ; sonst Exponent max. 2^23 ( 2^7 )
  norm:
    add.l   D0,D0          ; Zahl normalisieren, implizite Eins weg
    dbcs    D1,norm
    move.b  D1,D0          ; Exponent ist Position des hoechstwertigen
                           ; gesetzten Bits ( das als impl. Eins rausfaellt )
    ror.l   #8,D0          ; Exponent ins oberste Byte
    lsr.l   #1,D0          ; Platz fuer ( positives ) Vorzeichen
    tst.b   D2             ; war <int> negativ ?
    beq.s   return         ; B: nein, ok
    bset    #31,D0         ; sonst negatives Vorzeichen setzen
  return:
    move.l  D0,RETURN(A6)
    move.w  (SP)+,D2

    unlk    A6             ; END FLOATs
    movea.l (SP)+,A4
    movea.l (SP)+,A0
    addq.l  #4,SP
    jmp     (A0)
*)
  INLINE( 3F02H,202EH,000CH,6738H,5BC2H,6A02H,4480H,323CH,009EH );
  INLINE( 0B0BCH,0000H,0FFFFH,6206H,4840H,927CH,0010H,0B0BCH,00FFH );
  INLINE( 0FFFFH,6204H,0E188H,5141H,0D080H,55C9H,0FFFCH,1001H,0E098H );
  INLINE( 0E288H,4A02H,6704H,08C0H,001FH,2D40H,0010H,341FH,4E5EH );
  INLINE( 285FH,205FH,588FH,4ED0H );

END FLOATs;

(*---------------------------------------------------------------------------*)

PROCEDURE FDIVd ( dividend, divisor : LONGREAL ): LONGREAL;
(*T*)
(* Da ich auch nach mehrmaligem Durchackern nicht imstande war
 * die Originalroutine in gaenze zu verstehen, geschweige denn
 * den Fehler zu finden, habe ich eine neue geschrieben, die zudem
 * noch den Vorteil hat, bis auf einige Spezialfaelle, schneller
 * zu sein als das Original.
 *
 * Die Routine funktioniert im wesentlichen wie die schriftliche
 * Division mit Papier und Bleistift:
 *
 * Der Divisor wird mit dem Dividenden verglichen und soweit
 * nach rechts verschoben, bis er ohne Uebertrag vom Dividenden
 * subtrahiert werden kann. Fuer jedes Rechtsschieben wird im
 * Ergebnis eine Null notiert; kann er subtrahiert werden, wird
 * eine eins notiert, denn entgegen der Division im Dezimalsystem,
 * bei der der Divisor bis zu neunmal im Dividenden enthalten sein
 * kann ( Zahlenbasis minus eins ), ist dies im Binaersystem nur
 * einmal moeglich.
 * Dieses Verfahren wird fortgesetzt, bis die gewuenschte Anzahl
 * der Ergebnisbits berechnet ist ( entgegen der Multiplikation
 * koennen die weiteren niederwertigen Bits keinen Uebertrag
 * erzeugen, sodass sie die Genauigkeit nicht beeinflussen ):
 *
 * Fuer LONGREAL-Zahlen werden benoetigt:
 *
 *    52 Bit explizite Mantisse
 *  +  1 Bit implizite eins
 *  +  1 GUARD-Bit, fuer eine evtl. Normalisierung ( Divisor > Dividend )
 *  +  1 ROUND-Bit, fuers Runden auf 1/2 LSB
 *  ----
 *  = 55 Bit
 *)

BEGIN
(*
;* Registerbenutzung:
;*   d0/d1 = Divisor-Mantisse
;*   d2/d3 = Dividend-Mantisse
;*   d4    = Verschiedenes ( Zaehler, Maske... )
;*   d5/d6 = Quotient-Mantisse
;*   d7    = Quotient-Exponent & Vorzeichen


IEEEofl     EQU 3
HALTX       EQU -$00000020

expmsk      EQU $00007FF0
BIAS        EQU 1023

divisor     EQU 12
dividend    EQU divisor+8
RETURN      EQU dividend+8

FDIVd:
  movem.l D4-D7,-(SP)
  movem.l divisor(A6),D0-D3 ; D0/D1 := Divisor, D2/D3 := Dividend
  swap    D0                ; Exponenten im unteren Wort fuer schnelleren
  swap    D2                ; Zugriff
  move.w  D0,D6
  move.w  D2,D7
  move.w  #expmsk,D4
  and.w   D4,D6             ; D6 := Exponent des Divisors
  beq     div0              ; B: Divisor Null = Division durch Null
  and.w   D4,D7             ; D7 := Exponent des Dividenden
  beq     null              ; B: Dividend Null = Ergebnis Null
  sub.w   D6,D7             ; Default-Exponent des Ergebnisses ist die
                            ; Differenz von Dividend- und Divisor-Exponent;
                            ; Das Ergebnis kann im Laufe der Berechnung um eins
                            ; nach oben ( falls Divisor > Dividend, und damit
                            ; eine Stelle verlorengeht ), und/oder um eins nach
                            ; unten korrigiert werden ( falls bei der Rundung
                            ; ein Ueberlauf auftritt ):
  asr.w   #4,D7             ; Exponent als INTEGER, damit die Addition des
                            ; Bias keine negative Zahl geben kann
  addi.w  #BIAS,D7          ; durch die Differenz ist der Bias rausgefallen
  bvs     ofl               ; B: Exponent-Ueberlauf kann nicht weit genug
                            ; nach unten korrigiert werden
  blt     ufl               ; B: Exponent-Unterlauf, kann nicht auf einen
                            ; gueltigen Exponenten korrigiert werden, ein
                            ; Exponent gleich Null kann aber evtl. noch auf
                            ; Eins korrigiert werden
  swap    D7                ; Vorzeichen des Ergebnisses im oberen Wort
  move.w  D0,D7             ; von D7 merken
  eor.w   D2,D7             ;
  swap    D7                ;
  moveq   #%00001111,D4     ; Exponent und Vorzeichen aus der Mantisse
  and.w   D4,D2             ; loeschen
  and.w   D4,D0             ;
  bne.s   implEins          ; B: Divisor keine Zweierpotenz
  swap    D0                ; restl. Mantisse auch testen
  tst.w   D0                ;
  bne.s   implEins0         ; B: Divisor keine Zweierpotenz
  tst.l   D1                ; untere Mantisse des Divisors auch Null ?
  bne.s   implEins          ; B: nein, normale Division
  move.l  D2,D5             ; Division durch eine Zweierpotenz ist lediglich
  move.l  D3,D6             ; eine Subtraktion der Exponenten
  bra     addexp

implEins0:
  swap    D0
implEins:
  moveq   #%00010000,D4     ; implizite Eins setzen, damit beginnen beide
  or.w    D4,D0             ; Mantissen mit einer Eins
  or.w    D4,D2
  swap    D0                ; Mantissen wieder in richtige Position
  swap    D2                ;
  moveq   #0,D5             ; alle Ergebnisbits loeschen
  moveq   #0,D6             ;
  moveq   #(52+1)+1+1-32-1,D4 ; erst mal die hoeherwertigen Bits
  bra.s   tstgt

shifthi:
  add.l   D3,D3             ; Dividend eine Stelle nach links
  addx.l  D2,D2             ;
tstgt:
  cmp.l   D0,D2             ; obere Mant. Dividend >= obere Mant. Divisor ?
  dbcc    D4,shifthi        ; B: nein, dann Dividend < Divisor
  blo.s   lomant            ; B: alle Bits berechnet
  sub.l   D1,D3             ; Dividend - Divisor
  subx.l  D0,D2             ;
  blo.s   zurueckhi         ; B: die untere Mant. des Divisors war groesser
                            ; also Subtraktion rueckgaengig machen
  bset    D4,D5             ; Ergebnisbit setzen
  bra.s   weiterhi          ; und naechstes Bit berechnen
zurueckhi:
  add.l   D1,D3             ; irrtuemliche Subtraktion rueckgaengig machen
  addx.l  D0,D2             ;
weiterhi:
  dbra    D4,shifthi        ; B: noch nicht alle Bits berechnet

lomant:
  moveq   #32-1,D4          ; die niederwertigen 32 Bits berechnen
shiftlo:                    ; wie oben...
  add.l   D3,D3
  addx.l  D2,D2
  cmp.l   D0,D2
  dbcc    D4,shiftlo
  blo.s   tstnorm
  sub.l   D1,D3
  subx.l  D0,D2
  blo.s   zuruecklo
  bset    D4,D6
  bra.s   weiterlo
zuruecklo:
  add.l   D1,D3
  addx.l  D0,D2
weiterlo:
  dbra    D4,shiftlo

tstnorm:
  btst    #22,D5          ; oberstes Bit der Mantisse gesetzt ?
  bne.s   round           ; B: ja, Mantisse ist normalisiert
  add.l   D6,D6           ; sonst ist bei der Division eine Stelle verloren-
  addx.l  D5,D5           ; gegangen, GUARD-Bit wird jetzt unterstes Bit der
                          ; Mantisse, damit Mantisse wieder normalisiert
  subq.w  #1,D7           ; das Links-Schieben der Mantisse muss durch
                          ; Verringern des Exponenten ausgeglichen werden

round:                    ; Runden der Mantisse auf naechstgelegene Zahl
                          ; durch Beruecksichtigung des Bits hinter dem
                          ; letzten Bit der Mantisse ( = ROUND-Bit, falls
                          ; normalisiert werden musste, sonst = GUARD-Bit )
  moveq   #0,D4           ; damit nur der evtl. Ueberlauf addiert wird
  addq.l  #2,D6           ;
  addx.l  D4,D5           ;
  btst    #23,D5          ; Ueberlauf beim Runden ?
  beq.s   mkreal          ; B: nein, ok
  lsr.l   #1,D5           ; sonst Mantisse eins nach rechts
  roxr.l  #1,D6           ;
  addq.w  #1,D7           ; und Exponent dafuer um eins erhoehen
mkreal:
  lsr.l   #1,D5           ;Mantisse um 2 Bits in die richtige Position schieben
  roxr.l  #1,D6           ;( GUARD- und ROUND-Bit, falls nicht normalisiert
  lsr.l   #1,D5           ; wurde,sonst ROUND-Bit und nachgeschobenes Null-Bit
  roxr.l  #1,D6           ; entfernen )
  swap    D5              ; fuer Wort-Zugriff
  andi.w  #$000F,D5       ; implizite Eins loeschen
tstexp:
  tst.w   D7              ; Exponent-Unterlauf ?
  ble.s   ufl             ; B: ja, Ergebnis ist Null
  cmpi.w  #$07FE,D7       ; Exponent-Ueberlauf ?
  bgt.s   ofl             ; B: ja, Meldung, MAX(LONGREAL) liefern
addexp:
  lsl.w   #4,D7           ; Exponent in die richtige Position
  or.w    D7,D5           ; und vor die Mantisse setzen
  swap    D5              ;
tstsign:
  tst.l   D7              ; Ergebnis-Vorzeichen setzen
  bpl.s   return          ;
  bset    #31,D5          ;
return:
  movem.l D5-D6,RETURN(A6)
  bra.s   ende

ufl:                      ; Unterlauf evtl. auch Meldung
null:                     ; nur bei Dividend = Null
  moveq   #0,D5           ; bei Unterlauf oder Null-Dividend ist das Ergebnis
  moveq   #0,D6           ; auch Null
  bra.s   return

div0:
  divu    #0,D0           ; Bei Division durch Null auch eine entsprechende
  bra.s   maxreal         ; Meldung und MAX(LONGREAL) liefern
ofl:
  moveq   #IEEEofl,D0     ; Meldung: IEEE-Ueberlauf
  movea.l HALTX(A4),A3
  jsr     (A3)
maxreal:
  move.l  #$7FEFFFFF,D5   ; bei Ueberlauf die groesste LONGREAL-Zahl
  moveq   #$FF,D6         ; liefern ( MAX(LONGREAL) )
  bra.s   tstsign

ende:                     ; END FDIVd :
  unlk    A6
  movea.l (SP)+,A4
  movea.l (SP)+,A0
  lea     2*8(SP),SP
  jmp     (A0)
*)
 INLINE(48E7H,0F00H,4CEEH,000FH,000CH,4840H,4842H,3C00H);
 INLINE(3E02H,383CH,7FF0H,0CC44H,6700H,00DEH,0CE44H,6700H);
 INLINE(00D2H,9E46H,0E847H,0647H,03FFH,6900H,00D2H,6D00H);
 INLINE(00C2H,4847H,3E00H,0B547H,4847H,780FH,0C444H,0C044H);
 INLINE(6614H,4840H,4A40H,660CH,4A81H,660AH,2A02H,2C03H);
 INLINE(6000H,008AH,4840H,7810H,8044H,8444H,4840H,4842H);
 INLINE(7A00H,7C00H,7816H,6004H,0D683H,0D582H,0B480H,54CCH);
 INLINE(0FFF8H,6512H,9681H,9580H,6504H,09C5H,6004H,0D681H);
 INLINE(0D580H,51CCH,0FFE4H,781FH,0D683H,0D582H,0B480H,54CCH);
 INLINE(0FFF8H,6512H,9681H,9580H,6504H,09C6H,6004H,0D681H);
 INLINE(0D580H,51CCH,0FFE4H,0805H,0016H,6606H,0DC86H,0DB85H);
 INLINE(5347H,7800H,5486H,0DB84H,0805H,0017H,6706H,0E28DH);
 INLINE(0E296H,5247H,0E28DH,0E296H,0E28DH,0E296H,4845H,0245H);
 INLINE(000FH,4A47H,6F1CH,0C47H,07FEH,6E22H,0E94FH,8A47H);
 INLINE(4845H,4A87H,6A04H,08C5H,001FH,48EEH,0060H,001CH);
 INLINE(601EH,7A00H,7C00H,60F2H,80FCH,0000H,6008H,7003H);
 INLINE(266CH,0FFE0H,4E93H,2A3CH,7FEFH,0FFFFH,7CFFH,60D2H);
 INLINE(4E5EH,285FH,205FH,4FEFH,0010H,4ED0H);
END FDIVd;

(*###########################################################################*)

PROCEDURE FileError;
BEGIN
  WriteLn;
  Write( ESC ); Write('p');
  WriteString('FEHLER BEIM BEARBEITEN DER DATEI! ABBRUCH.');
  Write( ESC ); Write('q');
  done := Fclose(file, file);
END FileError;


BEGIN
  allProcs := FALSE;

  (* Die ersten 32 Bytes der Original-FLOATs-Routine *)

  OrigFLOATs[ 0 ] := 2F0CH;
  OrigFLOATs[ 1 ] := 287AH;
  OrigFLOATs[ 2 ] := 0FAECH;
  OrigFLOATs[ 3 ] := 4E56H;
  OrigFLOATs[ 4 ] := 0000H;
  OrigFLOATs[ 5 ] := 202EH;
  OrigFLOATs[ 6 ] := 000CH;
  OrigFLOATs[ 7 ] := 4A80H;
  OrigFLOATs[ 8 ] := 672AH;
  OrigFLOATs[ 9 ] := 323CH;
  OrigFLOATs[ 10] := 009EH;
  OrigFLOATs[ 11] := 0B0BCH;
  OrigFLOATs[ 12] := 0000H;
  OrigFLOATs[ 13] := 0FFFFH;
  OrigFLOATs[ 14] := 6206H;
  OrigFLOATs[ 15] := 4840H;

  (* Die ersten 32 Bytes der Original-TRUNCd-Routine *)

  OrigTRUNCd[ 0 ] := 2F0CH;
  OrigTRUNCd[ 1 ] := 287AH;
  OrigTRUNCd[ 2 ] := 0F27CH;
  OrigTRUNCd[ 3 ] := 4E56H;
  OrigTRUNCd[ 4 ] := 0000H;
  OrigTRUNCd[ 5 ] := 48E7H;
  OrigTRUNCd[ 6 ] := 2100H;
  OrigTRUNCd[ 7 ] := 4CEEH;
  OrigTRUNCd[ 8 ] := 0003H;
  OrigTRUNCd[ 9 ] := 000CH;
  OrigTRUNCd[ 10] := 7400H;
  OrigTRUNCd[ 11] := 2E00H;
  OrigTRUNCd[ 12] := 6A04H;
  OrigTRUNCd[ 13] := 08C2H;
  OrigTRUNCd[ 14] := 001FH;
  OrigTRUNCd[ 15] := 0287H;


  (* Die ersten 32 Bytes der Original-FDIVd-Routine *)

  OrigFDIVd[ 0 ] := 2F0CH;
  OrigFDIVd[ 1 ] := 287AH;
  OrigFDIVd[ 2 ] := 0F656H;
  OrigFDIVd[ 3 ] := 4E56H;
  OrigFDIVd[ 4 ] := 0000H;
  OrigFDIVd[ 5 ] := 4CEEH;
  OrigFDIVd[ 6 ] := 0003H;
  OrigFDIVd[ 7 ] := 0014H;
  OrigFDIVd[ 8 ] := 4CEEH;
  OrigFDIVd[ 9 ] := 000CH;
  OrigFDIVd[ 10] := 000CH;
  OrigFDIVd[ 11] := 48E7H;
  OrigFDIVd[ 12] := 0F00H;
  OrigFDIVd[ 13] := 2800H;
  OrigFDIVd[ 14] := 0B584H;
  OrigFDIVd[ 15] := 2E00H;

  (* Die ersten 32 Bytes der Original-FSHORT-Routine *)

  OrigFSHORT[ 0 ] := 2F0CH;
  OrigFSHORT[ 1 ] := 287AH;
  OrigFSHORT[ 2 ] := 0F18CH;
  OrigFSHORT[ 3 ] := 4E56H;
  OrigFSHORT[ 4 ] := 0000H;
  OrigFSHORT[ 5 ] := 4CEEH;
  OrigFSHORT[ 6 ] := 0003H;
  OrigFSHORT[ 7 ] := 000CH;
  OrigFSHORT[ 8 ] := 7400H;
  OrigFSHORT[ 9 ] := 2E00H;
  OrigFSHORT[ 10] := 6A04H;
  OrigFSHORT[ 11] := 08C2H;
  OrigFSHORT[ 12] := 001FH;
  OrigFSHORT[ 13] := 0287H;
  OrigFSHORT[ 14] := 7FF0H;
  OrigFSHORT[ 15] := 0000H;

  (* Die ersten 32 Bytes der Original-FCMPd-Routine *)

  OrigFCMPd[ 0 ] := 2F0CH;
  OrigFCMPd[ 1 ] := 287AH;
  OrigFCMPd[ 2 ] := 0F398H;
  OrigFCMPd[ 3 ] := 4E56H;
  OrigFCMPd[ 4 ] := 0000H;
  OrigFCMPd[ 5 ] := 2800H;
  OrigFCMPd[ 6 ] := 6A0CH;
  OrigFCMPd[ 7 ] := 0A80H;
  OrigFCMPd[ 8 ] := 7FFFH;
  OrigFCMPd[ 9 ] := 0FFFFH;
  OrigFCMPd[ 10] := 0A81H;
  OrigFCMPd[ 11] := 0FFFFH;
  OrigFCMPd[ 12] := 0FFFFH;
  OrigFCMPd[ 13] := 0284H;
  OrigFCMPd[ 14] := 7FF0H;
  OrigFCMPd[ 15] := 0000H;

LOOP
  IF  ~allProcs  THEN
    Write( ESC ); Write('E');
    WriteString("Welche Datei soll 'gepatched' werden ?");
    WriteLn;
    WriteLn;
    WriteString('  1 = M2SHELL.OBM'); WriteLn;
    WriteString('  2 = SYSTEM.OBM');  WriteLn;
    WriteLn;
    WriteString('Abbruch mit jeder anderen Taste : ');
    Read( dat ); Write( dat );
    WriteLn;
    IF  ( dat < '1' ) OR ( dat > '2' ) THEN EXIT; END;

    WriteLn;
    WriteString("Welche Prozedur soll 'gepatched' werden ?");
    WriteLn;
    WriteLn;
    WriteString('  1 = FLOATs  ( Korrektur )'); WriteLn;
    WriteString('  2 = FDIVd   ( Korrektur )'); WriteLn;
    WriteString('  3 = FSHORT  ( Korrektur )'); WriteLn;
    WriteString('  4 = FCMPd   ( Korrektur )'); WriteLn;
    WriteString('  5 = TRUNCd  ( Korrektur )'); WriteLn;
    WriteLn;
    WriteString('  6 = alle fÅnf'); WriteLn;
    WriteLn;
    WriteString('Abbruch mit jeder anderen Taste : ');
    Read( proc ); Write( proc );
    IF  ( proc < '1' ) OR ( proc > '6' ) THEN EXIT; END;
    WriteLn;
    WriteLn;
    WriteLn;

    IF  proc = '6'  THEN
      allProcs := TRUE;
      proc     := '1';
    END;
  END;

  IF    proc = '1'  THEN
    prozedur  := 'FLOATs';
    schreiben := LenNewFLOATs;
    patchAdr  := ADR( FLOATs ) + VAL( ADDRESS, LenProcHead );
    offset    := OffsetFLOATs;
    OrigCode  := OrigFLOATs;
  ELSIF proc = '2' THEN
    prozedur  := 'FDIVd';
    schreiben := LenNewFDIVd;
    patchAdr  := ADR( FDIVd ) + VAL( ADDRESS, LenProcHead );
    offset    := OffsetFDIVd;
    OrigCode  := OrigFDIVd;
  ELSIF proc = '3'  THEN
    prozedur  := 'FSHORT';
    schreiben := LenNewFSHORT;
    patchAdr  := ADR( FSHORT ) + VAL( ADDRESS, LenProcHead );
    offset    := OffsetFSHORT;
    OrigCode  := OrigFSHORT;
  ELSIF proc = '4'  THEN
    prozedur  := 'FCMPd';
    schreiben := LenNewFCMPd;
    patchAdr  := ADR( FCMPd ) + VAL( ADDRESS, LenProcHead );
    offset    := OffsetFCMPd;
    OrigCode  := OrigFCMPd;
  ELSE
    prozedur  := 'TRUNCd';
    schreiben := LenNewTRUNCd;
    patchAdr  := ADR( TRUNCd ) + VAL( ADDRESS, LenProcHead );
    offset    := OffsetTRUNCd;
    OrigCode  := OrigTRUNCd;
  END;


  IF  dat = '1'  THEN
    datei  := 'M2SHELL.OBM';
    INC( offset, ShellOffset );
  ELSE
    datei  := 'SYSTEM.OBM';
  END;


  done := Fopen(ADR(datei), 2, file);
  IF  ~done  THEN
    Write( ESC ); Write('p');
    WriteString('DATEI WURDE NICHT GEFUNDEN ODER IST SCHREIBGESCHöTZT,');
    WriteLn;
    WriteString('BITTE INS AKTUELLE VERZEICHNIS KOPIEREN ODER SCHREIBSCHUTZ ');
    WriteString('ENTFERNEN.');
    Write( ESC ); Write('q');
    WriteLn;
    Read( ch );
    RETURN;
  END;

  done := Fseek(offset, file, 0, position);
  IF  ~done  THEN
    FileError;
    RETURN;
  END;

  vergleich := ADR( CompareCode );
  einlesen  := SIZE( CompareCode );

  done := Fread(file, einlesen, vergleich, gelesen);
  IF  ~done  OR ( einlesen # gelesen )  THEN
    FileError;
    RETURN;
  END;
(*
  FOR  i := 0  TO  HIGH( CompareCode )  DO
    IF  CompareCode[ i ] # OrigCode[ i ]  THEN
      WriteLn;
      Write( ESC ); Write('p');
      WriteString('DIE ZU PATCHENDE ROUTINE LIEGT NICHT AN DER VORGESEHENEN ');
      WriteString('STELLE,');
      WriteLn;
      WriteString('ODER WURDE SCHON GEPATCHED !');
      WriteLn;
      Write( ESC ); Write('q');
      done := Fclose(file, file);
      Read( ch );
      RETURN;
    END;
  END;
*)
  INC( offset, LenProcHead );
  done := Fseek(offset, file, 0, position);
  IF  ~done  THEN
    FileError;
    RETURN;
  END;

  done := Fwrite(file, schreiben, patchAdr, geschrieben);
  IF  ~done  OR ( schreiben # geschrieben )  THEN
    FileError;
    RETURN;
  END;

  done := Fclose(file, file);
  IF  ~done  THEN
    FileError;
    RETURN;
  END;

  WriteString('>>');
  WriteString( prozedur );
  WriteString('<<  in  >>');
  WriteString( datei );
  WriteString('<<  wurde gepatched.');
  WriteLn;

  IF  allProcs & ( proc < '5' ) THEN
    INC( proc );
  ELSE
    allProcs := FALSE;
    WriteLn;
    WriteString('Weiter (j/n) ?');
    Read( ch ); Write( ch );
    IF  CAP( ch ) # 'J'  THEN  EXIT  END;
  END;

END; (* LOOP *)

END RtsPatch.
