MODULE LowLong;
(*$-K no stack checks *)
(*$+X extensions *)
(*****************************************************************************)
(* M2-ISO-LowLong, STJ-Oberon-2-Version                                      *)
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

VAR lrc : RECORD
      lc1 : LONGINT;
      lc2 : LONGINT;
    END;

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
  places*     = 53; (* 52 + 'hidden bit' *)
  expoMin*    = -1022;
  expoMax*    = 1023;
VAR
  large-      : LONGREAL;
  small-      : LONGREAL;
CONST
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
(*$-C no entry code *)
PROCEDURE exponent* ((* EIN/ -- *) x : LONGREAL ): INTEGER;
BEGIN
 ASSEMBLER
   MOVE.W  #$7FF0,D0
   AND.W   4(SP),D0
   BEQ.B   ende
   LSR.W   #4,D0
   SUBI.W  #1023,D0
ende:
   RTS
 END;
END exponent;
(*$+C *)

(*---------------------------------------------------------------------------*)

PROCEDURE fraction* ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

VAR tmp : LONGREAL;

BEGIN
 ASSEMBLER
   MOVEM.L x,D0-D1
   SWAP    D0
   MOVE.W  #$7FF0,D2
   AND.W   D0,D2
   BNE.B   norm
   MOVEQ   #0,D0
   MOVEQ   #0,D1
   BRA.B   ende
norm:
   ANDI.W  #$FFFF-$FFF0,D0
   ORI.W   #$3FF0,D0
   SWAP    D0
ende:
(*
   MOVEM.L D0/D1,-(SP)
   FMOVE.D (SP)+,FP0
*)
   MOVEM.L D0/D1,tmp
   FMOVE.D tmp,FP0
   RETURN
 END;
END fraction;

(*---------------------------------------------------------------------------*)

PROCEDURE sign* ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

VAR tmp : LONGREAL;

BEGIN
 ASSEMBLER
   MOVE.L  #$7FE00000,D0
   MOVE.W  x,D2
   LSL.W   #1,D2
   ROXR.L  #1,D0
   MOVEQ   #0,D1
(*
   MOVEM.L D0/D1,-(SP)
   FMOVE.D (SP)+,FP0
*)
   MOVEM.L D0/D1,tmp
   FMOVE.D tmp,FP0
   RETURN
 END;
END sign;

(*---------------------------------------------------------------------------*)

PROCEDURE succ* ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

VAR tmp : LONGREAL;

BEGIN
 ASSEMBLER
   MOVEM.L x,D0-D1
   MOVE.L  D0,D2
   SWAP    D2
   ANDI.W  #$7FF0,D2
   BEQ.B   min
   CMPI.W  #$7FF0,D2
   BEQ.B   ende
   TST.L   D0
   BMI.B   sub
   ADDQ.L  #1,D1
   BCC.B   ende
   ADDQ.L  #1,D0
   BRA.B   ende
min:
   MOVEQ   #0,D1
   MOVE.L  #$00100000,D0
   BRA.B   ende
sub:
   SUBQ.L  #1,D1
   BCC.B   ende
   SUBQ.L  #1,D0
   CMPI.L  #$800FFFFF,D0
   BNE.B   ende
   MOVEQ   #0,D0
   MOVEQ   #0,D1
ende:
(*
   MOVEM.L D0/D1,-(SP)
   FMOVE.D (SP)+,FP0
*)
   MOVEM.L D0/D1,tmp
   FMOVE.D tmp,FP0
   RETURN
 END;
END succ;

(*---------------------------------------------------------------------------*)

PROCEDURE ulp* ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

VAR tmp : LONGREAL;

BEGIN
 ASSEMBLER
   MOVE.W  x,D1
   MOVE.W  #$7FF0,D0
   AND.W   D1,D0
   BEQ.B   null
   CMPI.W  #$0350,D0     ;1+52<<4
   BLT.B   null
   SUBI.W  #$0340,D0     ;52<<4
   SWAP    D0
   CLR.W   D0
   BRA.B   ende
null:
   MOVEQ   #0,D0
ende:
   MOVEQ   #0,D1
(*
   MOVEM.L D0/D1,-(SP)
   FMOVE.D (SP)+,FP0
*)
   MOVEM.L D0/D1,tmp
   FMOVE.D tmp,FP0
   RETURN
 END;
END ulp;

(*---------------------------------------------------------------------------*)

PROCEDURE pred* ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

VAR tmp : LONGREAL;

BEGIN
 ASSEMBLER
   MOVEM.L x,D0-D1
   MOVE.L  D0,D2
   SWAP    D2
   ANDI.W  #$7FF0,D2
   BEQ.B   min
   CMPI.W  #$7FF0,D2
   BEQ.B   ende
   TST.L   D0
   BPL.B   sub
   ADDQ.L  #1,D1
   BCC.B   ende
   ADDQ.L  #1,D0
   BRA.B   ende
min:
   MOVEQ   #0,D1
   MOVE.L  #$80100000,D0
   BRA.B   ende
sub:
   SUBQ.L  #1,D1
   BCC.B   ende
   SUBQ.L  #1,D0
   CMPI.L  #$000FFFFF,D0
   BNE.B   ende
   MOVEQ   #0,D0
   MOVEQ   #0,D1
ende:
(*
   MOVEM.L D0/D1,-(SP)
   FMOVE.D (SP)+,FP0
*)
   MOVEM.L D0/D1,tmp
   FMOVE.D tmp,FP0
   RETURN
 END;
END pred;

(*---------------------------------------------------------------------------*)

PROCEDURE intpart* ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

VAR tmp : LONGREAL;

BEGIN
 ASSEMBLER
   MOVEM.L x,D0-D1
   MOVE.L  D0,D2
   SWAP    D2
   ANDI.W  #$7FF0,D2
   CMPI.W  #$3FF0,D2     ;1023+0<<4
   BLT.B   null
   CMPI.W  #$4330,D2     ;1023+52<<4
   BGE.B   ende
   LSR.W   #4,D2
   SUBI.W  #1023,D2
   CMPI.W  #20,D2
   BGT.B   mant2
   MOVE.L  #$FFFFFC00,D1
   SUBI.W  #10,D2
   BPL.B   shr1
   NEG.W   D2
   LSL.L   D2,D1
   BRA.B   mask1
shr1:
   ASR.L   D2,D1
mask1:
   AND.L   D1,D0
   MOVEQ   #0,D1
   BRA.B   ende
mant2:
   MOVEQ   #$FF,D3
   CLR.W   D3
   SUBI.W  #36,D2
   BPL.B   shr2
   NEG.W   D2
   LSL.L   D2,D3
   BRA.B   mask2
shr2:
   ASR.L   D2,D3
mask2:
   AND.L   D3,D1
   BRA.B   ende
null:
   MOVEQ   #0,D0
   MOVEQ   #0,D1
ende:
(*
   MOVEM.L D0/D1,-(SP)
   FMOVE.D (SP)+,FP0
*)
   MOVEM.L D0/D1,tmp
   FMOVE.D tmp,FP0
   RETURN
 END;
END intpart;

(*---------------------------------------------------------------------------*)

PROCEDURE fractpart* ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

VAR tmp : LONGREAL;

BEGIN
 ASSEMBLER
   MOVEM.L x,D0-D1
   MOVE.L  D0,D2
   SWAP    D2
   LSR.W   #4,D2
   MOVE.W  D2,D3         ; Exponent bis spaeter aufbewahren
   ANDI.W  #$07FF,D2     ; Vorzeichen ausblenden
   CMPI.W  #1023+0,D2    ; Zahl kleiner eins -> alles fractpart
   BLT     ende
   CMPI.W  #1023+52,D2   ; intpart groesser gleich 52+1 Bit -> fractpart = 0
   BGE     null
   SUBI.W  #1023-1,D2    ; D2 in [1..52] -- um soviele Stellen mindestens
;                          nach links schieben

; erstes gesetztes Bit von links in fractpart suchen, fuer Normalisierung.
; max. 52 - <D2> + 1 Bits testen

   CMPI.W  #20,D2
   BGT.B   sffs2         ; fractpart beginnt erst in D1
   SUBI.W  #20,D2        ; zu schiebende Stellen in Bitnummer umrechnen
   NEG.W   D2            ;
ffs1:                    ; erstes gesetztes Bit in D0 suchen
   BTST    D2,D0         ;
   DBNE    D2,ffs1       ;
   BEQ.B   tst2          ; in D0 kein Bit gesetzt, mit D1 versuchen
   SUBI.W  #20,D2        ; Bitnummer in zu schiebende Stellen umrechnen
   NEG.W   D2            ;
   BRA.B   tst32         ; jetzt zum Schieben
tst2:
   MOVE.W  #21,D2
sffs2:
   SUBI.W  #20+32,D2     ; zu schiebende Stellen in Bitnummer umrechnen
   NEG.W   D2            ;
ffs2:                    ; erstes gesetztes Bit in D1 suchen
   BTST    D2,D1         ;
   DBNE    D2,ffs2       ;
   BEQ.B   null          ; kein Bit im fractpart gesetzt -> fractpart = 0
   SUBI.W  #20+32,D2     ; Bitnummer in zu schiebende Stellen umrechnen
   NEG.W   D2            ;

tst32:
   SUB.W   D2,D3         ; Exponent fuer normalisierten fractpart berechnen
   LSL.W   #4,D3         ;
   CMPI.W  #32,D2        ; mindestens 32 Positionen nach links ?
   BLT.B   tst16         ; B: nein
   MOVE.L  D1,D0         ; schnelles Linksschieben um 32 Positionen
   MOVEQ   #0,D1         ;
   SUBI.W  #32,D2        ; 32 Positionen weniger zu schieben
tst16:
   CMPI.W  #16,D2        ; mindestens 16 Positionen nach links ?
   BLT.B   tst8          ; B: nein
   SWAP    D0            ; schnelles Linksschieben um 16 Positionen
   SWAP    D1            ;
   MOVE.W  D1,D0         ;
   CLR.W   D1            ;
   SUBI.W  #16,D2        ; 16 Positionen weniger zu schieben
tst8:
   CMPI.W  #8,D2         ; mindestens 8 Positionen nach links ?
   BLT.B   tstshl        ; B: nein
   LSL.L   #8,D0         ; schnelles Linksschieben um 8 Positionen
   ROL.L   #8,D1         ;
   MOVE.B  D1,D0         ;
   CLR.B   D1            ;
   SUBQ.W  #8,D2         ; 8 Positionen weniger zu schieben
   BRA.B   tstshl
shl:                     ; restliche Positionen in 1-Bit-Schritten schieben
   ADD.L   D1,D1         ;
   ADDX.L  D0,D0         ;
tstshl:
   DBRA    D2,shl        ;

   SWAP    D0            ; Exponent einfuegen
   ANDI.W  #$000F,D0     ;
   OR.W    D3,D0         ;
   SWAP    D0            ;
   BRA.B   ende
null:
   MOVEQ   #0,D0
   MOVEQ   #0,D1
ende:
(*
   MOVEM.L D0/D1,-(SP)
   FMOVE.D (SP)+,FP0
*)
   MOVEM.L D0/D1,tmp
   FMOVE.D tmp,FP0
   RETURN
 END;
END fractpart;

(*---------------------------------------------------------------------------*)

PROCEDURE scale* ((* EIN/ -- *) x : LONGREAL;
                  (* EIN/ -- *) n : INTEGER  ): LONGREAL;

VAR tmp : LONGREAL;

BEGIN
 ASSEMBLER
   MOVE.W  x,D1
   MOVE.L  #$00007FF0,D0
   AND.W   D1,D0
   BEQ.B   null
   LSR.W   #4,D0
   ADD.W   n,D0
   BVS.B   max
   BLE.B   null
   CMPI.L  #1023+1023,D0
   BGT.B   max
   LSL.W   #4,D0
   ANDI.W  #$FFFF-$7FF0,D1
   OR.W    D1,D0
   SWAP    D0
   MOVE.W  x+2,D0
   MOVE.L  x+4,D1
   BRA.B   ende
null:
   MOVEQ   #0,D0
   MOVEQ   #0,D1
   BRA.B   ende
max:
   MOVE.L  #$FFE00000,D0
   LSL.W   #1,D1
   ROXR.L  #1,D0
   MOVEQ   #0,D1
ende:
(*
   MOVEM.L D0/D1,-(SP)
   FMOVE.D (SP)+,FP0
*)
   MOVEM.L D0/D1,tmp
   FMOVE.D tmp,FP0
   RETURN
 END;
END scale;

(*---------------------------------------------------------------------------*)

PROCEDURE trunc* ((* EIN/ -- *) x : LONGREAL;
                  (* EIN/ -- *) n : INTEGER  ): LONGREAL;

VAR tmp : LONGREAL;

BEGIN
 ASSEMBLER
   MOVEM.L x,D0-D1
   MOVE.L  D0,D2
   SWAP    D2
   ANDI.L  #$00007FF0,D2
   BEQ.B   null
   CMPI.W  #$7FF0,D2
   BEQ.B   ende
   MOVE.W  n,D2
   BLE.B   null
   CMPI.L  #53,D2
   BGE.B   ende
   SUBQ.W  #1,D2
   CMPI.W  #20,D2
   BGT.B   mant2
   MOVE.L  #$FFFFFC00,D1
   SUBI.W  #10,D2
   BPL.B   shr1
   NEG.W   D2
   LSL.L   D2,D1
   BRA.B   mask1
shr1:
   ASR.L   D2,D1
mask1:
   AND.L   D1,D0
   MOVEQ   #0,D1
   BRA.B   ende
mant2:
   MOVEQ   #$FF,D3
   CLR.W   D3
   SUBI.W  #36,D2
   BPL.B   shr2
   NEG.W   D2
   LSL.L   D2,D3
   BRA.B   mask2
shr2:
   ASR.L   D2,D3
mask2:
   AND.L   D3,D1
   BRA.B   ende
null:
   MOVEQ   #0,D0
   MOVEQ   #0,D1
ende:
(*
   MOVEM.L D0/D1,-(SP)
   FMOVE.D (SP)+,FP0
*)
   MOVEM.L D0/D1,tmp
   FMOVE.D tmp,FP0
   RETURN
 END;
END trunc;

(*---------------------------------------------------------------------------*)

PROCEDURE round* ((* EIN/ -- *) x : LONGREAL;
                  (* EIN/ -- *) n : INTEGER  ): LONGREAL;

VAR tmp : LONGREAL;

BEGIN
 ASSEMBLER
   MOVEM.L x,D0-D1
   MOVE.L  D0,D2
   SWAP    D2
   ANDI.L  #$00007FF0,D2
   BEQ     null
   CMPI.W  #$7FF0,D2
   BEQ     ende
   MOVE.W  n,D2
   BLE     null
   CMPI.L  #53,D2
   BGE     ende
   SUBQ.W  #1,D2
   MOVE.W  D2,D4
   CMPI.W  #20,D2
   BGT.B   mant2
   MOVE.L  #$FFFFFC00,D3
   SUBI.W  #10,D2
   BPL.B   shr1
   NEG.W   D2
   LSL.L   D2,D3
   BRA.B   rnd1
shr1:
   ASR.L   D2,D3
rnd1:
   SUBI.W  #19,D4
   NEG.W   D4
   BMI.B   special
   MOVE.W  D4,D2
   ADDQ.W  #1,D2         ; letztes zu erhaltendes Bit, evtl. impl. eins
   BTST    D4,D0         ; hoechstwertiges Rundungsbit gesetzt ?
   BEQ.B   mask1         ; B: nein, kleiner 0.5, abrunden
   MOVE.L  D3,D4         ; Maske fuer die restlichen Rundungsbits, ausser
   NOT.L   D4            ;   dem hoechstwertigen
   LSR.L   #1,D4         ;
   AND.L   D0,D4         ; weitere Rundungsbits in oberer Mantisse gesetzt ?
   BNE     up1           ; B: ja, groesser 0.5, aufrunden
   TST.L   D1            ; weitere Rundungsbits in unterer Mantisse gesetzt ?
   BNE.B   up1           ; B: ja, groesser 0.5, aufrunden
; Rest genau 0.5 -> auf naechste GERADE Zahl runden
   CMPI.W  #20,D2        ; impl. eins einziges zu erhaltendes Bit ?
   BEQ.B   up1           ; B: ja, aufrunden, da ungerade
   BTST    D2,D0         ; letztes zu erhaltendes Bit gesetzt ?
   BEQ.B   mask1         ; B: nein, abrunden
up1:
   MOVE.L  D3,D4         ; Maske fuer letztes zu erhaltendes Bit
   LSL.L   #1,D4         ;
   EOR.L   D3,D4         ;
   ADD.L   D4,D0         ; eins auf letztes zu erhaltendes Bit addieren
   BRA.B   mask1
special:
   TST.L   D1
   BPL.B   mask1
   ADD.L   D1,D1
   BNE.B   ups
   BTST    #0,D0
   BEQ.B   mask1
ups:
   ADDQ.L  #1,D0
mask1:
   AND.L   D3,D0
   MOVEQ   #0,D1
   BRA.B   ende

mant2:
   MOVEQ   #$FF,D3
   CLR.W   D3
   SUBI.W  #36,D2
   BPL.B   shr2
   NEG.W   D2
   LSL.L   D2,D3
   BRA.B   rnd2
shr2:
   ASR.L   D2,D3

rnd2:
   SUBI.W  #51,D4
   NEG.W   D4
   MOVE.W  D4,D2
   ADDQ.W  #1,D2
   BTST    D4,D1
   BEQ.B   mask2
   MOVE.L  D3,D4
   NOT.L   D4
   LSR.L   #1,D4
   AND.L   D1,D4
   BNE.B   up2
   BTST    D2,D1
   BEQ.B   mask2
up2:
   MOVE.L  D3,D4
   LSL.L   #1,D4
   EOR.L   D3,D4
   MOVEQ   #0,D2
   ADD.L   D4,D1
   ADDX.L  D2,D0

mask2:
   AND.L   D3,D1
   BRA.B   ende
null:
   MOVEQ   #0,D0
   MOVEQ   #0,D1
ende:
(*
   MOVEM.L D0/D1,-(SP)
   FMOVE.D (SP)+,FP0
*)
   MOVEM.L D0/D1,tmp
   FMOVE.D tmp,FP0
   RETURN
 END;
END round;

(*---------------------------------------------------------------------------*)

PROCEDURE synthesize* ((* EIN/ -- *) expart  : INTEGER;
                       (* EIN/ -- *) frapart : LONGREAL ): LONGREAL;

BEGIN
 RETURN(scale(frapart, expart));
END synthesize;

(*---------------------------------------------------------------------------*)

PROCEDURE setMode* ((* EIN/ -- *) m : Modes );
BEGIN
END setMode;

(*---------------------------------------------------------------------------*)

PROCEDURE currentMode* ( ): Modes;
BEGIN
 RETURN({});
END currentMode;

BEGIN
 lrc.lc1 := 000100000H; lrc.lc2 := 000000000H; small := S.VAL(LONGREAL,lrc);
 lrc.lc1 := 07FEFFFFFH; lrc.lc2 := 0FFFFFFFFH; large := S.VAL(LONGREAL,lrc);
END LowLong.
