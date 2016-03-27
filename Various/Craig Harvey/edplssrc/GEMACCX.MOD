IMPLEMENTATION MODULE GEMX;
(* Restore GEM registers A1-2/D1-2 after MShrink call,
   and do normal stack fixing. 2.30, 1/29/92
   *)
(* increase size of stack again, 1/15/92 *)
(* ---------------------------------------------------------------------- *)
(* (c) Copyright 1986, 1987  Modula-2 Software Ltd.  All Rights Reserved. *)
(* ---------------------------------------------------------------------- *)
(* (c) Copyright 1986, 1987  TDI Software, Inc.      All Rights Reserved. *)
(* ---------------------------------------------------------------------- *)

(* VERSION FOR GEM
 

     Version         :      4.10a  05-Jan-87  Phil Camp, M2SW
                            Mods for 32 bit (3.00a) compiler.
                            4.00a    05-Feb-85    Paul Curtis TDI.
                            Body of GEMX not initialising the display
                            pointer A5. Fixed by moving startup code
                            into body of GEMX.
                            Corrected stack alignment.
                            O3.01a    17-Aug-85    Phil Camp TDI
                            Fixed DIVS32 code.
                            Made error processor put mouse back on screen.
                            3.00a    08-Aug-85    Phil Camp TDI
                            GEM adaption.
                            2.00a    28-Jun-85    Phil Camp TDI
                            Added LONGREAL hooks.
                            Implmented 32 bit signed divide.
                            1.10a    30-May-85    Phil Camp TDI
                            Fixed bug in floating point add (again!). Was
                            bug in rounding of precision overflow.
                            1.01a    17-Dec-84    Phil Camp TDI
                            Fixed bug in floating point add -0 detect code.
                            1.00a    17-Oct-84    Phil Camp TDI   (MOSYS 1.00a)
                            Converted for TDI Pinnacle from SAGE

*)

(*$T- NEVER ACTIVATE RUNTIME TESTS FOR 'SYSTEMX' *)
(*$S- NEVER ACTIVATE STACK TESTS FOR 'SYSTEMX'   *)


(*                S Y S T E M X                      *)
(*                -------------                      *)
(*                                                   *)
(*         MOTOROLA MC68000 RUNTIME SYSTEM.          *)
(*                                                   *)
(*                  VERSION 2.0                      *)
(*                                                   *)
(*                                                   *)
(*     31.03.82             HERMANN SEILER           *)
(*     31.07.82 UPDATED.       RZETHZ.               *)
(*     31.10.82 UPDATED.                             *)
(*                                                   *)
(*     30.09.82 CHANGES FOR ELECTRONIC INSTITUTE     *)
(*              R. FISCHER   MARKED WITH ( ++ )      *)
(*                                                   *)
(*     22.04.83 E. BALLARIN (TEMP. CHANGES) MARKED   *)
(*              WITH ( &&&& )                        *)
(*                                                   *)
(*     31.08.83 ADAPTED FOR COMPILER VERSION 4.0     *)
(*              R. FISCHER                           *)
(*              (PROGRAMS STILL RUN IN USER-MODE)    *)
(*                                                   *)
(*     25/01/84 SAGE IV adaption                     *)
(*              Phil Camp  TDI Ltd.  ($$TDI)         *)
(*                                                   *)


FROM SYSTEM IMPORT ADDRESS, PROCESS, LONGWORD,
                   ADR, TSIZE,
                   CODE, ASH,
                   REGISTER, SETREG;


CONST


     (* REGISTER USAGE AND DEDICATED REGISTERS : *)

     (* D-REGISTER POOL FOR EXPRESSION EVALUATION. *)

     D0  = 0;   (* D-REGISTER POOL, FREELY USED, NEVER RESERVED *)
     D1  = 1;   (* D-REGISTER POOL, RESERVED WHEN USED *)
     D2  = 2;   (* D-REGISTER POOL, RESERVED WHEN USED *)
     D3  = 3;   (* D-REGISTER POOL, RESERVED WHEN USED *)
     D4  = 4;   (* D-REGISTER POOL, RESERVED WHEN USED *)
     D5  = 5;   (* D-REGISTER POOL, RESERVED WHEN USED *)
     D6  = 6;   (*   NEVER USED    *)
     D7  = 7;   (*   NEVER USED    *)

     (* A-REGISTER POOL FOR ADDRESS CALCULATIONS.  *)
     (* NOTE : THE VALUES ASSIGNED TO THE A-REG.-  *)
     (* ----   CONSTANTS DIFFER FROM THESE USED    *)
     (*        IN THE CONST-DEFINITION OF PASS4X.  *)

     A0  = 0;   (* A-REGISTER POOL, FREELY USED, NEVER RESERVED *)
     A1  = 1;   (* A-REGISTER POOL, RESERVED WHEN USED *)
     A2  = 2;   (* A-REGISTER POOL, RESERVED WHEN USED *)
     A3  = 3;   (* A-REGISTER POOL, RESERVED WHEN USED *)
     A4  = 4;   (* A-REGISTER POOL, RESERVED WHEN USED *)

     (* DEDICATED A-REGISTERS : *)

     A5  = 5;   (* DEDICATED FOR : *)
     PD  = 5;   (* PD = A5 : POINTER TO ACTIVE PROCESS DESCRIPTOR *)
     A6  = 6;   (* DEDICATED FOR : *)
     MP  = 6;   (* MP = A6 : STACK MARKER FOR LOCAL VARS./PARAMETERS *)
     A7  = 7;   (* DEDICATED FOR : *)
     SP  = 7;   (* SP = A7 : ACTIVE STACK POINTER      *)


     (* ADDRESSING MODE CATEGORIES. *)

     DDIR     = 0;       (* D-REG. DIRECT  *)
     ADIR     = 10B;     (* A-REG. DIRECT  *)
     AIDR     = 20B;     (*     (AN)       *)
     AINC     = 30B;     (*     (AN)+      *)
     ADEC     = 40B;     (*    -(AN)       *)
     AOFF     = 50B;     (*   OFFSET(AN)   *)
     AIDX     = 60B;     (*    D(AN,DX)    *)
     XXXW     = 70B;     (* ABSOLUTE SHORT *)
     XXXL     = 71B;     (* ABSOLUTE LONG  *)
     PREL     = 72B;     (* PC RELATIVE    *)
     IMM      = 74B;     (* IMMEDIATE  OR  *)
     ISR      = 74B;     (* STATUS REGISTER*)


     (* INSTRUCTION SIZE (NOT VALID FOR MOVE GROUP) *)

     BYTE  =  0;    WORD  =  1;    LONGW  =  2;    UNDF  =  3;

     (* THE RANGE OF 16 BIT SIGN EXTENDED DISPLACEMENT *)

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&& *)
     MINIDUMMY = -32766;    MINIOFF = MINIDUMMY - 1;

  (* MINIOFF  =  -32767; *)
(* &&&&&&&&&&&&&&&&&&&&&&&&&&&& *)
     MAXIOFF  =  32767;

     (* MC68000 INSTRUCTION MNEMONICS. *)
     (* -----------------------------  *)

     (* SPECIAL PURPOSE. *)
     UNLK     = 047136B; (* UNLINK MP *)
     LINK     = 047126B; (* LINK MP,#DISPLACEMENT *)
     LEASP    = 047757B; (* LEA DISPLACEMENT(SP),SP *)
     INCSP    = 050217B; (* ADDQ.L #N,SP *)
     DECSP    = 050617B; (* SUBQ.L #N,SP *)
     MOVEMDEC = 044347B; (* MOVEM.L REGISTERS,-(SP) *)
     MOVEMINC = 046337B; (* MOVEM.L (SP)+,REGISTERS *)
     MVEMSP   = 027400B; (* MOVE.L  EA,-(SP) *)
     MVESPP   = 020037B; (* MOVE.L  (SP)+,EA *)

     (* OP0: INSTRUCTIONS WITHOUT OPERAND. *)
     NOP  = 047161B; RSET = 047160B; RTE  = 047163B;
     RTR  = 047167B; RTS  = 047165B; TRAPV= 047166B;

     (* OP1: INSTRUCTIONS WITH ONE OPERAND. *)
     (* BRANCHES : WITH A DISPLACEMENT. *)
     BCC  = 062000B; BHIS = 062000B; (*  SYNONYM  *)
     BCS  = 062400B; BLO  = 062400B; (*  SYNONYM  *)
     BEQ  = 063400B; BGE  = 066000B; BGT  = 067000B;
     BHI  = 061000B; BLE  = 067400B;
     BLS  = 061400B; BLOS = 061400B; (*  SYNONYM  *)
     BLT  = 066400B; BMI  = 065400B; BNE  = 063000B;
     BPL  = 065000B; BRA  = 060000B; BSR  = 060400B;
     BVC  = 064000B; BVS  = 064400B;

     (* Scc : Set according to condition *)
     SMI  = 05BC0H ;

     (* OPERAND IS A SPECIFIC REGISTER. *)
     SWAP = 044100B;
     EXTW = 044200B; (* EXT.W  BYTE TO WORD *)
     EXTL = 044300B; (* EXT.L  WORD TO LONG *)

     (* OPERAND IS AN EFFECTIVE ADDRESS. *)
     CLR  = 041000B; (* CAUTION: CLR DOES A READ/WRITE CYCLE. *)
     NEG  = 042000B; NEGX = 040000B;
     COM  = 043000B; (* SYNOMYM FOR NOT *)
     JMP  = 047300B; JSR  = 047200B;
     PEA  = 044100B; TAS  = 045300B;
     TST1 = 045000B; (* TST: COLLISION WITH FILE 'TST' IN BASE *)
     INC1 = 051000B; (* ADDQ #1,EA *)
     DEC1 = 051400B; (* SUBQ #1,EA *)

     (* OPERAND IS AN IMMEDIATE VALUE. *)
     STOP = 047162B; (* STOP #XXXX TO SR (NOT XC68000) *)
     TRAP = 047100B; (* TRAP #VECTOR *)

     (* OP2: INSTRUCTIONS WITH 2 OPERANDS. *)
     (* A REGISTER AND AN EFFECTIVE ADDRESS. *)
     ADD  = 150000B; ADDX = 150400B;
     SUB  = 110000B; SUBX = 110400B;
     CMP  = 130000B; CMPM = 130410B;
     ANDL = 140000B; (* LOGICAL AND: SYNONYM FOR AND *)
     ORL  = 100000B; (* INCLUSIVE OR *)
     EORL = 130600B; (* EXCLUSIVE OR *)
     CHK  = 040600B; LEA  = 040700B;
     DIVS = 100700B; DIVU = 100300B;
     MULS = 140700B; MULU = 140300B;
     ADDAL= 150700B; (* ADDA.L EA,AN *)
     CMPAL= 130700B; (* CMPA.L EA,AN *)
     SUBAL= 110700B; (* SUBA.L EA,AN *)
     EXGL = 140500B; (* EXG.L  DX,DY *)

     (* IMMEDIATE DATA WITHIN OP. AND AN EFFECTIVE ADDRESS. *)
     ADDQ = 050000B; SUBQ = 050400B;

     (* SHIFT REGISTER BY COUNT *)
     ASL  = 160400B; ASR  = 160000B; LSL  = 160410B;
     LSR  = 160010B; ROL  = 160430B; ROR  = 160030B;
     ROXL = 160420B; ROXR = 160020B;

     (* IMMEDIATE DATA WITHIN EXTENSION AND AN EFFECTIVE ADDRESS. *)
     ADDI = 003000B; ANDI = 001000B; CMPI = 006000B;
     EORI = 005000B; ORI  = 000000B; SUBI = 002000B;

     (* BRANCHES : A REGISTER AND A DISPLACEMENT (NOT XC68000). *)
     DBCC = 052310B; DBCS = 052710B; DBEQ = 053710B;
     DBGE = 056310B; DBGT = 057310B; DBHI = 051310B;
     DBLE = 057710B; DBLS = 051710B; DBLT = 056710B;
     DBMI = 055710B; DBNE = 053310B; DBPL = 055310B;
     DBRA = 050710B; (* SYNONYM FOR DBF *)
     DBT  = 050310B; DBVC = 054310B; DBVS = 054710B;

     (* BIT MANIPULATION : DEFAULT DYNAMIC, POSTFIX 'S' FOR STATIC: *)
     BTST = 000400B; BTSTS = 004000B;
     BCHG = 000500B; BCHGS = 004100B;
     BCLR = 000600B; BCLRS = 004200B;
     BSET = 000700B; BSETS = 004300B;

     (* MOVE GROUP *)
     MOVEB     = 010000B; (* GROUP 1 *)
     MOVEW     = 030000B; (* GROUP 3 *)
     MOVEL     = 020000B; (* GROUP 2 *)
     MOVEAW    = 030100B; (* MOVEA.W EA,AN *)
     MOVEAL    = 020100B; (* MOVEA.L EA,AN *)
     MOVETOCCR = 042300B; (* MOVE EA TO CCR, SIZE IS WORD *)
     MOVETOSR  = 043300B; (* MOVE EA TO SR,  SIZE IS WORD *)
     MOVEFRSR  = 040300B; (* MOVE SR TO EA,  SIZE IS WORD *)
     MOVETOUSP = 047140B; (* MOVE AN TO USP, SIZE IS LONG *)
     MOVEFRUSP = 047150B; (* MOVE USP TO AN, SIZE IS LONG *)
     MOVEQ     = 070000B; (* MOVE $XX TO DN, SIZE IS LONG *)


     (* CONCERNING THE STATUS REGISTER *)
     TBIT      = 100000B; (* TRACE BIT *)
     SBIT      = 020000B; (* SUPERVISOR BIT *)
     NBIT      = 10B;     (* NEGATIVE BIT *)
     ZBIT      = 4;       (* ZERO BIT *)
     VBIT      = 2;       (* OVERFLOW BIT *)
     CBIT      = 1;       (* ZERO BIT *)
     CLRALLI   = 174377B; (* ENABLE (AND) ALL INTERRUPTS *)
     SETALLI   = 3400B;   (* DISABLE (OR) ALL INTERRUPTS *)


     (* EXCEPTION VECTOR NUMBERS : MULTIPLY NUMBER *)
     (* BY 4 TO GET THE ABSOLUTE ADDRESS.          *)

     INITSSP   = 0;       INITPC   = 1;
     BUSERR    = 2;       ADRERR   = 3;
     ILLINS    = 4;       ZERDIV   = 5;
     CHKINS    = 6;       TRAPVINS = 7;
     PRIVVIO   = 8;       TRACE    = 9;
     EM1010    = 10;      EM1111   = 11;



     (* CALL RUNTIME SYSTEM PROCEDURE NUMBERS :                  *)
     (* THESE NUMBERS MUST CORRESPOND WITH THE PROCEDURE NUMBERS *)
     (* ASSOCIATED WITH A SPECIFIC PROCEDURE IN THE DEFINITION   *)
     (* MODULE 'SYSTEMX'.                                        *)

     BODYOFSYSTEMX       = 0; (* RESERVED FOR BODY OF 'SYSTEMX'  *)
     CASECODE            = 1; (* SYSTEMX.CASEX FOR CASE-STAT.    *)
     HALTCODE            = 2; (* SYSTEMX.HALTX FOR COMPILER      *)
     STACKTESTCODE       = 3; (* SYSTEMX.STACKTEST FOR S+ OPTION *)
     NEWPROCESSCODE      = 4; (* SYSTEMX.NEWPROCESS              *)
     TRANSFERCODE        = 5; (* SYSTEMX.TRANSFER                *)
     IOTRANSFERCODE      = 6; (* SYSTEMX.IOTRANSFER              *)
     SYSCALLCODE         = 7; (* SYSTEMX.SYSCALL                 *)
     MULU32CODE          = 8; (* SYSTEMX.MULU32 = UNSIGNED MUL   *)
     DIVU32CODE          = 9; (* SYSTEMX.DIVU32 = UNSIGNED DIV   *)
     MULS32CODE          = 10;(* SYSTEMX.MULS32 = SIGNED MUL     *)
     DIVS32CODE          = 11;(* SYSTEMX.DIVS32 = SIGNED DIV     *)
     FADDCODE            = 12;(* SYSTEMX.FADD   = FLOATING ADD   *)
     FSUBCODE            = 13;(* SYSTEMX.FSUB   = FLOATING SUB   *)
     FMULCODE            = 14;(* SYSTEMX.FMUL   = FLOATING MUL   *)
     FDIVCODE            = 15;(* SYSTEMX.FDIV   = FLOATING DIV   *)
     FCMPCODE            = 16;(* SYSTEMX.FDIV   = FLOATING CMP   *)
     FTSTCODE            = 17;(* SYSTEMX.FTST   = FLOATING TST   *)
     FLOATCODE           = 18;(* SYSTEMX.FLOATX = FLOAT XFERFUNC.*)
     TRUNCCODE           = 19;(* SYSTEMX.TRUNCX = TRUNC XFERFUNC.*)


     (* TRAP NUMBERS USED WITHIN THE  MODULE 'SYSTEMX' :   *)

     MODTRAP   = 7;    (* RESERVED FOR SYSTEMX-SERVICES-CALLS    *) (* $$TDI *)
     TFRTRAP   = 6;    (* RESERVED FOR TRANSFER                  *) (* $$TDI *)
     IOTTRAP   = 5;    (* RESERVED FOR IOTRANSFER                *) (* $$TDI *)


     (* MODTRAP SERVICES : REQUEST SERVICE NUMBER, VALUE IN      *)
     (*                    (LONG) REGISTER (D0).                 *)

     TFRREQ  = 0;   (* REQUEST TRANSFER   (IF TFRTRAP = MODTRAP) *)
     IOTREQ  = 1;   (* REQUEST IOTRANSFER (IF IOTTRAP = MODTRAP) *)
     CHGPRIO = 2;   (* REQUEST FOR CHANGE TO NEW PRIORITY        *)
     STOPRIO = 3;   (* REQUEST FOR RESTORE PREVIOUS PRIORITY     *)
     LISREQ  = 4;   (* REQUEST FOR LISTEN (ENABLE INTERRUPTS)    *)
     SYSREQ  = 5;   (* REQUEST FOR SYSRESET                      *)
     HALTREQ = 6;   (* REQUEST FOR NORMAL PROGRAM HALT           *)
     STARTUS = 7;   (* REQUEST FOR START USER PROGRAM            *)



     (* LEFT SHIFT CONSTANTS : MULTIPLY BY POWER OF 2 *)
     LS3  =  10B;  LS4  =  20B;  LS5  =  40B;   LS6  =  100B;
     LS7  = 200B;  LS8  = 400B;  LS9  =  1000B; LS10 =  2000B;
     LS11 = 4000B; LS12 = 10000B;


     (* SPACED USED ON STACK FOR RETURN ADDRESS AND *)
     (* DYNAMIC LINK AT ENTRY OF A PROCEDURE :      *)
     PROCMARKSPACE = 10B;

    (* GEM Constants *)

    GEMFUNC = 200 ;
    GEMTRAP = 04E42H ;            (* GEM trap is TRAP #2 func 200 *)
    TermOpcode = 4CH ;
    GEMDOSTRAP = 04E41H ;
    PUSHLONGD0 = 02F00H ;
    PUSHWORDD0 = 03F00H ;

TYPE

     (* EXCEPTION VECTORS IN THE FIRST 1000B BYTES. *)
     EXCEPTIONS    = ARRAY [0..255] OF PROC;

VAR

  StackSize  : POINTER TO RECORD
                            JMP : CARDINAL ;
                            Addr: ADDRESS ;
                            Size: LONGCARD ;
                          END ; 
(* record to patch for fact that GEM linker puts a jmp.l at start of code *)


  (*   GENERAL COMMENTS TO PROCEDURES WITH A     *)
  (*  (*$P-*) OPTION IN FRONT OF THE PROCEDURE   *)
  (*             DECLARATION :                   *)
  (*  -----------------------------------------  *)
  (*                                             *)
  (* - ABSOLUTELY NO CODE IS GENERATED FOR THESE *)
  (*   PROCEDURES ON ENTRY AND ON EXIT :         *)
  (*   E.G. - NO STACKTESTS                      *)
  (*        - NO LINK-INSTRUCTION WHICH SAVES    *)
  (*          THE CURRENT VALUE OF 'MP' ONTO     *)
  (*          THE STACK AND RESERVES SPACE FOR   *)
  (*          LOCAL DATA. LOCAL DATA MUST BE     *)
  (*          ALLOCATED AND RESERVED EXPLICITELY *)
  (*          WITH A 'CODE(LINK,XXX)' STATEMENT, *)
  (*          WHERE XXX IS THE NUMBER OF BYTES   *)
  (*          NEEDED FOR LOCAL DATA.             *)
  (*        - NO SAVE OF A PRIORITY :            *)
  (*          A (*$P-*) PROCEDURE CANNOT HAVE A  *)
  (*          PRIORITY.                          *)
  (*        - NO SAVE OF A STATIC LINK : THIS    *)
  (*          MEANS THAT A (*$P-*) PROCEDURE     *)
  (*          CANNOT BE LOCAL TO ANOTHER         *)
  (*          PROCEDURE.                         *)
  (*        - A (*$P-*) PROCEDURE MUST NOT BE A  *)
  (*          FUNCTION AND THUS CANNOT CONTAIN A *)
  (*          RETURN-STATEMEMT.                  *)
  (*        - A (*$P-*) PROCEDURE MUST NOT HAVE  *)
  (*          PARAMETERS IN THE PROCEDURE HEADER *)
  (*          BECAUSE THE OFFSETS ALLOCATED BY   *)
  (*          THE COMPILER FOR THESE PARAMETERS  *)
  (*          WOULD NOT MATCH THE EFFECTIVE      *)
  (*          OFFSETS : FOR A CALL BY 'JSR', THE *)
  (*          'MP' WAS NOT SAVED ONTO THE STACK, *)
  (*          WHEREAS FOR A CALL BY 'TRAP', THE  *)
  (*          'MP' WAS NOT SAVED, BUT THE WORD-  *)
  (*          SIZED STATUS-REGISTER.             *)
  (*                                             *)
  (* - FOR A (*$P-*) PROCEDURE CALLED BY 'TRAP'  *)
  (*   RETURN  WITH A 'CODE(RTE)' STATEMENT.     *)
  (*                                             *)
  (* - FOR A (*$P-*) PROCEDURE CALLED BY 'JSR'   *)
  (*   RETURN WITH A 'CODE(RTS)' STATEMENT.      *)
  (*                                             *)
  (* - SHOULD A (*$P-*) PROCEDURE CONTAIN 'WITH' *)
  (*   STATEMENTS, THEN THE MARKER 'MP' MUST BE  *)
  (*   SET AT THE ENTRY OF THE PROCEDURE AND     *)
  (*   RESET BEFORE EXIT, BECAUSE WITH-POINTERS  *)
  (*   ARE ACCESSED VIA THE MARKER 'MP'. THIS IS *)
  (*   DONE WITH THE FOLLOWING STATEMENTS :      *)
  (*                                             *)
  (*   (*$P- THIS IS A P- PROCEDURE *)           *)
  (*   PROCEDURE PPP;                            *)
  (*   BEGIN                                     *)
  (*      CODE(LINK,XXX); XXX = LOCAL DATA BYTES *)
  (*                      IF ANY, ELSE XXX = 0.  *)
  (*        ....                                 *)
  (*        ....                                 *)
  (*        ....                                 *)
  (*                                             *)
  (*      CODE(UNLK);                            *)
  (*      CODE(RTS) OR CODE(RTE);                *)
  (*   END PPP;                                  *)
  (*                                             *)
  (* - A MODULE BODY MUST NEVER HAVE A (*$P-*)   *)
  (*   IN FRONT OF IT'S BEGIN.                   *)
  (*                                             *)


PROCEDURE CopyRights ;

  PROCEDURE Dummy(VAR s: ARRAY OF CHAR);
  END Dummy;

BEGIN
  Dummy("ACCX") ;
(* Dummy routines to include copyright and other notices in GEMX.lnk *)
  Dummy("Modula-2/ST (c) Copyright Modula 2 Software Ltd. 1985,1986,1987. ") ;
  Dummy("(c) Copyright TDI Software Inc. 1985,1986,1987. ");
END CopyRights ;



  (* SUPPORTING THE COMPILER *)
  (* ----------------------- *)

  (*$P- SUPPRESS ENTRY/EXIT CODE GENERATED BY COMPILER *)
  PROCEDURE CASEX;
    (* CASE-STATEMENT PROCESSOR CALLED BY :      *)
    (*                                           *)
    (*      MOVE.L CASE-INDEX,D0 ( BITS [0..31]) *)
    (*      JSR    SYSTEMX.CASEX                 *)
    (* REF: VALUE OF LOW         ( LONGWORD )    *)
    (*      VALUE OF (HIGH-LOW)  ( LONGWORD )    *)
    (*      OFFSET OF CASE-TABLE ( LONGWORD )    *)
    (*             RELATIVE TO REF.              *)
    (*                                           *)
    (* NOTE : NO RETURN FROM THIS PROCEDURE.     *)
    (* ----   POP RETURN ADDRESS FROM STACK.     *)
    (*        THE RETURN ADDRESS ON STACK        *)
    (*        POINTS TO THE REFERENCE LOCATION   *)
    (*        'REF'.                             *)
    (*        THE REGISTERS A0 AND D0 ARE FREE   *)
    (*        FOR USE AT ANY TIME, BECAUSE THE   *)
    (*        COMPILER DOES NOT RESERVE THESE 2  *)
    (*        REGISTERS. ALL OTHER POOL REGISTERS*)
    (*        NEEDED FOR CALCULATIONS MUST BE    *)
    (*        SAVED AND RESTORED BY CASEX.       *)
    (*        (ACTUALLY ONLY A0 AND D0 USED).    *)
    (*                                           *)
  BEGIN
    CODE(MOVEAL + AINC + SP);               (* MOVEA.L (SP)+,A0 *)
    CODE(SUB + LONGW*LS6 + AIDR);            (* SUB.L   (A0),D0  *)
    CODE(CMP + LONGW*LS6 + AOFF, 4);         (* CMP.L   4(A0),D0 *)
    (* IF CARDINAL(VALUE - LOW) > CARDINAL(HIGH - LOW) THEN  *)
    (* CASE-VALUE IS OUT OF TABLE RANGE :                    *)
    CODE(BHI + 12);                         (* GOT TO ELSE-CODE *)
    (* A0 = 'REF'.  TABLE-INDEX = 2*(VALUE - LOW).           *)
    (* 'REF' + OFFSET OF CASE-TABLE = FWA CASE-TABLE.        *)
    (* FWA CASE-TABLE + TABLE-INDEX = ADDRESS OF TABLE-ENTRY.*)
    (* ADD TABLE-ENTRY-WORD TO 'REF' TO GET JUMP-ADDRESS.    *)
    CODE(ASL + 1*LS9 + LONGW*LS6);           (* ASL.L   #1,D0    *)
    CODE(ADD + LONGW*LS6 + AOFF, 8);         (* ADD.L   8(A0),D0 *)
    CODE(ADD + 3*LS6 + AIDX, LS11);         (* ADDA.W (A0,D0.L),A0*)
    CODE(JMP + AIDR);                       (* JMP     (A0)     *)
    (* ELSE-CODE : A PC-RELATIVE-JUMP TO THE ELSE-CODE IS    *)
    (* FOUND IN THE LONG-WORD IN FRONT OF THE CASE-TABLE.    *)
    CODE(ADD + 7*LS6 + AOFF, 8);            (* ADDA.L  8(A0),A0 *)
    CODE(SUBQ + 4*LS9 + LONGW*LS6 + ADIR);   (* SUBQ.L  #4,A0    *)
    CODE(JMP + AIDR);                       (* JMP     (A0)     *)
  END CASEX;


  (*$P- SUPPRESS ENTRY/EXIT CODE GENERATED BY COMPILER *)
  PROCEDURE HALTX;
    (* THIS PROCEDURE IS CALLED BY THE COMPILER  *)
    (* FOR PROGRAM-HALT OR FOR SOME COMPILER-    *)
    (* GENERATED ERROR-HALTS.                    *)
    (*                                           *)
    (* THE CALLING SEQUENCE IS :                 *)
    (*                                           *)
    (*    MOVEQ  HALT-INDEX,D0                   *)
    (*    JSR    SYSTEMX.HALTX                   *)
    (*                                           *)
    (* ALL POOL REGISTERS FREE FOR HALTX.        *)
    (*                                           *)
  BEGIN
    CODE(RTS);                 (* RTS                       *)
  END HALTX;



  (*$P- SUPPRESS ENTRY/EXIT CODE GENERATED BY COMPILER *)
  PROCEDURE STACKTEST;
    (* THIS PROCEDURE IS CALLED ON EVERY ENTRY   *)
    (* TO A MODULE-BODY OR PROCEDURE IF THE      *)
    (* S-OPTION IS ON (*$S+*) AT COMPILATION     *)
    (* TIME OF THE PROGRAM.                      *)
    (*                                           *)
    (* THE CALLING SEQUENCE IS :                 *)
    (*                                           *)
    (*    MOVE.L #NRBYTES,D0                     *)
    (*    JSR    SYSTEMX.STACKTEST               *)
    (*                                           *)
    (*    ALL POOL REGISTERS FREE FOR STACKTEST. *)
    (*    NRBYTES IS THE MINIMUM NUMBER OF BYTES *)
    (*    NEEDED ON STACK.                       *)
    (*                                           *)
  CONST RESERVE = 200B;  (* For saving interrupt context and ErrorRoutine *)
  BEGIN
    CODE(RTS);                             (* NORMAL RETURN    *)
  END STACKTEST;



  (* PSEUDO-MODULE SYSTEM *)
  (* -------------------- *)

  (*$P- SUPPRESS ENTRY/EXIT CODE GENERATED BY COMPILER *)
  PROCEDURE TERMINATE;
    (* SIGNAL PROCESS WAS TERMINATED. *)
  BEGIN
    CODE(RTS) ;
  END TERMINATE;

  PROCEDURE NEWPROCESS (PROCESSCODE : PROC;
                        FWAWSP : ADDRESS; LENGTHWSP : LONGCARD;
                        VAR PROCESSDESCRIPTOR : PROCESS;
                        INITIALPRIO : LONGCARD);
    (* NEWPROCESS (EXPORTED FROM PSEUDO-MODULE SYSTEM) :   *)
    (* PROCEDURE NEWPROCESS(PROCESSCODE : PROC;            *)
    (*                FWAWSP : ADDRESS; LENGTH : CARDINAL; *)
    (*                VAR PROCESSDESCRIPTOR : PROCESS;     *)
    (*                INITIALPRIO : CARDINAL);             *)
    (*                                                     *)
    (*    SAVEREGS USED BY THE COMPILER                    *)
    (*    PUSH   ADRESS OF PROCEDURE CODE   (1 LONGWORD)   *)
    (*    PUSH   VALUE(FWAWSP)              (1 LONGWORD)   *)
    (*    PUSH   VALUE(LENGTH)              (1 LONGWORD)   *)
    (*    PUSH   ADR(PROCESSDESCRIPTOR)     (1 LONGWORD)   *)
    (*    PUSH   VALUE(INITIALPRIO)         (1 LONGWORD)   *)
    (*    JSR    SYSTEMX.NEWPROCESS                        *)
    (*    POP    THE 5 PARAMETERS                          *)
    (*    RESTOREREGS                                      *)
    (*                                                     *)
    (*                                                     *)
    (* NOTE : CALL AS FOR A NORMAL MODULA-2 PROCEDURE.     *)
    (* ----   ALL POOL REGISTERS FREE. NORMAL RETURN.      *)
    (*                                                     *)
    (* NOTE : ALTHOUGH THE 'LENGTH' AND THE 'INITIALPRIO'  *)
    (* ----   PARAMETERS MUST BE DECLARED OF TYPE CARDINAL *)
    (*        IN A MODULA-2 SOURCE PROGRAM, THIS SPECIAL   *)
    (*        IMPLEMENTATION DEFINES THEM TO BE OF TYPE    *)
    (*        LONGCARD. THIS IS THE ONLY WAY TO HANDLE 32  *)
    (*        BIT LONG-CARDINAL VALUES CORRECTLY. NOTE     *)
    (*        THAT THE COMPILER GENERATED CODE PUSHES ALL  *)
    (*        PARAMETERS AS LONGWORDS (SEE PROCEDURE HEADER*)
    (*        DECLARATION OF NEWPROCESS).                  *)
    (*                                                     *)
  BEGIN
  END NEWPROCESS;

  (*$P- SUPPRESS ENTRY/EXIT CODE GENERATED BY COMPILER *)
  PROCEDURE TRANSFER;
    (* TRANSFER  (EXPORTED FROM PSEUDO-MODULE SYSTEM) :    *)
    (* PROCEDURE TRANSFER(VAR FROMPROC, TOPROC : PROCESS); *)
    (*                                                     *)
    (*    SAVEREGS USED BY COMPILER                        *)
    (*    MOVEA.L ADR(FROMPROC),A0                         *)
    (*    MOVEA.L ADR(TOPROC),A1                           *)
    (*    JSR     SYSTEMX.TRANSFER                         *)
    (*    RESTOREREGS                                      *)
    (*                                                     *)
   BEGIN
     CODE(RTS);
   END TRANSFER;

  (*$P- SUPPRESS ENTRY/EXIT CODE GENERATED BY COMPILER *)
  PROCEDURE TRANSFERT;
    (*   IMPLEMENTED FOR MODULES RUNNING IN USER-MODE      *)
    (*   TRANSFERT IS CALLED BY TRAP #TFRTRAP.             *)
    (*   ALL POOL REGISTERS FREE.                          *)
    (*   RETURN WITH 'RTE'.                                *)
  CONST MA6 = 6400B;  (* -(A6)  *)
        A6P = 36B;    (*  (A6)+ *)
        SSP = 7;      (* SSP = SP = A7 *)
  BEGIN
    CODE(RTE);                              (* RTE                   *)
  END TRANSFERT;

  (*$P- SUPPRESS ENTRY/EXIT CODE GENERATED BY COMPILER *)
  PROCEDURE IOTRANSFER;                                        (* +++++++++ *)
    (* IOTRANSFER (EXPORTED FROM PSEUDO-MODULE SYSTEM) :   *)
    (* PROCEDURE IOTRANSFER(VAR FROMPROC, TOPROC: PROCESS; *)
    (*                      DEVICE : ADDRESS);             *)
    (*                                                     *)
    (*    SAVEREGS USED BY COMPILER                        *)
    (*    MOVEA.L  ADR(FROMPROC),A0                        *)
    (*    MOVEA.L  ADR(TOPROC),A1                          *)
    (*    MOVEA.L  VECTORADR(DEVICE),A2                    *)
    (*    JSR      SYSTEMX.IOTRANSFER                      *)
    (*    RESTOREREGS                                      *)
    (*                                                     *)
  BEGIN
    CODE(RTS);
  END IOTRANSFER;

  (*$P- SUPPRESS ENTRY/EXIT CODE GENERATED BY COMPILER *)
  PROCEDURE IOTRANSFERT;
    (*  IMPLEMENTED FOR MODULES RUNNING IN USER-MODE       *)
    (*  IOTRANSFER IS CALLED BY TRAP #IOTTRAP.             *)
    (*  ALL POOL REGISTERS FREE.                           *)
    (*  RETURN WITH 'RTE'.                                 *)
    (*                                                     *)
    (* AUTHOR : R. FISCHER, ELECTRONIC INSTITUTE ETH       *)
    (* ------   ETH ZURICH, SEPTEMBER 1982.                *)
    (*                                                     *)
  CONST MA6 = 6400B;  (* -(A6)  *)
        A6P = 36B;    (*  (A6)+ *)
        SSP = 7;      (* SSP = SP = A7 *)
        IOFFSET = 2AH;
  BEGIN
    CODE(RTE);                              (* RTE                   *)
  END IOTRANSFERT;

  (*$P- SUPPRESS ENTRY/EXIT CODE GENERATED BY COMPILER *)
  PROCEDURE MODCALL;
    (* MODCALL : REQUEST MODTRAP-SERVICE :                 *)
    (* -------   IMPLEMENTS FUNCTIONS WHICH USE PRIVILEGED *)
    (*           INSTRUCTIONS. RUNS IN SUPERVISOR-MODE.    *)
    (*                                                     *)
    (*                                                     *)
    (*    SAVEREGS USED BY COMPILER                        *)
    (*    MOVEQ   #SERVICE,D0       (BITS 0..7 USED ONLY)  *)
    (*    MOVE    (ADDITIONAL PARAMETERS),D1               *)
    (*    TRAP    #MODTRAP                                 *)
    (*    RESTOREREGS                                      *)
    (*                                                     *)
    (* NOTE : MODCALL CALLED BY TRAP #MODTRAP.             *)
    (* ----   ALL POOL REGISTERS FREE.                     *)
    (*        RETURN WITH 'RTE'.                           *)
    (* NOTE : TFRREQ AND IOTREQ CURRENTLY NOT IMPLEMENTED, *)
    (* ----   TRANSFER/IOTRANSFER DO HAVE THEIR OWN TRAPS. *)

  BEGIN (* MODCALL *)
    CODE(RTE);                                 (* START USER       *)
  END MODCALL;


  (*$P- SUPPRESS ENTRY/EXIT CODE GENERATED BY COMPILER *)
  PROCEDURE SYSCALL;
    (* SYSCALL (EXPORTED FROM PSEUDO-MODULE SYSTEM) :      *)
    (* PROCEDURE SYSCALL(SERVICE : CARDINAL;               *)
    (*                   FWAPARAMETERBLOCK : ADDRESS;      *)
    (*                   VAR REPLY : CARDINAL);            *)
    (*                                                     *)
    (*                                                     *)
    (* THE CALLING SEQUENCE IF CALLED BY MODULA2-PROGRAM : *)
    (*                                                     *)
    (*    SAVEREGS USED BY THE COMPILER                    *)
    (*    MOVE.L   VALUE(SERVICE),D0                       *)
    (*    MOVEA.L  VALUE(FWA),A0                           *)
    (*    JSR      SYSTEMX.SYSCALL                         *)
    (*    MOVE     D0,ADR(REPLY)                           *)
    (*    RESTOREREGS                                      *)
    (*                                                     *)
    (*                                                     *)
    (* SPECIAL SYSTEM REQUESTS :                           *)
    (* -----------------------                             *)
    (* SERVICES 0 .. 9 RESERVED FOR SPECIAL REQUESTS USED  *)
    (* BY THE COMPILER ITSELF.                             *)
    (* REGISTERS A0 AND D0 CAN BE USED FREELY AT ANY TIME. *)
    (*                                                     *)
    (* THE CALLING SEQUENCE FOR SPECIAL SYSTEM REQUESTS :  *)
    (*                                                     *)
    (*    MOVE.L  SERVICENUMBER,D0                         *)
    (*    MOVEA.L OPTIONAL-PARAMETER,A0                    *)
    (*    JSR     SYSTEMX.SYSCALL                          *)
    (*                                                     *)
    (* WHERE :                                             *)
    (*    SERVICE #0 = REQUEST FOR CHANGE TO NEW PRIORITY. *)
    (*    SERVICE #1 = REQUEST FOR CHANGE STATUS REGISTER. *)
    (*    SERVICE #2 = REQUEST FOR LISTEN (ENABLE IR'S).   *)
    (*    SERVICE #3 = REQUEST FOR SYSRESET.               *)
    (*    SERVICE #4 .. #9 FOR FUTURE EXTENSION.           *)
    (*                                                     *)
  BEGIN (* SYSCALL *)
     CODE(RTS);
  END SYSCALL;


  (* 32-BIT ARITHMETIC PROCEDURES :                        *)
  (* ----------------------------                          *)
  (*                                                       *)
  (* USED FOR                                              *)
  (*                                                       *)
  (*    -  32-BIT SIGNED/UNSIGNED (LONG-) ARITHMETIC       *)
  (*    -  32-BIT IEEE-FLOATING POINT ARITHMETIC (REAL)    *)
  (*                                                       *)
  (*                                                       *)
  (* NOTES FOR THE 32-BIT ARITHMETIC PROCEDURES :          *)
  (*                                                       *)
  (*    -  ALL PROCEDURES CALLED BY JSR.                   *)
  (*       RETURN WITH RTS BY COMPILER GENERATED CODE.     *)
  (*    -  THE PARAMETERS ARE ON THE STACK AND ARE         *)
  (*       ACCESSED VIA N(MP) ADDRESSING MODES, WHERE N    *)
  (*       IS THE POSITIVE DISPLACEMENT OF THE PARAMETER.  *)
  (*    -  PARAMETERS ARE POPPED FROM STACK BY COMPILER    *)
  (*       GENERATED CODE.                                 *)
  (*    -  FOR THE 32-BIT SIGNED/UNSIGNED LONG ARITHMETIC, *)
  (*       THE RESULT(S) ARE DEPOSITED IN THE 2 LONGWORDS  *)
  (*       OF THE PARAMETER AREA. FOR THE MULTIPLICATION,  *)
  (*       THE RESULT IS A 64-BIT PRODUCT. FOR DIVISION,   *)
  (*       THE REMAINDER IS AT LOCATION (SP) AND THE       *)
  (*       QUOTIENT AT LOCATION 4(SP).                     *)
  (*    -  FOR THE 32-BIT IEEE-FLOATING POINT ARITHMETIC,  *)
  (*       THE RESULT IS EXPECTED TO BE IN THE LONGWORD    *)
  (*       OF THE 1. PARAMETER ON THE STACK, EXCEPT FOR    *)
  (*       THE PROCEDURES FCMP AND FTST. FCMP AND FTST     *)
  (*       MUST SET THE CONDITION-CODE-REGISTER FLAGS      *)
  (*       ACCORDING TO THE RESULT OF THE COMPARISION.     *)
  (*    -  ALL POOL-REGISTERS USED FOR THE INTERNAL        *)
  (*       COMPUTATION OF A 32-BIT ARITHMETIC PROCEDURE    *)
  (*       MUST BE SAVED ON ENTRY AND RESTORED ON EXIT     *)
  (*       OF A SPECIFIC PROCEDURE.                        *)
  (*    -  IT IS ASSUMED THAT THE CODING CANNOT BE DONE    *)
  (*       WITH MODULA-2, BUT WITH THE USE OF THE          *)
  (*       NON-STANDARD PROCEDURE 'CODE', EXPORTED FROM    *)
  (*       MODULE SYSTEM.                                  *)
  (*    -  AS LONG AS PARAMETERS ARE REFERENCED WITH N(MP) *)
  (*       ADDRESSING MODE, DO NEVER SELECT A (*$P-*)      *)
  (*       OPTION IN FRONT OF A PROCEDURE HEADER.          *)
  (*    -  AFTER A MOVEM-INSTRUCTION, THE MODULA-2 'WITH'- *)
  (*       STATEMENT MUST NOT BE USED BECAUSE THE STACK    *)
  (*       USED FOR THE SAVED REGISTERS IS NOT COMPATIBLE  *)
  (*       WITH THE BOOKKEEPING DONE BY THE COMPILER.      *)
  (*                                                       *)


    (* 32-BIT UNSIGNED ARITHMETIC FOR A LONG-CARDINAL TYPE *)

  PROCEDURE MULU32     (MULTIPLICAN, MULTIPLIER : LONGCARD);
    (* SEE MC68000 COURSE NOTES : PAGE 117.   *)
    (* (MOTOROLA TECHNICAL TRAINING).         *)
  CONST RESULT = PROCMARKSPACE + 4; (* OFFSET OF MULTIPLICAN *)
        PARAM2 = PROCMARKSPACE;     (* OFFSET OF MULTIPLIER  *)
  BEGIN
    CODE(MOVEMDEC, {10,11,12,13,14} );          (* MOVEM D5-D1,-(SP) *)
    (* COPY THE 2 FACTORS INTO REGISTERS D1 AND D2 : *)
    CODE(MOVEL + D1*LS9 + AOFF + MP, PARAM2);   (* MOVE.L RESULT,D1  *)
    CODE(MOVEL + D2*LS9 + AOFF + MP, RESULT);   (* MOVE.L PARAM2,D2  *)
    CODE(02601H,02801H,02A02H,04844H,04845H);
    CODE(0C2C2H,0C4C4H,0C6C5H,0C8C5H,04841H);
    CODE(0D242H,04285H,0D985H,0D243H,0D985H);
    CODE(04841H,04242H,04243H,04842H,04843H);
    CODE(0D483H,0D484H);
    (* THE RESULT IS A 64-BIT PRODUCT AS FOLLOWS :   *)
    (* THE LOWER 32 BITS ARE IN LOCATION 'RESULT',   *)
    (* WHEREAS THE UPPER 32 BITS ARE IN 'PARAM2'.    *)
    CODE(MOVEL + MP*LS9 + AOFF*LS3 + D1,RESULT);(* MOVE.L D1,RESULT  *)
    CODE(MOVEL + MP*LS9 + AOFF*LS3 + D2,PARAM2);(* MOVE.L D2,PARAM2  *)
    CODE(MOVEMINC, {1,2,3,4,5} );               (* MOVEM (SP)+,D1-D5 *)
  END MULU32;

  PROCEDURE DIVU32     (DIVIDEND, DIVISOR       : LONGCARD);
    (* SEE MC68000 COURSE NOTES : PAGE 121.   *)
    (* (MOTOROLA TECHNICAL TRAINING).         *)
  CONST RESULT = PROCMARKSPACE + 4; (* OFFSET OF DIVIDEND/QUOTIENT *)
        PARAM2 = PROCMARKSPACE;     (* OFFSET OF DIVISOR/REMAINDER  *)
  BEGIN
    (* DEVELOPED ON A SMAKY 6/SMAKY 8 SYSTEM *)
    (* KEYED IN FROM THE HEX LISTING.        *)
    (* P. FINK, IFI ETH ZURICH, 11.7. 1983.  *)
    CODE(MOVEMDEC, {11..14} );                (* MOVEM D4-D1,-(SP)  *)
    CODE(MOVEL + D1*LS9 + AOFF + MP, RESULT); (* MOVE.L DIVIDEND,D1 *)
    CODE(MOVEL + D2*LS9 + AOFF + MP, PARAM2); (* MOVE.L DIVISOR,D2  *)
    CODE (0B4BCH, 0000H,0FFFFH, 621EH);
    CODE ( 4243H, 82C2H, 680EH);
    CODE ( 3801H, 4241H, 4841H, 82C2H, 3601H, 3204H, 82C2H);
    CODE ( 4843H, 3601H, 4241H, 4841H, 601EH);
    CODE ( 4283H, 3601H, 4843H, 4241H, 4841H, 383CH, 000FH);
    CODE (0E38BH,0E391H,0B282H, 6504H, 9282H, 5243H, 51CCH,0FFF2H);
    (* D1 CONTAINS THE REMAINDER, D3 CONTAINS THE QUOTIENT. *)
    CODE(MOVEL + MP*LS9 + AOFF*LS3 + D3,RESULT);(* MOVE.L D3,RESULT *)
    CODE(MOVEL + MP*LS9 + AOFF*LS3 + D1,PARAM2);(* MOVE.L D1,PARAM2 *)
    CODE(MOVEMINC, {D1..D4} );                (* MOVEM (SP)+,D1-D4  *)
  END DIVU32;

  (* 32-BIT SIGNED ARITHMETIC FOR A LONG-INTEGER TYPE *)

  PROCEDURE MULS32     (MULTIPLICAN, MULTIPLIER : LONGINT);
    (* SEE MC68000 COURSE NOTES : PAGE 120.   *)
    (* (MOTOROLA TECHNICAL TRAINING).         *)
  CONST RESULT = PROCMARKSPACE + 4; (* OFFSET OF MULTIPLICAN *)
        PARAM2 = PROCMARKSPACE;     (* OFFSET OF MULTIPLIER  *)
  BEGIN
    CODE(MOVEMDEC, {8..15} );                   (* MOVEM D7-D0,-(SP) *)
    (* COPY THE 2 FACTORS INTO REGISTERS D1 AND D2 :       *)
    CODE(MOVEL + D1*LS9 + AOFF + MP, PARAM2);   (* MOVE.L RESULT,D1  *)
    CODE(MOVEL + D2*LS9 + AOFF + MP, RESULT);   (* MOVE.L PARAM2,D2  *)
    CODE(02601H,02801H,02A02H,02C01H,04287H,04844H,04845H);
    CODE(0C2C2H,0C4C4H,0C6C5H,0C8C5H,04841H);
    CODE(0D242H,0D987H,0D243H,0D987H);
    CODE(04841H,04242H,04243H,04842H,04843H);
    CODE(0D483H,0D484H,04845H,04A86H,06A02H);
    CODE(09485H,04A85H,06A02H,09486H);
    (* THE RESULT IS A 64-BIT PRODUCT AS FOLLOWS :         *)
    (* THE LOWER 32 BITS ARE IN LOCATION 'RESULT', WHEREAS *)
    (* THE UPPER 32 BITS PLUS THE SIGN ARE IN 'PARAM2'.    *)
    CODE(MOVEL + MP*LS9 + AOFF*LS3 + D1,RESULT);(* MOVE.L D1,RESULT  *)
    CODE(MOVEL + MP*LS9 + AOFF*LS3 + D2,PARAM2);(* MOVE.L D2,PARAM2  *)
    CODE(MOVEMINC, {0..7} );                    (* MOVEM (SP)+,D0-D7 *)
  END MULS32;

(*$P- , No entry/exit code as this routine calls DIVU32 direct. *)
  PROCEDURE DIVS32     (DIVIDEND, DIVISOR       : LONGINT);
    (* EVERYBODY LIKES TO IMPLEMENT THE 32-BIT *)
    (* SIGNED DIVIDE/MODULO.                   *)
  CONST RESULT = 4;     (* OFFSET OF DIVIDEND ON STACK *)       (*3.01a*)
        PARAM2 = 0;     (* OFFSET OF DIVISOR ON STACK *)        (*3.01a*)
  BEGIN
    CODE(MOVEL+D0*LS9+AINC+SP) ;    (* MOVE.L    +(SP),D0             *)

    CODE(MOVEL+D7*LS9+AOFF+SP,PARAM2) ;
    CODE(MOVEL+D6*LS9+AOFF+SP,RESULT) ;
    CODE(EORL+D7*LS9+D6) ;    
    CODE(SMI+D6) ;    (* D6 = signs different, must NEG result *)
    CODE(TST1+LONGW*LS6+AOFF+SP,RESULT) ;
    CODE(BPL+4) ;
    CODE(NEG+LONGW*LS6+AOFF+SP,RESULT) ;
    CODE(TST1+LONGW*LS6+D7) ;
    CODE(SMI+D7) ;    (* D7 = divisor -ve, must NEG remainder *)
    CODE(BPL+4) ;
    CODE(NEG+LONGW*LS6+AOFF+SP,PARAM2) ;

    SETREG(ADIR+A0,DIVU32) ;            (* get ADR(DIVU32) *)
    CODE(JSR + AIDR+A0) ;                       (* DIVU32 *)

    CODE(TST1+BYTE*LS6+D7) ;
    CODE(BEQ+4) ;
    CODE(NEG+LONGW*LS6+AOFF+SP,RESULT) ;
    CODE(TST1+BYTE*LS6+D6) ;
    CODE(BEQ+4) ;
    CODE(NEG+LONGW*LS6+AOFF+SP,PARAM2) ;

    CODE(MOVEL+SP*LS9+ADEC*LS3+D0) ;    (* MOVE.L    D0,-(SP) *)
    CODE(RTS) ;

  END DIVS32;


  (* FLOATING PACKAGE INTERFACE *)

  PROCEDURE FADD       (ADDER,       ADDEND     : REAL);
  CONST RESULT = PROCMARKSPACE + 4; (* OFFSET OF ADDER  *)
        PARAM2 = PROCMARKSPACE;     (* OFFSET OF ADDEND *)
  BEGIN
  (* SOFTWARE DEVELOPPED ON A SMAKY6/SMAKY8 SYSTEM, THEN KEYED IN
     FROM THE HEX LISTING.
     EACH LINE ('CODE') CORRESPONDS TO ONE COMMENTED PART IN THE SOURCE.
     THE ARITHMETIC IS DONE WITH ROUNDING.
     -0 ARE ALWAYS DETECTED AND CONVERTED TO +0 (OPERANDS, RESULT).
     27.4.1983 P. FINK ETH *)
    CODE ( 48E7H, 9F00H);
    CODE ( 282EH, 000CH, 2C2EH, 0008H,0E39CH, 0E39EH);
    CODE ( 2004H, 9086H, 6402H,0C946H);
    CODE ( 1604H,0C63CH, 0001H, 0800H, 0000H, 6704H, 08C3H, 0001H);
    CODE (0E19CH, 4245H, 1A04H, 56C4H,0E29CH, 4204H,0E19EH, 4247H,
           1E06H, 56C6H,0E29EH, 4206H);
    CODE ( 3005H, 9047H,0B07CH, 0018H, 622EH,0E0AEH);
    CODE ( 0803H, 0001H, 660AH);
    CODE (0D886H, 6404H, 0E294H, 5245H, 601CH);
    CODE ( 9886H, 6B18H, 6716H,0B8BCH, 0000H,0FFFFH, 6208H, 9A7CH,
           0010H, 4844H, 6B06H, 5345H,0E38CH, 6AFAH);
(* 1.10a : The ADDQ and ROXR opcodes were in the wrong order as the 
           ADDQ lost the X flag. (thats 0E294H <--> 5245H).
*)
    CODE (0D8BCH, 0000H, 0080H, 6404H, 0E294H, 5245H);
    CODE ( 4204H, 4A84H,
           6602H, 4245H, 4A45H, 6E04H, 4284H, 6018H,0BA7CH, 00FFH,(*1.01a*)
           6D08H);
    CODE (MOVEQ + 5); (* D0 = HALT-INDEX = 5 *) HALTX;
    CODE (0E38CH, 1805H,0E09CH,0E213H,0E294H);
    CODE ( 2D44H, 000CH, 4CDFH, 00F9H);
  END FADD;

  (*$P- NO PROC ENTRY CODE. THIS PROC JUMPS DIRECTLY TO THE BEGINNING
        OF FADD *)
  PROCEDURE FSUB       (MINUEND,     SUBTRAHEND : REAL);
  CONST RESULT = PROCMARKSPACE + 4; (* OFFSET OF RESULT *)
  BEGIN
    SETREG(ADIR+A0, FADD);
    CODE ( 086FH, 0007H, 0004H);  (* CHANGE SIGN OF SOURCE OPERAND *)
    CODE ( 4ED0H);   (* JUMP (A0) *)
  END FSUB;

  PROCEDURE FMUL       (MULTIPLICAN, MULTIPLIER : REAL);
  CONST RESULT = PROCMARKSPACE + 4; (* OFFSET OF RESULT *)
  BEGIN
    CODE ( 48E7H,0CF00H);
    CODE ( 282EH, 000CH, 2C2EH, 0008H);
    CODE ( 2E04H,0BD87H);
    CODE ( 4844H, 3A04H,0CA7CH, 7F80H, 676CH,0EE4DH,
          0C87CH, 007FH,
           887CH, 0080H, 4846H, 3E06H,0CE7CH, 7F80H, 6758H,0EE4FH,
          0CC7CH, 007FH, 8C7CH, 0080H);
    CODE (0DA47H, 9A7CH, 007EH, 6D46H);
    CODE ( 2004H, 4840H, 4846H,0C0C6H, 4240H, 4840H);
    CODE ( 3204H,0C2C6H,0D081H);
    CODE ( 2204H, 4841H, 4846H,0C2C6H,0D081H);
    CODE (0C8C6H, 4844H,0D880H);
    CODE ( 6B04H,0E38CH, 5345H);
    CODE (0D8BCH, 0000H, 0080H, 6404H,0E294H, 5245H);
    CODE ( 4A45H, 6B0EH,0BA7CH, 00FFH, 6D0CH);
    CODE (MOVEQ + 5); (* D0 = HALT-INDEX = 5 *) HALTX;
    CODE ( 4284H, 600AH);
    CODE (0E38CH, 1805H,0E09CH,0E397H,0E294H);
    CODE ( 2D44H, 000CH, 4CDFH, 00F3H);
  END FMUL;

  PROCEDURE FDIV       (DIVIDEND,    DIVISOR    : REAL);
  CONST RESULT = PROCMARKSPACE + 4; (* OFFSET OF RESULT *)
  BEGIN
    CODE ( 48E7H, 8F00H);
    CODE ( 282EH, 000CH, 2C2EH, 0008H);
    CODE ( 2E04H,0BD87H);
    CODE (0E38EH,0E19EH, 4247H, 1E06H, 675EH, 1C3CH, 0001H,0E29EH,
          0E38CH,0E19CH, 4245H, 1A04H, 6756H, 183CH, 0001H,0E29CH);
    CODE ( 9A47H,0DA7CH, 007FH);
    CODE ( 4846H,0E28CH, 88C6H, 3004H, 4244H, 88C6H, 4844H, 3800H);
    CODE ( 2006H, 4840H,0C0C4H,0E288H, 80C6H,0C0BCH, 0000H,0FFFFH,
          0E388H, 4844H, 9880H);
    CODE ( 6B04H,0E38CH, 5345H);
    CODE (0D8BCH, 0000H, 0080H, 6404H,0E294H, 5245H);
    CODE ( 4A45H, 6B0EH,0BA7CH, 00FFH, 6D0CH);
    CODE (MOVEQ + 5); (* D0 = HALT-INDEX = 5 *) HALTX;
    CODE ( 4284H, 600AH);
    CODE (0E39CH, 1805H,0E09CH,0E397H,0E294H);
    CODE ( 2D44H, 000CH, 4CDFH, 00F1H);
  END FDIV;

  PROCEDURE FCMP       (DESTINATION, SOURCE     : REAL);
  (* RESULT IS SET IN CONDITION-CODE-REGISTER N Z V BITS *)
  BEGIN
    CODE ( 48E7H,0E000H);
    CODE ( 202EH, 000CH, 2400H, 6A06H, 0A80H, 7FFFH,0FFFFH,
          0C4BCH, 7F80H, 0000H, 6602H, 4280H);
    CODE ( 222EH, 0008H, 2401H, 6A06H, 0A81H, 7FFFH,0FFFFH,
          0C4BCH, 7F80H, 0000H, 6602H, 4281H);
    CODE (0B081H);
    CODE ( 4CDFH, 0007H);
  END FCMP;

  PROCEDURE FTST       (TOTEST                  : REAL);
  (* RESULT IS SET IN CONDITION-CODE-REGISTER Z N BITS *)
  BEGIN
    CODE ( 48E7H,0A000H);
    CODE ( 202EH, 0008H);
    CODE ( 2400H,0C4BCH, 7F80H, 0000H, 6602H, 4280H);
    CODE ( 4A80H);
    CODE ( 4CDFH, 0005H);
  END FTST;

  PROCEDURE FLOATX     (TOCONVERT               : LONGWORD);
  CONST RESULT = PROCMARKSPACE; (* OFFSET OF RESULT *)
  BEGIN
    CODE ( 48E7H,0C000H);
    CODE ( 202EH, 0008H, 672AH, 323CH, 009EH);
    CODE (0B0BCH, 0000H,0FFFFH, 6206H, 4840H, 927CH, 0010H);
    CODE (0B0BCH, 00FFH,0FFFFH, 6204H,0E188H, 5141H);
    CODE (0E388H, 55C9H,0FFFCH);
    CODE ( 1001H,0E098H,0E288H);
    CODE ( 2D40H, 0008H, 4CDFH, 0003H);
  END FLOATX;

  PROCEDURE TRUNCX     (TOCONVERT               : REAL);
  CONST RESULT = PROCMARKSPACE; (* OFFSET OF RESULT *)
  BEGIN
    CODE ( 48E7H,0C000H);
    CODE ( 202EH, 0008H);
    CODE ( 6A0AH,0C0BCH, 7F80H, 0000H, 6716H, 6020H);
    CODE (0E388H,0E198H, 4241H, 1200H, 103CH, 0001H,0E298H);
    CODE ( 927CH, 007FH, 6C04H, 4280H, 601AH);
    CODE ( 927CH, 001FH, 4441H, 6C08H);
    CODE (MOVEQ + 5); (* D0 = HALT-INDEX = 5 *) HALTX;
    CODE (0E2A8H);
    CODE (0B0BCH, 0000H,0FFFFH, 62EEH);
    CODE ( 2D40H, 0008H, 4CDFH, 0003H);
  END TRUNCX;

(* ------------------------- 64 bit LONGREAL routines -------------------- *)
(* 4.10a : LONGREAL code by Martin Fisher                                  *)
(* LONGREAL support - developed on Pinnacle/Mac+ in assembler              *)
(* All routines use IEEE standard 64 bit arithmetic (but not sticky bits   *)
(* infinity and gradual underflow - features not supported by Modula-2)    *)
(* the S-code files were split into code statements and pasted into MACX   *)
(* and thus are not split into one CODE statement per instruction          *)
(* (*$P-*) option used - code contains necessary LINK instruction          *) 
(*$P-*)
PROCEDURE LFADD      (ADDER,       ADDEND     : LONGREAL);
CONST RESULT = PROCMARKSPACE+8;
BEGIN
    CODE(04E56H);CODE(00000H);CODE(048E7H);CODE(0FF00H);CODE(04CEEH);
    CODE(000F0H);CODE(00008H);CODE(07400H);CODE(0DA85H);CODE(0D984H);
    CODE(0DB82H);CODE(0DE87H);CODE(0DD86H);CODE(0DF82H);CODE(02004H);
    CODE(02205H);CODE(09287H);CODE(09186H);CODE(06404H);CODE(0CB47H);
    CODE(0C946H);CODE(07600H);CODE(01605H);CODE(0BF03H);CODE(00505H);
    CODE(06704H);CODE(0700FH);CODE(001C3H);CODE(0701FH);CODE(0E28CH);
    CODE(0E295H);CODE(06402H);CODE(001C4H);CODE(04844H);CODE(03204H);
    CODE(0E28EH);CODE(0E297H);CODE(06402H);CODE(001C6H);CODE(00241H);
    CODE(07FF0H);CODE(06612H);CODE(02806H);CODE(02A07H);CODE(048EEH);
    CODE(00030H);CODE(00010H);CODE(04CDFH);CODE(000FFH);CODE(04E5EH);
    CODE(04E75H);CODE(04844H);CODE(04846H);CODE(03006H);CODE(00240H);
    CODE(07FF0H);CODE(067E6H);CODE(04844H);CODE(00244H);CODE(0000FH);
    CODE(008C4H);CODE(00004H);CODE(04844H);CODE(00246H);CODE(0000FH);
    CODE(008C6H);CODE(00004H);CODE(04846H);CODE(03401H);CODE(09240H);
    CODE(0673AH);CODE(0E849H);CODE(00C41H);CODE(00035H);CODE(0644CH);
    CODE(00C01H);CODE(00020H);CODE(06D0AH);CODE(02E06H);CODE(07C00H);
    CODE(00401H);CODE(00020H);CODE(06722H);CODE(00C01H);CODE(00010H);
    CODE(06D0EH);CODE(03E06H);CODE(04246H);CODE(04846H);CODE(04847H);
    CODE(00401H);CODE(00010H);CODE(0670EH);CODE(07000H);CODE(03006H);
    CODE(0E2AEH);CODE(0E2AFH);CODE(0E2B8H);CODE(04240H);CODE(08E80H);
    CODE(00803H);CODE(00000H);CODE(0662EH);CODE(0DA87H);CODE(0D986H);
    CODE(07015H);CODE(00104H);CODE(0670AH);CODE(0E28CH);CODE(0E295H);
    CODE(00642H);CODE(00010H);CODE(06B12H);CODE(04844H);CODE(00244H);
    CODE(0000FH);CODE(08842H);CODE(04203H);CODE(08843H);CODE(04844H);
    CODE(06000H);CODE(0FF66H);CODE(07005H); HALTX;
    CODE(09A87H);CODE(09986H);CODE(06612H);CODE(04A85H);CODE(06700H);
    CODE(0FF52H);CODE(04845H);CODE(03805H);CODE(04245H);CODE(00442H);
    CODE(00100H);CODE(06B28H);CODE(00C84H);CODE(00000H);CODE(0000FH);
    CODE(0620EH);CODE(04844H);CODE(04845H);CODE(03805H);CODE(04245H);
    CODE(00442H);CODE(00100H);CODE(06B12H);CODE(07014H);CODE(00104H);
    CODE(066B2H);CODE(00442H);CODE(00010H);CODE(06B06H);CODE(0DA85H);
    CODE(0D984H);CODE(060F0H);CODE(07800H);CODE(07A00H);CODE(06000H);
    CODE(0FF16H);CODE(06000H);CODE(0FF16H)
END LFADD ;

(*$P-*)
PROCEDURE LFSUB      (MINUEND,     SUBTRAHEND : LONGREAL);
CONST RESULT = PROCMARKSPACE+8 ;
BEGIN
    SETREG(ADIR+A0,LFADD) ;
    CODE(0086FH);CODE(00007H);CODE(00004H);CODE(04ED0H);
END LFSUB ;

(*$P-*)
PROCEDURE LFMUL      (MULTIPLICAN, MULTIPLIER : LONGREAL);
CONST RESULT = PROCMARKSPACE+8 ;
BEGIN
    CODE(04E56H);CODE(00000H);CODE(048E7H);CODE(0FF00H);CODE(04CEEH);
    CODE(000F0H);CODE(00008H);CODE(04844H);CODE(03604H);CODE(04846H);
    CODE(0BD43H);CODE(05BE7H);CODE(03404H);CODE(0303CH);CODE(07FF0H);
    CODE(0C440H);CODE(06700H);CODE(0010EH);CODE(03606H);CODE(0C640H);
    CODE(06700H);CODE(00106H);CODE(0D642H);CODE(00443H);CODE(03FF0H);
    CODE(06300H);CODE(000FCH);CODE(06B00H);CODE(000FEH);CODE(0700FH);
    CODE(0C840H);CODE(008C4H);CODE(00004H);CODE(0CC40H);CODE(008C6H);
    CODE(00004H);CODE(07400H);CODE(03F03H);CODE(03004H);CODE(0C0C6H);
    CODE(04840H);CODE(03204H);CODE(0C2C7H);CODE(03604H);CODE(04846H);
    CODE(0C6C6H);CODE(0D083H);CODE(03604H);CODE(04847H);CODE(0C6C7H);
    CODE(04841H);CODE(0D243H);CODE(04243H);CODE(04843H);CODE(0D183H);
    CODE(04844H);CODE(03604H);CODE(0C6C6H);CODE(0D243H);CODE(04841H);
    CODE(04243H);CODE(04843H);CODE(0D183H);CODE(03604H);CODE(04846H);
    CODE(0C6C6H);CODE(0D083H);CODE(03604H);CODE(0C6C7H);CODE(0D283H);
    CODE(0D182H);CODE(03604H);CODE(04847H);CODE(0C8C7H);CODE(04244H);
    CODE(04844H);CODE(0D284H);CODE(0D182H);CODE(03605H);CODE(0C6C6H);
    CODE(0D283H);CODE(0D182H);CODE(03605H);CODE(04846H);CODE(0C6C6H);
    CODE(04243H);CODE(04843H);CODE(0D283H);CODE(0D182H);CODE(04845H);
    CODE(03605H);CODE(0C6C6H);CODE(0D283H);CODE(0D182H);CODE(04846H);
    CODE(0CCC5H);CODE(04841H);CODE(0D246H);CODE(04841H);CODE(04246H);
    CODE(04846H);CODE(0D186H);CODE(04847H);CODE(0CAC7H);CODE(04245H);
    CODE(04845H);CODE(0D285H);CODE(0D182H);CODE(05081H);CODE(0D182H);
    CODE(0361FH);CODE(07804H);CODE(07A19H);CODE(00B00H);CODE(06706H);
    CODE(05244H);CODE(00643H);CODE(00010H);CODE(01400H);CODE(0E8BAH);
    CODE(04202H);CODE(0E8A8H);CODE(0E8A9H);CODE(08282H);CODE(05B05H);
    CODE(00B00H);CODE(0660CH);CODE(0D482H);CODE(0D381H);CODE(0D180H);
    CODE(00443H);CODE(0000AH);CODE(06324H);CODE(04A43H);CODE(06B28H);
    CODE(04840H);CODE(00240H);CODE(0000FH);CODE(08043H);CODE(04840H);
    CODE(04A1FH);CODE(06704H);CODE(0761FH);CODE(007C0H);CODE(048EEH);
    CODE(00003H);CODE(00010H);CODE(04CDFH);CODE(000FFH);CODE(04E5EH);
    CODE(04E75H);CODE(0544FH);CODE(07000H);CODE(07200H);CODE(060EAH);
    CODE(MOVEQ + 5);  (* D0 = HALT-INDEX = 5 *)
    HALTX;            (* HALTX(8)            *)
END LFMUL ;

(*$P-*)
PROCEDURE LFDIV      (DIVIDEND,    DIVISOR    : LONGREAL);
CONST RESULT = PROCMARKSPACE+8;
BEGIN
    CODE(04E56H);CODE(00000H);CODE(048E7H);CODE(0FF00H);CODE(04CEEH);
    CODE(000F0H);CODE(00008H);CODE(04844H);CODE(03204H);CODE(00241H);
    CODE(07FF0H);CODE(06700H);CODE(0008EH);CODE(04846H);CODE(03006H);
    CODE(00240H);CODE(07FF0H);CODE(06700H);CODE(00070H);CODE(09041H);
    CODE(00640H);CODE(03FF0H);CODE(06B00H);CODE(00078H);CODE(03206H);
    CODE(0B941H);CODE(05BE7H);CODE(00246H);CODE(0000FH);CODE(008C6H);
    CODE(00004H);CODE(00244H);CODE(0000FH);CODE(008C4H);CODE(00004H);
    CODE(04846H);CODE(04844H);CODE(0721EH);CODE(07600H);CODE(06122H);
    CODE(02403H);CODE(07217H);CODE(07600H);CODE(06116H);CODE(07209H);
    CODE(0E3ABH);CODE(0D582H);CODE(06B4EH);CODE(00440H);CODE(00010H);
    CODE(06B00H);CODE(0002CH);CODE(0D683H);CODE(0D582H);CODE(06040H);
    CODE(0DE87H);CODE(0DD86H);CODE(0BC84H);CODE(05CC9H);CODE(0FFF8H);
    CODE(003C3H);CODE(09E85H);CODE(09D84H);CODE(05BC9H);CODE(0FFEEH);
    CODE(06A0CH);CODE(0DE85H);CODE(0DD84H);CODE(00383H);CODE(04A41H);
    CODE(05DC9H);CODE(0FFE0H);CODE(04E75H);CODE(0548FH);CODE(07400H);
    CODE(07600H);CODE(048EEH);CODE(0000CH);CODE(00010H);CODE(04CDFH);
    CODE(000FFH);CODE(04E5EH);CODE(04E75H);CODE(07005H);HALTX;
    CODE(07C00H);CODE(00683H);CODE(00000H);
    CODE(00800H);CODE(0D586H);CODE(0640AH);CODE(0E292H);CODE(0E293H);
    CODE(00640H);CODE(00010H);CODE(06BE2H);CODE(07200H);CODE(03202H);
    CODE(07E0BH);CODE(0EEAAH);CODE(0EEABH);CODE(0EEB9H);CODE(04201H);
    CODE(08681H);CODE(04842H);CODE(00242H);CODE(0000FH);CODE(08440H);
    CODE(04842H);CODE(04A1FH);CODE(067B6H);CODE(0701FH);CODE(001C2H);
    CODE(060B0H);
END LFDIV ;

(*$P-*)
PROCEDURE LFCMP      (DESTINATION, SOURCE     : LONGREAL);
(* RESULT IS RETURNED IN CCR z AND n BITS *)
BEGIN
    CODE(04E56H);CODE(00000H);CODE(048E7H);CODE(0F800H);CODE(04CEEH);
    CODE(0000FH);CODE(00008H);CODE(02800H);CODE(06A08H);CODE(00A80H);
    CODE(07FFFH);CODE(0FFFFH);CODE(04681H);CODE(00284H);CODE(07FF0H);
    CODE(00000H);CODE(06604H);CODE(07000H);CODE(07200H);CODE(02802H);
    CODE(06A08H);CODE(00A82H);CODE(07FFFH);CODE(0FFFFH);CODE(04683H);
    CODE(00284H);CODE(07FF0H);CODE(00000H);CODE(06604H);CODE(07400H);
    CODE(07600H);CODE(0B480H);CODE(06602H);CODE(0B681H);CODE(04CDFH);
    CODE(0001FH);CODE(04E5EH);CODE(04E75H);
END LFCMP ;

(*$P-*)
PROCEDURE LFTST      (TOTEST                  : LONGREAL);
(* Result returned in CCR z and n bits *)
BEGIN
    CODE(04E56H);CODE(00000H);CODE(048E7H);CODE(0C000H);CODE(0202EH);
    CODE(00008H);CODE(02200H);CODE(00281H);CODE(07FF0H);CODE(00000H);
    CODE(06602H);CODE(07000H);CODE(04A80H);CODE(04CDFH);CODE(00003H);
    CODE(04E5EH);CODE(04E75H);
END LFTST ;

(*$P-*)
PROCEDURE LFLOATX    (TOCONVERT               : LONGWORD);
CONST RESULT = PROCMARKSPACE ;
BEGIN
        CODE(04E56H);CODE(00000H);CODE(048E7H);
        CODE(0E000H);CODE(07000H);CODE(0222EH);CODE(00008H);
        CODE(06748H);CODE(0343CH);CODE(041E0H);CODE(04841H);
        CODE(03001H);CODE(0660AH);CODE(04841H);CODE(03001H);
        CODE(07200H);CODE(00442H);CODE(00100H);CODE(04241H);
        CODE(00C40H);CODE(000FFH);CODE(0620CH);CODE(0E188H);
        CODE(0E199H);CODE(08001H);CODE(04201H);CODE(00442H);
        CODE(00080H);CODE(04A40H);CODE(06B0AH);CODE(00442H);
        CODE(00010H);CODE(0D281H);CODE(0D140H);CODE(06AF6H);
        CODE(0EB88H);CODE(0EB99H);CODE(08001H);CODE(04201H);
        CODE(04840H);CODE(00240H);CODE(0000FH);CODE(08042H);
        CODE(04840H);CODE(048EEH);CODE(00003H);CODE(00008H);
        CODE(04CDFH);CODE(00007H);CODE(04E5EH);CODE(04E75H);
        CODE(04E75H);
END LFLOATX ;



(*$P-*)
PROCEDURE LTRUNCX    (TOCONVERT               : LONGREAL);
CONST RESULT = PROCMARKSPACE+4 ;
BEGIN
    CODE(04E56H);CODE(00000H);CODE(048E7H);CODE(0E000H);CODE(04CEEH);
    CODE(00003H);CODE(00008H);CODE(04840H);CODE(07400H);CODE(03400H);
    CODE(06A0EH);CODE(00242H);CODE(07FF0H);CODE(06738H);CODE(07005H);
    HALTX;
    CODE(0E84AH);CODE(0672CH);
    CODE(00442H);CODE(003FFH);CODE(06D26H);CODE(00240H);CODE(0000FH);
    CODE(008C0H);CODE(00004H);CODE(04840H);CODE(00442H);CODE(0001FH);
    CODE(04442H);CODE(06DDCH);CODE(00442H);CODE(0000BH);CODE(06D12H);
    CODE(0E4A8H);CODE(02D40H);CODE(0000CH);CODE(04CDFH);CODE(00007H);
    CODE(04E5EH);CODE(04E75H);CODE(07000H);CODE(060F0H);CODE(04442H);
    CODE(0E5A8H);CODE(04241H);CODE(0E5B9H);CODE(08041H);CODE(060E4H);
END LTRUNCX ;
(*$P+*)

(*$P-*)
PROCEDURE LENGTHEN(real : REAL) ;
(* Convert a 32 bit Real to a 64 bit LongReal *)
CONST RESULT = PROCMARKSPACE ;
BEGIN
CODE(04E56H);CODE(00000H);CODE(048E7H);CODE(0E000H);CODE(0202EH);CODE(00008H);
CODE(0E398H);CODE(02400H);CODE(00280H);CODE(000FFH);CODE(0FFFFH);CODE(00282H);
CODE(0FF00H);CODE(00000H);CODE(06612H);CODE(07000H);CODE(07200H);CODE(048EEH);
CODE(00003H);CODE(00008H);CODE(04CDFH);CODE(00007H);CODE(04E5EH);CODE(04E75H);
CODE(0E68AH);CODE(0E288H);CODE(0E292H);CODE(00682H);CODE(03800H);CODE(00000H);
CODE(02200H);CODE(0E688H);CODE(0E699H);CODE(00281H);CODE(07000H);CODE(00000H);
CODE(08082H);CODE(060D6H);
END LENGTHEN;

(*$P-*)
PROCEDURE SHORTEN(longreal : LONGREAL) ;
(* Convert a 64 bit LongReal to a 32 bit Real *)
CONST RESULT = PROCMARKSPACE+4 ;
BEGIN
    CODE(04E56H);CODE(00000H);CODE(048E7H);CODE(0F000H);CODE(04CEEH);
    CODE(00003H);CODE(00008H);CODE(04840H);CODE(03400H);CODE(00242H);
    CODE(07FF0H);CODE(06762H);CODE(00442H);CODE(03800H);CODE(06B00H);
    CODE(0005CH);CODE(00C42H);CODE(00FFFH);CODE(06E00H);CODE(00058H);
    CODE(0E94AH);CODE(0760FH);CODE(00700H);CODE(06704H);CODE(008C2H);
    CODE(00000H);CODE(00240H);CODE(0000FH);CODE(008C0H);CODE(00004H);
    CODE(04840H);CODE(00681H);CODE(00010H);CODE(00000H);CODE(06412H);
    CODE(05280H);CODE(07614H);CODE(00700H);CODE(0660AH);CODE(0E288H);
    CODE(0E291H);CODE(00642H);CODE(00100H);CODE(06526H);CODE(0E788H);
    CODE(0E799H);CODE(00201H);CODE(00007H);CODE(08001H);CODE(04840H);
    CODE(00880H);CODE(00007H);CODE(0E25AH);CODE(08042H);CODE(04840H);
    CODE(02D40H);CODE(0000CH);CODE(04CDFH);CODE(0000FH);CODE(04E5EH);
    CODE(04E75H);CODE(07000H);CODE(060F0H);CODE(07005H);HALTX
END SHORTEN;
(*$P+*)
(* End of LONGREAL (4.10a) additions                                      *)
(* ---------------------------------------------------------------------- *)

VAR
(*
  Stack: ARRAY [0..512 DIV 2] OF CARDINAL;  (*4.00a*)
*)
  Stack: ARRAY [0..896 DIV 2] OF CARDINAL; (* EdHak 2.30 1/15/92 *)

(*$P- THIS IS A VERY SPECIAL MODULE BODY *)
BEGIN (* BODY OF MODULE SYSTEMX : FIRST MODULE BODY EXECUTED. *)
(* copy A0 to A6 for temp storage since A0 gets zapped by GEMDOS call *)
  CODE(MOVEAL + A6*LS9 + ADIR+A0) ;        (* MOVEA.L   A0,A6        *)
(* clr.l D0 *)
  CODE(CLR + LONGW*LS6 + DDIR);
(* cmpa.l D0, A0 *)
  CODE(CMPAL + A0 + DDIR);
(**
(* bne 6(pc) skip prg basepage stuff *)
  CODE(BNE + 48) ; (* jump down to where BasePageAddress is set to A0 *)
**)
  CODE(BNE + 54) ; (* jump down to where BasePageAddress is set to A6=A0 *)

(********************************)
(*** the next two+ lines are for running as a prg ***)
  CODE(MOVEAL + A0*LS9 + ADIR+A7) ;        (* MOVEA.L   A7,A0        *)
  CODE(MOVEAL+A0*LS9+A0+AOFF,4) ;          (* MOVEA.L   4(A0),A0     *)
(***
  BasePageAddress := REGISTER(8) ;        (* MOVE.L  A0,BasePageAddress   *)
***)
(* copy A0 to A6 for temp storage since A0 gets zapped by GEMDOS call *)
  CODE(MOVEAL + A6*LS9 + ADIR+A0) ;        (* MOVEA.L   A0,A6        *)

(****************)
(** check if running as prg, and if so, shrink memory *)
(**
   The first thing a GEM application has to do is access the base page
   and return any spare memory via the GEMDOS 'Shrink' command.
**)

(** not needed for this modified acc/prg startup code...
  StackSize := BasePageAddress^.CodeBase ;  (* patched stack size loc *)
**)

(* start addition with code length (text segment of code) *)
  CODE(MOVEL+D0*LS9+AOFF,0CH);            (* MOVE.L    C(A0),D0           *)
(* add data length *)
  CODE(ADD+LONGW*LS6+D0*LS9+AOFF,14H);     (* ADD.L     14(A0),D0          *)
(* add bss length *)
  CODE(ADD+LONGW*LS6+D0*LS9+AOFF,1CH);     (* ADD.L     1C(A0),D0          *)
(****
 Add stacksize, which is longword at 6 bytes above the actual start of code,
 since linker puts jmp.l (6 bytes) followed by stacksize at start of code.
 But for ACC, we don't need or want any normal stack, so we skip this.
 (and we still use our own stack when running as PRG)

  SETREG(D5,StackSize^.Size);
  CODE(ADD+LONGW*LS6+D0*LS9+D5);          (* ADD.L     StackSize^,D0      *)
****)
(* add size of basepage = $100 *)
  CODE(ADDI+LONGW*LS6+D0,0,100H);         (* ADDI.L    #$100,D0           *)
(**)
(* set stack pointer to sum of codelen, datalen, bsslen, stacksize & basepagelen *)
  CODE(MOVEAL+SP*LS9+D0);                 (* MOVEA.L   D0,SP              *)
(* now add all that to the base page address to move it up in memory *)
  CODE(ADDAL+SP*LS9+A0+ADIR);             (* ADDA.L    A0,SP              *)

(***
(* deleted 2.30 1/29/92, -6 bytes *)
(* +12 to allow 12 for MShrink call *)
  CODE(ADDAL+SP*LS9+IMM,0,12);            (* ADDA.L    12,SP              *)
***)
(****)
(* Now prepare the GEMDOS MShrink call *)
  (* save registers, 2.30, 1/29/92, +4 bytes *)
  (* movem.l A1-A2/D1-D2,-(SP) *)
  CODE(048E7H, 06060H); (* 0100 1000 1110 0111, 0110 0000 0110 0000 *)

(* First PUSH the size of space to reserve onto the stack *)
  CODE(MOVEL+ADEC*LS3+SP*LS9+D0);         (* MOVE.L    D0,-(SP)           *)
(* Then PUSH the address of the start of space to reserve, = basepage adr  *)
  CODE(MOVEL+ADEC*LS3+SP*LS9+A0+ADIR);    (* MOVE.L    A0,-(SP)           *)
(* Now PUSH any dummy word place holder (could just be clr.w) onto stack *)
  CODE(MOVEW+ADEC*LS3+SP*LS9+D0);         (* MOVE.W    D0,-(SP)           *)
(* Push MShrink code onto stack *)
  CODE(MOVEW+ADEC*LS3+SP*LS9+IMM,4AH);    (* MOVE.W    4AH,-(SP)          *)
(* and finally call GEMDOS trap *) (* this can screw up regs A0-A2 *)
  CODE(TRAP+1);                           (* TRAP      #1                 *)
(* 2.30 1/29/92 +4 bytes, add back in to be safe *)
(* fix stack pointer, i.e., pop 12 bytes from stack *)
  CODE(0508FH); (* (0101 0000 1000 1111) addq.l #8, sp [stack corr.] *)
  CODE(0588FH); (* (0101 1000 1000 1111) addq.l #4, sp [stack corr.] *)
(** probably unneeded since don't use this stack?: **)
(**
(* fix stack pointer, i.e., pop 12 bytes from stack *)
  CODE(ADDAL+SP*LS9+IMM,0,12);            (* ADDA.L    12,SP              *)
**)
  (* restore all necessary registers, 2.30 1/29/92, +4 bytes *)
  (* movem.l A1-A2/D1-D2,(SP)+ *)
  CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)

(******** End of Shrink code *********)

(* This is where we jump to from above if acc instead of prg *)
(* Set basepageadr for exporting to other modules that might want it *)
(* get from A6 since Gemdos TRAP call ruined A0 *)

  BasePageAddress:= REGISTER(14);        (* MOVE.L  A6,BasePageAddress   *)

(**
(* movea.l A0, A1  copy for later checking if acc or prg in term stuff *)
  CODE(MOVEAL + ADIR+A0 + A1*LS9);
**)
(**
(* movea.l BasePageAddress, A1 *)
  SETREG(9, BasePageAddress); (* for later termination code stuff *)
**)

  (* Setup our local stack A7 = SP *)
  SETREG(15, ADR(Stack[HIGH(Stack)])) ; (* set stack pointer to top word of stack *)

(* copy stack pointer to A0 *)
  CODE(MOVEAL + ADIR+SP + A0*LS9);           (* MOVEA.L A7,A0     *) (*4.00a*)
(* clr.l -(A0) clears 12 bytes of stack below top word *)
  CODE(CLR + LONGW*LS6 + ADEC);               (* RESERVE          *)
  CODE(CLR + LONGW*LS6 + ADEC);               (* RESERVE          *)
  CODE(CLR + LONGW*LS6 + ADEC);               (* RESERVE          *)
(****** GEM TEMP KLUDGE *)
(* move.l $1000, -(A0) puts 4096 decimal in 4th longword from top word of stack *)
  CODE(MOVEL + ADEC*LS3 + IMM , 0 ,1000H);   (* STACKLIMIT=19000H*)(* $TDI *)
(* clr.l -(A0) clears 5th longword from top word of stack *)
  CODE(CLR + LONGW*LS6 + ADEC);               (* HERE THE PD      *)
(* movea.l A0, A5 saves address of 5th longword from top word of stack in A5 *)
  CODE(MOVEAL + PD*LS9 + ADIR);              (* INITIAL 'PD'     *)
(* suba.l #36, A0 skip 8 more longwords down into stack *)
  CODE(SUBAL-LS8 + IMM, 36);                 (* DISPLAY'S        *)

(****)
(* lea 6(pc), A1  save pointer to SUBAL command as term address for acc
   or pointer to TermOpcode command if prg *)
(* See if pointer to parent's basepage is zero = acc *)
(* cmpi.l #0, 36(A6) *)
  CODE(CMPI + LONGW*LS6 + A6+AOFF, 0,0, 36);
(* beq 6(pc) skip prg term stuff *)
  CODE(BEQ + 6) ;
(* lea 12(pc), A1 set term address for PRG *)
  CODE(LEA + A1*LS9 + PREL, 12);              (* SET THE          *)(* ++ *)
(* bra 4(pc) skip acc term setting command *)
  CODE(BRA + 4) ;

(* lea 24(pc), A1 set term address for ACC to SUBAL command *)
  CODE(LEA + A1*LS9 + PREL, 26);              (* SET THE          *)(* ++ *)
(****)

(* move.l A1, -(A0) put startup (term?) address at 14th longword from top of stack *)
  CODE(MOVEL + ADEC*LS3 + ADIR+A1);          (*  TERMINATION ADR *)(* ++ *)
(****)
    CODE(BRA + 10H) ;                          (* skip term stuff  *)
    CODE(MOVEL + IMM,0,TermOpcode) ;           (* MOVE.L  GEMTERM,D0     *)
    CODE(PUSHWORDD0) ;
    CODE(MOVEL + IMM,0,0) ;                    (* MOVE.L  0,D0     *)
    CODE(GEMDOSTRAP) ;
(****)
(* movea.l A0, SP set stack pointer to 14th longword from top of stack *)
  CODE(MOVEAL + ADIR+A0 + SP*LS9);           (* MOVE.L A0,A7     *) (*4.00a*)

(* suba.l A6, A6  why not just movea.l #0,A6 ? because it's shorter(&faster?) *)
  CODE(SUBAL + MP*LS9 + ADIR+MP);            (* INITIAL MP = clear A6  *)

(** only if want to pass basepageadr in A0 as well as A2 **
(* movea.l A2,A0 save basepageadr *)
  CODE(MOVEAL+A0*LS9+A2+ADIR);
**)
  (* now run through initialisation list *)

END (* OF IMPLEMENTATION MODULE *) GEMX.
