MODULE Sys; (*SJ 17.10.93 *)


IMPORT
  S:=SYSTEM, O2Init;


CONST
  CompDate = "04.01.1994";
  CompTime = "11:06:00";
  StackSize= "300";

  TYPERR*    = 1;  (* type check failed *)
  NORET*     = 2;  (* return missing *)
  CASERR*    = 3;  (* case selector failed & no else *)
  REALERR*   = 4;  (* floating point error *)
  OUTOFMEM*  = 5;  (* no more memory available *)
  WITHERR*   = 6;  (* with selector failed & no else *)
  MEMERR*    = 7;  (* memory destroyed *)
  STACKERR*  = 8;  (* stack overflow *)
  BUSERR*    = 10;  (* cpu bus error *)
  ADDRERR*   = 11;  (* cpu address error *)
  ILLERR*    = 12;  (* illegal opcode *)
  DIVERR*    = 13;  (* division by zero *)
  INXERR*    = 14;  (* index check failed *)
  OVFLERR*   = 15;  (* overflow error *)
  PRIVERR*   = 16;  (* privilege error *)
  TRACERR*   = 17;  (* trace exception *)
  PROTOUSED* = 20;  (* prototype used which should be overridden *)
  NOMEMADR*  = 21;  (* DISPOSE called with no valid memory address *)
  BREAK*     = 22;  (* User pressed Shift-Shift *)



TYPE
  basepage* = POINTER TO RECORD
                LowTPA*,  HighTPA*,  TextBase*,  TextLen*,  DataBase*,
                DataLen*,  BssBase*,  BssLen*,  DTA*,  Parent* : LONGINT;
                LoadDrv*,  CurrDrv* : CHAR;
                Rsv1     : INTEGER;
                Env*     : LONGINT;
                Rsv2     : ARRAY 50H OF CHAR;
                ComLen*  : SHORTINT; (* 0..127 *)
                Command* : ARRAY 127 OF CHAR;
              END(*RECORD*);
  haltproc* = PROCEDURE ( Value : INTEGER );



VAR
  Basepage* : basepage;
  (*
   points to the basepage of the linked program or, wenn running as module
   to the basepage of OBERON.PRG. In the commandline of the basepage,
   Loader.Call writes the Command given to it. Modules that use the feature
   of taking parameters, can read them out of the variable Basepage.Command.
   When running as a stand alone program, Basepage points to the basepage
   of the program and parameters are also in Basepage.Command. Notice
   that you can test if your program is called as an accessory, then
   Basepage.Parent is 0
   *)

  Halt* : haltproc;
  (*
   this procedure is called if a HALT-command occurs. The parameter is the
   same as the one of HALT in the source file. System links a procedure
   which calls GEMDOS.Pterm. Oberon links a procedure which show an alert
   where the user can choose to cancel running, debug or continue. You
   can link your own routine if you wish
   *)

  Loader*,ModuleCall* : BOOLEAN;
  (*
   Loader is TRUE if running under the oberon load time linking environment.
   Then ModuleCall is TRUE if the module was called, else a single procedure
   from the module is called
   *)

  MiNT*   : BOOLEAN;
  (*
   TRUE if running under MiNT, the multitasking environment
   *)

  FPU*    : BOOLEAN;
  (*
   TRUE if there is a floating point unit. (set if there is a cookie "_FPU")
   *)

  Cpu68030* : BOOLEAN;
  (*
   TRUE if the _CPU cookie has a value of $1E = 68030
   *)

  isAcc*   : BOOLEAN;
  (*
   TRUE if the program was started as an accessory
   *)

  compDate* : ARRAY 12 OF CHAR;
  (*
   This string always contains the date of compilation of the main
   module. The format is "tt.mm.jjjj". The loaders and the linker
   set this string when linking.
   *)

  compTime* : ARRAY 10 OF CHAR;
  (*
   similar to compDate. Can also be displayed while developping. Is
   normally not displayed in programs. Format is "hh:mm:ss".
   *)

  stackSize*, stackEnd*: LONGINT;

  Contents: LONGINT;

  CookieJar : S.PTR;


PROCEDURE SetCompTimeDate;
 BEGIN
  COPY(CompDate, compDate);
  COPY(CompTime, compTime);
 END SetCompTimeDate;


PROCEDURE SetStack;
 BEGIN
  S.GET( S.ADR( StackSize), stackSize);
  stackEnd := S.VAL( LONGINT, Basepage) + 256 + Basepage.TextLen
              + Basepage.DataLen + Basepage.BssLen - stackSize;
 END SetStack;

(*$-k *)

PROCEDURE halt*(no: INTEGER);
 BEGIN
  Halt(no);
 END halt;


PROCEDURE CaseFail*;
 BEGIN
  Halt(CASERR);
 END CaseFail;


PROCEDURE WithFail*;
 BEGIN
  Halt(WITHERR);
 END WithFail;


PROCEDURE IndexFail*;
 BEGIN
  Halt(INXERR);
 END IndexFail;


PROCEDURE TypeFail*;
 BEGIN
  Halt(TYPERR);
 END TypeFail;


PROCEDURE RetFail*;
 BEGIN
  Halt(NORET);
 END RetFail;


(*$-c for speed reasons *)

PROCEDURE CheckStack*;
 BEGIN
  ASSEMBLER

    CMP.L  stackEnd,SP
    BGE  Ok
    MOVE.W  #STACKERR,-(SP)
    BSR  halt
    ADDQ  #2,SP
  Ok:
    RTS

  END;
 END CheckStack;


PROCEDURE CheckLongIndex*;
 BEGIN
  ASSEMBLER

    TST.L D0
    BMI.B fail

    CMP.L D1,D0
    BGT.B fail

    RTS

  fail:
    BRA   IndexFail

  END;
 END CheckLongIndex;

(*$+c *)

(* GEMDOS may not be imported *)

PROCEDURE- Cconout(c : INTEGER) 2,1;

PROCEDURE- Cconws(StrPtr : S.PTR) 9,1;

PROCEDURE- Pterm(Return : INTEGER) 76,1;

PROCEDURE MsgHalt(no: INTEGER);
 BEGIN
  Cconout( 1BH); Cconout( 70H);  (* revers on *)
  Cconws( S.ADR( "HALT command encountered") );
  Cconout( 1BH); Cconout( 71H);  (* revers off *)
  Cconout( 0DH); Cconout( 0AH);
  Cconws( S.ADR( "Program is aborted") );
  Cconout( 0DH); Cconout( 0AH);
  Pterm(no);
 END MsgHalt;

(* Cookie may not be imported *)

PROCEDURE- Supexec(Code : PROCEDURE) 38,14;

(*$-k *)

PROCEDURE GetCookieJar; (* super mode *)
 BEGIN
  S.GET(5A0H,CookieJar);
 END GetCookieJar;

(*$+k *)

PROCEDURE CookieSearch(Code : ARRAY OF CHAR; VAR Cont : LONGINT) : BOOLEAN;
  VAR
    ptr: S.PTR; li, key : LONGINT;
 BEGIN
  Supexec( GetCookieJar);
  IF CookieJar # NIL THEN
    S.GET(S.ADR(Code),li);
    ptr := CookieJar;
    S.GET( ptr, key);
    WHILE key # 0 DO
      IF key = li THEN
        S.GET( ptr+4, Cont); RETURN TRUE
      END;
      INC(ptr, 8);
      S.GET( ptr, key);
    END;
  END;
  RETURN FALSE
 END CookieSearch;


BEGIN
  SetCompTimeDate;
  Halt := MsgHalt;
  Cpu68030 := CookieSearch("_CPU", Contents) & (Contents = 1EH);
  MiNT := CookieSearch("MiNT", Contents);
  FPU := CookieSearch("_FPU", Contents);
  Basepage := O2Init.Basepage;
  SetStack;
  isAcc := O2Init.isAcc;
  Loader := O2Init.loader;
END Sys.

