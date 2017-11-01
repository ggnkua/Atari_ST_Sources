MODULE FastPrint;                                 (* Mit Mini-GEMX linken! *)
(* ½ 1994-95 ROLF SCHRADER.                  * 7.10.94 + 1.11.94 ++ 6.2.95 *)
(*
   Ein schneller Centronics-Treiber. Das TSR-Programm h„ngt sich in den BIOS-
   Trap ein, f„ngt alle Druckausgaben ab und leitet die Daten selbst zur
   Centronics-Schnittstelle; und zwar wesentlich schneller, als jede TOS-
   Version, sogar auch das TT-TOS! Man kann's vom Desktop starten, oder am
   besten gleich in den AUTO-Ordner packen und vergessen ....

   Lit.:       Eckehard Fiedler: "Entfesselte Ausgabe", c't 10/91 S.264-267
           Brckmann et al.: "Atari ST intern", Data Becker 1985, S.318-369
*)
(*$S-,$T-,$Q+*)

FROM   SYSTEM  IMPORT ADR, ADDRESS, LONGWORD, CODE, REGISTER, SETREG;
IMPORT GDB, Mini, GEMX;

CONST  RTS = 4E75H;  BIOSVEC = 0B4H;  XMAG = 58425241H (* ="XBRA"*);
       RTE = 4E73H;  PRNTVEC = 50AH;  FPRN = 4650524EH (* ="FPRN"*);

       TRAP = 4E40H; XTRAP = TRAP +14;  HZ200  = 4BAH;
       JUMP = 4EF9H (* jmp abs.l *);    LONGSR = 59EH;

       PUSHW = 3F3CH;       (* MOVE.W #*,-(A7);      W.-Konst. auf'n Stack.*)
       PUSHV = 2F2EH;       (* MOVE.L s(A6),-(A7);   Long- v VAR-Parameter.*)

TYPE   xBRA = RECORD MAGIC, Ident: LONGINT; OldVec: PROC;
                     ENTRY:        INTEGER; NewPrc: PROC; END;

VAR    xB,xP: xBRA;
       PrPr4: PROC;

       BiosVec[BIOSVEC],
       PrntVec[PRNTVEC]: PROC;

       Hz200[HZ200], Time: LONGINT;

PROCEDURE TrapProc; (*$P-*)                    (* New BIOS trap dispatcher.*)
 BEGIN
   CODE (
    0817H,13,                (* BTST.B  #13, (A7) ;  called in super mode? *)
    6600H+04,                (* BNE.S   wasSuper  *)
    4E69H,                   (* MOVE.L  USP, A1   ;  else p. on user stack *)
    6000H+12,                (* BRA.S   Select    *)
(* wasSuper: *)
    43EFH,0006H,             (* LEA.L   6H(A7),A1 ; -> parameters *)
    4A78H,059EH,             (* TST.W   LONGSR    ;   68000er stackframe ? *)
    6700H+02,                (* BEQ.S   Select    *)
    5489H,                   (* ADDQ.L  #2, A1    ;  no, long stack frame! *)
(* Select: *)
    0C91H,0003H,0000H,       (* CMPI.L  #30000H,(A1); Bconout ? *)
    6700H+24,                (* BEQ.S   NewPrnt   *)
    0C91H,0008H,0000H,       (* CMPI.L  #80000H,(A1); Bconstat? *)
    6700H+08 );              (* BEQ.S   NewStat   *)
   SETREG (8, xB.OldVec);
   CODE (4ED0H);             (* JMP     (A0)      ; normal BIOS *)
(* NewStat: *)
   SETREG (8, StatProc);
   CODE (6000H+06);          (* BRA.S   Execute   *)
(* NewPrnt: *)
   SETREG (8, PrPr4);
(* Execute: *)
   CODE (
    3029H,0004H,             (* MOVE.W  4H(A1),D0 ; set output value *)
    4E90H,                   (* JSR     (A0)      ; execute routine  *)
    RTE ); END TrapProc;

PROCEDURE StatProc; (*$P-*)
 BEGIN
   CODE (
    70FFH,                   (* MOVEQ.L #-1H, D0  ; default = ok *)
    0239H,00FEH,0FFH,0FA05H, (* ANDI.B  #FEH, MFPDTDR ; MFP bit 0 DataIn *)
    0839H,0000H,0FFH,0FA01H, (* BTST.B  #0H,  MFPPORT ; Centronics busy? *)
    6700H+02,                (* BEQ.S   rts       ; ready => return -1   *)
    7000H,                   (* MOVEQ.L #00H, D0  ; else return 0 *)
    RTS ); END StatProc;

PROCEDURE PrntProc; (*$P-*)
 BEGIN
   CODE (
(* DumpEntry: *)             (* Here TOS' screendump function enters.*)
    302FH,0004H,             (* MOVE.W  4H(A7),D0 ; get output value *)
(* Entry: *)                 (* Here the new Bprnout starts.*)
    2438H,04BAH,             (* MOVE.L  HZ200, D2 ; get start time *)
(* BusyCheck: *)
    0239H,00FEH,0FFH,0FA05H, (* ANDI.B  #FEH, MFPDTDR ; MFP bit 0 DataIn *)
    0839H,0000H,0FFH,0FA01H, (* BTST.B  #0H,  MFPPORT ; centronics busy? *)
    6700H+44 );              (* BEQ.S   DoIt      ; ready => DoIt  *)
   SETREG (1, Time);         (* MOVE.L  Time,  D1 ; get error time *)
   CODE (
    92B8H,04BAH,             (* SUB.L   HZ200, D1 ; compare to act. time *)
   0D2BCH,0000H,03E8H,       (* ADD.L   #1000, D1 ; < 5 sec ?  *)
    6A00H+14,                (* BPL.S   TimeOut   ;  new error *)
    2238H,04BAH,             (* MOVE.L  HZ200, D1 ; get act. time *)
    9282H,                   (* SUB.L   D2, D1 *)
   0B2BCH,0000H,0FA0H,       (* CMP.L   #4000, D1 ; < 20 sec ? *)
    6E00H-50 );              (* BLT.S   BusyCheck ;  then wait *)
(* TimeOut: *)
   Time := Hz200;            (* MOVE.L  HZ200,Time; 8 bytes *)
   CODE ( 4280H, RTS );      (* CLR.L  D0 and RTS *)
(* DoIt: *)
   CODE (
    40E7H,                   (* MOVE.W  SR, -(A7) ; save interrupt mask  *)
    007CH,0700H,             (* ORI.W   #700H, SR ; no interrupts please *)
    43F9H,00FFH,8800H,       (* LEA.L   SNDCHIP,A1 *)
    12BCH,0007H,             (* MOVE.B  #7H, (A1) ; select DD-reg.*)
    1211H,                   (* MOVE.B  (A1), D1  ; read reg. DD  *)
    823CH,{6,7},             (* OR.B    #C0H, D1  ; ports A & B   *)
    1341H,0002H,             (* MOVE.B  D1,2H(A1) ; set exit      *)
    12BCH,000FH,             (* MOVE.B  #FH, (A1) ; select port B *)
    1340H,0002H,             (* MOVE.B  D0,2H(A1) ; output char   *)
    12BCH,000EH,             (* MOVE.B  #EH, (A1) ; select port A *)
    1211H,                   (* MOVE.B  (A1), D1  ; read port A   *)
   0C23CH,{0..4,6,7},        (* AND.B   #DFH, D1  ; excl. strobe  *)
    1341H,0002H,             (* MOVE.B  D1,2H(A1) ; strobe low    *)
(*  7464H,                      MOVEQ.B #100,D2   ; strobe delay: *)
(*  4E71H,                      loop: NOP         ;  activate iff *)
(*  51CAH,                      DBF     D2,loop   ;  printer requ.*)
    823CH,{5},               (* OR.B    #20H, D1  ; incl. strobe  *)
    1341H,0002H,             (* MOVE.B  D1,2H(A1) ; strobe high   *)
    46DFH,                   (* MOVE.W  (A7)+, SR ; enable interrupts *)
    70FFH,                   (* MOVEQ.L #-1H, D0  ; return -1 for ok  *)
    RTS ); END PrntProc;

(*$P+*)

PROCEDURE SupExec (Code: PROC): (*ReturnFromCodeProc:*) ADDRESS;    (* X38 *)
 BEGIN CODE (PUSHV,8, PUSHW,38, XTRAP); RETURN REGISTER (0) END SupExec;

PROCEDURE xSet (Id, Old,New: LONGWORD; VAR x: xBRA): (*Entry:*) ADDRESS;
 BEGIN WITH x DO MAGIC := XMAG; ENTRY := JUMP; Ident := LONGINT (Id);
          OldVec := PROC (Old); NewPrc := PROC (New);
          RETURN ADR (ENTRY); END (*x*); END xSet;

PROCEDURE install;
 VAR   pxI: POINTER TO xBRA;
 BEGIN pxI := ADDRESS (PrntVec) -12;
   IF (pxI^.MAGIC =XMAG) & (pxI^.Ident =FPRN) THEN SETREG (0, 0); RETURN END;
   BiosVec := PROC (xSet (FPRN, BiosVec, TrapProc, xB));
   PrntVec := PROC (xSet (FPRN, PrntVec, PrntProc, xP));
   SETREG (0, 1); END install;

PROCEDURE Install (): BOOLEAN;
 BEGIN RETURN (1 = SupExec (install)) END Install;
(*
 VAR   eP: LONGCARD;
 BEGIN IF BIOX.InqVec (PRNTVEC, eP, xP)
           & (xP.Ident = FPRN) THEN RETURN FALSE END;
   BIOX.SetVec (BIOSVEC, FPRN, TrapProc, xB);
   BIOX.SetVec (PRNTVEC, FPRN, PrntProc, xP);
   RETURN TRUE; END Install;
*)
PROCEDURE Ln; BEGIN Mini.wT (15c); Mini.wT (12c) END Ln;

BEGIN Ln; Mini.wT (" Centronics Driver ½ '94 Drupert Pixler "); Ln;
      PrPr4 := PROC (4+ LONGCARD (PrntProc));
   IF Install () THEN GDB.Stay (0, GEMX.pBP^.HiTPA - GEMX.pBP^.LoTPA);
   ELSE   Mini.wT ("      is already resident."); Ln END;
   END FastPrint .
