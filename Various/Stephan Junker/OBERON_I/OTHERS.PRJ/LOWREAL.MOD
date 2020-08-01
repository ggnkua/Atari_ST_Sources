MODULE LowReal;
(*$-K no stack checks *)
(*$-C no entry code *)
(*$+X extensions *)
(*****************************************************************************)
(* M2-ISO-LowReal, STJ-Oberon-2-Version                                      *)
(* --------------------------------------------------------------------------*)
(* Zugriff auf die Interna reeller Zahlen                                    *)
(* --------------------------------------------------------------------------*)
(* 15-Okt-95, Holger Kleinschmidt                                            *)
(*****************************************************************************)

(* Fuer eine Implementierung dieses Moduls brauchen nicht unbedingt alle
 * Funktionen ``zu Fuss'' implementiert zu werden. Moeglicherweise
 * lassen sich folgende Aequivalenzen ausnutzen (kommt auch auf die
 * interne Real-Darstellung an!):
 *
 * basemant   ::= fraction(1.0);
 * baseexpo   ::= exponent(1.0);
 * unit(x, p) ::= scale(basemant, exponent(x) - p + 1)
 *
 * ulp(x)          = unit(x, places)
 * succ(x)         = x + ulp(x)
 * pred(x)         = x - ulp(x)
 * intpart(x)      = trunc(x, exponent(x) - baseexpo + 1)
 * fractpart(x)    = x - intpart(x)
 * synthesize(e,f) = scale(f, e)
 * round(x,p) =
 *     int  := trunc(x, i);
 *     rest := x - int;
 *     rnd  := unit(x, i + 1);
 *     last := unit(x, i);
 *
 *     IF rest >= rnd THEN
 *       int + last
 *     ELSE
 *       int
 *     END
 *
 * Wenn alle diese Aequivalenzen verwendet werden, muessen lediglich
 * 'fraction', 'exponent', 'scale' und 'trunc' implementiert werden.
 *)

IMPORT S:=SYSTEM;

(* Die folgenden Konstanten gelten fuer die interne Defaultdarstellung reeller
   Zahlen, falls es mehrere Moeglichkeiten gibt, und auch nur fuer die
   Darstellung gespeicherter Werte.

  radix      : Basis der verwendeten Zahlendarstellung
  places     : Anzahl der 'radix'-Stellen zur Speicherung der Werte
  expoMin    : Kleinstmoeglicher Exponent
  expoMax    : Groesstmoeglicher Exponent
  large      : Groesste darstellbare Zahl
  small      : Kleinste (normalisierte) darstellbare Zahl
  IEC559     : vollstaendig IEC 559:1989 (IEEE 754:1987) kompatibel, d.h.
               NaN, neg. Null usw.
  LIA1       : vollstaendig ISO 10967-1:199x-kompatibel,
               (Information technology -- Language Independent Arithmetic)
  rounds     : Liefert jede Operation die dem mathematischen Resultat
               naechstmoegliche Darstellung ?
  gUnderflow : Gibt es Werte zwischen 0.0 und 'small' (denormalisierte Zahlen) ?
  exception  : Loest jede Operation, die ein Resultat ausserhalb des
               Wertebereichs erzeugt, eine Ausnahme aus ?
  extend     : Werden Werte mit einer hoeheren Genauigkeit berechnet als
               gespeichert ?
  nModes     : Anzahl der Bits, die fuer das Statusfeld benoetigt werden
 *)

CONST
  radix*      = 2;
  places*     = 24; (* 23 + 'hidden bit' *)
  expoMin*    = -126;
  expoMax*    = 127;
  large*      = S.VAL(REAL,7F7FFFFFH);
  small*      = S.VAL(REAL,00800000H);
  IEC559*     = FALSE;
  LIA1*       = FALSE;
  rounds*     = FALSE;
  gUnderflow* = FALSE;
  exception*  = FALSE;
  extend*     = FALSE;
  nModes*     = 1;

TYPE
  Modes* = SET;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE exponent* ((* EIN/ -- *) x : REAL ): INTEGER;

(* Liefert den Exponenten von <x> im Bereich [expoMin..expoMax].
   Fuer <x> = 0.0 wird Null geliefert.
 *)

BEGIN
 ASSEMBLER
   MOVE.W  #$7F80,D0
   AND.W   4(SP),D0
   BEQ.B   ende
   LSR.W   #7,D0
   SUBI.W  #127,D0
 ende:
   RTS
 END;
END exponent;

(*---------------------------------------------------------------------------*)

PROCEDURE fraction* ((* EIN/ -- *) x : REAL ): REAL;

(* Liefert den signifikanten Teil (Mantisse) von <x> *)

BEGIN
 ASSEMBLER
   MOVE.L  4(SP),D0
   SWAP    D0
   MOVE.W  #$7F80,D1
   AND.W   D0,D1
   BNE.B   norm
   MOVEQ   #0,D0
   BRA.B   ende
norm:
   ANDI.W #$FFFF-$7F80,D0
   ORI.W   #$3F80,D0
   SWAP    D0
ende:
   FMOVE.S D0,FP0
   RTS
 END;
END fraction;

(*---------------------------------------------------------------------------*)

PROCEDURE sign* ((* EIN/ -- *) x : REAL ): REAL;

(* Liefert folgende Werte.

   -1.0, falls <x> kleiner als Null
    1.0, falls <x> groesser als Null
   und 1.0 oder -1.0, falls x gleich 0.0, um zwischen +0.0 und
   -0.0 unterscheiden zu koennen, falls die Darstellung reeller
   Zahlen dies erlaubt.
 *)

BEGIN
 ASSEMBLER
   MOVE.L  #$7F000000,D0
   MOVE.W  4(SP),D1
   LSL.W   #1,D1
   ROXR.L  #1,D0
   FMOVE.S D0,FP0
   RTS
 END;
END sign;

(*---------------------------------------------------------------------------*)

PROCEDURE succ* ((* EIN/ -- *) x : REAL ): REAL;

(* Liefert den naechstgroesseren Wert von <x>, falls dieser existiert,
   sonst +Inf.
 *)

BEGIN
 ASSEMBLER
   MOVE.L  4(SP),D0
   MOVE.W  #$7F80,D2
   MOVE.L  D0,D1
   SWAP    D1
   AND.W   D2,D1
   BEQ.B   min
   CMP.W   D2,D1
   BEQ.B   ende
   TST.L   D0
   BMI.B   sub
   ADDQ.L  #1,D0
   BRA.B   ende
 min:
   MOVE.L  #$00800000,D0
   BRA.B   ende
 sub:
   SUBQ.L  #1,D0
   CMPI.L  #$807FFFFF,D0
   BNE.B   ende
   MOVEQ   #0,D0
 ende:
   FMOVE.S D0,FP0
   RTS
 END;
END succ;

(*---------------------------------------------------------------------------*)

PROCEDURE ulp* ((* EIN/ -- *) x : REAL ): REAL;

(* Liefert den Wert der letzten Stelle von <x>.
   (ulp <=> Unit in the Last Place.)

   Es gilt: ulp(x) = succ(x) - x, oder ulp(x) = x - pred(x), oder beides.
 *)

BEGIN
 ASSEMBLER
   MOVE.W  4(SP),D1
   MOVE.W  #$7F80,D0
   AND.W   D1,D0
   BEQ.B   null
   CMPI.W  #$0C00,D0 ; (1+23)<<7
   BLT.B   null
   SUBI.W  #$0B80,D0 ; 23<<7
   SWAP    D0
   CLR.W   D0
   BRA.B   ende
null:
   MOVEQ   #0,D0
ende:
   FMOVE.S D0,FP0
   RTS
 END;
END ulp;

(*---------------------------------------------------------------------------*)

PROCEDURE pred* ((* EIN/ -- *) x : REAL ): REAL;

(* Liefert den naechstkleineren Wert von <x>, falls dieser existiert,
   sonst -Inf.
 *)

BEGIN
 ASSEMBLER
   MOVE.L  4(SP),D0
   MOVE.W  #$7F80,D2
   MOVE.L  D0,D1
   SWAP    D1
   AND.W   D2,D1
   BEQ.B   min
   CMP.W   D2,D1
   BEQ.B   ende
   TST.L   D0
   BPL.B   sub
   ADDQ.L  #1,D0
   BRA.B   ende
 min:
   MOVE.L  #$80800000,D0
   BRA.B   ende
 sub:
   SUBQ.L  #1,D0
   CMPI.L  #$007FFFFF,D0
   BNE.B   ende
   MOVEQ   #0,D0
 ende:
   FMOVE.S D0,FP0
   RTS
 END;
END pred;

(*---------------------------------------------------------------------------*)

PROCEDURE intpart* ((* EIN/ -- *) x : REAL ): REAL;

(* Liefert den ganzzahligen Anteil von <x>. Falls <x> negativ ist, wird
   -intpart(abs(x)) zurueckgeliefert.
 *)

BEGIN
 ASSEMBLER
   MOVE.L  4(SP),D0
   MOVE.L  #$FFFFF000,D1
   MOVE.L  D0,D2
   SWAP    D2
   ANDI.W  #$7F80,D2
   CMPI.W  #$3F80,D2 ; (127+0)<<7
   BLT.B   null
   CMPI.W  #$4B00,D2 ; (127+23)<<7
   BGE.B   ende
   LSR.W   #7,D2
   SUBI.W  #127+11,D2
   BPL.B   shr
   NEG.W   D2
   LSL.L   D2,D1
   BRA.B   mask
 shr:
   ASR.L   D2,D1
 mask:
   AND.L   D1,D0
   BRA.B   ende
 null:
   MOVEQ   #0,D0
 ende:
   FMOVE.S D0,FP0
   RTS
 END;
END intpart;

(*---------------------------------------------------------------------------*)

PROCEDURE fractpart* ((* EIN/ -- *) x : REAL ): REAL;

(* Liefert den gebrochenen Anteil von <x>.

   Es gilt: x = intpart(x) + fractpart(x).
 *)

BEGIN
 ASSEMBLER
   MOVE.L  4(SP),D0
   MOVE.W  #23,D3
   MOVE.L  D0,D2
   SWAP    D2
   LSR.W   #7,D2
   MOVE.W  D2,D1          ; Exponent bis spaeter aufbewahren
   ANDI.W  #$00FF,D2      ; Vorzeichen loeschen
   CMPI.W  #127+0,D2      ; Zahl kleiner eins -> alles fractpart
   BLT.B   ende
   CMPI.W  #127+23,D2     ; intpart groesser gleich 53+1 Bit -> fractpart = 0
   BGE.B   null
   SUBI.W  #127-1,D2      ; D2 in [1..23] -- um soviele Stellen mindestens
;                           nach links schieben

; erstes gesetztes Bit von links in fractpart suchen, fuer Normalisierung.
; max. 23 - <D2> + 1 Bits testen

   SUB.W   D3,D2          ; zu schiebende Stellen in Bitnummer umrechnen
   NEG.W   D2             ;
ffs:                      ; erstes gesetztes Bit in D0 suchen
   BTST    D2,D0          ;
   DBNE    D2,ffs         ;
   BEQ.B   null           ; kein Bit im fractpart gesetzt -> fractpart = 0
   SUB.W   D3,D2          ; Bitnummer in zu schiebende Stellen umrechnen
   NEG.W   D2             ;
   SUB.W   D2,D1          ; Exponent fuer normalisierten fractpart berechnen
   LSL.W   #7,D1          ;
tst16:
   CMPI.W  #16,D2         ; mindestens 16 Positionen nach links ?
   BLT.B   shl            ; B: nein
   SWAP    D0             ; schnelles Linksschieben um 16 Positionen
   CLR.W   D0             ;
   SUBI.W  #16,D2         ; 16 Positionen weniger zu schieben
shl:
   LSL.L   D2,D0          ; restliche Positionen nach links schieben

   SWAP    D0             ; Exponent einfuegen
   ANDI.W  #$007F,D0      ;
   OR.W    D1,D0          ;
   SWAP    D0             ;
   BRA.B   ende
null:
   MOVEQ   #0,D0
ende:
   FMOVE.S D0,FP0
   RTS
 END;
END fractpart;

(*---------------------------------------------------------------------------*)

PROCEDURE scale* ((* EIN/ -- *) x : REAL;
                  (* EIN/ -- *) n : INTEGER  ): REAL;

(* Liefert: x * radix^n, falls ein solcher Wert existiert, sonst
   +Inf oder 0.0.
 *)

BEGIN
 ASSEMBLER
   MOVE.W  6(SP),D1
   MOVE.L  #$00007F80,D0
   AND.W   D1,D0
   BEQ.B   null
   LSR.W   #7,D0
   ADD.W   4(SP),D0
   BVS.B   max
   BLE.B   null
   CMPI.L  #127+127,D0
   BGT.B   max
   LSL.W   #7,D0
   ANDI.W  #$FFFF-$7F80,D1
   OR.W    D1,D0
   SWAP    D0
   MOVE.W  8(SP),D0
   BRA.B   ende
null:
   MOVEQ   #0,D0
   BRA.B   ende
max:
   MOVE.L  #$FF000000,D0
   LSL.W   #1,D1
   ROXR.L  #1,D0
ende:
   FMOVE.S D0,FP0
   RTS
 END;
END scale;

(*---------------------------------------------------------------------------*)

PROCEDURE trunc* ((* EIN/ -- *) x : REAL;
                  (* EIN/ -- *) n : INTEGER  ): REAL;

(* Liefert die <n> hoechstwertigen signifikanten Stellen von <x>.
   Falls n <= 0, wird 0.0 geliefert.
 *)

BEGIN
 ASSEMBLER
   MOVE.L  6(SP),D0
   MOVE.L  #$FFFFF000,D1
   MOVE.L  D0,D2
   SWAP    D2
   ANDI.L  #$00007F80,D2
   BEQ.B   null
   CMPI.W  #$7F80,D2
   BEQ.B   ende
   MOVE.W  4(SP),D2
   BLE.B   null
   CMPI.L  #24,D2
   BGE.B   ende
   SUBI.W  #1+11,D2
   BPL.B   shr1
   NEG.W   D2
   LSL.L   D2,D1
   BRA.B   mask1
shr1:
   ASR.L   D2,D1
mask1:
   AND.L   D1,D0
   BRA.B   ende
null:
   MOVEQ   #0,D0
ende:
   FMOVE.S D0,FP0
   RTS
 END;
END trunc;

(*---------------------------------------------------------------------------*)

PROCEDURE round* ((* EIN/ -- *) x : REAL;
                  (* EIN/ -- *) n : INTEGER  ): REAL;

(* Liefert <x> auf die <n> hoechstwertigen signifikanten Stellen gerundet.
   Falls n <= 0, wird 0.0 geliefert.
 *)

BEGIN
 ASSEMBLER
   MOVE.L  6(SP),D0
   MOVE.L  #$FFFFF000,D1
   MOVE.L  D0,D2
   SWAP    D2
   ANDI.L  #$00007F80,D2
   BEQ.B   null
   CMPI.W  #$7F80,D2
   BEQ.B   ende
   MOVE.W  4(SP),D2
   BLE.B   null
   CMPI.L  #24,D2
   BGE.B   ende
   SUBQ.W  #1,D2          ; D2: Anzahl zu erhaltender Bits [0..22]
   MOVE.W  D2,D3          ;
   SUBI.W  #11,D2
   BPL.B   shr
   NEG.W   D2
   LSL.L   D2,D1
   BRA.B   rnd
shr:
   ASR.L   D2,D1
rnd:
   SUBI.W  #22,D3         ; Nummer des hoechstwertigen Rundungsbit
   NEG.W   D3             ;
   MOVE.W  D3,D2
   ADDQ.W  #1,D2          ; letztes zu erhaltenden Bit, evtl. impl. Eins
   BTST    D3,D0          ; hoechstwertiges Rundungsbit gesetzt ?
   BEQ.B   trnc           ; B: nein, kleiner 0.5, abrunden
   MOVE.L  D1,D3          ; Maske fuer die restlichen Rundungsbit, ausser dem
   NOT.L   D3             ;   hoechstwertigen
   LSR.L   #1,D3          ;
   AND.L   D0,D3          ; weitere Rundungsbits gesetzt ?
   BNE.B   up             ; B: ja, groesser 0.5, aufrunden
; Rest genau 0.5, auf naechste GERADE Zahl runden
   CMPI.W  #23,D2         ; implizite Eins einziges zu erhaltendes Bit ?
   BEQ.B   up             ; B: ja, aufrunden, da ungerade
   BTST    D2,D0          ; letztes zu erhaltendes Bit gesetzt ?
   BEQ.B   trnc           ; B: nein, nicht aufrunden
up:
   MOVE.L  D1,D3          ; Maske fuer letztes zu erhaltendes Bit
   LSL.L   #1,D3
   EOR.L   D1,D3
   ADD.L   D3,D0          ; Eins auf letztes zu erhaltendes Bit addieren
trnc:
   AND.L   D1,D0          ; restliche Stellen abschneiden
   BRA.B   ende
null:
   MOVEQ   #0,D0
ende:
   FMOVE.S D0,FP0
   RTS
 END;
END round;
(*$+K *)
(*$+C *)
(*---------------------------------------------------------------------------*)

PROCEDURE synthesize* ((* EIN/ -- *) expart  : INTEGER;
                       (* EIN/ -- *) frapart : REAL    ): REAL;

(* Setzt einen Wert aus <frapart> und <expart> zusammen.

   Es gilt: x = synthesize(exponent(x), fraction(x))
 *)

BEGIN
 RETURN(scale(frapart, expart));
END synthesize;

(*---------------------------------------------------------------------------*)

PROCEDURE setMode* ((* EIN/ -- *) m : Modes );

(* Setzt die Statusflags auf den Wert <m> entsprechend der verwendeten
   Gleitkommaarithmetik.
 *)

BEGIN
END setMode;

(*---------------------------------------------------------------------------*)

PROCEDURE currentMode* ( ): Modes;

(* Liefert die momentane Einstellung der Statusflags *)

BEGIN
 RETURN({});
END currentMode;

END LowReal.
