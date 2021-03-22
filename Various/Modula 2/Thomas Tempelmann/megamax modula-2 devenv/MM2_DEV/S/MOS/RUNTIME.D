DEFINITION MODULE Runtime;              (* Juergen Mueller 26.3.85, 25.10.86 *)
                                        (* Th. Tempelmann 1.12.89            *)

(* Runtime Support fuer Megamax Modula-2   /4.0/  V#025

   Real-/LongInt-/LongCard-/Set-Arithmetik,
   Zuweisung fuer strukturierte Datentypen,
   Standard-Prozeduren.

   Alle Prozeduren koennen mit 'JSR name' auch von Assemblerteilen
   aus aufgerufen werden. Die Identifier werden automatisch in alle
   Module, auch lokale, importiert.
*)

FROM SYSTEM IMPORT WORD, LONGWORD, ADDRESS;

EXPORT PERVASIVE
  HALT,
  @LENW, @LENL, @ROTA, @SHFT, @CAP,
  @FP0L, @FP1L, @FP2L, @FP3L, @FP4L, @FP5L, @FP6L, @FP7L,
  @FP0H, @FP1H, @FP2H, @FP3H, @FP4H, @FP5H, @FP6H, @FP7H,
  @LC2S, @LI2S, @LC2D, @LI2D, @S2LC, @S2LI, @D2LC, @D2LI,
  @IMLL, @CMLL, @IDVL, @CDVL, @IMDL, @CMDL,
  @IMLW, @CMLW, @IDVW, @CDVW, @IMDW, @CMDW,
  @LREQ, @LRNE, @LRGT, @LRGE, @LRLT, @LRLE,
  @LNEG, @LABS, @LADD, @LSUB, @LMUL, @LDIV,
  @STOL, @LTOS, @SRGT, @SRGE, @SRLT, @SRLE,
  @SNEG, @SABS, @SADD, @SSUB, @SMUL, @SDIV,
  @FNUL, @FOPS, @FOPD, @FMVS, @FMVD, @FCPN, @FCPS, @FCPD,
  @FP7S, @FP7D, @FP3S, @FP3D, @FG7S, @FG7D, @FG3S, @FG3D, @FP7M, @FG7M,
  @SAND, @SXOR, @SSUM, @SDIF, @SEQL, @SLEQ, @SMEM, @EXCL, @INCL, @SIRG,
  @SAN1, @SXO1, @SSU1, @SDI1, @SAN2, @SXO2, @SSU2, @SDI2,
  @PS3B, @PS3W, @PS3L, @PS7B, @PS7W, @PS7L,
  @CWOP, @CLOP, @COPW, @COPL,
  @VFPU, @V020,
  @PRIO, @LSTN, @NEWP, @TRAN, @IOTR, @IOCA, @STK1, @STK2,
  @RES1, @RES2, @RES3, @RES4, @RES5, @RES6, @RES7,
  @IMUL, @CMUL, @IDIV, @CDIV, @IMOD, @CMOD;


(* Standard-Identifier *)

PROCEDURE HALT;


(* CAP-Funktion fÅr Variable *)

PROCEDURE @CAP;         (* D0.B:= CAP (D0.W)  -- High-Byte muû Null sein! *)


(* FLOAT / TRUNC - Routinen *)

PROCEDURE @LC2S;      (* LC(D0.L) -> SR(D0.L) *)
PROCEDURE @LI2S;      (* LI(D0.L) -> SR(D0.L) *)
PROCEDURE @LC2D;      (* LC(D0.L) -> LR(A0)   *)
PROCEDURE @LI2D;      (* LI(D0.L) -> LR(A0)   *)
PROCEDURE @S2LC;      (* SR(D0.L) -> LC(D0.L) *)
PROCEDURE @S2LI;      (* SR(D0.L) -> LI(D0.L) *)
PROCEDURE @D2LC;      (* LR(A0)   -> LC(D0.L) *)
PROCEDURE @D2LI;      (* LR(A0)   -> LI(D0.L) *)


(*
 * Real- und Long-Arithmetik fÅr Megamax-Reals
 *)

(* Pseudo-Register f. Reals *)

VAR @FP0L: LONGWORD; @FP0H: LONGWORD;
    @FP1L: LONGWORD; @FP1H: LONGWORD;
    @FP2L: LONGWORD; @FP2H: LONGWORD;
    @FP3L: LONGWORD; @FP3H: LONGWORD;
    @FP4L: LONGWORD; @FP4H: LONGWORD;
    @FP5L: LONGWORD; @FP5H: LONGWORD;
    @FP6L: LONGWORD; @FP6H: LONGWORD;
    @FP7L: LONGWORD; @FP7H: LONGWORD;

(* Bei allen Real-Operationen sind die Regs D0-D2/A0-A2/FP0-FP2 frei *)

PROCEDURE @LREQ;       (*  "a = b"   (A1),(A0) -> D0 *)
PROCEDURE @LRNE;       (*  "a # b"   (A1),(A0) -> D0 *)
PROCEDURE @LRLE;       (*  "a <= b"  (A1),(A0) -> D0 *)
PROCEDURE @LRGE;       (*  "a >= b"  (A1),(A0) -> D0 *)
PROCEDURE @LRLT;       (*  "a < b"   (A1),(A0) -> D0 *)
PROCEDURE @LRGT;       (*  "a > b"   (A1),(A0) -> D0 *)

PROCEDURE @LNEG;       (*  "  - a"   (A0) -> (A0) *)
PROCEDURE @LABS;       (*  "  |a|"   (A0) -> (A0) *)
PROCEDURE @LMUL;       (*  "a * b"   (A1),(A0) -> (A1) *)
PROCEDURE @LDIV;       (*  "a / b"   (A1),(A0) -> (A1) *)
PROCEDURE @LADD;       (*  "a + b"   (A1),(A0) -> (A1) *)
PROCEDURE @LSUB;       (*  "a - b"   (A1),(A0) -> (A1) *)


(* Megamax Fast Floating Point Routinen           jm 3.2.90  *)

PROCEDURE @STOL;       (* D0 -> (A0) *)
PROCEDURE @LTOS;       (* (A0) -> D0 *)

PROCEDURE @SRLE;       (*  "a <= b"  D1,D0 -> D0 *)
PROCEDURE @SRGE;       (*  "a >= b"  D1,D0 -> D0 *)
PROCEDURE @SRLT;       (*  "a < b"   D1,D0 -> D0 *)
PROCEDURE @SRGT;       (*  "a > b"   D1,D0 -> D0 *)

PROCEDURE @SNEG;       (*  "  - a"   D0 -> D0 *)
PROCEDURE @SABS;       (*  "  |a|"   D0 -> D0 *)

PROCEDURE @SMUL;       (*  "a * b"   D1,D0 -> D1 *)
PROCEDURE @SDIV;       (*  "a / b"   D1,D0 -> D1 *)
PROCEDURE @SADD;       (*  "a + b"   D1,D0 -> D1 *)
PROCEDURE @SSUB;       (*  "a - b"   D1,D0 -> D1 *)


(*
 * Real- und Long-Arithmetik fÅr IEEE-Reals Åber FPU (68881/2) bei $F+
 * Bei allen Routinen wird A2 zerstîrt.
 *)

PROCEDURE @FNUL;       (* F-Instr. in D0 *)
PROCEDURE @FOPS;       (* F-Instr. in D0, arg.S in D1 *)
PROCEDURE @FOPD;       (* F-Instr. in D0, arg.D in (A0) *)
PROCEDURE @FMVS;       (* F-Instr. in D0, FP.S nach (A0) *)
PROCEDURE @FMVD;       (* F-Instr. in D0, FP.D nach (A0) *)
PROCEDURE @FCPN;       (* F-Instr. in D0, Cond. in D2 *)
PROCEDURE @FCPS;       (* F-Instr. in D0, Cond. in D2, arg.S in D1 *)
PROCEDURE @FCPD;       (* F-Instr. in D0, Cond. in D2, arg.D in (A0) *)
PROCEDURE @FP7S;       (* F-Instr. in D2, FP.S nach -(A7) *)
PROCEDURE @FP7D;       (* F-Instr. in D2, FP.D nach -(A7) *)
PROCEDURE @FP3S;       (* F-Instr. in D2, FP.S nach (A3)+ *)
PROCEDURE @FP3D;       (* F-Instr. in D2, FP.D nach (A3)+ *)
PROCEDURE @FG7S;       (* F-Instr. in D2, (A7)+ nach FP.S *)
PROCEDURE @FG7D;       (* F-Instr. in D2, (A7)+ nach FP.D *)
PROCEDURE @FG3S;       (* F-Instr. in D2, -(A3) nach FP.S *)
PROCEDURE @FG3D;       (* F-Instr. in D2, -(A3) nach FP.D *)
PROCEDURE @FP7M;       (* FMOVEM auf A7; Instr. in D0 *)
PROCEDURE @FG7M;       (* FMOVEM von A7; Instr. in D0 *)
PROCEDURE @VFPU;       (* Laufzeitfehler, wenn keine FPU vorhanden ist *)


(*
 * LONGCARD / LONGINT - Arithmetik
 *
 * Int-Routinen setzen V-Bit, Card-Routinen das Carry-Bit bei öberlauf.
 * Die Long-Divisionen prÅfen den Divisor selbst auf Null, bei den letzten
 * vier Word-Divisionen muû der Divisor vorher entspr. geprÅft werden.
 *)

PROCEDURE @IMLL;       (* D0.L := D0.L * D1.L   /D2/ *)
PROCEDURE @CMLL;
PROCEDURE @IDVL;       (* D0.L := D0.L / D1.L   /D2/ *)
PROCEDURE @CDVL;
PROCEDURE @IMDL;       (* D0.L := D0.L % D1.L   /D2/ *)
PROCEDURE @CMDL;
PROCEDURE @IMLW;       (* D0.L := D0.L * D1.W   /D2/  (0<=D1<32768) *)
PROCEDURE @CMLW;       (*                                           *)
PROCEDURE @IDVW;       (* D0.L := D0.L / D1.W   /D2/  (0<D1<32768)  *)
PROCEDURE @CDVW;       (*                             (D1#0)        *)
PROCEDURE @IMDW;       (* D0.L := D0.L % D1.W   /D2/  (0<D1<32768)  *)
PROCEDURE @CMDW;       (*                             (D1>0)        *)

(*
 * Kopien auf A3/A7-Stack anlegen
 * Registerbelegung: A1: source-Ptr; D1.L: anzahl in bytes/words/longs;
 *  A0: Adr. f. Pointer auf kopierte Daten (nur bei A7-Stack);
 *  A2 ist frei, A0/D2/A2 aber nicht!.
 *)
PROCEDURE @PS3B;        (* byte-weise nach A3 *)
PROCEDURE @PS3W;        (* word-weise nach A3 *)
PROCEDURE @PS3L;        (* long-weise nach A3 *)
PROCEDURE @PS7B;        (* byte-weise nach A7 *)
PROCEDURE @PS7W;        (* word-weise nach A7 *)
PROCEDURE @PS7L;        (* long-weise nach A7 *)

(*
 * Open Arrays m. 1 HIGH-Wert und Byte-Elementen auf Stack kopieren.
 * Kopieren Ptr & High-Wert auf A3-, Daten auf A7-Stack
 *)
PROCEDURE @CWOP;        (* HIGH ist [0..32767] *)
PROCEDURE @CLOP;        (* HIGH ist LONGCARD *)

(*
 * Daten kopieren.
 * Registerbelegung: A1: source-Ptr; D0: anzahl in bytes; A0: ziel-Pointer;
 *)

PROCEDURE @COPW;       (* D0 ist Word, D1 frei *)
PROCEDURE @COPL;       (* D0 ist Longword, D1/D2/A2 frei *)

(*
 * Set-Manipulation.
 *)

PROCEDURE @SAND;      (*  "s * t"   *)
PROCEDURE @SXOR;      (*  "s / t"   *)
PROCEDURE @SSUM;      (*  "s + t"   *)
PROCEDURE @SDIF;      (*  "s - t"   *)
PROCEDURE @SAN1;
PROCEDURE @SXO1;
PROCEDURE @SSU1;
PROCEDURE @SDI1;
PROCEDURE @SAN2;
PROCEDURE @SXO2;
PROCEDURE @SSU2;
PROCEDURE @SDI2;
PROCEDURE @SEQL;      (*  "s = t"  Ergebnis in Z-Flag *)
PROCEDURE @SLEQ;      (*  "s <= t" Ergebnis in Z-Flag *)
PROCEDURE @SMEM;      (*  "e IN s" Ergebnis in Z-Flag *)
PROCEDURE @INCL;      (*  INCL (s, e) *)
PROCEDURE @EXCL;      (*  EXCL (s, e) *)
PROCEDURE @SIRG;      (*  INCL (s, lo..hi) *)

(*
 * LENGTH-Funktionen
 *   Reg-Belegung: A0: Ptr auf String; D0: HIGH (String) & Ergebnis;
 *                 D1 ist frei.
 *)
PROCEDURE @LENW;        (* LENGTH f. Strings < 64KB *)
PROCEDURE @LENL;        (* LENGTH f. Strings > 64KB *)

(*
 * SHIFT/ROTATE-Funktionen
 *)
PROCEDURE @ROTA;  (* D0: Argument, D1: Rotierweite, D2: 7/15/31 (Arg-Breite) *)
PROCEDURE @SHFT;  (* D0: Argument, D1: Schubweite,  D2: 7/15/31 (Arg-Breite) *)


(* Coroutinen-Unterstuetzung *)

PROCEDURE @NEWP ( p: PROC; wspAddr: ADDRESS; wspSize: LONGCARD; VAR prc: ADDRESS);
PROCEDURE @TRAN ( VAR resumed, new: ADDRESS );
PROCEDURE @IOTR ( VAR resumed, new: ADDRESS; addr: ADDRESS );
PROCEDURE @IOCA ( addr: ADDRESS );
PROCEDURE @LSTN;

PROCEDURE @PRIO;  (* PrioritÑt bei Monitor-Modulen setzen *)
PROCEDURE @STK1;  (* Stack-Check mit festem $200-Space *)
PROCEDURE @STK2;  (* Stack-Check mit variablem Space *)

PROCEDURE @V020;  (* Laufzeitfehler, wenn keine 68020/30/ff. vorhanden ist *)

PROCEDURE @RES1;  (* Vergleicht 8 Byte (A0) <-> (A1), Erg. in Z-Flag *)
PROCEDURE @RES2;
PROCEDURE @RES3;
PROCEDURE @RES4;
PROCEDURE @RES5;
PROCEDURE @RES6;
PROCEDURE @RES7;

PROCEDURE @IMUL (a,b: LONGINT ): LONGINT;  (*  "a * b"    *)
PROCEDURE @CMUL (a,b: LONGCARD): LONGCARD; (*  "a * b"    *)
PROCEDURE @IDIV (a,b: LONGINT ): LONGINT;  (*  "a div b"  *)
PROCEDURE @CDIV (a,b: LONGCARD): LONGCARD; (*  "a div b"  *)
PROCEDURE @IMOD (a,b: LONGINT ): LONGINT;  (*  "a mod b"  *)
PROCEDURE @CMOD (a,b: LONGCARD): LONGCARD; (*  "a mod b"  *)

END Runtime.
