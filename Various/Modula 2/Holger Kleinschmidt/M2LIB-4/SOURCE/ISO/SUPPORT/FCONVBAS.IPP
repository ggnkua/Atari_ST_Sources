IMPLEMENTATION MODULE FConvBase;
__IMP_SWITCHES__
__DEBUG__
#ifdef HM2
#ifdef __LONG_WHOLE__
(*$!i+: Modul muss mit $i- uebersetzt werden! *)
(*$!w+: Modul muss mit $w- uebersetzt werden! *)
#else
(*$!i-: Modul muss mit $i+ uebersetzt werden! *)
(*$!w-: Modul muss mit $w+ uebersetzt werden! *)
#endif
#endif
(*****************************************************************************)
(* 27-Okt-95, Holger Kleinschmidt                                            *)
(*****************************************************************************)

/* Moegliche Aenderungen: */

#if 1
#define __EXP_PLUS_SIGN__
#endif

#if 0
#define __ONLY_EXP__
#endif

#if 0
#define __EXP_UNDERFLOW__
#endif

#if 0
#define __NO_LEADING_DIGITS__
#endif


INLINE_CODE_IMPORT
VAL_INTRINSIC
CAST_IMPORT


FROM PORTAB IMPORT
(* TYPE *) UNSIGNED, UNSIGNEDWORD, UNSIGNEDLONG, SIGNEDWORD, WORDSET,
           SIGNEDLONG;

IMPORT types;

FROM ConvTypes IMPORT
(* TYPE *) ConvResults;

IMPORT LowLong;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

TYPE
  lrc = RECORD
    CASE : UNSIGNEDWORD OF
      0 : lr  : LONGREAL;
     |1 : sl1 : SIGNEDLONG;
          ul2 : UNSIGNEDLONG;
     |2 : sw1 : SIGNEDWORD;
          uw2 : UNSIGNEDWORD;
          uw3 : UNSIGNEDWORD;
          uw4 : UNSIGNEDWORD;
    ELSE  ws1 : WORDSET;
          ws2 : WORDSET;
          ws3 : WORDSET;
          ws4 : WORDSET;
    END;
  END;

  rc = RECORD
    CASE : UNSIGNEDWORD OF
#ifdef HM2
      0 : r   : SHORTREAL;
#else
      0 : r   : REAL;
#endif
     |1 : sl  : SIGNEDLONG;
     |2 : sw1 : SIGNEDWORD;
          uw2 : UNSIGNEDWORD;
    ELSE  ws1 : WORDSET;
          ws2 : WORDSET;
    END;
  END;


#if LONGREAL_var
VAR
  lcast : lrc;

VAR
  null  : LONGREAL; (* 0.0 *)
  one   : LONGREAL; (* 1.0 *)
  five  : LONGREAL; (* 5.0 *)
  nine  : LONGREAL; (* 9.0 *)
  ten   : LONGREAL; (* 1.0E+1 *)
  ten2  : LONGREAL; (* 1.0E+2 *)
  ten4  : LONGREAL; (* 1.0E+4 *)
  ten8  : LONGREAL; (* 1.0E+8 *)
  ten16 : LONGREAL; (* 1.0E+16 *)
  ten20 : LONGREAL; (* 1.0E+20 *)
#else
CONST
  null  = LRC(0.0,0);
  one   = LRC(1.0,0);
  five  = LRC(5.0,0);
  nine  = LRC(9.0,0);
  ten   = LRC(1.0,1);
  ten2  = LRC(1.0,2);
  ten4  = LRC(1.0,4);
  ten8  = LRC(1.0,8);
  ten16 = LRC(1.0,16);
  ten20 = LRC(1.0,20);
#endif

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

#ifdef HM2
PROCEDURE checkReal ((* EIN/ -- *)     real   : SHORTREAL;
#else
PROCEDURE checkReal ((* EIN/ -- *)     real   : REAL;
#endif
                     (* -- /AUS *) VAR format : RealFormat ): BOOLEAN;
#ifndef MM2
CONST
  ExpMask  = WORDSET{7..14};
  MantMask = WORDSET{0..6};
VAR exp : WORDSET;
#endif
VAR cast : rc;

BEGIN
 WITH cast DO
   r := real;
#ifdef MM2
   IF sl = 0 THEN
     format := pnull;
   ELSIF sl < 0 THEN
     (* Bit 31 gesetzt *)
     format := normal;
   ELSE
     format := denorm;
   END;
#else
   exp := ws1 * ExpMask;
   IF exp = WORDSET{} THEN
     IF (ws1 * MantMask # WORDSET{}) OR (uw2 # 0) THEN
       format := denorm;
     ELSIF sw1 < 0 THEN
       format := mnull;
     ELSE
       format := pnull;
     END;
   ELSIF exp = ExpMask THEN
     IF (ws1 * MantMask # WORDSET{}) OR (uw2 # 0) THEN
       format := nan;
     ELSIF sw1 < 0 THEN
       format := minf;
     ELSE
       format := pinf;
     END;
     RETURN(FALSE);
   ELSE
     format := normal;
   END;
#endif
 END;
 RETURN(TRUE);
END checkReal;

(*---------------------------------------------------------------------------*)

PROCEDURE checkLReal ((* EIN/ -- *)     real   : LONGREAL;
                      (* -- /AUS *) VAR format : RealFormat ): BOOLEAN;

CONST
#ifdef MM2
  ExpMask  = WORDSET{3..15};
#else
  ExpMask  = WORDSET{4..14};
  MantMask = WORDSET{0..3};

VAR
  exp : WORDSET;
#endif

VAR cast : lrc;

BEGIN
 WITH cast DO
   lr := real;
#ifdef MM2
   IF sw1 = 0 THEN
     format := pnull;
   ELSIF ws1 * ExpMask = WORDSET{3..14} THEN
     IF ODD(sw1) THEN
       format := minf;
     ELSE
       format := pinf;
     END;
     RETURN(FALSE);
   ELSE
     format := normal;
   END;
#else
   exp := ws1 * ExpMask;
   IF exp = WORDSET{} THEN
     IF (ws1 * MantMask # WORDSET{}) OR (uw2 # 0) OR (ul2 # VAL(UNSIGNEDLONG,0)) THEN
       format := denorm;
     ELSIF sw1 < 0 THEN
       format := mnull;
     ELSE
       format := pnull;
     END;
   ELSIF exp = ExpMask THEN
     IF (ws1 * MantMask # WORDSET{}) OR (uw2 # 0) OR (ul2 # VAL(UNSIGNEDLONG,0)) THEN
       format := nan;
     ELSIF sw1 < 0 THEN
       format := minf;
     ELSE
       format := pinf;
     END;
     RETURN(FALSE);
   ELSE
     format := normal;
   END;
#endif
 END;
 RETURN(TRUE);
END checkLReal;

(*---------------------------------------------------------------------------*)

PROCEDURE formToStr ((* EIN/ -- *)     form : RealFormat;
                     (* -- /AUS *) VAR str  : ARRAY OF CHAR );

VAR s : FormStr;
    i : UNSIGNEDWORD;

BEGIN
 CASE form OF
   minf : s := "-Inf";
  |pinf : s := "+Inf";
  |nan  : s := "NaN";
 ELSE     s := "";
 END;
 i := 0;
 WHILE (i <= MAXFORM) & (i <= VAL(UNSIGNEDWORD,HIGH(str))) DO
   str[i] := s[i];
   INC(i);
 END;
 (*
 IF i <= VAL(UNSIGNEDWORD,HIGH(str)) THEN
   str[i] := types.EOS;
 END;
 *)
END formToStr;

(*---------------------------------------------------------------------------*)

PROCEDURE formLen ((* EIN/ -- *) form : RealFormat ): UNSIGNEDWORD;
BEGIN
 IF form <= normal THEN
   RETURN(0);
 ELSIF form = nan THEN
   RETURN(3); (* NaN *)
 ELSE
   RETURN(4); (* +/-Inf *)
 END;
END formLen;

(*---------------------------------------------------------------------------*)

PROCEDURE scale ((* EIN/ -- *) x     : LONGREAL;
                 (* EIN/ -- *) shift : SIGNEDWORD ): LONGREAL;

(* Fuer die exakte Darstellung beliebiger Bitmuster <= 1.0E+20 wuerden
   mindestens 66 Mantissenbits benoetigt (log2(1.0E+20) ~ 66). Da aber bei
   Zehnerpotenzen die unteren Bits Null sind, kann 1.0E+20 noch mit
   'LowLong.places >= 47' Bits exakt dargestellt werden (nicht
   vorhandene Bits gelten als Nullbits). Die exakte Darstellung der
   Faktoren ist Voraussetzung fuer eine ``moeglichst genaue''
   Transformation von <x>.
 *)
VAR __REG__ sh : SIGNEDWORD;

BEGIN
 sh := shift;
 IF sh < 0 THEN
   (* Keine Multiplikation, da negative Zehnerpotenzen nicht
    * exakt darstellbar sind.
    *)
   WHILE sh <= -20 DO
     x := x / ten20; INC(sh, 20);
   END;
   IF sh <= -16 THEN
     x := x / ten16; INC(sh, 16);
   END;
   IF sh <= -8 THEN
     x := x / ten8; INC(sh, 8);
   END;
   IF sh <= -4 THEN
     x := x / ten4; INC(sh, 4);
   END;
   IF sh <= -2 THEN
     x := x / ten2; INC(sh, 2);
   END;
   IF sh = -1 THEN
     x := x / ten;
   END;
 ELSE
   WHILE sh >= 20 DO
     x := x * ten20; DEC(sh, 20);
   END;
   IF sh >= 16 THEN
     x := x * ten16; DEC(sh, 16);
   END;
   IF sh >= 8 THEN
     x := x * ten8; DEC(sh, 8);
   END;
   IF sh >= 4 THEN
     x := x * ten4; DEC(sh, 4);
   END;
   IF sh >= 2 THEN
     x := x * ten2; DEC(sh, 2);
   END;
   IF sh = 1 THEN
     x := x * ten;
   END;
 END;
 RETURN(x);
END scale;

(*---------------------------------------------------------------------------*)

PROCEDURE split ((* EIN/ -- *)     val  : LONGREAL;
                 (* -- /AUS *) VAR neg  : BOOLEAN;
                 (* -- /AUS *) VAR norm : LONGREAL;
                 (* -- /AUS *) VAR exp  : SIGNEDWORD;
                 (* -- /AUS *) VAR form : RealFormat ): BOOLEAN;

VAR __REG__ exp2 : SIGNEDWORD;

BEGIN
 IF ~checkLReal(val, form) THEN
   RETURN(FALSE);
 ELSIF form < normal THEN
   neg  := FALSE;
   norm := null;
   exp  := 0;
   RETURN(TRUE);
 END;

 neg := val < null;
 IF neg THEN
   val := -val;
 END;
#ifdef MM2
 exp2 := VAL(SIGNEDWORD,LowLong.exponent(val)) - 1;
#else
 exp2 := VAL(SIGNEDWORD,LowLong.exponent(val));
#endif

 (* Zehnerexponent durch Zweierexponent annaehern:
    exp[10] = exp[2] * log10(2).
    19728.0 / 65536.0 ~ 0.30103 <=> log10(2).
  *)
 IF exp2 < 0 THEN
   exp2 := -VAL(SIGNEDWORD,(VAL(UNSIGNED,-exp2) * LC(19728)) DIV LC(65536));
 ELSE
   exp2 := VAL(SIGNEDWORD,(VAL(UNSIGNED,exp2) * LC(19728)) DIV LC(65536));
 END;

 val := scale(val, -exp2);

 (* Jetzt exakt auf [1.0, 10.0) transformieren. Der Absolutwert des
    angenaeherten Zehnerexponenten kann hoechstens um Eins kleiner als
    der tatsaechliche Wert sein (Ganzzahlarithmetik - Rest fehlt, nicht
    beruecksichtigte Mantisse), aber nicht groesser.
  *)
 IF val >= ten THEN
   val := val / ten; INC(exp2);
 ELSIF val < one THEN
   val := val * ten; DEC(exp2);
 END;
 norm := val;
 exp  := exp2;
 RETURN(TRUE);
END split;

(*---------------------------------------------------------------------------*)
#ifdef MM2
__PROCFRAME_OFF__
PROCEDURE r2s ((* EIN/ -- *)     norm : LONGREAL;
               (* EIN/ -- *)     figs : UNSIGNEDWORD;
               (* EIN/AUS *) VAR str  : SigFigStr    );

(* <norm> ist eine normierte Zahl im Bereich [1.0, 10.0). <str>
   muss vollstaendig mit '0' aufgefuellt sein und wird mit den
   ersten <figs> + 1 (Rundungsstelle) Ziffern von <norm> ueberschrieben.
 *)

BEGIN
 ASSEMBLER
; <norm> wird in eine Festkommazahl mit dem Dezimalkomma hinter dem
; obersten Byte umgewandelt. Der Wert der Vorkommastelle liegt
; zwischen 0 und 9.
; Die naechste Vorkommastelle wird jeweils durch Multiplikation
; (durch Addition ersetzt) des Nachkommateils mit 10 berechnet.

   MOVEM.L D3/D4,-(SP)
   MOVEA.L -(A3),A0
   MOVE.W  -(A3),D4
   MOVE.L  -(A3),D1
   MOVE.L  -(A3),D0

   SWAP    D0           ; Exponent: 2^1 .. 2^4
   MOVE.W  D0,D3        ;
   LSR.W   #3,D3        ; Shift: 1..4

   CLR.W   D0           ; Nur Mantissenbits
   SWAP    D0           ;

; Mantisse um Shift Bits nach links schieben, damit der Wert bzgl. des
; Dezimalkommas stimmt.

   LSL.L   D3,D0
   ROL.L   D3,D1

   SUBQ.W  #4,D3        ; Aus Shift eine Bitmaske berechnen
   NEG.W   D3           ;
   MOVEQ   #$F,D2       ;
   LSR.W   D3,D2        ;

   MOVE.W  D2,D3        ;
   AND.B   D1,D2        ;
   OR.B    D2,D0        ;
   NOT.W   D3           ;
   AND.B   D3,D1        ;

convlp:
   MOVE.L  D1,D2        ; Mantisse = Null -> weitere Berechnung ueberfluessig
   OR.L    D0,D2        ;
   BEQ.B   end          ;

   SWAP    D0           ; Vorkommastelle rausziehen
   MOVE.B  D0,D2        ;
   CLR.W   D0           ;
   SWAP    D0           ;
   ADDI.B  #'0',D2      ;
   MOVE.B  D2,(A0)+     ;

   ADD.L   D1,D1        ; Mantisse (Nachkommastellen) * 10
   ADDX.L  D0,D0        ;
   MOVE.L  D1,D3        ;
   MOVE.L  D0,D2        ;
   ADD.L   D1,D1        ;
   ADDX.L  D0,D0        ;
   ADD.L   D1,D1        ;
   ADDX.L  D0,D0        ;
   ADD.L   D3,D1        ;
   ADDX.L  D2,D0        ;
   DBRA    D4,convlp
end:
   MOVEM.L (SP)+,D3/D4
 END;
END r2s;
__PROCFRAME_ON__

#else

PROCEDURE r2s ((* EIN/ -- *)     norm : LONGREAL;
               (* EIN/ -- *)     digs : UNSIGNEDWORD;
               (* EIN/AUS *) VAR str  : SigFigStr    );

(* <norm> ist eine normierte Zahl im Bereich [1.0, 10.0). <str>
   muss vollstaendig mit '0' aufgefuellt sein und wird mit den
   ersten <digs> + 1 (Rundungsstelle) Ziffern von <norm> ueberschrieben.
 *)

BEGIN
(*
; <norm> wird in eine Festkommazahl mit dem Dezimalkomma hinter dem
; obersten Byte umgewandelt. Der Wert der Vorkommastelle liegt
; zwischen 0 und 9.
; Die naechste Vorkommastelle wird jeweils durch Multiplikation
; (durch Addition ersetzt) des Nachkommateils mit 10 berechnet.

#if (defined LPRM2) || (defined SPCM2)
  movea.l 12(A6),A0
  move.w  16(A6),D4
  movem.l 18(A6),D0-D1
#elif (defined TDIM2)
  movea.l 8(A6),A0
  move.w  12(A6),D4
  movem.l 14(A6),D0-D1
#elif (defined HM2)
  movea.l 18(A6),A0
  move.w  16(A6),D4
  movem.l 8(A6),D0-D1
  movem.l D2-D4,-(SP)
#endif
  move.l  D0,D3          ; Exponent: 2^0 .. 2^3
  swap    D3             ;
  lsr.w   #4,D3          ;
  subi.w  #1023-4,D3     ; Shift: 4..7

  andi.l  #$000fffff,D0  ; Nur Mantissenbits
  bset    #20,D0         ; implizite Eins

; Mantisse um Shift Bits nach links schieben, damit der Wert bzgl. des
; Dezimalkommas stimmt.

  lsl.l   D3,D0
  rol.l   D3,D1

  subq.w  #7,D3          ; Aus Shift eine Bitmaske berechnen
  neg.w   D3             ;
  moveq   #$7f,D2        ;
  lsr.w   D3,D2          ;

  move.w  D2,D3          ;
  and.b   D1,D2          ;
  or.b    D2,D0          ;
  not.w   D3             ;
  and.b   D3,D1          ;

convlp:
  move.l  D1,D2          ; Mantisse = Null -> weitere Berechnung ueberfluessig
  or.l    D0,D2          ;
  beq.s   end            ;

  rol.l   #8,D0          ; Vorkommastelle rausziehen
  move.b  D0,D2          ;
  lsr.l   #8,D0          ;
  addi.b  #'0',D2        ;
  move.b  D2,(A0)+       ;

  add.l   D1,D1          ; Mantisse (Nachkommastellen) * 10
  addx.l  D0,D0          ;
  move.l  D1,D3          ;
  move.l  D0,D2          ;
  add.l   D1,D1          ;
  addx.l  D0,D0          ;
  add.l   D1,D1          ;
  addx.l  D0,D0          ;
  add.l   D3,D1          ;
  addx.l  D2,D0          ;
  dbra    D4,convlp
end:
#if (defined HM2)
  movem.l (SP)+,D2-D4
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
 CODE(206EH,000CH,382EH,0010H,4CEEH,0003H,0012H);
#elif (defined TDIM2)
 CODE(206EH,0008H,382EH,000CH,4CEEH,0003H,000EH);
#elif (defined HM2)
 CODE(206EH,0012H,382EH,0010H,4CEEH,0003H,0008H);
 CODE(48E7H,3800H);
#endif
 CODE(2600H);
 CODE(4843H,0E84BH,0443H,03FBH,0280H,000FH,0FFFFH,08C0H);
 CODE(0014H,0E7A8H,0E7B9H,5F43H,4443H,747FH,0E66AH,3602H);
 CODE(0C401H,8002H,4643H,0C203H,2401H,8480H,6724H,0E198H);
 CODE(1400H,0E088H,0602H,0030H,10C2H,0D281H,0D180H,2601H);
 CODE(2400H,0D281H,0D180H,0D281H,0D180H,0D283H,0D182H,51CCH);
 CODE(0FFD8H);
#if (defined HM2)
 CODE(4CDFH,001CH);
#endif
END r2s;
#endif
(*---------------------------------------------------------------------------*)

PROCEDURE mantToStr ((* EIN/ -- *)     norm : LONGREAL;
                     (* EIN/ -- *)     fix  : BOOLEAN;
                     (* EIN/ -- *)     figs : SIGNEDWORD;
                     (* EIN/ -- *)     long : BOOLEAN;
                     (* EIN/AUS *) VAR exp  : SIGNEDWORD;
                     (* -- /AUS *) VAR digs : UNSIGNEDWORD;
                     (* -- /AUS *) VAR mant : SigFigStr    );

VAR __REG__ i   : SIGNEDWORD;
    __REG__ fig : SIGNEDWORD;

BEGIN
 (* HIGH(mant) + 1 = MAXLSIGFIGS + 1 '0'-en *)
#ifdef MM2
 mant := "0000000000000000";
#else
 mant := "00000000000000000";
#endif

 IF norm = null THEN
   digs := 1;
   RETURN;
 END;

 fig := figs;
 IF fix THEN
   IF fig >= 0 THEN
     INC(fig, exp + 1);
   ELSE
     INC(fig, exp + 2);
   END;
 ELSIF fig = 0 THEN
   fig := DEFSIGFIGS;
 END;

 IF fig <= 0 THEN
   (* Kann nur bei Fixpunktdarstellung auftreten *)
   IF fig < 0 THEN
     (* Es gibt keine signifikanten Stellen, es muss nur ggf.
      * mit Nullen aufgefuellt werden.
      *)
     digs := 0;
     exp  := 0;
   ELSE (* fig = 0 *)
     (* Die einzige signifikante Stelle wird durch Rundung der
      * naechstkleineren Stelle zu Null oder Eins berechnet;
      *)
     IF norm >= five THEN
       mant[0] := '1';
       INC(exp);
     ELSE
       exp := 0;
     END;
     digs := 1;
   END;
   RETURN;
 END;

 (* Maximal sinnvoll zu berechnende Anzahl von Digits, der Rest wird
  * spaeter durch Nullen aufgefuellt.
  *)
 IF long & (figs > MAXLSIGFIGS) THEN
   figs := MAXLSIGFIGS;
 ELSIF ~long & (figs > MAXSSIGFIGS) THEN
   figs := MAXSSIGFIGS;
 END;
 digs := CAST(UNSIGNEDWORD,fig);

 r2s(norm, fig, mant);

 IF mant[fig] >= '5' THEN
   i := fig - 1;
   WHILE (i >= 0) & (mant[i] = '9')  DO
     mant[i] := '0';
     DEC(i);
   END;
   IF i >= 0 THEN
     INC(mant[i]);
   ELSE
     mant[0] := '1';
     INC(exp);
   END;
 END;
 mant[fig] := '0';
END mantToStr;

(*---------------------------------------------------------------------------*)

PROCEDURE fixLen ((* EIN/ -- *) neg    : BOOLEAN;
                  (* EIN/ -- *) exp    : SIGNEDWORD;
                  (* EIN/ -- *) places : SIGNEDWORD ): UNSIGNEDWORD;

VAR __REG__ len : SIGNEDWORD;

BEGIN
 IF neg THEN
   len := 1; (* Minuszeichen *)
 ELSE
   len := 0; (* Kein Vorzeichen *)
 END;
 IF places < 0 THEN
   IF -places - 2 > exp THEN
     INC(len); (* Vorzeichen, Null *)
   ELSE
     INC(len, exp + 1);
     (* Vorzeichen, <exp>+1 Vorkommastellen *)
   END;
 ELSIF exp >= 0 THEN (* places >= 0 *)
   INC(len, exp + 2 + places);
   (* Vorzeichen, <exp>+1 Vorkommastellen, Dezimalpunkt, <places> Nachkommastellen *)
 ELSE (* exp < 0, places >= 0 *)
   INC(len, 2 + places);
   (* Vorzeichen, Vorkommanull, Dezimalpunkt, <places> Nachkommastellen *)
 END;
 RETURN(CAST(UNSIGNEDWORD,len));
END fixLen;

(*---------------------------------------------------------------------------*)

PROCEDURE FixLength ((* EIN/ -- *) val    : LONGREAL;
                     (* EIN/ -- *) long   : BOOLEAN;
                     (* EIN/ -- *) places : SIGNEDWORD ): UNSIGNEDWORD;

VAR neg   : BOOLEAN;
    exp   : SIGNEDWORD;
    digs  : UNSIGNEDWORD;
    mant  : SigFigStr;
    form  : RealFormat;
    len   : SIGNEDWORD;

BEGIN
 IF ~split(val, neg, val, exp, form) THEN
   RETURN(formLen(form));
 END;

 IF exp >= 0 THEN
   (* Nur bei Vorkommastellen Aenderung der Stellenzahl moeglich *)
   IF neg THEN
     len := 1; (* Minuszeichen *)
   ELSE
     len := 0; (* Kein Vorzeichen *)
   END;

   IF places < -exp - 2 THEN
     RETURN(len + 1); (* Vorzeichen, Null *)
   ELSIF places = -exp - 2 THEN
     IF val < five THEN
       RETURN(len + 1); (* Vorzeichen, Null *)
     ELSE
       RETURN(len + exp + 2);
       (* Vorzeichen, <exp>+2 Vorkommastellen (aufgerundet) *)
     END;
   ELSIF val >= nine THEN (* places > -exp - 2 *)
     mantToStr(val, TRUE, places, long, exp, digs, mant);
   END;
 END;
 RETURN(fixLen(neg, exp, places));
END FixLength;

(*---------------------------------------------------------------------------*)

PROCEDURE adjustEng ((* EIN/AUS *) VAR exp : SIGNEDWORD;
                     (* -- /AUS *) VAR pre : UNSIGNEDWORD );
BEGIN
 IF exp < 0 THEN
   pre := VAL(UNSIGNEDWORD,2 - (-exp - 1) MOD 3);
 ELSE
   pre := VAL(UNSIGNEDWORD,exp MOD 3);
 END;
 DEC(exp, CAST(SIGNEDWORD,pre));
 INC(pre);
END adjustEng;

(*---------------------------------------------------------------------------*)

PROCEDURE expLen ((* EIN/ -- *) exp : SIGNEDWORD ): UNSIGNEDWORD;

VAR __REG__ len  : SIGNEDWORD;

BEGIN
 len := 0;
 IF exp # 0 THEN
   IF exp < 0 THEN
     exp := -exp;
#ifdef __EXP_PLUS_SIGN__
   END;
   len := 1; (* Vorzeichen *)
#else
     len := 1; (* Vorzeichen *)
   END;
#endif
   IF exp >= 1000 THEN
     INC(len, 1 + 4); (* 'E', vier Stellen *)
   ELSIF exp >= 100 THEN
     INC(len, 1 + 3); (* 'E', drei Stellen *)
   ELSIF exp >= 10 THEN
     INC(len, 1 + 2); (* 'E', zwei Stellen *)
   ELSE
     INC(len, 1 + 1); (* 'E', eine Stelle *)
   END;
 END;
 RETURN(len);
END expLen;

(*---------------------------------------------------------------------------*)

PROCEDURE floatLen ((* EIN/ -- *) neg  : BOOLEAN;
                    (* EIN/ -- *) eng  : BOOLEAN;
                    (* EIN/ -- *) exp  : SIGNEDWORD;
                    (* EIN/ -- *) figs : UNSIGNEDWORD ): UNSIGNEDWORD;

VAR len : UNSIGNEDWORD;
    pre : UNSIGNEDWORD;

BEGIN
 IF figs = 0 THEN
   figs := DEFSIGFIGS;
 END;

 IF eng THEN
   adjustEng(exp, pre);
 ELSE
   pre := 1; (* Eine Vorkommastelle *)
 END;

 IF neg THEN
   len := 1; (* Minuszeichen *)
 ELSE
   len := 0; (* Kein Vorzeichen *)
 END;

 IF figs <= pre THEN
   INC(len, pre); (* <pre> Vorkommastellen, kein Dezimalpunkt *)
 ELSE
   INC(len, figs + 1); (* <figs> Stellen, Dezimalpunkt *)
 END;
 RETURN(len + expLen(exp));
END floatLen;

(*---------------------------------------------------------------------------*)

PROCEDURE FloatLength ((* EIN/ -- *) val  : LONGREAL;
                       (* EIN/ -- *) eng  : BOOLEAN;
                       (* EIN/ -- *) long : BOOLEAN;
                       (* EIN/ -- *) figs : UNSIGNEDWORD ): UNSIGNEDWORD;

VAR neg  : BOOLEAN;
    exp  : SIGNEDWORD;
    digs : UNSIGNEDWORD;
    mant : SigFigStr;
    form : RealFormat;

BEGIN
 IF ~split(val, neg, val, exp, form) THEN
   RETURN(formLen(form));
 END;
 IF figs = 0 THEN
   figs := DEFSIGFIGS;
 END;
 IF (val >= nine) & ((exp = 0) OR (exp = -1) OR eng) THEN
   (* Eine Aenderung der Stellenzahl durch (Auf)Rundung kann nur eintreten,
    * wenn die erste Ziffer eine 9 ist.
    * Bei wissenschaftlicher Darstellung kann sie ausserdem nur auftreten,
    * wenn der Exponent entweder verschwindet, weil er zu Null aufgerundet
    * wurde, oder wenn er erst durch die Rundung auftritt (vorher Null).
    * Bei technischer Darstellung kann sich die Zahl der Vorkommastellen bei
    * jeder Aufrundung aendern.
    *)
   mantToStr(val, FALSE, CAST(SIGNEDWORD,figs), long, exp, digs, mant);
 END;
 RETURN(floatLen(neg, eng, exp, figs));
END FloatLength;

(*---------------------------------------------------------------------------*)

PROCEDURE expToStr ((* EIN/ -- *)     exp   : SIGNEDWORD;
                    (* -- /AUS *) VAR estr  : ExpStr;
                    (* -- /AUS *) VAR start : UNSIGNEDWORD );

VAR         neg  : BOOLEAN;
    __REG__ eidx : UNSIGNEDWORD;

BEGIN
 neg := exp < 0;
 IF neg THEN
   exp := -exp;
 END;
 eidx := MAXEXPFIGS;
 REPEAT
   estr[eidx] := CHR(exp MOD 10 + VAL(SIGNEDWORD,ORD('0')));
   exp        := exp DIV 10;
   DEC(eidx);
 UNTIL exp = 0;
 IF neg THEN
   estr[eidx] := '-';
#ifdef __EXP_PLUS_SIGN__
 ELSE
   estr[eidx] := '+';
 END;
 DEC(eidx);
#else
   DEC(eidx);
 END;
#endif
 estr[eidx] := 'E';
 start      := eidx;
END expToStr;

(*---------------------------------------------------------------------------*)

PROCEDURE floatToStr ((* EIN/ -- *)     neg  : BOOLEAN;
                      (* EIN/ -- *)     norm : LONGREAL;
                      (* EIN/ -- *)     exp  : SIGNEDWORD;
                      (* EIN/ -- *)     eng  : BOOLEAN;
                      (* EIN/ -- *)     figs : UNSIGNEDWORD;
                      (* EIN/ -- *)     long : BOOLEAN;
                      (* -- /AUS *) VAR str  : ARRAY OF CHAR );

VAR         estr : ExpStr;
            pre  : UNSIGNEDWORD;
    __REG__ sidx : UNSIGNEDWORD;
    __REG__ midx : UNSIGNEDWORD;
            mant : SigFigStr;
            digs : UNSIGNEDWORD;

BEGIN
 IF figs = 0 THEN
   figs := DEFSIGFIGS;
 END;
 mantToStr(norm, FALSE, CAST(SIGNEDWORD,figs), long, exp, digs, mant);

 (* Optionales Vorzeichen schreiben *)
 IF neg THEN
   str[0] := '-';
   sidx   := 1;
 ELSE
   sidx   := 0;
 END;

 (* Vorkommastellen schreiben *)
 IF eng THEN
   adjustEng(exp, pre);
 ELSE
   pre := 1;
 END;
 midx := 0;
 WHILE (sidx <= VAL(UNSIGNEDWORD,HIGH(str))) & (midx < pre) DO
   str[sidx] := mant[midx];
   INC(sidx);
   INC(midx);
 END;

 (* Optionalen Dezimalpunkt mit Nachkommastellen schreiben *)
 IF (figs > pre) & (sidx <= VAL(UNSIGNEDWORD,HIGH(str))) THEN
   str[sidx] := '.';
   INC(sidx);
   WHILE (sidx <= VAL(UNSIGNEDWORD,HIGH(str))) & (midx < digs) DO
     str[sidx] := mant[midx];
     INC(sidx);
     INC(midx);
   END;
   WHILE (sidx <= VAL(UNSIGNEDWORD,HIGH(str))) & (digs < figs) DO
     str[sidx] := '0';
     INC(sidx);
     INC(digs);
   END;
 END;

 (* Optionalen Exponenten schreiben *)
 IF exp # 0 THEN
   expToStr(exp, estr, pre);
   WHILE (sidx <= VAL(UNSIGNEDWORD,HIGH(str))) & (pre <= MAXEXPFIGS)  DO
     str[sidx] := estr[pre];
     INC(sidx);
     INC(pre);
   END;
 END;
 IF sidx <= VAL(UNSIGNEDWORD,HIGH(str)) THEN
   str[sidx] := types.EOS;
 END;
END floatToStr;

(*---------------------------------------------------------------------------*)

PROCEDURE fixToStr ((* EIN/ -- *)     neg    : BOOLEAN;
                    (* EIN/ -- *)     norm   : LONGREAL;
                    (* EIN/ -- *)     exp    : SIGNEDWORD;
                    (* EIN/ -- *)     places : SIGNEDWORD;
                    (* EIN/ -- *)     long   : BOOLEAN;
                    (* -- /AUS *) VAR str    : ARRAY OF CHAR );

VAR __REG__ sidx : UNSIGNEDWORD;
    __REG__ midx : UNSIGNEDWORD;
            mant : SigFigStr;
            digs : UNSIGNEDWORD;

BEGIN
 mantToStr(norm, TRUE, places, long, exp, digs, mant);

 (* Optionales Vorzeichen schreiben *)
 IF neg THEN
   str[0] := '-';
   sidx   := 1;
 ELSE
   sidx   := 0;
 END;

 midx := 0;
 IF exp < 0 THEN
(* [-]0.[000]xxxxx[000] *)
   IF sidx <= VAL(UNSIGNEDWORD,HIGH(str)) THEN
     str[sidx] := '0';
     INC(sidx);
     IF (places >= 0) & (sidx <= VAL(UNSIGNEDWORD,HIGH(str))) THEN
       str[sidx] := '.';
       INC(sidx);
       exp := -exp - 1;
       DEC(places, exp + CAST(SIGNEDWORD,digs));
       WHILE (sidx <= VAL(UNSIGNEDWORD,HIGH(str))) & (exp > 0) DO
         str[sidx] := '0';
         INC(sidx);
         DEC(exp);
       END;
       WHILE (sidx <= VAL(UNSIGNEDWORD,HIGH(str))) & (midx < digs) DO
         str[sidx] := mant[midx];
         INC(sidx);
         INC(midx);
       END;
       WHILE (sidx <= VAL(UNSIGNEDWORD,HIGH(str))) & (places > 0) DO
         str[sidx] := '0';
         INC(sidx);
         DEC(places);
       END;
     END;
   END;
 ELSE (* exp >= 0 *)
   IF places < 0 THEN
(* [-]xxx[000] *)
     WHILE (sidx <= VAL(UNSIGNEDWORD,HIGH(str))) & (midx < digs) DO
       str[sidx] := mant[midx];
       INC(sidx);
       INC(midx);
     END;
     DEC(exp, CAST(SIGNEDWORD,digs));
     WHILE (sidx <= VAL(UNSIGNEDWORD,HIGH(str))) & (exp >= 0) DO
       str[sidx] := '0';
       INC(sidx);
       DEC(exp);
     END;
   ELSE (* places >= 0, exp >= 0 *)
     IF CAST(UNSIGNEDWORD,exp) + 1 >= digs THEN
(* [-]xxx[000[.[000]]] *)
       WHILE (sidx <= VAL(UNSIGNEDWORD,HIGH(str))) & (midx < digs) DO
         str[sidx] := mant[midx];
         INC(sidx);
         INC(midx);
       END;
       DEC(exp, CAST(SIGNEDWORD,digs));
       WHILE (sidx <= VAL(UNSIGNEDWORD,HIGH(str))) & (exp >= 0) DO
         str[sidx] := '0';
         INC(sidx);
         DEC(exp);
       END;
       IF sidx <= VAL(UNSIGNEDWORD,HIGH(str)) THEN
         str[sidx] := '.';
         INC(sidx);
         WHILE (sidx <= VAL(UNSIGNEDWORD,HIGH(str))) & (places > 0) DO
           str[sidx] := '0';
           INC(sidx);
           DEC(places);
         END;
       END;
     ELSE (* places >= 0, exp >= 0, exp < digs - 1 *)
(* [-]xxx.[xxx][000] *)
       WHILE (sidx <= VAL(UNSIGNEDWORD,HIGH(str))) & (midx <= CAST(UNSIGNEDWORD,exp)) DO
         str[sidx] := mant[midx];
         INC(sidx);
         INC(midx);
       END;
       IF sidx <= VAL(UNSIGNEDWORD,HIGH(str)) THEN
         str[sidx] := '.';
         INC(sidx);
         exp := CAST(SIGNEDWORD,sidx);
         WHILE (sidx <= VAL(UNSIGNEDWORD,HIGH(str))) & (midx < digs) DO
           str[sidx] := mant[midx];
           INC(sidx);
           INC(midx);
         END;
         DEC(places, CAST(SIGNEDWORD,sidx) - exp);
         WHILE (sidx <= VAL(UNSIGNEDWORD,HIGH(str))) & (places > 0) DO
           str[sidx] := '0';
           INC(sidx);
           DEC(places);
         END;
       END;
     END;
   END;
 END;
 IF sidx <= VAL(UNSIGNEDWORD,HIGH(str)) THEN
   str[sidx] := types.EOS;
 END;
END fixToStr;

(*---------------------------------------------------------------------------*)

PROCEDURE strToReal ((* EIN/ -- *) VAR str    : ARRAY OF CHAR;
                     (* EIN/ -- *)     min    : LONGREAL;
                     (* EIN/ -- *)     minExp : SIGNEDWORD;
                     (* EIN/ -- *)     max    : LONGREAL;
                     (* EIN/ -- *)     maxExp : SIGNEDWORD;
                     (* -- /AUS *) VAR res    : ConvResults ): LONGREAL;

VAR negMant  : BOOLEAN;
    ch       : CHAR;
    shift    : SIGNEDWORD;
    exp      : SIGNEDWORD;
    i        : SIGNEDWORD;
    sLen     : SIGNEDWORD;
    digits   : SIGNEDWORD;
    mant     : LONGREAL;
    maxTenth : LONGREAL;
#ifdef __EXP_UNDERFLOW__
    minTen   : LONGREAL;
#endif

#if !((defined ISOM2) || (defined MM2) || (defined HM2))
 PROCEDURE LENGTH (VAR s : ARRAY OF CHAR): UNSIGNEDWORD;
 __REG__ VAR i : UNSIGNEDWORD;
 BEGIN
  i := 0;
  WHILE (i <= VAL(UNSIGNEDWORD,HIGH(s))) & (s[i] # types.EOS) DO
    INC(i);
  END;
  RETURN(i);
 END LENGTH;
#endif

PROCEDURE ParseSign ((* -- /AUS *) VAR neg : BOOLEAN ): BOOLEAN;
(* Ein optionales Vorzeichen wird ueberlesen und gemerkt.
 * Hinter dem Vorzeichen darf der String noch nicht zuende sein.
 *)
BEGIN
 neg := str[i] = '-';
 IF neg OR (str[i] = '+')  THEN
   INC(i);
   RETURN(i < sLen);
 ELSE
   RETURN(TRUE);
 END;
END ParseSign;

PROCEDURE ParseZeros;
(* Aufeinanderfolgende Nullen werden ueberlesen und mitgezaehlt *)
BEGIN
 WHILE (i < sLen) & (str[i] = '0') DO
   INC(i);
 END;
END ParseZeros;

PROCEDURE ParseDigits ((* EIN/AUS *) VAR mant : LONGREAL );
(* Ein optionaler Strom von Ziffern wird gelesen; die Ziffern werden
 * ihrer Wertigkeit entsprechend summiert, solange nicht die maximal
 * repraesentierbare Ziffernzahl ueberschritten wird (ansonsten wird
 * nur ueberlesen).
 *)
BEGIN
 WHILE (i < sLen) & ('0' <= str[i]) & (str[i] <= '9') DO
   IF digits <= MAXLSIGFIGS THEN
#if (defined LPRM2) || (defined SPCM2) || (defined TDIM2)
     mant := ten * mant + FLOATD(ORD(str[i]) - ORD('0'));
#elif (defined ISOM2) || (defined MM2) || (defined HM2)
     mant := ten * mant + LFLOAT(ORD(str[i]) - ORD('0'));
#else
     mant := ten * mant + FLOAT(ORD(str[i]) - ORD('0'));
#endif
     INC(digits);
   END;
   INC(i);
 END;
END ParseDigits;

PROCEDURE ParseExponent ((* -- /AUS *) VAR exp : SIGNEDWORD ): BOOLEAN;
(* Ein optionaler Exponent wird gelesen und ausgewertet. Er darf ein
 * Vorzeichen haben und eine oder mehrere nachfolgende Ziffern.
 * Die Ziffern werden ihrer Wertigkeit entsprechend aufaddiert,
 * solange nicht der Maximalexponent ueberschritten wird; Zahlen,
 * die danach noch kommen, werden ueberlesen.
 *)
VAR         negExp : BOOLEAN;
    __REG__ e      : SIGNEDWORD;
            tmp    : SIGNEDWORD;

BEGIN
 e := 0;
 IF (i < sLen) & (CAP(str[i]) = 'E') THEN
   INC(i);
   IF (i < sLen) & ParseSign(negExp) & ('0' <= str[i]) & (str[i] <= '9') THEN
     REPEAT
       IF e < MAXEXP THEN
         INC(e, e);
         tmp := e;
         INC(e, e);
         INC(e, e);
         INC(e, tmp);
         INC(e, VAL(SIGNEDWORD,ORD(str[i]) - ORD('0')));
       END;
       INC(i);
     UNTIL (i >= sLen) OR (str[i] < '0') OR (str[i] > '9');

     IF negExp THEN
       e := -e;
     END;
   ELSE
     exp := 0;
     RETURN(FALSE);
   END;
 END;
 exp := e;
 RETURN(TRUE);
END ParseExponent;


BEGIN (* strToReal *)
 sLen     := VAL(SIGNEDWORD,LENGTH(str));
 shift    := 0;
 digits   := 0;
 i        := 0;
 mant     := null;
 maxTenth := max / ten;
#ifdef __EXP_UNDERFLOW__
 minTen   := min * ten;
#endif
 res      := strWrongFormat;

 (* Fuehrende Leerzeichen ueberlesen *)
 WHILE (i < sLen) & (str[i] = ' ') DO
   INC(i);
 END;

 IF i >= sLen THEN
   (* String besteht nur aus Leerzeichen *)
   res := strEmpty;
   RETURN(null);
 END;


 IF ~ParseSign(negMant) THEN
   (* Hinter einem Vorzeichen muss noch etwas folgen *)
   RETURN(null);
 END;

#ifdef __NO_LEADING_DIGITS__
 (* Die Zahl kann entweder mit mindestens einer Vorkommastelle
  * (auch wenn diese Null ist) oder einem Dezimalpunkt, dem mindestens
  * eine Nachkommastelle folgt, beginnen.
  *)
#endif
 ch := str[i];

 IF ('0' <= ch) & (ch <= '9') THEN
   (* Die Zahl beginnt mit Vorkommastellen. Zuerst werden fuehrende
    * Nullen einfach ueberlesen, da sie nichts zum Wert beitragen.
    * Dann folgen die echten Vorkommastellen, um deren Anzahl - 1
    * spaeter der Exponent korrigiert werden muss. Wenn ein
    * Dezimalpunkt existiert, muss zuerst geprueft werden, ob es
    * ueberhaupt gueltige (ungleich Null) Vorkommastellen gab;
    * wenn nicht, gibt die Anzahl der jetzt zu ueberlesenden, fuehrenden
    * Nachkommanullen die spaetere Exponentkorrektur an.
    * Ansonsten werden die optionalen echten Nachkommastellen, egal
    * ob Nullen oder nicht, verarbeitet.
    *)
   ParseZeros;
   shift := i;
   ParseDigits(mant);
   shift := i - shift - 1;

   IF i < sLen THEN
     IF str[i] = '.' THEN
       INC(i);
       IF shift < 0 THEN
         (* Keine Vorkommastellen ungleich Null *)
         shift := i;
         ParseZeros;
         DEC(shift, i + 1);
       END;
       ParseDigits(mant);
     END;
   END;
#ifdef __NO_LEADING_DIGITS__
 ELSIF ch = '.' THEN
   (* Die Zahl beginnt mit einem Dezimalpunkt. Danach muss mindestens
    * eine Ziffer folgen. Auch hier gibt die Anzahl der fuehrenden
    * Nachkommanullen die spaetere Exponentkorrektur an. Es folgen die
    * optionalen (wenn keine fuehrenden Nullen vorhanden waren, ist
    * es mindestens eine) echten Nachkommastellen.
    *)
   INC(i);
   IF (i < sLen) & ('0' <= str[i]) & (str[i] <= '9') THEN
     shift := i;
     ParseZeros;
     DEC(shift, i + 1);
     ParseDigits(mant);
   ELSE
     RETURN(null);
   END;
#endif
#ifdef __ONLY_EXP__
 ELSIF CAP(ch) = 'E' THEN
   (* Wenn die Zahl mit dem Exponenten beginnt, wird die Mantisse
    * zu 1.0 angenommen.
    *)
   mant   := one;
   digits := 1;
#endif
 ELSE
   (* Mit anderen Zeichen darf die Zahl nicht beginnen *)
   RETURN(null);
 END;


 IF ParseExponent(exp) & (i >= sLen) THEN
   (* Nach dem optionalen Exponenten muss der String beendet sein.
    * Je nach Entfernung der ersten zaehlenden Stelle vom Dezimalpunkt
    * muss der Exponent korrigiert werden.
    *)
   INC(exp, shift);

   (* Auf Ueberlauf testen. Entweder reicht der Exponent schon
    * aus, oder es wird bei einem Exponenten, der so gross ist wie der
    * maximale Exponent, mit einem Zehntel der Mantisse getestet, so dass
    * nicht schon beim Test das Malheur passiert.
    *)
   IF mant = null THEN
     res := strAllRight;
   ELSIF (exp > maxExp)
      OR (exp = maxExp) & (scale(mant, exp - digits) > maxTenth)
   THEN
     res  := strOutOfRange;
     mant := max;
#ifdef __EXP_UNDERFLOW__
   ELSIF (exp < minExp)
      OR (exp = minExp) & (scale(mant, exp - digits + 2) < minTen)
   THEN
     res  := strOutOfRange;
     mant := min;
#endif
   ELSE
     res  := strAllRight;
     mant := scale(mant, exp - digits + 1);
   END;

   IF negMant THEN
     mant := -mant;
   END;
 END;
 RETURN(mant);
END strToReal;

#if LONGREAL_var
(*===========================================================================*)

BEGIN (* FConvBase *)
 WITH lcast DO
   sl1 := 000000000H; ul2 := 000000000H; null  := lr;
   sl1 := 03FF00000H; (* wie oben *)     one   := lr;
   sl1 := 040140000H; (* wie oben *)     five  := lr;
   sl1 := 040220000H; (* wie oben *)     nine  := lr;
   sl1 := 040240000H; (* wie oben *)     ten   := lr;
   sl1 := 040590000H; (* wie oben *)     ten2  := lr;
   sl1 := 040C38800H; (* wie oben *)     ten4  := lr;
   sl1 := 04197D784H; (* wie oben *)     ten8  := lr; (* 1.0000000000000E+8 *)
   sl1 := 04341C379H; ul2 := 037E08000H; ten16 := lr; (* 1.0000000000000E+16 *)
   sl1 := 04415AF1DH; ul2 := 078B58C40H; ten20 := lr; (* 1.0000000000000E+20 *)
 END;
#endif
END FConvBase.
