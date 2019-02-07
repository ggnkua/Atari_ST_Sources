IMPLEMENTATION MODULE GEMX;              (* Check: vor Mini-GEMX benutzen! *)
(* ½ 1991-96 ROLF SCHRADER. * 3.2.93 ~ 8.3.96 *)
(*$T-,$S-,$Q+*)
(*
   Gebrauch (um die Benutzung der Dienste von GEMX zu checken):
   Das zu checkende Prg. mit diesem Modul anstatt des normalen GEMX linken,
   dann mit einem Disassembler oder einem Monitor die Nummern der benutzten
   Dienste herausfinden, indem nach " LINK A6,#0H 00?? UNLK RTS " bzw. nach
   " 4E56 0000 00?? 4E5E 4E75 " gesucht wird.
   Achtung, das hiermit erzeugte Prg. ist nicht ablauff„hig, falls wirklich
   Dienste beansprucht werden!
*)

FROM  SYSTEM  IMPORT ADDRESS,LONGWORD,WORD, PROCESS, CODE, REGISTER,SETREG;

TYPE  LC = LONGCARD; LI = LONGINT; LR = LONGREAL; AD = ADDRESS;
      LW = LONGWORD; PR = PROCESS;

(* Dienste: *)

PROCEDURE CASEX; BEGIN CODE (01H) END CASEX;
PROCEDURE HALTX; BEGIN CODE (02H) END HALTX;
PROCEDURE STACKTEST;  BEGIN CODE (03H) END STACKTEST;               (* !!! *)
PROCEDURE NEWPROCESS (P: PROC; F: AD; L: LC; VAR D: PR; I: LC);
                      BEGIN CODE (04H) END NEWPROCESS;
PROCEDURE   TRANSFER; BEGIN CODE (05H) END TRANSFER;
PROCEDURE IOTRANSFER; BEGIN CODE (06H) END IOTRANSFER;
PROCEDURE SYSCALL;    BEGIN CODE (07H) END SYSCALL;
PROCEDURE MULU32   (M1, M2: LC); BEGIN CODE (08H) END MULU32;
PROCEDURE DIVU32   (DD, DS: LC); BEGIN CODE (09H) END DIVU32;
PROCEDURE MULS32   (M1, M2: LI); BEGIN CODE (10H) END MULS32;
PROCEDURE DIVS32   (DD, DS: LI); BEGIN CODE (11H) END DIVS32;
PROCEDURE FADD     (A, B: REAL); BEGIN CODE (12H) END FADD;
PROCEDURE FSUB     (M, S: REAL); BEGIN CODE (13H) END FSUB;
PROCEDURE FMUL     (A, B: REAL); BEGIN CODE (14H) END FMUL;
PROCEDURE FDIV     (A, B: REAL); BEGIN CODE (15H) END FDIV;
PROCEDURE FCMP     (D, S: REAL); BEGIN CODE (16H) END FCMP;
PROCEDURE FTST     (TOTE: REAL); BEGIN CODE (17H) END FTST;
PROCEDURE FLOATX   (TOCO:   LW); BEGIN CODE (18H) END FLOATX;
PROCEDURE TRUNCX   (TOCO: REAL); BEGIN CODE (19H) END TRUNCX;
PROCEDURE LFADD    (A1, A2: LR); BEGIN CODE (20H) END LFADD;
PROCEDURE LFSUB    (M,  S : LR); BEGIN CODE (21H) END LFSUB;
PROCEDURE LFMUL    (M1, M2: LR); BEGIN CODE (22H) END LFMUL;
PROCEDURE LFDIV    (DD, DS: LR); BEGIN CODE (23H) END LFDIV;
PROCEDURE LFCMP    (D,  S : LR); BEGIN CODE (24H) END LFCMP;
PROCEDURE LFTST    (TOTEST: LR); BEGIN CODE (25H) END LFTST;
PROCEDURE LFLOATX  (TOCONV: LW); BEGIN CODE (26H) END LFLOATX;
PROCEDURE LTRUNCX  (TOCONV: LR); BEGIN CODE (27H) END LTRUNCX;
PROCEDURE LENGTHEN (TOCO: REAL); BEGIN CODE (28H) END LENGTHEN;
PROCEDURE SHORTEN  (TOCONV: LR); BEGIN CODE (29H) END SHORTEN;

PROCEDURE aMPD (): AD; BEGIN CODE (30H) END aMPD;

CONST DTRAP = 4E41H;
      PUSHV = 2F2EH; (* MOVE.L s(A6),-(A7)  Long- oder VAR-Par.*)
      PUSHW = 3F3CH; (* MOVE.W #*,-(A7); W.-Konst. auf'n Stack.*)

PROCEDURE Shrink (BlockAdr, NewSize: AD);
 BEGIN CODE (PUSHV,8 ,PUSHV,8+4, PUSHW,0, PUSHW,4AH, DTRAP) END Shrink;

PROCEDURE Halt;
  (*$P-*) BEGIN CODE (PUSHW,0, DTRAP); Dummy (" ½ '96 RS ") END Halt;

PROCEDURE Dummy (VAR s: ARRAY OF CHAR); END Dummy;

VAR   lTPA: AD;
      pLI:  POINTER TO LI;

(*$P- Startup: *)
BEGIN noAcc := (0= REGISTER(8)); (* Acc-pBP aus A0, sonst vom Parent-Stack.*)
   IF noAcc THEN CODE (206FH, 4) (* MOVEA.L 4(SP),A0 *) END;
   pBP := REGISTER (8);
   WITH pBP^ DO   pLI := CodeBase +6;                      (* -> Patx-Area.*)
      lTPA := 100H + CodeLen + DataLen + BssLen;
(**)  IF noAcc & (pLI^ > 0) THEN INC (lTPA, pLI^) END;     (* not in BSS ? *)
      HiTPA := AD (pBP) + lTPA; END;
   SETREG (14, 0);
   IF noAcc  OR  (pLI^ < 0) THEN SETREG (13, pBP^.HiTPA -12);
   ELSE  SETREG (13, AD (pBP) +256 -12) END;      (* Vorl„ufiger Acc-Stack.*)
   SETREG (15, REGISTER (13) -36);
   pLI := REGISTER (13);
   pLI^ := 0;
   IF noAcc THEN Shrink (pBP, lTPA);              (* Returns spare memory! *)
      SETREG (9, Halt); CODE (2F09H) (* MOVE.L A1,-(SP) *) END; (* TermPrc.*)
   END GEMX.
