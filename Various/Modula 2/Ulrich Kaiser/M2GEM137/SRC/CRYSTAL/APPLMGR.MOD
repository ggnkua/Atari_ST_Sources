IMPLEMENTATION MODULE ApplMgr;

(*
AES Application Manager.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM AES      IMPORT Global,IntIn,IntOut,Addr,crystal,Version,Integer;
FROM pSTORAGE IMPORT ALLOCATE,DEALLOCATE;
FROM PORTAB   IMPORT SIGNEDWORD,UNSIGNEDWORD,WORDSET,ANYTYPE,ANYPOINTER;
FROM SYSTEM   IMPORT ADR;
#if (defined LPRM2) || (defined SPCM2)
FROM SYSTEM   IMPORT SETREG,INLINE;
FROM Register IMPORT D1;
#elif (defined TDIM2) || (defined FTLM2)
FROM SYSTEM   IMPORT SETREG,CODE;
FROM Register IMPORT D1;
#elif (defined ANAM2)
FROM SYSTEM   IMPORT SETREG,CODE;
FROM Register IMPORT D1;
#elif (defined HM2)
FROM SYSTEM   IMPORT LOAD,CODE;
FROM Register IMPORT D1;
#elif (defined MM2)
FROM SYSTEM   IMPORT CADR,LOAD,ASSEMBLER;
FROM Register IMPORT D1;
#elif (defined FSTM2)
FROM SYSTEM   IMPORT ASSEMBLER;
#elif (defined LM2)
FROM SYSTEM   IMPORT SETREG,CX,DX,SWI;
#elif (defined SDSM2)
FROM SYSTEM   IMPORT RegCX,RegDX,SWI;
#elif (defined TSM2_1)
FROM AESSYS   IMPORT applyield;
#elif (defined TSM2_2)
FROM SYSTEM   IMPORT BYTE;
#endif
CAST_IMPORT
#if ST
FROM AES IMPORT KAOS;
#endif
(*
FROM e    IMPORT ENOMEM;
FROM clib IMPORT exit,atexit;
*)
#if Seimet
CONST F10 = 00A000100H;
      F11 = 00B020101H;
      F12 = 00C020101H;
      F13 = 00D000101H;
      F14 = 00E020101H;
      F15 = 00F010101H;
      F16 = 010020100H;
      F17 = 011000100H;
      F18 = 012010301H;
      F19 = 013000100H;
      F24 = 018020100H;
#endif

TYPE ApplInitPtr = POINTER TO ApplInitRec;
     ApplInitRec = RECORD
                     Next: ApplInitPtr;
                     Proc: ApplInitProc;
                   END;

VAR ApplInitList: ApplInitPtr;
    CurrApplInit: ApplInitPtr;

PROCEDURE applinit(): SIGNEDWORD;
BEGIN
  crystal(10,0,1,0);
#if ST
  KAOS:= IntIn.Magic = 04B414F53H;
#endif
  RETURN IntOut[0];
END applinit;

PROCEDURE ApplInit(): SIGNEDWORD;

VAR ApId: SIGNEDWORD;

BEGIN
  CurrApplInit:= ApplInitList;

  IF CurrApplInit # NIL THEN
    ApId:= 0; (* this is necessary for the following while loop *)
  ELSE
    ApId:= -1; (* ALLOCATE has failed *)
  END;

  WHILE (CurrApplInit # NIL) AND (ApId >= 0) DO
    ApId:= CurrApplInit^.Proc();
    ApplInitList:= CurrApplInit;
    CurrApplInit:= CurrApplInit^.Next;
    DISPOSE(ApplInitList); (* cleaning things up... *)
  END;

  RETURN ApId;
END ApplInit;

PROCEDURE ApplRead(    Id     : SIGNEDWORD;
                       Length : UNSIGNEDWORD;
                   VAR PBuffer: ARRAY OF ANYTYPE): BOOLEAN;
BEGIN
  WITH IntIn DO
    Array[0]:= Id;
    Array[1]:= Length;
  END;
  Addr[0]:= ADR(PBuffer);
  crystal(11,2,1,1);
  RETURN IntOut[0] > 0;
END ApplRead;

PROCEDURE ApplWrite(    Id     : SIGNEDWORD;
                        Length : UNSIGNEDWORD;
                    VAR PBuffer: ARRAY OF ANYTYPE);
BEGIN
  WITH IntIn DO
    Array[0]:= Id;
    Array[1]:= Length;
  END;
  Addr[0]:= ADR(PBuffer);
  crystal(12,2,1,1);
END ApplWrite;

PROCEDURE ApplFind(VAR Name: ARRAY OF CHAR): SIGNEDWORD;
BEGIN
  Addr[0]:= ADR(Name);
  crystal(13,0,1,1);
  RETURN IntOut[0];
END ApplFind;

PROCEDURE ApplTPlay(PTape : TapePtr;
                    Length: EventTape;
                    Scale : UNSIGNEDWORD);
BEGIN
#if ST
  IF Version() >= 0120H THEN
#endif
    WITH IntIn DO
      Array[0]:= Length;
      Array[1]:= Scale;
    END;
    Addr[0]:= PTape;
    crystal(14,2,1,1);
#if ST
  ELSE
    IntOut[0]:= 0; (* error *)
  END;
#endif
END ApplTPlay;

PROCEDURE ApplTRecord(PTape : TapePtr;
                      Length: EventTape): EventTape;
BEGIN
#if ST
  IF Version() >= 0120H THEN
#endif
    IntIn.Array[0]:= Length;
    Addr[0]:= PTape;
    crystal(15,1,1,1);
    RETURN IntOut[0];
#if ST
  ELSE
    RETURN 0; (* error *)
  END;
#endif
END ApplTRecord;

PROCEDURE ApplBVSet(BVDisk: WORDSET;
                    BVHard: WORDSET);
BEGIN
#if ST
#if ABC
#warning ...taking care of ABC-GEM
  IF (Version() = 0220H) OR (Version() = 1042H) OR (Version() = 0399H) THEN
#endif
#else
  IF Version() >= 0220H THEN (* GEM 2.x, GEM 3.x *)
#endif

#if ST
#if ABC
    WITH IntIn DO
      Array[0]:= CAST(Integer,BVDisk);
      Array[1]:= CAST(Integer,BVHard);
    END;
    crystal(16,2,1,0);
  END;
#else

#endif
#else
    WITH IntIn DO
      Array[0]:= CAST(Integer,BVDisk);
      Array[1]:= CAST(Integer,BVHard);
    END;
    crystal(16,2,1,0);
  END;
#endif
END ApplBVSet;

PROCEDURE ApplYield;
#if (defined MM2)
(*$L-*)
#endif

CONST OpCode = 0C9H;

#if (defined ANAM2) || (defined LPRM2) || (defined SPCM2) || \
    (defined HM2)   || (defined TDIM2) || (defined FTLM2)
      trap2  = 4E42H;
#elif (defined LM2) || (defined FSTM2) || (defined SDSM2) || \
      (defined TSM2_2)
      GEM    = 0EFH;
#endif

#ifdef TSM2_2

TYPE CODE = ARRAY[0..7] OF BYTE;

(*#call(inline=>on) *)
PROCEDURE applyield = CODE(0B9H,0C9H,000H, (* mov cx,OpCode *)
                           0BAH,000H,000H, (* mov dx,0      *)
                           0CDH,GEM);      (* int GEM       *)
(*#call(inline=>off) *)
#endif

BEGIN
#if (defined LPRM2) || (defined SPCM2)
  INLINE(303CH,OpCode); (* move.w #OpCode,d0 *)
  INLINE(trap2);        (* trap   #2         *)

#elif (defined HM2)
  CODE(303CH);  (* move.w #OpCode,d0 *)
  CODE(OpCode);
  CODE(trap2);  (* trap   #2         *)

#elif (defined TDIM2) || (defined ANAM2) || (defined FTLM2)
  CODE(303CH,OpCode); (* move.w #OpCode,d0 *)
  CODE(trap2);        (* trap   #2         *)

#elif (defined MM2)
  ASSEMBLER
    MOVE.W #OpCode,D0
    TRAP   #2
  END;

#elif (defined MSM2)
  (*$A+*)
    MOVE.W #OpCode,D0
    TRAP   #2
  (*$A-*)

#elif (defined FSTM2)
  ASM
    MOV CX,OpCode
    MOV DX,0
    INT GEM
  END;

#elif (defined LM2)
  SETREG(CX,OpCode);
  SETREG(DX,0);
  SWI(GEM);

#elif (defined SDSM2)
  RegCX:= OpCode;
  RegDX:= 0;
  SWI(GEM);

#elif (defined TSM2_1) || (defined TSM2_2)
  applyield;

#elif (defined XAM2) || (defined XHM2)
  crystal(17,0,1,0);

#endif
(* alternatively:

  WITH IntIn DO
    Array[0]:= 0;
    Array[1]:= 0;
  END;
  crystal(24,2,1,0);

   for KAOS, GEM 2.x or higher only:

  crystal(17,0,1,0);

*)
END ApplYield;
#if (defined MM2)
(*$L= *)
#endif

PROCEDURE ApplSearch(    Mode: UNSIGNEDWORD;
                     VAR Name: ARRAY OF CHAR;
                     VAR Type: UNSIGNEDWORD;
                     VAR Id  : UNSIGNEDWORD): BOOLEAN;
BEGIN
#if ST
  IF (Version() >= 0399H) AND (Version() < 1042H) THEN
    IntIn.Array[0]:= Mode;
    Addr[0]:= ADR(Name);
    crystal(18,1,3,1);
    Type:= IntOut[1];
    Id:= IntOut[2];
    RETURN IntOut[0] = 1;
  END;
#endif
  RETURN FALSE;
END ApplSearch;

TYPE ApplExitPtr = POINTER TO ApplExitRec;
     ApplExitRec = RECORD
                     Next: ApplExitPtr;
                     Proc: ApplExitProc;
                   END;

VAR ApplExitList: ApplExitPtr;
    CurrApplExit: ApplExitPtr;

PROCEDURE applexit;
BEGIN
  IF Global.ApId >= 0 THEN
    crystal(19,0,1,0);
    Global.ApVersion:= 0; (* no more AES calls *)
    Global.ApId:= -1; (* protection versus multiple calls *)
  END;
END applexit;

PROCEDURE ApplExit;
BEGIN
  CurrApplExit:= ApplExitList;

  WHILE CurrApplExit # NIL DO
    CurrApplExit^.Proc();
    ApplExitList:= CurrApplExit;
    CurrApplExit:= CurrApplExit^.Next;
    DISPOSE(ApplExitList);
  END;
END ApplExit;

PROCEDURE AddApplInit(InitProc: ApplInitProc);
BEGIN
  IF CurrApplInit # NIL THEN
    NEW(CurrApplInit^.Next); (* NIL in case of failure *)
    CurrApplInit:= CurrApplInit^.Next;
  ELSE
    (*exit(ENOMEM)*);
  END;

  IF CurrApplInit # NIL THEN
    WITH CurrApplInit^ DO
      Next:= NIL;
      Proc:= InitProc;
    END;
  END;
END AddApplInit;

PROCEDURE AddApplExit(ExitProc: ApplExitProc);
BEGIN
  NEW(CurrApplExit); (* NIL in case of failure *)
  IF CurrApplExit # NIL THEN
    WITH CurrApplExit^ DO
      Next:= ApplExitList;
      Proc:= ExitProc;
    END;
    ApplExitList:= CurrApplExit;
  ELSE
    (*exit(ENOMEM)*);
  END;
END AddApplExit;

BEGIN
  NEW(ApplInitList);
  IF ApplInitList # NIL THEN
    ApplInitList^.Next:= NIL;
    ApplInitList^.Proc:= applinit;
  END;
  CurrApplInit:= ApplInitList; (* may be NIL, necessary for AddApplInit() *)

  NEW(ApplExitList);
  IF ApplExitList # NIL THEN
    ApplExitList^.Next:= NIL;
    ApplExitList^.Proc:= applexit;
  END;
(*CurrApplExit:= ApplExitList; not necessary *)

(*
  atexit(ApplExit);
*)
END ApplMgr.